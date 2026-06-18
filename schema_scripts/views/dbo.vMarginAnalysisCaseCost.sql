CREATE view [dbo].[vMarginAnalysisCaseCost] as

select
	sub.*
	--,RevCode1 as RevCode
from (

select
	cc.CostTxnId
	,cc.ORCase
	,cc.AnesCaseNum
	,cc.MRN
	,CONCAT('8~',SUBSTRING(cc.ADTCaseNum, PATINDEX('%[^0]%', cc.ADTCaseNum+'.'), LEN(cc.ADTCaseNum))) as VisitID
	,cc.ADTCaseNum
	,cc.TransDate
	,cc.Description
	,cc.ChargeGroup
	,cc.Quantity
	,cc.UnitCost
	,cc.ExtendedCost
	,cc.GeneratedDate
	,coalesce(cc.itemid, cc.implantid, cc.ni_implant_id) as ItemID
	,mi.ItemType
	,mi.ChargeCode
	,cdm.ChargeCodeDescription
	,cdm.RevCode
	,cdm.RevCodeDescription
	,110 as Facility
from [CORHPIVMAP14].[DATA_PIMS_OK_OklahomaCity_CommunityHospital].[dbo].PIMS_CaseCost cc
left join [CORHPIVMAP14].[DATA_PIMS_OK_OklahomaCity_CommunityHospital].[dbo].[PIMS_Materials_Item] mi on coalesce(cc.itemid, cc.implantid, cc.ni_implant_id) = mi.itemid
left join (SELECT * FROM openquery(hmsls, 
								  '	select
										ch.svccd ChargeCode
										,cd.DESC as ChargeCodeDescription
										,ch.inscd4 RevCode		
										,rc.LITRL as RevCodeDescription
									from mhd32.HOSPF110.CHGDHST ch
										left join mhd32.HOSPF110.CHRGDESC cd ON cd.SVCCD = ch.SVCCD
										left join MHD32.HOSPF100.INSCDSUM rc ON rc.INSCD4 = ch.INSCD4
									where CDMTERDT = ''9999-12-31''
									')) cdm ON  convert(varchar,cdm.ChargeCode) = convert(varchar,mi.ChargeCode)

union all

select
	cc.CostTxnId
	,cc.ORCase
	,cc.AnesCaseNum
	,cc.MRN
	,CONCAT('2~',SUBSTRING(cc.ADTCaseNum, PATINDEX('%[^0]%', cc.ADTCaseNum+'.'), LEN(cc.ADTCaseNum))) as VisitID
	,cc.ADTCaseNum
	,cc.TransDate
	,cc.Description
	,cc.ChargeGroup
	,cc.Quantity
	,cc.UnitCost
	,cc.ExtendedCost
	,cc.GeneratedDate
	,coalesce(cc.itemid, cc.implantid, cc.ni_implant_id) as ItemID
	,mi.ItemType
	,mi.ChargeCode
	,cdm.ChargeCodeDescription
	,cdm.RevCode
	,cdm.RevCodeDescription
	,100 as Facility
from [CORHPIVMAP14].[DATA_PIMS_OK_OklahomaCity_NorthwestSurgicalHospital].[dbo].PIMS_CaseCost cc
left join [CORHPIVMAP14].[DATA_PIMS_OK_OklahomaCity_NorthwestSurgicalHospital].[dbo].[PIMS_Materials_Item] mi on coalesce(cc.itemid, cc.implantid, cc.ni_implant_id) = mi.itemid
left join (SELECT * FROM openquery(hmsls, 
								  '	select
										ch.svccd ChargeCode
										,cd.DESC as ChargeCodeDescription
										,ch.inscd4 RevCode	
										,rc.LITRL as RevCodeDescription
									from mhd32.HOSPF100.CHGDHST ch
										left join mhd32.HOSPF100.CHRGDESC cd ON cd.SVCCD = ch.SVCCD
										left join MHD32.HOSPF100.INSCDSUM rc ON rc.INSCD4 = ch.INSCD4
									where CDMTERDT = ''9999-12-31''
									')) cdm ON convert(varchar,cdm.ChargeCode) = convert(varchar,mi.ChargeCode)) sub
--left join fact.MedhostChargeDesc cd on sub.Facility = cd.Facility and sub.ChargeCode = cd.ChargeCode and cd.IsActive = 1
where 
	sub.TransDate > DATEADD(year,-3,GETDATE())
	and sub.ExtendedCost <> 0
GO
