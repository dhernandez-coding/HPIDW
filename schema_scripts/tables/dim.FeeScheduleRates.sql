CREATE TABLE [dim].[FeeScheduleRates] (
    [FeeScheduleRateID] VARCHAR(100) NOT NULL,
    [FeeScheduleID] VARCHAR(100) NOT NULL,
    [FeeScheduleYear] VARCHAR(4) NULL,
    [FeeScheduleProcedureCode] VARCHAR(10) NULL,
    [FeeScheduleModifier] VARCHAR(10) NULL,
    [FeeScheduleNonFacilityRate] DECIMAL(18,4) NULL,
    [FeeScheduleFacilityRate] DECIMAL(18,4) NULL,
    [FeeScheduleIsActive] BIT NULL,
    [FeeScheduleUpdatedDatetime] DATETIME NULL,
    [FeeScheduleFacilityRateMidLevel] DECIMAL(18,4) NULL,
    [FeeScheduleNonFacilityRateMidLevel] DECIMAL(18,4) NULL,
    CONSTRAINT [PK__FeeSched__163CFBD622F37021] PRIMARY KEY ([FeeScheduleRateID])
);
GO
