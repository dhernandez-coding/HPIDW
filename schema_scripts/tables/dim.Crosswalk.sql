CREATE TABLE [dim].[Crosswalk] (
    [DW_DepartmentID] NVARCHAR(50) NOT NULL,
    [DW_DepartmentSourceID] BIGINT NULL,
    [DW_DepartmentName] NVARCHAR(50) NULL,
    [UKG_Department] NVARCHAR(50) NOT NULL,
    [Assumed_Service_Unit] NVARCHAR(50) NOT NULL,
    CONSTRAINT [PK_Crosswalk] PRIMARY KEY ([DW_DepartmentID])
);
GO
