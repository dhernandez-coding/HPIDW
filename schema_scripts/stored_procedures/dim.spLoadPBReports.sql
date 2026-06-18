CREATE PROCEDURE [dim].[spLoadPBReports] AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE 
        @PlatformID   NVARCHAR(50) = N'1~PBI',
        @Token        NVARCHAR(MAX),
        @Now          DATETIME      = GETDATE(),
        @DatasourceID INT           = 13,
        @BaseUrl      NVARCHAR(200) = N'https://api.powerbi.com/v1.0/myorg',
        @GroupID      NVARCHAR(100),
        @Url          NVARCHAR(500),
        @ps           NVARCHAR(MAX),
        @cmd          VARCHAR(8000),
        @json         NVARCHAR(MAX);

    -- 1) Token
    SELECT TOP (1) @Token = ReportPlatformAccessToken
    FROM [dim].[ReportPlatforms] WITH (NOLOCK)
    WHERE ReportPlatformID = @PlatformID
      AND ISNULL(ReportPlatformIsActive,1) = 1
    ORDER BY ReportPlatformUpdateDatetime DESC;

    IF @Token IS NULL
    BEGIN
        RAISERROR('No token found in dim.ReportPlatforms for %s',16,1,@PlatformID);
        RETURN;
    END

    IF LEFT(@Token, 7) = N'Bearer ' 
        SET @Token = SUBSTRING(@Token, 8, LEN(@Token) - 7);
    SET @Token = REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(@Token)), CHAR(13), N''), CHAR(10), N''), N'"', N'');

    -- 2) Active workspaces
    IF OBJECT_ID('tempdb..#ws') IS NOT NULL DROP TABLE #ws;
    CREATE TABLE #ws
    (
        PBWorkspaceID       NVARCHAR(150) NOT NULL,
        PBWorkspaceSourceID NVARCHAR(100) NOT NULL
    );

    INSERT #ws (PBWorkspaceID, PBWorkspaceSourceID)
    SELECT W.PBWorkspaceID, W.PBWorkspaceSourceID
    FROM [dim].[PBWorkspaces] AS W WITH (NOLOCK)
    WHERE W.PBWorkspaceDatasourceID = @DatasourceID
      AND W.PBWorkspaceIsActive = 1
      AND LEFT(W.PBWorkspaceID, 2) = '1~';

    -- 3) Staging
    IF OBJECT_ID('tempdb..#stg_rp') IS NOT NULL DROP TABLE #stg_rp;
    CREATE TABLE #stg_rp
    (
        PBReportID              NVARCHAR(150) NOT NULL,
        PBReportDatasourceID    INT           NOT NULL,
        PBReportSourceID        NVARCHAR(100) NOT NULL,
        PBWorkspaceID           NVARCHAR(150) NOT NULL,
        PBWorkspaceSourceID     NVARCHAR(100) NOT NULL,
        PBReportName            NVARCHAR(256) NULL,
        PBReportWebUrl          NVARCHAR(512) NULL,
        PBReportIsActive        BIT           NOT NULL,
        PBReportUpdatedDatetime DATETIME      NOT NULL,
        PBDatasetID             NVARCHAR(100) NULL,
        PBReportDescription     NVARCHAR(MAX) NULL
    );

    -- 4) Cursor
    DECLARE c CURSOR LOCAL FAST_FORWARD FOR
        SELECT PBWorkspaceSourceID FROM #ws;

    OPEN c;
    FETCH NEXT FROM c INTO @GroupID;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @Url = CONCAT(@BaseUrl, N'/groups/', @GroupID, N'/reports?$top=5000');
        SET @json = NULL;

        SET @ps =
              'powershell -NoProfile -Command "'
            + '  $h=@{ Authorization = ''Bearer ' + REPLACE(@Token,'''','''''') + '''; Accept = ''application/json''; ''Accept-Encoding'' = ''identity'' }; '
            + '  $u=''' + @Url + '''; '
            + '  try { '
            + '    $r = Invoke-WebRequest -Uri $u -Headers $h -Method Get -ErrorAction Stop; '
            + '    ''##JSON_BEGIN##''; '
            + '    ($r.Content | ConvertFrom-Json | ConvertTo-Json -Depth 12); '
            + '    ''##JSON_END##''; '
            + '  } catch { '
            + '    ''##ERR_BEGIN##''; '
            + '    if ($_.Exception.Response) { '
            + '      $sr = New-Object IO.StreamReader($_.Exception.Response.GetResponseStream()); '
            + '      $b = $sr.ReadToEnd(); $sr.Close(); $b '
            + '    } else { $_.Exception.Message } '
            + '    ''##ERR_END##''; '
            + '  }"';

        SET @cmd = CONVERT(VARCHAR(8000), @ps);

        IF OBJECT_ID('tempdb..#out') IS NOT NULL DROP TABLE #out;
        CREATE TABLE #out (rn INT IDENTITY(1,1) PRIMARY KEY, line NVARCHAR(4000));

        INSERT #out(line) EXEC master..xp_cmdshell @cmd;

        DECLARE @s INT = (SELECT MIN(rn) FROM #out WHERE line='##JSON_BEGIN##');
        DECLARE @e INT = (SELECT MAX(rn) FROM #out WHERE line='##JSON_END##');

        IF @s IS NOT NULL AND @e IS NOT NULL AND @e > @s
        BEGIN
            SELECT @json = (
    SELECT line
    FROM #out
    WHERE rn > @s AND rn < @e
      AND line IS NOT NULL
      AND line <> 'NULL'
    FOR XML PATH(''), TYPE
).value('.', 'NVARCHAR(MAX)');
        END

        DROP TABLE #out;

        IF @json IS NOT NULL AND LEN(@json) > 0
        BEGIN
            INSERT #stg_rp
            (
                PBReportID,
                PBReportDatasourceID,
                PBReportSourceID,
                PBWorkspaceID,
                PBWorkspaceSourceID,
                PBReportName,
                PBReportWebUrl,
                PBReportIsActive,
                PBReportUpdatedDatetime,
                PBDatasetID,
                PBReportDescription
            )
            SELECT
                PBReportID              = CONCAT('1~', j.[id]),
                PBReportDatasourceID    = @DatasourceID,
                PBReportSourceID        = j.[id],
                PBWorkspaceID           = CONCAT('1~', @GroupID),
                PBWorkspaceSourceID     = @GroupID,
                PBReportName            = j.[name],
                PBReportWebUrl          = j.[webUrl],
                PBReportIsActive        = 1,
                PBReportUpdatedDatetime = @Now,
                PBDatasetID             = j.[datasetId],
                PBReportDescription     = j.[description]
            FROM OPENJSON(@json, '$.value')
            WITH
            (
                [id]          NVARCHAR(100) '$.id',
                [name]        NVARCHAR(256) '$.name',
                [webUrl]      NVARCHAR(512) '$.webUrl',
                [datasetId]   NVARCHAR(100) '$.datasetId',
                [description] NVARCHAR(MAX) '$.description'
            ) j;
        END

        FETCH NEXT FROM c INTO @GroupID;
    END

    CLOSE c;
    DEALLOCATE c;

    -- 5) Reload
    BEGIN TRANSACTION;
        TRUNCATE TABLE [dim].[PBReports];
        INSERT INTO [dim].[PBReports]
        SELECT * FROM #stg_rp;
    COMMIT TRANSACTION;
END
GO
