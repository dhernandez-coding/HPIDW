CREATE TABLE [dim].[DWViews] (
    [DataBaseName] SYSNAME NOT NULL,
    [SchemaName] SYSNAME NOT NULL,
    [ViewName] SYSNAME NOT NULL,
    [CreateDatetime] DATETIME NULL,
    [ViewLastModifiedDatetime] DATETIME NULL,
    [LoadDatetime] DATETIME NULL DEFAULT (getdate()),
    [ViewID] VARCHAR(350) NULL
);
GO
