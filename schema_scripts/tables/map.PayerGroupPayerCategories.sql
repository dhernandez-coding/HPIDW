CREATE TABLE [map].[PayerGroupPayerCategories] (
    [PayerGroupPayerCategoryID] INT IDENTITY(1,1) NOT NULL,
    [PayerGroupID] VARCHAR(100) NOT NULL,
    [PayerCategoryID] VARCHAR(100) NOT NULL,
    [PayerGroupPayerCategoryIsActive] BIT NULL,
    [PayerGroupPayerCategoryUpdatedDatetime] DATETIME NULL,
    CONSTRAINT [PK__PayerGro__64C0B440D1AC5E7B] PRIMARY KEY ([PayerGroupPayerCategoryID])
);
GO
