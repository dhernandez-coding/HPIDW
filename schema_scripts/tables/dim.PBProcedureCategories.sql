CREATE TABLE [dim].[PBProcedureCategories] (
    [CategoryID] INT IDENTITY(1000,1) NOT NULL,
    [CategoryName] VARCHAR(255) NOT NULL,
    [VisitTypeID] INT NULL,
    [CategoryPriority] FLOAT NULL,
    [Priority] VARCHAR(100) NULL,
    [IsActive] BIT NOT NULL DEFAULT ((1)),
    [CreatedDatetime] DATETIME NOT NULL DEFAULT (getdate()),
    [UpdatedDatetime] DATETIME NOT NULL DEFAULT (getdate()),
    [ModifiedBy] VARCHAR(100) NULL,
    CONSTRAINT [PK_PBProcedureCategories] PRIMARY KEY ([CategoryID])
);
GO
