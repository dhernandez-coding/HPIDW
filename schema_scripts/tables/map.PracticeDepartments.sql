CREATE TABLE [map].[PracticeDepartments] (
    [PracticeDepartmentID] INT IDENTITY(1,1) NOT NULL,
    [PracticeID] VARCHAR(100) NOT NULL,
    [DepartmentID] VARCHAR(100) NOT NULL,
    [PracticeDepartmentEffectiveDate] DATE NULL,
    [PracticeDepartmentEndDate] DATE NULL,
    [PracticeDepartmentIsActive] BIT NULL,
    [PracticeDepartmentUpdatedDatetime] DATETIME NULL,
    [PracticeIDNew] VARCHAR(10) NULL,
    CONSTRAINT [PK__Practice__DA9D289640CBDB53] PRIMARY KEY ([PracticeDepartmentID])
);
GO
