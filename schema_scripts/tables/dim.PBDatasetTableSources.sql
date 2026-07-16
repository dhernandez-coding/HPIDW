CREATE TABLE [dim].[PBDatasetTableSources] (
    [PBDatasetTableSourceRefID] VARCHAR(500) NOT NULL,
    [PBDatasetTableID] VARCHAR(300) NULL,
    [SourceRef] VARCHAR(400) NULL,
    [LoadDatetime] DATETIME2 NULL,
    CONSTRAINT [PK__PBDatase__3A1F9793B31CB71E] PRIMARY KEY ([PBDatasetTableSourceRefID])
);
GO
