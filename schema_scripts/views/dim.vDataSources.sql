create view [dim].[vDataSources] as

SELECT 
	[DataSourceID]
	,[DataSourceServerID]
	,[DataSourceName]
	,[DataSourceAcronym]
	,[DataSourceType]
	,[DataSourceDatabaseType]
	,[DatasourceETLType]
	,[DataSourceLinkedServerName]
	,[DataSourceLinkedServerCatalogName]
	,[DataSourceIsActive]
	,[DataSourceUpdatedDateTime]
FROM [HPIDW].[dim].[DataSources]
GO
