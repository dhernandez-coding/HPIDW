CREATE TABLE [dim].[ServiceLines] (
    [ServiceLineID] VARCHAR(100) NOT NULL,
    [ServiceLineDataSourceID] INT NULL,
    [ServiceLineSourceID] VARCHAR(100) NULL,
    [ServiceLineName] VARCHAR(100) NULL,
    [ServiceLineGroupID] VARCHAR(100) NULL,
    [ServiceLineCaseAdjustment] DECIMAL(18,0) NULL,
    [ServiceLineAvgDaysScheduledOut] DECIMAL(18,0) NULL,
    [ServiceLineIsActive] BIT NULL,
    [ServiceLineUpdatedDateTime] DATETIME NULL,
    CONSTRAINT [PK__ServiceL__09C322156F464D85] PRIMARY KEY ([ServiceLineID])
);
GO
