CREATE TABLE [fact].[VisitDiagnoses] (
    [VisitDiagnosisID] VARCHAR(100) NOT NULL,
    [VisitDiagnosisDataSourceID] INT NULL,
    [VisitDiagnosisSourceID] VARCHAR(100) NULL,
    [VisitDiagnosisVisitID] VARCHAR(100) NULL,
    [VisitDiagnosisAccountID] VARCHAR(100) NULL,
    [VisitDiagnosisType] VARCHAR(100) NULL,
    [VisitDiagnosisSequence] INT NULL,
    [VisitDiagnosisCodeType] VARCHAR(100) NULL,
    [VisitDiagnosisCode] VARCHAR(100) NULL,
    [VisitDiagnosisDescription] VARCHAR(1000) NULL,
    [VisitDiagnosisDate] DATETIME NULL,
    [VisitDiagnosisIsPrimary] BIT NULL,
    [VisitDiagnosisIsActive] BIT NULL,
    [VisitDiagnosisUpdatedDatetime] DATETIME NULL,
    CONSTRAINT [PK__VisitDia__675B3EAC5767072E] PRIMARY KEY ([VisitDiagnosisID])
);
GO
