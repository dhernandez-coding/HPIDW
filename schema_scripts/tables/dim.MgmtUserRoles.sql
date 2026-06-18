CREATE TABLE [dim].[MgmtUserRoles] (
    [RoleID] INT IDENTITY(1,1) NOT NULL,
    [RoleDesc] VARCHAR(100) NULL,
    [RoleIsActive] BIT NULL,
    [RoleCreateDatetime] DATETIME NULL,
    [RoleModifiedDatetime] DATETIME NULL,
    CONSTRAINT [PK_MgmtUserRoles] PRIMARY KEY ([RoleID])
);
GO
