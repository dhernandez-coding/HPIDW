CREATE TABLE [dim].[PBWorkspaces] (
    [PBWorkspaceID] VARCHAR(100) NOT NULL,
    [PBWorkspaceDatasourceID] INT NULL,
    [PBWorkspaceSourceID] VARCHAR(100) NULL,
    [PBWorkspaceName] VARCHAR(100) NULL,
    [PBWorkspaceIsActive] BIT NULL,
    [PBWorkspaceUpdatedDatetime] DATETIME NULL,
    CONSTRAINT [PK__PBWorksp__CA6BAF0DA15CAD1E] PRIMARY KEY ([PBWorkspaceID])
);
GO
