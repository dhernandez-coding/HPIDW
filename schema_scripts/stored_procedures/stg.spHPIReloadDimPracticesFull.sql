CREATE PROCEDURE [stg].[spHPIReloadDimPracticesFull] as
		
/* 
-- =============================================
-- Author:		Chris Cross
-- Create date: Nov 21 2024  5:29PM
-- Edit date:   
-- Description:	INCREMENTAL reload for dim.zTEST_Practices from HPI App
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
	,PracticeGLLocationID varchar(10)
	,PracticeGLLocation varchar(50)
	,PracticeGLPracticeID varchar(10)
	,PracticeSpecialty varchar(30)
	,PracticeIsSameStore bit
	,PracticeIsActive bit
	,PracticeUpdatedDatetime datetime
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
	,PracticeGLLocationID
	,PracticeGLLocation
	,PracticeGLPracticeID
	,PracticeSpecialty
	,PracticeIsSameStore
	,PracticeIsActive
	,PracticeUpdatedDatetime
	)

	SELECT
	CONCAT('0~',p.PracticeID) AS PracticeID
	,0 AS PracticeDataSourceID
	,p.PracticePracticeID AS PracticeSourceID
	,PracticeName
	,PracticeAbbreviation
	,PracticeDataSource
	,c.CompanyName as PracticeCompany
	,PracticeGLLocationID
	,PracticeGLLocation
	,PracticeGLPracticeID
	,PracticeSpecialty
	,PracticeIsSameStore
	,PracticeIsActive
	,PracticeUpdatedDatetime
	FROM HPIAPP.dbo.Practices p
		left join HPIApp.dbo.Companies c ON c.CompanyID = p.PracticeCompanyId
	WHERE 1=1
		

IF (SELECT COUNT(1) FROM @StagingTable) >= 10 
	BEGIN 
	PRINT 'At least 10 records exist in the staging table.  Proceed with delete and reload...'

/*-----DELETE/DEACTIVATE old records----*/
	PRINT 'Deleting records in Datasource....'
	DELETE FROM dim.zTEST_Practices WHERE PracticeDataSourceID = 0 

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
	,target.PracticeGLLocationID = source.PracticeGLLocationID
	,target.PracticeGLLocation = source.PracticeGLLocation
	,target.PracticeGLPracticeID = source.PracticeGLPracticeID
	,target.PracticeSpecialty = source.PracticeSpecialty
	,target.PracticeIsSameStore = source.PracticeIsSameStore
	,target.PracticeIsActive = source.PracticeIsActive
	,target.PracticeUpdatedDatetime = source.PracticeUpdatedDatetime
	
	FROM dim.zTEST_Practices target
		INNER JOIN @StagingTable source ON source.PracticeID = target.PracticeID
*/

/*-----INSERT new records-----*/
	PRINT 'Inserting new records in Datasource from @StagingTable....'
	INSERT INTO dim.zTEST_Practices
	(PracticeID
	,PracticeDataSourceID
	,PracticeSourceID
	,PracticeName
	,PracticeAbbreviation
	,PracticeDataSource
	,PracticeCompany
	,PracticeGLLocationID
	,PracticeGLLocation
	,PracticeGLPracticeID
	,PracticeSpecialty
	,PracticeIsSameStore
	,PracticeIsActive
	,PracticeUpdatedDatetime
	)

	SELECT
	source.PracticeID
	,source.PracticeDataSourceID
	,source.PracticeSourceID
	,source.PracticeName
	,source.PracticeAbbreviation
	,source.PracticeDataSource
	,source.PracticeCompany
	,source.PracticeGLLocationID
	,source.PracticeGLLocation
	,source.PracticeGLPracticeID
	,source.PracticeSpecialty
	,source.PracticeIsSameStore
	,source.PracticeIsActive
	,source.PracticeUpdatedDatetime
	
	FROM @StagingTable source
	--	LEFT JOIN dim.zTEST_Practices target ON target.PracticeID = source.PracticeID
	WHERE 1=1
	--	AND target.PracticeID IS NULL 

	END

ELSE
	BEGIN
	PRINT 'Less than 10 records in the staging table. Ending job without delete and reload...'
	END

END
GO
