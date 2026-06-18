-- =============================================
-- Author:		Ryan Tisserand
-- Create date: 03/01/2023
-- Description:	Extracts, Transforms and Loads Location Data from Medhost Nortwest Surgical Hospital Source System into a dim Table
-- Change Control
--	1. 03/01/2023 - Ryan Tisserand - Initial build of procedure
-- =============================================
CREATE PROCEDURE [stg].[spMedhostNSReloadDimLocationsFull]
AS
BEGIN
SET NOCOUNT ON;

delete from dim.Locations where LocationDataSourceID = 2

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
	'2~' + cast(l.LocationSourceID as varchar(50)) LocationID,
	2 LocationDataSourceID,
	l.LocationSourceID,
	CASE WHEN l.locationname = 'NORTH IP' THEN 'HPI	COMMUNITY HOSPITAL NORTH'
	WHEN l.locationname = 'SOUTH IP' THEN 'HPI COMMUNITY HOSPITAL SOUTH'
	WHEN l.locationname = 'NORTHWEST SURGICAL' THEN 'HPI NORTHWEST SURGICAL HOSPITAL'
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
		FROM MHD32.HOSPF100.PAADMLOC l
	'
)l
END
GO
