CREATE PROCEDURE [stg].[spEPICReloadDimSchedules_Full] AS

/* 
-- =============================================
-- Author:		Eric Silvestri
-- Create date: Jul 26 2024 11:01AM
-- Edit date:   
-- Description:	Full reload for dim.Schedules from EPIC
-- ============================================= 
*/
BEGIN

	/*-----INSERT INTO @StagingTable-----*/
	PRINT 'Creating @StagingTable....'
	DECLARE @StagingTable table 
	(	[ScheduleID] [int] IDENTITY(1,1)
		,[ScheduleDataSourceID] int
		,[ScheduleRoomID] varchar(100)
		,[ScheduleRoomSourceID] varchar(100)
		,[ScheduleRoomName] varchar(100)
		,[ScheduleLocationID] varchar(100)
		,[ScheduleLocationName] varchar(100)
		,[ScheduleDate] datetime
		,[ScheduleDOWInMonth] int
		,[ScheduleWeekDayName] varchar(100)
		,[ScheduleWeekDayOrder] int
		,[ScheduleTimeSlotName] varchar(100)
		,[ScheduleTimeSlotStartDatetime] datetime
		,[ScheduleTimeSlotEndDatetime] datetime
		,[ScheduleTimeSlotMinutes] int
		,[ScheduleSlotAvailabilityType] varchar(100)
		,[ScheduleRoomStartTime] datetime
		,[ScheduleRoomEndTime] datetime
		,[ScheduleRoomProviderID] varchar(100)
		,[ScheduleOriginalBlockName] varchar(100)
		,[ScheduleCurrentBlockName] varchar(100)
		,[ScheduleBlockKey] varchar(100)
		,[ScheduleRoomComments] varchar(100)
		,[ScheduleBlockModifiedReason] varchar(100)
		,[ScheduleBlockDaysSinceRelease] int
		,[ScheduleBlockReleasedTimely] int
		,[ScheduleTimeSlotAMPMFlag] varchar(10)
		,[ScheduleTimeSlotUpdateDatetime] datetime
	)

	PRINT 'Creating temporary table #TEMP_Blocks....'

	;WITH x AS
