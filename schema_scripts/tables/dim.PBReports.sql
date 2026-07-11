CREATE TABLE [dim].[PBReports] (
    [PBReportID] NVARCHAR(150) NULL,
    [PBReportDatasourceID] INT NULL,
    [PBReportSourceID] NVARCHAR(100) NULL,
    [PBWorkspaceID] NVARCHAR(150) NULL,
    [PBWorkspaceSourceID] NVARCHAR(100) NULL,
    [PBReportName] NVARCHAR(256) NULL,
    [PBReportWebUrl] NVARCHAR(512) NULL,
    [PBReportIsActive] BIT NULL,
    [PBReportUpdatedDatetime] DATETIME NULL,
    [PBDatasetID] NVARCHAR(100) NULL,
    [PBReportDescription] NVARCHAR(MAX) NULL,
    [PBReportDataSourceType] VARCHAR(50) NULL
);
GO
