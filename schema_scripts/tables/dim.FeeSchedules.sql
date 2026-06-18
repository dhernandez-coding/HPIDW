CREATE TABLE [dim].[FeeSchedules] (
    [FeeScheduleID] VARCHAR(100) NOT NULL,
    [FeeScheduleName] VARCHAR(100) NULL,
    [FeeScheduleIsActive] BIT NULL,
    [FeeScheduleRateMultiplier] DECIMAL(18,4) NULL,
    [FeeScheduleUpdatedDatetime] DATETIME NULL,
    CONSTRAINT [PK__FeeSched__C0F7BAD0B3C7C334] PRIMARY KEY ([FeeScheduleID])
);
GO
