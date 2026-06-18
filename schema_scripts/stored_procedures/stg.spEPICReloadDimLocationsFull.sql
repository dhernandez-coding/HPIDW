-- =============================================
-- Author:		Ryan Tisserand
-- Create date: 02/10/2023
-- Description:	Extracts, Transforms and Loads Location Data from EPIC Source System into a dim Table
-- Change Control
--	1. 02/10/2023 - Ryan Tisserand - Initial build of procedure
--  2. 05/07/2025 - Diego Hernandez - Safe load script
-- =============================================
CREATE PROCEDURE [stg].[spEPICReloadDimLocationsFull] AS
BEGIN
	SET NOCOUNT OFF;

	-- Create Staging table
	PRINT 'Creating @StagingTable...'
	DECLARE @StagingTable TABLE 
	(
		LocationID VARCHAR(50),
		LocationDataSourceID INT,
		LocationSourceID VARCHAR(50),
		LocationName VARCHAR(200),
		LocationAbbreviation VARCHAR(50),
		LocationDescription VARCHAR(200),
		LocationStreetAddress1 VARCHAR(200),
		LocationStreetAddress2 VARCHAR(200),
		LocationCity VARCHAR(200),
		LocationState VARCHAR(200),
		LocationZipCode VARCHAR(200),
		LocationPhone VARCHAR(50),
		LocationFederalTaxID VARCHAR(20),
		LocationIsActive BIT,
		LocationUpdatedDateTime DATETIME
	)

	-- Load data from EPIC into the staging table
	INSERT INTO @StagingTable (
		LocationID,
		LocationDataSourceID,
		LocationSourceID,
		LocationName,
		LocationAbbreviation,
		LocationDescription,
		LocationStreetAddress1,
		LocationStreetAddress2,
		LocationCity,
		LocationState,
		LocationZipCode,
		LocationPhone,
		LocationFederalTaxID,
		LocationIsActive,
		LocationUpdatedDateTime
	)
	SELECT *
	FROM OPENQUERY([CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM],
	'
	    SELECT 
	        ''5~'' + CAST(l.LOC_ID AS VARCHAR(50)) AS LocationID,
	        5 AS LocationDataSourceID,
	        l.LOC_ID AS LocationSourceID,
	        l.LOC_NAME AS LocationName,
	        l.LOCATION_ABBR AS LocationAbbreviation,
	        '''' AS LocationDescription,
	        p.ADDRESS_LINE_1 AS LocationStreetAddress1,
	        p.ADDRESS_LINE_2 AS LocationStreetAddress2,
	        p.CITY AS LocationCity,
	        s.ABBR AS LocationState,
	        p.ZIP AS LocationZipCode,
	        p.PHONE AS LocationPhone,
	        '''' AS LocationFederalTaxID,
	        1 AS LocationIsActive,
	        GETDATE() AS LocationUpdatedDateTime
	    FROM [Clarity].[ORGFILTER].[CLARITY_LOC] l
	    LEFT JOIN [Clarity].[ORGFILTER].[CLARITY_POS] p 
	        ON l.LOC_ID = p.POS_ID
	    LEFT JOIN [Clarity].[ORGFILTER].[ZC_STATE] s 
	        ON p.STATE_C = s.STATE_C
	    WHERE l.SERV_AREA_ID IN (425, 430, 452000)
	') AS loc;
	-- Proceed only if at least 10 records were returned
	IF (SELECT COUNT(1) FROM @StagingTable) >= 10
	BEGIN
		BEGIN TRANSACTION
			PRINT 'At least 10 records found. Proceeding to delete and reload.'

			DELETE FROM dim.Locations WHERE LocationDataSourceID = 5;

			INSERT INTO dim.Locations (
				LocationID,
				LocationDataSourceID,
				LocationSourceID,
				LocationName,
				LocationAbbreviation,
				LocationDescription,
				LocationStreetAddress1,
				LocationStreetAddress2,
				LocationCity,
				LocationState,
				LocationZipCode,
				LocationPhone,
				LocationFederalTaxID,
				LocationIsActive,
				LocationUpdatedDateTime
			)
			SELECT
				LocationID,
				LocationDataSourceID,
				LocationSourceID,
				LocationName,
				LocationAbbreviation,
				LocationDescription,
				LocationStreetAddress1,
				LocationStreetAddress2,
				LocationCity,
				LocationState,
				LocationZipCode,
				LocationPhone,
				LocationFederalTaxID,
				LocationIsActive,
				LocationUpdatedDateTime
			FROM @StagingTable;

		COMMIT TRANSACTION
	END
	ELSE
	BEGIN
		PRINT 'Less than 10 records in the staging table. Ending job without delete and reload...'
	END
END

--####################################### OLD QUERY ###########################################

--	-- Create Staging table
--	PRINT 'Creating @StagingTable...'
--	DECLARE @StagingTable TABLE 
--	(
--		LocationID VARCHAR(50),
--		LocationDataSourceID INT,
--		LocationSourceID VARCHAR(50),
--		LocationName VARCHAR(200),
--		LocationAbbreviation VARCHAR(50),
--		LocationDescription VARCHAR(200),
--		LocationStreetAddress1 VARCHAR(200),
--		LocationStreetAddress2 VARCHAR(200),
--		LocationCity VARCHAR(200),
--		LocationState VARCHAR(200),
--		LocationZipCode VARCHAR(200),
--		LocationPhone VARCHAR(50),
--		LocationFederalTaxID VARCHAR(20),
--		LocationIsActive BIT,
--		LocationUpdatedDateTime DATETIME
--	)

--	-- Load data from EPIC into the staging table
--	INSERT INTO @StagingTable (
--		LocationID,
--		LocationDataSourceID,
--		LocationSourceID,
--		LocationName,
--		LocationAbbreviation,
--		LocationDescription,
--		LocationStreetAddress1,
--		LocationStreetAddress2,
--		LocationCity,
--		LocationState,
--		LocationZipCode,
--		LocationPhone,
--		LocationFederalTaxID,
--		LocationIsActive,
--		LocationUpdatedDateTime
--	)
--	SELECT 
--		'5~' + CAST(l.LOC_ID AS VARCHAR(50)) AS LocationID,
--		5 AS LocationDataSourceID,
--		l.LOC_ID AS LocationSourceID,
--		l.LOC_NAME AS LocationName,
--		l.LOCATION_ABBR AS LocationAbbreviation,
--		'' AS LocationDescription,
--		p.ADDRESS_LINE_1 AS LocationStreetAddress1,
--		p.ADDRESS_LINE_2 AS LocationStreetAddress2,
--		p.CITY AS LocationCity,
--		s.ABBR AS LocationState,
--		p.ZIP AS LocationZipCode,
--		p.PHONE AS LocationPhone,
--		'' AS LocationFederalTaxID,
--		1 AS LocationIsActive,
--		GETDATE() AS LocationUpdatedDateTime
--	FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[CLARITY_LOC] l
--	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[CLARITY_POS] p ON l.LOC_ID = p.POS_ID
--	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[ZC_STATE] s ON p.STATE_C = s.STATE_C
--	WHERE l.SERV_AREA_ID IN (425,430)

--	-- Proceed only if at least 10 records were returned
--	IF (SELECT COUNT(1) FROM @StagingTable) >= 10
--	BEGIN
--		BEGIN TRANSACTION
--			PRINT 'At least 10 records found. Proceeding to delete and reload.'

--			DELETE FROM dim.Locations WHERE LocationDataSourceID = 5;

--			INSERT INTO dim.Locations (
--				LocationID,
--				LocationDataSourceID,
--				LocationSourceID,
--				LocationName,
--				LocationAbbreviation,
--				LocationDescription,
--				LocationStreetAddress1,
--				LocationStreetAddress2,
--				LocationCity,
--				LocationState,
--				LocationZipCode,
--				LocationPhone,
--				LocationFederalTaxID,
--				LocationIsActive,
--				LocationUpdatedDateTime
--			)
--			SELECT
--				LocationID,
--				LocationDataSourceID,
--				LocationSourceID,
--				LocationName,
--				LocationAbbreviation,
--				LocationDescription,
--				LocationStreetAddress1,
--				LocationStreetAddress2,
--				LocationCity,
--				LocationState,
--				LocationZipCode,
--				LocationPhone,
--				LocationFederalTaxID,
--				LocationIsActive,
--				LocationUpdatedDateTime
--			FROM @StagingTable;

--		COMMIT TRANSACTION
--	END
--	ELSE
--	BEGIN
--		PRINT 'Less than 10 records in the staging table. Ending job without delete and reload...'
--	END
--END
GO
