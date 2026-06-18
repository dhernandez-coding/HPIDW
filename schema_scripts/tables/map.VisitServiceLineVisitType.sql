CREATE TABLE [map].[VisitServiceLineVisitType] (
    [ID] INT IDENTITY(1,1) NOT NULL,
    [ServiceLineID] VARCHAR(100) NOT NULL,
    [VisitTypeID] VARCHAR(50) NOT NULL,
    [ServiceLineVisitLinkingMgmtUserID] INT NULL,
    [ServiceLineVisitLinkingCreatedDatetime] DATETIME NULL,
    [ServiceLineVisitLinkingUpdatedDatetime] DATETIME NULL,
    [ServiceLineVisitLinkingIsActive] BIT NULL,
    CONSTRAINT [PK__ServiceLineVisitTypeID] PRIMARY KEY ([ID])
);
GO
