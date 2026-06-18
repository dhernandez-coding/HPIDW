CREATE PROCEDURE [stg].[spEPICReloadFactVisitsFull] AS 
  
 /*Load Temporary Table for Hospital Encounters*/
	select 
	e.PAT_ENC_CSN_ID as EncounterID
	,e.PAT_ID  as EncounterPatientID
	,e.HSP_ACCOUNT_ID as EncounterAccountID
	,har.PRIM_ENC_CSN_ID as AccountPrimaryEncounterID
	,bc.NAME as AccountBaseClass
	,ac.NAME as AccountClass
	,pc.NAME as EncounterClass
	,hs.NAME as EncounterHospitalService
	,ps.NAME as EncounterStatus
	--,enc.APPT_STATUS_C
	,st.NAME as EncounterAppointmentStatus
	,loc.LOC_NAME as EncounterLocation
	,dep.DEPARTMENT_NAME as EncounterDepartment
	,e.CONTACT_DATE as EncounterContactDate
	,e.EXP_ADMISSION_TIME as EncounterScheduledAdmitDatetime
	,enc.APPT_TIME AS EncounterAppointmentDatetime
	,e.HOSP_ADMSN_TIME as EncounterAdmitDatetime
	,e.INP_ADM_DATE as EncounterIPAdmitDatetime
	,e.OP_ADM_DATE as EncounterOPAdmitDatetime
	,e.EMER_ADM_DATE as EncounterEDAdmitDatetime
	,e.HOSP_DISCH_TIME as EncounterDischargeDatetime
	,e.ADMISSION_PROV_ID as EncounterAdmittingProviderID
	,ser1.PROV_NAME as EncounterAdmittingProvider
	,s1.NAME as EncounterAdmittingProviderSpecialty
	,har.ATTENDING_PROV_ID as EncounterAttendingProviderID
	,ser2.PROV_NAME as EncounterAttendingProvider
	,s2.NAME as EncounterAttendingProviderSpecialty
	,e.DISCHARGE_PROV_ID as EncounterDischargeProviderID
	,ser3.PROV_NAME as EncounterDischargeProvider
	,s3.NAME as EncounterDischargeProviderSpecialty
	,e.ED_EPISODE_ID as EncounterEDEpisodeID
	,e.ED_DISPOSITION_C AS EncounterEDDispositionID
	,edd.NAME as EncounterEDDisposition
	,drg.DRG_NUMBER as EncounterDRG
	,drg.DRG_NAME EncounterDRGDescription
	,har.TOT_CHGS AS AccountTotalCharges
	,har.TOT_ADJ as AccountTotalAdjustments
	,har.TOT_PMTS as AccountTotalPayments
	,har.TOT_ACCT_BAL as AccountTotalBalance
	--,har.*
	into #tempEncounters
	from [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].PAT_ENC_HSP e 
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].CLARITY_DEP dep ON e.DEPARTMENT_ID = dep.DEPARTMENT_ID
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].CLARITY_LOC loc ON dep.REV_LOC_ID = loc.LOC_ID
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[ZC_PAT_STATUS] ps ON ps.ADT_PATIENT_STAT_C = e.ADT_PATIENT_STAT_C
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[ZC_PAT_CLASS] pc ON pc.ADT_PAT_CLASS_C = e.ADT_PAT_CLASS_C
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_ED_DISPOSITION edd ON e.ED_DISPOSITION_C = edd.ED_DISPOSITION_C
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_PAT_SERVICE hs ON e.HOSP_SERV_C = hs.HOSP_SERV_C
		inner join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].PAT_ENC enc ON enc.PAT_ENC_CSN_ID = e.PAT_ENC_CSN_ID
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_APPT_STATUS st ON st.APPT_STATUS_C = enc.APPT_STATUS_c
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].HSP_ACCOUNT har ON e.HSP_ACCOUNT_ID = har.HSP_ACCOUNT_ID
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].CLARITY_DRG drg ON har.FINAL_DRG_ID = drg.DRG_ID
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_ACCT_BASECLS_HA bc ON har.ACCT_BASECLS_HA_C = bc.ACCT_BASECLS_HA_C
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_ACCT_CLASS_HA ac ON har.ACCT_CLASS_HA_C = AC.ACCT_CLASS_HA_C
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].CLARITY_SER ser1 ON ser1.PROV_ID = e.ADMISSION_PROV_ID
			left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[CLARITY_SER_SPEC] sp1 on sp1.PROV_ID = ser1.PROV_ID and sp1.line = 1
			left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[ZC_SPECIALTY] s1 on sp1.SPECIALTY_C = s1.SPECIALTY_C
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].CLARITY_SER ser2 ON ser2.PROV_ID = har.ATTENDING_PROV_ID
			left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[CLARITY_SER_SPEC] sp2 on sp2.PROV_ID = ser2.PROV_ID and sp2.line = 1
			left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[ZC_SPECIALTY] s2 on sp2.SPECIALTY_C = s2.SPECIALTY_C
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].CLARITY_SER ser3 ON ser3.PROV_ID = e.DISCHARGE_PROV_ID
			left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[CLARITY_SER_SPEC] sp3 on sp3.PROV_ID = ser3.PROV_ID and sp3.line = 1
			left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[ZC_SPECIALTY] s3 on sp3.SPECIALTY_C = s3.SPECIALTY_C
	where 1=1
		AND e.ADT_SERV_AREA_ID = 430 /*HPI*/

