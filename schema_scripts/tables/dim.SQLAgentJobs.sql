CREATE TABLE [dim].[SQLAgentJobs] (
    [JobExecutionID] INT IDENTITY(1,1) NOT NULL,
    [JobName] NVARCHAR(255) NULL,
    [StepName] NVARCHAR(255) NULL,
    [ExecStatement] NVARCHAR(MAX) NULL,
    [LastRunDate] DATE NULL,
    [RunTime] INT NULL,
    [LastRunDatetime] DATETIME NULL,
    [LoadDatetime] DATETIME NULL DEFAULT (getdate()),
    [StoredProcedure] VARCHAR(400) NULL,
    [DatabaseName] VARCHAR(200) NULL,
    CONSTRAINT [PK__SQLAgent__00DAA4C8E8409D8C] PRIMARY KEY ([JobExecutionID])
);
GO
