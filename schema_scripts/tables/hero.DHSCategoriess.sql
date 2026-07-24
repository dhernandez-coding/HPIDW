CREATE TABLE [hero].[DHSCategoriess] (
    [DHSCategoryID] INT NOT NULL,
    [DHSCategoryName] NVARCHAR(MAX) NOT NULL,
    [DHSCategoryIsActive] BIT NOT NULL,
    [DHSCategoryCreatedDate] DATETIME2 NOT NULL,
    [DHSCategoryCreatedByUserID] FLOAT NOT NULL,
    [DHSCategoryModifiedDate] DATETIME2 NOT NULL,
    [DHSCategoryModifiedByUserID] FLOAT NOT NULL,
    [CreatedDate] DATETIME2 NULL,
    [ModifiedDate] DATETIME2 NULL,
    [ModifiedBy] NVARCHAR(MAX) NULL,
    [DeletedDate] DATETIME2 NULL,
    [DeletedBy] NVARCHAR(MAX) NULL,
    [IsDeleted] BIT NOT NULL,
    [IsActive] BIT NOT NULL
);
GO
