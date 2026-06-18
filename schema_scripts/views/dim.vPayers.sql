CREATE view [dim].[vPayers] as
SELECT
	[PayerID]
	,[PayerDataSourceID]
	,[PayerSourceID]
	,pay.[PayerGroupID]
	,pg.PayerGroupName 
	,pay.[PayerCategoryID]
	,pc.PayerCategoryName
	,[PayerName]
	,[PayerAbbreviation]
	,[PayerStreetAddress1]
	,[PayerStreetAddress2]
	,[PayerCity]
	,[PayerState]
	,[PayerZipCode]
	,[PayerIsActive]
	,[PayerUpdatedDatetime]
FROM [HPIDW].[dim].[Payers] pay
		left join dim.PayerCategories pc ON pc.PayerCategoryID = pay.PayerCategoryID
		left join dim.PayerGroups pg ON pg.PayerGroupID = pay.PayerGroupID
GO
