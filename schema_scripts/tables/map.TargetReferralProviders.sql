CREATE TABLE [map].[TargetReferralProviders] (
    [ProviderID] VARCHAR(100) NOT NULL,
    [Name] VARCHAR(100) NULL,
    [Suffix] VARCHAR(100) NULL,
    [Practice] VARCHAR(100) NULL,
    [Specialty] VARCHAR(100) NULL,
    [Profession] VARCHAR(100) NULL,
    [PrimaryOfficeName] VARCHAR(100) NULL,
    [Street] VARCHAR(100) NULL,
    [City] VARCHAR(100) NULL,
    [State] VARCHAR(100) NULL,
    [ZipCode] VARCHAR(100) NULL,
    [TargetType] VARCHAR(100) NULL,
    [UpdateDatetime] DATETIME NULL,
    CONSTRAINT [PK__TargetRe__B54C689DEB84E0A2] PRIMARY KEY ([ProviderID])
);
GO
