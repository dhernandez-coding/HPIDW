CREATE   PROCEDURE [dim].[spLoadPBWorkspaces] AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE 
        @PlatformID NVARCHAR(50) = N'1~PBI',
        @Token      NVARCHAR(MAX),
        @Url        NVARCHAR(400) = N'https://api.powerbi.com/v1.0/myorg/groups?$top=5000',
        @ps         NVARCHAR(MAX),
        @cmd        VARCHAR(8000),
        @json       NVARCHAR(MAX),
        @Now        DATETIME      = GETDATE(),
        @DatasourceID INT         = 13;  -- your constant

    /* Pull latest active token from dim.ReportPlatforms */
    SELECT TOP (1) @Token = ReportPlatformAccessToken
    FROM [HPIDW].[dim].[ReportPlatforms] WITH (NOLOCK)
    WHERE ReportPlatformID = @PlatformID
      AND ISNULL(ReportPlatformIsActive,1) = 1
    ORDER BY ReportPlatformUpdateDatetime DESC;

    IF @Token IS NULL
    BEGIN
        RAISERROR('No token found in dim.ReportPlatforms for %s',16,1,@PlatformID);
        RETURN;
    END

    -- Normalize token text
    IF LEFT(@Token, 7) = N'Bearer ' 
        SET @Token = SUBSTRING(@Token, 8, LEN(@Token) - 7);
    SET @Token = REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(@Token)), CHAR(13), N''), CHAR(10), N''), N'"', N'');

    /* Call Power BI API and capture JSON between markers */
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

    IF @s IS NULL OR @e IS NULL OR @e <= @s
    BEGIN
        -- show error block if present
        SELECT TOP 1000 line FROM #out ORDER BY rn;
        DROP TABLE #out;
        RAISERROR('No JSON block returned from Power BI API',16,1);
        RETURN;
    END

    SELECT @json = (
        SELECT line
        FROM #out
        WHERE rn > @s AND rn < @e AND line IS NOT NULL AND line <> 'NULL'
        ORDER BY rn
        FOR XML PATH(''), TYPE
    ).value('.','nvarchar(max)');

    DROP TABLE #out;

    IF @json IS NULL OR LEN(@json)=0
    BEGIN
        RAISERROR('JSON payload empty',16,1);
        RETURN;
    END

    /* Stage results */
    IF OBJECT_ID('tempdb..#ws') IS NOT NULL DROP TABLE #ws;
    CREATE TABLE #ws
    (
        PBWorkspaceSourceID NVARCHAR(100) NOT NULL,
        PBWorkspaceName     NVARCHAR(256) NULL,
        PBWorkspaceType     NVARCHAR(128) NULL,
        PBWorkspaceState    NVARCHAR(64)  NULL,
        PBWorkspaceOnCapacity BIT NULL
    );

    INSERT #ws (PBWorkspaceSourceID, PBWorkspaceName, PBWorkspaceOnCapacity, PBWorkspaceType, PBWorkspaceState)
    SELECT 
        j.[id],
        j.[name],
        TRY_CAST(j.[isOnDedicatedCapacity] AS BIT),
        j.[type],
        j.[state]
    FROM OPENJSON(@json, '$.value') WITH
    (
        [id] NVARCHAR(100) '$.id',
        [name] NVARCHAR(256) '$.name',
        [isOnDedicatedCapacity] NVARCHAR(10) '$.isOnDedicatedCapacity',
        [type] NVARCHAR(128) '$.type',
        [state] NVARCHAR(64) '$.state'
    ) AS j;

    /* Upsert into dim.PBWorkspaces */
    MERGE [dim].[PBWorkspaces] AS tgt
    USING (
        SELECT
            PBWorkspaceID          = CONCAT('1~', w.PBWorkspaceSourceID),
            PBWorkspaceDatasourceID= @DatasourceID,
            PBWorkspaceSourceID    = w.PBWorkspaceSourceID,
            PBWorkspaceName        = w.PBWorkspaceName,
            PBWorkspaceIsActive    = CAST(1 AS BIT),
            PBWorkspaceUpdatedDatetime = @Now
        FROM #ws AS w
    ) AS src
    ON tgt.PBWorkspaceID = src.PBWorkspaceID
    WHEN MATCHED THEN
        UPDATE SET
            tgt.PBWorkspaceDatasourceID   = src.PBWorkspaceDatasourceID,
            tgt.PBWorkspaceSourceID       = src.PBWorkspaceSourceID,
            tgt.PBWorkspaceName           = src.PBWorkspaceName,
            tgt.PBWorkspaceIsActive       = 1,
            tgt.PBWorkspaceUpdatedDatetime= @Now
    WHEN NOT MATCHED BY TARGET THEN
        INSERT
        (
            PBWorkspaceID,
            PBWorkspaceDatasourceID,
            PBWorkspaceSourceID,
            PBWorkspaceName,
            PBWorkspaceIsActive,
            PBWorkspaceUpdatedDatetime
        )
        VALUES
        (
            src.PBWorkspaceID,
            src.PBWorkspaceDatasourceID,
            src.PBWorkspaceSourceID,
            src.PBWorkspaceName,
            src.PBWorkspaceIsActive,
            src.PBWorkspaceUpdatedDatetime
        )
    -- Optionally capture the action
    OUTPUT $action AS MergeAction, inserted.PBWorkspaceID;

    /* Deactivate rows that are no longer returned by the API for this datasource */
    UPDATE W
    SET 
        W.PBWorkspaceIsActive = 0,
        W.PBWorkspaceUpdatedDatetime = @Now
    FROM [dim].[PBWorkspaces] AS W
    WHERE W.PBWorkspaceDatasourceID = @DatasourceID
      AND LEFT(W.PBWorkspaceID, 2) = '1~'
      AND NOT EXISTS (
            SELECT 1
            FROM #ws AS C
            WHERE CONCAT('1~', C.PBWorkspaceSourceID) = W.PBWorkspaceID
      );

END
GO
