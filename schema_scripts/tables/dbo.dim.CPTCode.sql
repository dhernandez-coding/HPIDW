CREATE TABLE [dbo].[dim.CPTCode] (
    [ProcedureID] VARCHAR(20) NULL,
    [CPTCodeDataSourceID] INT NULL,
    [CPTCode] VARCHAR(10) NULL,
    [ProcedureName] VARCHAR(100) NULL,
    [RVU] INT NULL,
    [DataSourceName] VARCHAR(50) NULL,
    [EffectiveStartDate] DATE NULL,
    [EffectiveEndDate] DATE NULL
);
GO
