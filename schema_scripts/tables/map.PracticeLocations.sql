CREATE TABLE [map].[PracticeLocations] (
    [PracticeLocationID] INT IDENTITY(1,1) NOT NULL,
    [LocationID] VARCHAR(100) NULL,
    [PracticeID] VARCHAR(100) NULL,
    [IsReferralTarget] BIT NULL,
    [IsHPIPrimaryCare] BIT NULL,
    [IsHPISpecialist] BIT NULL,
    [IsAffiliate] BIT NULL,
    [PracticeLocationUpdatedDatetime] DATETIME NULL
);
GO
