CREATE PROCEDURE [stg].[spEPICReloadDimRooms_Full] as
		
/* 
-- =============================================
-- Author:		Eric Silvestri
-- Create date: Jul 26 2024 11:01AM
-- Edit date:   
-- Description:	Full reload for dim.Rooms from EPIC
-- Edited by Diego Hernandez to add open query
-- ============================================= 
*/
BEGIN

/*-----INSERT INTO @StagingTable-----*/
	PRINT 'Creating @StagingTable....'
	DECLARE @StagingTable table 
	(RoomID varchar(50)
	,RoomDataSourceID int
	,RoomSourceID varchar(50)
	,RoomName varchar(200)
	,RoomLocationID varchar(50)
	,RoomIsOR bit
	,RoomIsActive bit
	,RoomUpdatedDateTime datetime
	)
	
	PRINT 'Inserting records from Datasource into @StagingTable....'
	INSERT INTO @StagingTable 
	(RoomID
	,RoomDataSourceID
	,RoomSourceID
	,RoomName
	,RoomLocationID
	,RoomIsOR
	,RoomIsActive
	,RoomUpdatedDateTime
	)

SELECT *
FROM OPENQUERY([CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM],
'
    SELECT
        CONCAT(''5~'', r.ROOM_ID) AS RoomID,
        5 AS RoomDataSourceID,
        r.ROOM_ID AS RoomSourceID,
        r.ROOM_NM AS RoomName,
        r.LOCATION_ID AS RoomLocationID,
        CASE 
            WHEN r.ROOM_NM LIKE (''%OR%'') THEN 1 
            ELSE 0 
        END AS RoomIsOR,
        NULL AS RoomIsActive,
        GETDATE() AS RoomUpdatedDateTime
    FROM [Clarity].[ORGFILTER].[V_OR_UTIL_ROOM_CASE_SUM] r
    WHERE 1=1 
      AND r.LOCATION_NM LIKE (''%HPI%'')
      AND r.ROOM_ID IS NOT NULL
    GROUP BY
        r.ROOM_ID,
        r.ROOM_NM,
        r.LOCATION_ID
') AS rooms;
	

IF (SELECT COUNT(1) FROM @StagingTable) >= 10 
	BEGIN 
	PRINT 'At least 10 records exist in the staging table.  Proceed with delete and reload...'

/*-----DELETE/DEACTIVATE old records----*/
	PRINT 'Deleting records in Datasource....'
	DELETE FROM dim.Rooms WHERE RoomDataSourceID = 5 --AND <Insert Incremental Date Column> between 2024-06-26 AND 2024-07-26

/*-----UPDATE existing records----*/
/*----------Commented out for INCREMENTAL reload based on modified date range----------
	PRINT 'Updating records in Datasource from @StagingTable....'
	UPDATE target
	SET target.RoomID = source.RoomID
	,target.RoomDataSourceID = source.RoomDataSourceID
	,target.RoomSourceID = source.RoomSourceID
	,target.RoomName = source.RoomName
	,target.RoomLocationID = source.RoomLocationID
	,target.RoomIsOR = source.RoomIsOR
	,target.RoomIsActive = source.RoomIsActive
	,target.RoomUpdatedDateTime = source.RoomUpdatedDateTime
	
	FROM dim.Rooms target
		INNER JOIN @StagingTable source ON source.RoomID = target.RoomID
*/

/*-----INSERT new records-----*/
	PRINT 'Inserting new records in Datasource from @StagingTable....'
	INSERT INTO dim.Rooms
	(RoomID
	,RoomDataSourceID
	,RoomSourceID
	,RoomName
	,RoomLocationID
	,RoomIsOR
	,RoomIsActive
	,RoomUpdatedDateTime
	)

	SELECT
	source.RoomID
	,source.RoomDataSourceID
	,source.RoomSourceID
	,source.RoomName
	,source.RoomLocationID
	,source.RoomIsOR
	,source.RoomIsActive
	,source.RoomUpdatedDateTime
	
	FROM @StagingTable source
	--	LEFT JOIN dim.Rooms target ON target.RoomID = source.RoomID
	WHERE 1=1
	--	AND target.RoomID IS NULL 

	END

ELSE
	BEGIN
	PRINT 'Less than 10 records in the staging table. Ending job without delete and reload...'
	END

END


--################################################## OLD QUERY ############################# 

--/*-----INSERT INTO @StagingTable-----*/
--	PRINT 'Creating @StagingTable....'
--	DECLARE @StagingTable table 
--	(RoomID varchar(50)
--	,RoomDataSourceID int
--	,RoomSourceID varchar(50)
--	,RoomName varchar(200)
--	,RoomLocationID varchar(50)
--	,RoomIsOR bit
--	,RoomIsActive bit
--	,RoomUpdatedDateTime datetime
--	)
	
--	PRINT 'Inserting records from Datasource into @StagingTable....'
--	INSERT INTO @StagingTable 
--	(RoomID
--	,RoomDataSourceID
--	,RoomSourceID
--	,RoomName
--	,RoomLocationID
--	,RoomIsOR
--	,RoomIsActive
--	,RoomUpdatedDateTime
--	)

--	SELECT
--	CONCAT('5~',r.ROOM_ID) AS RoomID
--	,5 AS RoomDataSourceID
--	,r.ROOM_ID AS RoomSourceID
--	,r.ROOM_NM AS RoomName
--	,r.LOCATION_ID AS RoomLocationID
--	,CASE WHEN r.ROOM_NM like ('%OR%') THEN 1 ELSE 0 END AS RoomIsOR
--	,NULL AS RoomIsActive
--	,GETDATE() AS RoomUpdatedDateTime
--	FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].V_OR_UTIL_ROOM_CASE_SUM r
--	WHERE 1=1 and r.LOCATION_NM like ('%HPI%') and ROOM_ID IS NOT NULL
--	GROUP BY
--		r.ROOM_ID
--		,r.ROOM_NM
--		,r.LOCATION_ID
	

