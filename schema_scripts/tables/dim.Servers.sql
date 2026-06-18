CREATE TABLE [dim].[Servers] (
    [ServerID] INT IDENTITY(1,1) NOT NULL,
    [ServerName] VARCHAR(250) NOT NULL,
    [ServerIPAddress] VARCHAR(50) NULL,
    CONSTRAINT [PK_Servers] PRIMARY KEY ([ServerID])
);
GO
