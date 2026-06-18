CREATE TABLE [fact].[Coding] (
    [CodingAccountID] VARCHAR(50) NOT NULL,
    [CodingDataSource] INT NULL,
    [CodingAccountSourceID] VARCHAR(50) NULL,
    [CodingSequence] INT NULL,
    [CodingStatusDate] DATETIME NULL,
    [CodingStatusComment] VARCHAR(255) NULL,
    [CodingStatus] VARCHAR(50) NULL,
    [CodingUser] VARCHAR(50) NULL,
    [CodingUpdateDate] DATETIME NULL
);
GO