(
    SELECT 
          o.RECORD_ID	AS BlockID
		, o.SER_RECORD_ID AS BlockRoomID
		, r.RoomName
		, o.TEMPLATE_DT      AS BlockDate
		--,l.PRIMARY_PHYS_ID
		,z2.Name AS BlockFromType
		,z1.NAME AS BlockToType
		,CASE WHEN o.FROM_BLK_ID = 2 THEN 'Unblocked' 
			ELSE p1.ProviderFullName END AS BlockFrom
		,CASE WHEN (o.TO_BLK_ID IS NULL AND zm.NAME = 'Manual Block Release') 
				THEN 'Unblocked'
			WHEN l.PRIMARY_PHYS_ID IS NOT NULL
				THEN p1.ProviderFullName
			WHEN o.TO_BLK_ID = 2 THEN 'Unblocked' 
			ELSE p.ProviderFullName END AS BlockTo
        , z.NAME        AS BlockReleaseReason
        ,CASE WHEN l.PRIMARY_PHYS_ID IS NOT NULL
				THEN 'Automatic Block Release - Performed'
			WHEN z2.Name = 'Service'
				THEN 'Automatic Block Release - Service'
			ELSE zm.NAME END  AS BlockModifiedReason
        ,o.BLOCK_START_INST AS BlockStartTime
        ,o.BLOCK_END_INST   AS BlockEndTime
        ,o.MOD_INST         AS BlockModifiedDate
		,CASE WHEN zm.NAME = 'Manual Block Release' 
			THEN o.REL_DAYS_IN_ADVANC
				ELSE NULL END AS BlockDaysSinceRelease
		,CASE WHEN zm.NAME = 'Manual Block Release' AND o.REL_DAYS_IN_ADVANC >= 3 
			THEN 1 
			WHEN zm.NAME = 'Manual Block Release' AND o.REL_DAYS_IN_ADVANC < 3  
			THEN 0 ELSE NULL END AS BlockReleasedTimely
		,CASE WHEN o.MOD_INST > o.BLOCK_START_INST  THEN 1
			ELSE 0 END AS BlockAlreadyPerformed
        ,ROW_NUMBER() OVER
          (
              PARTITION BY o.SER_RECORD_ID, o.TEMPLATE_DT, o.BLOCK_START_INST, o.BLOCK_END_INST
              ORDER BY o.MOD_INST DESC, o.RECORD_ID DESC
          ) AS BlockSequence
	FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].OR_OTA o 
		LEFT JOIN hpidw.dim.vProviders p ON p.ProviderSourceID = o.TO_BLOCK_ID
		LEFT JOIN hpidw.dim.vProviders p1 ON p1.ProviderSourceID = o.FROM_BLOCK_ID
		LEFT JOIN hpidw.dim.Rooms r ON r.RoomDataSourceID = 5 AND r.RoomSourceID = o.SER_RECORD_ID --and r.RoomIsOR = 1
		LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_RELEASE_REASON z ON z.release_reason_c = o.release_reason_c
		LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_MOD_TYPE zm ON zm.mod_type_c = o.mod_type_c
		LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_OR_OLD_BLOCK z2 on z2.OLD_BLOCK_TYPE_C = FROM_BLOCK_TYPE_C
		LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_OR_OLD_BLOCK z1 on z1.OLD_BLOCK_TYPE_C = TO_BLOCK_TYPE_C
		LEFT JOIN(SELECT 
			  	l.SURGERY_DATE
			  	,l.ROOM_ID
			  	,l.PRIMARY_PHYS_ID
			  FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].or_log l
			  WHERE LOG_ACCEPTED_YN = 'Y' 
			  GROUP BY
			  	l.SURGERY_DATE
			  	,l.ROOM_ID
			  	,l.PRIMARY_PHYS_ID) l ON l.SURGERY_DATE = o.TEMPLATE_DT
										AND l.ROOM_ID = o.SER_RECORD_ID
										AND l.PRIMARY_PHYS_ID = o.FROM_BLOCK_ID
			  WHERE r.RoomIsOR = 1
				--AND o.TEMPLATE_DT = '2026-01-07T00:00:00.000'
	--WHERE zm.NAME = 'Manual Block Release' and o.TEMPLATE_DT >= '2026-01-07T00:00:00.000'
)
	SELECT 
		*
		,CASE WHEN BlockSequence = 1 THEN 1 
			ELSE 0 END AS BlockIsActive
		,GETDATE() AS BlockUpdateDateTime
	INTO #TempBlockChanges
	FROM x
	--where BlockStartTime = '2023-06-19 07:00:00.000' --and BlockRoomID = '10720060'
	WHERE BlockAlreadyPerformed = 0 --and BlockSequence = 1
	ORDER BY
	    BlockDate,
		BlockRoomID,
	    BlockStartTime,
	    BlockEndTime,
	    BlockModifiedDate DESC;


	SELECT 
		r.RoomID
		,r.RoomSourceID
		,r.RoomName
		,rt.SCHEDULE_DATE AS RoomScheduleDate
		,rt.SLOT_START_TIME AS RoomScheduleStartTime
		,rt.SLOT_END_TIME AS RoomScheduleEndTime
		,b.BlockStartTime
		,b.BlockEndTime
		,CASE WHEN b.BlockStartTime IS NULL AND rt.SLOT_TYPE_NM IN ('Service','Surgeon')
			THEN rt.SLOT_START_TIME ELSE b.BlockStartTime END AS BlockUpdatedStartTime
		,CASE WHEN b.BlockEndTime IS NULL AND rt.SLOT_TYPE_NM IN ('Service','Surgeon')
			THEN rt.SLOT_END_TIME ELSE b.BlockEndTime END AS BlockUpdatedEndTime
		,BlockModifiedDate
		,rt.SLOT_TYPE_NM AS RoomScheduleSlotType
		,rt.SURGEON_ID AS RoomScheduleProviderID
		,rt.BLOCK_KEY AS RoomScheduleBlockKey
		,CASE WHEN rt.SLOT_TYPE_NM = 'Unblocked' THEN 'Unblocked'
			ELSE p.ProviderFullName END AS RoomOriginalBlockName

		,case WHEN b.BlockModifiedReason = 'Manual Block Release'
				THEN b.BlockTo
			WHEN b.BlockModifiedReason = 'Automatic Block Release'
				THEN p.ProviderFullName
			WHEN b.BlockTo IS NULL AND rt.SLOT_TYPE_NM = 'Unblocked'
				THEN 'Unblocked'
			WHEN b.BlockTo IS NOT NULL 
				THEN b.BlockTo
			ELSE p.ProviderFullName END AS RoomCurrentBlockName
		,b.BlockReleaseReason AS RoomBlockReleaseReason
		,CASE WHEN b.BlockModifiedReason = 'Manual Block Release'
				THEN 'Manual Block Release'
			WHEN rt.SLOT_TYPE_NM = 'Surgeon' AND rt.SCHEDULE_DATE < GETDATE()
				THEN 'Automatic Block Release - Performed'
			ELSE b.BlockModifiedReason END AS RoomBlockModifiedReason
		--, rt.GROUP_ID as RoomScheduleGroupID
		,rt.COMMENTS AS RoomScheduleComments
		,b.BlockDaysSinceRelease
		,b.BlockReleasedTimely
	INTO #TEMP_Blocks
	FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].V_OR_ROOM_TEMPLATE rt 
		INNER JOIN hpidw.dim.Rooms r ON r.RoomDataSourceID = 5 AND r.RoomSourceID = rt.ROOM_ID and r.RoomIsOR = 1
		LEFT JOIN hpidw.dim.vProviders p ON p.ProviderSourceID = rt.SURGEON_ID
		LEFT JOIN #TempBlockChanges b ON b.BlockRoomID = r.RoomSourceID
									AND b.BlockStartTime = rt.SLOT_START_TIME
									AND b.BlockEndTime >= rt.SLOT_END_TIME
									AND b.BlockSequence = 1
	WHERE 1=1 
		AND rt.SCHEDULE_DATE >= DATEFROMPARTS(YEAR(GETDATE())-1,1,1) /*Beginning of Last Year forward*/
		AND rt.SCHEDULE_DATE < DATEADD(DAY,30,getdate()) /*30 Days Forward*/
		--and rt.SCHEDULE_DATE = '2026-01-07'
		order by rt.SLOT_START_TIME


	
	--SELECT 
	--	r.RoomID
	--	,r.RoomSourceID
	--	,rt.SCHEDULE_DATE as RoomScheduleDate
	--	,rt.SLOT_START_TIME as RoomScheduleStartTime
	--	,rt.SLOT_END_TIME as RoomScheduleEndTime
	--	,rt.SLOT_TYPE_NM as RoomScheduleSlotType
	--	,rt.SURGEON_ID as RoomScheduleProviderID
	--	,p.ProviderFullName as RoomScheduleBlockName
	--	--, rt.GROUP_ID as RoomScheduleGroupID
	--	,rt.BLOCK_KEY as RoomScheduleBlockKey
	--	,rt.COMMENTS as RoomScheduleComments
	----INTO #TEMP_Blocks
	--FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].V_OR_ROOM_TEMPLATE rt 
	--	INNER JOIN hpidw.dim.Rooms r ON r.RoomDataSourceID = 5 AND r.RoomSourceID = rt.ROOM_ID and r.RoomIsOR = 1
	--	LEFT JOIN hpidw.dim.vProviders p ON p.ProviderSourceID = rt.SURGEON_ID
	--WHERE 1=1
	--	--AND rt.SCHEDULE_DATE >= DATEFROMPARTS(YEAR(GETDATE())-1,1,1) /*Beginning of Last Year forward*/
	--	--AND rt.SCHEDULE_DATE < DATEADD(DAY,30,getdate()) /*30 Days Forward*/
	--	and rt.SCHEDULE_DATE = '2026-01-07'


	PRINT 'Inserting records from Datasource into @StagingTable....'
	INSERT INTO @StagingTable 
	(	[ScheduleDataSourceID]
		,[ScheduleRoomID]
		,[ScheduleRoomSourceID]
		,[ScheduleRoomName]
		,[ScheduleLocationID]
		,[ScheduleLocationName]
		,[ScheduleDate]
		,[ScheduleDOWInMonth]
		,[ScheduleWeekDayName]
		,[ScheduleWeekDayOrder]
		,[ScheduleTimeSlotName]
		,[ScheduleTimeSlotStartDatetime]
		,[ScheduleTimeSlotEndDatetime]
		,[ScheduleTimeSlotMinutes]
		,[ScheduleSlotAvailabilityType]
		,[ScheduleRoomStartTime]
		,[ScheduleRoomEndTime]
		,[ScheduleRoomProviderID]
		,[ScheduleOriginalBlockName]
		,[ScheduleCurrentBlockName]
		,[ScheduleBlockKey]
		,[ScheduleRoomComments]
	    ,[ScheduleBlockModifiedReason]
		,[ScheduleBlockDaysSinceRelease]
		,[ScheduleBlockReleasedTimely]
		,[ScheduleTimeSlotAMPMFlag]
		,[ScheduleTimeSlotUpdateDatetime]
	)

	SELECT	
		'5' as ScheduleDataSourceID
		,s.RoomID as ScheduleRoomID
		,s.RoomSourceID as ScheduleRoomSourceID
		,s.RoomName as ScheduleRoomName
		,s.RoomLocationID as ScheduleLocationID
		,s.RoomLocationName as ScheduleLocationName
		,s.Date as ScheduleDate
		,s.DOWInMonth as ScheduleDOWInMonth
		,s.WeekDayName as ScheduleWeekDayName
		,s.Weekday as ScheduleWeekDayOrder
		,s.ScheduleTimeSlotName
		,s.ScheduleTimeSlotStartDatetime
		,s.ScheduleTimeSlotEndDatetime
		,s.ScheduleTimeSlotMinutes
		,CASE WHEN rt.RoomCurrentBlockName = 'Unblocked' THEN 'Unblocked'
			WHEN rt.RoomScheduleSlotType is not null AND rt.RoomScheduleSlotType <> 'Unblocked' THEN 'Blocked' 
			WHEN DATEPART(HOUR,s.ScheduleTimeSlotStartDatetime) < 5 OR DATEPART(HOUR,s.ScheduleTimeSlotStartDatetime) >= 18 THEN 'Unavailable' 
				ELSE 'Unblocked' 
			 END as ScheduleSlotAvailabilityType
		,rt.RoomScheduleStartTime AS ScheduleRoomStartTime
		,rt.RoomScheduleEndTime AS ScheduleRoomEndTime
		,rt.RoomScheduleProviderID AS ScheduleRoomProvider
		,rt.RoomOriginalBlockName AS ScheduleOriginalBlockName
		,rt.RoomCurrentBlockName AS ScheduleCurrentBlockName
		--,CASE WHEN rt.RoomScheduleBlockName IS NULL THEN 'Unblocked' ELSE rt.RoomScheduleBlockName END as RoomScheduleBlockName
		,rt.RoomScheduleBlockKey AS ScheduleBlockKey
		,rt.RoomScheduleComments AS ScheduleRoomComments
		,rt.RoomBlockModifiedReason AS ScheduleBlockModifiedReason
		,rt.BlockDaysSinceRelease AS ScheduleBlockDaysSinceRelease
		,rt.BlockReleasedTimely   AS ScheduleBlockReleasedTimely
		,CASE WHEN CAST(s.ScheduleTimeSlotStartDatetime as time) between '00:00:00' and '11:59:59' THEN 'AM' ELSE 'PM' END as ScheduleTimeSlotAMPMFlag
		,GETDATE() as ScheduleTimeSlotUpdateDatetime
	FROM (
		SELECT	
			r.RoomID
			,r.RoomSourceID
			,r.RoomName
			,r.RoomLocationID
			,l.LocationName as RoomLocationName
			,d.Date
			,d.DOWInMonth
			,d.WeekDayName
			,d.Weekday
			,ts.ScheduleTimeSlotName
			,convert(datetime, convert(char(8),d.Date, 112) + ' ' + convert(char(8),ts.ScheduleTimeSlotStartTime, 108)) as ScheduleTimeSlotStartDatetime
			,convert(datetime, convert(char(8),d.Date, 112) + ' ' + convert(char(8),ts.ScheduleTimeSlotEndTime, 108)) as ScheduleTimeSlotEndDatetime
			,ts.ScheduleTimeSlotMinutes
		FROM dim.Rooms r 
			LEFT JOIN HPIDW.dim.Dates d ON 1=1 
				AND d.Date >= DATEFROMPARTS(YEAR(GETDATE())-1,1,1) /*Beginning of Last Year forward*/
				AND d.Date < DATEFROMPARTS(YEAR(GETDATE())+1,1,1) /*End of this Year*/
			LEFT JOIN HPIDW.dim.ScheduleTimeSlots ts ON 1=1 AND ts.ScheduleTimeSlotInterval = 'Every 30 Minutes'
			LEFT JOIN HPIDW.dim.Locations l ON l.LocationSourceID = r.RoomLocationID
		WHERE r.RoomIsOR = 1 --AND d.Date = '2026-01-07'
	) s
	LEFT JOIN #TEMP_Blocks rt ON rt.RoomSourceID = s.RoomSourceID 
							AND rt.RoomScheduleDate = s.Date
							AND rt.RoomScheduleStartTime < s.ScheduleTimeSlotEndDatetime
							AND rt.RoomScheduleEndTime > s.ScheduleTimeSlotStartDatetime



	IF (SELECT COUNT(1) FROM @StagingTable) >= 10 
	BEGIN 
	PRINT 'At least 10 records exist in the staging table.  Proceed with delete and reload...'

	/*-----DELETE/DEACTIVATE old records----*/
	PRINT 'Deleting records in Datasource....'
	DELETE FROM dim.Schedules WHERE ScheduleDataSourceID = 5 --AND <Insert Incremental Date Column> between 2024-06-26 AND 2024-07-26

	/*-----UPDATE existing records----*/
	/*----------Commented out for INCREMENTAL reload based on modified date range----------
	PRINT 'Updating records in Datasource from @StagingTable....'
	UPDATE target
	SET target.ScheduleID =	source.ScheduleID
	,target.ScheduleLocationID source.ScheduleLocationID
	,target.ScheduleRoomID = source.ScheduleRoomID
	,target.ScheduleLocationName = source.ScheduleLocationName
	,target.ScheduleRoomName = source.ScheduleRoomName
	,target.ScheduleDate = source.ScheduleDate
	,target.ScheduleFromDateTime = source.ScheduleFromDateTime
	,target.ScheduleThroughDateTime = source.ScheduleThroughDateTime
	,target.ScheduleType = source.ScheduleType
	,target.ScheduleAvailabilityType = source.ScheduleAvailabilityType
	,target.ScheduleBlockName = source.ScheduleBlockName
	,target.ScheduleUtilizationStatus = source.ScheduleUtilizationStatus
	,target.ScheduleTimeSlotName = source.ScheduleTimeSlotName
	,target.ScheduleTimeSlotStartDatetime = source.ScheduleTimeSlotStartDatetime
	,target.ScheduleTimeSlotEndDatetime = source.ScheduleTimeSlotEndDatetime
	,target.ScheduleTotalMinutes = source.ScheduleTotalMinutes
	,target.ScheduleTimeSlotAMPMFlag = source.ScheduleTimeSlotAMPMFlag
	,target.ScheduleTimeSlotUpdateDatetime = source.ScheduleTimeSlotUpdateDatetime
	FROM dim.Schedules target
	INNER JOIN @StagingTable source ON source.ScheduleID = target.ScheduleID
	*/

	/*-----INSERT new records-----*/
	PRINT 'Inserting new records in Datasource from @StagingTable....'
	INSERT INTO hpidw.dim.Schedules
	(	ScheduleDataSourceID
		,ScheduleRoomID
		,ScheduleRoomSourceID
		,ScheduleRoomName
		,ScheduleLocationID
		,ScheduleLocationName
		,ScheduleDate
		,ScheduleDOWInMonth
		,ScheduleWeekDayName
		,ScheduleWeekDayOrder
		,ScheduleTimeSlotName
		,ScheduleTimeSlotStartDatetime
		,ScheduleTimeSlotEndDatetime
		,ScheduleTimeSlotMinutes
		,ScheduleSlotAvailabilityType
		,ScheduleRoomStartTime
		,ScheduleRoomEndTime
		,ScheduleRoomProviderID
		,ScheduleOriginalBlockName
		,ScheduleCurrentBlockName
		,ScheduleBlockKey
		,ScheduleRoomComments
	    ,ScheduleBlockModifiedReason
		,ScheduleBlockDaysSinceRelease
		,ScheduleBlockReleasedTimely
		,ScheduleTimeSlotAMPMFlag
		,ScheduleTimeSlotUpdateDatetime
	)

	SELECT
		source.ScheduleDataSourceID
		,source.ScheduleRoomID
		,source.ScheduleRoomSourceID
		,source.ScheduleRoomName
		,source.ScheduleLocationID
		,source.ScheduleLocationName
		,source.ScheduleDate
		,source.ScheduleDOWInMonth
		,source.ScheduleWeekDayName
		,source.ScheduleWeekDayOrder
		,source.ScheduleTimeSlotName
		,source.ScheduleTimeSlotStartDatetime
		,source.ScheduleTimeSlotEndDatetime
		,source.ScheduleTimeSlotMinutes
		,source.ScheduleSlotAvailabilityType
		,source.ScheduleRoomStartTime
		,source.ScheduleRoomEndTime
		,source.ScheduleRoomProviderID
		,source.ScheduleOriginalBlockName
		,source.ScheduleCurrentBlockName
		,source.ScheduleBlockKey
		,source.ScheduleRoomComments
	    ,source.ScheduleBlockModifiedReason
		,source.ScheduleBlockDaysSinceRelease
		,source.ScheduleBlockReleasedTimely
		,source.ScheduleTimeSlotAMPMFlag
		,source.ScheduleTimeSlotUpdateDatetime
	FROM @StagingTable source

	END
	ELSE
	BEGIN
	PRINT 'Less than 10 records in the staging table. Ending job without delete and reload...'
	END

	DROP TABLE #TempBlockChanges
	DROP TABLE #TEMP_Blocks


END
GO
