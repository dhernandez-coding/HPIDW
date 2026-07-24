CREATE TABLE [hero].[Companiess] (
    [CompanyID] INT NOT NULL,
    [CompanyName] NVARCHAR(MAX) NOT NULL,
    [CreatedDate] DATETIME2 NULL,
    [ModifiedDate] DATETIME2 NULL,
    [ModifiedBy] NVARCHAR(MAX) NULL,
    [DeletedDate] DATETIME2 NULL,
    [DeletedBy] NVARCHAR(MAX) NULL,
    [IsDeleted] BIT NOT NULL,
    [IsActive] BIT NOT NULL
);
GO
