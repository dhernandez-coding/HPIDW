CREATE view [dbo].[vNewProviderAliases] as

/*This is used for getting new provider aliases to external source systems*/
select 
nProviderId as ProviderId,
nSourceSystemId as SourceSystemId,
nValue as Value,
ProviderNPI,

ProviderLastName, 
ProviderFirstName
from (
select 

heroP.ProviderId as nProviderId, 
heroP.ProviderLastName, 
heroP.ProviderFirstName,
heroP.ProviderNPI,
ss.Name,
pl.ParentProviderID, 
LEFT(pl.ChildProviderId, CHARINDEX('~', pl.ChildProviderId) - 1) as nSourceSystemId
,SUBSTRING(pl.ChildProviderId, CHARINDEX('~', pl.ChildProviderId) + 1, LEN(pl.ChildProviderId)) AS nValue
from map.vProviderLinking pl
left join dim.Providers p on  p.ProviderId = pl.ParentProviderID
left join map.vProviderLinking plJr on plJr.ChildProviderID = p.ProviderId

left join [hero-db].hpi.dbo.Providerss heroP on p.ProviderNPI = heroP.providerNPI

left join [hero-db].hpi.dbo.SourceSystems ss on (LEFT(pl.ChildProviderId, CHARINDEX('~', pl.ChildProviderId) - 1)) = ss.Id
) t
where not exists(

Select Value, SourceSystemId, ProviderId from [hero-db].hpi.dbo.ProviderAliases pa
where pa.Value = nValue and pa.SourceSystemid = nSourceSystemId and pa.ProviderId = nProviderId

)
and nProviderId is not null
GO
