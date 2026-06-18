CREATE PROCEDURE [stg].[spEPICReloadFactVisitSchedulePBFull]	AS
BEGIN		
	-- ========================================================================
	-- Author:		Eric Silvestri
	-- Create date: 11-12-2024
	-- Description:	Loads PB VisitSchedule records from EPIC into fact.VisitSchedulePB.
    -- Change Control:
    --      1. 1/8/26 - Diego Hernandez - Modify to Open Query
	-- ========================================================================


-- Step 1: Delete existing records for the data source
DELETE FROM fact.VisitSchedulePB
WHERE VisitScheduleDataSourceID = 5;


-- Step 2: Insert into fact.VisitSchedulePB
INSERT INTO fact.VisitSchedulePB
(
    [VisitScheduleVisitID],
    [VisitScheduleDataSourceID],
    [VisitScheduleSourceID],
    [VisitScheduleAccountID],
    [VisitScheduleDate],
    [VisitSchedulePatientID],
    [VisitScheduleStatus],
    [VisitScheduleDepartmentID],
    [VisitScheduleSpecialty],
    [VisitScheduleLocationID],
    [VisitScheduleProviderID],
    [VisitSchedulePayerID],
    [VisitScheduleType],
    [VisitScheduleScheduleDate],
    [VisitScheduleAppointmentDate],
    [VisitScheduleCheckinTime],
    [VisitScheduleInRoomTime],
    [VisitScheduleProviderInTime],
    [VisitScheduleEndTime],
    [VisitScheduleCheckoutTime],
    [VisitScheduleTimeToRoom],
    [VisitScheduleTimeInRoom],
    [VisitScheduleVisitDuration],
    [VisitScheduleSameDayCancellation],
    [VisitScheduleConfirmationStatus],
    [VisitScheduleConfirmationDate],
    [VisitScheduleOverbook],
    [VisitScheduleCancellationDate],
    [VisitScheduleLateCancellation],
    [VisitScheduleCopayDue],
    [VisitScheduleCopayCollected],
    [VisitScheduleUpdateDate]
)

SELECT
    CONCAT('5~',src.PAT_ENC_CSN_ID) AS VisitScheduleVisitID,
    5 AS VisitScheduleDataSourceID,
    src.PAT_ENC_CSN_ID AS VisitScheduleSourceID,
    CONCAT('5~',src.ACCOUNT_ID) AS VisitScheduleAccountID,
    src.CONTACT_DATE AS VisitScheduleDate,
    CONCAT('5~',src.PAT_ID) AS VisitSchedulePatientID,
    src.APPT_STATUS_NAME AS VisitScheduleStatus,
    CONCAT('5~',src.DEPARTMENT_ID) AS VisitScheduleDepartmentID,
    src.DEPT_SPECIALTY_NAME AS VisitScheduleSpecialty,
    CONCAT('5~',src.LOC_ID) AS VisitScheduleLocationID,
    CONCAT('5~',src.PROV_ID) AS VisitScheduleProviderID,
    CONCAT('5~',src.PAYOR_ID) AS VisitSchedulePayerID,
    src.PRC_NAME AS VisitScheduleType,
    src.APPT_MADE_DATE AS VisitScheduleScheduleDate,
    src.APPT_DTTM AS VisitScheduleAppointmentDate,
    src.CHECKIN_DTTM AS VisitScheduleCheckinTime,
    src.ROOMED_DTTM AS VisitScheduleInRoomTime,
    src.PHYS_ENTER_DTTM AS VisitScheduleProviderInTime,
    src.VISIT_END_DTTM AS VisitScheduleEndTime,
    src.CHECKOUT_DTTM AS VisitScheduleCheckoutTime,
    src.TIME_TO_ROOM_MINUTES AS VisitScheduleTimeToRoom,
    src.TIME_IN_ROOM_MINUTES AS VisitScheduleTimeInRoom,
    src.CYCLE_TIME_MINUTES AS VisitScheduleVisitDuration,
    src.SAME_DAY_CANC_YN AS VisitScheduleSameDayCancellation,
    src.APPT_CONF_STAT_NAME AS VisitScheduleConfirmationStatus,
    src.APPT_CONF_DTTM AS VisitScheduleConfirmationDate,
    src.OVERBOOKED_YN AS VisitScheduleOverbook,
    src.APPT_CANC_UTC_DTTM AS VisitScheduleCancellationDate,
    src.LATE_CANCEL_YN AS VisitScheduleLateCancellation,
    src.COPAY_DUE AS VisitScheduleCopayDue,
    src.COPAY_COLLECTED AS VisitScheduleCopayCollected,
    GETDATE() AS VisitScheduleUpdateDate

FROM OPENQUERY
(
    [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM],
'
SELECT
    s.PAT_ENC_CSN_ID,
    s.ACCOUNT_ID,
    s.CONTACT_DATE,
    s.PAT_ID,
    s.APPT_STATUS_NAME,
    s.DEPARTMENT_ID,
    s.DEPT_SPECIALTY_NAME,
    s.LOC_ID,
    s.PROV_ID,
    c.PAYOR_ID,
    s.PRC_NAME,
    s.APPT_MADE_DATE,
    s.APPT_DTTM,
    s.CHECKIN_DTTM,
    s.ROOMED_DTTM,
    s.PHYS_ENTER_DTTM,
    s.VISIT_END_DTTM,
    s.CHECKOUT_DTTM,
    s.TIME_TO_ROOM_MINUTES,
    s.TIME_IN_ROOM_MINUTES,
    s.CYCLE_TIME_MINUTES,
    s.SAME_DAY_CANC_YN,
    s.APPT_CONF_STAT_NAME,
    s.APPT_CONF_DTTM,
    s.OVERBOOKED_YN,
    s.APPT_CANC_UTC_DTTM,
    s.LATE_CANCEL_YN,
    s.COPAY_DUE,
    s.COPAY_COLLECTED
FROM CLARITY.ORGFILTER.V_SCHED_APPT s
LEFT JOIN CLARITY.ORGFILTER.COVERAGE c
    ON c.COVERAGE_ID = s.COVERAGE_ID
WHERE
    s.DEPARTMENT_NAME LIKE ''TPG%''
    OR s.DEPARTMENT_NAME LIKE ''HPIP%''
'
) src;

