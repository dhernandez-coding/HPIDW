CREATE TABLE [map].[PayerPlanFeeSchedules] (
    [PayerPlanFeeScheduleID] VARCHAR(100) NOT NULL,
    [PayerPlanID] VARCHAR(100) NOT NULL,
    [FeeScheduleID] VARCHAR(100) NOT NULL,
    [PayerPlanFeeScheduleIsActive] BIT NULL,
    [PayerPlanFeeScheduleUpdatedDatetime] DATETIME NULL,
    CONSTRAINT [PK__PayerPla__672E127D94C651BE] PRIMARY KEY ([PayerPlanFeeScheduleID])
);
GO
