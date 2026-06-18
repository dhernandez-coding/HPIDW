-- =============================================
-- Author:		Ryan Tisserand
-- Create date: <Create Date,,>
-- Description:	Extracts, Transforms and Loads Location Data from APM Source System into a dim Table
-- Change Control
--	1. 11/23/2022 - Ryan Tisserand - Initial build of procedure
--  2. 03/10/2023 - Ryan Tisserand - Added delete statement to replace truncate job step
-- =============================================
CREATE PROCEDURE [stg].[spAPMReloadDimLocationsFull]
AS
BEGIN
SET NOCOUNT ON;

delete from dim.Locations where LocationDataSourceID = 1

insert into dim.Locations
(
	LocationID,
	LocationDataSourceID,
	LocationSourceID,
	LocationAbbreviation,
	LocationDescription,
	LocationStreetAddress1,
	LocationStreetAddress2,
	LocationCity,
	LocationName,
	LocationState,
	LocationZipCode,
	LocationPhone,
	LocationFederalTaxID,
	LocationIsActive,
	LocationUpdatedDateTime
)
select 
	'1~' + cast(l.Location_ID as varchar(10)) LocationID,
	'1' LocationDataSourceID,
	cast(l.Location_ID as varchar(10)) LocationSourceID,
	l.Abbreviation LocationAbbreviation,
	l.[Description] LocationDescription,
	l.Street1 LocationStreetAddress1,
	l.Street2 LocationStreetAddress2,
	l.City LocationCity,
	l.[Name] LocationName,
	l.[State] LocationState,
	l.Zip_Code LocationZipCode,
	l.Phone LocationPhone,
	l.Federal_ID_No LocationFederalTaxID,
	1 as LocationIsActive,
	GETDATE() as LocationUpdatedDatetime
from tievmdb03.Ntier_627200.pm.Locations l
END
GO
