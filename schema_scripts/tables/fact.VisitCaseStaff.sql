CREATE TABLE [fact].[VisitCaseStaff] (
    [VisitCaseStaffID] VARCHAR(100) NOT NULL,
    [VisitCaseStaffDatasourceID] INT NULL,
    [VisitCaseStaffSourceID] VARCHAR(100) NULL,
    [VisitCaseID] VARCHAR(100) NOT NULL,
    [VisitCaseStaffLine] INT NOT NULL,
    [VisitCaseStaffName] VARCHAR(100) NULL,
    [VisitCaseStaffCred] VARCHAR(10) NULL,
    [VisitCaseStaffType] VARCHAR(100) NULL,
    [VisitCaseStaffSubtype] VARCHAR(100) NULL,
    [VisitCaseStaffAccountableStaff] VARCHAR(5) NULL,
    [VisitCaseStaffDurationMinutes] INT NULL,
    [VisitCaseStaffIsActive] BIT NULL,
    [VisitCaseStaffUpdatedDatetime] DATETIME NULL,
    CONSTRAINT [PK__VisitCas__834B2210316F1E1C] PRIMARY KEY ([VisitCaseStaffID])
);
GO
