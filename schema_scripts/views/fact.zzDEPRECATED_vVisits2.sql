CREATE view [fact].[vVisits2] as
	select 
		sub.*
		,b.BudgetID
	from (
	select
		v.[VisitID]
		,v.[VisitDataSourceID]
		,v.[VisitSourceID]
		,v.[VisitReferenceNumber]
		,v.[VisitPatientID]
		,v.[VisitLocationID]
		,v.[VisitDepartmentID]
		,v.[VisitRoom]
		,v.[VisitPrimaryDiagnosis]
		,v.[VisitPrimaryProcedureCode]
		,v.[VisitPrimaryPayerID]
		,v.VisitPrimaryPayerPlanID
		,v.VisitPrimaryProviderID
		,pl.ParentProviderID
		,v.[VisitAdmittingProviderID]
		,v.[VisitAttendingProviderID]
		,v.[VisitReferringProviderID]
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
		,case
			when v.VisitType like 'PT%' or v.VisitType like '%Therapies%' then '0~12'
			when v.VisitType like '%Mammography%' or v.VisitType like '%Radiology%' or v.VisitType like '%DEXA%' or v.VisitType like '%Radiation%' then '0~17'
			when v.VisitType like '%Pre%' then '0~20'
			when v.VisitType like 'CT%'  then '0~10'
			when v.VisitType like '%MRI%'  then '0~11'
			when v.VisitType like '%Emergency%'  then '0~3'
			when v.VisitType like '%Ultrasound%' or v.VisitType like 'US' then '0~14' 
			when v.VisitType like '%Pain%'  then '0~9'
			when v.VisitType like '%Sleep%'  then '0~13'
			when v.VisitType like 'Lab%'  then '0~21'
			when v.VisitType like 'Home%'  then '0~19'
			when v.VisitType like 'NZT%'  then '0~18'
		end as VisitServiceLineID
		,case
			when v.VisitType like 'PT%' or v.VisitType like '%Therapies%' then '0~12'
			when v.VisitType like '%Mammography%' or v.VisitType like '%Radiology%' or v.VisitType like '%DEXA%' or v.VisitType like '%Radiation%' then '0~17'
			when v.VisitType like '%Pre%' then '0~20'
			when v.VisitType like 'CT%'  then '0~10'
			when v.VisitType like '%MRI%'  then '0~11'
			when v.VisitType like '%Emergency%'  then '0~3'
			when v.VisitType like '%Ultrasound%' or v.VisitType like 'US' then '0~14' 
			when v.VisitType like '%Pain%'  then '0~9'
			when v.VisitType like '%Sleep%'  then '0~13'
			when v.VisitType like 'Lab%'  then '0~21'
			when v.VisitType like 'Home%'  then '0~19'
			when v.VisitType like 'NZT%'  then '0~18'
		end as MappedVisitType
		,v.[VisitReason]
		,v.[VisitBillingStatus]
		,v.[VisitAdmittedFrom]
		,v.[VisitDischargedTo]
		,v.[VisitDRG]
		,v.[VisitDRGDescription]
		,CASE WHEN v.VisitDRG is null THEN null ELSE CONCAT(v.VisitDRG,' - ',v.VisitDRGDescription,' (', v.VisitDRGMDC,')') END as VisitDRGWithDescription
		,v.VisitDRGMDC
		,v.VisitDRGType
		,CASE WHEN v.VisitDataSourceID in (2,8) THEN 'Yes'
			  WHEN v.VisitDataSourceID = 5 and v.VisitSourceID like '6%' THEN 'Yes' 
			  ELSE 'No' END as VisitIsHospital
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
								  ,'Pain') THEN 'Yes' Else 'No' END as VisitIsSurgical
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
		,DATEFROMPARTS(year(v.visitdateofservice), month(v.visitdateofservice), 1) budgetdate
	from fact.Visits v
	left join map.ProviderLinking pl on v.VisitReferringProviderID = pl.ChildProviderID
		where VisitDateOfService >= dateadd(year, -2, getdate())
	) sub
	left join fact.vBudgets b on DATEFROMPARTS(year(sub.visitdateofservice), month(sub.visitdateofservice), 1) = b.BudgetDate and sub.ParentProviderID = b.BudgetProviderID and sub.VisitServiceLineID = b.BudgetServiceLineID
GO
