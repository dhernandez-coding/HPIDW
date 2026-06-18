CREATE TABLE [fact].[SelfPay] (
    [SelfPayTransactionID] VARCHAR(50) NOT NULL,
    [SelfPayDataSourceID] INT NULL,
    [SelfPayTransactionSourceID] VARCHAR(50) NULL,
    [SelfPayVisitID] VARCHAR(50) NULL,
    [SelfPayPatientID] VARCHAR(50) NULL,
    [SelfPayType] VARCHAR(50) NULL,
    [SelfPayDateOfService] DATETIME NULL,
    [SelfPayPostDate] DATETIME NULL,
    [SelfPayPostDateAge] INT NULL,
    [SelfPayPostDateAgeBucket] VARCHAR(50) NULL,
    [SelfPayAgeDate] DATETIME NULL,
    [SelfPayAge] INT NULL,
    [SelfPayAgeBucket] VARCHAR(50) NULL,
    [SelfPayFinancialClass] VARCHAR(50) NULL,
    [SelfPayBalance] MONEY NULL,
    [SelfPayPatientResponsibility] MONEY NULL,
    [SelfPayOutstandingBalance] MONEY NULL,
    [SelfPayUpdateDate] DATETIME NULL
);
GO
