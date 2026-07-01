CREATE VIEW [dim].[vProviderNPIs] as
SELECT
p.ProviderNPI
--,MIN(p.ProviderDataSourceID)
--,MAX(p.ProviderDataSourceID)
,MAX(s.SpecialtyName) as ProviderSpecialty
,COALESCE(MAX(CASE WHEN p.ProviderDataSourceID = 5 THEN CONCAT(p.ProviderLastName,', ',p.ProviderFirstName,' ', p.ProviderMiddleInitial) END) 
		, MAX(CONCAT(p.ProviderLastName,', ',p.ProviderFirstName,' ', p.ProviderMiddleInitial))) as ProviderName
FROM dim.vProviders p
	left join dim.Specialties s ON s.SpecialtyID = p.ProviderSpecialtyID
GROUP BY p.ProviderNPI
GO
