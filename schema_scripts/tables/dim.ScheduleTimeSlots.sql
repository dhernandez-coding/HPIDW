CREATE TABLE [dim].[ScheduleTimeSlots] (
    [ScheduleTimeSlotID] INT IDENTITY(1,1) NOT NULL,
    [ScheduleTimeSlotName] VARCHAR(100) NULL,
    [ScheduleTimeSlotInterval] VARCHAR(100) NOT NULL,
    [ScheduleTimeSlotStartTime] TIME NULL,
    [ScheduleTimeSlotEndTime] TIME NULL,
    [ScheduleTimeSlotMinutes] DECIMAL(18,2) NULL,
    [ScheduleTimeSlotUpdateDatetime] DATETIME NULL,
    CONSTRAINT [PK__Schedule__E3E3C1A88A8EA004] PRIMARY KEY ([ScheduleTimeSlotID])
);
GO
