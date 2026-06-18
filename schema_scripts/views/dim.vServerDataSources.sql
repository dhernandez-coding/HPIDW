CREATE VIEW [dim].[ServerDataSources]
AS
SELECT        s.ServerID, s.ServerName, s.ServerIPAddress, d.DataSourceID, d.DataSourceName, d.DataSourceType, d.DataSourceDatabase, d.DatasourceETLType, d.DataSourceDatabaseName, d.DataSourceProviderString, 
                         d.DataSourceCatalog
FROM            dim.Servers AS s LEFT OUTER JOIN
                         dim.DataSources AS d ON s.ServerID = d.ServerID
GO
