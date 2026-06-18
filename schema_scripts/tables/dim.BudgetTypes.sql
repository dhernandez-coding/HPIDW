CREATE TABLE [dim].[BudgetTypes] (
    [BudgetTypeID] VARCHAR(100) NOT NULL,
    [BudgetTypeDatasourceID] INT NOT NULL,
    [BudgetTypeSourceID] VARCHAR(100) NOT NULL,
    [BudgetTypeName] VARCHAR(100) NOT NULL,
    [BudgetTypeIsActive] BIT NULL,
    [BudgetTypeUpdatedDatetime] DATETIME NULL,
    CONSTRAINT [PK__BudgetTy__3BF8A73D247383E5] PRIMARY KEY ([BudgetTypeID])
);
GO
