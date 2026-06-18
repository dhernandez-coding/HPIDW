CREATE PROCEDURE [dim].[zDEPRECATED_spReloadEPICSchedules_Full] AS

/* 
-- =============================================
-- Author:		Eric Silvestri
-- Create date: Jul 26 2024 11:01AM
-- Edit date:  9/11/26 - Chris Cross - Renamed [stg].[spEPICReloadDimSchedules_Full]  
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
		,[ScheduleBlockName] varchar(100)
		,[ScheduleBlockKey] varchar(100)
		,[ScheduleRoomComments] varchar(100)
		,[ScheduleTimeSlotAMPMFlag] varchar(10)
		,[ScheduleTimeSlotUpdateDatetime] datetime
	)

	PRINT 'Creating temporary table #TEMP_Blocks....'
	SELECT 
		r.RoomID
		,r.RoomSourceID
		,rt.SCHEDULE_DATE as RoomScheduleDate
		,rt.SLOT_START_TIME as RoomScheduleStartTime
		,rt.SLOT_END_TIME as RoomScheduleEndTime
		,rt.SLOT_TYPE_NM as RoomScheduleSlotType
		,rt.SURGEON_ID as RoomScheduleProviderID
		,p.ProviderFullName as RoomScheduleBlockName
		--, rt.GROUP_ID as RoomScheduleGroupID
		,rt.BLOCK_KEY as RoomScheduleBlockKey
		,rt.COMMENTS as RoomScheduleComments
	INTO #TEMP_Blocks
	FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].V_OR_ROOM_TEMPLATE rt
		INNER JOIN hpidw.dim.Rooms r ON r.RoomDataSourceID = 5 AND r.RoomSourceID = rt.ROOM_ID and r.RoomIsOR = 1
		LEFT JOIN hpidw.dim.vProviders p ON p.ProviderSourceID = rt.SURGEON_ID
	WHERE 1=1
		AND rt.SCHEDULE_DATE >= DATEFROMPARTS(YEAR(GETDATE())-1,1,1) /*Beginning of Last Year forward*/
		AND rt.SCHEDULE_DATE < DATEADD(DAY,30,getdate()) /*30 Days Forward*/

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
		,[ScheduleBlockName]
		,[ScheduleBlockKey]
		,[ScheduleRoomComments]
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
		,CASE WHEN rt.RoomScheduleSlotType is not null AND rt.RoomScheduleSlotType <> 'Unblocked' THEN 'Blocked' 
				WHEN DATEPART(HOUR,s.ScheduleTimeSlotStartDatetime) < 5 OR DATEPART(HOUR,s.ScheduleTimeSlotStartDatetime) >= 18 THEN 'Unavailable' 
				ELSE 'Unblocked' 
			 END as ScheduleSlotAvailabilityType
		,rt.RoomScheduleStartTime
		,rt.RoomScheduleEndTime
		,rt.RoomScheduleProviderID
		,CASE WHEN rt.RoomScheduleBlockName IS NULL THEN 'Unblocked' ELSE rt.RoomScheduleBlockName END as RoomScheduleBlockName
		,rt.RoomScheduleBlockKey
		,rt.RoomScheduleComments
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
		WHERE r.RoomIsOR = 1 --and r.RoomID = '5~10720180' AND d.Date between '7/4/24' and '7/10/2024'
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
		,ScheduleBlockName
		,ScheduleBlockKey
		,ScheduleRoomComments
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
		,source.ScheduleBlockName
		,source.ScheduleBlockKey
		,source.ScheduleRoomComments
		,source.ScheduleTimeSlotAMPMFlag
		,source.ScheduleTimeSlotUpdateDatetime
	FROM @StagingTable source

	END
	ELSE
	BEGIN
	PRINT 'Less than 10 records in the staging table. Ending job without delete and reload...'
	END

	DROP TABLE #TEMP_Blocks

END
GO
