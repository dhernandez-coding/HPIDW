CREATE view [dbo].[_vProviders] as 

--DROP TABLE IF EXISTS #tempProviderAliases;
--DROP TABLE IF EXISTS #tempSourceSystems;
--DROP TABLE IF EXISTS #tempProviders;


with tempProviderAliases as (
select pa.*, concat(pa.SourceSystemId, '~', value) as MappedId  from hpi_etl.dbo.ProviderAliases pa
),
tempSourceSystems as (
select * from hpi_etl.dbo.SourceSystems
),
tempProviders as (
select * from hpi_etl.dbo.Providerss
)


SELECT
	pa.MappedId,
	p.[ProviderID]
	,p2.ProviderID ParentProviderID
	,tp.[ProviderDataSourceID]
	,ds.name as ProviderDataSource
	,tp.[ProviderSourceID]
	,tp.[ProviderAbbreviation]
	,CASE WHEN p2.ProviderLastName IS NOT NULL THEN CONCAT(p2.ProviderLastName,', ',p2.ProviderFirstName,' ', p2.ProviderMiddleInitial)
		  ELSE CONCAT(p.ProviderLastName,', ',p.ProviderFirstName,' ', p.ProviderMiddleInitial) END as ProviderFullName
	,p2.[ProviderFirstName]
	,p2.[ProviderMiddleInitial]
	,tp.[ProviderLastName]
	,tp.[ProviderGender]
	,tp.[ProviderSuffix]
	,tp.[ProviderStreetAddress1]
	,tp.[ProviderStreetAddress2]
	,tp.[ProviderCity]
	,tp.[ProviderState]
	,tp.[ProviderZipCode]
	,tp.[ProviderPhone]
	,tp.[ProviderFax]
	,Concat('0~', tp.[ProviderSpecialtyID]) as [ProviderSpecialtyID]
	,coalesce(p2.ProviderSpecialtyID, p.[ProviderSpecialtyID]) ParentSpecialtyID
	,s.SpecialtyName as ParentSpecialtyName
	,tp.[ProviderUPIN]
	,tp.[ProviderNPI]
	,tp.[ProviderIsActive]
	
	--,CASE WHEN p2.ProviderID = '0~1255384483' THEN '2024-07-01' ELSE NULL END AS ProviderRVUEffectiveDate -- Date for Providers that have change in RVU Target
	,p.[ProviderUpdatedDateTime]

	--select * from [HPIDW].[dim].[Providers] p
FROM [HPIDW].[dim].[Providers] p
	left join tempSourceSystems ds ON ds.id = p.ProviderDataSourceID
	left join tempProviderAliases pa on p.ProviderID = MappedId --MappedId is built when buildint the temp table this is sourced from #LRR

	left join hpidw.map.vProviderLinking pl on p.ProviderID = pl.ChildProviderID
	left join dim.Providers p2 on pl.ParentProviderID = p2.ProviderID
	left join dim.Specialties s ON s.SpecialtyID = coalesce(p2.ProviderSpecialtyID, p.[ProviderSpecialtyID])
	left join tempProviders tp on p.ProviderID = tp.ProviderProviderId

	--left join (select a.AccountAttendingProviderID 
	--			from fact.Accounts a 
	--			where year(AccountDateOfService) >= (year(getdate()) - 4) 
	--			group by a.AccountAttendingProviderID) pa ON pa.AccountAttendingProviderID = p.ProviderID
where 1=1
GO
