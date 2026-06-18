CREATE TABLE [dim].[Departments] (
    [DepartmentID] VARCHAR(50) NOT NULL,
    [DepartmentDataSourceID] INT NOT NULL,
    [DepartmentSourceID] VARCHAR(50) NOT NULL,
    [DepartmentName] VARCHAR(200) NULL,
    [DepartmentLocationID] VARCHAR(50) NULL,
    [DepartmentParentLocationID] VARCHAR(50) NULL,
    [DepartmentServiceAreaLocationID] VARCHAR(50) NULL,
    [DepartmentAbbreviation] VARCHAR(50) NULL,
    [DepartmentDescription] VARCHAR(200) NULL,
    [DepartmentStreetAddress1] VARCHAR(200) NULL,
    [DepartmentStreetAddress2] VARCHAR(200) NULL,
    [DepartmentCity] VARCHAR(200) NULL,
    [DepartmentState] VARCHAR(200) NULL,
    [DepartmentZipCode] VARCHAR(200) NULL,
    [DepartmentPhone] VARCHAR(50) NULL,
    [DepartmentFederalTaxID] VARCHAR(20) NULL,
    [DepartmentIsActive] BIT NULL,
    [DepartmentUpdatedDateTime] DATETIME NULL,
    CONSTRAINT [PK_Departments] PRIMARY KEY ([DepartmentID])
);
GO
