CREATE VIEW [dim].[vProviders2] as


SELECT
	p.[ProviderID]
	--,p2.ProviderID ParentProviderID
	--,p.[ProviderDataSourceID]
	--,ds.DataSourceName as ProviderDataSource
	--,p.[ProviderSourceID]
	--,p.[ProviderAbbreviation]
	,CONCAT(p.ProviderLastName,', ',p.ProviderFirstName,' ', p.ProviderMiddleInitial) ProviderFullName
	,p.[ProviderFirstName]
	,p.[ProviderMiddleInitial]
	,p.[ProviderLastName]
	--,p.[ProviderGender]
	--,p.[ProviderSuffix]
	--,p.[ProviderStreetAddress1]
	--,p.[ProviderStreetAddress2]
	--,p.[ProviderCity]
	--,p.[ProviderState]
	--,p.[ProviderZipCode]
	--,p.[ProviderPhone]
	--,p.[ProviderFax]
	,p.[ProviderSpecialtyID]
	--,p.[ProviderUPIN]
	--,p.[ProviderNPI]
	,p.[ProviderIsActive]
	--,p.[ProviderUpdatedDateTime]
FROM [HPIDW].[dim].[vProviders] p
where p.ProviderDataSourceID = 0
	--where coalesce(cast(pl.ProviderNPI as varchar), p.[ProviderNPI]) = '1578665063'

--SELECT
--	p.[ProviderID]
--	,p2.ProviderID ParentProviderID
--	,p.[ProviderDataSourceID]
--	,ds.DataSourceName as ProviderDataSource
--	,p.[ProviderSourceID]
--	,p.[ProviderAbbreviation]
--	,CASE WHEN p2.ProviderLastName IS NOT NULL THEN CONCAT(p2.ProviderLastName,', ',p2.ProviderFirstName,' ', p2.ProviderMiddleInitial)
--		  ELSE CONCAT(p.ProviderLastName,', ',p.ProviderFirstName,' ', p.ProviderMiddleInitial) END as ProviderFullName
--	,p.[ProviderFirstName]
--	,p.[ProviderMiddleInitial]
--	,p.[ProviderLastName]
--	,p.[ProviderGender]
--	,p.[ProviderSuffix]
--	,p.[ProviderStreetAddress1]
--	,p.[ProviderStreetAddress2]
--	,p.[ProviderCity]
--	,p.[ProviderState]
--	,p.[ProviderZipCode]
--	,p.[ProviderPhone]
--	,p.[ProviderFax]
--	,p.[ProviderSpecialtyID]
--	,coalesce(p2.ProviderSpecialtyID, p.[ProviderSpecialtyID]) ParentSpecialtyID
--	,p.[ProviderUPIN]
--	,p.[ProviderNPI]
--	,p.[ProviderIsActive]
--	,p.[ProviderUpdatedDateTime]
--FROM [HPIDW].[dim].[vProviders] p
--	left join [HPIDW].[dim].[DataSources] ds ON ds.DataSourceID = p.ProviderDataSourceID
--	left join hpidw.map.ProviderLinking pl on p.ProviderID = pl.ChildProviderID
--	left join dim.vProviders p2 on pl.ParentProviderID = p2.ProviderID
--	--where p2.ProviderSpecialtyID is not null
--	--where coalesce(cast(pl.ProviderNPI as varchar), p.[ProviderNPI]) = '1578665063'
GO
