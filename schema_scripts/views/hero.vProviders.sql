CREATE view [hero].[vProviders] as


SELECT
	Coalesce(NULLIF(Coalesce(NULLIF(CONCAT(pa.SourceSystemId, '~', pa.value), '~'), concat('0~', p.ProviderNPI)), '0~'), p.ProviderProviderID) as MappedId,
	p.[ProviderID]
	,p.ProviderProviderID as ParentProviderID
	,p.[ProviderDataSourceID]
	,ds.name as ProviderDataSource
	,p.[ProviderSourceID]
	,p.[ProviderAbbreviation]
	,
		 CONCAT(p.ProviderLastName,', ',p.ProviderFirstName,' ', p.ProviderMiddleInitial) as ProviderFullName
	,p.[ProviderFirstName]
	,p.[ProviderMiddleInitial]
	,p.[ProviderLastName]
	,p.[ProviderGender]
	,p.[ProviderSuffix]
	,p.[ProviderStreetAddress1]
	,p.[ProviderStreetAddress2]
	,p.[ProviderCity]
	,p.[ProviderState]
	,p.[ProviderZipCode]
	,p.[ProviderPhone]
	,p.[ProviderFax],
	CASE 
    WHEN p.ProviderSpecialtyID IS NULL THEN NULL
    ELSE Concat('0~', cast(p.ProviderSpecialtyID as varchar))
END AS [ProviderSpecialtyID]
	--,Concat('0~', cast(p.[ProviderSpecialtyID] as varchar)) as [ProviderSpecialtyID]
	,p.[ProviderSpecialtyID] as ParentSpecialtyID
	,s.SpecialtyName as ParentSpecialtyName
	,p.[ProviderUPIN]
	,p.[ProviderNPI]
	,p.[ProviderIsActive]
	
	--,CASE WHEN p2.ProviderID = '0~1255384483' THEN '2024-07-01' ELSE NULL END AS ProviderRVUEffectiveDate -- Date for Providers that have change in RVU Target
	,p.[ProviderUpdatedDateTime]

	--select * from [HPIDW].[dim].[Providers] p
	--select * 
FROM [hero].[Providerss] p
	left join hero.ProviderAliases pa on p.ProviderID = pa.ProviderID --MappedId is built when buildint the temp table this is sourced from #LRR
	
	left join hero.SourceSystems ds ON pa.SourceSystemId = ds.Id
	left join hero.Specialtiess s ON s.SpecialtyID =p.[ProviderSpecialtyID]
GO
