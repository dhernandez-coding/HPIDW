CREATE TABLE [dim].[Rooms] (
    [RoomID] VARCHAR(50) NOT NULL,
    [RoomDataSourceID] INT NOT NULL,
    [RoomSourceID] VARCHAR(50) NOT NULL,
    [RoomName] VARCHAR(200) NULL,
    [RoomLocationID] VARCHAR(50) NULL,
    [RoomIsOR] BIT NULL,
    [RoomIsActive] BIT NULL,
    [RoomUpdatedDateTime] DATETIME NULL,
    CONSTRAINT [PK_Rooms] PRIMARY KEY ([RoomID])
);
GO
