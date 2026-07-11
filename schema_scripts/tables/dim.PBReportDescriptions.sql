CREATE TABLE [dim].[PBReportDescriptions] (
    [PBReportSourceID] VARCHAR(100) NOT NULL,
    [PBReportName] NVARCHAR(400) NULL,
    [PBReportDescription] NVARCHAR(1000) NULL,
    [PBReportDescriptionModel] VARCHAR(100) NULL,
    [PBReportDescriptionGeneratedDatetime] DATETIME2 NULL,
    CONSTRAINT [PK__PBReport__C2C8C8C99F616851] PRIMARY KEY ([PBReportSourceID])
);
GO
