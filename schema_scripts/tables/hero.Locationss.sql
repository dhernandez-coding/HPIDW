CREATE TABLE [hero].[Locationss] (
    [LocationID] INT NOT NULL,
    [LocationName] NVARCHAR(MAX) NOT NULL,
    [LocationIsActive] BIT NOT NULL,
    [LocationCreatedDate] DATETIME2 NOT NULL,
    [LocationCreatedByUserID] FLOAT NOT NULL,
    [LocationModifiedDate] DATETIME2 NOT NULL,
    [LocationModifiedByUserID] FLOAT NOT NULL,
    [CreatedDate] DATETIME2 NULL,
    [ModifiedDate] DATETIME2 NULL,
    [ModifiedBy] NVARCHAR(MAX) NULL,
    [DeletedDate] DATETIME2 NULL,
    [DeletedBy] NVARCHAR(MAX) NULL,
    [IsDeleted] BIT NOT NULL,
    [IsActive] BIT NOT NULL
);
GO
