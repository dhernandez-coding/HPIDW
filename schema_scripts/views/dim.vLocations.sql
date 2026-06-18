create view dim.[vLocations] as

SELECT
	[LocationID]
	,[LocationDataSourceID]
	,[LocationSourceID]
	,[LocationName]
	,[LocationAbbreviation]
	,[LocationDescription]
	,[LocationStreetAddress1]
	,[LocationStreetAddress2]
	,[LocationCity]
	,[LocationState]
	,[LocationZipCode]
	,[LocationPhone]
	,[LocationFederalTaxID]
	,[LocationIsActive]
	,[LocationUpdatedDateTime]
FROM [HPIDW].[dim].[Locations]
GO
