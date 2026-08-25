CREATE procedure [hero].[etl_provider_aliases_to_hero] as





--ALTER procedure [hero].[etl_provider_aliases_to_hero] as
--DROP TABLE IF EXISTS #vNewProviderAliases;
--DROP TABLE IF EXISTS #SourceSystems;

--select * into #SourceSystems from hero.SourceSystems
--select * into #vNewProviderAliases from vNewProviderAliases

---- Using OPENQUERY to force a fresh metadata check against the remote server
--insert into OPENQUERY([hero-db], 
--    'SELECT 
--        [Name], [Description], [Value], [ProviderId], [SourceSystemId],  [CreatedDate]
--        ,[ModifiedDate], [ModifiedBy], [DeletedDate], [DeletedBy], [IsDeleted], [IsActive]
--        ,[ProviderNPI]
--        ,[ProviderFirstName]
--        ,[ProviderLastName]
--    FROM hpi.dbo.ProviderAliases 
--    WHERE 1=0'
--)
--Select
--    concat(ss.Name, ' Id') as [Name],
--    concat(ss.Name, ' Mapping Value') as Description,
--    pa.[Value] as [Value],
--    pa.ProviderId as ProviderId,
--    ss.Id as SourceSystemId
--    ,'2026-02-25 15:45:29.2773287' as [CreatedDate]
--    ,'2026-02-25 15:45:29.2773287' as [ModifiedDate]
--    ,'ETL' as [ModifiedBy]
--    ,null as [DeletedDate]
--    ,null as [DeletedBy]
--    ,0 as [IsDeleted],
--    1 as IsActive
--    ,pa.[ProviderNPI] as ProviderNPI
--    ,pa.[ProviderFirstName] as ProviderFirstName
--    ,pa.[ProviderLastName] as ProviderLastName
--from #vNewProviderAliases pa
--Left Join #SourceSystems ss on pa.SourceSystemId = ss.id


--DROP TABLE IF EXISTS #vNewProviderAliases;
--DROP TABLE IF EXISTS #SourceSystems;
--GO




DROP TABLE IF EXISTS #vNewProviderAliases;
DROP TABLE IF EXISTS #SourceSystems;

DROP TABLE IF EXISTS #existingAliases;


select * into #SourceSystems from hero.SourceSystems



select Concat(concat(SourceSystemId, '~'), value) as ProviderId into #existingAliases From hero.ProviderAliases
Select * INTO #vNewProviderAliases From dim.Providers where ProviderID not like '0~%' --non zero's means external system
and PRoviderId not in (select ProviderId from #existingAliases) --only aliases that dont already exist
and trim(ProviderNPI) != '' and ProviderNPI is not null --cant match back to non NPI record.

select * From #vNewProviderAliases
where ProviderId not like '%~%'


-- Using OPENQUERY to force a fresh metadata check against the remote server
insert into OPENQUERY([hero-db], 
    'SELECT 
        [Name], [Description], [Value], [ProviderId], [SourceSystemId],  [CreatedDate]
        ,[ModifiedDate], [ModifiedBy], [DeletedDate], [DeletedBy], [IsDeleted], [IsActive]
        ,[ProviderNPI]
        ,[ProviderFirstName]
        ,[ProviderLastName]
    FROM hpi.dbo.ProviderAliases 
    WHERE 1=0'
)
Select
    concat(ss.Name, ' Id') as [Name],
    concat(ss.Name, ' Mapping Value') as Description,

	
--LEFT(PA.prOVIDERid, CHARINDEX('~', PA.prOVIDERid) - 1) as nSourceSystemId
SUBSTRING(PA.prOVIDERid, CHARINDEX('~', PA.prOVIDERid) + 1, LEN(PA.prOVIDERid)) AS Value

    --pa.[Value] as [Value],
    ,p.ProviderId as ProviderId
    ,LEFT(PA.prOVIDERid, CHARINDEX('~', PA.prOVIDERid) - 1) as SourceSystemId
    ,'2026-02-25 15:45:29.2773287' as [CreatedDate]
    ,'2026-02-25 15:45:29.2773287' as [ModifiedDate]
    ,'ETL' as [ModifiedBy]
    ,null as [DeletedDate]
    ,null as [DeletedBy]
    ,0 as [IsDeleted],
    1 as IsActive
    ,pa.[ProviderNPI] as ProviderNPI
    ,pa.[ProviderFirstName] as ProviderFirstName
    ,pa.[ProviderLastName] as ProviderLastName
from #vNewProviderAliases pa
LEFT JOIN hero.Providerss p on pa.ProviderNPI = p.ProviderNPI
Left Join #SourceSystems ss on LEFT(PA.prOVIDERid, CHARINDEX('~', PA.prOVIDERid) - 1) = ss.id


DROP TABLE IF EXISTS #vNewProviderAliases;
DROP TABLE IF EXISTS #SourceSystems;
GO
