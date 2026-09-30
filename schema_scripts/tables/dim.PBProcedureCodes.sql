CREATE TABLE [dim].[PBProcedureCodes] (
    [ProcedureCodeID] INT IDENTITY(1000,1) NOT NULL,
    [ProcedureCode] VARCHAR(50) NOT NULL,
    [CptDescription] VARCHAR(500) NULL,
    [CategoryID] INT NULL,
    [ServiceLineID] INT NULL,
    [DHSCategoryID] INT NULL,
    [IsLocationDependent] BIT NULL,
    [InPlay] BIT NULL,
    [THPLab] BIT NULL,
    [IsMapped] BIT NOT NULL DEFAULT ((0)),
    [FirstPostDate] DATETIME NULL,
    [LastPostDate] DATETIME NULL,
    [ChargeCount] FLOAT NULL,
    [TotalCharges] FLOAT NULL,
    [IsActive] BIT NOT NULL DEFAULT ((1)),
    [CreatedDatetime] DATETIME NOT NULL DEFAULT (getdate()),
    [UpdatedDatetime] DATETIME NOT NULL DEFAULT (getdate()),
    [ModifiedBy] VARCHAR(100) NULL,
    CONSTRAINT [PK_PBProcedureCodes] PRIMARY KEY ([ProcedureCodeID])
);
GO
