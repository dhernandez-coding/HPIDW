CREATE VIEW rpt.vETLAgentJobHistory AS
SELECT 
    jobs.job_id AS JobID,
    jobs.name AS JobName,
    CONVERT(VARCHAR(10), 
        CAST(CAST(history.run_date AS CHAR(8)) AS DATE), 120) AS RunDate,
    RIGHT('0' + CAST(history.run_time / 10000 AS VARCHAR(2)), 2) + ':' +
    RIGHT('0' + CAST((history.run_time / 100) % 100 AS VARCHAR(2)), 2) + ':' +
    RIGHT('0' + CAST(history.run_time % 100 AS VARCHAR(2)), 2) AS RunTime,
    RIGHT('0' + CAST(history.run_duration / 10000 AS VARCHAR(2)), 2) + ':' +
    RIGHT('0' + CAST((history.run_duration / 100) % 100 AS VARCHAR(2)), 2) + ':' +
    RIGHT('0' + CAST(history.run_duration % 100 AS VARCHAR(2)), 2) AS RunDuration,
    CASE history.run_status 
        WHEN 0 THEN 'Failed'
        WHEN 1 THEN 'Succeeded'
        WHEN 2 THEN 'Retry'
        WHEN 3 THEN 'Canceled'
        WHEN 4 THEN 'In Progress'
        ELSE 'Unknown'
    END AS RunStatus,
    history.sql_message_id AS SQLMessageID,
    history.sql_severity AS SQLSeverity,
    history.message AS Message,
    history.step_name AS StepName,
    history.step_id AS StepID,
    history.server AS ServerName,
    history.instance_id AS InstanceID
FROM 
    msdb.dbo.sysjobs AS jobs
INNER JOIN 
    msdb.dbo.sysjobhistory AS history 
    ON jobs.job_id = history.job_id
WHERE 1=1
    --history.step_id = 0 -- Select only the final status of the job (not each step's status)
--ORDER BY 
--    CAST(CAST(history.run_date AS CHAR(8)) AS DATE) DESC, 
--    history.run_time DESC;
GO
