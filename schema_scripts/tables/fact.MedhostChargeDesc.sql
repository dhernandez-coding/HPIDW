CREATE TABLE [fact].[MedhostChargeDesc] (
    [ChargeCode] INT NULL,
    [Price] DECIMAL(18,2) NULL,
    [RevCode1] INT NULL,
    [RevCode2] INT NULL,
    [RevCode3] INT NULL,
    [EffectiveDate] DATE NULL,
    [TerminationDate] DATE NULL,
    [ChangeDate] DATE NULL,
    [ChangedBy] VARCHAR(50) NULL,
    [Facility] INT NULL,
    [IsActive] BIT NULL
);
GO
