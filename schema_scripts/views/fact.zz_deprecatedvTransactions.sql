CREATE view [fact].[vTransactions] as

SELECT
	[TransactionID]
	,[TransactionDatasourceID]
	--,ds.DataSourceName as TransactionDataSource
	,[TransactionSourceID]
	,[TransactionVisitID]
	--,v.VisitClass as TransactionVisitClass
	--,v.VisitType as TransactionVisitType
	--,vl.LocationName as TransactionVisitLocation
	--,v.VisitDateOfService as TransactionVisitDateOfService
	,[TransactionDepartmentID]
	--,d.DepartmentName as TransactionDepartment
	,[TransactionPayerID]
	--,py.PayerName as TransactionPayer
	--,pc.PayerCategoryName as TransactionPayerCategory
	,[TransactionBillingProviderID]
	--,CASE WHEN t.TransactionBillingProviderID is not null THEN CONCAT(p.ProviderLastName,', ',p.ProviderFirstName,' ',p.ProviderMiddleInitial) END as TransactionBillingProvider
	--,s.SpecialtyName as TransactionBillingProviderSpecialty
	,[TransactionBillingType]
	,[TransactionType]
	,[TransactionSubType]
	,[TransactionRevenueCode]
	,[TransactionRevenueCodeDescription]
	,[TransactionCode]
	,[TransactionDescription]
	,[TransactionCPTCode]
	,[TransactionModifier1]
	,[TransactionModifier2]
	,[TransactionModifier3]
	,[TransactionModifier4]
	,[TransactionUnits]
	,[TransactionAmount]
	,[TransactionDateOfService]
	,[TransactionDateOfPosting]
	,[TransactionDateOfBilling]
	,[TransactionReportingPeriodID]
	,[TransactionStatus]
	,CASE WHEN t.TransactionType = 'Charge' and (ISNUMERIC(t.TransactionCPTCode) = 1 or t.TransactionCPTCode is null)
			   AND (t.TransactionRevenueCode  in ('610','611','612','614','615','0610','0611','0612','0614','0615')
					OR t.TransactionCode in ('4192471','4192472','4192473','4192474','4192476','4192477','4192478','4192480','4192482','4192483'
											,'4192484','4192485','4192486','4192487','4192488','4192489','4192490','4192491'
											,'4192492','4192493','4192494','4192495','4192496','4192497','4192498','4192502'
											,'4192503','4192505','4193000','4193002','4193003','4193004','4193005','4193006'
											,'4193007','4193008','4193009','4192512','4192521','4193010','4193011','4192488'
											,'4192490','4192493','4192495','4193002','4193007')) THEN 'Yes' ELSE 'No' END as TransactionIsMRICharge
	,CASE WHEN t.TransactionType = 'Charge' AND t.TransactionRevenueCode in ('350','351','352','0350','0351','0352') THEN 'Yes' ELSE 'No' END as TransactionIsCTCharge
	,CASE WHEN t.TransactionType = 'Charge' AND t.TransactionRevenueCode in ('401','403','0401','0403') THEN 'Yes' ELSE 'No' END as TransactionIsMammoCharge
	,CASE WHEN t.TransactionType = 'Charge' AND t.TransactionRevenueCode in ('402','483','921','0402','0483','0921') THEN 'Yes' ELSE 'No' END as TransactionIsUltrasoundCharge
	,case
		when t.TransactionType = 'Charge' and (ISNUMERIC(t.TransactionCPTCode) = 1 or t.TransactionCPTCode is null)
		then
			case
				when
			   (t.TransactionRevenueCode  in ('610','611','612','614','615','0610','0611','0612','0614','0615')
				OR t.TransactionCode in ('4192471','4192472','4192473','4192474','4192476','4192477','4192478','4192480','4192482','4192483'
											,'4192484','4192485','4192486','4192487','4192488','4192489','4192490','4192491'
											,'4192492','4192493','4192494','4192495','4192496','4192497','4192498','4192502'
											,'4192503','4192505','4193000','4193002','4193003','4193004','4193005','4193006'
											,'4193007','4193008','4193009','4192512','4192521','4193010','4193011','4192488'
											,'4192490','4192493','4192495','4193002','4193007'))
				then '0~11' -- mri
		else
			CASE
				when t.TransactionRevenueCode in ('350','351','352','0350','0351','0352') 
				then '0~10' -- ct
		else
			CASE
				when t.TransactionRevenueCode in ('401','403','0401','0403')
				then '0~15' -- mammo
		else
			CASE
				when t.TransactionRevenueCode in ('402','483','921','0402','0483','0921')
				then '0~14' -- ultrasound
		end end end end end as TransactionImagingType

	,[TransactionIsActive]
	,[TransactionUpdatedDateTime]
FROM [HPIDW].[fact].[Transactions] t
	--LEFT JOIN dim.Providers p ON p.ProviderID = t.TransactionBillingProviderID
	--LEFT JOIN dim.Specialties s ON s.SpecialtyID = p.ProviderSpecialtyID
	--LEFT JOIN dim.Departments d ON d.DepartmentID = t.TransactionDepartmentID
	--LEFT JOIN dim.Payers py ON py.PayerID = t.TransactionPayerID
	--LEFT JOIN dim.PayerCategories pc ON pc.PayerCategoryID = py.PayerCategoryID
	--LEFT JOIN dim.DataSources ds ON ds.DataSourceID = t.TransactionDatasourceID
	--LEFT JOIN fact.Visits v ON v.VisitID = t.TransactionVisitID
	--LEFT JOIN dim.Locations vl ON vl.LocationID = v.VisitLocationID
--where year(TransactionDateOfService) >= (year(getdate()) - 2)
where 1=1 
--AND TransactionVisitID in (select v.VisitID from fact.vVisits v group by v.VisitID)
AND YEAR(t.TransactionDateOfPosting) >= (year(getdate()) - 2)
GO
