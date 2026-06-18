CREATE TABLE [dbo].[Platforms] (
    [PlatformID] INT IDENTITY(1,1) NOT NULL,
    [PlatformName] VARCHAR(100) NULL,
    [ParentPlatformID] INT NULL,
    [PlatformVendor] VARCHAR(100) NULL,
    [PlatformType] VARCHAR(100) NULL,
    [PlatformTenant] VARCHAR(100) NULL,
    [PlatformUrl] VARCHAR(300) NULL,
    [PlatformRefreshToken] VARCHAR(4000) NULL,
    [PlatformAccessToken] VARCHAR(4000) NULL,
    [PlatformIsActive] BIT NULL,
    [PlatformUpdateDatetime] DATETIME NULL,
    CONSTRAINT [PK__Platform__F559F6DA52750321] PRIMARY KEY ([PlatformID])
);
GO
