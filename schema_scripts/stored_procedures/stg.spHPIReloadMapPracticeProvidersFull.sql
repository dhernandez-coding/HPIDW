CREATE PROCEDURE [stg].[spHPIReloadMapPracticeProvidersFull] as
		
/* 
-- =============================================
-- Author:		Chris Cross
-- Create date: Nov 20 2024  5:04PM
-- Edit date:   Full reload for map.PracticeProviders from HPI App
-- ============================================= 
*/
BEGIN

/*-----INSERT INTO @StagingTable-----*/
	PRINT 'Creating @StagingTable....'
	DECLARE @StagingTable table 
	(PracticeProviderID varchar(100)
	,PracticeID varchar(100)
	,ProviderID varchar(100)
	,PracticeProviderIsDefaultPractice bit
	,PracticeProviderIsDefaultReferralPractice bit
	,PracticeProviderIsPrimary bit
	,PracticeProviderIsSpecialist bit
	,PracticeProviderIsMidLevel bit
	,PracticeProviderIsReferralTarget bit
	,PracticeProviderIsAffiliate bit
	,PracticeProviderEffectiveDate date
	,PracticeProviderEndDate date
	,PracticeProviderFTE decimal
	,PracticeProviderAllocationPercent decimal
	,PracticeProviderLocation varchar(50)
	,PracticeProviderGLType varchar(30)
	,PracticeProviderGLTypeID varchar(30)
	,PracticeProviderGLProviderID varchar(10)
	,PracticeProviderDHSType int
	,PracticeProviderIsActive bit
	,PracticeProviderUpdatedDatetime datetime
	)
	
	PRINT 'Inserting records from Datasource into @StagingTable....'
	INSERT INTO @StagingTable 
	(PracticeProviderID
	,PracticeID
	,ProviderID
	,PracticeProviderIsDefaultPractice
	,PracticeProviderIsDefaultReferralPractice
	,PracticeProviderIsPrimary
	,PracticeProviderIsSpecialist
	,PracticeProviderIsMidLevel
	,PracticeProviderIsReferralTarget
	,PracticeProviderIsAffiliate
	,PracticeProviderEffectiveDate
	,PracticeProviderEndDate
	,PracticeProviderFTE
	,PracticeProviderAllocationPercent
	,PracticeProviderLocation
	,PracticeProviderGLType
	,PracticeProviderGLTypeID
	,PracticeProviderGLProviderID
	,PracticeProviderDHSType
	,PracticeProviderIsActive
	,PracticeProviderUpdatedDatetime
	)

	SELECT
	CONCAT('0~',PracticeID,'~',pp.ProviderID) AS PracticeProviderID
	,CONCAT('0~',PracticeID) AS PracticeID
	,p.ProviderProviderID AS ProviderID
	,PracticeProviderIsDefaultPractice
	,PracticeProviderIsDefaultReferralPractice
	,PracticeProviderIsPrimary
	,PracticeProviderIsSpecialist
	,PracticeProviderIsMidLevel
	,PracticeProviderIsReferralTarget
	,PracticeProviderIsAffiliate
	,PracticeProviderEffectiveDate
	,PracticeProviderEndDate
	,PracticeProviderFTE
	,PracticeProviderAllocationPercent
	,PracticeProviderLocation
	,PracticeProviderGLType
	,PracticeProviderGLTypeID
	,PracticeProviderGLProviderID
	,PracticeProviderDHSType
	,PracticeProviderIsActive
	,PracticeProviderUpdatedDatetime
	
	FROM HPIApp.dbo.PracticeProviders pp
		LEFT JOIN HPIApp.dbo.Providers p ON p.ProviderID = pp.ProviderID
	WHERE 1=1
		AND pp.PracticeID is not null
		AND pp.ProviderID is not null
		and pp.PracticeProviderIsActive = 1
		

IF (SELECT COUNT(1) FROM @StagingTable) >= 10 
	BEGIN 
	PRINT 'At least 10 records exist in the staging table.  Proceed with delete and reload...'

/*-----DELETE/DEACTIVATE old records----*/
	PRINT 'Deleting records in Datasource....'
	DELETE FROM map.zTEST_PracticeProviders 

