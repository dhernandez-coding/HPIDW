CREATE View [dim].[vPBProcedureCodeCategories]
as

SELECT 
	c.ProcedureCode as ProcedureCode
	,pc.ProcedureCategory as ProcedureCodeCategory
	,pc.ProcedureCategoryVisitType as ProcedureCodeSubCategory
	,sl.ServiceLineName as ProcedureCodeServiceLine
	,c.ProcedureCodeIsLocationDependent as ProcedureCodeIsLocationDependent
	,pc.ProcedureCategoryPriority as ProcedureCodePriority
	,dhs.DHSCategoryName as ProcedureCodeDHSCategory
	,Case When c.ProcedureCodeInPlay = 1 Then 'Y' else 'N' End as ProcedureCodeInPlay
	,Case When c.ProcedureCodeTHPLab = 1 Then 'Y' else 'N' End as ProcedureCodeTHPLab
	,c.ModifiedDate
	,c.ModifiedBy
FROM [HERO-DB].hpi.dbo.PBProcedureCodess c 
	left join [HERO-DB].hpi.dbo.PBProcedureCategoriess pc ON pc.id = c.ProcedureCodeCategoryID
	left join [HERO-DB].hpi.dbo.ServiceLiness sl ON sl.ServiceLineid = c.ProcedureCodeServiceLineId
	left join [HERO-DB].hpi.dbo.DHSCategoriess dhs ON dhs.DHSCategoryID = c.ProcedureCodeDHSCategoryId
WHERE 1=1
	AND c.ProcedureCodeCategoryID is not null

/*Old PowerApp-based mapping query replaced on 6/2/2026:

Select 
	pc.ProcedureCode
	,pcc.ProcedureCategory as ProcedureCodeCategory
	,pcc.ProcedureCategoryVisitType as ProcedureCodeSubCategory
	,sl.ServiceLineName as ProcedureCodeServiceLine
	,pc.ProcedureCodeIsLocationDependent as ProcedureCodeIsLocationDependent
	,pcc.ProcedureCategoryPriority as ProcedureCodePriority
	,dhsc.DHSCategoryName as ProcedureCodeDHSCategory
	,Case When pc.ProcedureCodeInPlay = 1 Then 'Y' else 'N' End as ProcedureCodeInPlay
	,Case When pc.ProcedureCodeTHPLab = 1 Then 'Y' else 'N' End as ProcedureCodeTHPLab
From HPIAPP.dbo.PbProcedureCodes pc
	Left Join HPIApp.dbo.PBProcedureCategories pcc on pc.ProcedureCodeCategoryId = pcc.Id
	Left Join HPIApp.dbo.ServiceLines sl on pc.ProcedureCodeServiceLineId = sl.ServiceLineID
	left join HPIApp.dbo.DHSCategories dhsc on pc.ProcedureCodeDHSCategoryId = dhsc.DHSCategoryID
--order by ProcedureCode
*/
GO
