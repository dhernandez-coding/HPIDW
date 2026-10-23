CREATE TABLE [dim].[CPTCode] (
    [CPTCodeID] VARCHAR(100) NOT NULL,
    [CPTCodeDatasourceID] INT NOT NULL,
    [CPTCode] VARCHAR(20) NULL,
    [RVU] NUMERIC(12,2) NULL,
    [CPTDescription] VARCHAR(254) NULL,
    [EffectiveStartDate] DATETIME NULL,
    [EffectiveEndDate] DATETIME NOT NULL,
    [CPTCodeIsActive] BIT NULL,
    [CPTCodeUpdatedDatetime] DATETIME NULL,
    CONSTRAINT [PK__CPTCode___E8517A80BA5B2A13] PRIMARY KEY ([CPTCodeID])
);
GO