/*-----UPDATE existing records----*/
/*----------Commented out for INCREMENTAL reload based on modified date range----------
	PRINT 'Updating records in Datasource from @StagingTable....'
	UPDATE target
	SET target.PracticeProviderID = source.PracticeProviderID
	,target.PracticeID = source.PracticeID
	,target.ProviderID = source.ProviderID
	,target.PracticeProviderIsDefaultPractice = source.PracticeProviderIsDefaultPractice
	,target.PracticeProviderIsDefaultReferralPractice = source.PracticeProviderIsDefaultReferralPractice
	,target.PracticeProviderIsPrimary = source.PracticeProviderIsPrimary
	,target.PracticeProviderIsSpecialist = source.PracticeProviderIsSpecialist
	,target.PracticeProviderIsMidLevel = source.PracticeProviderIsMidLevel
	,target.PracticeProviderIsReferralTarget = source.PracticeProviderIsReferralTarget
	,target.PracticeProviderIsAffiliate = source.PracticeProviderIsAffiliate
	,target.PracticeProviderEffectiveDate = source.PracticeProviderEffectiveDate
	,target.PracticeProviderEndDate = source.PracticeProviderEndDate
	,target.PracticeProviderFTE = source.PracticeProviderFTE
	,target.PracticeProviderAllocationPercent = source.PracticeProviderAllocationPercent
	,target.PracticeProviderLocation = source.PracticeProviderLocation
	,target.PracticeProviderGLType = source.PracticeProviderGLType
	,target.PracticeProviderGLTypeID = source.PracticeProviderGLTypeID
	,target.PracticeProviderGLProviderID = source.PracticeProviderGLProviderID
	,target.PracticeProviderDHSType = source.PracticeProviderDHSType
	,target.PracticeProviderIsActive = source.PracticeProviderIsActive
	,target.PracticeProviderUpdatedDatetime = source.PracticeProviderUpdatedDatetime
	
	FROM map.zTEST_PracticeProviders target
		INNER JOIN @StagingTable source ON source.PracticeProviderID = target.PracticeProviderID
*/

/*-----INSERT new records-----*/
	PRINT 'Inserting new records in Datasource from @StagingTable....'
	INSERT INTO map.zTEST_PracticeProviders
	(PracticeProviderID
	,PracticeID
	,ProviderID
	,PracticeProviderIsDefaultPractice
	,PracticeProviderIsDefaultReferralPractice
	,PracticeProviderIsPrimary
	,PracticeProviderIsSpecialist
	,PracticeProviderIsMidLevel
	,PracticeProviderIsReferralTarget
	,PracticeProviderIsAffiliate
	,PracticeProviderEffectiveDate
	,PracticeProviderEndDate
	,PracticeProviderFTE
	,PracticeProviderAllocationPercent
	,PracticeProviderLocation
	,PracticeProviderGLType
	,PracticeProviderGLTypeID
	,PracticeProviderGLProviderID
	,PracticeProviderDHSType
	,PracticeProviderIsActive
	,PracticeProviderUpdatedDatetime
	)

	SELECT
	source.PracticeProviderID
	,source.PracticeID
	,source.ProviderID
	,source.PracticeProviderIsDefaultPractice
	,source.PracticeProviderIsDefaultReferralPractice
	,source.PracticeProviderIsPrimary
	,source.PracticeProviderIsSpecialist
	,source.PracticeProviderIsMidLevel
	,source.PracticeProviderIsReferralTarget
	,source.PracticeProviderIsAffiliate
	,source.PracticeProviderEffectiveDate
	,source.PracticeProviderEndDate
	,source.PracticeProviderFTE
	,source.PracticeProviderAllocationPercent
	,source.PracticeProviderLocation
	,source.PracticeProviderGLType
	,source.PracticeProviderGLTypeID
	,source.PracticeProviderGLProviderID
	,source.PracticeProviderDHSType
	,source.PracticeProviderIsActive
	,source.PracticeProviderUpdatedDatetime
	
	FROM @StagingTable source
	--	LEFT JOIN map.zTEST_PracticeProviders target ON target.PracticeProviderID = source.PracticeProviderID
	WHERE 1=1
	--	AND target.PracticeProviderID IS NULL 

	END

ELSE
	BEGIN
	PRINT 'Less than 10 records in the staging table. Ending job without delete and reload...'
	END

END
GO
