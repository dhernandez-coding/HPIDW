/****** Script for SelectTopNRows command from SSMS  ******/
CREATE PROCEDURE [stg].[spMedhostCHReloadFactVisitItemsFull]
as

DELETE FROM fact.VisitItems WHERE VisitItemDataSourceID = 8

INSERT INTO fact.VisitItems
([VisitItemDatasourceID]
      ,[AccountID]
      ,[VisitID]
      ,[VisitCaseID]
      ,[ItemID]
      ,[ItemChargeCode]
      ,[ItemRevenueCode]
      ,[ItemRevenueCodeDescription]
      ,[ItemDescription]
      ,[ItemType]
      ,[ItemSubtype]
      ,[VisitItemQuantity]
      ,[VisitItemUnitCost]
      ,[VisitItemExtendedCost]
      ,[VisitItemUsedDate]
	  ,[VisitItemIsChargeable]
      ,[VisitItemIsActive]
      ,[VisitItemUpdatedDatetime]
	  )
SELECT
	--top 100
	--CONCAT('8~',cc.CostTxnID) [VisitItemID]
	8 as [VisitItemDatasourceID]
	,CONCAT('8~', cc.ADTCaseNum) [AccountID]
	,CONCAT('8~', cc.ADTCaseNum) [VisitID]
	,CONCAT('8~', cc.ORCase) [VisitCaseID]
	,CONCAT('8~',coalesce(cc.itemid, cc.implantid, cc.ni_implant_id)) as [ItemID]
	,mi.ChargeCode [ItemChargeCode]
	,cdm.RevCode [ItemRevenueCode]
	,cdm.RevCodeDescription [ItemRevenueCodeDescription]
	,mi.LongDesc [ItemDescription]	
	,CASE WHEN mi.ChargeCode in (4031078,4093238,4099322,4099323) THEN 'Monitoring' 
		  WHEN cdm.RevCode = '302' THEN 'Cell Savers'
		  ELSE cc.ChargeGroup END as [ItemType]
	,it.ShortDesc [ItemSubtype]
	,cc.Quantity [VisitItemQuantity]
	,cc.UnitCost [VisitItemUnitCost]
	,cc.ExtendedCost [VisitItemExtendedCost]
	,cc.TransDate [VisitItemUsedDate]
	,1 as [VisitItemIsChargeable]
	,case
		when mi.inactive = 0 then 1 else 0 end [VisitItemIsActive]
	,getdate() AS VisitItemUpdatedDatetime
--select top 100 * --from [CORHPIVMAP14].[DATA_PIMS_OK_OklahomaCity_CommunityHospital].[dbo].ORSched where ORCase = 17102069704
from [CORHPIVMAP14].[DATA_PIMS_OK_OklahomaCity_CommunityHospital].[dbo].PIMS_CaseCost cc
left join [CORHPIVMAP14].[DATA_PIMS_OK_OklahomaCity_CommunityHospital].[dbo].[PIMS_Materials_Item] mi on coalesce(cc.itemid, cc.implantid, cc.ni_implant_id) = mi.itemid
left join [CORHPIVMAP14].[DATA_PIMS_OK_OklahomaCity_CommunityHospital].dbo.pims_materials_item_type it on mi.itemtype = it.ItemType
left join
--select * from
	openquery(hmsls, 
		'	select
			ch.svccd ChargeCode
			,cd.DESC as ChargeCodeDescription
			,ch.inscd4 RevCode		
			,rc.LITRL as RevCodeDescription
		from mhd32.HOSPF110.CHGDHST ch
			left join mhd32.HOSPF110.CHRGDESC cd ON cd.SVCCD = ch.SVCCD
			left join MHD32.HOSPF110.INSCDSUM rc ON rc.INSCD4 = ch.INSCD4
		where CDMTERDT = ''9999-12-31''
		') cdm ON  convert(varchar,cdm.ChargeCode) = convert(varchar,mi.ChargeCode)
where 1=1 
AND cc.TransDate >= '1/1/2016' /*Limited to just 2018 forward*/

--UNION ALL 
/*Add Medications*/
INSERT INTO fact.VisitItems
([VisitItemDatasourceID]
      ,[AccountID]
      ,[VisitID]
      ,[VisitCaseID]
      ,[ItemID]
      ,[ItemChargeCode]
      ,[ItemRevenueCode]
      ,[ItemRevenueCodeDescription]
      ,[ItemDescription]
      ,[ItemType]
      ,[ItemSubtype]
      ,[VisitItemQuantity]
      ,[VisitItemUnitCost]
      ,[VisitItemExtendedCost]
      ,[VisitItemUsedDate]
	  ,[VisitItemIsChargeable]
      ,[VisitItemIsActive]
      ,[VisitItemUpdatedDatetime]
	  )
select 
	--CONCAT('8~CHG~',c.PATNO,'~',c.BATCH,'~',c.SEQ#,'~',c.REF#,'~',c.SVCCD) [VisitItemID]
	8 as [VisitItemDatasourceID]
	,CONCAT('8~', c.PATNO) [AccountID]
	,CONCAT('8~', c.PATNO) [VisitID]
	,NULL as [VisitCaseID]
	,CONCAT('8~',c.ChargeCode) as [ItemID]
	,c.ChargeCode [ItemChargeCode]
	,c.RevenueCode [ItemRevenueCode]
	,c.RevenueCodeDescription [ItemRevenueCodeDescription]
	,c.ChargeDescription [ItemDescription]	
	,'Medications' as [ItemType]
	,c.RevenueCodeDescription as [ItemSubtype]
	,c.Quantity [VisitItemQuantity]
	,c.FixedCost [VisitItemUnitCost]
	,c.FixedCost * c.Quantity as [VisitItemExtendedCost]
	,c.UsedDate as [VisitItemUsedDate]
	,1 as [VisitItemIsChargeable]
	,1 as [VisitItemIsActive]
	,getdate() AS VisitItemUpdatedDatetime
FROM OPENQUERY([hmsls],'
	select 
	c.PATNO as VisitSourceID
	,c.SVCCD as ChargeCode
	,cd.DESC AS ChargeDescription
	,c.INSCD as RevenueCode
	,rc.LITRL as RevenueCodeDescription
	,cd.FCOST AS FixedCost
	,c.QTY as Quantity
	,c.Amt1 as ChargeAmount
	,C.ISDATE AS UsedDate
	,c.*
	from MHD32.HOSPF110.ACCUMCHG c
		left join MHD32.HOSPF110.CHRGDESC cd ON cd.SVCCD = c.SVCCD
		left join MHD32.HOSPF110.INSCDSUM rc ON rc.INSCD4 = c.INSCD
	where 1=1 
	AND CAST(ISPDATEA as DATE) >= ''1/1/2016''--(CURRENT_DATE - 10 DAYS)  /*Exclude older transactions for processing sake*/
	AND (c.INSCD IS NULL OR c.INSCD > 8) /*Exclude Payments and Adjustments*/
	AND c.INSCD IN (250,251,252,255,257,258,259,630,631,632,633,634,635,636) /*Medications*/
	AND cd.FCOST <> 0
	') c
GO
