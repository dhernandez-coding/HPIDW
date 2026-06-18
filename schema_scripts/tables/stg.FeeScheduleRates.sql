CREATE TABLE [stg].[FeeScheduleRates] (
    [FeeScheduleRateID] VARCHAR(100) NOT NULL,
    [FeeScheduleID] VARCHAR(100) NOT NULL,
    [FeeScheduleYear] VARCHAR(4) NULL,
    [FeeScheduleProcedureCode] VARCHAR(10) NULL,
    [FeeScheduleModifier] VARCHAR(10) NULL,
    [FeeScheduleNonFacilityRate] DECIMAL(18,4) NULL,
    [FeeScheduleFacilityRate] DECIMAL(18,4) NULL,
    [FeeScheduleIsActive] BIT NULL,
    [FeeScheduleUpdatedDatetime] DATETIME NULL,
    CONSTRAINT [PK__FeeSched__163CFBD62B53A6E1] PRIMARY KEY ([FeeScheduleRateID])
);
GO
