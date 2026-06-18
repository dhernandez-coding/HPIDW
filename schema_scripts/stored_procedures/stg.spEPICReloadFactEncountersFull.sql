-- =============================================
-- Author:		Jacob Roan
-- Create date: 03/15/2023
-- Description:	Extracts, Transforms and Loads encounter Data from pims/medhost Source System into a dim Table
-- Change Control
--	1. 03/15/2023 - Jacob Roan - Initial build of procedure
-- =============================================
CREATE PROCEDURE [stg].[spEPICReloadFactEncountersFull]
AS
BEGIN
SET NOCOUNT ON;

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

/*DELETE AND LOAD INTO fact.Encounters*/
DELETE FROM fact.Encounters WHERE EncounterDataSourceID = 5

insert into fact.Encounters
([EncounterID]
      ,[EncounterDataSourceID]
      ,[EncounterSourceID]
      ,[ParentEncounterID]
      ,[EncounterVisitID]
      ,[EncounterPatientID]
      ,[EncounterLocationID]
      ,[EncounterDepartmentID]
      ,[EncounterRoom]
      ,[EncounterPrimaryProviderID]
      ,[EncounterAdmittingProviderID]
      ,[EncounterAttendingProviderID]
      ,[EncounterReferringProviderID]
      ,[EncounterDateOfService]
      ,[EncounterDateOfScheduling]
      ,[EncounterDateOfRegistration]
      ,[EncounterBeginDatetime]
      ,[EncounterEndDatetime]
      ,[EncounterDateOfCancellation]
      ,[EncounterCancelledReason]
      ,[EncounterStatus]
      ,[EncounterClass]
      ,[EncounterType]
      ,[EncounterReason]
	  ,[EncounterIsSurgical]
      ,[EncounterIsActive]
      ,[EncounterUpdatedDatetime]
)

SELECT 
	CONCAT('5~',e.EncounterID) as [EncounterID]
      ,'5' as [EncounterDataSourceID]
      ,e.EncounterID as [EncounterSourceID]
	  ,CONCAT('5~',COALESCE(e.AccountPrimaryEncounterID,e.EncounterID)) as ParentEncounterID
      ,CASE WHEN e.EncounterAccountID is not null THEN CONCAT('5~',e.EncounterAccountID) ELSE CONCAT('5~NoAccount~',e.EncounterID) END as [EncounterVisitID]
      ,CASE WHEN e.EncounterPatientID is not null THEN CONCAT('5~',e.EncounterPatientID) END as [EncounterPatientID]
      ,e.EncounterLocation as [EncounterLocationID]
      ,e.EncounterDepartment as [EncounterDepartmentID]
      ,NULL as [EncounterRoom]
      ,CASE WHEN COALESCE(c.CasePrimaryProviderID,e.EncounterDischargeProviderID,e.EncounterAttendingProviderID,e.EncounterAdmittingProviderID) is not null THEN 
		CONCAT('5~',COALESCE(c.CasePrimaryProviderID,e.EncounterDischargeProviderID,e.EncounterAttendingProviderID,e.EncounterAdmittingProviderID))  END as [EncounterPrimaryProviderID]
      ,CASE WHEN e.EncounterAdmittingProviderID is not null THEN CONCAT('5~',e.EncounterAdmittingProviderID) END as [EncounterAdmittingProviderID]
      ,CASE WHEN e.EncounterAttendingProviderID is not null THEN CONCAT('5~',e.EncounterAttendingProviderID) END as [EncounterAttendingProviderID]
      ,NULL as [EncounterReferringProviderID]
      ,CONVERT(date,COALESCE(e.EncounterAdmitDatetime,e.EncounterScheduledAdmitDatetime)) as [EncounterDateOfService]
      ,e.EncounterContactDate as [EncounterDateOfScheduling]
      ,e.EncounterAdmitDatetime as [EncounterDateOfRegistration]
      ,e.EncounterAdmitDatetime as [EncounterBeginDatetime]
      ,e.EncounterDischargeDatetime as [EncounterEndDatetime]
      ,NULL as [EncounterDateOfCancellation]
      ,NULL as [EncounterCancelledReason]
      ,COALESCE(e.EncounterAppointmentStatus,e.EncounterStatus) as [EncounterStatus]
      ,e.EncounterClass as [EncounterClass]
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
			ELSE e.EncounterClass END as [EncounterType]
      ,NULL as [EncounterReason]
	  ,case when c.cases > 0 then 1 else 0 end as [EncounterIsSurgical] -- change to when total case count - cancel case count
      ,1 as [EncounterIsActive]
      ,GETDATE() as [EncounterUpdatedDatetime]
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
			  from #tempCases c -- [NXDC1DBSQ016.CORP.INTEGRIS-HEALTH.COM].[Revenue].dbo.FactCases c 
			  GROUP BY c.CaseEncounterID,c.CaseVisitID ) c ON c.CaseEncounterID = e.EncounterID
			-- where e.encounterid = 606108517

	DROP TABLE #tempEncounters
	DROP TABLE #tempCases


END
GO