/*Load Temporary Table for Surgical Cases*/
	select 
		orc.OR_CASE_ID  as CaseID
		,enc.PAT_ENC_CSN_ID as CaseEncounterID
		,hsp.HSP_ACCOUNT_ID as CaseVisitID
		,orc.CASE_NAME as CaseName
		,orc.SCHED_STATUS_C as CaseScheduledStatusID
		,sts.NAME as CaseScheduledStatusName
		,orc.SURGERY_DATE as CaseServiceDate
		,orc.TIME_SCHEDULED as CaseScheduledDatetime
		,orc.CASE_BEGIN_INSTANT as CaseBeginDatetime
		,orc.CASE_END_INSTANT as CaseEndDatetime
		,orc.CANCEL_DATE as CaseCancelledDate
		,can.NAME as CaseCancelledReason
		--,cc.NAME as CaseClass
		,orc.LOC_ID as CaseLocationID
		,orc.OR_ID as CaseORID
		,orc.ADD_ON_CASE_YN as CaseIsAddOn
		,orc.SERVICE_C as CaseServiceID
		,svc.NAME as CaseServiceName
		,orc.PAT_CLASS_C as CasePatientClassID
		,pc.NAME as CasePatientClassName
		,orc.PRIMARY_PHYSICIAN_ID as CasePrimaryProviderID
		,prv.PROV_NAME as CasePrimaryProviderName
		--,orc.ADT_CSN
		--,select orc.*
	into #tempCases
	from [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].OR_CASE orc
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].PAT_OR_ADM_LINK orl ON orl.OR_CASELOG_ID = orc.OR_CASE_ID
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].PAT_ENC enc ON enc.PAT_ENC_CSN_ID = orl.OR_LINK_CSN
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].PAT_ENC_HSP hsp ON hsp.PAT_ENC_CSN_ID = enc.PAT_ENC_CSN_ID
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_OR_CANCEL_RSN can ON can.CANCEL_REASON_C = orc.CANCEL_REASON_C 
		--left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_OR_CASE_CLASS cc ON cc.CASE_CLASS_C = orc.CASE_CLASS_C 
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].CLARITY_SER prv ON prv.PROV_ID = orc.PRIMARY_PHYSICIAN_ID
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_PAT_CLASS pc ON pc.ADT_PAT_CLASS_C = orc.PAT_CLASS_C 
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_OR_SERVICE svc ON svc.SERVICE_C = orc.SERVICE_C
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_OR_SCHED_STATUS sts ON sts.SCHED_STATUS_C = orc.SCHED_STATUS_C
	where 1=1 

