CREATE TABLE [dim].[ServiceLineGroups] (
    [ServiceLineGroupID] VARCHAR(100) NOT NULL,
    [ServiceLineGroupDataSourceID] INT NULL,
    [ServiceLineGroupSourceID] VARCHAR(100) NULL,
    [ServiceLineGroupName] VARCHAR(100) NULL,
    [ServiceLineGroupIsActive] BIT NULL,
    [ServiceLineGroupUpdatedDateTime] DATETIME NULL,
    CONSTRAINT [PK__ServiceL__2786DFA06959E8D0] PRIMARY KEY ([ServiceLineGroupID])
);
GO
