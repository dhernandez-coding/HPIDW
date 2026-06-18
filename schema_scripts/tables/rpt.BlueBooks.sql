CREATE TABLE [rpt].[BlueBooks] (
    [BlueBooksID] BIGINT IDENTITY(1,1) NOT NULL,
    [FiscalYear] INT NULL,
    [FiscalPeriod] INT NULL,
    [FiscalYearPeriod] VARCHAR(10) NULL,
    [ReportSection] VARCHAR(100) NULL,
    [ReportGroupLevel1] VARCHAR(100) NULL,
    [ReportGroupLevel2] VARCHAR(100) NULL,
    [ReportGroupLevel3] VARCHAR(100) NULL,
    [ReportGroupLevel4] VARCHAR(100) NULL,
    [PracticeID] VARCHAR(30) NULL,
    [ReportingProviderID] VARCHAR(30) NULL,
    [FiscalPeriodValue] DECIMAL(18,4) NULL,
    [FiscalPeriodNumerator] DECIMAL(18,4) NULL,
    [FiscalPeriodDenominator] DECIMAL(18,4) NULL,
    [UpdatedDatetime] DATETIME NULL,
    CONSTRAINT [PK_BlueBooks] PRIMARY KEY ([BlueBooksID])
);
GO