--IF (SELECT COUNT(1) FROM @StagingTable) >= 10 
--	BEGIN 
--	PRINT 'At least 10 records exist in the staging table.  Proceed with delete and reload...'

--/*-----DELETE/DEACTIVATE old records----*/
--	PRINT 'Deleting records in Datasource....'
--	DELETE FROM dim.Rooms WHERE RoomDataSourceID = 5 --AND <Insert Incremental Date Column> between 2024-06-26 AND 2024-07-26

--/*-----UPDATE existing records----*/
--/*----------Commented out for INCREMENTAL reload based on modified date range----------
--	PRINT 'Updating records in Datasource from @StagingTable....'
--	UPDATE target
--	SET target.RoomID = source.RoomID
--	,target.RoomDataSourceID = source.RoomDataSourceID
--	,target.RoomSourceID = source.RoomSourceID
--	,target.RoomName = source.RoomName
--	,target.RoomLocationID = source.RoomLocationID
--	,target.RoomIsOR = source.RoomIsOR
--	,target.RoomIsActive = source.RoomIsActive
--	,target.RoomUpdatedDateTime = source.RoomUpdatedDateTime
	
--	FROM dim.Rooms target
--		INNER JOIN @StagingTable source ON source.RoomID = target.RoomID
--*/

--/*-----INSERT new records-----*/
--	PRINT 'Inserting new records in Datasource from @StagingTable....'
--	INSERT INTO dim.Rooms
--	(RoomID
--	,RoomDataSourceID
--	,RoomSourceID
--	,RoomName
--	,RoomLocationID
--	,RoomIsOR
--	,RoomIsActive
--	,RoomUpdatedDateTime
--	)

--	SELECT
--	source.RoomID
--	,source.RoomDataSourceID
--	,source.RoomSourceID
--	,source.RoomName
--	,source.RoomLocationID
--	,source.RoomIsOR
--	,source.RoomIsActive
--	,source.RoomUpdatedDateTime
	
--	FROM @StagingTable source
--	--	LEFT JOIN dim.Rooms target ON target.RoomID = source.RoomID
--	WHERE 1=1
--	--	AND target.RoomID IS NULL 

--	END

--ELSE
--	BEGIN
--	PRINT 'Less than 10 records in the staging table. Ending job without delete and reload...'
--	END

--END
GO
