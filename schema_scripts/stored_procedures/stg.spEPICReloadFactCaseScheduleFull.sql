-- =============================================
-- Author:		Eric Silvestri
-- Create date: 08/26/2024
-- Description:	Extracts, reloads the case status schedule from EPIC
-- Change Control

-- =============================================
	
	CREATE procedure [stg].[spEPICReloadFactCaseScheduleFull] as

	delete from fact.CaseSchedule where CaseScheduleDataSourceID = 5

	insert into fact.CaseSchedule
(
CaseScheduleID
,CaseScheduleDataSourceID
,CaseScheduleAction
,CaseScheduleStatus
,CaseScheduleVisitVolume
,CaseScheduleCancellationAgeCategory
,CaseScheduleDaysFromCancellation
,CaseScheduleDateOfAction
,CaseScheduleDateOfReschedule
,CaseScheduleDateofCase
,CaseScheduleCancellationReason
,CaseScheduleDateOfCancellation
,CaseScheduleCencellationComments
,CaseScheduleRescheduleComments
,CaseScheduleNotPerformedReason
,CaseScheduleNotPerformedComments
,CaseScheduleProviderID
,CaseScheduleProviderName
,CaseScheduleAnesthesiaProviderID
,CaseScheduleAnesthesiaProviderName
,CaseScheduleServiceLine
,CaseSchedueVisitType
,CaseScheduleVisitClass
,CaseSchedulePrimaryProcedure
,CaseScheduleLocationID
)

SELECT
	sub.CaseScheduleID
	,sub.CaseScheduleDataSourceID
	,sub.CaseScheduleAction
	,sub.CaseScheduleStatus
	,sub.CaseScheduleVisitVolume
	,CASE WHEN sub.CaseScheduleStatus = 'Canceled' 
	         AND CONVERT(DATE, sub.CaseScheduleDateofCase) = CONVERT(DATE, sub.CaseScheduleDateOfCancellation)
	         THEN 'Same Day Cancellation'
		WHEN sub.CaseScheduleStatus = 'Canceled' 
	         AND DATEDIFF(DAY,sub.CaseScheduleDateOfCancellation, sub.CaseScheduleDateofCase) < 0
			 THEN 'Canceled After Case Date'
	    WHEN sub.CaseScheduleStatus = 'Canceled' 
	         AND DATEDIFF(DAY,sub.CaseScheduleDateOfCancellation, sub.CaseScheduleDateofCase) <= 30
	         THEN '1-30 Days from Case'
	    WHEN sub.CaseScheduleStatus = 'Canceled' 
	         AND DATEDIFF(DAY,sub.CaseScheduleDateOfCancellation, sub.CaseScheduleDateofCase) <= 60
	         THEN '31-60 Days from Case'
	    WHEN sub.CaseScheduleStatus = 'Canceled' 
	         AND DATEDIFF(DAY,sub.CaseScheduleDateOfCancellation, sub.CaseScheduleDateofCase) <= 90
	         THEN '61-90 Days from Case'
	    WHEN sub.CaseScheduleStatus = 'Canceled' 
	         AND CONVERT(DATE, sub.CaseScheduleDateofCase) > GETDATE()
	         THEN 'Future Case Cancelled'
		END as CaseScheduleCancellationAgeCategory
	,DATEDIFF(DAY,sub.CaseScheduleDateOfCancellation, sub.CaseScheduleDateofCase) as CaseScheduleDaysFromCancellation
	,sub.CaseScheduleDateOfAction
	,sub.CaseScheduleDateOfReschedule
	,sub.CaseScheduleDateofCase
	,sub.CaseScheduleCancellationReason
	,sub.CaseScheduleDateOfCancellation
	,sub.CaseScheduleCencellationComments
	,sub.CaseScheduleRescheduleComments
	,sub.CaseScheduleNotPerformedReason
	,sub.CaseScheduleNotPerformedComments
	,sub.CaseScheduleProviderID
	,sub.CaseScheduleAnesthesiaProviderID
	,sub.CaseScheduleProviderName
	,sub.CaseScheduleAnesthesiaProviderName
	,sub.CaseScheduleServiceLine
	,sub.CaseSchedueVisitType
	,sub.CaseScheduleVisitClass
	,sub.CaseSchedulePrimaryProcedure
	,sub.CaseScheduleLocationID
