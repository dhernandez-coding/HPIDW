CREATE PROCEDURE [stg].[spEPICReloadFactVisitStatsPBFull]	AS
BEGIN		
	-- ========================================================================
	-- Author:		Eric Silvestri
	-- Create date: 11-12-2024
	-- Description:	Loads PB VisitStats records from EPIC into fact.VisitStatsPB.
	-- Change Control
		-- 1. 1/8/26 - Diego Hernandez - Modify to OpenQuery
	-- ========================================================================

-- Step 1: Delete existing records for the data source
DELETE FROM fact.VisitStatsPB
WHERE VisitStatsDataSourceID = 5;


-- Step 2: Insert into fact.VisitStatsPB
INSERT INTO fact.VisitStatsPB
(
    [VisitStatsID],
    [VisitStatsDataSourceID],
    [VisitStatsProviderID],
    [VisitStatsDepartmentID],
    [VisitStatsDate],
    [VisitStatsAvailableHours],
    [VisitStatsBookedHours],
    [VisitStatsAvailableOpeningsOnDay],
    [VisitStatsRegularOpeningsOnDay],
    [VisitStatsSameDayRegularBooked],
    [VisitStatsRegularBooked],
    [VisitStatsOverbookOpenings],
    [VisitStatsSameDayOverbooked],
    [VisitStatsOverbooked],
    [VisitStatsArrivedCount],
    [VisitStatsNoShowCount],
    [VisitStatsLeftWithoutBeingSeenCount],
    [VisitStatsCompletedCount],
    [VisitStatsScheduledCount],
    [VisitStatsCanceledCount],
    [VisitStatsPatientCanceledCount],
    [VisitStatsSameDayCanceledCount],
    [VisitStatsLateCanceledCount],
    [VisitStatsLateProviderCanceledCount],
    [VisitStatsRescheduledCount],
    [VisitStatsSameDayBooked],
    [VisitStatsForTodayLeadDays],
    [VisitStatsForTodayCount],
    [VisitStatsMadeTodayLeadDays],
    [VisitStatsMadeTodayCount],
    [VisitStatsRegularAvailableHours],
    [VisitStatsOverbookAvailableHours],
    [VisitStatsUnavailableOpeningsUsed],
    [VisitStatsHeldOpeningsUsed],
    [VisitStatsUpdateDate]
)

SELECT
    CONCAT('5~',src.PROV_ID,'~',src.DEPARTMENT_ID,'~',FORMAT(src.STATISTICS_DATE,'yyyy-MM-dd')) AS VisitStatsID,
    5 AS VisitStatsDataSourceID,
    CONCAT('5~',src.PROV_ID) AS VisitStatsProviderID,
    CONCAT('5~',src.DEPARTMENT_ID) AS VisitStatsDepartmentID,
    src.STATISTICS_DATE AS VisitStatsDate,
    src.SCHEDULABLE_HRS AS VisitStatsAvailableHours,
    src.BOOKED_HRS AS VisitStatsBookedHours,
    src.AVAIL_OPENINGS_ON_DAY_CNT AS VisitStatsAvailableOpeningsOnDay,
    src.REG_OPENINGS_CNT AS VisitStatsRegularOpeningsOnDay,
    src.SAME_DAY_REG_OPENINGS_USED_CNT AS VisitStatsSameDayRegularBooked,
    src.PREVIOUS_REG_OPENINGS_USED_CNT AS VisitStatsRegularBooked,
    src.OVERBOOK_OPENINGS_CNT AS VisitStatsOverbookOpenings,
    src.SAME_DAY_OVRBK_OPENGS_USED_CNT AS VisitStatsSameDayOverbooked,
    src.PREVIOUS_OVRBK_OPENGS_USED_CNT AS VisitStatsOverbooked,
    src.ARRIVED_CNT AS VisitStatsArrivedCount,
    src.NO_SHOW_CNT AS VisitStatsNoShowCount,
    src.LEFT_WO_SEEN_CNT AS VisitStatsLeftWithoutBeingSeenCount,
    src.COMPLETED_CNT AS VisitStatsCompletedCount,
    src.SCHEDULED_CNT AS VisitStatsScheduledCount,
    src.CANCELED_CNT AS VisitStatsCanceledCount,
    src.PATIENT_CANCELED_CNT AS VisitStatsPatientCanceledCount,
    src.SAME_DAY_CANCELED_CNT AS VisitStatsSameDayCanceledCount,
    src.LATE_CANCELED_CNT AS VisitStatsLateCanceledCount,
    src.LATE_PROV_CANCELED_CNT AS VisitStatsLateProviderCanceledCount,
    src.RESCHEDULED_APPT_CNT AS VisitStatsRescheduledCount,
    src.SAME_DAY_APPT_CNT AS VisitStatsSameDayBooked,
    src.APPT_FOR_TODAY_LEAD_DAYS AS VisitStatsForTodayLeadDays,
    src.APPT_FOR_TODAY_CNT AS VisitStatsForTodayCount,
    src.APPT_MADE_TODAY_LEAD_DAYS AS VisitStatsMadeTodayLeadDays,
    src.APPT_MADE_TODAY_CNT AS VisitStatsMadeTodayCount,
    src.REG_AVAILABLE_HRS AS VisitStatsRegularAvailableHours,
    src.OVERBOOK_AVAILABLE_HRS AS VisitStatsOverbookAvailableHours,
    src.UNAVAILABLE_OPENINGS_USED_CNT AS VisitStatsUnavailableOpeningsUsed,
    src.HELD_OPENINGS_USED_CNT AS VisitStatsHeldOpeningsUsed,
    GETDATE() AS VisitStatsUpdateDate

