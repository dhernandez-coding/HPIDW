CREATE view [fact].[vGeneralTransactionsPB] as

SELECT 
	sub.*
	,CASE WHEN DATEFROMPARTS(LEFT(sub.TransactionReportPeriodDate, 4), RIGHT(sub.TransactionReportPeriodDate, 2),1) between (DATEADD(MONTH,-13,DATEFROMPARTS(YEAR(CAST(GETDATE() AS DATE)), MONTH(CAST(GETDATE() AS DATE)),1))) AND (DATEADD(MONTH,-1,DATEFROMPARTS(YEAR(CAST(GETDATE() AS DATE)), MONTH(CAST(GETDATE() AS DATE)),1))) THEN 'Y' ELSE 'N' END as TransactionTrailing13Months
	,CASE WHEN DATEFROMPARTS(LEFT(sub.TransactionReportPeriodDate, 4), RIGHT(sub.TransactionReportPeriodDate, 2),1) = (DATEADD(MONTH,-1,DATEFROMPARTS(YEAR(CAST(GETDATE() AS DATE)), MONTH(CAST(GETDATE() AS DATE)),1))) THEN 'Y' ELSE 'N' END as TransactionCurrentMonthEnd
	,GETDATE() as AsOfDatetime

FROM (

	SELECT
		t.[TransactionID]
		,t.TransactionDatasourceID
		,ds.DataSourceName as TransactionDataSource
		,CONCAT(t.[TransactionDatasourceID],'~',t.[TransactionSourceID]) as TransactionSourceID
		,CONCAT(t.[TransactionDatasourceID],'~',t.[TransactionParentSourceID]) as TransactionParentSourceID
		,COALESCE(t.TransactionDepartmentID,tc.TransactionDepartmentID) as TransactionDepartmentID
		,v.VisitLocationID as TransactionVisitLocationID
		,t.[TransactionPayerID]
		,t.[TransactionPayerPlanID]
		,t.[TransactionType]
		,COALESCE(t.[TransactionCPTCode],tc.TransactionCPTCode) as TransactionCPTCode
		,t.[TransactionDateOfService]
		,t.[TransactionDateOfPosting]
		,t.[TransactionDateOfBilling]
		,t.[TransactionDateOfVoid]
		,t.[TransactionReportingPeriodID] as TransactionReportPeriodDate
		,FORMAT(DATEFROMPARTS(LEFT(t.TransactionReportingPeriodID,4),RIGHT(t.TransactionReportingPeriodID,2),1),'MMM-yy') AS TransactionReportPeriod 
		

	FROM fact.TransactionsPB t
		LEFT JOIN fact.Accounts a ON a.AccountID = t.TransactionAccountID -- for patient MRN 2/1/24 and employer 4/18/24
		LEFT JOIN dim.Patients p ON p.PatientID = a.AccountPatientID -- for patient MRN 2/1/24
		left join dim.vPBProcedureCodeCategories c ON c.ProcedureCode = COALESCE(t.TransactionCPTCode,t.TransactionCode) AND t.TransactionType = 'Charge'
		left join [HERO-DB].hpi.dbo.PBProcedureCategoriess cat ON cat.ProcedureCategory = CASE WHEN c.ProcedureCodeIsLocationDependent = 1 and t.TransactionPlaceOfServiceCode in ('21','22') THEN 'Outpatient Procedures' 
																				WHEN c.ProcedureCodeIsLocationDependent = 1 and t.TransactionPlaceOfServiceCode not in ('21','22') THEN 'In Office Procedures'
																				ELSE c.ProcedureCodeCategory END
		left join dim.DataSources ds ON t.TransactionDatasourceID = ds.DataSourceID
		left join map.vProviderLinking pl ON pl.ChildProviderID = t.TransactionBillingProviderID
		left join map.PracticeDepartments pd ON pd.DepartmentID = t.TransactionDepartmentID
		
		
		-- 10/22: CC replaced old stg.MedicareFeeSchedule with new comprehensive logic
		LEFT JOIN map.PayerPlanFeeSchedules fs ON fs.PayerPlanID = t.TransactionPayerPlanID --a.AccountPrimaryPayerPlanID 
		LEFT JOIN dim.FeeSchedules fsc ON fsc.FeeScheduleID = fs.FeeScheduleID
		LEFT JOIN dim.FeeScheduleRates mfs ON mfs.FeeScheduleID = fs.FeeScheduleID
											AND YEAR(t.TransactionDateOfPosting) = mfs.FeeScheduleYear
											AND t.TransactionCPTCode = mfs.FeeScheduleProcedureCode
											AND CASE WHEN t.TransactionModifier1 in ('53','26','TC') THEN t.TransactionModifier1 
														WHEN t.TransactionModifier2 in ('53','26','TC') THEN t.TransactionModifier2
														WHEN t.TransactionModifier3 in ('53','26','TC') THEN t.TransactionModifier3
														WHEN t.TransactionModifier4 in ('53','26','TC') THEN t.TransactionModifier4
														  ELSE '' END = mfs.FeeScheduleModifier
		
		
		LEFT JOIN dim.CPTCode cpt ON cpt.CPTCode = t.TransactionCPTCode 
			AND t.TransactionDateOfPosting >= cpt.EffectiveStartdate 
			AND t.TransactionDateOfPosting < cpt.EffectiveEndDate
			AND t.TransactionType = 'Charge'
				  

		LEFT JOIN map.PBAdjustmentCodes pba ON pba.PBAdjustmentCodeID = CONCAT(t.TransactionDataSourceID,'~',t.TransactionCode) AND t.TransactionType = 'Adjustment'
		LEFT JOIN dim.Payers py ON py.PayerID = t.TransactionPayerID
		LEFT JOIN dim.PayerCategories pc ON pc.PayerCategoryID = py.PayerCategoryID
		LEFT JOIN dim.PayerGroups pg ON pg.PayerGroupID = py.PayerGroupID
		LEFT JOIN fact.Visits2 v on t.TransactionVisitID = v.VisitID
		LEFT JOIN fact.TransactionsPB tc ON tc.TransactionType = 'Charge' 
									   AND t.TransactionType <> 'Charge'
									   AND CONCAT(t.TransactionDatasourceID,'~',t.TransactionParentSourceID) = tc.TransactionID
									   --AND tc.TransactionDatasourceID = t.TransactionDatasourceID
									   --AND tc.TransactionSourceID = t.TransactionParentSourceID
		--left join stg.PBProcedureCodeCategories cc ON cc.ProcedureCode = COALESCE(tc.TransactionCPTCode,tc.TransactionCode) AND tc.TransactionType = 'Charge'
		--left join dim.CPTCode pcpt2 ON pcpt2.CPTCode = tc.TransactionCPTCode AND pcpt2.EffectiveEndDate > GETDATE()
		left join dim.vPBProcedureCodeCategories cc ON cc.ProcedureCode = COALESCE(tc.TransactionCPTCode,tc.TransactionCode) AND tc.TransactionType = 'Charge'
		left join dim.CPTCode pcpt2 ON pcpt2.CPTCode = tc.TransactionCPTCode AND pcpt2.EffectiveEndDate > GETDATE()
									   

	where 1=1 
	AND year(t.TransactionDateOfPosting) >= (year(getdate()) - 2)
	--AND t.TransactionBillingType = 'PB'
	--AND t.TransactionDateOfPosting >= '10/2/2024'
	--AND t.TransactionModifier1 is not null
	--AND YEAR(t.TransactionDateOfService) = 2024 -- testing
	--AND t.TransactionType = 'Charge'
	--AND (t.TransactionModifier1 = '51' OR t.TransactionModifier2 = '51' OR t.TransactionModifier3 = '51' OR t.TransactionModifier4 = '51') -- testing
	--AND t.TransactionAccountID = '1~19228230' -- testing
	--AND t.TransactionSourceID = 'PB~18302254~4710192' --testing
) sub

--GO
