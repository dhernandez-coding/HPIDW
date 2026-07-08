CREATE VIEW [fact].[vTransactionsPB] as

/*
Change Control:

	1. 9/3/24 - Chris Cross - Replaced fact.Transactions2 with PB-filtered fact.TransactionsPB core table to improve performance
	2. 11/5/2024 - Diego Hernandez - Added TransactionForecastDay, TransactionPaymentLagPost and TransactionPaymentDOS
	3. 05/21/2025 - Eric Silvestri - Added TransactionIsDenial and TransactionDenialType
	4. 10/28/2025 - Eric Silvestri - Added ICD10 codes
	5. 6/2/2026 - Chris Cross - Replaced HPIApp.dbo.PBProcedureCategories with [HERO-DB].hpi.dbo.PBProcedureCategoriess to look at new HERO app
*/


SELECT 
	sub.*
	, CASE WHEN sub.TransactionGLSegmentType = '99' THEN '00' /*Administrative*/ 
			 --WHEN sub.TransactionPracticeID = '0~TDT' AND sub.TransactionVisitLocationID in ('1~95','1~135','1~200') THEN '22' /*Thomason - Hinton*/ 
			 --WHEN sub.TransactionPracticeID = '0~TDT' AND sub.TransactionVisitLocationID = '1~223' THEN '30' /*Thomason - Binger*/
			 --WHEN sub.TransactionPracticeID = '0~TDT' AND sub.TransactionVisitLocationID = '1~230' THEN '31' /*Thomason - Hydro*/
			WHEN sub.TransactionDepartmentID = '5~42501006002' THEN '34' --Checks if Choctaw department for Shadid
			WHEN sub.TransactionDepartmentID = '5~42501006001' THEN '23' --Checks if Choctaw department for Shadid
			WHEN (sub.TransactionVisitLocationID IN ('1~95','1~135','1~200') OR sub.TransactionDepartmentID = '5~42501041001') AND sub.TransactionPracticeID = '0~TDT' THEN '22' -- checks for location and provider for Thomason
			WHEN (sub.TransactionVisitLocationID = '1~223' OR sub.TransactionDepartmentID = '5~42501043001') AND sub.TransactionPracticeID = '0~TDT' THEN '30'
			WHEN (sub.TransactionVisitLocationID = '1~230' OR sub.TransactionDepartmentID = '5~42501042001') AND sub.TransactionPracticeID = '0~TDT' THEN '22' --2/2/26 - Change to 22 instead of 31 per Michael Clough
		     WHEN sub.TransactionGLLocationID is not null THEN sub.TransactionGLLocationID
			 END as TransactionGLSegmentLocation
	, CASE WHEN sub.TransactionGLSegmentType = '99' THEN '000' /*Administrative*/
			 WHEN sub.TransactionBillingProviderID = '5~114876' THEN 'Nancy Turner' /*Nancy Turner Exception*/
			 ELSE sub.TransactionGLPracticeID /*Assigned from mapped practice*/
		END as TransactionGLSegmentPractice
	, CASE WHEN sub.TransactionGLSegmentType in ('01','41','31','34','51','55','56','59','99') THEN '000' /*Direct, Procedure Category Types, and Administrative*/
		   WHEN sub.TransactionGLProviderID IS NOT NULL THEN sub.TransactionGLProviderID /*Assigned from mapped practice provider*/
		   ELSE '000' /*Billing Provider is Practice Provider*/
		END as TransactionGLSegmentProvider
	,CASE WHEN DATEFROMPARTS(LEFT(sub.TransactionReportPeriodDate, 4), RIGHT(sub.TransactionReportPeriodDate, 2),1) between (DATEADD(MONTH,-13,DATEFROMPARTS(YEAR(CAST(GETDATE() AS DATE)), MONTH(CAST(GETDATE() AS DATE)),1))) AND (DATEADD(MONTH,-1,DATEFROMPARTS(YEAR(CAST(GETDATE() AS DATE)), MONTH(CAST(GETDATE() AS DATE)),1))) THEN 'Y' ELSE 'N' END as TransactionTrailing13Months
	,CASE WHEN DATEFROMPARTS(LEFT(sub.TransactionReportPeriodDate, 4), RIGHT(sub.TransactionReportPeriodDate, 2),1) = (DATEADD(MONTH,-1,DATEFROMPARTS(YEAR(CAST(GETDATE() AS DATE)), MONTH(CAST(GETDATE() AS DATE)),1))) THEN 'Y' ELSE 'N' END as TransactionCurrentMonthEnd
	,ROUND(sub.CalculatedFeeSchedule * 0.02,2) AS SequestrationAmount  -- Sequestration Rate = 0.02
	,CASE WHEN sub.TransactionType = 'Charge' THEN DATEADD(DAY, sub.TransactionPaymentLagPost, sub.TransactionDateOfPosting) ELSE NULL END AS TransactionDateOfForecastCollection
	,GETDATE() as AsOfDatetime

