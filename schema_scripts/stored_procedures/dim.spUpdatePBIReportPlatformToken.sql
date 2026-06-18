CREATE PROCEDURE [dim].[spUpdatePBIReportPlatformToken] AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE 
        @ReportPlatformID NVARCHAR(50)  = N'1~PBI',
        @TenantId         NVARCHAR(64)  = N'c7ae6850-3a33-412b-a092-8bc8d5dc590e',
        @ClientId         NVARCHAR(64)  = N'3c452bde-6750-454a-b3fa-44cfbc9cf0ce',
        @ClientSecret     NVARCHAR(256) = N'********',
        @Scope            NVARCHAR(512) = N'https://analysis.windows.net/powerbi/api/.default';

    IF NOT EXISTS (SELECT 1 FROM [dim].[ReportPlatforms] WITH (NOLOCK) WHERE [ReportPlatformID] = @ReportPlatformID)
    BEGIN
        RAISERROR('ReportPlatformID not found in dim.ReportPlatforms', 16, 1);
        RETURN;
    END

    -- PowerShell: get token, split into <=200-char chunks, print "####:chunk" lines so SQL can reassemble in order
    DECLARE @ps NVARCHAR(MAX) =
          N'powershell -NoProfile -Command "'
        + N'$ErrorActionPreference=''Stop''; '
        + N'$u=''https://login.microsoftonline.com/' + @TenantId + N'/oauth2/v2.0/token''; '
        + N'$b=@{grant_type=''client_credentials''; client_id=''' + @ClientId + N'''; client_secret=''' + @ClientSecret + N'''; scope=''' + @Scope + N'''}; '
        + N'$r=Invoke-RestMethod -Method Post -Uri $u -Body $b -ContentType ''application/x-www-form-urlencoded''; '
        + N'if(-not $r.access_token){ throw ''No access_token in response'' }; '
        + N'$t=$r.access_token.Trim(); '
        + N'$m=[regex]::Matches($t,''.{1,200}''); '
        + N'for($i=0;$i -lt $m.Count;$i++){ Write-Output (''{0:D4}:{1}'' -f $i,$m[$i].Value) }" 2>&1';

    DECLARE @cmd VARCHAR(8000) = CONVERT(VARCHAR(8000), @ps);

    IF OBJECT_ID('tempdb..#out')    IS NOT NULL DROP TABLE #out;
    IF OBJECT_ID('tempdb..#parsed') IS NOT NULL DROP TABLE #parsed;

    CREATE TABLE #out(line NVARCHAR(4000) NULL);

    INSERT #out EXEC master..xp_cmdshell @cmd;

    -- Parse xp_cmdshell output into #parsed (indexed chunk lines vs. error/info lines)
    CREATE TABLE #parsed
    (
        idx   INT NULL,
        piece NVARCHAR(MAX) NULL
    );

    INSERT #parsed(idx, piece)
    SELECT
        CASE 
            WHEN TRY_CONVERT(int, LEFT(line,4)) IS NOT NULL AND SUBSTRING(line,5,1)=':' 
            THEN TRY_CONVERT(int, LEFT(line,4)) 
        END AS idx,
        CASE 
            WHEN TRY_CONVERT(int, LEFT(line,4)) IS NOT NULL AND SUBSTRING(line,5,1)=':' 
            THEN SUBSTRING(line,6,4000) 
            ELSE line 
        END AS piece
    FROM #out
    WHERE line IS NOT NULL;

    -- If PowerShell emitted any errors/warnings, show them
    SELECT piece AS PowerShellOutput
    FROM #parsed
    WHERE idx IS NULL;

    -- Reconstruct token in order of idx (XML concat, compatible everywhere)
    DECLARE @Token NVARCHAR(MAX) =
    (
        SELECT (
            SELECT piece AS [text()]
            FROM #parsed
            WHERE idx IS NOT NULL
            ORDER BY idx
            FOR XML PATH(''), TYPE
        ).value('.','nvarchar(max)')
    );

    IF (@Token IS NULL OR LEN(@Token) < 500 OR CHARINDEX('.', @Token) = 0)
    BEGIN
        RAISERROR('Failed to reconstruct a valid token. Check PowerShellOutput above for errors.', 16, 1);
        RETURN;
    END

    -- Update the platform row
    UPDATE rp
    SET rp.[ReportPlatformAccessToken]    = @Token,
        rp.[ReportPlatformTenant]         = @TenantId,
        rp.[ReportPlatformUpdateDatetime] = GETDATE()
    FROM [dim].[ReportPlatforms] rp
    WHERE rp.[ReportPlatformID] = @ReportPlatformID;

    -- Confirm
    SELECT
        ReportPlatformID,
        ReportPlatformName,
        LEFT(ReportPlatformAccessToken, 40) + N'...' AS TokenPreview,
        ReportPlatformUpdateDatetime
    FROM [dim].[ReportPlatforms]
    WHERE ReportPlatformID = @ReportPlatformID;
END
GO
