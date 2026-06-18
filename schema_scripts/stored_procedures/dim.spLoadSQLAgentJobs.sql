CREATE PROCEDURE [dim].[spLoadSQLAgentJobs] AS
BEGIN
     SET NOCOUNT ON;
	 -- STEP1: Truncate the Table
	 TRUNCATE TABLE dim.SQLAgentJobs

	 -- STEP2: Load
    ;WITH JobRuns AS (
        SELECT  
            j.job_id,
            s.step_id,
            j.name AS JobName,
            s.step_name AS StepName,
            s.command AS FullCommand,
            CONVERT(DATETIME, 
                STUFF(STUFF(CAST(h.run_date AS CHAR(8)), 5, 0, '-'), 8, 0, '-') + ' ' +
                STUFF(STUFF(RIGHT('000000' + CAST(h.run_time AS VARCHAR(6)), 6), 3, 0, ':'), 6, 0, ':')
            ) AS LastRunDatetime,
            CAST(CONVERT(CHAR(8), h.run_date) AS DATE) AS LastRunDate,
            h.run_time AS RunTime,
            ROW_NUMBER() OVER (PARTITION BY j.job_id, s.step_id ORDER BY h.run_date DESC, h.run_time DESC) AS rn,
			s.database_name
        FROM msdb.dbo.sysjobs j
        JOIN msdb.dbo.sysjobsteps s ON j.job_id = s.job_id
        JOIN msdb.dbo.sysjobhistory h ON j.job_id = h.job_id AND s.step_id = h.step_id
        WHERE h.run_status = 1
          AND CHARINDEX('exec', LOWER(s.command)) > 0
    ),
    LatestRuns AS (
        SELECT *
        FROM JobRuns
        WHERE rn = 1
    )


    INSERT INTO dim.SQLAgentJobs (
    JobName,
    StepName,
    ExecStatement,
    LastRunDate,
    RunTime,
    LastRunDatetime,
    StoredProcedure,
    DatabaseName
)
SELECT 
    JobName,
    StepName,
    LTRIM(RTRIM(ProcedureCall)) AS ExecStatement,
    LastRunDate,
    RunTime,
    LastRunDatetime,
    sp_normalized.NormalizedStoredProcedure AS StoredProcedure,
    database_name
FROM LatestRuns
CROSS APPLY dbo.SplitExecCalls(FullCommand)

-- Step 1: Basic clean-up (remove EXEC, brackets, trim)
CROSS APPLY (
    SELECT 
        LTRIM(RTRIM(
            REPLACE(REPLACE(
                REPLACE(REPLACE(ProcedureCall, 'EXEC', ''), 'exec', ''),
            '[', ''), ']', '')
        )) AS CleanedSP
) AS sp_cleaned

-- Step 2: Remove any parameters (anything starting with @)
CROSS APPLY (
    SELECT 
        -- If there's an @, cut the string at that point
        CASE 
            WHEN CHARINDEX('@', sp_cleaned.CleanedSP) > 0 
                THEN LEFT(sp_cleaned.CleanedSP, CHARINDEX('@', sp_cleaned.CleanedSP) - 1)
            ELSE sp_cleaned.CleanedSP
        END AS NoParamsSP
) AS sp_noparams

-- Step 3: Normalize to 3-part name
CROSS APPLY (
    SELECT 
        CASE 
            WHEN LEN(sp_noparams.NoParamsSP) - LEN(REPLACE(sp_noparams.NoParamsSP, '.', '')) = 1 
                THEN database_name + '.' + LTRIM(RTRIM(sp_noparams.NoParamsSP))
            ELSE LTRIM(RTRIM(sp_noparams.NoParamsSP))
        END AS NormalizedStoredProcedure
) AS sp_normalized

END;
GO
