CREATE TABLE [dim].[Locations] (
    [LocationID] VARCHAR(50) NOT NULL,
    [LocationDataSourceID] INT NOT NULL,
    [LocationSourceID] VARCHAR(50) NOT NULL,
    [LocationName] VARCHAR(200) NULL,
    [LocationAbbreviation] VARCHAR(50) NULL,
    [LocationDescription] VARCHAR(200) NULL,
    [LocationStreetAddress1] VARCHAR(200) NULL,
    [LocationStreetAddress2] VARCHAR(200) NULL,
    [LocationCity] VARCHAR(200) NULL,
    [LocationState] VARCHAR(200) NULL,
    [LocationZipCode] VARCHAR(200) NULL,
    [LocationPhone] VARCHAR(50) NULL,
    [LocationFederalTaxID] VARCHAR(20) NULL,
    [LocationIsActive] BIT NULL,
    [LocationUpdatedDateTime] DATETIME NULL,
    CONSTRAINT [PK_Locations] PRIMARY KEY ([LocationID])
);
GO
