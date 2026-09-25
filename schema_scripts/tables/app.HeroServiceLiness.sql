CREATE TABLE [app].[HeroServiceLiness] (
    [ServiceLineID] INT NOT NULL,
    [ServiceLineName] NVARCHAR(MAX) NOT NULL,
    [ServiceLineGroupID] FLOAT NOT NULL,
    [ServiceLineIsActive] BIT NOT NULL,
    [ServiceLineCreatedDate] DATETIME2 NOT NULL,
    [ServiceLineCreatedByUserID] FLOAT NOT NULL,
    [ServiceLineModifiedDate] DATETIME2 NOT NULL,
    [ServiceLineModifiedByUserID] FLOAT NOT NULL,
    [ValidFrom] DATETIME2 NOT NULL,
    [ValidTo] DATETIME2 NOT NULL,
    [CreatedDate] DATETIME2 NULL,
    [ModifiedDate] DATETIME2 NULL,
    [ModifiedBy] NVARCHAR(MAX) NULL,
    [DeletedDate] DATETIME2 NULL,
    [DeletedBy] NVARCHAR(MAX) NULL,
    [IsDeleted] BIT NOT NULL,
    [IsActive] BIT NOT NULL
);
GO
