CREATE TABLE [dim].[PBReportUsage] (
    [PBReportUsageID] NVARCHAR(250) NOT NULL,
    [PBReportUsageDatasourceID] INT NOT NULL DEFAULT ((13)),
    [PBReportID] NVARCHAR(150) NOT NULL,
    [PBReportSourceID] NVARCHAR(100) NOT NULL,
    [PBWorkspaceID] NVARCHAR(150) NOT NULL,
    [PBWorkspaceSourceID] NVARCHAR(100) NOT NULL,
    [PBReportUsageDate] DATE NOT NULL,
    [PBReportUsagePage] NVARCHAR(256) NULL,
    [PBReportUsagePlatform] NVARCHAR(50) NULL,
    [PBReportUsageDistributionMethod] NVARCHAR(100) NULL,
    [PBReportUsageUserEmail] NVARCHAR(256) NULL,
    [PBReportUsageUserName] NVARCHAR(256) NULL,
    [PBReportUsageGivenName] NVARCHAR(256) NULL,
    [PBReportUsageFamilyName] NVARCHAR(256) NULL,
    [PBReportUsageViewsCount] INT NOT NULL,
    [PBReportUsageLoadDatetime] DATETIME NOT NULL DEFAULT (getdate()),
    [PBReportUsagePageKey] NVARCHAR(407) NULL,
    CONSTRAINT [PK__PBReport__F0C0B4FEB7E5EB35] PRIMARY KEY ([PBReportUsageID])
);
GO
