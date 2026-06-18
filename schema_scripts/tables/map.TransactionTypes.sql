CREATE TABLE [map].[TransactionTypes] (
    [TransactionTypeID] VARCHAR(200) NOT NULL,
    [DataSourceID] INT NOT NULL,
    [TransactionCodeDescription] VARCHAR(200) NULL,
    [TransactionType] VARCHAR(200) NULL,
    CONSTRAINT [PK_TransactionCodeDescriptionTypes] PRIMARY KEY ([TransactionTypeID])
);
GO
