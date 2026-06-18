CREATE TABLE [dim].[Specialties] (
    [SpecialtyID] VARCHAR(50) NOT NULL,
    [SpecialtyDataSourceID] INT NULL,
    [SpecialtySourceID] VARCHAR(50) NULL,
    [SpecialtyName] VARCHAR(100) NULL,
    [SpecialtyAbbreviation] VARCHAR(50) NULL,
    [SpecialtyDescription] VARCHAR(200) NULL,
    [SpecialtyIsActive] BIT NULL,
    [SpecialtyCoPayApplies] BIT NULL,
    [SpecialtyUpdatedDateTime] DATETIME NULL,
    CONSTRAINT [PK_Specialties] PRIMARY KEY ([SpecialtyID])
);
GO
