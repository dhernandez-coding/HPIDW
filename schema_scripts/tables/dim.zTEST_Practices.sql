CREATE TABLE [dim].[zTEST_Practices] (
    [PracticeID] VARCHAR(100) NOT NULL,
    [PracticeDataSourceID] INT NULL,
    [PracticeSourceID] VARCHAR(100) NULL,
    [PracticeName] VARCHAR(100) NULL,
    [PracticeAbbreviation] VARCHAR(30) NULL,
    [PracticeDataSource] VARCHAR(30) NULL,
    [PracticeCompany] VARCHAR(30) NULL,
    [PracticeGLLocationID] VARCHAR(10) NULL,
    [PracticeGLLocation] VARCHAR(50) NULL,
    [PracticeGLPracticeID] VARCHAR(10) NULL,
    [PracticeSpecialty] VARCHAR(30) NULL,
    [PracticeIsSameStore] BIT NULL,
    [PracticeIsActive] BIT NULL,
    [PracticeUpdatedDatetime] DATETIME NULL
);
GO
