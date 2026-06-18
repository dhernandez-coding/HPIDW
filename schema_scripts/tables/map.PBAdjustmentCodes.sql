CREATE TABLE [map].[PBAdjustmentCodes] (
    [PBAdjustmentCodeID] VARCHAR(100) NOT NULL,
    [PBAdjustmentCodeDescription] VARCHAR(100) NULL,
    [PBAdjustmentCodeCategory] VARCHAR(100) NULL,
    [PBAdjustmentCodeUpdatedDatetime] DATETIME NULL,
    CONSTRAINT [PK__PBAdjust__772BBE865E53F1FA] PRIMARY KEY ([PBAdjustmentCodeID])
);
GO
