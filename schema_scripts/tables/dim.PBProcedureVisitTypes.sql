CREATE TABLE [dim].[PBProcedureVisitTypes] (
    [VisitTypeID] INT IDENTITY(1000,1) NOT NULL,
    [VisitTypeName] VARCHAR(255) NOT NULL,
    [IsActive] BIT NOT NULL DEFAULT ((1)),
    [CreatedDatetime] DATETIME NOT NULL DEFAULT (getdate()),
    [UpdatedDatetime] DATETIME NOT NULL DEFAULT (getdate()),
    [ModifiedBy] VARCHAR(100) NULL,
    CONSTRAINT [PK_PBProcedureVisitTypes] PRIMARY KEY ([VisitTypeID])
);
GO
