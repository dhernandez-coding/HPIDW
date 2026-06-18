CREATE TABLE [rpt].[PBClosedClaims] (
    [Datasource] NVARCHAR(50) NULL,
    [VisitID] NVARCHAR(50) NULL,
    [Account] NVARCHAR(50) NULL,
    [ServiceDate] DATETIME NULL,
    [BillingProvider] NVARCHAR(100) NULL,
    [Payer] NVARCHAR(100) NULL,
    [PayerCategory] NVARCHAR(100) NULL,
    [Charges] DECIMAL(18,2) NULL,
    [Adjustments] DECIMAL(18,2) NULL,
    [TotalPayments] DECIMAL(18,2) NULL,
    [InsurancePayments] DECIMAL(18,2) NULL,
    [PatientPayments] DECIMAL(18,2) NULL,
    [PercentAdjusted] DECIMAL(18,4) NULL,
    [Balance] DECIMAL(18,2) NULL
);
GO
