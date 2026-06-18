CREATE TABLE [fact].[VisitItems] (
    [VisitItemDatasourceID] INT NOT NULL,
    [AccountID] VARCHAR(100) NOT NULL,
    [VisitID] VARCHAR(100) NULL,
    [VisitCaseID] VARCHAR(100) NULL,
    [ItemID] VARCHAR(100) NULL,
    [ItemChargeCode] VARCHAR(100) NULL,
    [ItemRevenueCode] VARCHAR(100) NULL,
    [ItemRevenueCodeDescription] VARCHAR(100) NULL,
    [ItemDescription] VARCHAR(1000) NULL,
    [ItemType] VARCHAR(100) NULL,
    [ItemSubtype] VARCHAR(100) NULL,
    [VisitItemQuantity] DECIMAL(18,2) NULL,
    [VisitItemUnitCost] MONEY NULL,
    [VisitItemExtendedCost] MONEY NULL,
    [VisitItemUsedDate] DATE NULL,
    [VisitItemIsChargeable] BIT NULL,
    [VisitItemIsActive] BIT NULL,
    [VisitItemUpdatedDatetime] DATETIME NULL
);
GO
