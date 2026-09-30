CREATE TABLE [dim].[PBProcedureServiceLines] (
    [ServiceLineID] INT IDENTITY(1000,1) NOT NULL,
    [ServiceLineName] VARCHAR(255) NOT NULL,
    [ServiceLineGroupID] FLOAT NULL,
    [IsActive] BIT NOT NULL DEFAULT ((1)),
    [CreatedDatetime] DATETIME NOT NULL DEFAULT (getdate()),
    [UpdatedDatetime] DATETIME NOT NULL DEFAULT (getdate()),
    [ModifiedBy] VARCHAR(100) NULL,
    CONSTRAINT [PK_PBProcedureServiceLines] PRIMARY KEY ([ServiceLineID])
);
GO
