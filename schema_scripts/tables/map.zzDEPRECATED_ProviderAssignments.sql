CREATE TABLE [map].[zzDEPRECATED_ProviderAssignments] (
    [ProviderAssignmentID] INT IDENTITY(1,1) NOT NULL,
    [DataSourceID] INT NOT NULL,
    [ProviderAssignmentType] VARCHAR(50) NOT NULL,
    [ProviderAssignmentProviderID] VARCHAR(50) NOT NULL,
    [ProviderAssignmentProviderType] VARCHAR(50) NULL,
    [ProviderAssignmentWorksForID] VARCHAR(50) NULL,
    [ProviderAssignmentSplit] VARCHAR(50) NULL,
    CONSTRAINT [PK_ProviderAssignments] PRIMARY KEY ([ProviderAssignmentID])
);
GO
