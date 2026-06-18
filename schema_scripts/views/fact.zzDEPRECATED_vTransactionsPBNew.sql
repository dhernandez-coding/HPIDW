CREATE view [fact].[vTransactionsPBNew] as

/*
Change Control:

	1. 9/3/24 - Chris Cross - Replaced fact.Transactions2 with PB-filtered fact.TransactionsPB core table to improve performance

*/


SELECT 
	sub.*
	, CASE WHEN sub.TransactionGLSegmentType = '99' THEN '00' /*Administrative*/ 
			 WHEN sub.TransactionPracticeID = '0~TDT' AND sub.TransactionVisitLocationID in ('1~95','1~135') THEN '22' /*Thomason - Hinton*/ 
			 WHEN sub.TransactionPracticeID = '0~TDT' AND sub.TransactionVisitLocationID = '1~223' THEN '30' /*Thomason - Binger*/
			 WHEN sub.TransactionPracticeID = '0~TDT' AND sub.TransactionVisitLocationID = '1~230' THEN '31' /*Thomason - Hydro*/
		     WHEN sub.TransactionGLLocationID is not null THEN sub.TransactionGLLocationID
			 END as TransactionGLSegmentLocation
	, CASE WHEN sub.TransactionGLSegmentType = '99' THEN '000' /*Administrative*/
			 WHEN sub.TransactionBillingProviderID = '5~114876' THEN 'Nancy Turner' /*Nancy Turner Exception*/
			 ELSE sub.TransactionGLPracticeID /*Assigned from mapped practice*/
		END as TransactionGLSegmentPractice
	, CASE WHEN sub.TransactionGLSegmentType in ('01','41','31','34','51','55','56','99') THEN '000' /*Direct, Procedure Category Types, and Administrative*/
		   WHEN sub.TransactionGLProviderID IS NOT NULL THEN sub.TransactionGLProviderID /*Assigned from mapped practice provider*/
		   ELSE '000' /*Billing Provider is Practice Provider*/
		END as TransactionGLSegmentProvider
	,CASE WHEN DATEFROMPARTS(LEFT(sub.TransactionReportPeriodDate, 4), RIGHT(sub.TransactionReportPeriodDate, 2),1) between (DATEADD(MONTH,-13,DATEFROMPARTS(YEAR(CAST(GETDATE() AS DATE)), MONTH(CAST(GETDATE() AS DATE)),1))) AND (DATEADD(MONTH,-1,DATEFROMPARTS(YEAR(CAST(GETDATE() AS DATE)), MONTH(CAST(GETDATE() AS DATE)),1))) THEN 'Y' ELSE 'N' END as TransactionTrailing13Months
	,CASE WHEN DATEFROMPARTS(LEFT(sub.TransactionReportPeriodDate, 4), RIGHT(sub.TransactionReportPeriodDate, 2),1) = (DATEADD(MONTH,-1,DATEFROMPARTS(YEAR(CAST(GETDATE() AS DATE)), MONTH(CAST(GETDATE() AS DATE)),1))) THEN 'Y' ELSE 'N' END as TransactionCurrentMonthEnd
	,ROUND(sub.CalculatedFeeSchedule * 0.02,2) AS SequestrationAmount  -- Sequestration Rate = 0.02
	,GETDATE() as AsOfDatetime

