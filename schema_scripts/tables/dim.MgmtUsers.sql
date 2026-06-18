CREATE TABLE [dim].[MgmtUsers] (
    [UserID] INT IDENTITY(1,1) NOT NULL,
    [UserEmail] VARCHAR(100) NULL,
    [UserPIN] CHAR(6) NULL,
    [UserRoleID] INT NULL,
    [UserIsActive] BIT NULL,
    [UserCreateDate] DATE NULL,
    [UserModifiedDate] DATE NULL,
    CONSTRAINT [PK_MgmtUsers] PRIMARY KEY ([UserID])
);
GO
