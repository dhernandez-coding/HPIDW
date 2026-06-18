CREATE TABLE [map].[PayerCategories] (
    [PayerCategoryID] INT IDENTITY(1,1) NOT NULL,
    [DataSourceID] INT NOT NULL,
    [PayerCategory] VARCHAR(200) NOT NULL,
    [PayerSubCategory] VARCHAR(200) NOT NULL,
    CONSTRAINT [PK_PayerCategories] PRIMARY KEY ([PayerCategoryID])
);
GO
