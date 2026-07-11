CREATE TABLE [dim].[PBDatasets] (
    [PBDatasetID] NVARCHAR(150) NOT NULL,
    [PBDatasetDatasourceID] INT NOT NULL,
    [PBDatasetSourceID] NVARCHAR(100) NOT NULL,
    [PBWorkspaceID] NVARCHAR(150) NOT NULL,
    [PBWorkspaceSourceID] NVARCHAR(100) NOT NULL,
    [PBDatasetName] NVARCHAR(256) NULL,
    [PBDatasetIsActive] BIT NOT NULL DEFAULT ((1)),
    [PBDatasetUpdatedDatetime] DATETIME NOT NULL DEFAULT (getdate()),
    [PBDatasetLastRefreshDatetime] DATETIME2 NULL,
    [PBDatasetLastRefreshStatus] VARCHAR(50) NULL,
    CONSTRAINT [PK__PBDatase__CE4BF629CE8D783B] PRIMARY KEY ([PBDatasetID])
);
GO
