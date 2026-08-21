CREATE PROCEDURE dim.spReloadHeroProviders_INCREMENTAL as
		
/* 
-- =============================================
-- Author:		Chris Cross
-- Create date: Aug 20 2026  1:01PM
-- Edit date:   
-- Description:	INCREMENTAL reload for dim.Providers_Hero from HPI App
-- ============================================= 
*/
BEGIN

/*-----INSERT INTO @StagingTable-----*/
	PRINT 'Creating @StagingTable....'
	DECLARE @StagingTable table 
	(ProviderID varchar(50)
	,ProviderDataSourceID int
	,ProviderSourceID varchar(50)
	,ProviderAbbreviation varchar(50)
	,ProviderFirstName varchar(100)
	,ProviderMiddleInitial varchar(50)
	,ProviderLastName varchar(100)
	,ProviderGender varchar(50)
	,ProviderSuffix varchar(50)
	,ProviderStreetAddress1 varchar(100)
	,ProviderStreetAddress2 varchar(100)
	,ProviderCity varchar(50)
	,ProviderState varchar(50)
	,ProviderZipCode varchar(50)
	,ProviderPhone varchar(50)
	,ProviderFax varchar(50)
	,ProviderSpecialtyID varchar(50)
	,ProviderUPIN varchar(50)
	,ProviderNPI varchar(50)
	,ProviderIsActive bit
	,ProviderUpdatedDateTime datetime
	)
	
	PRINT 'Inserting records from Datasource into @StagingTable....'
	INSERT INTO @StagingTable 
	(ProviderID
	,ProviderDataSourceID
	,ProviderSourceID
	,ProviderAbbreviation
	,ProviderFirstName
	,ProviderMiddleInitial
	,ProviderLastName
	,ProviderGender
	,ProviderSuffix
	,ProviderStreetAddress1
	,ProviderStreetAddress2
	,ProviderCity
	,ProviderState
	,ProviderZipCode
	,ProviderPhone
	,ProviderFax
	,ProviderSpecialtyID
	,ProviderUPIN
	,ProviderNPI
	,ProviderIsActive
	,ProviderUpdatedDateTime
	)

	SELECT
	MappedId as ProviderID
	,ProviderDataSourceID
	, ProviderSourceID
	,ProviderAbbreviation
	,ProviderFirstName
	,ProviderMiddleInitial
	,ProviderLastName
	,ProviderGender
	,ProviderSuffix
	,ProviderStreetAddress1
	,ProviderStreetAddress2
	,ProviderCity
	,ProviderState
	,ProviderZipCode
	,ProviderPhone
	,ProviderFax
	,ProviderSpecialtyID
	,ProviderUPIN
	,ProviderNPI
	,ProviderIsActive
	,coalesce(try_cast(ProviderUpdatedDateTime as Datetime), GetDate())  as ProviderUpdatedDateTime	
	
	FROM hero.vProviders
	WHERE 1=1
		--AND <Insert Incremental Date Column> between 2026-07-21 AND 2026-08-20

IF (SELECT COUNT(1) FROM @StagingTable) >= 10 
	BEGIN 
	PRINT 'At least 10 records exist in the staging table.  Proceed with delete and reload...'

/*-----DELETE/DEACTIVATE old records----*/
	PRINT 'Deleting records in Datasource....'
	DELETE FROM dim.Providers_hero --WHERE ProviderDataSourceID = 0 AND <Insert Incremental Date Column> between 2026-07-21 AND 2026-08-20

/*-----UPDATE existing records----*/
/*----------Commented out for INCREMENTAL reload based on modified date range----------
	PRINT 'Updating records in Datasource from @StagingTable....'
	UPDATE target
	SET target.ProviderID = source.ProviderID
	,target.ProviderDataSourceID = source.ProviderDataSourceID
	,target.ProviderSourceID = source.ProviderSourceID
	,target.ProviderAbbreviation = source.ProviderAbbreviation
	,target.ProviderFirstName = source.ProviderFirstName
	,target.ProviderMiddleInitial = source.ProviderMiddleInitial
	,target.ProviderLastName = source.ProviderLastName
	,target.ProviderGender = source.ProviderGender
	,target.ProviderSuffix = source.ProviderSuffix
	,target.ProviderStreetAddress1 = source.ProviderStreetAddress1
	,target.ProviderStreetAddress2 = source.ProviderStreetAddress2
	,target.ProviderCity = source.ProviderCity
	,target.ProviderState = source.ProviderState
	,target.ProviderZipCode = source.ProviderZipCode
	,target.ProviderPhone = source.ProviderPhone
	,target.ProviderFax = source.ProviderFax
	,target.ProviderSpecialtyID = source.ProviderSpecialtyID
	,target.ProviderUPIN = source.ProviderUPIN
	,target.ProviderNPI = source.ProviderNPI
	,target.ProviderIsActive = source.ProviderIsActive
	,target.ProviderUpdatedDateTime = source.ProviderUpdatedDateTime
	
	FROM dim.Providers_Hero target
		INNER JOIN @StagingTable source ON source.ProviderID = target.ProviderID
*/

/*-----INSERT new records-----*/
	PRINT 'Inserting new records in Datasource from @StagingTable....'
	INSERT INTO dim.Providers_Hero
	(ProviderID
	,ProviderDataSourceID
	,ProviderSourceID
	,ProviderAbbreviation
	,ProviderFirstName
	,ProviderMiddleInitial
	,ProviderLastName
	,ProviderGender
	,ProviderSuffix
	,ProviderStreetAddress1
	,ProviderStreetAddress2
	,ProviderCity
	,ProviderState
	,ProviderZipCode
	,ProviderPhone
	,ProviderFax
	,ProviderSpecialtyID
	,ProviderUPIN
	,ProviderNPI
	,ProviderIsActive
	,ProviderUpdatedDateTime
	)

	SELECT
	source.ProviderID
	,source.ProviderDataSourceID
	,source.ProviderSourceID
	,source.ProviderAbbreviation
	,source.ProviderFirstName
	,source.ProviderMiddleInitial
	,source.ProviderLastName
	,source.ProviderGender
	,source.ProviderSuffix
	,source.ProviderStreetAddress1
	,source.ProviderStreetAddress2
	,source.ProviderCity
	,source.ProviderState
	,source.ProviderZipCode
	,source.ProviderPhone
	,source.ProviderFax
	,source.ProviderSpecialtyID
	,source.ProviderUPIN
	,source.ProviderNPI
	,source.ProviderIsActive
	,source.ProviderUpdatedDateTime
	
	FROM @StagingTable source
	--	LEFT JOIN dim.Providers_Hero target ON target.ProviderID = source.ProviderID
	WHERE 1=1
	--	AND target.ProviderID IS NULL 

	END

ELSE
	BEGIN
	PRINT 'Less than 10 records in the staging table. Ending job without delete and reload...'
	END

END
GO
