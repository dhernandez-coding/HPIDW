CREATE TABLE [dim].[zzDEPRECATED_DataSources] (
    [DataSourceID] INT IDENTITY(1,1) NOT NULL,
    [DataSourceServerID] INT NOT NULL,
    [DataSourceName] VARCHAR(200) NOT NULL,
    [DataSourceAcronym] VARCHAR(50) NOT NULL,
    [DataSourceType] VARCHAR(50) NOT NULL,
    [DataSourceDatabaseType] VARCHAR(50) NOT NULL,
    [DatasourceETLType] VARCHAR(50) NOT NULL,
    [DataSourceLinkedServerName] VARCHAR(50) NULL,
    [DataSourceLinkedServerCatalogName] VARCHAR(100) NULL,
    [DataSourceIsActive] BIT NULL,
    [DataSourceUpdatedDateTime] DATETIME NULL,
    CONSTRAINT [PK_EHRs] PRIMARY KEY ([DataSourceID])
);
GO
