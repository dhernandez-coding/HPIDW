-- =============================================
-- Author:		Ryan Tisserand
-- Create date: 1/19/2023
-- Description:	Selects Servers and DataSources
-- =============================================
CREATE PROCEDURE [dim].[spSelectServerDataSources]
AS
BEGIN
SET NOCOUNT ON;
select
	s.ServerID,
	s.ServerName,
	s.ServerIPAddress,
	d.DataSourceID,
	d.DataSourceName,
	d.DataSourceType,
	d.DataSourceDatabaseType,
	d.DatasourceETLType,
	d.DataSourceLinkedServerName,
	d.DataSourceLinkedServerCatalogName
from dim.Servers s
left join dim.DataSources d on s.ServerID = d.DataSourceServerID

END
GO
