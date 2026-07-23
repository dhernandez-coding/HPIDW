CREATE VIEW [fact].[vVisitCases] as


WITH TempBlocks AS
(
    SELECT
          r.RoomID
        , r.RoomSourceID
        , rt.SCHEDULE_DATE AS RoomScheduleDate

        -- Build true DATETIME block start/end from date + time
        , DATEADD(
              SECOND,
              DATEDIFF(
                  SECOND,
                  CAST('00:00:00' AS TIME),
                  CAST(rt.SLOT_START_TIME AS TIME)
              ),
              CAST(rt.SCHEDULE_DATE AS DATETIME)
          ) AS RoomScheduleStartDateTime

        , DATEADD(
              SECOND,
              DATEDIFF(
                  SECOND,
                  CAST('00:00:00' AS TIME),
                  CAST(rt.SLOT_END_TIME AS TIME)
              ),
              CAST(rt.SCHEDULE_DATE AS DATETIME)
          ) AS RoomScheduleEndDateTime

        , rt.SLOT_TYPE_NM AS RoomScheduleSlotType
        , rt.SURGEON_ID AS RoomScheduleProviderID
        , p.ProviderFullName AS RoomScheduleBlockName
        , rt.BLOCK_KEY AS RoomScheduleBlockKey
        , rt.COMMENTS AS RoomScheduleComments
	FROM OPENQUERY(
        [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM],
        '
            SELECT
                  ROOM_ID
                , SCHEDULE_DATE
                , SLOT_START_TIME
                , SLOT_END_TIME
                , SLOT_TYPE_NM
                , SURGEON_ID
                , BLOCK_KEY
                , COMMENTS
            FROM CLARITY.ORGFILTER.V_OR_ROOM_TEMPLATE t
				LEFT JOIN CLARITY.DBO.OR_SER_ROOM r ON PROV_ID = t.ROOM_id
			WHERE 1=1
				and t.SCHEDULE_DATE >= ''1/1/2023''
				and LEFT (r.PROV_ABB, 3) IN (''CHS'',''CHN'') 
        '
    ) rt  
    INNER JOIN hpidw.dim.Rooms r
        ON r.RoomDataSourceID = 5
       AND r.RoomSourceID = rt.ROOM_ID
       AND r.RoomIsOR = 1
    LEFT JOIN hpidw.dim.vProviders p
        ON p.ProviderSourceID = rt.SURGEON_ID
),

 Turnover AS
(
    SELECT
          c.VisitCaseID
        , c.VisitCaseRoomID
        , c.VisitCaseORBeginDatetime
        , c.VisitCaseOREndDatetime
        , LEAD(c.VisitCaseORBeginDatetime) OVER
            (PARTITION BY c.VisitCaseRoomID ORDER BY c.VisitCaseORBeginDatetime) AS Next_ORBegin
        , LEAD(CAST(c.VisitCaseORBeginDatetime AS date)) OVER
            (PARTITION BY c.VisitCaseRoomID ORDER BY c.VisitCaseORBeginDatetime) AS Next_ORBeginDate
    FROM fact.VisitCases c
    WHERE c.VisitCaseORBeginDatetime IS NOT NULL
      AND c.VisitCaseOREndDatetime   IS NOT NULL
      AND c.VisitCaseScheduleStatus = 'Completed'
)