FROM OPENQUERY
(
    [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM],
'
SELECT
    s.PROV_ID,
    s.DEPARTMENT_ID,
    s.STATISTICS_DATE,
    s.SCHEDULABLE_HRS,
    s.BOOKED_HRS,
    s.AVAIL_OPENINGS_ON_DAY_CNT,
    s.REG_OPENINGS_CNT,
    s.SAME_DAY_REG_OPENINGS_USED_CNT,
    s.PREVIOUS_REG_OPENINGS_USED_CNT,
    s.OVERBOOK_OPENINGS_CNT,
    s.SAME_DAY_OVRBK_OPENGS_USED_CNT,
    s.PREVIOUS_OVRBK_OPENGS_USED_CNT,
    s.ARRIVED_CNT,
    s.NO_SHOW_CNT,
    s.LEFT_WO_SEEN_CNT,
    s.COMPLETED_CNT,
    s.SCHEDULED_CNT,
    s.CANCELED_CNT,
    s.PATIENT_CANCELED_CNT,
    s.SAME_DAY_CANCELED_CNT,
    s.LATE_CANCELED_CNT,
    s.LATE_PROV_CANCELED_CNT,
    s.RESCHEDULED_APPT_CNT,
    s.SAME_DAY_APPT_CNT,
    s.APPT_FOR_TODAY_LEAD_DAYS,
    s.APPT_FOR_TODAY_CNT,
    s.APPT_MADE_TODAY_LEAD_DAYS,
    s.APPT_MADE_TODAY_CNT,
    s.REG_AVAILABLE_HRS,
    s.OVERBOOK_AVAILABLE_HRS,
    s.UNAVAILABLE_OPENINGS_USED_CNT,
    s.HELD_OPENINGS_USED_CNT
FROM CLARITY.ORGFILTER.F_SCHED_APPT_STATS s
LEFT JOIN CLARITY.ORGFILTER.CLARITY_DEP d
    ON d.DEPARTMENT_ID = s.DEPARTMENT_ID
WHERE
    d.DEPARTMENT_NAME LIKE ''TPG%''
    OR d.DEPARTMENT_NAME LIKE ''HPIP%''
'
) src;

END

---- Step 1: Delete existing records for the data source
--	DELETE FROM fact.VisitStatsPB 
--	WHERE VisitStatsDataSourceID = 5;

---- Step 2: Insert into fact.VisitStatsPB
--INSERT INTO fact.VisitStatsPB(
--	[VisitStatsID],
--	[VisitStatsDataSourceID],
--	[VisitStatsProviderID],
--	[VisitStatsDepartmentID],
--	[VisitStatsDate],
--	[VisitStatsAvailableHours],
--	[VisitStatsBookedHours],
--	[VisitStatsAvailableOpeningsOnDay],
--	[VisitStatsRegularOpeningsOnDay],
--	[VisitStatsSameDayRegularBooked],
--	[VisitStatsRegularBooked],
--	[VisitStatsOverbookOpenings],
--	[VisitStatsSameDayOverbooked],
--	[VisitStatsOverbooked],
--	[VisitStatsArrivedCount],
--	[VisitStatsNoShowCount],
--	[VisitStatsLeftWithoutBeingSeenCount],
--	[VisitStatsCompletedCount],
--	[VisitStatsScheduledCount],
--	[VisitStatsCanceledCount],
--	[VisitStatsPatientCanceledCount],
--	[VisitStatsSameDayCanceledCount],
--	[VisitStatsLateCanceledCount],
--	[VisitStatsLateProviderCanceledCount],
--	[VisitStatsRescheduledCount],
--	--[ReschedulePatientVolume],
--	--[RescheduleProviderVolume],
--	[VisitStatsSameDayBooked],
--	[VisitStatsForTodayLeadDays],
--	[VisitStatsForTodayCount],
--	[VisitStatsMadeTodayLeadDays],
--	[VisitStatsMadeTodayCount],
--	[VisitStatsRegularAvailableHours],
--	[VisitStatsOverbookAvailableHours],
--	[VisitStatsUnavailableOpeningsUsed],
--	[VisitStatsHeldOpeningsUsed],
--	[VisitStatsUpdateDate]
--)



