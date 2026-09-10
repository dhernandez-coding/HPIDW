CREATE PROCEDURE [stg].[spReloadDimHPIProviders_INCREMENTAL] as
		
/* 
-- =============================================
-- Author:		Chris Cross
-- Create date: Sep  8 2026  9:49PM
-- Edit date:   
-- Description:	INCREMENTAL reload for dim.Providers from HPI App
-- ============================================= 
*/
BEGIN

SET NOCOUNT OFF
/*-----INSERT INTO #StagingTable-----*/
	PRINT 'Creating #StagingTable....'
	DROP TABLE IF EXISTS #StagingTable

	CREATE TABLE #StagingTable
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
	
	PRINT 'Inserting records from Datasource into #StagingTable....'
	INSERT INTO #StagingTable 
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


	select --p.providerid,
		Concat('0~', p.ProviderNPI) as ProviderID
		 ,0 as [ProviderDataSourceID]
		  ,p.ProviderNPI as ProviderSourceID
		  , COALESCE(
				MAX(CASE WHEN p.ProviderDataSourceID = 5 THEN p.[ProviderAbbreviation] END) 
				,MAX(p.[ProviderAbbreviation])) as [ProviderAbbreviation]
		  ,COALESCE(
				MAX(CASE WHEN p.ProviderDataSourceID = 5 THEN p.ProviderFirstName END) 
				,MAX(p.ProviderFirstName)) as [ProviderFirstName]
		  ,Left(COALESCE(
				MAX(CASE WHEN p.ProviderDataSourceID = 5 THEN p.[ProviderMiddleInitial] END) 
				,MAX(p.[ProviderMiddleInitial])) 
				,1) as [ProviderMiddleInitial]
		  ,COALESCE(
				MAX(CASE WHEN p.ProviderDataSourceID = 5 THEN p.ProviderLastName END) 
				,MAX(p.ProviderLastName)) as [ProviderLastName]
		  ,COALESCE(
				MAX(CASE WHEN p.ProviderDataSourceID = 5 THEN p.[ProviderGender] END) 
				,MAX(p.[ProviderGender])) as [ProviderGender]
		  ,COALESCE(
				MAX(CASE WHEN p.ProviderDataSourceID = 5 THEN p.[ProviderSuffix] END) 
				,MAX(p.[ProviderSuffix])) as [ProviderSuffix]
		  ,COALESCE(
				MAX(CASE WHEN p.ProviderDataSourceID = 5 THEN p.[ProviderStreetAddress1] END) 
				,MAX(p.[ProviderStreetAddress1])) as [ProviderStreetAddress1]
		  ,COALESCE(
				MAX(CASE WHEN p.ProviderDataSourceID = 5 THEN p.[ProviderStreetAddress2] END) 
				,MAX(p.[ProviderStreetAddress2])) as [ProviderStreetAddress2]
		  ,COALESCE(
				MAX(CASE WHEN p.ProviderDataSourceID = 5 THEN p.[ProviderCity] END) 
				,MAX(p.[ProviderCity])) as [ProviderCity]
		  ,COALESCE(
				MAX(CASE WHEN p.ProviderDataSourceID = 5 THEN p.[ProviderState] END) 
				,MAX(p.[ProviderState])) as [ProviderState]
		  ,COALESCE(
				MAX(CASE WHEN p.ProviderDataSourceID = 5 THEN p.[ProviderZipCode] END) 
				,MAX(p.[ProviderZipCode])) as [ProviderZipCode]
		  ,COALESCE(
				MAX(CASE WHEN p.ProviderDataSourceID = 5 THEN p.[ProviderPhone] END) 
				,MAX(p.[ProviderPhone])) as [ProviderPhone]
		  ,COALESCE(
				MAX(CASE WHEN p.ProviderDataSourceID = 5 THEN p.[ProviderFax] END) 
				,MAX(p.[ProviderFax])) as [ProviderFax]
		  ,null as [ProviderSpecialtyID] 
		  ,COALESCE(
				MAX(CASE WHEN p.ProviderDataSourceID = 5 THEN p.[ProviderUPIN] END) 
				,MAX(p.[ProviderUPIN])) as [ProviderUPIN]
		  ,COALESCE(
				MAX(CASE WHEN p.ProviderDataSourceID = 5 THEN p.[ProviderNPI] END) 
				,MAX(p.[ProviderNPI])) as [ProviderNPI]
		  ,1 as [ProviderIsActive]
		  ,GetDate() as [ProviderUpdatedDateTime]
		  --,0 as IsDeleted
	FROM HPIDW.dim.Providers p
		--left join HPIDW.dim.Specialties s ON s.SpecialtyID = p.ProviderSpecialtyID
		left join HPIDW.dim.Providers p0 ON p0.ProviderNPI = p.ProviderNPI and p0.ProviderDataSourceID = 0
	WHERE 1=1
		AND p.ProviderDataSourceID <> 0
		AND ISNUMERIC(p.ProviderNPI) = 1 
		AND p.ProviderNPI NOT IN ('0'
								,'000'
								,'000000'
								,'000000000'
								,'0000000000'
								,'0000000009'
								,'000000002'
								,'9999999'
								,'99999999'
								,'9999999999')
		AND p0.ProviderID is null /*No current matches*/
		--and p.ProviderNPI = '1942659362'
	GROUP BY p.ProviderNPI

IF (SELECT COUNT(1) FROM #StagingTable) >= 1
	BEGIN 
	PRINT 'At least 1 records exist in the staging table.  Proceed with delete and reload...'

/*-----DELETE/DEACTIVATE old records----*/
	--PRINT 'Deleting records in Datasource....'
	--DELETE FROM dim.Providers WHERE ProviderDataSourceID = 0 AND <Insert Incremental Date Column> between 2026-08-09 AND 2026-09-08

/*-----UPDATE existing records----*/
	--PRINT 'Updating records in Datasource from #StagingTable....'
/*
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
	
	FROM dim.Providers target
		INNER JOIN #StagingTable source ON source.ProviderID = target.ProviderID
*/

/*-----INSERT new records-----*/
	PRINT 'Inserting new records in Datasource from #StagingTable....'
	INSERT INTO dim.Providers
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
	
	FROM #StagingTable source
		LEFT JOIN dim.Providers target ON target.ProviderID = source.ProviderID
	WHERE 1=1
		AND target.ProviderID IS NULL 

	END
	--select * from dim.Providers where ProviderNPI = '1013526417' OR ProviderID = '0~1013526417'


ELSE
	BEGIN
	PRINT 'Less than 1 records in the staging table. Ending job without delete and reload...'
	END

/* 
--9/9/26 - Updated Specialties manually - Chris Cross
UPDATE dim.Providers SET ProviderSpecialtyID = '0~1' WHERE ProviderID = '0~1356674451'
UPDATE dim.Providers SET ProviderSpecialtyID = '0~8' WHERE ProviderID = '0~1518588516'
UPDATE dim.Providers SET ProviderSpecialtyID = '0~7' WHERE ProviderID = '0~1972139954'
UPDATE dim.Providers SET ProviderSpecialtyID = '0~5' WHERE ProviderID = '0~1366703092'
*/

DROP TABLE IF EXISTS #StagingTable
END
GO
