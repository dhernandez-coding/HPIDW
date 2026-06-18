CREATE TABLE [map].[PracticeProviders] (
    [PracticeProviderID] INT IDENTITY(1,1) NOT NULL,
    [PracticeID] VARCHAR(100) NOT NULL,
    [ProviderID] VARCHAR(100) NOT NULL,
    [ProviderAbbreviation] VARCHAR(100) NULL,
    [PracticeProviderIsPrimary] BIT NULL,
    [PracticeProviderEffectiveDate] DATE NULL,
    [PracticeProviderEndDate] DATE NULL,
    [PracticeProviderIsActive] BIT NULL,
    [PracticeProviderUpdatedDatetime] DATETIME NULL,
    [PracticeProviderFTE] DECIMAL(18,2) NULL,
    [PracticeProviderAllocationPercent] DECIMAL(18,8) NULL,
    [PracticeProviderLocation] VARCHAR(50) NULL,
    [PracticeProviderIsSpecialist] BIT NULL,
    [PracticeProviderIsMidLevel] BIT NULL,
    [PracticeProviderGLType] VARCHAR(30) NULL,
    [PracticeProviderGLTypeID] VARCHAR(30) NULL,
    [PracticeProviderGLProviderID] VARCHAR(10) NULL,
    [PracticeProviderDHSType] INT NULL,
    CONSTRAINT [PK__Practice__5E7F77EEDAF98428] PRIMARY KEY ([PracticeProviderID])
);
GO
