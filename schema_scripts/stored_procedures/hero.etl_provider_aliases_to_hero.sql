create procedure [hero].[etl_provider_aliases_to_hero] as
DROP TABLE IF EXISTS #vNewProviderAliases;
DROP TABLE IF EXISTS #SourceSystems;

select * into #SourceSystems from hero.SourceSystems
select * into #vNewProviderAliases from vNewProviderAliases

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
    pa.[Value] as [Value],
    pa.ProviderId as ProviderId,
    ss.Id as SourceSystemId
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
Left Join #SourceSystems ss on pa.SourceSystemId = ss.id


DROP TABLE IF EXISTS #vNewProviderAliases;
DROP TABLE IF EXISTS #SourceSystems;
GO
