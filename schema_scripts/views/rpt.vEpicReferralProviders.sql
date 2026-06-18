CREATE VIEW rpt.vEpicReferralProviders as 
SELECT
	pr.ProviderID
	,pr.ProviderName
	,pt.PracticeID as MappedPracticeID
	,pt.PracticeName as MappedPractice
	,pt.PracticeCompany as MappedPracticeCompany
	,sum(pr.ByCount) as ReferredByCount
	,sum(pr.ToCount) as ReferredToCount
FROM (
	select
		b.ReferredByProviderID AS ProviderID
		,b.ReferredByProvider AS ProviderName
		,count(1) as ByCount
		,0 as ToCount
	from rpt.vEpicReferrals b
	where b.ReferralEntryDate >= '1/1/2023'
		AND b.ReferralType <> 'Auth/Cert'
	group by
		b.ReferredByProviderID
		,b.ReferredByProvider

	UNION ALL

	select
		b.ReferredToProviderID
		,b.ReferredToProvider
		,0 as ByCount
		,count(1) as ToCount
	from rpt.vEpicReferrals b
	where b.ReferralEntryDate >= '1/1/2023'
		AND b.ReferralType <> 'Auth/Cert'
	group by
		b.ReferredToProviderID
		,b.ReferredToProvider
	) pr
	left join map.EpicPracticeProviders epp ON epp.ProviderID = pr.ProviderID
	left join dim.practices pt ON pt.PracticeID = epp.PracticeID
GROUP BY
	pr.ProviderID
	,pr.ProviderName
	,pt.PracticeID
	,pt.PracticeName
	,pt.PracticeCompany
GO
