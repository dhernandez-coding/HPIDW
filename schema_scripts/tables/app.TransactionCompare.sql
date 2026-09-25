CREATE TABLE [app].[TransactionCompare] (
    [RunID] INT NOT NULL,
    [PostingMonth] DATE NOT NULL,
    [TransactionID] VARCHAR(100) NOT NULL,
    [ProdRowCount] INT NULL,
    [AppRowCount] INT NULL,
    [ProdPracticeID] VARCHAR(100) NULL,
    [AppPracticeID] VARCHAR(100) NULL,
    [ProdGLSegmentLocation] VARCHAR(10) NULL,
    [AppGLSegmentLocation] VARCHAR(10) NULL,
    [ProdGLSegmentPractice] VARCHAR(10) NULL,
    [AppGLSegmentPractice] VARCHAR(10) NULL,
    [ProdGLSegmentProvider] VARCHAR(20) NULL,
    [AppGLSegmentProvider] VARCHAR(20) NULL,
    [TransactionDepartmentID] VARCHAR(100) NULL,
    [TransactionBillingProviderID] VARCHAR(100) NULL,
    [ComparedAt] DATETIME NOT NULL DEFAULT (getdate()),
    CONSTRAINT [PK_app_TransactionCompare] PRIMARY KEY ([RunID], [TransactionID])
);
GO
