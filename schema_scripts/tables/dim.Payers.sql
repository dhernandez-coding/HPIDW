CREATE TABLE [dim].[Payers] (
    [PayerID] VARCHAR(50) NOT NULL,
    [PayerDataSourceID] INT NOT NULL,
    [PayerSourceID] VARCHAR(50) NOT NULL,
    [PayerGroupID] VARCHAR(50) NULL,
    [PayerCategoryID] VARCHAR(50) NULL,
    [PayerName] VARCHAR(100) NULL,
    [PayerAbbreviation] VARCHAR(50) NULL,
    [PayerStreetAddress1] VARCHAR(50) NULL,
    [PayerStreetAddress2] VARCHAR(50) NULL,
    [PayerCity] VARCHAR(50) NULL,
    [PayerState] VARCHAR(50) NULL,
    [PayerZipCode] VARCHAR(50) NULL,
    [PayerIsActive] BIT NULL,
    [PayerUpdatedDatetime] DATETIME NULL,
    CONSTRAINT [PK_Payers] PRIMARY KEY ([PayerID])
);
GO
