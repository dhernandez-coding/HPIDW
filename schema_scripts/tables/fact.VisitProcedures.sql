CREATE TABLE [fact].[VisitProcedures] (
    [VisitProcedureID] VARCHAR(100) NOT NULL,
    [VisitProcedureDataSourceID] INT NULL,
    [VisitProcedureSourceID] VARCHAR(100) NULL,
    [VisitProcedureVisitID] VARCHAR(100) NULL,
    [VisitProcedureAccountID] VARCHAR(100) NULL,
    [VisitProcedureType] VARCHAR(100) NULL,
    [VisitProcedureSequence] INT NULL,
    [VisitProcedureCodeType] VARCHAR(100) NULL,
    [VisitProcedureCode] VARCHAR(100) NULL,
    [VisitProcedureDescription] VARCHAR(1000) NULL,
    [VisitProcedureMod1] VARCHAR(100) NULL,
    [VisitProcedureMod2] VARCHAR(100) NULL,
    [VisitProcedureMod3] VARCHAR(100) NULL,
    [VisitProcedureMod4] VARCHAR(100) NULL,
    [VisitProcedureProviderID] VARCHAR(100) NULL,
    [VisitProcedureDate] DATETIME NULL,
    [VisitProcedureIsPrimary] BIT NULL,
    [VisitProcedureIsActive] BIT NULL,
    [VisitProcedureUpdatedDatetime] DATETIME NULL,
    CONSTRAINT [PK__VisitPro__DC0A11B3D394B839] PRIMARY KEY ([VisitProcedureID])
);
GO
