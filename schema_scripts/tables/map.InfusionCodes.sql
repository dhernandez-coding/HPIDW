CREATE TABLE [map].[InfusionCodes] (
    [InfustionCodeID] INT IDENTITY(1,1) NOT NULL,
    [DataSourceID] INT NOT NULL,
    [InfusionCodeProcedureCode] VARCHAR(100) NOT NULL,
    CONSTRAINT [PK_HCPCS] PRIMARY KEY ([InfustionCodeID])
);
GO