--SELECT 	
--	CONCAT('5~',s.PROV_ID,'~',s.DEPARTMENT_ID,'~',FORMAT(s.STATISTICS_DATE, 'yyyy-MM-dd')) as VisitStatsID
--	,5 as VisitStatsDataSourceID
--	,CONCAT('5~', s.PROV_ID) as VisitStatsProviderID	
--	,CONCAT('5~', s.DEPARTMENT_ID) as VisitStatsDepartmentID	
--	,s.STATISTICS_DATE as VisitStatsDate
--	--,s.MASTER_SCHEDULABLE_HRS	
--	,s.SCHEDULABLE_HRS as VisitStatsAvailableHours
--	,s.BOOKED_HRS as VisitStatsBookedHours
--	,s.AVAIL_OPENINGS_ON_DAY_CNT as VisitStatsAvailableOpeningsOnDay	--The count of both regular and overbook openings for this date that were available for scheduling on this date for this provider in this department (includes openings made available by same day cancellations).
--	,s.REG_OPENINGS_CNT	 as VisitStatsRegularOpeningsOnDay  --The number of regular openings for this provider in this department for this date.
--	,s.SAME_DAY_REG_OPENINGS_USED_CNT as VisitStatsSameDayRegularBooked --The number of openings with appointments scheduled for this provider in this department where the appointment was made the same day it occurred and did not cause the number of appointments for this slot to exceed the number of regular openings available.
--	,s.PREVIOUS_REG_OPENINGS_USED_CNT as VisitStatsRegularBooked	--The number of openings with appointments scheduled for this provider in this department where the appointment was made prior to the day it occurred and did not exceed the number of regular openings available for that slot.
--	,s.OVERBOOK_OPENINGS_CNT as VisitStatsOverbookOpenings  --The number of overbook openings for this provider in this department for this date.
--	,s.SAME_DAY_OVRBK_OPENGS_USED_CNT as VisitStatsSameDayOverbooked  --The number of openings with appointments scheduled for this provider in this department beyond the number of regular openings for the slot where the appointment was made the same day it occurred.
--	,s.PREVIOUS_OVRBK_OPENGS_USED_CNT as VisitStatsOverbooked	 --The number of openings with appointments scheduled for this provider in this department beyond the number of regular openings for the slot where the appointment was made prior to the day it occurred.
--	,s.ARRIVED_CNT as VisitStatsArrivedCount
--	,s.NO_SHOW_CNT as VisitStatsNoShowCount	
--	,s.LEFT_WO_SEEN_CNT	as VisitStatsLeftWithoutBeingSeenCount
--	,s.COMPLETED_CNT as VisitStatsCompletedCount
--	,s.SCHEDULED_CNT as VisitStatsScheduledCount	
--	,s.CANCELED_CNT	as VisitStatsCanceledCount
--	,s.PATIENT_CANCELED_CNT	as VisitStatsPatientCanceledCount
--	,s.SAME_DAY_CANCELED_CNT as VisitStatsSameDayCanceledCount
--	,s.LATE_CANCELED_CNT as VisitStatsLateCanceledCount
--	,s.LATE_PROV_CANCELED_CNT as VisitStatsLateProviderCanceledCount
--	,s.RESCHEDULED_APPT_CNT	as VisitStatsRescheduledCount
--	--,COALESCE(r.ReschedulePatientVolume, 0) as ReschedulePatientVolume
--	--,COALESCE(r.RescheduleProviderVolume, 0) as RescheduleProviderVolume
--	,s.SAME_DAY_APPT_CNT as VisitStatsSameDayBooked
--	--,s.APPT_WITH_PCP_CNT 
--	,s.APPT_FOR_TODAY_LEAD_DAYS	as VisitStatsForTodayLeadDays --days between when an appointment was made and when it occurred for appointments scheduled for this date
--	,s.APPT_FOR_TODAY_CNT as VisitStatsForTodayCount
--	,s.APPT_MADE_TODAY_LEAD_DAYS as VisitStatsMadeTodayLeadDays
--	,s.APPT_MADE_TODAY_CNT as VisitStatsMadeTodayCount
--	,s.REG_AVAILABLE_HRS as VisitStatsRegularAvailableHours
--	,s.OVERBOOK_AVAILABLE_HRS as VisitStatsOverbookAvailableHours
--	,s.UNAVAILABLE_OPENINGS_USED_CNT as VisitStatsUnavailableOpeningsUsed  --The number of openings with appointments scheduled for this provider in this department in slots marked unavailable
--	,s.HELD_OPENINGS_USED_CNT as VisitStatsHeldOpeningsUsed
--	,GETDATE() as VisitStatsUpdateDate
--FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].F_SCHED_APPT_STATS s
--	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].CLARITY_DEP d on d.DEPARTMENT_ID = s.DEPARTMENT_ID
--	--LEFT JOIN (
--	--			SELECT 
--	--				CONCAT('5~',s.PROV_ID,'~',s.DEPARTMENT_ID,'~',FORMAT(s.CONTACT_DATE, 'yyyy-MM-dd')) as RescheduleID
--	--				,CONCAT('5~',s.PROV_ID) as ProviderID
--	--				,CONCAT('5~',s.DEPARTMENT_ID) as DepartmentID
--	--				,s.CONTACT_DATE as ContactDate
--	--				,CASE WHEN s.CANCEL_REASON_NAME = 'Patient' THEN COUNT(s.RESCHED_APPT_CSN_ID) END as ReschedulePatientVolume
--	--				,CASE WHEN s.CANCEL_REASON_NAME = 'Provider' THEN COUNT(s.RESCHED_APPT_CSN_ID) END as RescheduleProviderVolume
--	--			FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].V_SCHED_APPT s
--	--			WHERE (s.DEPARTMENT_NAME  like 'TPG%' or s.DEPARTMENT_NAME like 'HPIP%') 	
--	--				 and s.RESCHED_APPT_CSN_ID is not null
--	--			GROUP BY
--	--				s.PROV_ID
--	--				,s.DEPARTMENT_ID
--	--				,s.CONTACT_DATE
--	--				,s.CANCEL_REASON_NAME) as r on r.RescheduleID = CONCAT('5~',s.PROV_ID,'~',s.DEPARTMENT_ID,'~',FORMAT(s.STATISTICS_DATE, 'yyyy-MM-dd'))
--WHERE d.DEPARTMENT_NAME  like 'TPG%' or d.DEPARTMENT_NAME like 'HPIP%' 	

