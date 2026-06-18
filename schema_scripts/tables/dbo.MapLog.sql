CREATE TABLE [dbo].[MapLog] (
    [MapLogID] INT IDENTITY(1,1) NOT NULL,
    [MapTable] VARCHAR(50) NOT NULL,
    [ActionType] VARCHAR(20) NOT NULL,
    [UpdatedDateTime] DATETIME NULL,
    [UserComments] VARCHAR(800) NULL,
    [CommandString] VARCHAR(MAX) NULL,
    CONSTRAINT [PK__MapLog__A815789D3AD4075E] PRIMARY KEY ([MapLogID])
);
GO
