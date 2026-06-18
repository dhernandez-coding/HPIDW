CREATE   PROCEDURE [dim].[spLoadPBDatasets] AS
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

    /* 1) Token */
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

    /* 2) Active workspaces */
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

    /* 3) Staging table */
    IF OBJECT_ID('tempdb..#stg_ds') IS NOT NULL DROP TABLE #stg_ds;
    CREATE TABLE #stg_ds
    (
        PBDatasetID               NVARCHAR(150) NOT NULL,  -- '1~' + datasetId
        PBDatasetDatasourceID     INT           NOT NULL,  -- 13
        PBDatasetSourceID         NVARCHAR(100) NOT NULL,  -- datasetId
        PBWorkspaceID             NVARCHAR(150) NOT NULL,  -- '1~' + groupId
        PBWorkspaceSourceID       NVARCHAR(100) NOT NULL,  -- groupId
        PBDatasetName             NVARCHAR(256) NULL,
        PBDatasetDefaultMode      NVARCHAR(64)  NULL,
        PBDatasetIsActive         BIT           NOT NULL,
        PBDatasetUpdatedDatetime  DATETIME      NOT NULL
    );

    /* 4) Cursor over workspaces */
    DECLARE c CURSOR LOCAL FAST_FORWARD FOR
        SELECT PBWorkspaceSourceID FROM #ws;

    OPEN c;
    FETCH NEXT FROM c INTO @GroupID;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @Url = CONCAT(@BaseUrl, N'/groups/', @GroupID, N'/datasets?$top=5000');
        SET @json = NULL; -- reset per-iteration

        /* PS call */
        SET @ps =
              'powershell -NoProfile -Command "'
            + '  $h=@{ Authorization = ''Bearer ' + REPLACE(@Token,'''','''''') + '''; Accept = ''application/json''; ''Accept-Encoding'' = ''identity'' }; '
            + '  $u=''' + @Url + '''; '
            + '  try { '
            + '    $r = Invoke-WebRequest -Uri $u -Headers $h -Method Get -ErrorAction Stop; '
            + '    ''##JSON_BEGIN##''; '
            + '    ($r.Content | ConvertFrom-Json | ConvertTo-Json -Depth 12 -Compress); '
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
        CREATE TABLE #out (rn INT IDENTITY(1,1) PRIMARY KEY, line NVARCHAR(4000) NULL);

        INSERT #out(line) EXEC master..xp_cmdshell @cmd;

        DECLARE @s INT = (SELECT MIN(rn) FROM #out WHERE line='##JSON_BEGIN##');
        DECLARE @e INT = (SELECT MAX(rn) FROM #out WHERE line='##JSON_END##');

        IF @s IS NOT NULL AND @e IS NOT NULL AND @e > @s
        BEGIN
            SELECT @json = (
                SELECT line
                FROM #out
                WHERE rn > @s AND rn < @e AND line IS NOT NULL AND line <> 'NULL'
                ORDER BY rn
                FOR XML PATH(''), TYPE
            ).value('.','nvarchar(max)');
        END

        DROP TABLE #out;

        IF @json IS NOT NULL AND LEN(@json) > 0
        BEGIN
            INSERT #stg_ds
            (
                PBDatasetID,
                PBDatasetDatasourceID,
                PBDatasetSourceID,
                PBWorkspaceID,
                PBWorkspaceSourceID,
                PBDatasetName,
                PBDatasetDefaultMode,
                PBDatasetIsActive,
                PBDatasetUpdatedDatetime
            )
            SELECT
                PBDatasetID              = CONCAT('1~', j.[id]),
                PBDatasetDatasourceID    = @DatasourceID,
                PBDatasetSourceID        = j.[id],
                PBWorkspaceID            = CONCAT('1~', @GroupID),
                PBWorkspaceSourceID      = @GroupID,
                PBDatasetName            = j.[name],
                PBDatasetDefaultMode     = j.[defaultMode],
                PBDatasetIsActive        = CAST(1 AS BIT),
                PBDatasetUpdatedDatetime = @Now
            FROM OPENJSON(@json, '$.value') WITH
            (
                [id]          NVARCHAR(100) '$.id',
                [name]        NVARCHAR(256) '$.name',
                [defaultMode] NVARCHAR(64)  '$.defaultMode'
            ) AS j;
        END

        FETCH NEXT FROM c INTO @GroupID;
    END

    CLOSE c;
    DEALLOCATE c;

    /* 5) Upsert */
    MERGE [dim].[PBDatasets] AS tgt
    USING #stg_ds AS src
    ON tgt.PBDatasetID = src.PBDatasetID
    WHEN MATCHED THEN
        UPDATE SET
            tgt.PBDatasetDatasourceID    = src.PBDatasetDatasourceID,
            tgt.PBDatasetSourceID        = src.PBDatasetSourceID,
            tgt.PBWorkspaceID            = src.PBWorkspaceID,
            tgt.PBWorkspaceSourceID      = src.PBWorkspaceSourceID,
            tgt.PBDatasetName            = src.PBDatasetName,
            tgt.PBDatasetIsActive        = 1,
            tgt.PBDatasetUpdatedDatetime = @Now
    WHEN NOT MATCHED BY TARGET THEN
        INSERT
        (
            PBDatasetID,
            PBDatasetDatasourceID,
            PBDatasetSourceID,
            PBWorkspaceID,
            PBWorkspaceSourceID,
            PBDatasetName,
            PBDatasetIsActive,
            PBDatasetUpdatedDatetime
        )
        VALUES
        (
            src.PBDatasetID,
            src.PBDatasetDatasourceID,
            src.PBDatasetSourceID,
            src.PBWorkspaceID,
            src.PBWorkspaceSourceID,
            src.PBDatasetName,
            src.PBDatasetIsActive,
            src.PBDatasetUpdatedDatetime
        );

    /* 6) Deactivate missing */
    UPDATE D
    SET 
        D.PBDatasetIsActive = 0,
        D.PBDatasetUpdatedDatetime = @Now
    FROM [dim].[PBDatasets] AS D
    WHERE D.PBDatasetDatasourceID = @DatasourceID
      AND LEFT(D.PBDatasetID, 2) = '1~'
      AND NOT EXISTS (
            SELECT 1
            FROM #stg_ds AS S
            WHERE S.PBDatasetID = D.PBDatasetID
      );

END
GO
