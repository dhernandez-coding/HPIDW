CREATE TABLE [dim].[PBDatasetTables] (
    [PBDatasetTableID] NVARCHAR(250) NOT NULL,
    [PBDatasetTableDatasourceID] INT NOT NULL DEFAULT ((13)),
    [PBDatasetTableSourceID] NVARCHAR(100) NOT NULL,
    [PBDatasetID] NVARCHAR(150) NOT NULL,
    [PBDatasetSourceID] NVARCHAR(100) NOT NULL,
    [PBDatasetTableName] NVARCHAR(256) NOT NULL,
    [PBDatasetTableSourceType] NVARCHAR(100) NULL,
    [PBDatasetTableConnectionServer] NVARCHAR(255) NULL,
    [PBDatasetTableConnectionDatabase] NVARCHAR(255) NULL,
    [PBDatasetTableDBSourceTable] NVARCHAR(1000) NULL,
    [PBDatasetTableMExpression] NVARCHAR(MAX) NULL,
    [PBDatasetTableIsActive] BIT NOT NULL DEFAULT ((1)),
    [PBDatasetTableUpdatedDatetime] DATETIME NOT NULL DEFAULT (getdate()),
    CONSTRAINT [PK__PBDatase__2382BBFD478580AF] PRIMARY KEY ([PBDatasetTableID])
);
GO