/*Load Temporary Table for Hospital Accounts/Visits */

SELECT 
	  CONCAT('5~',a.HSP_ACCOUNT_ID) as [VisitID]
      ,5 as [VisitDataSourceID]
      ,a.HSP_ACCOUNT_ID as [VisitSourceID]
      ,a.HSP_ACCOUNT_ID as [VisitReferenceNumber]
      ,CONCAT('5~',a.PAT_ID) as [VisitPatientID]
      ,CONCAT('5~',COALESCE(a.DISCH_LOC_ID, a.ADM_LOC_ID, a.LOC_ID)) as [VisitLocationID]
      ,CASE WHEN COALESCE(a.DISCH_DEPT_ID, a.ADM_DEPARMENT_ID,e2.DEPARTMENT_ID, e1.DEPARTMENT_ID) is not null 
		    THEN CONCAT('5~',COALESCE(a.DISCH_DEPT_ID, a.ADM_DEPARMENT_ID,e2.DEPARTMENT_ID, e1.DEPARTMENT_ID)) END as[VisitDepartmentID]
      ,CASE WHEN e2.ROOM_ID is not null THEN CONCAT('5~',e2.ROOM_ID) END as [VisitRoom]
      ,CASE WHEN edg.DX_ID is not null THEN CONCAT(edg.REF_BILL_CODE,' - ',edg.DX_NAME,' (ICD)') END as [VisitPrimaryDiagnosis]
      ,CASE WHEN icd.ICD_PX_ID is not null THEN CONCAT(icd.PROC_MASTER_NM,' - ',icd.PROCEDURE_NAME,' (ICD)')
			WHEN cpt.CPT_CODE is not null THEN CONCAT(cpt.CPT_CODE,' - ',cpt.CPT_CODE_DESC,' (CPT)') END as [VisitPrimaryProcedureCode]
      ,CASE WHEN a.PRIMARY_PAYOR_ID is null THEN NULL ELSE CONCAT('5~',a.PRIMARY_PAYOR_ID) END as [VisitPrimaryPayerID]
	  ,CASE WHEN a.PRIMARY_PLAN_ID is null THEN NULL ELSE CONCAT('5~',a.PRIMARY_PLAN_ID) END AS VisitPrimaryPayerPlanID
      ,CASE WHEN COALESCE(a.ATTENDING_PROV_ID,e2.ADMISSION_PROV_ID,e1.VISIT_PROV_ID) is null THEN NULL ELSE CONCAT('5~',COALESCE(a.ATTENDING_PROV_ID,e2.ADMISSION_PROV_ID,e1.VISIT_PROV_ID)) END as [VisitPrimaryProviderID]
      ,CASE WHEN COALESCE(a.ATTENDING_PROV_ID,e2.ADMISSION_PROV_ID,e1.VISIT_PROV_ID) is null THEN NULL ELSE CONCAT('5~',COALESCE(a.ATTENDING_PROV_ID,e2.ADMISSION_PROV_ID,e1.VISIT_PROV_ID)) END as [VisitAdmittingProviderID]
      ,CASE WHEN a.ATTENDING_PROV_ID is null THEN NULL ELSE CONCAT('5~',a.ATTENDING_PROV_ID) END as [VisitAttendingProviderID]
      ,CASE WHEN a.REFERRING_PROV_ID is null THEN NULL ELSE CONCAT('5~',a.REFERRING_PROV_ID) END as [VisitReferringProviderID]
      ,CONVERT(date,COALESCE(a.ADM_DATE_TIME, e1.EFFECTIVE_DATE_DT)) as [VisitDateOfService]
      ,COALESCE(e1.APPT_MADE_DATE, e1.ENTRY_TIME) as [VisitDateOfScheduling]
      ,e1.CHECKIN_TIME as [VisitDateOfRegistration]
      ,COALESCE(a.ADM_DATE_TIME, e1.APPT_TIME, e2.HOSP_ADMSN_TIME) as [VisitDateOfAdmission]
      ,a.DISCH_DATE_TIME as [VisitDateOfDischarge]
	  ,a.ACCT_BILLED_DATE as VisitDateOfBilling
	  ,a.ACCT_CLOSE_DATE as VisitDateOfClosing
      ,e1.APPT_CANCEL_DATE as [VisitDateOfCancellation]
	  ,a.ACCT_ZERO_BAL_DT as VisitDateOfZeroBalance
	  ,NULL AS VisitDateOfBadDebtWriteOff
      ,cr.NAME as [VisitCancelledReason]
      ,COALESCE(ps.Name,st.NAME) as [VisitStatus]  --a3.BAD_DEBT_FLAG_YN
      ,bc.NAME as [VisitClass]
      ,ac.NAME as [VisitType]
      ,NULL AS [VisitReason]
      ,bs.NAME as [VisitBillingStatus]
	  ,bs.NAME as VisitBillingFlag
	  ,a.TOT_CHGS as VisitTotalCharges
	  ,a.TOT_ADJ as VisitTotalAdjustments
	  ,a.TOT_PMTS as VisitTotalPayments
	  ,NULL as VisitTotalRefunds
	  ,A.TOT_ACCT_BAL as VisitTotalBalance
      ,src.NAME as [VisitAdmittedFrom]
      ,dd.NAME as [VisitDischargedTo]
      ,drg.DRG_NUMBER as [VisitDRG]
	  ,drg.DRG_NAME as VisitDRGDescription
	  ,drgt.NAME as VisitDRGType
	  ,drg.DRG_MDC_C as VisitDRGMDC
      ,CASE WHEN a.IS_ACTIVE_YN = 'Y' THEN 1 ELSE 0 END as [VisitIsActive] /*Closed Hospital Accounts are considered inactive by this logic*/
      ,GETDATE() AS [VisitUpdatedDatetime]
	  --,a.PRIM_ENC_CSN_ID
	  --SELECT * 
  INTO #tempVisits
  FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].HSP_ACCOUNT a
	left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].HSP_ACCOUNT_3 a3 ON a3.HSP_ACCOUNT_ID = a.HSP_ACCOUNT_ID	
	left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_ACCT_BILLSTS_HA bs ON bs.ACCT_BILLSTS_HA_C = a.ACCT_BILLSTS_HA_C	
	left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_ACCT_CLASS_HA ac ON ac.ACCT_CLASS_HA_C = a.ACCT_CLASS_HA_C
	left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_ACCT_BASECLS_HA bc ON bc.ACCT_BASECLS_HA_C = a.ACCT_BASECLS_HA_C
	left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_ADM_SOURCE src ON src.ADMIT_SOURCE_C = a.ADMISSION_SOURCE_C
	left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].PAT_ENC e1 ON e1.PAT_ENC_CSN_ID = a.PRIM_ENC_CSN_ID
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_APPT_STATUS st ON st.APPT_STATUS_C = e1.APPT_STATUS_C
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_CANCEL_REASON cr ON cr.CANCEL_REASON_C = e1.CANCEL_REASON_C
		--left join [CLARITY].[ORGFILTER].[ZC_DISP_ENC_TYPE] et ON et.DISP_ENC_TYPE_C = e1.ENC_TYPE_C
	left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].PAT_ENC_HSP e2 ON e2.PAT_ENC_CSN_ID = a.PRIM_ENC_CSN_ID
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[ZC_PAT_STATUS] ps ON ps.ADT_PATIENT_STAT_C = e2.ADT_PATIENT_STAT_C
	left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_DISCH_DESTIN_HA dd ON dd.DISCH_DESTIN_HA_C = a.DISCH_DESTIN_HA_C
	left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].CLARITY_DRG drg ON a.FINAL_DRG_ID = drg.DRG_ID
	left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[ZC_DRG_CASE_TYPE] drgt ON drgt.DRG_CASE_TYPE_C = drg.DRG_CASE_TYPE_C
	left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].HSP_ACCT_SBO sbo ON sbo.HSP_ACCOUNT_ID = a.HSP_ACCOUNT_ID
	left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].HSP_ACCT_CPT_CODES cpt ON cpt.HSP_ACCOUNT_ID = a.HSP_ACCOUNT_ID and cpt.LINE = 1
	left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].HSP_ACCT_PX_LIST px ON px.HSP_ACCOUNT_ID = a.HSP_ACCOUNT_ID and px.LINE = 1
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].CL_ICD_PX icd ON icd.ICD_PX_ID = px.FINAL_ICD_PX_ID 
	left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].HSP_ACCT_DX_LIST dx ON dx.HSP_ACCOUNT_ID = a.HSP_ACCOUNT_ID and dx.LINE = 1
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[CLARITY_EDG] edg ON edg.DX_ID = dx.DX_ID
  where 1=1 


