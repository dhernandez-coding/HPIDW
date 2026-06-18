Create View vPBProcedureCategories
as
Select pc.ProcedureCode
,pcc.ProcedureCategory as ProcedureCodeCategory
,pcc.ProcedureCategoryVisitType as ProcedureCodeSubCategory
,sl.ServiceLineName as ProcedureCodeServiceLine
,pc.ProcedureCodeIsLocationDependent as ProcedureCodeIsLocationDependent
,pc.ProcedureCodePriority
,dhsc.DHSCategoryName as ProcedureCodeDHSCategory
,Case 
When pc.ProcedureCodeInPlay = 1
Then 'Y'
else 'N'
End as ProcedureCodeInPlay
,Case 
When pc.ProcedureCodeTHPLab = 1
Then 'Y'
else 'N'
End as ProcedureCodeTHPLab
From HPIAPP.dbo.PbProcedureCodes pc
Left Join HPIApp.dbo.PBProcedureCategories pcc on pc.ProcedureCodeCategoryId = pcc.Id
Left Join HPIApp.dbo.ServiceLines sl on pc.ProcedureCodeServiceLineId = sl.ServiceLineID
left join HPIApp.dbo.DHSCategories dhsc on pc.ProcedureCodeDHSCategoryId = dhsc.DHSCategoryID
--order by ProcedureCode
GO
