CREATE TABLE [hero].[PBProcedureCodess] (
    [Id] INT NOT NULL,
    [ProcedureCode] NVARCHAR(MAX) NULL,
    [CptDescription] NVARCHAR(MAX) NULL,
    [IsDeleted] BIT NOT NULL,
    [ChargeCount] FLOAT NULL,
    [TotalCharges] FLOAT NULL,
    [LastPostDate] DATETIME2 NULL,
    [ProcedureCodeIsLocationDependent] BIT NOT NULL,
    [ProcedureCodeInPlay] BIT NOT NULL,
    [ProcedureCodeTHPLab] BIT NOT NULL,
    [ProcedureCodeCategoryId] FLOAT NULL,
    [ProcedureCodeServiceLineId] FLOAT NULL,
    [ProcedureCodeDHSCategoryId] FLOAT NULL,
    [FirstPostDate] DATETIME2 NULL,
    [CreatedDate] DATETIME2 NULL,
    [ModifiedDate] DATETIME2 NULL,
    [ModifiedBy] NVARCHAR(MAX) NULL,
    [DeletedDate] DATETIME2 NULL,
    [DeletedBy] NVARCHAR(MAX) NULL,
    [IsActive] BIT NOT NULL,
    [Mapped] BIT NOT NULL
);
GO
