CREATE PROCEDURE dim.spReloadHeroPractices_INCREMENTAL as
		
/* 
-- =============================================
-- Author:		Chris Cross
-- Create date: Aug 20 2026 12:19PM
-- Edit date:   
-- Description:	INCREMENTAL reload for dim.Practices_Hero from HPI App
-- ============================================= 
*/
BEGIN

/*-----INSERT INTO @StagingTable-----*/
	PRINT 'Creating @StagingTable....'
	DECLARE @StagingTable table 
	(PracticeID varchar(100)
	,PracticeDataSourceID int
	,PracticeSourceID varchar(100)
	,PracticeName varchar(100)
	,PracticeAbbreviation varchar(30)
	,PracticeDataSource varchar(30)
	,PracticeCompany varchar(30)
	,PracticeIsActive bit
	,PracticeIsSameStore bit
	,PracticeUpdatedDatetime datetime
	,PracticeGLLocationID varchar(10)
	,PracticeGLLocation varchar(50)
	,PracticeGLPracticeID varchar(10)
	,PracticeSpecialty varchar(10)
	,PracticeSameStoreDate date
	)
	
	PRINT 'Inserting records from Datasource into @StagingTable....'
	INSERT INTO @StagingTable 
	(PracticeID
	,PracticeDataSourceID
	,PracticeSourceID
	,PracticeName
	,PracticeAbbreviation
	,PracticeDataSource
	,PracticeCompany
	,PracticeIsActive
	,PracticeIsSameStore
	,PracticeUpdatedDatetime
	,PracticeGLLocationID
	,PracticeGLLocation
	,PracticeGLPracticeID
	,PracticeSpecialty
	,PracticeSameStoreDate
	)

	SELECT
	[PracticeID],
	[PracticeDataSourceID],
	[PracticeSourceID],
	[PracticeName],
	[PracticeAbbreviation],
	[PracticeDataSource],
	[PracticeCompany],
	[PracticeIsActive],
	[PracticeIsSameStore],
	coalesce(try_cast([PracticeUpdatedDatetime] as Datetime), GetDate())  as [PracticeUpdatedDatetime],
	[PracticeGLLocationID],
	[PracticeGLLocation],
	[PracticeGLPracticeID],
	[PracticeSpecialty],
	coalesce(try_cast([PracticeSameStoreDate] as Datetime), GetDate()) as [PracticeSameStoreDate]
	
	
	
From hero.vPractices 
	WHERE 1=1

IF (SELECT COUNT(1) FROM @StagingTable) >= 10 
	BEGIN 
	PRINT 'At least 10 records exist in the staging table.  Proceed with delete and reload...'

/*-----DELETE/DEACTIVATE old records----*/
	PRINT 'Deleting records in Datasource....'
	DELETE FROM dim.Practices_Hero
/*-----UPDATE existing records----*/
/*----------Commented out for INCREMENTAL reload based on modified date range----------
	PRINT 'Updating records in Datasource from @StagingTable....'
	UPDATE target
	SET target.PracticeID = source.PracticeID
	,target.PracticeDataSourceID = source.PracticeDataSourceID
	,target.PracticeSourceID = source.PracticeSourceID
	,target.PracticeName = source.PracticeName
	,target.PracticeAbbreviation = source.PracticeAbbreviation
	,target.PracticeDataSource = source.PracticeDataSource
	,target.PracticeCompany = source.PracticeCompany
	,target.PracticeIsActive = source.PracticeIsActive
	,target.PracticeIsSameStore = source.PracticeIsSameStore
	,target.PracticeUpdatedDatetime = source.PracticeUpdatedDatetime
	,target.PracticeGLLocationID = source.PracticeGLLocationID
	,target.PracticeGLLocation = source.PracticeGLLocation
	,target.PracticeGLPracticeID = source.PracticeGLPracticeID
	,target.PracticeSpecialty = source.PracticeSpecialty
	,target.PracticeSameStoreDate = source.PracticeSameStoreDate
	
	FROM dim.Practices target
		INNER JOIN @StagingTable source ON source.PracticeID = target.PracticeID
*/

/*-----INSERT new records-----*/
	PRINT 'Inserting new records in Datasource from @StagingTable....'
	INSERT INTO dim.Practices_Hero
	(PracticeID
	,PracticeDataSourceID
	,PracticeSourceID
	,PracticeName
	,PracticeAbbreviation
	,PracticeDataSource
	,PracticeCompany
	,PracticeIsActive
	,PracticeIsSameStore
	,PracticeUpdatedDatetime
	,PracticeGLLocationID
	,PracticeGLLocation
	,PracticeGLPracticeID
	,PracticeSpecialty
	,PracticeSameStoreDate
	)

	SELECT
	source.PracticeID
	,source.PracticeDataSourceID
	,source.PracticeSourceID
	,source.PracticeName
	,source.PracticeAbbreviation
	,source.PracticeDataSource
	,source.PracticeCompany
	,source.PracticeIsActive
	,source.PracticeIsSameStore
	,source.PracticeUpdatedDatetime
	,source.PracticeGLLocationID
	,source.PracticeGLLocation
	,source.PracticeGLPracticeID
	,source.PracticeSpecialty
	,source.PracticeSameStoreDate
	
	FROM @StagingTable source
	--	LEFT JOIN dim.Practices target ON target.PracticeID = source.PracticeID
	WHERE 1=1
	--	AND target.PracticeID IS NULL 

	END

ELSE
	BEGIN
	PRINT 'Less than 10 records in the staging table. Ending job without delete and reload...'
	END

END
GO
