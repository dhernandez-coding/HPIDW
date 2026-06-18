CREATE TABLE [map].[zzEpicPracticeProviders] (
    [EpicPracticeProviderID] INT IDENTITY(1,1) NOT NULL,
    [ProviderID] VARCHAR(100) NULL,
    [PracticeID] VARCHAR(100) NULL,
    [IsReferralTarget] BIT NULL,
    [IsHPIPrimaryCare] BIT NULL,
    [IsHPISpecialist] BIT NULL,
    [IsAffiliate] BIT NULL,
    [EpicPracticeProviderUpdatedDatetime] DATETIME NULL
);
GO
