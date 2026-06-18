CREATE TABLE [dim].[Companies] (
    [CompanyID] INT IDENTITY(1,1) NOT NULL,
    [CompanyName] VARCHAR(200) NOT NULL,
    [CompanyServiceLine] VARCHAR(50) NULL,
    CONSTRAINT [PK_Companies] PRIMARY KEY ([CompanyID])
);
GO
