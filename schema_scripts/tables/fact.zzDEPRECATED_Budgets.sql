CREATE TABLE [fact].[zzDEPRECATED_Budgets] (
    [BudgetID] BIGINT IDENTITY(1,1) NOT NULL,
    [BudgetType] VARCHAR(100) NULL,
    [BudgetDate] DATE NULL,
    [BudgetSpecialty] VARCHAR(100) NULL,
    [BudgetProviderNPI] VARCHAR(100) NULL,
    [BudgetValue] DECIMAL(18,2) NULL,
    [BudgetUpdatedDatetime] DATETIME NULL,
    CONSTRAINT [PK__Budgets__E38E79C448E5C473] PRIMARY KEY ([BudgetID])
);
GO
