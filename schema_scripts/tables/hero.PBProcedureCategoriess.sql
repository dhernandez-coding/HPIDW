CREATE TABLE [hero].[PBProcedureCategoriess] (
    [Id] INT NOT NULL,
    [ProcedureCategory] NVARCHAR(MAX) NOT NULL,
    [ProcedureCategoryPriority] FLOAT NOT NULL,
    [ProcedureCategoryVisitType] NVARCHAR(MAX) NOT NULL,
    [IsDeleted] BIT NOT NULL,
    [Priority] NVARCHAR(MAX) NOT NULL,
    [CreatedDate] DATETIME2 NULL,
    [ModifiedDate] DATETIME2 NULL,
    [ModifiedBy] NVARCHAR(MAX) NULL,
    [DeletedDate] DATETIME2 NULL,
    [DeletedBy] NVARCHAR(MAX) NULL,
    [IsActive] BIT NOT NULL
);
GO
