CREATE TABLE [rpt].[CoPayPB] (
    [CopayDataSourceID] INT NULL,
    [CopayVisitID] VARCHAR(50) NULL,
    [CopayPatientID] VARCHAR(50) NULL,
    [CopayProviderID] VARCHAR(50) NULL,
    [CopayDepartmentID] VARCHAR(50) NULL,
    [CopayPayerID] VARCHAR(50) NULL,
    [CopayPracticeID] VARCHAR(50) NULL,
    [CopayUserEntryName] VARCHAR(100) NULL,
    [CopayDateOfService] DATETIME NULL,
    [CopayDateOfPayment] DATETIME NULL,
    [CopayDOSFlag] VARCHAR(10) NULL,
    [CopayDue] MONEY NULL,
    [CopayCollected] MONEY NULL,
    [CopayUpdateDate] DATETIME NULL
);
GO