FROM (

	SELECT
		t.[TransactionID]
		,t.TransactionDatasourceID
		,ds.DataSourceName as TransactionDataSource
		,CONCAT(t.[TransactionDatasourceID],'~',t.[TransactionSourceID]) as TransactionSourceID
		,CONCAT(t.[TransactionDatasourceID],'~',t.[TransactionParentSourceID]) as TransactionParentSourceID
		,a.AccountPatientID as PatientID
		,p.PatientMRN [PatientMRN] -- added with 2 joins below 2/1
		,t.[TransactionVisitID]
		,t.[TransactionAccountID]
		,t.TransactionVisitID as [TransactionEncounterID]
		,COALESCE(t.TransactionDepartmentID,tc.TransactionDepartmentID) as TransactionDepartmentID
		,v.VisitLocationID as TransactionVisitLocationID
		,t.[TransactionPayerID]
		,a.AccountEmployerName as Employer
		,t.[TransactionBillingProviderID]
		,pt.PracticeID as TransactionPracticeID
		,t.[TransactionBillingType]
		,t.[TransactionType]
		,t.[TransactionSubType]
		,CASE WHEN t.TransactionType = 'Charge' THEN '1_Charge'
			  WHEN t.TransactionType = 'Adjustment' THEN pba.PBAdjustmentCodeCategory
			  WHEN t.TransactionSubType like '%Refund%' THEN '7_Refund'
			  WHEN t.TransactionType = 'Payment' AND ISNULL(pg.PayerGroupName,'') <> 'Self-Pay' THEN '5_Payer Receipts'
			  WHEN t.TransactionType = 'Payment' AND ISNULL(pg.PayerGroupName,'') = 'Self-Pay' THEN '6_Patient Receipts'
			  END as TransactionARCategory
		,t.[TransactionRevenueCode]
		,t.[TransactionRevenueCodeDescription]
		,t.[TransactionCode]
		,t.[TransactionDescription]
		,COALESCE(t.[TransactionCPTCode],tc.TransactionCPTCode) as TransactionCPTCode
		,CASE WHEN t.TransactionType='Payment' THEN pcpt2.ProcedureCodeInsuranceDescription ELSE pcpt.ProcedureCodeInsuranceDescription END as TransactionCPTDescription
		,CASE WHEN t.TransactionType='Payment' THEN cc.[ProcedureCodeDHSCategory] ELSE c.[ProcedureCodeDHSCategory] END AS TransactionCPTCodeDHSCategory
		,CASE WHEN t.TransactionType='Payment' THEN cc.[ProcedureCodeInPlay] ELSE c.[ProcedureCodeInPlay] END AS TransactionCPTCodeInPlay
		,cat.ProcedureCategoryPriority as ProcedureCategoryRank
		,cat.ProcedureCategory as ProcedureCategory
		,cat.ProcedureCategoryVisitType as ProcedureVisitType
		,t.[TransactionModifier1]
		,t.[TransactionModifier2]
		,t.[TransactionModifier3]
		,t.[TransactionModifier4]
		,t.[TransactionUnits]
		,t.[TransactionAmount]
		,CPT.RVU as [UnmodifiedRVU]
		,(CPT.RVU * COALESCE(RVU.Adjustment,RVU2.Adjustment,RVU3.Adjustment,RVU4.Adjustment)) as [ModifiedRVU]
		,(CASE WHEN Mult.row_num = 1 THEN .5
			  WHEN Mult.row_num > 1 THEN .25
			  ELSE NULL END) as MultProcModifier
		,(CASE WHEN Mult.row_num = 1 THEN .5
			   WHEN Mult.row_num > 1 THEN .25
			   ELSE 1 END) 
			* 
		 (CASE WHEN ISNULL(COALESCE(RVU.Adjustment,RVU2.Adjustment,RVU3.Adjustment,RVU4.Adjustment),0) = 0 THEN CPT.RVU /*No Modifer Adjustment Exists*/
			   WHEN ISNULL(COALESCE(RVU.Adjustment,RVU2.Adjustment,RVU3.Adjustment,RVU4.Adjustment),0) <> 0 THEN CPT.RVU * COALESCE(RVU.Adjustment,RVU2.Adjustment,RVU3.Adjustment,RVU4.Adjustment) /*Modifier Adjustment Exists*/
			   ELSE cpt.RVU END)
			* t.[TransactionUnits] as CalculatedRVU /*Added Voids back in on 1/15/24*/
		
		,mfs.NonFacilityFeeSchedAmt AS UnmodifiedFeeSchedule
		,(mfs.NonFacilityFeeSchedAmt * COALESCE(RVU.Adjustment,RVU2.Adjustment,RVU3.Adjustment,RVU4.Adjustment)) as ModifiedFeeSchedule
		,(CASE WHEN YEAR(t.TransactionDateOfService) = 2024
			THEN(CASE WHEN Mult.row_num = 1 THEN .5
				   WHEN Mult.row_num > 1 THEN .25
				   ELSE 1 END) 
				* 
			 (CASE WHEN ISNULL(COALESCE(RVU.Adjustment,RVU2.Adjustment,RVU3.Adjustment,RVU4.Adjustment),0) = 0 THEN mfs.NonFacilityFeeSchedAmt /*No Modifer Adjustment Exists*/
				   WHEN ISNULL(COALESCE(RVU.Adjustment,RVU2.Adjustment,RVU3.Adjustment,RVU4.Adjustment),0) <> 0 THEN mfs.NonFacilityFeeSchedAmt * COALESCE(RVU.Adjustment,RVU2.Adjustment,RVU3.Adjustment,RVU4.Adjustment) /*Modifier Adjustment Exists*/
				   ELSE mfs.NonFacilityFeeSchedAmt END)
				ELSE null END)
			* t.[TransactionUnits] as CalculatedFeeSchedule
		,t.[TransactionDateOfService]
		,t.[TransactionDateOfPosting]
		,t.[TransactionDateOfBilling]
		,t.[TransactionDateOfVoid]
		,t.[TransactionReportingPeriodID] as TransactionReportPeriodDate
		,FORMAT(DATEFROMPARTS(LEFT(t.TransactionReportingPeriodID,4),RIGHT(t.TransactionReportingPeriodID,2),1),'MMM-yy') AS TransactionReportPeriod 
		,CASE WHEN tc.TransactionGLType = 'Smartbeat' THEN 'Y' /*Associated Charge for Payments and Adjustments*/
			  WHEN t.TransactionGLType = 'Smartbeat' THEN 'Y'
			  /*WHEN SB.[Resource_Desc] like '%smartbeat%' THEN 'Y'*/
			  ELSE 'N' END as TransactionSmartBeat
		,CASE WHEN tc.TransactionGLType = 'RadTC' THEN 'Y' /*Associated Charge for Payments and Adjustments*/
			  WHEN t.TransactionGLType = 'RadTC' THEN 'Y'
			  /*CASE WHEN RTC.TransactionVisitID is not null THEN 'Y'*/
			  ELSE 'N' END as TransactionRadTC
		,t.TransactionPlaceOfServiceCode
		,t.TransactionPlaceOfServiceType
		,t.[TransactionStatus]
		,t.[TransactionIsActive]
		,t.[TransactionUpdatedDateTime]

		/*  info related to original charge  */
		--,cte.TransactionPayerID AS ChargePayerID
		,CASE
			WHEN t.TransactionType = 'charge'
				THEN t.TransactionPayerID
			ELSE tc.TransactionPayerID
		END AS ChargePayerID
		
		,CASE WHEN t.[TransactionGLType] is null THEN tc.TransactionGLType ELSE t.[TransactionGLType] END AS TransactionGLType
		--,t.[TransactionGLType]
		,RIGHT('00' + CONVERT(NVARCHAR, pt.PracticeGLLocationID),2) as TransactionGLLocationID
		,RIGHT('000' + CONVERT(NVARCHAR, pt.PracticeGLPracticeID),3) as TransactionGLPracticeID
		,pp.PracticeProviderGLProviderID as TransactionGLProviderID
		,'4010' as TransactionGLSegmentDescription
		,--CASE WHEN t.TransactionType = 'Payment' THEN
			CASE WHEN COALESCE(t.TransactionGLType,tc.TransactionGLType) = 'RadTC' THEN '41' /*Rad TC*/
				 WHEN COALESCE(t.TransactionDepartmentID,tc.TransactionDepartmentID) = '1~10' THEN '61' /*PI*/
				 WHEN COALESCE(t.TransactionDepartmentID,tc.TransactionDepartmentID) = '1~15' THEN '01' /*Direct for GMNH*/
				 WHEN pp.PracticeProviderGLTypeID = '21' THEN '21' /*Billing Provider is Associate*/
				 WHEN COALESCE(t.TransactionGLType,tc.TransactionGLType) = 'Xray' THEN '41' /*X-Ray*/  
				 WHEN COALESCE(t.TransactionGLType,tc.TransactionGLType) = 'DME' THEN '31' /*DME*/
				 WHEN COALESCE(t.TransactionGLType,tc.TransactionGLType) = 'Ultrasound' THEN '34' /*Ultrasound*/
				 WHEN COALESCE(t.TransactionGLType,tc.TransactionGLType) = 'Lab' THEN '51' /*Lab*/
				 WHEN COALESCE(t.TransactionGLType,tc.TransactionGLType) = 'Smartbeat' THEN '55' /*Smartbeat*/
				 WHEN COALESCE(t.TransactionGLType,tc.TransactionGLType) = 'MaxPulse' THEN '56' /*Max Pulse*/
				 WHEN COALESCE(t.TransactionGLType,tc.TransactionGLType) in ('Heartcloud','ANS','URO') and pp.PracticeProviderIsPrimary = 1 THEN '01' /*Direct for Heartcloud*/
				 WHEN COALESCE(t.TransactionGLType,tc.TransactionGLType) in ('Heartcloud','ANS','URO') and pp.PracticeProviderGLTypeID is not null THEN pp.PracticeProviderGLTypeID /*PA, ARNP, etc for Heartcloud*/
				 WHEN COALESCE(t.TransactionGLType,tc.TransactionGLType) is null and pp.PracticeProviderIsPrimary = 1 THEN '01' /*Direct*/
				 WHEN COALESCE(t.TransactionGLType,tc.TransactionGLType) is null and pp.PracticeProviderGLTypeID is not null THEN pp.PracticeProviderGLTypeID /*PA, ARNP, etc*/
				 ELSE '99' /*Admin for non-mapped or no longer effective practice providers*/
			END 
		 --END 
		 as TransactionGLSegmentType

	FROM fact.TransactionsPB t
		left join stg.PBProcedureCodeCategories c ON c.ProcedureCode = t.TransactionCode AND t.TransactionType = 'Charge'
		left join stg.PBProcedureCategories cat ON cat.ProcedureCategory = CASE WHEN c.ProcedureCodeIsLocationDependent = 1 and t.TransactionPlaceOfServiceCode in ('21','22') THEN 'Outpatient Procedures' 
																				WHEN c.ProcedureCodeIsLocationDependent = 1 and t.TransactionPlaceOfServiceCode not in ('21','22') THEN 'In Office Procedures'
																				ELSE c.ProcedureCodeCategory END
		left join dim.DataSources ds ON t.TransactionDatasourceID = ds.DataSourceID
		left join map.ProviderLinking pl ON pl.ChildProviderID = t.TransactionBillingProviderID
		left join map.PracticeDepartments pd ON pd.DepartmentID = t.TransactionDepartmentID
		left join map.vPracticeProviders pp ON pp.ParentProviderID = pl.ParentProviderID
											AND pp.PracticeProviderEffectiveDate <= t.TransactionDateOfPosting 
											AND pp.PracticeProviderEndDate >= t.TransactionDateOfPosting
											/*This is here to handle duplicates with Amy James and Murphi Scarborough at multiple practices*/
											AND ((t.TransactionBillingProviderID in ('1~19898','5~126867','1~19711','5~125582') AND (pp.PracticeID = pd.PracticeID OR (pd.PracticeID is null AND t.TransactionBillingProviderID = pp.ProviderID)))
												  OR t.TransactionBillingProviderID not in ('1~19898','5~126867','1~19711','5~125582'))
											--AND pp.ProviderID = t.TransactionBillingProviderID
		left join dim.Practices pt ON pt.PracticeID = COALESCE(pd.PracticeID,pp.PracticeID)

		-- 1/4: RR joins added to include CPTs from CMS (Integris) and RVU adjustments from AMGA
		LEFT JOIN map.RVUModifier rvu ON t.TransactionModifier1 = rvu.Modifier AND t.TransactionModifier1 <> '51'
		LEFT JOIN map.RVUModifier rvu2 ON t.TransactionModifier2 = rvu2.Modifier AND t.TransactionModifier2 <> '51'
		LEFT JOIN map.RVUModifier rvu3 ON t.TransactionModifier3 = rvu3.Modifier AND t.TransactionModifier3 <> '51'
		LEFT JOIN map.RVUModifier rvu4 ON t.TransactionModifier4 = rvu4.Modifier AND t.TransactionModifier4 <> '51'
		LEFT JOIN stg.MedicareFeeSchedule mfs ON t.TransactionCPTCode = mfs.HCPCSCode
												AND CASE WHEN t.TransactionModifier1 in ('53','26','TC') THEN t.TransactionModifier1 
														  WHEN t.TransactionModifier2 in ('53','26','TC') THEN t.TransactionModifier2
														  WHEN t.TransactionModifier3 in ('53','26','TC') THEN t.TransactionModifier3
														  WHEN t.TransactionModifier4 in ('53','26','TC') THEN t.TransactionModifier4
														  ELSE '' END = mfs.Modifier
		LEFT JOIN dim.CPTCode cpt ON cpt.CPTCode = t.TransactionCPTCode 
			AND t.TransactionDateOfPosting >= cpt.EffectiveStartdate 
			AND t.TransactionDateOfPosting < cpt.EffectiveEndDate
			AND t.TransactionType = 'Charge'

		LEFT JOIN (
					SELECT 
						TransactionVisitID as TransactionVisitID
						, TransactionCPTCode
						, max(cpt.rvu) Rvu
						, ROW_NUMBER() OVER(PARTITION BY [TransactionVisitID] ORDER BY max(cpt.RVU) desc) as row_num
					FROM [HPIDW].[fact].[TransactionsPB] t
						LEFT JOIN dim.CPTCode cpt ON cpt.CPTCode = t.TransactionCPTCode 
													AND t.TransactionDateOfPosting >= cpt.EffectiveStartDate 
													AND t.TransactionDateOfPosting < cpt.EffectiveEndDate
					WHERE 1=1 -- AND TransactionAccountID = '1~19228230'
						AND TransactionType = 'Charge'
						AND (TransactionModifier1 = '51' OR TransactionModifier2 = '51' OR TransactionModifier3 = '51' OR TransactionModifier4 = '51')
						AND YEAR(TransactionDateOfPosting) >= (year(getdate()) - 2)
						--AND TransactionBillingType = 'PB'
						--AND TransactionStatus = 'Active' /*Excluding Voided Transactions*/
					GROUP BY  
						[TransactionVisitID],
						TransactionCPTCode
					) as Mult ON Mult.TransactionVisitID = t.TransactionVisitID 
							 AND Mult.TransactionCPTCode = t.TransactionCPTCode 
							 AND t.TransactionType = 'Charge'				 
				  
		LEFT JOIN fact.Accounts a ON a.AccountID = t.TransactionAccountID -- for patient MRN 2/1/24 and employer 4/18/24
		LEFT JOIN dim.Patients p ON p.PatientID = a.AccountPatientID -- for patient MRN 2/1/24
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
		left join stg.PBProcedureCodeCategories cc ON cc.ProcedureCode = tc.TransactionCode AND tc.TransactionType = 'Charge'
		left join dim.ProcedureCodes pcpt on pcpt.ProcedureCode = t.TransactionCPTCode and pcpt.ProcedureCodeDataSourceID = t.TransactionDatasourceID
		left join dim.ProcedureCodes pcpt2 on pcpt2.ProcedureCode = tc.TransactionCPTCode and pcpt2.ProcedureCodeDataSourceID = tc.TransactionDatasourceID
							   

	where 1=1 
	AND t.TransactionBillingType = 'PB'
	AND year(t.TransactionDateOfPosting) >= (year(getdate()) - 2)
	--AND t.TransactionModifier1 is not null
	--AND YEAR(t.TransactionDateOfService) = 2023 -- testing 
	--AND (t.TransactionModifier1 = '51' OR t.TransactionModifier2 = '51' OR t.TransactionModifier3 = '51' OR t.TransactionModifier4 = '51') -- testing
	--AND t.TransactionAccountID = '1~19228230' -- testing
	--AND t.TransactionSourceID = 'PB~18302254~4710192' --testing

) sub

--GO