/*DELETE AND LOAD INTO fact.Visits*/
  DELETE FROM fact.Visits WHERE VisitDataSourceID = 5

  INSERT INTO fact.Visits
  ([VisitID]
      ,[VisitDataSourceID]
      ,[VisitSourceID]
      ,[VisitReferenceNumber]
      ,[VisitPatientID]
      ,[VisitLocationID]
      ,[VisitDepartmentID]
      ,[VisitRoom]
      ,[VisitPrimaryDiagnosis]
      ,[VisitPrimaryProcedureCode]
      ,[VisitPrimaryPayerID]
      ,[VisitPrimaryPayerPlanID]
      ,[VisitPrimaryProviderID]
      ,[VisitAdmittingProviderID]
      ,[VisitAttendingProviderID]
      ,[VisitReferringProviderID]
      ,[VisitDateOfService]
      ,[VisitDateOfScheduling]
      ,[VisitDateOfRegistration]
      ,[VisitDateOfAdmission]
      ,[VisitDateOfDischarge]
      ,[VisitDateOfBilling]
      ,[VisitDateOfClosing]
      ,[VisitDateOfCancellation]
      ,[VisitDateOfZeroBalance]
      ,[VisitDateOfBadDebtWriteOff]
      ,[VisitCancelledReason]
      ,[VisitStatus]
      ,[VisitClass]
      ,[VisitType]
      ,[VisitReason]
      ,[VisitBillingStatus]
      ,[VisitBillingFlag]
      ,[VisitTotalCharges]
      ,[VisitTotalAdjustments]
      ,[VisitTotalPayments]
      ,[VisitTotalRefunds]
      ,[VisitTotalBalance]
      ,[VisitAdmittedFrom]
      ,[VisitDischargedTo]
      ,[VisitDRG]
      ,[VisitDRGDescription]
      ,[VisitDRGType]
      ,[VisitDRGMDC]
	  ,VisitIsSurgical
      ,[VisitIsActive]
      ,[VisitUpdatedDatetime]
	  )

  /*Hospital Encounters without a hospital account assigned (ex. Scheduled or Cancelled*/
  SELECT
	CONCAT('5~NoAccount~',e.EncounterID) as [VisitID]
      ,5 as [VisitDataSourceID]
      ,CONCAT('NoAccount~',e.EncounterID) AS [VisitSourceID]
      ,e.EncounterID AS [VisitReferenceNumber]
      ,CASE WHEN e.EncounterPatientID IS NOT NULL THEN CONCAT('5~',e.EncounterPatientID) END [VisitPatientID]
      ,e.EncounterLocation as [VisitLocationID]
      ,e.EncounterDepartment as [VisitDepartmentID]
      ,null as [VisitRoom]
      ,null as [VisitPrimaryDiagnosis]
      ,null as [VisitPrimaryProcedureCode]
      ,null as [VisitPrimaryPayerID]
      ,null as [VisitPrimaryPayerPlanID]
      ,CASE WHEN COALESCE(c.CasePrimaryProviderID,e.EncounterDischargeProviderID,e.EncounterAttendingProviderID,e.EncounterAdmittingProviderID) is not null THEN 
		CONCAT('5~',COALESCE(c.CasePrimaryProviderID,e.EncounterDischargeProviderID,e.EncounterAttendingProviderID,e.EncounterAdmittingProviderID)) END AS [VisitPrimaryProviderID]
      ,CASE WHEN e.EncounterAdmittingProviderID is not null THEN CONCAT('5~',e.EncounterAdmittingProviderID) END as [VisitAdmittingProviderID]
      ,CASE WHEN e.EncounterAttendingProviderID is not null THEN CONCAT('5~',e.EncounterAttendingProviderID) END as [VisitAttendingProviderID]
      ,NULL AS [VisitReferringProviderID]
      ,CONVERT(date,COALESCE(e.EncounterAdmitDatetime,e.EncounterScheduledAdmitDatetime)) AS [VisitDateOfService]
      ,e.EncounterContactDate as [VisitDateOfScheduling]
      ,e.EncounterAdmitDatetime as [VisitDateOfRegistration]
      ,e.EncounterAdmitDatetime as [VisitDateOfAdmission]
      ,e.EncounterDischargeDatetime as [VisitDateOfDischarge]
      ,NULL AS [VisitDateOfBilling]
      ,NULL AS [VisitDateOfClosing]
      ,NULL AS [VisitDateOfCancellation]
      ,NULL AS [VisitDateOfZeroBalance]
      ,NULL AS [VisitDateOfBadDebtWriteOff]
      ,NULL AS [VisitCancelledReason]
      --,COALESCE(e.EncounterAppointmentStatus,e.EncounterStatus) as [VisitStatus]
      ,CASE WHEN e.EncounterDischargeDatetime is not null THEN 'Completed'
			WHEN COALESCE(e.EncounterAppointmentStatus,e.EncounterStatus) in ('Completed','Discharged') THEN 'Completed'
			WHEN COALESCE(e.EncounterAppointmentStatus,e.EncounterStatus) in ('Arrived','Admission') THEN 'Arrived'
			WHEN COALESCE(e.EncounterAppointmentStatus,e.EncounterStatus) in ('Scheduled','Preadmission') THEN 'Scheduled'
			WHEN COALESCE(e.EncounterAppointmentStatus,e.EncounterStatus) in ('No Show') THEN 'No Show'
			WHEN COALESCE(e.EncounterAppointmentStatus,e.EncounterStatus) in ('Canceled','Cancelled') THEN 'Canceled'
			WHEN e.EncounterAdmitDatetime is not null THEN 'Arrived'
		    --WHEN v.VisitTotalCharges > 0 THEN 'Arrived'
			--WHEN v.VisitDateOfClosing <= GETDATE() THEN 'Completed'
			--WHEN v.VisitDateOfBilling <= GETDATE() THEN 'Completed'
			ELSE COALESCE(e.EncounterAppointmentStatus,e.EncounterStatus) END [VisitStatus]
      ,e.EncounterClass as [VisitClass]
      ,CASE WHEN e.EncounterDepartment like '%PAIN%' THEN 'Pain'
			WHEN c.Cases > 0 THEN CASE WHEN e.EncounterDepartment like '%PAIN%' THEN 'Pain'
									   ELSE e.EncounterClass END
			WHEN e.EncounterDepartment IN ('HPI CHN CT'
										   ,'HPI CHS CT'
										   ,'HPI NWSH CT') THEN 'CT'
			WHEN e.EncounterDepartment IN ('HPI CHN ULTRASOUND'
										   ,'HPI CHS ULTRASOUND'
										   ,'HPI NWSH ULTRASOUND') THEN 'US'
			WHEN e.EncounterDepartment IN ('HPI CHN MRI'
										   ,'HPI CHS MRI'
										   ,'HPI NWSH MRI') THEN 'MRI'
			WHEN e.EncounterDepartment IN ('HPI CHN RADIOLOGY'
										   ,'HPI CHS RADIOLOGY'
										   ,'HPI NWSH RADIOLOGY') THEN 'Radiology'
			WHEN e.EncounterDepartment like '%lABORATORY%' THEN 'Lab'
			WHEN e.EncounterDepartment like '%PREADM%' THEN 'Pre-Admission Testing'
			ELSE e.EncounterClass END as [VisitType]
      ,null as [VisitReason]
      ,null as [VisitBillingStatus]
      ,null as [VisitBillingFlag]
      ,0 as [VisitTotalCharges]
      ,0 as [VisitTotalAdjustments]
      ,0 as [VisitTotalPayments]
      ,0 as [VisitTotalRefunds]
      ,0 as [VisitTotalBalance]
      ,null as [VisitAdmittedFrom]
      ,null as [VisitDischargedTo]
      ,null as [VisitDRG]
      ,null as [VisitDRGDescription]
      ,null as [VisitDRGType]
      ,null as [VisitDRGMDC]
	  ,CASE WHEN C.Cases > 0 THEN 1 ELSE 0 END as VisitIsSurgical
      ,1 AS [VisitIsActive]
      ,GETDATE() AS [VisitUpdatedDatetime]
	FROM #tempEncounters e --[NXDC1DBSQ016.CORP.INTEGRIS-HEALTH.COM].[Revenue].dbo.FactHospitalEncounters e
			left join (select 
				c.CaseEncounterID
				,c.CaseVisitID
				,count(c.CaseID) as Cases
				,count(CASE WHEN c.CaseScheduledStatusID = 1 THEN c.CaseID END) as CasesScheduled
				,count(CASE WHEN c.CaseScheduledStatusID = 2 THEN c.CaseID END) as CasesCancelled
				,count(CASE WHEN c.CaseScheduledStatusID = 3 THEN c.CaseID END) as CasesNotScheduled
				,count(CASE WHEN c.CaseScheduledStatusID = 8 THEN c.CaseID END) as CasesCompleted
				,max(c.CasePrimaryProviderID) as CasePrimaryProviderID
			  from #tempCases c --[NXDC1DBSQ016.CORP.INTEGRIS-HEALTH.COM].[Revenue].dbo.FactCases c 
			  GROUP BY c.CaseEncounterID,c.CaseVisitID ) c ON c.CaseEncounterID = e.EncounterID
	WHERE 1=1
		AND e.EncounterAccountID is null

	union all

	select [VisitID]
      ,[VisitDataSourceID]
      ,convert(varchar,[VisitSourceID]) as VisitSourceID
      ,[VisitReferenceNumber]
      ,[VisitPatientID]
      ,[VisitLocationID]
      ,[VisitDepartmentID]
      ,[VisitRoom]
      ,[VisitPrimaryDiagnosis]
      ,[VisitPrimaryProcedureCode]
      ,[VisitPrimaryPayerID]
      ,[VisitPrimaryPayerPlanID]
      ,COALESCE(c.CasePrimaryProviderID,v.VisitPrimaryProviderID) as [VisitPrimaryProviderID]
      ,[VisitAdmittingProviderID]
      ,[VisitAttendingProviderID]
      ,[VisitReferringProviderID]
      ,[VisitDateOfService]
      ,[VisitDateOfScheduling]
      ,[VisitDateOfRegistration]
      ,[VisitDateOfAdmission]
      ,[VisitDateOfDischarge]
      ,[VisitDateOfBilling]
      ,[VisitDateOfClosing]
      ,[VisitDateOfCancellation]
      ,[VisitDateOfZeroBalance]
      ,[VisitDateOfBadDebtWriteOff]
      ,[VisitCancelledReason]
      ,CASE WHEN v.VisitDateOfDischarge is not null THEN 'Completed'
			WHEN v.VisitStatus in ('Completed','Discharged') THEN 'Completed'
			WHEN v.VisitStatus in ('Arrived','Admission') THEN 'Arrived'
			WHEN v.VisitStatus in ('Scheduled','Preadmission') THEN 'Scheduled'
			WHEN v.VisitStatus in ('No Show') THEN 'No Show'
			WHEN v.VisitStatus in ('Canceled','Cancelled') THEN 'Canceled'
			WHEN v.VisitDateOfAdmission is not null THEN 'Arrived'
		    WHEN v.VisitTotalCharges > 0 THEN 'Arrived'
			WHEN v.VisitDateOfClosing <= GETDATE() THEN 'Completed'
			WHEN v.VisitDateOfBilling <= GETDATE() THEN 'Completed'
			ELSE v.VisitStatus END [VisitStatus]
      ,[VisitClass]
      ,CASE WHEN d.DepartmentName like '%PAIN%' THEN 'Pain'
			WHEN c.Cases > 0 THEN CASE WHEN d.DepartmentName like '%PAIN%' THEN 'Pain'
									   ELSE v.VisitType END
			WHEN d.DepartmentName IN ('HPI CHN CT'
										   ,'HPI CHS CT'
										   ,'HPI NWSH CT') THEN 'CT'
			WHEN d.DepartmentName IN ('HPI CHN ULTRASOUND'
										   ,'HPI CHS ULTRASOUND'
										   ,'HPI NWSH ULTRASOUND') THEN 'US'
			WHEN d.DepartmentName IN ('HPI CHN MRI'
										   ,'HPI CHS MRI'
										   ,'HPI NWSH MRI') THEN 'MRI'
			WHEN d.DepartmentName IN ('HPI CHN RADIOLOGY'
										   ,'HPI CHS RADIOLOGY'
										   ,'HPI NWSH RADIOLOGY') THEN 'Radiology'
			WHEN d.DepartmentName like '%lABORATORY%' THEN 'Lab'
			WHEN d.DepartmentName like '%PREADM%' THEN 'Pre-Admission Testing'
			ELSE v.VisitType END [VisitType]
      ,[VisitReason]
      ,[VisitBillingStatus]
      ,[VisitBillingFlag]
      ,[VisitTotalCharges]
      ,[VisitTotalAdjustments]
      ,[VisitTotalPayments]
      ,[VisitTotalRefunds]
      ,[VisitTotalBalance]
      ,[VisitAdmittedFrom]
      ,[VisitDischargedTo]
      ,[VisitDRG]
      ,[VisitDRGDescription]
      ,[VisitDRGType]
      ,[VisitDRGMDC]
	  ,CASE WHEN C.Cases > 0 THEN 1 ELSE 0 END as VisitIsSurgical
      ,[VisitIsActive]
      ,[VisitUpdatedDatetime] 
	--SELECT distinct VisitStatus
	from #tempVisits v --[NXDC1DBSQ016.CORP.INTEGRIS-HEALTH.COM].[Revenue].dbo.FactVisits v
		left join dim.Departments d ON d.DepartmentID = v.VisitDepartmentID
		left join (select 
				--c.CaseEncounterID
				CONCAT('5~',c.CaseVisitID) as CaseVisitID
				,count(c.CaseID) as Cases
				,count(CASE WHEN c.CaseScheduledStatusID = 1 THEN c.CaseID END) as CasesScheduled
				,count(CASE WHEN c.CaseScheduledStatusID = 2 THEN c.CaseID END) as CasesCancelled
				,count(CASE WHEN c.CaseScheduledStatusID = 3 THEN c.CaseID END) as CasesNotScheduled
				,count(CASE WHEN c.CaseScheduledStatusID = 8 THEN c.CaseID END) as CasesCompleted
				,CASE WHEN max(c.CasePrimaryProviderID) IS NOT NULL THEN CONCAT('5~',max(c.CasePrimaryProviderID)) END as CasePrimaryProviderID
			  from #tempCases c --[NXDC1DBSQ016.CORP.INTEGRIS-HEALTH.COM].[Revenue].dbo.FactCases c 
			  GROUP BY c.CaseVisitID ) c ON c.CaseVisitID = v.VisitID

	DROP TABLE #tempEncounters
	DROP TABLE #tempCases
	DROP TABLE #tempVisits
GO