SELECT
	  vc.[VisitCaseID]
      ,[VisitCaseDatesourceID]
      ,[VisitCaseSourceID]
      ,[VisitCaseVisitID]
      ,[VisitCaseCSN]
      ,[VisitCaseLocationID]
	  ,l.LocationName as VisitCaseLocation
      ,[VisitCaseServiceDate]
      ,[VisitCaseScheduledDatetime]
      ,[VisitCaseScheduleStartDatetime]
      ,[VisitCaseScheduleEndDatetime]
      ,[VisitCaseBeginDatetime]
      ,[VisitCaseEndDatetime]
	  ,[VisitCaseRescheduledDate]
      ,[VisitCaseCancelledDate]
      ,CASE WHEN vc.VisitCaseServiceDate = vc.VisitCaseCancelledDate AND [VisitCaseCancelledReason] IS NULL 
		THEN 'No Reason Provided'
		ELSE [VisitCaseCancelledReason] END AS VisitCaseCancelledReason
      ,[VisitCaseIsRescheduled]
	  ,CASE WHEN vc.VisitCaseServiceDate = vc.VisitCaseCancelledDate THEN 'Y' ELSE 'N' END as VisitCaseSameDayCancellation
      ,CASE WHEN vc.VisitCaseService like 'Pain%' THEN '0~9' ELSE sl.ServiceLineID END as VisitCaseServiceLineID
      ,[VisitCaseORID]
      ,vc.[VisitCaseRoomID]
	  ,r.RoomName as VisitCaseRoom
      ,[VisitCaseScheduleStatus]
      ,[VisitCasePatientClass]
      ,[VisitCaseService]
	  ,CASE WHEN tb.RoomScheduleBlockName IS NULL THEN 'Unblocked' ELSE tb.RoomScheduleBlockName END AS VisitCaseScheduledBlockName
	  --,CASE WHEN b.BlockCurrentName IS NULL THEN 'Unblocked' ELSE b.BlockCurrentName END AS VisitCaseScheduledBlockName
	  ,[VisitCasePrimaryProviderID]
	  ,p.ProviderFullName
      ,[VisitCaseTotalTimeNeeded]
      ,[VisitCaseLogStatus]
	  ,tb.RoomScheduleStartDateTime  
	  ,tb.RoomScheduleEndDateTime
      ,[VisitCaseScheduledORBeginDatetime]
      ,[VisitCaseScheduledOREndDatetime]
      ,[VisitCasePreOpBeginDatetime]
      ,[VisitCasePreOpEndDatetime]
      ,vc.[VisitCaseORBeginDatetime]
      ,[VisitCaseProcedureBeginDatetime]
      ,[VisitCaseProcedureEndDatetime]
      ,vc.[VisitCaseOREndDatetime]
      ,[VisitCaseRecoveryBeginDatetime]
      ,[VisitCaseRecoveryEndDatetime]
      ,[VisitCasePhase2BeginDatetime]
      ,[VisitCasePhase2EndDatetime]
      ,[VisitCaseMinutesScheduledInOR]
      ,[VisitCaseMinutesInPreop]
      ,[VisitCaseMinutesInOR]
	  ,DATEDIFF(MINUTE,[VisitCaseProcedureBeginDatetime],[VisitCaseProcedureEndDatetime]) VisitCaseMinutesInProcedure
      ,[VisitCaseMinutesInRecovery]
      ,[VisitCaseMinutesInPhase2]
	  ,[VisitCaseSetupMinutes]
	  ,[VisitCaseCleanupMinutes]
	  ,[VisitCaseScheduledTurnoverDuration]
	  ,[VisitCaseRoomTurnoverDuration]
	  ,[VisitCaseProcedureTurnoverDuration]
	  ,CASE WHEN t.Next_ORBegin IS NULL THEN NULL
        WHEN t.Next_ORBeginDate <> CAST(t.VisitCaseORBeginDatetime AS date) THEN NULL
        ELSE DATEDIFF(minute, t.VisitCaseOREndDatetime, t.Next_ORBegin)
		  END AS VisitCaseTurnoverMinutes
	  ,[VisitCaseMinutesLate]
	  ,[VisitCaseLateStart]
	  ,[VisitCaseMinutesOverrun] 
	  ,vc.VisitCaseMinutesScheduledInOR-vc.VisitCaseMinutesInOR as VisitCaseLenghtDifference
	  --,[VisitCaseLenghtDifference]
	  ,[VisitCaseLenghtDifferencePercent]
	  ,[VisitCaseLengthAccuracy]
	  ,t.Next_ORBegin AS VisitCaseNextORBeginDatetime
      ,[VisitCasePrimaryProcedure]
	  ,CASE WHEN DATEDIFF(MINUTE, vc.VisitCaseScheduleStartDatetime, vc.VisitCaseORBeginDatetime)<0 THEN 'Early Start'
		WHEN DATEDIFF(MINUTE, vc.VisitCaseScheduleStartDatetime, vc.VisitCaseORBeginDatetime) between (0) and (5) THEN 'On Time'
		WHEN DATEDIFF(MINUTE, vc.VisitCaseScheduleStartDatetime, vc.VisitCaseORBeginDatetime)> 5 THEN 'Late Start'
			END as VisitCaseOnTimeStartStatus 
	  ,CASE WHEN vc.VisitCaseLengthAccuracy = 'Y' THEN 'Accurate'
		WHEN vc.VisitCaseMinutesScheduledInOR-vc.VisitCaseMinutesInOR < -30 THEN '30 Mins Underscheduled'
		WHEN vc.VisitCaseMinutesScheduledInOR-vc.VisitCaseMinutesInOR < -50 THEN '15 Mins Underscheduled'
		WHEN vc.VisitCaseMinutesScheduledInOR-vc.VisitCaseMinutesInOR > 30 THEN '30 Mins Overscheduled'
		WHEN vc.VisitCaseMinutesScheduledInOR-vc.VisitCaseMinutesInOR > 15 THEN '15 Mins Overscheduled'
			END as VisitCaseAccuracyStatus
      ,[VisitCaseFirstCaseofDay]
      ,[VisitCaseNotPerformedReason]
      ,[VisitCaseNotPerformedComment]
	  ,[VisitCaseAnesthesiaType]
      ,[VisitCaseASARating]
      ,[VisitCasePhysician]
      ,[VisitCaseCirculatingNurse]
      ,[VisitCaseSurgTech]
      ,[VisitCasePatientTemperaturePACUArrival]
      ,[VisitCaseAnesthesiaProviderID]
      ,[VisitCaseAdmissionStatus]
      ,[VisitCaseDischargeDisposition]
      ,[VisitCaseUpdatedDatetime]
FROM [HPIDW].[fact].[VisitCases] vc
	LEFT JOIN dim.vProviders p ON p.ProviderID = vc.VisitCasePrimaryProviderID
	LEFT JOIN dim.Specialties spc ON spc.SpecialtyID = p.ParentSpecialtyID
	LEFT JOIN dim.ServiceLines sl ON sl.ServiceLineName = spc.SpecialtyName /*Service Lines matched to Specialty by Name*/
	LEFT JOIN dim.Rooms r ON r.RoomID = vc.VisitCaseRoomID
	LEFT JOIN dim.Locations l ON l.LocationID = vc.VisitCaseLocationID
	LEFT JOIN Turnover t ON t.VisitCaseID = vc.VisitCaseID
	LEFT JOIN TempBlocks tb ON tb.RoomID = vc.VisitCaseRoomID
		 AND vc.VisitCaseScheduleStartDatetime >= tb.RoomScheduleStartDateTime  --RoomScheduleStartTime
		 AND vc.VisitCaseScheduleEndDatetime   <= tb.RoomScheduleEndDateTime
GO
