create view vNewProviders as 
Select * from dim.Providers where ProviderNPi is not null and Trim(ProviderNPI) <> ''
 AND  ProviderId not in (select ChildProviderId from map.ProviderLinking) and ProviderId not in (select ProviderProviderId from [hero-db].hpi.dbo.Providerss)
GO
