CREATE view [dim].[vProcedureCodes] 
as

/*Chris Cross - 6/2/2026 - This may be ready to deprecate now that we've moved to [HERO-DB]*/
select * from (
 Select 
    --[ProcedureCodeID]
  Concat(pc.DataSourceId, Concat('~', pc.[SourceID])) as ProcedureCodeID
      --[ProcedureCodeDataSourceID]
	  ,pc.DataSourceId as ProcedureCodeDataSourceID
      ,--[ProcedureCodeSourceID]
	  pc.[SourceID] as ProcedureCodeSourceID
      ,--[ProcedureCode]
	  pc.ProcedureCode
      ,--[ProcedureCodeInsuranceDescription]
	  pc.[ProcedureCodeInsuranceDescription]
      ,--[ProcedureCodeStatementDescription]
	  pc.ProcedureCodeStatementDescription
      ,--[ProcedureCodeType]
	  pc.ProcedureCodeType
      ,--[ProcedureCodeCategoryID]
	  pc.ProcedureCodeSubCategoryID
      ,--[ProcedureCodeCategoryAbbreviation]
	  pcsubc.ProcedureCodeCategoryAbbreviation
      ,--[ProcedureCodeCategoryDescription]
	  pcsubc.ProcedureCodeCategoryDescription
      ,--[ProcedureCodeSelfPay]
	  pc.ProcedureCodeSelfPay
      ,--[ProcedureCodeEnableSplitBilling]
	  pc.ProcedureCodeEnableSplitBilling
      ,--[ProcedureCodeInfusion]
	  pc.ProcedureCodeInfusion
      ,--[ProcedureCodeIsActive]
	  pc.ProcedureCodeCategoryId,

	  Case
	  when pc.IsDeleted = 1 then 0
	  else 1
	  end as ProcedureCodeIsActive
      ,--[ProcedureCodeUpdatedDateTime]
	  pc.ProcedureCodeUpdatedDateTime 
  
From HPIAPP.dbo.PbProcedureCodes pc
Left Join HPIApp.dbo.PBProcedureCategories pcc on pc.ProcedureCodeCategoryId = pcc.Id
Left Join HPIApp.dbo.ServiceLines sl on pc.ProcedureCodeServiceLineId = sl.ServiceLineID
left join HPIApp.dbo.DHSCategories dhsc on pc.ProcedureCodeDHSCategoryId = dhsc.DHSCategoryID
Left Join HPIApp.dbo.ProcedureCodeCategories pcsubc on pc.ProcedureCodeSubCategoryId = pcsubc.ProcedureCodeCategoryId



union
 Select 
    --[ProcedureCodeID]
  Concat(pc.DataSourceId, Concat('~', pc.[SourceID])) as ProcedureCodeID
      --[ProcedureCodeDataSourceID]
	  ,pc.DataSourceId as ProcedureCodeDataSourceID
      ,--[ProcedureCodeSourceID]
	  pc.[SourceID] as ProcedureCodeSourceID
      ,--[ProcedureCode]
	  pc.ProcedureCode
      ,--[ProcedureCodeInsuranceDescription]
	  pc.[ProcedureCodeInsuranceDescription]
      ,--[ProcedureCodeStatementDescription]
	  pc.ProcedureCodeStatementDescription
      ,--[ProcedureCodeType]
	  pc.ProcedureCodeType
      ,--[ProcedureCodeCategoryID]
	  pc.ProcedureCodeSubCategoryID
      ,--[ProcedureCodeCategoryAbbreviation]
	  pcsubc.ProcedureCodeCategoryAbbreviation
      ,--[ProcedureCodeCategoryDescription]
	  pcsubc.ProcedureCodeCategoryDescription
      ,--[ProcedureCodeSelfPay]
	  pc.ProcedureCodeSelfPay
      ,--[ProcedureCodeEnableSplitBilling]
	  pc.ProcedureCodeEnableSplitBilling
      ,--[ProcedureCodeInfusion]
	  pc.ProcedureCodeInfusion
      ,--[ProcedureCodeIsActive]
	  
	  pc.ProcedureCodeCategoryId,
	  Case
	  when pc.IsDeleted = 1 then 0
	  else 1
	  end as ProcedureCodeIsActive
      ,--[ProcedureCodeUpdatedDateTime]
	  pc.ProcedureCodeUpdatedDateTime 
  
From HPIAPP.dbo.UnmappedPBProcedureCodes pc
Left Join HPIApp.dbo.PBProcedureCategories pcc on pc.ProcedureCodeCategoryId = pcc.Id
Left Join HPIApp.dbo.ServiceLines sl on pc.ProcedureCodeServiceLineId = sl.ServiceLineID
left join HPIApp.dbo.DHSCategories dhsc on pc.ProcedureCodeDHSCategoryId = dhsc.DHSCategoryID
Left Join HPIApp.dbo.ProcedureCodeCategories pcsubc on pc.ProcedureCodeSubCategoryId = pcsubc.ProcedureCodeCategoryId
) as t where t.ProcedureCodeID != '~'
GO
