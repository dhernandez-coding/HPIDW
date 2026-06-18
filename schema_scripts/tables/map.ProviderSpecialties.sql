CREATE TABLE [map].[ProviderSpecialties] (
    [ID] INT IDENTITY(1,1) NOT NULL,
    [ProviderNPI] INT NOT NULL,
    [SpecialtyID] VARCHAR(100) NOT NULL,
    [ProviderSpecialtyIsPrimary] BIT NULL,
    [ProviderSpecialtyMgmtUserID] INT NULL,
    [ProviderSpecialtyCreatedDatetime] DATETIME NULL,
    [ProviderSpecialtyUpdatedDatetime] DATETIME NULL,
    [ProviderSpecialtyIsActive] BIT NULL,
    CONSTRAINT [PK__Provider__72F3EAFA505F35F2] PRIMARY KEY ([ID])
);
GO
