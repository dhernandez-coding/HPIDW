CREATE TABLE [fact].[Budgets] (
    [BudgetID] VARCHAR(100) NOT NULL,
    [BudgetDatasourceID] INT NOT NULL,
    [BudgetSourceID] VARCHAR(100) NULL,
    [BudgetTypeID] VARCHAR(100) NOT NULL,
    [BudgetDate] DATE NULL,
    [BudgetLocationID] VARCHAR(100) NULL,
    [BudgetDepartmentID] VARCHAR(100) NULL,
    [BudgetServiceLineID] VARCHAR(100) NULL,
    [BudgetSpecialtyID] VARCHAR(100) NULL,
    [BudgetProviderID] VARCHAR(100) NULL,
    [BudgetPayerGroupID] VARCHAR(100) NULL,
    [BudgetPayerCategoryID] VARCHAR(100) NULL,
    [BudgetPayerID] VARCHAR(100) NULL,
    [BudgetPayerPlanID] VARCHAR(100) NULL,
    [BudgetValue] DECIMAL(18,2) NULL,
    [BudgetIsActive] BIT NULL,
    [BudgetUpdatedDatetime] DATETIME NULL,
    CONSTRAINT [PK__Budgets__E38E79C41F134524] PRIMARY KEY ([BudgetID])
);
GO
