-- =============================================
-- Author:		Jacob Roan
-- Create date: 08/08/2023
-- Description:	Extracts, Transforms and Loads visitcase Data from EPIC Source System into a fact table
-- Change Control
--	1. 08/08/2023 - Jacob Roan - Initial build of procedure
-- 2. 08/10/2023 - Jacob Roan - added visitcase fk
-- 3. 08/26/2024 - Eric Silvestri - added cancellation details ScheduleAction, ActionStatus, and Reschedule Date
-- 4. 09/27/2024 - Chris Cross - added begin and end datetimes for each phase, minutes in each phase, procedure, and room
-- 5. 10/07/2024 - Diego Hernandez - Added Anesthesia provider  and anesthesia type (Stryker project)
-- 6. 10/11/2024 - Eric Silvestri - added Late start details and on time first start
-- 7. 12/23/2024 - Diego Hernandez - Including height, weight and BMI
-- 8. 02/04/2025 - Diego Hernandez - Added [VisitCasePrimaryScheduledProcedure], [VisitCaseLaterality],[VisitCaseEmergencyStatus]  for USPI
-- 9. 03/26/2025 - Diego Hernandez -Include temp table
-- 10.04/08/2025 - Diego Hernandez - Changing to @stagingtable to manage failures 
-- =============================================
	CREATE procedure [stg].[spEPICReloadFactVisitCasesFull] as
	BEGIN
    SET NOCOUNT ON;
	--Create stg table for full load
	PRINT 'Creating @StagingTable...'

	DECLARE @StagingTable table 
	(VisitCaseID VARCHAR(100) NOT NULL,
    VisitCaseDatesourceID INT NULL,
    VisitCaseSourceID VARCHAR(100) NULL,
    VisitCaseVisitID VARCHAR(100) NULL,
    VisitCaseCSN VARCHAR(100) NULL,
    VisitCaseLocationID VARCHAR(100) NULL,
    VisitCaseServiceDate DATE NULL,
    VisitCaseScheduledDatetime DATETIME NULL,
    VisitCaseScheduleStartDatetime DATETIME NULL,
    VisitCaseScheduleEndDatetime DATETIME NULL,
    VisitCaseBeginDatetime DATETIME NULL,
    VisitCaseEndDatetime DATETIME NULL,
    VisitCaseRescheduledDate DATETIME NULL,
    VisitCaseCancelledDate DATETIME NULL,
    VisitCaseCancelledReason VARCHAR(100) NULL,
    VisitCaseIsRescheduled VARCHAR(10) NULL,
    VisitCaseServiceID VARCHAR(100) NULL,
    VisitCaseORID VARCHAR(100) NULL,
    VisitCaseRoomID VARCHAR(50) NULL,
    VisitCaseScheduleStatus VARCHAR(100) NULL,
    VisitCasePatientClass VARCHAR(100) NULL,
    VisitCaseService VARCHAR(100) NULL,
    VisitCasePrimaryProviderID VARCHAR(100) NULL,
    VisitCaseTotalTimeNeeded INT NULL,
    VisitCaseLogStatus VARCHAR(100) NULL,
    VisitCaseScheduledORBeginDatetime DATETIME NULL,
    VisitCaseScheduledOREndDatetime DATETIME NULL,
    VisitCasePreOpBeginDatetime DATETIME NULL,
    VisitCasePreOpEndDatetime DATETIME NULL,
    VisitCaseORBeginDatetime DATETIME NULL,
    VisitCaseProcedureBeginDatetime DATETIME NULL,
    VisitCaseProcedureEndDatetime DATETIME NULL,
    VisitCaseOREndDatetime DATETIME NULL,
    VisitCaseRecoveryBeginDatetime DATETIME NULL,
    VisitCaseRecoveryEndDatetime DATETIME NULL,
    VisitCasePhase2BeginDatetime DATETIME NULL,
    VisitCasePhase2EndDatetime DATETIME NULL,
    VisitCaseMinutesScheduledInOR INT NULL,
    VisitCaseMinutesInPreop INT NULL,
    VisitCaseMinutesInOR INT NULL,
    VisitCaseMinutesInRecovery INT NULL,
    VisitCaseMinutesInPhase2 INT NULL,
    VisitCaseSetupMinutes INT NULL,
    VisitCaseCleanupMinutes INT NULL,
    VisitCaseScheduledTurnoverDuration INT NULL,
    VisitCaseRoomTurnoverDuration INT NULL,
    VisitCaseProcedureTurnoverDuration INT NULL,
    VisitCaseMinutesLate INT NULL,
    VisitCaseLateStart VARCHAR(30) NULL,
    VisitCaseMinutesOverrun INT NULL,
    VisitCaseLenghtDifference INT NULL,
    VisitCaseLenghtDifferencePercent INT NULL,
    VisitCaseLengthAccuracy VARCHAR(30) NULL,
    VisitCasePrimaryProcedure VARCHAR(300) NULL,
    VisitCaseNotPerformedReason VARCHAR(300) NULL,
    VisitCaseNotPerformedComment VARCHAR(300) NULL,
    VisitCaseUpdatedDatetime DATETIME NULL,
    VisitCaseAnesthesiaType VARCHAR(255) NULL,
    VisitCaseASARating INT NULL,
    VisitCasePhysician INT NULL,
    VisitCaseCirculatingNurse INT NULL,
    VisitCaseSurgTech INT NULL,
    VisitCasePatientTemperaturePACUArrival DECIMAL(5,2) NULL,
    VisitCaseFirstCaseofDay VARCHAR(1) NULL,
    VisitCaseAnesthesiaProviderID VARCHAR(80) NULL,
    VisitCaseAdmissionStatus VARCHAR(150) NULL,
    VisitCaseDischargeDisposition VARCHAR(100) NULL,
    VisitCaseHeight VARCHAR(10) NULL,
    VisitCaseWeight FLOAT NULL,
    VisitCaseBMI FLOAT NULL,
    VisitCasePrimaryScheduledProcedure VARCHAR(MAX) NULL,
    VisitCaseLaterality VARCHAR(200) NULL,
    VisitCaseEmergencyStatus VARCHAR(200) NULL);


	-- Step 2: Create the temp table for laterality
	IF OBJECT_ID('tempdb..#Laterality') IS NOT NULL
    DROP TABLE #Laterality;

	CREATE TABLE #Laterality (
    VisitCaseID NVARCHAR(50),  -- Adjust the datatype if needed
    Lateralities NVARCHAR(MAX)  -- Assuming STRING_AGG results in a long string
	);
	-- Step 2: Insert data into the temp table
	INSERT INTO #Laterality (VisitCaseID, Lateralities)
		SELECT
			orc.or_case_id AS VisitCaseID,
			STRING_AGG(lrb.NAME, '/ ') AS Lateralities
		FROM 
			[CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].OR_CASE orc
		LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].OR_CASE_ALL_PROC cp 
			ON cp.OR_CASE_ID = orc.OR_CASE_ID AND cp.LINE = 1
		LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_OR_LRB lrb 
			ON lrb.LRB_C = cp.LRB_C
		GROUP BY orc.or_case_id;


	PRINT 'Inserting records from Datasource into @StagingTable....'
	INSERT INTO @StagingTable (
	   [VisitCaseID]
      ,[VisitCaseDatesourceID]
      ,[VisitCaseSourceID]
      ,[VisitCaseVisitID]
      ,[VisitCaseCSN]
      ,[VisitCaseLocationID]
      ,[VisitCaseServiceDate]
      ,[VisitCaseScheduledDatetime]
      ,[VisitCaseScheduleStartDatetime]
      ,[VisitCaseScheduleEndDatetime]
      ,[VisitCaseBeginDatetime]
      ,[VisitCaseEndDatetime]
	  ,[VisitCaseRescheduledDate]
      ,[VisitCaseCancelledDate]
      ,[VisitCaseCancelledReason]
      ,[VisitCaseIsRescheduled]
      ,[VisitCaseServiceID]
      ,[VisitCaseORID]
      ,[VisitCaseRoomID]
      ,[VisitCaseScheduleStatus]
      ,[VisitCasePatientClass]
      ,[VisitCaseService]
      ,[VisitCasePrimaryProviderID]
      ,[VisitCaseTotalTimeNeeded]
      ,[VisitCaseLogStatus]
      ,[VisitCaseScheduledORBeginDatetime]
      ,[VisitCaseScheduledOREndDatetime]
      ,[VisitCasePreOpBeginDatetime]
      ,[VisitCasePreOpEndDatetime]
      ,[VisitCaseORBeginDatetime]
      ,[VisitCaseProcedureBeginDatetime]
      ,[VisitCaseProcedureEndDatetime]
      ,[VisitCaseOREndDatetime]
      ,[VisitCaseRecoveryBeginDatetime]
      ,[VisitCaseRecoveryEndDatetime]
      ,[VisitCasePhase2BeginDatetime]
      ,[VisitCasePhase2EndDatetime]
      ,[VisitCaseMinutesScheduledInOR]
      ,[VisitCaseMinutesInPreop]
      ,[VisitCaseMinutesInOR]
      ,[VisitCaseMinutesInRecovery]
      ,[VisitCaseMinutesInPhase2]
	  ,[VisitCaseSetupMinutes]
	  ,[VisitCaseCleanupMinutes]
	  ,[VisitCaseScheduledTurnoverDuration]
	  ,[VisitCaseRoomTurnoverDuration]
	  ,[VisitCaseProcedureTurnoverDuration]
	  ,[VisitCaseMinutesLate]
	  ,[VisitCaseLateStart]
	  ,[VisitCaseMinutesOverrun] 
	  ,[VisitCaseLenghtDifference]
	  ,[VisitCaseLenghtDifferencePercent]
	  ,[VisitCaseLengthAccuracy]
      ,[VisitCasePrimaryProcedure]
      ,[VisitCaseNotPerformedReason]
      ,[VisitCaseNotPerformedComment]
	  ,[VisitCaseHeight]
	  ,[VisitCaseWeight]
	  ,[VisitCaseBMI]
	  ,[VisitCaseAnesthesiaProviderID]
	  ,[VisitCaseAnesthesiaType]
	  ,[VisitCaseASARating]
	  ,[VisitCasePhysician] 
	  ,[VisitCaseCirculatingNurse] 
	  ,[VisitCaseSurgTech] 
	  ,[VisitCaseFirstCaseofDay]
	  ,[VisitCaseDischargeDisposition]
	  ,[VisitCasePatientTemperaturePACUArrival]
	  ,[VisitCaseAdmissionStatus]
      ,[VisitCaseUpdatedDatetime]
	  ,[VisitCasePrimaryScheduledProcedure]
	  ,[VisitCaseLaterality]
	  ,[VisitCaseEmergencyStatus]

	)
	select
		concat('5~', orc.or_case_id) VisitCaseID
		,5 VisitCaseDatasourceID
		,orc.or_case_id VisitCaseSourceID
		,case when ol.or_link_csn is null then null else concat('5~', ol.or_link_csn) end VisitCaseVisitID
		,COALESCE(ol.OR_LINK_CSN, enc.PAT_ENC_CSN_ID, ol.PAT_ENC_CSN_ID) VisitCaseCSN
		,concat('5~', orc.loc_id) VisitCaseLocationID
		,orc.surgery_date VisitCaseServiceDate
		,orc.time_scheduled VisitCaseScheduledDatetime
		,orc.CASE_BEGIN_INSTANT as VisitCaseScheduleStartDateTime
        ,orc.CASE_END_INSTANT as VisitCaseScheduleEndDateTime
		,COALESCE(lb.IN_OR_DTTM, orc.case_begin_instant) as VisitCaseBeginDatetime
		,COALESCE(lb.OUT_OR_DTTM, orc.case_end_instant) as VisitCaseEndDatetime
		,CASE WHEN ISNULL(sts.NAME,'') <> 'Canceled' THEN orc.CANCEL_DATE END as VisitCaseRescheduledDate
		,CASE WHEN sts.NAME = 'Canceled' THEN orc.CANCEL_DATE END as VisitCaseCancelledDate
		,can.NAME as VisitCaseCancelledReason
		,CASE WHEN csc.CASE_ID is not null THEN 'Yes' ELSE 'No' END as VisitCaseIsRescheduled
		,orc.service_c VisitCaseServiceID
		,orc.or_id VisitCaseORID

		,CASE WHEN orl.ROOM_ID is not null THEN CONCAT('5~',orl.ROOM_ID)
			  WHEN orc.or_id IS NOT NULL THEN CONCAT('5~',orc.or_id) END as VisitCaseRoomID 

		,CASE WHEN lb.IN_OR_DTTM IS NOT NULL THEN 'Completed' ELSE sts.name END VisitCaseScheduleStatus
		,pc.name VisitCasePatientClass
		,svc.name VisitCaseService
		,concat('5~', orc.primary_physician_id) VisitCasePrimaryProviderID
		,orc.total_time_needed VisitCaseTotalTimeNeeded
		,os.name VisitCaseLogStatus
		,lb.SCHEDULED_IN_OR_DTTM as VisitCaseScheduledORBeginDatetime 
		,lb.SCHEDULED_OUT_OR_DTTM as VisitCaseScheduledOREndDatetime 
		,lb.IN_PREOP_DTTM as VisitCasePreOpBeginDatetime 
		,lb.COMP_PREOP_DTTM as VisitCasePreOpEndDatetime
		,lb.IN_OR_DTTM as VisitCaseORBeginDatetime 
		,lb.PROCEDURE_START_DTTM as VisitCaseProcedureBeginDatetime 
		,lb.PROCEDURE_COMP_DTTM as VisitCaseProcedureEndDatetime 
		,lb.OUT_OR_DTTM  as VisitCaseOREndDatetime 
		,lb.IN_RECOVERY_DTTM as VisitCaseRecoveryBeginDatetime 
		,lb.OUT_RECOVERY_DTTM as VisitCaseRecoveryEndDatetime 
		,lb.IN_PHASEII_DTTM as VisitCasePhase2BeginDatetime 
		,lb.OUT_PHASEII_DTTM as VisitCasePhase2EndDatetime 
		,lb.MINUTES_SCHEDULED_IN_OR as VisitCaseMinutesScheduledInOR 
		,lb.MINUTES_IN_PREOP as VisitCaseMinutesInPreop 
		,lb.MINUTES_IN_OR as VisitCaseMinutesInOR 
		,lb.MINUTES_IN_RECOVERY as VisitCaseMinutesInRecovery 
		,lb.MINUTES_IN_PHASEII as VisitCaseMinutesInPhase2 
		,ot.SETUP_LENGTH as VisitCaseSetupMinutes
		,ot.CLEANUP_LENGTH as VisitCaseCleanupMinutes
		,rt.SCHED_ROOM_OUT_TO_IN as VisitCaseScheduledTurnoverDuration
		,rt.ROOM_OUT_TO_IN_ADJ as VisitCaseRoomTurnoverDuration
		,rt.PROC_COMP_TO_START_ADJ as VisitCaseProcedureTurnoverDuration
		,lv.MINUTES_LATE as VisitCaseMinutesLate 
		,lv.LATE_CASE_YN as VisitCaseLateStart
		,lv.MINUTES_OVERRUN as VisitCaseMinutesOverrun --Minutes case ran over from scheduled time
		,lv.CASE_LEN_MIN_DIFF as VisitCaseLenghtDifference --Difference in minutes between scheduled time and actual time
		,lv.CASE_LEN_PCT_DIFF as VisitCaseLenghtDifferencePercent
		,lv.CASE_LEN_ACCURAT_YN as VisitCaseLengthAccuracy --Was the Scheduled case length accurate within 10 min threshold
		,CONVERT(varchar(300),op.PROC_NAME) as VisitCasePrimaryProcedure
		,np.[NAME] as VisitCaseNotPerformedReason 
		,orl.PROC_NOT_PERF_COM as VisitCaseNotPerformedComment
		,enc.HEIGHT as VisitCaseHeight --Including Height , Weight and BMI 12/23/2024 Diego Hernandez
		,TRY_CAST(enc.WEIGHT AS FLOAT) / 16 AS VisitCaseWeight -- Safely cast to FLOAT
		,TRY_CAST(enc.BMI AS FLOAT) AS VisitCaseBMI 
		,CASE WHEN lb.RESP_ANES_ID IS NULL THEN NULL ELSE CONCAT('5~',lb.RESP_ANES_ID) END as VisitCaseAnesthesiaProviderID --New Field Anesthesia provider for Styker project
		,(SELECT [NAME] FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[ZC_OR_ANESTH_TYPE] anz WHERE anz.ANESTHESIA_TYPE_C = lb.PRIMARY_ANES_TYPE_C) as VisitCaseAnesthesiaType --New Field AnesthesiaType name for Stryker 
		, orl.ASA_RATING_C as VisitCaseASARating --New Field ASA RATING
		,CASE WHEN lb.PRIMARY_PHYSICIAN_ID LIKE 'P%' THEN CAST(SUBSTRING(lb.PRIMARY_PHYSICIAN_ID, 2, LEN(lb.PRIMARY_PHYSICIAN_ID)) AS INT) ELSE CAST(lb.PRIMARY_PHYSICIAN_ID AS INT) END AS VisitCasePhysician --New Field Physician
		,lb.PRIMARY_CIRCULATOR_ID as VisitCaseCirculatingNurse --New Field Nurse
		,lb.PRIMARY_SURG_TECH_ID AS VisitCaseSurgTech --New Field Surg Tech
		,lv.FIRST_CASE_IN_RNG_YN AS VisitCaseFirstCaseofDay --New Field Flag First Case 
		,peh.DISCH_DISP_C AS VisitCaseDischargeDisposition -- new field Discharge Disposition
		,s.TEMPERATURE_PACU_FIRST as VisitCasePatientTemperaturePACUArrival --New Field PACU temperature
		,(SELECT zcadm.NAME FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_ADM_SOURCE zcadm WHERE peh.ADMIT_SOURCE_C = zcadm.ADMIT_SOURCE_C) as VisitCaseAdmissionStatus --New field VisitCaseAdmissionStatus
		,getdate() VisitCaseUpdatedDatetime
		,cp.PROC_DISPLAY_NAME as  VisitCasePrimaryScheduledProcedure
		,l.Lateralities as VisitCaseLaterality
		,orl.EMERG_STATUS_YN as VisitCaseEmergencyStatus

	--select distinct op.PROC_NAME
	from [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].OR_CASE orc
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].or_log orl on orc.or_case_id = orl.log_id
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].F_LOG_BASED lb ON lb.LOG_ID = orl.LOG_ID
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].clarity_loc loc on orc.loc_id = loc.loc_id
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].PAT_OR_ADM_LINK ol ON orc.OR_CASE_ID = ol.OR_CASELOG_ID
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].PAT_ENC enc ON ol.OR_LINK_CSN = enc.PAT_ENC_CSN_ID 
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_OR_SCHED_STATUS sts ON orc.SCHED_STATUS_C = sts.SCHED_STATUS_C
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].zc_or_status os on orl.status_c = os.status_c
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_OR_SERVICE svc ON orc.SERVICE_C = svc.SERVICE_C
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_PAT_CLASS pc ON orc.PAT_CLASS_C = pc.ADT_PAT_CLASS_C
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_OR_CANCEL_RSN can ON can.CANCEL_REASON_C = orc.CANCEL_REASON_C
		left join(
					select
						CASE_ID
					from [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].V_CASE_SCHEDULE_CHANGE
					where 
						RESCHED_TO_DATE is not null
					group by
						CASE_ID) csc on csc.CASE_ID = orc.or_case_id
		LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_PROC_NOT_PERF np ON np.PROC_NOT_PERF_C = orl.PROC_NOT_PERF_C
		LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].OR_CASE_ALL_PROC cp ON cp.OR_CASE_ID = orc.OR_CASE_ID and cp.LINE = 1
		LEFT JOIN #Laterality l ON l.VisitCaseID = orc.or_case_id
		LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[OR_PROC] op ON op.OR_PROC_ID = COALESCE(lb.PRIMARY_PROCEDURE_ID, cp.OR_PROC_ID)
		LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[OR_LOG_VIRTUAL] lv on lv.LOG_ID = orc.OR_CASE_ID
		LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].DM_SURGERY s ON s.LOG_ID = orc.OR_CASE_ID
		LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].PAT_ENC_HSP peh ON ol.OR_LINK_CSN = peh.PAT_ENC_CSN_ID
		LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].V_CASE_ON_TIME_START ot ON ot.case_id = orc.or_case_id
		LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[V_CASE_ROOM_TURNOVER] rt ON rt.CASE_ID = orc.or_case_id

		--left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].V_CASE_SCHEDULE_CHANGE csc on csc.CASE_ID = orc.OR_CASE_ID
	where 1=1 
	AND loc.serv_area_id in (430, 425); -- filter to only hpi and tpg while orgfilter is broken

	IF (SELECT COUNT(1) FROM @StagingTable) >= 10
	 BEGIN
        PRINT 'At least 10 records found. Proceeding to delete and reload.'
		DELETE FROM fact.VisitCases WHERE VisitCaseDatesourceID = 5;
		
		INSERT INTO fact.VisitCases(
	   [VisitCaseID]
      ,[VisitCaseDatesourceID]
      ,[VisitCaseSourceID]
      ,[VisitCaseVisitID]
      ,[VisitCaseCSN]
      ,[VisitCaseLocationID]
      ,[VisitCaseServiceDate]
      ,[VisitCaseScheduledDatetime]
      ,[VisitCaseScheduleStartDatetime]
      ,[VisitCaseScheduleEndDatetime]
      ,[VisitCaseBeginDatetime]
      ,[VisitCaseEndDatetime]
	  ,[VisitCaseRescheduledDate]
      ,[VisitCaseCancelledDate]
      ,[VisitCaseCancelledReason]
      ,[VisitCaseIsRescheduled]
      ,[VisitCaseServiceID]
      ,[VisitCaseORID]
      ,[VisitCaseRoomID]
      ,[VisitCaseScheduleStatus]
      ,[VisitCasePatientClass]
      ,[VisitCaseService]
      ,[VisitCasePrimaryProviderID]
      ,[VisitCaseTotalTimeNeeded]
      ,[VisitCaseLogStatus]
      ,[VisitCaseScheduledORBeginDatetime]
      ,[VisitCaseScheduledOREndDatetime]
      ,[VisitCasePreOpBeginDatetime]
      ,[VisitCasePreOpEndDatetime]
      ,[VisitCaseORBeginDatetime]
      ,[VisitCaseProcedureBeginDatetime]
      ,[VisitCaseProcedureEndDatetime]
      ,[VisitCaseOREndDatetime]
      ,[VisitCaseRecoveryBeginDatetime]
      ,[VisitCaseRecoveryEndDatetime]
      ,[VisitCasePhase2BeginDatetime]
      ,[VisitCasePhase2EndDatetime]
      ,[VisitCaseMinutesScheduledInOR]
      ,[VisitCaseMinutesInPreop]
      ,[VisitCaseMinutesInOR]
      ,[VisitCaseMinutesInRecovery]
      ,[VisitCaseMinutesInPhase2]
	  ,[VisitCaseSetupMinutes]
	  ,[VisitCaseCleanupMinutes]
	  ,[VisitCaseScheduledTurnoverDuration]
	  ,[VisitCaseRoomTurnoverDuration]
	  ,[VisitCaseProcedureTurnoverDuration]
	  ,[VisitCaseMinutesLate]
	  ,[VisitCaseLateStart]
	  ,[VisitCaseMinutesOverrun] 
	  ,[VisitCaseLenghtDifference]
	  ,[VisitCaseLenghtDifferencePercent]
	  ,[VisitCaseLengthAccuracy]
      ,[VisitCasePrimaryProcedure]
      ,[VisitCaseNotPerformedReason]
      ,[VisitCaseNotPerformedComment]
	  ,[VisitCaseHeight]
	  ,[VisitCaseWeight]
	  ,[VisitCaseBMI]
	  ,[VisitCaseAnesthesiaProviderID]
	  ,[VisitCaseAnesthesiaType]
	  ,[VisitCaseASARating]
	  ,[VisitCasePhysician] 
	  ,[VisitCaseCirculatingNurse] 
	  ,[VisitCaseSurgTech] 
	  ,[VisitCaseFirstCaseofDay]
	  ,[VisitCaseDischargeDisposition]
	  ,[VisitCasePatientTemperaturePACUArrival]
	  ,[VisitCaseAdmissionStatus]
      ,[VisitCaseUpdatedDatetime]
	  ,[VisitCasePrimaryScheduledProcedure]
	  ,[VisitCaseLaterality]
	  ,[VisitCaseEmergencyStatus]
	  )
	  SELECT
	  [VisitCaseID]
      ,[VisitCaseDatesourceID]
      ,[VisitCaseSourceID]
      ,[VisitCaseVisitID]
      ,[VisitCaseCSN]
      ,[VisitCaseLocationID]
      ,[VisitCaseServiceDate]
      ,[VisitCaseScheduledDatetime]
      ,[VisitCaseScheduleStartDatetime]
      ,[VisitCaseScheduleEndDatetime]
      ,[VisitCaseBeginDatetime]
      ,[VisitCaseEndDatetime]
	  ,[VisitCaseRescheduledDate]
      ,[VisitCaseCancelledDate]
      ,[VisitCaseCancelledReason]
      ,[VisitCaseIsRescheduled]
      ,[VisitCaseServiceID]
      ,[VisitCaseORID]
      ,[VisitCaseRoomID]
      ,[VisitCaseScheduleStatus]
      ,[VisitCasePatientClass]
      ,[VisitCaseService]
      ,[VisitCasePrimaryProviderID]
      ,[VisitCaseTotalTimeNeeded]
      ,[VisitCaseLogStatus]
      ,[VisitCaseScheduledORBeginDatetime]
      ,[VisitCaseScheduledOREndDatetime]
      ,[VisitCasePreOpBeginDatetime]
      ,[VisitCasePreOpEndDatetime]
      ,[VisitCaseORBeginDatetime]
      ,[VisitCaseProcedureBeginDatetime]
      ,[VisitCaseProcedureEndDatetime]
      ,[VisitCaseOREndDatetime]
      ,[VisitCaseRecoveryBeginDatetime]
      ,[VisitCaseRecoveryEndDatetime]
      ,[VisitCasePhase2BeginDatetime]
      ,[VisitCasePhase2EndDatetime]
      ,[VisitCaseMinutesScheduledInOR]
      ,[VisitCaseMinutesInPreop]
      ,[VisitCaseMinutesInOR]
      ,[VisitCaseMinutesInRecovery]
      ,[VisitCaseMinutesInPhase2]
	  ,[VisitCaseSetupMinutes]
	  ,[VisitCaseCleanupMinutes]
	  ,[VisitCaseScheduledTurnoverDuration]
	  ,[VisitCaseRoomTurnoverDuration]
	  ,[VisitCaseProcedureTurnoverDuration]
	  ,[VisitCaseMinutesLate]
	  ,[VisitCaseLateStart]
	  ,[VisitCaseMinutesOverrun] 
	  ,[VisitCaseLenghtDifference]
	  ,[VisitCaseLenghtDifferencePercent]
	  ,[VisitCaseLengthAccuracy]
      ,[VisitCasePrimaryProcedure]
      ,[VisitCaseNotPerformedReason]
      ,[VisitCaseNotPerformedComment]
	  ,[VisitCaseHeight]
	  ,[VisitCaseWeight]
	  ,[VisitCaseBMI]
	  ,[VisitCaseAnesthesiaProviderID]
	  ,[VisitCaseAnesthesiaType]
	  ,[VisitCaseASARating]
	  ,[VisitCasePhysician] 
	  ,[VisitCaseCirculatingNurse] 
	  ,[VisitCaseSurgTech] 
	  ,[VisitCaseFirstCaseofDay]
	  ,[VisitCaseDischargeDisposition]
	  ,[VisitCasePatientTemperaturePACUArrival]
	  ,[VisitCaseAdmissionStatus]
      ,[VisitCaseUpdatedDatetime]
	  ,[VisitCasePrimaryScheduledProcedure]
	  ,[VisitCaseLaterality]
	  ,[VisitCaseEmergencyStatus]
	  FROM @StagingTable;
	  END
   ELSE
   BEGIN
		PRINT 'Less than 10 records in the staging table. Ending job without delete and reload...'
   END

END;




	--and svc.NAME = 'ENT'
	--and orc.surgery_date between '8/1/2023' and '8/31/2023'
	
	--order by orc.surgery_date
	--order by VisitCaseServiceDate desc

	--SELECT * FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].OR_LOG where LOG_ID IN (2059431,2059434,2054202,2049700,2070023)
	
	--SELECT * FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].F_LOG_BASED where LOG_ID IN (2059431,2059434,2054202,2049700,2070023)

		--	select top 100 *  from [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].V_CASE_ON_TIME_START

		--select top 100 *  from [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[OR_LOG_VIRTUAL]

		--select top 100
		--	ld.*
		--	,zc.NAME
		--from [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[OR_LOG_DURATIONS] ld
		--	left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_CASE_DURATIONS zc on zc.CASE_DURATION_C = ld.DURATION_C
		--	where ld.LOG_ID = '2462557'

		--	select top 100
		--	te.*
		--	,zc.NAME
		--from [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[OR_LOG_TIMING_EVENTS] te
		--	left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_OR_TIMING_EVENT zc on zc.TIMING_EVENT_C = te.TIMING_EVENT_C
		--	where te.LOG_ID = '2462557'
GO
