CREATE TABLE [map].[VisitServiceLineSpecialties] (
    [ID] INT IDENTITY(1,1) NOT NULL,
    [ServiceLineID] VARCHAR(100) NOT NULL,
    [SpecialtiesID] VARCHAR(50) NOT NULL,
    [ServiceLineSpecLinkingMgmtUserID] INT NULL,
    [ServiceLineSpecLinkingCreatedDatetime] DATETIME NULL,
    [ServiceLineSpecLinkingUpdatedDatetime] DATETIME NULL,
    [ServiceLineSpecLinkingIsActive] BIT NULL,
    CONSTRAINT [PK__ServiceLineSpecialtiesID] PRIMARY KEY ([ID])
);
GO
