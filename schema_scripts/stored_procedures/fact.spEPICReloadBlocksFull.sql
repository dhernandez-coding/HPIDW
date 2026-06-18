CREATE PROCEDURE fact.spEPICReloadBlocksFull as
		
/* 
-- =============================================
-- Author:		Eric Silvestri
-- Create date: Mar 16 2026  2:57PM
-- Edit date:   
-- Description:	FULL reload for fact.Blocks from EPIC
-- ============================================= 
*/
BEGIN

/*-----INSERT INTO @StagingTable-----*/
	PRINT 'Creating @StagingTable....'
	DECLARE @StagingTable table 
	(BlockID varchar(100)
	,BlockDatasourceID int
	,BlockRoomID varchar(100)
	,BlockRoomSourceID varchar(100)
	,BlcokRoomName varchar(100)
	,BlockScheduleDate datetime
	,BlockScheduleStartTime datetime
	,BlockScheduleEndTime datetime
	,BlockStartTime datetime
	,BlockEndTime datetime
	,BlockUpdatedStartTime datetime
	,BlockUpdatedEndTime datetime
	,BlockModifiedDate datetime
	,BlockScheduleSlotType varchar(100)
	,BlockScheduleProviderID varchar(100)
	,BlockScheduleBlockKey varchar(100)
	,BlockOriginalName varchar(100)
	,BlockCurrentName varchar(100)
	,BlockReleaseReason varchar(100)
	,BlockModifiedReason varchar(100)
	,BlockScheduleComments varchar(100)
	,BlockDaysSinceRelease int
	,BlockReleasedTimely bit
	,BlockIsActive bit
	,BlockUpdatedDatetime datetime
	)


IF OBJECT_ID(N'tempdb..#TempBlockChanges') IS NOT NULL
BEGIN
DROP TABLE #TempBlockChanges
END

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

)
	SELECT 
		*
		,CASE WHEN BlockSequence = 1 THEN 1 
			ELSE 0 END AS BlockIsActive
		,GETDATE() AS BlockUpdateDateTime
	INTO #TempBlockChanges
	FROM x
	WHERE BlockAlreadyPerformed = 0 --and BlockSequence = 1
	ORDER BY
	    BlockDate,
		BlockRoomID,
	    BlockStartTime,
	    BlockEndTime,
	    BlockModifiedDate DESC;

	
	PRINT 'Inserting records from Datasource into @StagingTable....'
	INSERT INTO @StagingTable 
	(BlockID
	,BlockDatasourceID
	,BlockRoomID
	,BlockRoomSourceID
	,BlcokRoomName
	,BlockScheduleDate
	,BlockScheduleStartTime
	,BlockScheduleEndTime
	,BlockStartTime
	,BlockEndTime
	,BlockUpdatedStartTime
	,BlockUpdatedEndTime
	,BlockModifiedDate
	,BlockScheduleSlotType
	,BlockScheduleProviderID
	,BlockScheduleBlockKey
	,BlockOriginalName
	,BlockCurrentName
	,BlockReleaseReason
	,BlockModifiedReason
	,BlockScheduleComments
	,BlockDaysSinceRelease
	,BlockReleasedTimely
	,BlockIsActive
	,BlockUpdatedDatetime
	)

