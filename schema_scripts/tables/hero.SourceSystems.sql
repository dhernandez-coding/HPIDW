CREATE TABLE [hero].[SourceSystems] (
    [Id] INT NOT NULL,
    [Name] NVARCHAR(MAX) NOT NULL,
    [Description] NVARCHAR(MAX) NOT NULL,
    [Value] NVARCHAR(MAX) NOT NULL,
    [CreatedDate] DATETIME2 NULL,
    [ModifiedDate] DATETIME2 NULL,
    [ModifiedBy] NVARCHAR(MAX) NULL,
    [DeletedDate] DATETIME2 NULL,
    [DeletedBy] NVARCHAR(MAX) NULL,
    [IsDeleted] BIT NOT NULL,
    [IsActive] BIT NOT NULL
);
GO
