CREATE TABLE [dim].[StoreProcedures] (
    [StoreProcedureID] VARCHAR(300) NULL,
    [DatabaseName] VARCHAR(100) NULL,
    [SchemaName] VARCHAR(50) NULL,
    [ProcedureName] VARCHAR(200) NULL,
    [Definition] VARCHAR(MAX) NULL,
    [CreateDate] DATETIME NULL,
    [ModifyDate] DATETIME NULL
);
GO