END;
---- Step 1: Delete existing records for the data source
--	DELETE FROM fact.VisitSchedulePB 
--	WHERE VisitScheduleDataSourceID = 5;

---- Step 2: Insert into fact.VisitSchedulePB
--INSERT INTO fact.VisitSchedulePB(
--	[VisitScheduleVisitID],
--	[VisitScheduleDataSourceID],
--	[VisitScheduleSourceID],
--	[VisitScheduleAccountID],
--	[VisitScheduleDate],
--	[VisitSchedulePatientID],
--	[VisitScheduleStatus],
--	[VisitScheduleDepartmentID],
--	[VisitScheduleSpecialty],
--	[VisitScheduleLocationID],
--	[VisitScheduleProviderID],
--	[VisitSchedulePayerID],
--	[VisitScheduleType],
--	[VisitScheduleScheduleDate],
--	[VisitScheduleAppointmentDate],
--	[VisitScheduleCheckinTime],
--	[VisitScheduleInRoomTime],
--	[VisitScheduleProviderInTime],
--	[VisitScheduleEndTime],
--	[VisitScheduleCheckoutTime],
--	[VisitScheduleTimeToRoom],
--	[VisitScheduleTimeInRoom],
--	[VisitScheduleVisitDuration],
--	[VisitScheduleSameDayCancellation],
--	[VisitScheduleConfirmationStatus],
--	[VisitScheduleConfirmationDate],
--	[VisitScheduleOverbook],
--	[VisitScheduleCancellationDate],
--	[VisitScheduleLateCancellation],
--	[VisitScheduleCopayDue],
--	[VisitScheduleCopayCollected],
--	[VisitScheduleUpdateDate]
--)



--SELECT 
--	 CONCAT('5~', s.PAT_ENC_CSN_ID) as VisitScheduleVisitID
--	 ,5 as VisitScheduleDataSourceID
--	 ,s.PAT_ENC_CSN_ID as VisitScheduleSourceID
--	 ,CONCAT('5~', s.ACCOUNT_ID) as VisitScheduleAccountID
--	 ,CONTACT_DATE as VisitScheduleDate
--	 ,CONCAT('5~', s.PAT_ID) as VisitSchedulePatientID
--	 ,APPT_STATUS_NAME as VisitScheduleStatus
--	 ,CONCAT('5~', s.DEPARTMENT_ID) as VisitScheduleDepartmentID
--	 ,DEPT_SPECIALTY_NAME as VisitScheduleSpecialty
--	 ,CONCAT('5~', s.LOC_ID) as VisitScheduleLocationID
--	 ,CONCAT('5~', s.PROV_ID) as VisitScheduleProviderID
--	 ,CONCAT('5~', c.PAYOR_ID) as VisitSchedulePayerID
--	 ,s.PRC_NAME as VisitScheduleType
--	 ,s.APPT_MADE_DATE as VisitScheduleScheduleDate
--	 ,s.APPT_DTTM as VisitScheduleAppointmentDate
--	 ,s.CHECKIN_DTTM as VisitScheduleCheckinTime
--	 ,s.ROOMED_DTTM as VisitScheduleInRoomTime
--	 ,s.PHYS_ENTER_DTTM as VisitScheduleProviderInTime
--	 ,s.VISIT_END_DTTM as VisitScheduleEndTime
--	 ,s.CHECKOUT_DTTM as VisitScheduleCheckoutTime
--	 ,s.TIME_TO_ROOM_MINUTES as VisitScheduleTimeToRoom
--	 ,s.TIME_IN_ROOM_MINUTES as VisitScheduleTimeInRoom
--	 ,s.CYCLE_TIME_MINUTES as VisitScheduleVisitDuration 
--	 ,s.SAME_DAY_CANC_YN as VisitScheduleSameDayCancellation
--	 ,s.APPT_CONF_STAT_NAME as VisitScheduleConfirmationStatus
--	 ,s.APPT_CONF_DTTM as VisitScheduleConfirmationDate
--	 ,s.OVERBOOKED_YN as VisitScheduleOverbook
--	 ,s.APPT_CANC_UTC_DTTM as VisitScheduleCancellationDate
--	 ,s.LATE_CANCEL_YN as VisitScheduleLateCancellation
--	 ,s.COPAY_DUE as VisitScheduleCopayDue
--	 ,s.COPAY_COLLECTED as VisitScheduleCopayCollected
--	 ,GETDATE() as VisitScheduleUpdateDate
--FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].V_SCHED_APPT s 
--	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].COVERAGE c on c.COVERAGE_ID = s.COVERAGE_ID
--WHERE s.DEPARTMENT_NAME like 'TPG%' or s.DEPARTMENT_NAME like 'HPIP%'


--END;
GO
