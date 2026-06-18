CREATE TABLE [dim].[PayerGroups] (
    [PayerGroupID] VARCHAR(50) NOT NULL,
    [PayerGroupDataSourceID] INT NOT NULL,
    [PayerGroupSourceID] VARCHAR(50) NOT NULL,
    [PayerGroupName] VARCHAR(100) NULL,
    [PayerGroupIsActive] BIT NULL,
    [PayerGroupUpdatedDatetime] DATETIME NULL,
    CONSTRAINT [PK__PayerGro__7606E3BD580C7858] PRIMARY KEY ([PayerGroupID])
);
GO