FROM
(
SELECT
	concat('5~', csc.CASE_ID) CaseScheduleID
	,5 as CaseScheduleDataSourceID
	,csc.ACTION_NM as CaseScheduleAction
	,CASE WHEN csc.GENERAL_ACTION_NM = 'Procedure not Performed' and vc.VisitCaseCancelledDate is not null 
			THEN 'Canceled'
		WHEN csc.GENERAL_ACTION_NM = 'Rescheduled' and csc.RESCHED_TO_DATE is null and vc.VisitCaseCancelledDate is not null
			THEN 'Canceled'
		WHEN  csc.GENERAL_ACTION_NM = 'Scheduled' and vc.VisitCaseScheduleStatus = 'Completed'
			THEN 'Performed'
		ELSE csc.GENERAL_ACTION_NM END as CaseScheduleStatus
	--,csc.GENERAL_ACTION_NM as CaseScheduleStatus
	,CASE WHEN csc.GENERAL_ACTION_NM = 'Rescheduled' and vc.VisitCaseScheduleStatus = 'Completed'
		THEN 0 ELSE 1 END as CaseScheduleVisitVolume  --Case Count
	,csc.ACTION_DTTM as CaseScheduleDateOfAction
	,csc.RESCHED_TO_DATE as CaseScheduleDateOfReschedule
	,csc.CASE_DTTM as CaseScheduleDateofCase
	,csc.CANCELLATION_REASON_NM as CaseScheduleCancellationReason
	,CONVERT(DATE, vc.VisitCaseCancelledDate, 101) as CaseScheduleDateOfCancellation
	,csc.CANCELLATION_COMMENTS as CaseScheduleCencellationComments
	,csc.CANCEL_RESCHED_ACTION_RSN_CMTS  as CaseScheduleRescheduleComments
	,csc.PROC_NOT_PERFORM_PHASE_NM as CaseScheduleNotPerformedReason
	,csc.PROC_NOT_PERFORM_COMMENTS as CaseScheduleNotPerformedComments
	,CONCAT('5~',csc.PRIMARY_PHYSICIAN_ID) as CaseScheduleProviderID
	,csc.PRIMARY_PHYSICIAN_NM as CaseScheduleProviderName
	,CASE WHEN lb.RESP_ANES_ID IS NULL THEN NULL ELSE CONCAT('5~',lb.RESP_ANES_ID) END as CaseScheduleAnesthesiaProviderID
	,CASE WHEN lb.RESP_ANES_ID IS NULL THEN NULL ELSE p.ProviderFullName END as CaseScheduleAnesthesiaProviderName
	,csc.SERVICE_NM as CaseScheduleServiceLine
	,csc.PATIENT_CLASS_NM as CaseSchedueVisitType
	,csc.PATIENT_CLASS_GROUP as CaseScheduleVisitClass
	,csc.PRIMARY_PROCEDURE_NM as CaseSchedulePrimaryProcedure
	,CONCAT('5~',csc.LOCATION_ID)  as CaseScheduleLocationID
FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].V_CASE_SCHEDULE_CHANGE csc
	LEFT JOIN [HPIDW].[fact].[vVisitCases] vc on vc.VisitCaseID = CONCAT('5~',csc.CASE_ID)
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].F_LOG_BASED lb ON lb.LOG_ID = csc.LOG_ID
	LEFT JOIN [HPIDW].[dim].[vProviders] p on p.ProviderID = CONCAT('5~',lb.RESP_ANES_ID)
WHERE csc.LOCATION_NM like ('%HPI%')
) sub


/*
 SELECT top 100 * from  [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].F_LOG_BASED
	where LOG_ID = 2266605

SELECT top 100 * FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].V_CASE_SCHEDULE_CHANGE 

SELECT top 100 * from [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].OR_CASE

 SELECT top 100 * from [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].or_log



 SELECT top 100 * FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].V_CASE_SCHEDULE_CHANGE
 5~2140973

 
 SELECT top 100 * FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_OR_ANESTH_TYPE

 */
GO
