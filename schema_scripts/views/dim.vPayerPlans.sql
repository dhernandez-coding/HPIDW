CREATE view [dim].[vPayerPlans] as
SELECT
	[PayerPlanID]
	,[PayerPlanDataSourceID]
	,[PayerPlanSourceID]
	,pay.[PayerGroupID]
	,pg.PayerGroupName 
	,pay.[PayerCategoryID]
	,pc.PayerCategoryName
	,[PayerName]
	,PayerPlanName
	,[PayerPlanIsActive]
	,[PayerPlanUpdatedDatetime]
FROM [HPIDW].[dim].[PayerPlans] pp
		left join [HPIDW].[dim].[Payers] pay ON pay.PayerID = pp.PayerID
		left join dim.PayerCategories pc ON pc.PayerCategoryID = pay.PayerCategoryID
		left join dim.PayerGroups pg ON pg.PayerGroupID = pay.PayerGroupID
GO
