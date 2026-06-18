CREATE VIEW [fact].[vVisitItems]
AS
SELECT        VisitItemDatasourceID
, AccountID
, VisitID
, VisitCaseID, ItemID, ItemChargeCode, ItemRevenueCode, ItemRevenueCodeDescription, ItemDescription, ItemType, ItemSubtype, VisitItemQuantity, VisitItemUnitCost, 
                         VisitItemExtendedCost, VisitItemUsedDate, VisitItemIsChargeable, VisitItemIsActive, VisitItemUpdatedDatetime
FROM            fact.VisitItems
WHERE        (YEAR(VisitItemUsedDate) >= YEAR(GETDATE()) - 2)
GO
