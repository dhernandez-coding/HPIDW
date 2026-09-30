CREATE View [dim].[vPBProcedureCodeCategories]
as


-- 9/29/2026 - Repointed from [HERO-DB] to the app-maintained dim.PBProcedure* tables (through the dim.v* views
-- above, the same joins the EPIC fact load uses). Same output columns and the same "mapped codes only" filter.
SELECT c.ProcedureCode                                AS ProcedureCode
      ,pc.ProcedureCategory                           AS ProcedureCodeCategory
      ,pc.ProcedureCategoryVisitType                  AS ProcedureCodeSubCategory
      ,sl.ServiceLineName                             AS ProcedureCodeServiceLine
      ,c.ProcedureCodeIsLocationDependent             AS ProcedureCodeIsLocationDependent
      ,pc.ProcedureCategoryPriority                   AS ProcedureCodePriority
      ,dhs.DHSCategoryName                            AS ProcedureCodeDHSCategory
      ,CASE WHEN c.ProcedureCodeInPlay = 1 THEN 'Y' ELSE 'N' END AS ProcedureCodeInPlay
      ,CASE WHEN c.ProcedureCodeTHPLab = 1 THEN 'Y' ELSE 'N' END AS ProcedureCodeTHPLab
      ,c.ModifiedDate
      ,c.ModifiedBy
FROM dim.vPBProcedureCodes c
    LEFT JOIN dim.vPBProcedureCategories pc ON pc.Id = c.ProcedureCodeCategoryId
    LEFT JOIN dim.vServiceLines sl ON sl.ServiceLineID = c.ProcedureCodeServiceLineId
    LEFT JOIN dim.vDHSCategories dhs ON dhs.DHSCategoryID = c.ProcedureCodeDHSCategoryId
WHERE c.ProcedureCodeCategoryId IS NOT NULL
GO
