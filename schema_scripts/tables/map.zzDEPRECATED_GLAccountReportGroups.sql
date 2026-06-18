CREATE TABLE [map].[zzDEPRECATED_GLAccountReportGroups] (
    [GLAccountReportGroupID] INT IDENTITY(1,1) NOT NULL,
    [GLAccountDescriptionID] VARCHAR(100) NULL,
    [GLAccountTypeID] VARCHAR(100) NULL,
    [GLAccountLocationID] VARCHAR(100) NULL,
    [GLAccountPracticeID] VARCHAR(100) NULL,
    [GLAccountProviderID] VARCHAR(100) NULL,
    [GLAccountReportGroupLevel1] VARCHAR(100) NULL,
    [GLAccountReportGroupLevel2] VARCHAR(100) NULL,
    [GLAccountReportGroupLevel3] VARCHAR(100) NULL,
    [GLAccountReportGroupLevel1Sort] INT NULL,
    [GLAccountReportGroupLevel2Sort] INT NULL,
    [GLAccountReporGroupLevel3Sort] INT NULL,
    [GLAccountReportGroupIsActive] BIT NULL,
    [GLAccountReportGroupUpdatedDatetime] DATETIME NULL,
    [GLAccountIsAllocated] BIT NULL,
    CONSTRAINT [PK__GLAccoun__2C8BB6D4A8159949] PRIMARY KEY ([GLAccountReportGroupID])
);
GO
