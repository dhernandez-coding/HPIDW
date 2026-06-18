CREATE TABLE [map].[VisitServiceLineDepartment] (
    [ID] INT IDENTITY(1,1) NOT NULL,
    [ServiceLineID] VARCHAR(100) NOT NULL,
    [DepartmentID] VARCHAR(50) NOT NULL,
    [ServiceLineDeptLinkingMgmtUserID] INT NULL,
    [ServiceLineDeptLinkingCreatedDatetime] DATETIME NULL,
    [ServiceLinkDeptLinkingUpdatedDatetime] DATETIME NULL,
    [ServiceLineDeptLinkingIsActive] BIT NULL,
    CONSTRAINT [PK__ServiceLineDepartmentID] PRIMARY KEY ([ID])
);
GO
