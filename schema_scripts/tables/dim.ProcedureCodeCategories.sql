CREATE TABLE [dim].[ProcedureCodeCategories] (
    [ProcedureCodeCategoryID] VARCHAR(50) NOT NULL,
    [ProcedureCodeCategoryDataSourceID] INT NULL,
    [ProcedureCodeCategorySourceID] VARCHAR(50) NULL,
    [ProcedureCodeCategoryAbbreviation] VARCHAR(50) NULL,
    [ProcedureCodeCategoryDescription] VARCHAR(50) NULL,
    [ProcedureCodeCategoryIsActive] BIT NULL,
    [ProcedureCodeCategoryUpdatedDateTime] DATETIME NULL,
    CONSTRAINT [PK_ProcedureCodeCategories] PRIMARY KEY ([ProcedureCodeCategoryID])
);
GO