SELECT 
		CASE WHEN b.BlockStartTime IS NULL 
			THEN CONCAT('5~',rt.BLOCK_KEY,'~',r.RoomSourceID,'~',FORMAT(rt.SLOT_START_TIME, 'yyyyMMddHHmm'),'~',FORMAT(rt.SLOT_END_TIME, 'yyyyMMddHHmm')) 
			ELSE CONCAT('5~',rt.BLOCK_KEY,'~',r.RoomSourceID,'~',FORMAT(b.BlockStartTime, 'yyyyMMddHHmm'),'~',FORMAT(b.BlockEndTime, 'yyyyMMddHHmm'))
				END AS BlockID
		,5 AS BlockDataSourceID
		,r.RoomID AS BlockRoomID
		,r.RoomSourceID AS BlockRoomSourceID
		,r.RoomName AS BlockRoomName
		,rt.SCHEDULE_DATE AS BlockScheduleDate
		,rt.SLOT_START_TIME AS BlockScheduleStartTime
		,rt.SLOT_END_TIME AS BlockScheduleEndTime
		,b.BlockStartTime
		,b.BlockEndTime
		,CASE WHEN b.BlockStartTime IS NULL AND rt.SLOT_TYPE_NM IN ('Service','Surgeon')
			THEN rt.SLOT_START_TIME ELSE b.BlockStartTime END AS BlockUpdatedStartTime
		,CASE WHEN b.BlockEndTime IS NULL AND rt.SLOT_TYPE_NM IN ('Service','Surgeon')
			THEN rt.SLOT_END_TIME ELSE b.BlockEndTime END AS BlockUpdatedEndTime
		,BlockModifiedDate
		,rt.SLOT_TYPE_NM AS BlockScheduleSlotType
		,rt.SURGEON_ID AS BlockScheduleProviderID
		,rt.BLOCK_KEY AS BlockScheduleBlockKey
		,CASE WHEN rt.SLOT_TYPE_NM = 'Unblocked' THEN 'Unblocked'
			ELSE p.ProviderFullName END AS BlockOriginalName

		,case WHEN b.BlockModifiedReason = 'Manual Block Release'
				THEN b.BlockTo
			WHEN b.BlockModifiedReason = 'Automatic Block Release'
				THEN p.ProviderFullName
			WHEN b.BlockTo IS NULL AND rt.SLOT_TYPE_NM = 'Unblocked'
				THEN 'Unblocked'
			WHEN b.BlockTo IS NOT NULL 
				THEN b.BlockTo
			ELSE p.ProviderFullName END AS BlockCurrentName
		,b.BlockReleaseReason AS BlockReleaseReason
		,CASE WHEN b.BlockModifiedReason = 'Manual Block Release'
				THEN 'Manual Block Release'
			WHEN rt.SLOT_TYPE_NM = 'Surgeon' AND rt.SCHEDULE_DATE < GETDATE()
				THEN 'Automatic Block Release - Performed'
			ELSE b.BlockModifiedReason END AS BlockModifiedReason
		--, rt.GROUP_ID as RoomScheduleGroupID
		,rt.COMMENTS AS BlockScheduleComments
		,b.BlockDaysSinceRelease
		,b.BlockReleasedTimely
		,1 AS BlockIsActive
		,GETDATE() AS BlockUpdatedDatetime
	FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].V_OR_ROOM_TEMPLATE rt 
		INNER JOIN hpidw.dim.Rooms r ON r.RoomDataSourceID = 5 AND r.RoomSourceID = rt.ROOM_ID and r.RoomIsOR = 1
		LEFT JOIN hpidw.dim.vProviders p ON p.ProviderSourceID = rt.SURGEON_ID
		LEFT JOIN #TempBlockChanges b ON b.BlockRoomID = r.RoomSourceID
									AND b.BlockStartTime = rt.SLOT_START_TIME
									AND b.BlockEndTime >= rt.SLOT_END_TIME
									AND b.BlockSequence = 1
	WHERE 1=1 
		AND rt.SCHEDULE_DATE >= DATEFROMPARTS(YEAR(GETDATE())-2,1,1) /*Beginning of Last Year forward*/
		AND rt.SCHEDULE_DATE < DATEADD(DAY,90,getdate()) /*90 Days Forward*/
		--and rt.SCHEDULE_DATE = '2026-01-07'
		 --and rt.BLOCK_KEY = 'SRG-100396' and r.RoomSourceID = '10720040' and FORMAT(rt.SLOT_START_TIME, 'yyyyMMddHHmm') = '202407040700' and FORMAT(rt.SLOT_END_TIME, 'yyyyMMddHHmm') = '202407041200'
		order by rt.SLOT_START_TIME

IF (SELECT COUNT(1) FROM @StagingTable) >= 10 
	BEGIN 
	PRINT 'At least 10 records exist in the staging table.  Proceed with delete and reload...'

/*-----DELETE/DEACTIVATE old records----*/
	PRINT 'Deleting records in Datasource....'
	DELETE FROM fact.Blocks WHERE BlockDatasourceID = 5

