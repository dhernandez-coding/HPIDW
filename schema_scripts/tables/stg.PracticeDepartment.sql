CREATE TABLE [stg].[PracticeDepartment] (
    [PracticeID] VARCHAR(100) NOT NULL,
    [DepartmentID] VARCHAR(100) NOT NULL,
    [PracticeDepartmentEffectiveDate] DATE NULL,
    [PracticeDepartmentEndDate] DATE NULL,
    [PracticeDepartmentIsActive] BIT NULL,
    [PracticeDepartmentUpdatedDatetime] DATETIME NULL,
    [PracticeIDNew] VARCHAR(10) NULL
);
GO
