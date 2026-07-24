CREATE TABLE [hero].[Specialtiess] (
    [SpecialtyID] INT NOT NULL,
    [SpecialtyName] NVARCHAR(MAX) NOT NULL,
    [SpecialtyIsActive] BIT NOT NULL,
    [SpecialtyCreatedDate] DATETIME2 NOT NULL,
    [SpecialtyCreatedByUserID] FLOAT NOT NULL,
    [SpecialtyModifiedDate] DATETIME2 NOT NULL,
    [SpecialtyModifiedByUserID] FLOAT NOT NULL,
    [CreatedDate] DATETIME2 NULL,
    [ModifiedDate] DATETIME2 NULL,
    [ModifiedBy] NVARCHAR(MAX) NULL,
    [DeletedDate] DATETIME2 NULL,
    [DeletedBy] NVARCHAR(MAX) NULL,
    [IsDeleted] BIT NOT NULL,
    [IsActive] BIT NOT NULL
);
GO
