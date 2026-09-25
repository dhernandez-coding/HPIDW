CREATE TABLE [app].[ProviderLinking] (
    [ID] INT IDENTITY(1,1) NOT NULL,
    [ParentProviderID] VARCHAR(50) NOT NULL,
    [ChildProviderID] VARCHAR(50) NOT NULL,
    [ProviderLinkingMgmtUserID] INT NULL,
    [ProviderLinkingCreatedDatetime] DATETIME NULL,
    [ProviderLinkingUpdatedDatetime] DATETIME NULL,
    [ProviderLinkingIsActive] BIT NULL,
    CONSTRAINT [PK_app_ProviderLinking] PRIMARY KEY ([ID])
);
GO
