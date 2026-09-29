CREATE TABLE [dim].[CPTCode_backup] (
    [CPTCodeID] VARCHAR(100) NOT NULL,
    [CPTCodeDatasourceID] INT NOT NULL,
    [CPTCode] VARCHAR(20) NULL,
    [RVU] NUMERIC(12,2) NULL,
    [CPTDescription] VARCHAR(254) NULL,
    [EffectiveStartDate] DATETIME NULL,
    [EffectiveEndDate] DATETIME NOT NULL,
    [CPTCodeIsActive] BIT NULL,
    [CPTCodeUpdatedDatetime] DATETIME NULL
);
GO
