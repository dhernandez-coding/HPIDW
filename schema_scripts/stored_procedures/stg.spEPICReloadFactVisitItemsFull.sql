/****** Script for SelectTopNRows command from SSMS  ******/
CREATE PROCEDURE [stg].[spEPICReloadFactVisitItemsFull]
as

DELETE FROM fact.VisitItems WHERE VisitItemDataSourceID = 5


/*Supplies, Implants, and Medications*/
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
	--CONCAT('5~',si.LOG_ID,'~',si.ITEM_ID,'~',ISNULL(si.IMPLANT_ID,0),'~',si.REASON_WASTED_NM,'~',si.COST_PER_UNIT,'~',si.INVENTORY_LOCATION_ID,'~',si.CHARGEABLE_YN) as VisitItemID
	5 as VisitItemDataSourceID
	,CONCAT('5~',hsp.HSP_ACCOUNT_ID) as AccountID
	,CONCAT('5~',orl.OR_LINK_CSN) as VisitID
	,CONCAT('5~',orl.OR_CASELOG_ID) as VisitCaseID
	,CONCAT('5~',COALESCE(si.ITEM_ID, si.IMPLANT_ID)) as ItemID
	,s.CHARGE_CODE as ItemChargeCode
	,NULL AS ItemRevenueCode
	,NULL AS ItemRevenueCodeDescription
	,COALESCE(si.ITEM_NM, si.IMPLANT_NM) AS ItemDescription
	,CASE WHEN si.ITEM_ID in (163333,163068,169485) THEN 'Monitoring'
	      WHEN si.ITEM_ID in (151738,156376) THEN 'Cell Savers'
		  WHEN si.ITEM_TYPE = 'Supply' THEN 'Supplies'
		  WHEN si.ITEM_TYPE = 'Implant' THEN 'Implants'
		  ELSE si.ITEM_TYPE END as ItemType
	,si.TYPE_NM as ItemSubtype
	,ISNULL(si.NUMBER_USED,0) + ISNULL(si.NUMBER_WASTED,0) AS VisitItemQuantity
	,ISNULL(si.COST_PER_UNIT,0) AS VisitItemUnitCost
	,ISNULL(CASE WHEN si.ITEM_TYPE = 'Supply' THEN (ISNULL(si.NUMBER_USED,0) + ISNULL(si.NUMBER_WASTED,0)) * ISNULL(si.COST_PER_UNIT,0) 
		  WHEN si.ITEM_TYPE = 'Implant' AND si.CHARGEABLE_YN = 'Y' THEN (ISNULL(si.NUMBER_USED,0) + ISNULL(si.NUMBER_WASTED,0)) * ISNULL(si.COST_PER_UNIT,0) END, 0) as VisitItemExtendedCost
	,CONVERT(DATE,enc.EFFECTIVE_DATE_DTTM) as VisitItemUsedDate
	,CASE WHEN si.CHARGEABLE_YN = 'Y' THEN 1 ELSE 0 END as VisitItemIsChargeable
	,1 as VisitItemIsActive
	,GETDATE()
	--SELECT si.*
from [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[v_log_supplies_implants] si 
	left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].PAT_OR_ADM_LINK orl ON orl.OR_CASELOG_ID = si.CASE_ID
	left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].PAT_ENC enc ON enc.PAT_ENC_CSN_ID = orl.PAT_ENC_CSN_ID
	left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].PAT_ENC_HSP hsp ON hsp.PAT_ENC_CSN_ID = orl.OR_LINK_CSN 
	left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].OR_SPLY s ON s.SUPPLY_ID = si.ITEM_ID AND si.ITEM_TYPE = 'Supply'
	left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].OR_IMP i ON i.IMPLANT_ID = si.IMPLANT_ID AND si.ITEM_TYPE = 'Implant'
	left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].clarity_dep cd on enc.effective_dept_id = cd.department_id
	left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].clarity_loc cl on cd.rev_loc_id = cl.loc_id
where 1=1 
	--and si.LOG_ID = 2046
	--and si.CASE_ID in (2047,2046)
	and cl.serv_area_id in ('425', '430')


/*Medications*/
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
	--CONCAT('5~',si.LOG_ID,'~',si.ITEM_ID,'~',ISNULL(si.IMPLANT_ID,0),'~',si.REASON_WASTED_NM,'~',si.COST_PER_UNIT,'~',si.INVENTORY_LOCATION_ID,'~',si.CHARGEABLE_YN) as VisitItemID
	5 as VisitItemDataSourceID
	,CONCAT('5~',tx.HSP_ACCOUNT_ID) as AccountID
	,CONCAT('5~',hsp.PRIM_ENC_CSN_ID) as VisitID
	,null as VisitCaseID
	,CASE WHEN ord.MEDICATION_ID IS NOT NULL THEN CONCAT('5~','MED~',ord.MEDICATION_ID) END as ItemID
	,coalesce(tx.HCPCS_CODE, tx.CPT_CODE) as ItemChargeCode
	,rc.REVENUE_CODE as ItemRevenueCode
	,rc.BILL_DESC AS ItemRevenueCodeDescription
	,tx.PROCEDURE_DESC AS ItemDescription
	,'Medications' as ItemType
	,'Medications' as ItemSubtype
	,ISNULL(tx.QUANTITY,0) AS VisitItemQuantity
	,CASE WHEN ISNULL(tx.QUANTITY,0) = 0 THEN ISNULL(tx.COST,0) ELSE ISNULL(tx.COST,0) / ISNULL(tx.QUANTITY,1) END AS VisitItemUnitCost
	,ISNULL(tx.COST,0) as VisitItemExtendedCost
	,CONVERT(DATE,tx.SERVICE_DATE) as VisitItemUsedDate
	,1 as VisitItemIsChargeable
	,1 as VisitItemIsActive
	,GETDATE()
	--SELECT top 100 et.NAME,TX.procedure_desc, ord.*
from [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[HSP_TRANSACTIONS] tx 
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[HSP_ACCOUNT] hsp ON hsp.HSP_ACCOUNT_ID = tx.HSP_ACCOUNT_ID 
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].CL_UB_REV_CODE rc ON rc.UB_REV_CODE_ID = tx.UB_REV_CODE_ID	
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].ORDER_MED ord ON ord.ORDER_MED_ID = tx.ORDER_ID
	--LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].CLARITY_MEDICATION med ON med.MEDICATION_ID = ord.MEDICATION_ID
	--LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_PHARM_CLASS pc ON pc.PHARM_CLASS_C = med.PHARM_CLASS_C
	--LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].CLARITY_EAP eap ON eap.PROC_ID = tx.PROC_ID
where 1=1 
 AND tx.TX_TYPE_HA_C in (1)
 AND tx.SERV_AREA_ID in (425,430)
 AND tx.DFLT_UB_REV_CD_ID in (250,251,252,254,255,256,257,258,259,630,631,632,633,634,635,636) /*Pharmacy*/
 AND hsp.PRIM_ENC_CSN_ID is not null
GO
