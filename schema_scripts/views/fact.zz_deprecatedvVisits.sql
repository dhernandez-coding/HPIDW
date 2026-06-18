CREATE view [fact].[vVisits] as
--select
--	sub.*
--	,sl.ServiceLineName as VisitServiceLine
--	,b.BudgetID
--from (
	select
		v.[VisitID]
		,v.[VisitDataSourceID]
		--,ds.DataSourceName as VisitDataSource
		,v.[VisitSourceID]
		,v.[VisitReferenceNumber]
		,v.[VisitPatientID]
		,v.[VisitLocationID]
		--,l.LocationName as VisitLocation
		,v.[VisitDepartmentID]
		,v.[VisitRoom]
		,v.[VisitPrimaryDiagnosis]
		,v.[VisitPrimaryProcedureCode]
		,v.[VisitPrimaryPayerID]
		--,pg.PayerGroupID as VisitPrimaryPayerGroupID
		--,pg.PayerGroupName as VisitPrimaryPayerGroup
		--,pc.PayerCategoryID as VisitPrimaryPayerCategoryID
		--,pc.PayerCategoryName as VisitPrimaryPayerCategory
		--,pay.PayerName as VisitPrimaryPayer
		,pp.PayerPlanName as VisitPrimaryPayerPlan
		,v.VisitPrimaryProviderID
		--,prvpf.ParentProviderID as [VisitPrimaryProviderID]
		----,COALESCE(npipf.ProviderName, CONCAT(prvpf.ProviderLastName,', ',prvpf.ProviderFirstName,' ', prvpf.ProviderMiddleInitial)) as VisitPrimaryProvider
		--,prvpf.ProviderFullName as VisitPrimaryProvider
		----,COALESCE(npipf.ProviderSpecialty, spcpf.SpecialtyName) as VisitPrimaryProviderSpecialty
		--,spcpf.SpecialtyID as VisitPrimaryProviderSpecialtyID
		--,spcpf.SpecialtyName as VisitPrimaryProviderSpecialty
		,v.[VisitAdmittingProviderID]
		----,COALESCE(npiad.ProviderName, CONCAT(prvad.ProviderLastName,', ',prvad.ProviderFirstName,' ', prvad.ProviderMiddleInitial)) as VisitAdmittingProvider
		--,prvad.ProviderFullName as VisitAdmittingProvider
		----,COALESCE(npiad.ProviderSpecialty, spcad.SpecialtyName) as VisitAdmittingProviderSpecialty
		--,spcad.SpecialtyName as VisitAdmittingProviderSpecialty
		,v.[VisitAttendingProviderID]
		----,COALESCE(npiat.ProviderName, CONCAT(prvat.ProviderLastName,', ',prvat.ProviderFirstName,' ', prvat.ProviderMiddleInitial)) as VisitAttendingProvider
		--,prvat.ProviderFullName as VisitAttendingProvider
		----,COALESCE(npiat.ProviderSpecialty, spcat.SpecialtyName) as VisitAttendingProviderSpecialty
		--,spcad.SpecialtyName as VisitAttendingProviderSpecialty
		,v.[VisitReferringProviderID]
		----,CONCAT(prvrf.ProviderLastName,', ',prvrf.ProviderFirstName,' ', prvrf.ProviderMiddleInitial) as VisitReferringProvider
		--,prvrf.ProviderFullName as VisitReferringProvider
		,v.[VisitDateOfService]
		,v.[VisitDateOfScheduling]
		,v.[VisitDateOfRegistration]
		,v.[VisitDateOfAdmission]
		,v.[VisitDateOfDischarge]
		,v.[VisitDateOfBilling]
		,v.[VisitDateOfClosing]
		,v.[VisitDateOfCancellation]
		,v.[VisitDateOfZeroBalance]
		,v.[VisitCancelledReason]
		,v.[VisitStatus]
		,v.[VisitClass]
		,v.[VisitType]
		--,CASE WHEN v.VisitType in ('Surgery Admit','Outpatient Surgery','Outpatient', 'Observation','Inpatient','Emergent OR Case','OR Case') THEN spcpf.SpecialtyName
		--	  ELSE v.VisitType END as VisitServiceLine
		,/*Updated Service Line mapping on 7/26 to look at VisitIsSurgicalFlag first*/
		 case when v.VisitIsSurgical = 1 THEN 
				case when VisitType like '%Pain%' then '0~9'
					when spcpf.SpecialtyName like 'ENT' then '0~1'
					when spcpf.SpecialtyName like '%Eyes%' then '0~2'
					when spcpf.SpecialtyName like 'Gastro%' then '0~3'
					when spcpf.SpecialtyName like '%General%' then '0~4'
					when spcpf.SpecialtyName like '%Gynecology%' then '0~5'
					when spcpf.SpecialtyName like '%Ortho%' then '0~6'
					when spcpf.SpecialtyName like '%Spine%' then '0~7'
					when spcpf.SpecialtyName like '%Urology%' then '0~8'
					when spcpf.SpecialtyName like '%Pain%' then '0~9' end
			when VisitType like 'PT%' or VisitType like '%Therapies%' then '0~12'
			when VisitType like '%Mammography%' or VisitType like '%Radiology%' or VisitType like '%DEXA%' or VisitType like '%Radiation%' then '0~17'
			when VisitType like '%Pre%' then '0~20'
			when VisitType like 'CT%'  then '0~10' 
			when VisitType like '%MRI%'  then '0~11'
			when VisitType like '%Emergency%'  then '0~16'
			when VisitType like '%Ultrasound%' or VisitType like 'US' then '0~14' 
			when VisitType like '%Pain%'  then '0~9'
			when VisitType like '%Sleep%'  then '0~13'
			when VisitType like 'Lab%'  then '0~21'
			when VisitType like 'Home%'  then '0~19'
			when VisitType like 'NZT%'  then '0~18'
			else '0~22'
		end as VisitServiceLineID
		,case
			when VisitType like 'PT%' or VisitType like '%Therapies%' then '0~12'
			when VisitType like '%Mammography%' or VisitType like '%Radiology%' or VisitType like '%DEXA%' or VisitType like '%Radiation%' then '0~17'
			when VisitType like '%Pre%' then '0~20'
			when VisitType like 'CT%'  then '0~10'
			when VisitType like '%MRI%'  then '0~11'
			when VisitType like '%Emergency%'  then '0~3'
			when VisitType like '%Ultrasound%' or VisitType like 'US' then '0~14' 
			when VisitType like '%Pain%'  then '0~9'
			when VisitType like '%Sleep%'  then '0~13'
			when VisitType like 'Lab%'  then '0~21'
			when VisitType like 'Home%'  then '0~19'
			when VisitType like 'NZT%'  then '0~18'
			when spcpf.SpecialtyName like 'ENT' then '0~1'
			when spcpf.SpecialtyName like '%Eyes%' then '0~2'
			when spcpf.SpecialtyName like 'Gastro%' then '0~3'
			when spcpf.SpecialtyName like '%General%' then '0~4'
			when spcpf.SpecialtyName like '%Gynecology%' then '0~5'
			when spcpf.SpecialtyName like '%Ortho%' then '0~6'
			when spcpf.SpecialtyName like '%Spine%' then '0~7'
			when spcpf.SpecialtyName like '%Urology%' then '0~8'
			when spcpf.SpecialtyName like '%Pain%' then '0~9'
			else '0~22'
		end as MappedVisitType
		,v.[VisitReason]
		,v.[VisitBillingStatus]
		--,v.[VisitTotalCharges]
		,tx.VisitTotalCharges 
		--,v.[VisitTotalAdjustments]
		,tx.VisitTotalAdjustments 
		--,v.[VisitTotalPayments]
		,tx.VisitTotalPayments 
		--,v.[VisitTotalRefunds]
		--,v.[VisitTotalBalance]
		,tx.VisitTotalBalance
		,v.[VisitAdmittedFrom]
		,v.[VisitDischargedTo]
		,v.[VisitDRG]
		,v.[VisitDRGDescription]
		,CASE WHEN v.VisitDRG is null THEN null ELSE CONCAT(v.VisitDRG,' - ',v.VisitDRGDescription,' (', v.VisitDRGMDC,')') END as VisitDRGWithDescription
		,v.VisitDRGMDC
		,v.VisitDRGType
		,CASE WHEN tx.VisitTotalCharges > 0 AND tx.VisitTotalBalance < (tx.VisitTotalCharges - tx.VisitTotalAdjustments) * .10 THEN 'Yes' ELSE 'No' END as VisitIsMostlyAdjudicated 
		,CASE WHEN tx.VisitTotalBalance = 0 THEN 'Yes' ELSE 'No' END as VisitIsZeroBalance 
		,CASE WHEN v.VisitDataSourceID in (2,8) THEN 'Yes'
			  WHEN v.VisitDataSourceID = 5 and v.VisitSourceID like '6%' THEN 'Yes' 
			  WHEN v.VisitSourceID like 'NoAccount%' THEN 'Yes' /*Scheduled surgeries without a hospital account*/
			  ELSE 'No' END as VisitIsHospital
		/*--Replaced this with VisitIsSurgical from Visits on 7/26--
		,CASE WHEN v.VisitType in ('OUTPATIENT'
								  ,'INPATIENT'
								  ,'GI PATIENTS'
								  ,'SURGICAL'
								  ,'OBSERVATION'
								  ,'EYES'
								  ,'MEDICAL'
								  ,'PAIN MANAGEMENT'
								  ,'ICU'
								  ,'Surgery Admit'
								  ,'Outpatient Surgery'
								  ,'Pain') THEN 'Yes' Else 'No' END*/ 
		,CASE WHEN v.VisitIsSurgical = 1 THEN 'Yes' ELSE 'No' END as VisitIsSurgical
		,CASE WHEN v.VisitType in ('BONE DENSITY'
								,'CT SCAN'
								,'DIAGNOSTIC OTHER'
								,'LAKEPOINTE MRI'
								,'MRI'
								,'NORTH DEXA SCAN'
								,'NORTH MAMMOGRAPHY'
								,'NORTHWEST MRI'
								,'PRE OP DIAGNOSTICS'
								,'PRE-OP DIAGNOSTICS'
								,'ULTRASOUND'
								,'CT'
								,'US'
								,'MRI'
								,'Radiology') THEN 'Yes' ELSE 'No' END AS VisitIsImaging
		,CASE WHEN v.VisitStatus in ('Completed'
									,'Discharged'
									,'Arrived') THEN 'Yes' Else 'No' END as VisitIsArrivedOrCompleted
		,CASE WHEN v.VisitStatus = 'Scheduled' THEN 'Yes'
			  WHEN v.VisitDateOfService >= CONVERT(date,GETDATE())
				   AND ISNULL(v.VisitStatus,'') not in ('Canceled') THEN 'Yes' 
			  ELSE 'No' END as VisitIsScheduled
		,CASE WHEN v.VisitStatus in ('Canceled','No Show') THEN 'Yes' Else 'No' END as VisitIsCancelled
		,v.[VisitIsActive]
		,v.[VisitUpdatedDatetime]
	from fact.Visits v
		--left join dim.DataSources ds ON ds.DataSourceID = v.VisitDataSourceID
		--left join dim.Locations l ON l.LocationID = v.VisitLocationID
		left join dim.vProviders prvpf ON prvpf.ProviderID = v.VisitPrimaryProviderID 
			left join dim.Specialties spcpf ON spcpf.SpecialtyID = prvpf.ParentSpecialtyID
		--left join dim.vProviders prvad ON prvad.ProviderID = v.VisitAdmittingProviderID	
		--	left join dim.Specialties spcad ON spcad.SpecialtyID = prvad.ParentSpecialtyID
		--left join dim.vProviders prvat ON prvat.ProviderID = v.VisitAttendingProviderID 
		--	left join dim.Specialties spcat ON spcat.SpecialtyID = prvat.ParentSpecialtyID
		--left join dim.vProviders prvrf ON prvrf.ProviderID = v.VisitPrimaryProviderID 
		--left join dim.Payers pay ON pay.PayerID = v.VisitPrimaryPayerID
		--left join dim.PayerCategories pc ON pc.PayerCategoryID = pay.PayerCategoryID
		--left join dim.PayerGroups pg ON pg.PayerGroupID = pay.PayerGroupID
		left join dim.PayerPlans pp ON pp.PayerPlanID = v.VisitPrimaryPayerPlanID
		left join (select
					t.TransactionVisitID
					,sum(case when t.TransactionType = 'Charge' THEN t.TransactionAmount ELSE 0 END) as VisitTotalCharges
					,sum(case when t.TransactionType = 'Payment' THEN t.TransactionAmount ELSE 0 END) * -1 as VisitTotalPayments 
					,sum(case when t.TransactionType = 'Adjustment' THEN t.TransactionAmount ELSE 0 END) * -1 as VisitTotalAdjustments
					,sum(t.TransactionAmount) as VisitTotalBalance
				   from fact.Transactions t 
				   group by t.TransactionVisitID) tx ON tx.TransactionVisitID = v.VisitID

	where year(VisitDateOfService) >= (year(getdate()) - 3)
--) sub
--left join dim.Dates d on sub.VisitDateOfService = d.Date
--left join fact.Budgets b on d.FirstDayOfMonth = b.BudgetDate and sub.VisitServiceLineID = b.BudgetServiceLineID and sub.VisitPrimaryProviderID = b.BudgetProviderID and '0~1' = b.BudgetTypeID
--left join dim.ServiceLines sl ON sl.ServiceLineID = sub.VisitServiceLineID
GO
