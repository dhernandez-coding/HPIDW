CREATE TABLE [dim].[StoreProceduresSources] (
    [StoreProcedureID] INT IDENTITY(1,1) NOT NULL,
    [StoreProcedureSchema] NVARCHAR(128) NOT NULL,
    [StoreProcedureName] NVARCHAR(128) NOT NULL,
    [StoreProcedureTargetDatabase] NVARCHAR(128) NULL,
    [StoreProcedureTargetSchema] NVARCHAR(128) NULL,
    [StoreProcedureTargetTable] NVARCHAR(128) NULL,
    [StoreProcedureSourceServer] NVARCHAR(128) NULL,
    [StoreProcedureSourceDatabase] NVARCHAR(128) NULL,
    [StoreProcedureSourceSchema] NVARCHAR(128) NULL,
    [StoreProcedureSourceTable] NVARCHAR(128) NULL,
    [StoreProcedureLoadDatetime] DATETIME NOT NULL DEFAULT (getdate()),
    CONSTRAINT [PK__StorePro__3BBBA83A8A7FE0B7] PRIMARY KEY ([StoreProcedureID])
);
GO