--END;

/*
select top 1000 CANCEL_REASON_NAME from [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].F_SCHED_APPT_STATS group by CANCEL_REASON_NAME

select top 1000 * from [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].V_CASE_SCHEDULE_CHANGE

select top 1000 CANCEL_REASON_NAME from [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].V_SCHED_APPT where RESCHED_APPT_CSN_ID is not null group by CANCEL_REASON_NAME


SELECT 
	CONCAT('5~',s.PROV_ID,'~',s.DEPARTMENT_ID,'~',FORMAT(s.CONTACT_DATE, 'yyyy-MM-dd')) as RescheduleID
	,CONCAT('5~',s.PROV_ID) as ProviderID
	,CONCAT('5~',s.DEPARTMENT_ID) as DepartmentID
	,s.CONTACT_DATE as ContactDate
	,CASE WHEN s.CANCEL_REASON_NAME = 'Patient' THEN COUNT(s.RESCHED_APPT_CSN_ID) END as ReschedulePatientVolume
	,CASE WHEN s.CANCEL_REASON_NAME = 'Provider' THEN COUNT(s.RESCHED_APPT_CSN_ID) END as RescheduleProviderVolume
FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].V_SCHED_APPT s
WHERE (s.DEPARTMENT_NAME  like 'TPG%' or s.DEPARTMENT_NAME like 'HPIP%') 	
	 and s.RESCHED_APPT_CSN_ID is not null
GROUP BY
	s.PROV_ID
	,s.DEPARTMENT_ID
	,s.CONTACT_DATE
	,s.CANCEL_REASON_NAME

*/
GO
