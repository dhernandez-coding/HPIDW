CREATE TABLE [dim].[FinancialClasses] (
    [FinancialClassID] VARCHAR(100) NOT NULL,
    [FinancialClassDataSourceID] INT NULL,
    [FinancialClassSourceID] VARCHAR(100) NULL,
    [FinancialClassName] VARCHAR(100) NULL,
    [FinancialClassIsActive] BIT NULL,
    [FinancialClassUpdatedDatetime] DATETIME NULL,
    CONSTRAINT [PK__Financia__3ACBBF22A88C71C6] PRIMARY KEY ([FinancialClassID])
);
GO
