CREATE TABLE [app].[TransactionCompareSummary] (
    [RunID] INT NOT NULL,
    [PostingMonth] DATE NOT NULL,
    [ProdRows] INT NULL,
    [AppRows] INT NULL,
    [Transactions] INT NULL,
    [PracticeMatches] INT NULL,
    [GLMatches] INT NULL,
    [Mismatches] INT NULL,
    [ProdDuplicateTxns] INT NULL,
    [StartedAt] DATETIME NOT NULL DEFAULT (getdate()),
    [FinishedAt] DATETIME NULL,
    CONSTRAINT [PK_app_TransactionCompareSummary] PRIMARY KEY ([RunID], [PostingMonth])
);
GO
