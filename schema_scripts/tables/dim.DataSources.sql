CREATE TABLE [dim].[DataSources] (
    [DataSourceID] INT IDENTITY(0,1) NOT NULL,
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
    CONSTRAINT [PK__DataSour__28EECD4C7A95A381] PRIMARY KEY ([DataSourceID])
);
GO
