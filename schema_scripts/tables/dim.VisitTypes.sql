CREATE TABLE [dim].[VisitTypes] (
    [VisitTypeID] VARCHAR(50) NOT NULL,
    [VisitTypeDataSourceID] INT NULL,
    [VisitTypeSourceID] VARCHAR(50) NULL,
    [VisitTypeName] VARCHAR(100) NULL,
    [VisitTypeAbbreviation] VARCHAR(10) NULL,
    [VisitTypeIsActive] BIT NULL,
    [VisitTypeUpdatedDatetime] DATETIME2 NULL,
    CONSTRAINT [PK_dim.VisitTypes] PRIMARY KEY ([VisitTypeID])
);
GO
