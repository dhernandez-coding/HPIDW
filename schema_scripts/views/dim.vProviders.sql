CREATE view [dim].[vProviders] as


SELECT [ProviderID]
      ,[ParentProviderID]
      ,[ProviderDataSourceID]
      ,[ProviderDataSource]
      ,[ProviderSourceID]
      ,[ProviderAbbreviation]
      ,[ProviderFullName]
      ,[ProviderFirstName]
      ,[ProviderMiddleInitial]
      ,[ProviderLastName]
      ,[ProviderGender]
      ,[ProviderSuffix]
      ,[ProviderStreetAddress1]
      ,[ProviderStreetAddress2]
      ,[ProviderCity]
      ,[ProviderState]
      ,[ProviderZipCode]
      ,[ProviderPhone]
      ,[ProviderFax]
      ,[ProviderSpecialtyID]
      ,[ParentSpecialtyID]
      ,[ParentSpecialtyName]
      ,[ProviderUPIN]
      ,[ProviderNPI]
      ,[ProviderIsActive]
      ,[ProviderUpdatedDateTime]
FROM dbo._vProviders
WHERE EXISTS (
    SELECT 1 FROM dbo.DWConfig WHERE Name = 'UseAppTables' AND [Value] = 1
)

UNION ALL


SELECT
	p.[ProviderID]
	,p2.ProviderID ParentProviderID
	,p.[ProviderDataSourceID]
	,ds.DataSourceName as ProviderDataSource
	,p.[ProviderSourceID]
	,p.[ProviderAbbreviation]
	,CASE WHEN p2.ProviderLastName IS NOT NULL THEN CONCAT(p2.ProviderLastName,', ',p2.ProviderFirstName,' ', p2.ProviderMiddleInitial)
		  ELSE CONCAT(p.ProviderLastName,', ',p.ProviderFirstName,' ', p.ProviderMiddleInitial) END as ProviderFullName
	,p2.[ProviderFirstName]
	,p2.[ProviderMiddleInitial]
	,p.[ProviderLastName]
	,p.[ProviderGender]
	,p.[ProviderSuffix]
	,p.[ProviderStreetAddress1]
	,p.[ProviderStreetAddress2]
	,p.[ProviderCity]
	,p.[ProviderState]
	,p.[ProviderZipCode]
	,p.[ProviderPhone]
	,p.[ProviderFax]
	,p.[ProviderSpecialtyID]
	,coalesce(p2.ProviderSpecialtyID, p.[ProviderSpecialtyID]) ParentSpecialtyID
	,s.SpecialtyName as ParentSpecialtyName
	,p.[ProviderUPIN]
	,p.[ProviderNPI]
	,p.[ProviderIsActive]
	--,CASE WHEN p2.ProviderID = '0~1255384483' THEN '2024-07-01' ELSE NULL END AS ProviderRVUEffectiveDate -- Date for Providers that have change in RVU Target
	,p.[ProviderUpdatedDateTime]
FROM [HPIDW].[dim].[Providers] p
	left join [HPIDW].[dim].[DataSources] ds ON ds.DataSourceID = p.ProviderDataSourceID
	left join hpidw.map.vProviderLinking pl on p.ProviderID = pl.ChildProviderID
	left join dim.Providers p2 on pl.ParentProviderID = p2.ProviderID
	left join dim.Specialties s ON s.SpecialtyID = coalesce(p2.ProviderSpecialtyID, p.[ProviderSpecialtyID])
	--left join (select a.AccountAttendingProviderID 
	--			from fact.Accounts a 
	--			where year(AccountDateOfService) >= (year(getdate()) - 4) 
	--			group by a.AccountAttendingProviderID) pa ON pa.AccountAttendingProviderID = p.ProviderID
where 1=1 and
EXISTS (
    SELECT 1 FROM dbo.DWConfig WHERE Name = 'UseAppTables' AND [Value] = 0
)
GO