/*-----UPDATE existing records----*/
/*----------Commented out for INCREMENTAL reload based on modified date range----------
	PRINT 'Updating records in Datasource from @StagingTable....'
	UPDATE target
	SET target.BlockID = source.BlockID
	,target.BlockDatasourceID = source.BlockDatasourceID
	,target.BlockRoomID = source.BlockRoomID
	,target.BlockRoomSourceID = source.BlockRoomSourceID
	,target.BlcokRoomName = source.BlcokRoomName
	,target.BlockScheduleDate = source.BlockScheduleDate
	,target.BlockScheduleStartTime = source.BlockScheduleStartTime
	,target.BlockScheduleEndTime = source.BlockScheduleEndTime
	,target.BlockStartTime = source.BlockStartTime
	,target.BlockEndTime = source.BlockEndTime
	,target.BlockUpdatedStartTime = source.BlockUpdatedStartTime
	,target.BlockUpdatedEndTime = source.BlockUpdatedEndTime
	,target.BlockModifiedDate = source.BlockModifiedDate
	,target.BlockScheduleSlotType = source.BlockScheduleSlotType
	,target.BlockScheduleProviderID = source.BlockScheduleProviderID
	,target.BlockScheduleBlockKey = source.BlockScheduleBlockKey
	,target.BlockOriginalName = source.BlockOriginalName
	,target.BlockCurrentName = source.BlockCurrentName
	,target.BlockReleaseReason = source.BlockReleaseReason
	,target.BlockModifiedReason = source.BlockModifiedReason
	,target.BlockScheduleComments = source.BlockScheduleComments
	,target.BlockDaysSinceRelease = source.BlockDaysSinceRelease
	,target.BlockReleasedTimely = source.BlockReleasedTimely
	,target.BlockIsActive = source.BlockIsActive
	,target.BlockUpdatedDatetime = source.BlockUpdatedDatetime
	
	FROM fact.Blocks target
		INNER JOIN @StagingTable source ON source.BlockID = target.BlockID
*/

/*-----INSERT new records-----*/
	PRINT 'Inserting new records in Datasource from @StagingTable....'
	INSERT INTO fact.Blocks
	(BlockID
	,BlockDatasourceID
	,BlockRoomID
	,BlockRoomSourceID
	,BlcokRoomName
	,BlockScheduleDate
	,BlockScheduleStartTime
	,BlockScheduleEndTime
	,BlockStartTime
	,BlockEndTime
	,BlockUpdatedStartTime
	,BlockUpdatedEndTime
	,BlockModifiedDate
	,BlockScheduleSlotType
	,BlockScheduleProviderID
	,BlockScheduleBlockKey
	,BlockOriginalName
	,BlockCurrentName
	,BlockReleaseReason
	,BlockModifiedReason
	,BlockScheduleComments
	,BlockDaysSinceRelease
	,BlockReleasedTimely
	,BlockIsActive
	,BlockUpdatedDatetime
	)

	SELECT
	source.BlockID
	,source.BlockDatasourceID
	,source.BlockRoomID
	,source.BlockRoomSourceID
	,source.BlcokRoomName
	,source.BlockScheduleDate
	,source.BlockScheduleStartTime
	,source.BlockScheduleEndTime
	,source.BlockStartTime
	,source.BlockEndTime
	,source.BlockUpdatedStartTime
	,source.BlockUpdatedEndTime
	,source.BlockModifiedDate
	,source.BlockScheduleSlotType
	,source.BlockScheduleProviderID
	,source.BlockScheduleBlockKey
	,source.BlockOriginalName
	,source.BlockCurrentName
	,source.BlockReleaseReason
	,source.BlockModifiedReason
	,source.BlockScheduleComments
	,source.BlockDaysSinceRelease
	,source.BlockReleasedTimely
	,source.BlockIsActive
	,source.BlockUpdatedDatetime
	
	FROM @StagingTable source
	--	LEFT JOIN fact.Blocks target ON target.BlockID = source.BlockID
	WHERE 1=1
	--	AND target.BlockID IS NULL 

	END

ELSE
	BEGIN
	PRINT 'Less than 10 records in the staging table. Ending job without delete and reload...'
	END

END
GO
