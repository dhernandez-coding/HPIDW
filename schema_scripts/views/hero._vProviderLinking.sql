CREATE view [hero].[_vProviderLinking] 
with schemabinding as
  select pa.Id, concat('0~',  p.ProviderNPI) as ParentProviderId, concat(pa.SourceSystemId, '~', pa.[Value]) as ChildProviderId, 0 as ProviderLinkingMgmtUserId, pa.CreatedDate as ProviderLinkingCreatedDatetime, pa.ModifiedDate as 'ProviderLinkingUpdatedDatetime', pa.IsActive as ProviderLinkingIsActive from 
  [hero].ProviderAliases pa
  left join [hero].Providerss p on pa.ProviderId = p.ProviderID
GO
