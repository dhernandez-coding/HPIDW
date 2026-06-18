CREATE TABLE [dim].[ReportPlatforms] (
    [ReportPlatformID] NVARCHAR(100) NULL,
    [ReportPlatformName] NVARCHAR(100) NULL,
    [ReportParentPlatformID] INT NULL,
    [ReportPlatformVendor] NVARCHAR(100) NULL,
    [ReportPlatformType] NVARCHAR(100) NULL,
    [ReportPlatformTenant] NVARCHAR(200) NULL,
    [ReportPlatformUrl] NVARCHAR(500) NULL,
    [ReportPlatformRefreshToken] NVARCHAR(MAX) NULL,
    [ReportPlatformAccessToken] NVARCHAR(MAX) NULL,
    [ReportPlatformIsActive] BIT NOT NULL DEFAULT ((1)),
    [ReportPlatformUpdateDatetime] DATETIME NOT NULL DEFAULT (getdate())
);
GO
