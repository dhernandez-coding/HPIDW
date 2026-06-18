CREATE TABLE [etl].[ModMed_RunLog] (
    [LogID] INT IDENTITY(1,1) NOT NULL,
    [RunDate] DATETIME NULL DEFAULT (getdate()),
    [ScriptName] VARCHAR(100) NULL,
    [Status] VARCHAR(20) NULL,
    [ErrorMessage] NVARCHAR(MAX) NULL,
    CONSTRAINT [PK__ModMed_R__5E5499A83E643B92] PRIMARY KEY ([LogID])
);
GO
