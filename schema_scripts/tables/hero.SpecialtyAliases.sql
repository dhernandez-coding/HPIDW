CREATE TABLE [hero].[SpecialtyAliases] (
    [Id] INT NULL,
    [Name] NVARCHAR(MAX) NULL,
    [Description] NVARCHAR(MAX) NULL,
    [Value] NVARCHAR(MAX) NULL,
    [SpecialtyId] INT NULL,
    [SourceSystemId] INT NULL,
    [CreatedDate] DATETIME2 NULL,
    [ModifiedDate] DATETIME2 NULL,
    [ModifiedBy] NVARCHAR(MAX) NULL,
    [DeletedDate] DATETIME2 NULL,
    [DeletedBy] NVARCHAR(MAX) NULL,
    [IsDeleted] BIT NULL,
    [IsActive] BIT NULL
);
GO
