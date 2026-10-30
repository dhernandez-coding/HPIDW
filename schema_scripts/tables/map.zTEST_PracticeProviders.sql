CREATE TABLE [map].[zTEST_PracticeProviders] (
    [PracticeProviderID] VARCHAR(100) NULL,
    [PracticeID] VARCHAR(100) NULL,
    [ProviderID] VARCHAR(100) NULL,
    [PracticeProviderIsDefaultPractice] BIT NULL,
    [PracticeProviderIsDefaultReferralPractice] BIT NULL,
    [PracticeProviderIsPrimary] BIT NULL,
    [PracticeProviderIsSpecialist] BIT NULL,
    [PracticeProviderIsMidLevel] BIT NULL,
    [PracticeProviderIsReferralTarget] BIT NULL,
    [PracticeProviderIsAffiliate] BIT NULL,
    [PracticeProviderEffectiveDate] DATE NULL,
    [PracticeProviderEndDate] DATE NULL,
    [PracticeProviderFTE] DECIMAL(18,0) NULL,
    [PracticeProviderAllocationPercent] DECIMAL(18,0) NULL,
    [PracticeProviderLocation] VARCHAR(50) NULL,
    [PracticeProviderGLType] VARCHAR(30) NULL,
    [PracticeProviderGLTypeID] VARCHAR(30) NULL,
    [PracticeProviderGLProviderID] VARCHAR(10) NULL,
    [PracticeProviderDHSType] INT NULL,
    [PracticeProviderIsActive] BIT NULL,
    [PracticeProviderUpdatedDatetime] DATETIME NULL
);
GO
