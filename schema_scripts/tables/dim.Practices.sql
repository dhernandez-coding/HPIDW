CREATE TABLE [dim].[Practices] (
    [PracticeID] VARCHAR(100) NOT NULL,
    [PracticeDataSourceID] INT NULL,
    [PracticeSourceID] VARCHAR(100) NULL,
    [PracticeName] VARCHAR(100) NULL,
    [PracticeAbbreviation] VARCHAR(30) NULL,
    [PracticeDataSource] VARCHAR(30) NULL,
    [PracticeCompany] VARCHAR(30) NULL,
    [PracticeIsActive] BIT NULL,
    [PracticeIsSameStore] BIT NULL,
    [PracticeUpdatedDatetime] DATETIME NULL,
    [PracticeGLLocationID] VARCHAR(10) NULL,
    [PracticeGLLocation] VARCHAR(50) NULL,
    [PracticeGLPracticeID] VARCHAR(10) NULL,
    [PracticeSpecialty] VARCHAR(10) NULL,
    [PracticeSameStoreDate] DATE NULL,
    CONSTRAINT [PK__Practice__352A161230D0E8CA] PRIMARY KEY ([PracticeID])
);
GO
