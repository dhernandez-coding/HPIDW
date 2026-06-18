-- =============================================
-- Author:		Ryan Tisserand
-- Create date: 03/01/2023
-- Description:	Extracts, Transforms and Loads Location Data from Community Hospital Source System into a dim Table
-- Change Control
--	1. 03/01/2023 - Ryan Tisserand - Initial build of procedure
-- =============================================
CREATE PROCEDURE [stg].[spMedhostCHReloadDimLocationsFull]
AS
BEGIN
SET NOCOUNT ON;

delete from dim.Locations where LocationDataSourceID = 8

insert into dim.Locations
(
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
select
	'8~' + cast(l.LocationSourceID as varchar(50)) LocationID,
	8 LocationDataSourceID,
	l.LocationSourceID,
	CASE WHEN l.locationname = 'NORTH IP' THEN 'HPI COMMUNITY HOSPITAL NORTH'
		WHEN l.locationname = 'SOUTH IP' THEN 'HPI COMMUNITY HOSPITAL SOUTH'
		WHEN l.locationname = 'NORTHWEST SURGICAL' THEN 'HPI NORTHWEST SURGICAL HOSPITAL'
		WHEN l.LocationSourceID = '201' THEN 'HPI COMMUNITY HOSPITAL NORTH'
		WHEN l.locationname = 'NORTH OP' THEN 'HPI COMMUNITY HOSPITAL NORTH'
		WHEN l.locationname = 'SOUTH OP' THEN 'HPI COMMUNITY HOSPITAL SOUTH'
		ELSE l.LocationName END AS LocationName,
	'' LocationAbbreviation,
	'' LocationDescription,
	'' LocationStreetAddress1,
	'' LocationStreetAddress2,
	'' LocationCity,
	'' LocationState,
	'' LocationZipCode,
	'' LocationPhone,
	'' LocationFederalTaxID,
	1 LocationIsActive,
	getdate() LocationUpdatedDateTime
from openquery
(HMSLS, 
	'
		select
			PASITELOC LocationSourceID,
			PASITEDES LocationName
		FROM MHD32.HOSPF110.PAADMLOC l
	'
)l
END
GO
