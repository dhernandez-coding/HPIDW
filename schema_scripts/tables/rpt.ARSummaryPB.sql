CREATE TABLE [rpt].[ARSummaryPB] (
    [ARHistoryDate] DATE NULL,
    [TransactionDataSourceID] INT NULL,
    [TransactionDepartmentID] VARCHAR(50) NULL,
    [CurrentFinancialClass] VARCHAR(50) NULL,
    [CurrentPayerID] VARCHAR(50) NULL,
    [TransactionBillingProviderID] VARCHAR(50) NULL,
    [TransactionOriginalAmount] MONEY NULL,
    [TransactionARAmountAll] MONEY NULL,
    [TransactionARAmountSelfPay] MONEY NULL,
    [TransactionARAmountInsurance] MONEY NULL,
    [TransactionARAmountActive] MONEY NULL,
    [TransactionARAmountBadDebt] MONEY NULL,
    [TransactionARAgingBucketSort] TINYINT NULL,
    [TransactionARAgingBucket] VARCHAR(20) NULL,
    [IsARCredit] BIT NULL,
    [PeriodCategory] VARCHAR(20) NULL
);
GO
