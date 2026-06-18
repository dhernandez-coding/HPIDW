CREATE TABLE [rpt].[HPIPContractualSummary] (
    [ProviderName] NVARCHAR(255) NULL,
    [ARFinancialClass] NVARCHAR(255) NULL,
    [0to30] DECIMAL(18,2) NULL,
    [31to120] DECIMAL(18,2) NULL,
    [121to150] DECIMAL(18,2) NULL,
    [150+] DECIMAL(18,2) NULL,
    [Under150] DECIMAL(18,2) NULL,
    [BD0to30] DECIMAL(18,2) NULL,
    [BD31to120] DECIMAL(18,2) NULL,
    [BD121to150] DECIMAL(18,2) NULL,
    [BD150Plus] DECIMAL(18,2) NULL,
    [BDUnder150] DECIMAL(18,2) NULL,
    [Charges] DECIMAL(18,2) NULL,
    [Payments] DECIMAL(18,2) NULL,
    [ReimbursementPct] DECIMAL(18,4) NULL,
    [ARHistoryDate] DATE NULL
);
GO
