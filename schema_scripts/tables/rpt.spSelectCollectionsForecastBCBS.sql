CREATE TABLE [rpt].[spSelectCollectionsForecastBCBS] (
    [ReportPeriodDate] DATE NULL,
    [CollectionType] NVARCHAR(50) NULL,
    [DatasourceID] NVARCHAR(100) NULL,
    [PracticeID] NVARCHAR(100) NULL,
    [BillingProviderID] NVARCHAR(100) NULL,
    [PrimaryPayerPlanID] NVARCHAR(100) NULL,
    [FeeScheduleID] NVARCHAR(100) NULL,
    [CPTCode] NVARCHAR(50) NULL,
    [TransactionCount] INT NULL,
    [TransactionUnits] INT NULL,
    [TotalCharges] DECIMAL(18,2) NULL,
    [TotalCollections] DECIMAL(18,2) NULL,
    [ExampleTransactionID] NVARCHAR(100) NULL,
    [AsOfDatetime] DATETIME NULL DEFAULT (getdate())
);
GO
