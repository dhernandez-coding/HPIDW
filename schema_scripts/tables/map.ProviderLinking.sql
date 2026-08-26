CREATE TABLE [map].[ProviderLinking] (
    [ID] INT NULL,
    [ParentProviderID] VARCHAR(50) NOT NULL,
    [ChildProviderID] VARCHAR(50) NOT NULL,
    [ProviderLinkingMgmtUserID] INT NULL,
    [ProviderLinkingCreatedDatetime] DATETIME NULL,
    [ProviderLinkingUpdatedDatetime] DATETIME NULL,
    [ProviderLinkingIsActive] BIT NULL
);
GO
