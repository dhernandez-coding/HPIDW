CREATE TABLE [dim].[AJRRTriggerCode] (
    [Code] VARCHAR(20) NOT NULL,
    [BaseCode] VARCHAR(20) NOT NULL,
    [CodeSystem] VARCHAR(50) NOT NULL,
    [CodeSetTypes] VARCHAR(500) NULL,
    [TriggerVersions] VARCHAR(100) NULL,
    [IsPrimaryTrigger] BIT NOT NULL,
    [IsSupplementalTrigger] BIT NOT NULL,
    [IsHipFractureTrigger] BIT NOT NULL,
    [Joint] VARCHAR(5) NULL,
    [Laterality] CHAR(1) NULL,
    [CodeDescription] VARCHAR(1000) NULL,
    CONSTRAINT [PK_AJRRTriggerCode] PRIMARY KEY ([Code], [CodeSystem])
);
GO
