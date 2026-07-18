CREATE view _vProviderLinking as

  select pa.Id, concat('0~',  p.ProviderNPI) as ParentProviderId, concat(pa.SourceSystemId, '~', pa.[Value]) as ChildProviderId, 0 as ProviderLinkingMgmtUserId, pa.CreatedDate as ProviderLinkingCreatedDatetime, pa.ModifiedDate as 'ProviderLinkingUpdatedDatetime', pa.IsActive as ProviderLinkingIsActive from hpi_etl.[dbo].ProviderAliases pa
  left join hpi_etl.[dbo].Providerss p on pa.ProviderId = p.ProviderID
GO
