CREATE TABLE [dim].[PBReportPages] (
    [PBReportPageID] VARCHAR(250) NOT NULL,
    [PBReportID] VARCHAR(100) NULL,
    [PBReportSourceID] VARCHAR(100) NULL,
    [PBReportPageName] VARCHAR(200) NULL,
    [PBReportPageDisplayName] NVARCHAR(400) NULL,
    [PBReportPageOrder] INT NULL,
    [PBReportPageKey] VARCHAR(600) NULL,
    [PBReportPageUpdatedDatetime] DATETIME2 NULL,
    CONSTRAINT [PK__PBReport__C6EA1052B9210D7F] PRIMARY KEY ([PBReportPageID])
);
GO