FROM (

	SELECT
		t.[TransactionID]
		,t.TransactionDatasourceID
		,ds.DataSourceName as TransactionDataSource
		,CONCAT(t.[TransactionDatasourceID],'~',t.[TransactionSourceID]) as TransactionSourceID
		,CONCAT(t.[TransactionDatasourceID],'~',t.[TransactionParentSourceID]) as TransactionParentSourceID
		,COALESCE(t.TransactionPatientID, a.AccountPatientID) as PatientID
		,p.PatientMRN [PatientMRN] -- added with 2 joins below 2/1
		,t.[TransactionVisitID]
		,t.[TransactionAccountID]
		,t.TransactionVisitID as [TransactionEncounterID]
		,COALESCE(t.TransactionDepartmentID,tc.TransactionDepartmentID) as TransactionDepartmentID
		,v.VisitLocationID as TransactionVisitLocationID
		,t.[TransactionPayerID]
		,t.[TransactionPayerPlanID]
		,a.AccountEmployerName as Employer
		,t.[TransactionBillingProviderID]
		,pt.PracticeID as TransactionPracticeID
		,t.[TransactionBillingType] -- Maybe remove this 
		,t.[TransactionType]
		,t.[TransactionSubType]
		,CASE WHEN t.TransactionType = 'Charge' THEN '1_Charge'
			  WHEN t.TransactionType = 'Adjustment' THEN pba.PBAdjustmentCodeCategory
			  WHEN t.TransactionSubType like '%Refund%' THEN '7_Refund'
			  /*Include Payment Code mapping here*/
			  WHEN t.TransactionType = 'Payment' AND ISNULL(pg.PayerGroupName,'') <> 'Self-Pay' THEN '5_Payer Receipts'
			  WHEN t.TransactionType = 'Payment' AND ISNULL(pg.PayerGroupName,'') = 'Self-Pay' THEN '6_Patient Receipts'
			  
			  END as TransactionARCategory
		,CASE WHEN t.TransactionType = 'Charge' THEN ppl.PaymentLagDOS ELSE NULL END AS TransactionPaymentLagDOS
        ,CASE WHEN t.TransactionType = 'Charge' THEN ppl.PaymentLagPost ELSE NULL END AS TransactionPaymentLagPost
		,t.[TransactionRevenueCode]
		,t.[TransactionRevenueCodeDescription]
		,t.[TransactionCode]
		,t.[TransactionDescription]
		,COALESCE(t.[TransactionCPTCode],tc.TransactionCPTCode) as TransactionCPTCode
		,CASE WHEN t.TransactionType='Payment' THEN pcpt2.CPTDescription ELSE cpt.CPTDescription END as TransactionCPTDescription
		,CASE WHEN t.TransactionType='Payment' THEN cc.[ProcedureCodeDHSCategory] ELSE c.[ProcedureCodeDHSCategory] END AS TransactionCPTCodeDHSCategory
		,CASE WHEN t.TransactionType='Payment' THEN cc.[ProcedureCodeInPlay] ELSE c.[ProcedureCodeInPlay] END AS TransactionCPTCodeInPlay
		,cat.ProcedureCategoryPriority as ProcedureCategoryRank
		,cat.ProcedureCategory as ProcedureCategory
		,cat.ProcedureCategoryVisitType as ProcedureVisitType
		,t.[TransactionModifier1]
		,t.[TransactionModifier2]
		,t.[TransactionModifier3]
		,t.[TransactionModifier4]
		,t.TransactionICD10Dx1
		,t.TransactionICD10Dx2
		,t.TransactionICD10Dx3
		,t.TransactionICD10Dx4
		,t.TransactionICD10Dx5
		,t.[TransactionUnits]
		,t.[TransactionActiveARAmount]
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
		
		,CASE WHEN t.TransactionPlaceOfServiceCode in ('21','22') THEN mfs.FeeScheduleFacilityRate ELSE mfs.FeeScheduleNonFacilityRate END AS UnmodifiedFeeSchedule
		,(CASE WHEN t.TransactionPlaceOfServiceCode in ('21','22') THEN mfs.FeeScheduleFacilityRate ELSE mfs.FeeScheduleNonFacilityRate END  * COALESCE(RVU.Adjustment,RVU2.Adjustment,RVU3.Adjustment,RVU4.Adjustment)) as ModifiedFeeSchedule
		,CASE WHEN pp.PracticeProviderGLType in ('PA','APRN') THEN .85 ELSE 1 END as MidlevelDiscount
		,((CASE WHEN YEAR(t.TransactionDateOfService) >= 2024
			THEN(CASE WHEN Mult.row_num = 1 THEN .5
					WHEN Mult.row_num > 1 THEN .25
					ELSE 1 END) 
				* 
				(CASE WHEN ISNULL(COALESCE(RVU.Adjustment,RVU2.Adjustment,RVU3.Adjustment,RVU4.Adjustment),0) = 0 THEN CASE WHEN t.TransactionPlaceOfServiceCode in ('21','22') THEN mfs.FeeScheduleFacilityRate ELSE mfs.FeeScheduleNonFacilityRate END  /*No Modifer Adjustment Exists*/
					WHEN ISNULL(COALESCE(RVU.Adjustment,RVU2.Adjustment,RVU3.Adjustment,RVU4.Adjustment),0) <> 0 THEN CASE WHEN t.TransactionPlaceOfServiceCode in ('21','22') THEN mfs.FeeScheduleFacilityRate ELSE mfs.FeeScheduleNonFacilityRate END  * COALESCE(RVU.Adjustment,RVU2.Adjustment,RVU3.Adjustment,RVU4.Adjustment) /*Modifier Adjustment Exists*/
					ELSE CASE WHEN t.TransactionPlaceOfServiceCode in ('21','22') THEN mfs.FeeScheduleFacilityRate ELSE mfs.FeeScheduleNonFacilityRate END  END)
				ELSE null END) 
				*
				CASE WHEN pp.PracticeProviderGLType in ('PA','APRN') THEN .85 ELSE 1 END 
				* 
				ISNULL(fsc.FeeScheduleRateMultiplier,1))
			* t.[TransactionUnits] as CalculatedFeeSchedule
		,fs.FeeScheduleID
		,fsc.FeeScheduleName 

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
		,t.TransactionPlaceOfService
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
		,CASE
			WHEN t.TransactionType = 'charge'
				THEN t.TransactionPayerPlanID
			ELSE tc.TransactionPayerPlanID
		END AS ChargePayerPlanID
		
		,CASE WHEN t.[TransactionGLType] is null THEN tc.TransactionGLType ELSE t.[TransactionGLType] END AS TransactionGLType
		--,t.[TransactionGLType]
		,RIGHT('00' + CONVERT(NVARCHAR, pt.PracticeGLLocationID),2) as TransactionGLLocationID
		,RIGHT('000' + CONVERT(NVARCHAR, pt.PracticeGLPracticeID),3) as TransactionGLPracticeID
		,pp.PracticeProviderGLProviderID as TransactionGLProviderID
		,'4010' as TransactionGLSegmentDescription
		,--CASE WHEN t.TransactionType = 'Payment' THEN
			CASE WHEN pt.PracticeIsActive = 0 THEN '99' /*Set to 99-inactive for inactive practices - Chris Cross added on 4/1/25*/
				 WHEN COALESCE(t.TransactionGLType,tc.TransactionGLType) = 'RadTC' THEN '41' /*Rad TC*/
				 WHEN COALESCE(t.TransactionDepartmentID,tc.TransactionDepartmentID) in ('1~10','1~25') THEN '61' /*PI*/ 
				 WHEN COALESCE(t.TransactionDepartmentID,tc.TransactionDepartmentID) = '1~15' THEN '01' /*Direct for GMNH*/
				 WHEN pp.PracticeProviderGLTypeID = '21' THEN '21' /*Billing Provider is Associate*/
				 WHEN COALESCE(t.TransactionGLType,tc.TransactionGLType) = 'Xray' THEN '41' /*X-Ray*/  
				 WHEN COALESCE(t.TransactionGLType,tc.TransactionGLType) = 'DME' THEN '31' /*DME*/
				 WHEN COALESCE(t.TransactionGLType,tc.TransactionGLType) = 'Allergy' THEN '59' /*Allergy*/ --Added 1/28/2026
				 WHEN COALESCE(t.TransactionGLType,tc.TransactionGLType) = 'Ultrasound' THEN '34' /*Ultrasound*/
				 WHEN COALESCE(t.TransactionGLType,tc.TransactionGLType) = 'Lab' THEN '51' /*Lab*/
				 WHEN COALESCE(t.TransactionGLType,tc.TransactionGLType) = 'Smartbeat' THEN '55' /*Smartbeat*/
				 WHEN COALESCE(t.TransactionGLType,tc.TransactionGLType) = 'MaxPulse' THEN '56' /*Max Pulse*/
				 WHEN COALESCE(t.TransactionGLType,tc.TransactionGLType) in ('Heartcloud','ANS','URO') and pp.PracticeProviderIsPrimary = 1 THEN '01' /*Direct for Heartcloud*/
				 WHEN COALESCE(t.TransactionGLType,tc.TransactionGLType) in ('Heartcloud','ANS','URO') and pp.PracticeProviderGLTypeID is not null THEN pp.PracticeProviderGLTypeID /*PA, ARNP, etc for Heartcloud*/
				 WHEN COALESCE(t.TransactionGLType,tc.TransactionGLType) is null and pp.PracticeProviderIsPrimary = 1 THEN '01' /*Direct*/
				 WHEN COALESCE(t.TransactionGLType,tc.TransactionGLType) is null and pp.PracticeProviderGLProviderID in ('000') THEN '01' /*PA, ARNP, etc moved to Direct - Chris Cross added on 4/14/25*/
				 WHEN COALESCE(t.TransactionGLType,tc.TransactionGLType) is null and pp.PracticeProviderGLTypeID is not null THEN pp.PracticeProviderGLTypeID /*PA, ARNP, etc*/
				 WHEN COALESCE(t.TransactionGLType,tc.TransactionGLType) is null and COALESCE(t.TransactionBillingProviderID,tc.TransactionBillingProviderID) IS NULL and pt.PracticeIsActive = 1 THEN '01' /*Direct - Chris Cross added on 4/1/25*/
				 ELSE '99' /*Admin for non-mapped or no longer effective practice providers*/
			END 
		 --END 
			 as TransactionGLSegmentType
	  ,CASE WHEN t.TransactionType = 'Adjustment' THEN
	  		CASE WHEN t.TransactionDescription like 'DEN -%' THEN 'Yes'
			     WHEN t.TransactionDescription like 'DEN-%' THEN 'Yes'
				 WHEN t.TransactionDescription in ('CBO INCLUSIVE/INCLUDED IN PMT OF OTHER SERVICE'													
													,'CBO MUE DENIED MAX/FREQUENCY/LIMIT EXCEEDED'
													,'CBO NO AUTHORIZATION/AUTHORIZATION REQUIRED'
													,'CBO PAST TIMELY FILING DEMO/OFFICE ERROR'
													,'WRITE-OFF (UNCOLLECTIBLE DENIAL)') THEN 'Yes'
				WHEN t.TransactionCode in ('EXPERIM','INCLUS','LACKMEDN','MUE','NOAUTH','NODOCUM','NONCOV','NONCOVPT',
											'PANONCO','PASTTIME','PASTTIML','BELOWMIN','UNDAPPL','POSTOP') THEN 'Yes'
				 ELSE 'No' END
		  ELSE 'No'	END as TransactionIsDenial
	  ,CASE WHEN t.TransactionType = 'Adjustment' THEN
				/* ----EPIC - Denial Adjustments----- */
		  CASE WHEN t.TransactionDescription = 'DEN - BENEFITS EXHAUSTED' THEN 'Benefits Exhausted'
				WHEN t.TransactionDescription = 'DEN - BILLING ERROR' THEN 'Billing Error'
				WHEN t.TransactionDescription = 'DEN - FREQUENCY, LENGTH, DOSAGE, DAY''S SUPPLY' THEN 'Not Covered/Limit Exceeded'
				WHEN t.TransactionDescription = 'DEN - LATE OR NO NOTIFICATION' THEN 'Past Timely Filing'
				WHEN t.TransactionDescription = 'DEN - LEVEL OF SERVICE/CARE - HOSPITAL ACQUITY' THEN 'Level of Care'
				WHEN t.TransactionDescription = 'DEN - MED POL/PROC DEEMED EXPERIMENTAL/NOT APRVD BY FDA' THEN 'Not Medically Necessary'
				WHEN t.TransactionDescription = 'DEN - MEDICAL NECESSITY' THEN 'Not Medically Necessary'
				WHEN t.TransactionDescription = 'DEN - NO AUTH - AUTH NOT APPROVED (NAANA)' THEN 'No Authorization'
				WHEN t.TransactionDescription = 'DEN - NO AUTH - DOS OUTSIDE ORIGINAL AUTH (NADE)' THEN 'No Authorization'
				WHEN t.TransactionDescription = 'DEN - NO AUTH - PT REGISTERED WRONG (NAR)' THEN 'No Authorization'
				WHEN t.TransactionDescription = 'DEN - NO AUTHORIZATION NOT ATTEMPTED' THEN 'No Authorization'
				WHEN t.TransactionDescription = 'DEN - NO AUTO - AUTH ON FILE (NAAF)' THEN 'No Authorization'
				WHEN t.TransactionDescription = 'DEN - NO PRECERT/AUTH/NOTIFICATION' THEN 'No Authorization'
				WHEN t.TransactionDescription = 'DEN - NON-COVERED SERVICE' THEN 'No Authorization'
				WHEN t.TransactionDescription = 'DEN - PYMT INCLUDES PYMT FOR OTHER SVC/PROC NOT PD SEPARATELY' THEN 'Inclusive'
				WHEN t.TransactionDescription = 'DEN - TIMELY CLAIM NOT FILED' THEN 'Past Timely Filing'
				WHEN t.TransactionDescription = 'DEN - TIMELY ELIGIBILITY/INCORRECT INSURANCE' THEN 'Past Timely Filing'
				WHEN t.TransactionDescription = 'DEN - TIMELY PAST APPEAL DEADLINE' THEN 'Past Timely Filing'
				WHEN t.TransactionDescription = 'DEN-NO AUTHORIZATION-CLINICAL SUBMITTED BUT NOT RECEIVED' THEN 'No Authorization'
				WHEN t.TransactionDescription = 'CBO INCLUSIVE/INCLUDED IN PMT OF OTHER SERVICE' THEN 'Inclusive'
				WHEN t.TransactionDescription = 'CBO MUE DENIED MAX/FREQUENCY/LIMIT EXCEEDED' THEN 'Not Covered/Limit Exceeded'
				WHEN t.TransactionDescription = 'CBO NO AUTHORIZATION/AUTHORIZATION REQUIRED' THEN 'No Authorization'
				WHEN t.TransactionDescription = 'CBO PAST TIMELY FILING DEMO/OFFICE ERROR' THEN 'Past Timely Filing'
				WHEN t.TransactionDescription = 'WRITE-OFF (UNCOLLECTIBLE DENIAL)' THEN 'Unspecified'
				WHEN t.TransactionDescription like 'DEN -%' OR t.TransactionDescription like 'DEN-%' THEN 'Unspecified'
				/* ----APM - Denial Adjustments----- */
				WHEN t.TransactionDescription = 'Experimental/unproven/investig denial' THEN 'Not Medically Necessary'
				WHEN t.TransactionDescription = 'Lacks Medical Necessity denial' THEN 'Not Medically Necessary'
				WHEN t.TransactionDescription = 'MUE Denied Max/Frequency limit exceeded' THEN 'Not Covered/Limit Exceeded'
				WHEN t.TransactionDescription = 'Not Authorized/No Referral -ins requires' THEN 'No Authorization'
				WHEN t.TransactionDescription = 'Lack of Documentation/serv not supported' THEN 'Not Covered/Limit Exceeded'
				WHEN t.TransactionDescription = 'Non Covered Non Billable to Patient' THEN 'No Authorization'
				WHEN t.TransactionDescription = 'NON COVERED PATIENT LIABLE' THEN 'No Authorization'
				WHEN t.TransactionDescription = 'PA Physician Assist Non Covered CPT Code' THEN 'Not Covered/Limit Exceeded'
				WHEN t.TransactionDescription = 'Past Timely Filing Demo/Office Error' THEN 'Past Timely Filing'
				WHEN t.TransactionDescription = 'Past Timely Filing or Appeal' THEN 'Past Timely Filing'
				WHEN t.TransactionDescription = 'BELOW MINIMUM REIMBURSEMENT FOR APPEAL' THEN 'Unspecified'
				WHEN t.TransactionDescription = 'Under Appeal Limit' THEN 'Unspecified'
				WHEN t.TransactionDescription = 'Inclusive/included in pymt of other serv' THEN 'Inclusive'
				WHEN t.TransactionDescription = 'Post Op Services/Global to prev surgery' THEN 'Not Covered/Limit Exceeded'
			 END
		 END as TransactionDenialType
	FROM fact.TransactionsPB t
		LEFT JOIN fact.Accounts a ON a.AccountID = t.TransactionAccountID -- for patient MRN 2/1/24 and employer 4/18/24
		LEFT JOIN dim.Patients p ON p.PatientID = COALESCE(t.TransactionPatientID, a.AccountPatientID) -- for patient MRN 2/1/24
		left join dim.vPBProcedureCodeCategories c ON c.ProcedureCode = COALESCE(t.TransactionCPTCode,t.TransactionCode) AND t.TransactionType = 'Charge'
		left join [HERO-DB].hpi.dbo.PBProcedureCategoriess cat ON cat.ProcedureCategory = CASE WHEN c.ProcedureCodeIsLocationDependent = 1 and t.TransactionPlaceOfServiceCode in ('21','22') THEN 'Outpatient Procedures' 
																				WHEN c.ProcedureCodeIsLocationDependent = 1 and t.TransactionPlaceOfServiceCode not in ('21','22') THEN 'In Office Procedures'
																				ELSE c.ProcedureCodeCategory END
		left join dim.DataSources ds ON t.TransactionDatasourceID = ds.DataSourceID
		left join map.ProviderLinking pl ON pl.ChildProviderID = t.TransactionBillingProviderID AND NOT ( pl.ChildProviderID LIKE '18~%' OR pl.ChildProviderID LIKE '17~%') --Here for handle duplicates with THP Providers on APM
		left join map.PracticeDepartments pd ON pd.DepartmentID = t.TransactionDepartmentID
		left join map.vPracticeProviders pp ON pp.ParentProviderID = pl.ParentProviderID
									AND pp.PracticeProviderEffectiveDate <= t.TransactionDateOfPosting 
									AND pp.PracticeProviderEndDate >= t.TransactionDateOfPosting
									AND pp.ProviderDataSourceID not in (18,17)
									--AND pp.ProviderdatasourceID = t.TransactionDatasourceID
									AND (/*This is here to handle duplicates with Murphi Scarborough at multiple practices*/
												(pl.ParentProviderID in ('0~1588209423') 
													AND (pp.PracticeID = pd.PracticeID OR (pd.PracticeID is null AND (t.TransactionDatasourceID = 5 AND pp.PracticeID = '0~RGS')
																													  OR (t.TransactionDatasourceID = 1 AND pp.PracticeID = '0~RLN'))) )
												/*This is here to handle duplicates with Amy James at multiple practices*/
												OR (pl.ParentProviderID in ('0~1679132823') 
													AND (pp.PracticeID = pd.PracticeID OR (pd.PracticeID is null AND (t.TransactionDatasourceID = 5 AND pp.PracticeID = '0~MDW')
																													  OR (t.TransactionDatasourceID = 1 AND pp.PracticeID = '0~CGW'))) )
												/*Chris Cross - 10.7.24 - Added Olivo, Pape, and Dunkleberger due to practicing at PBJ, NMO, and NRJ; Defaults to PBJ if no mapped department defined in Epic*/
												OR (pl.ParentProviderID in ('0~1992746200','0~1891761136','0~1376509828') 
													AND (pp.PracticeID = pd.PracticeID OR (pd.PracticeID is null AND  pp.PracticeID = '0~PBJ') ) )
												/*Chris Cross - 02.18.25 - Added Jill Yingling due to practicing at MBJ and RLN; Defaults to RLN if no mapped department defined in Epic*/
												OR (pl.ParentProviderID in ('0~1245788231') 
													AND (pp.PracticeID = pd.PracticeID OR (pd.PracticeID is null AND pp.PracticeID = '0~RLN') ) )
												/*This is here to handle duplicates with Paul Maitino at multiple practices*/
												OR (pl.ParentProviderID in ('0~1376507665') 
													AND (pp.PracticeID = pd.PracticeID OR (pd.PracticeID is null AND (t.TransactionDepartmentID = '12~45' AND pp.PracticeID = '0~JRS')
																													  OR (t.TransactionDepartmentID = '12~46' AND pp.PracticeID = '0~OPCL'))) )
												/*This is here to handle duplicates with Calvin Johnson at multiple practices*/
												OR (pl.ParentProviderID in ('0~1063484251') 
													AND (pp.PracticeID = pd.PracticeID OR (pd.PracticeID is null AND (t.TransactionDepartmentID = '12~48' AND pp.PracticeID = '0~JCJ')
																													  OR (t.TransactionDepartmentID = '12~36' AND pp.PracticeID = '0~JCJ')
																													  OR (t.TransactionDepartmentID = '1~19' AND pp.PracticeID = '0~JCJ2')
																													  OR (t.TransactionDepartmentID = '1~5' AND pp.PracticeID = '0~JCJ2'))) )
												/*This is here to handle duplicates with Joseph Broome at multiple practices*/
												OR (pl.ParentProviderID in ('0~1306817887') 
													AND (pp.PracticeID = pd.PracticeID OR (pd.PracticeID is null AND pp.PracticeID = '0~JCB') ) )
												
												/*All other providers without specific mapping issues due to multiple practices as defined above*/
												OR pl.ParentProviderID not in ('0~1588209423','0~1679132823','0~1992746200','0~1891761136','0~1376509828','0~1245788231','0~1376507665','0~1063484251','0~1306817887'))
													
		left join dim.vPractices pt ON pt.PracticeID = COALESCE(pd.PracticeID,pp.PracticeID)
		left join rpt.PBPaymentLag ppl ON ppl.PracticeID = pt.PracticeID
		-- 1/4: RR joins added to include CPTs from CMS (Integris) and RVU adjustments from AMGA
		LEFT JOIN map.RVUModifier rvu ON t.TransactionModifier1 = rvu.Modifier AND t.TransactionModifier1 <> '51'
		LEFT JOIN map.RVUModifier rvu2 ON t.TransactionModifier2 = rvu2.Modifier AND t.TransactionModifier2 <> '51'
		LEFT JOIN map.RVUModifier rvu3 ON t.TransactionModifier3 = rvu3.Modifier AND t.TransactionModifier3 <> '51'
		LEFT JOIN map.RVUModifier rvu4 ON t.TransactionModifier4 = rvu4.Modifier AND t.TransactionModifier4 <> '51'
		
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
						AND TransactionDateOfPosting >= DATEFROMPARTS(YEAR(GETDATE()) - 5, 1, 1)
						--AND TransactionBillingType = 'PB'
						--AND TransactionStatus = 'Active' /*Excluding Voided Transactions*/
					GROUP BY  
						[TransactionVisitID],
						TransactionCPTCode
					) as Mult ON Mult.TransactionVisitID = t.TransactionVisitID 
							 AND Mult.TransactionCPTCode = t.TransactionCPTCode 
							 AND t.TransactionType = 'Charge'				 
				  

		LEFT JOIN map.PBAdjustmentCodes pba ON pba.PBAdjustmentCodeID = CONCAT(t.TransactionDataSourceID,'~',t.TransactionCode) AND t.TransactionType = 'Adjustment'
		LEFT JOIN dim.Payers py ON py.PayerID = t.TransactionPayerID
		LEFT JOIN dim.PayerCategories pc ON pc.PayerCategoryID = py.PayerCategoryID
		LEFT JOIN dim.PayerGroups pg ON pg.PayerGroupID = py.PayerGroupID
		LEFT JOIN fact.Visits2 v on t.TransactionVisitID = v.VisitID
		LEFT JOIN fact.TransactionsPB tc ON tc.TransactionID = t.TransactionParentID
											AND tc.TransactionType = 'Charge'
											AND t.TransactionType <> 'Charge'
									   --AND CONCAT(t.TransactionDatasourceID,'~',t.TransactionParentSourceID) = tc.TransactionID
		left join  dim.vPBProcedureCodeCategories cc ON cc.ProcedureCode = COALESCE(tc.TransactionCPTCode,tc.TransactionCode) AND tc.TransactionType = 'Charge'
		--left join dim.ProcedureCodes pcpt on pcpt.ProcedureCode = t.TransactionCPTCode and pcpt.ProcedureCodeDataSourceID = t.TransactionDatasourceID
		--left join dim.ProcedureCodes pcpt2 on pcpt2.ProcedureCode = tc.TransactionCPTCode and pcpt2.ProcedureCodeDataSourceID = tc.TransactionDatasourceID
		--left join dim.CPTCode pcpt ON pcpt.CPTCode = t.TransactionCPTCode AND pcpt.EffectiveEndDate > GETDATE()
		left join dim.CPTCode pcpt2 ON pcpt2.CPTCode = tc.TransactionCPTCode AND pcpt2.EffectiveEndDate > GETDATE()

	where 1=1 
		AND t.TransactionDateOfPosting >= DATEFROMPARTS(YEAR(GETDATE()) - 5, 1, 1)
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
