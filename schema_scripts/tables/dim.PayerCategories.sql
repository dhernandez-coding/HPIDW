CREATE TABLE [dim].[PayerCategories] (
    [PayerCategoryID] VARCHAR(50) NOT NULL,
    [PayerCategoryDataSourceID] INT NOT NULL,
    [PayerCategorySourceID] VARCHAR(50) NOT NULL,
    [PayerCategoryName] VARCHAR(100) NULL,
    [PayerCategoryIsActive] BIT NULL,
    [PayerCategoryUpdatedDatetime] DATETIME NULL,
    CONSTRAINT [PK__PayerCat__6051DC44C81B353B] PRIMARY KEY ([PayerCategoryID])
);
GO
