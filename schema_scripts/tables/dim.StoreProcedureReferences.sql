CREATE TABLE [dim].[StoreProcedureReferences] (
    [StoreProcedureReferenceID] VARCHAR(500) NOT NULL,
    [StoreProcedureID] VARCHAR(300) NULL,
    [StoreProcedureSchema] VARCHAR(100) NULL,
    [StoreProcedureName] VARCHAR(200) NULL,
    [ReferencedSchema] VARCHAR(100) NULL,
    [ReferencedEntity] VARCHAR(200) NULL,
    [ReferencedObjectID] VARCHAR(300) NULL,
    [IsRead] BIT NULL,
    [IsWrite] BIT NULL,
    [LoadDatetime] DATETIME2 NULL,
    CONSTRAINT [PK__StorePro__90BB2258E617A344] PRIMARY KEY ([StoreProcedureReferenceID])
);
GO
