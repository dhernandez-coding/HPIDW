CREATE TABLE [dbo].[MonthlyARSummary] (
    [ProviderName] VARCHAR(253) NULL,
    [ARFinancialClass] VARCHAR(100) NULL,
    [0to30] MONEY NULL,
    [31to120] MONEY NULL,
    [121to150] MONEY NULL,
    [150+] MONEY NULL,
    [Under150] MONEY NULL,
    [BD0to30] MONEY NULL,
    [BD31to120] MONEY NULL,
    [BD121to150] MONEY NULL,
    [BD150+] MONEY NULL,
    [BDUnder150] MONEY NULL,
    [Charges] MONEY NULL,
    [Payments] MONEY NULL,
    [ReimbursementPct] NUMERIC(19,4) NULL,
    [ARHistoryDate] DATE NULL
);
GO
