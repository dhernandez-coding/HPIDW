CREATE view [dim].[vPBProcedureCategories] as


-- 9/29/2026 - Repointed from hero.PBProcedureCategoriess to dim.PBProcedureCategories (maintained by the HPI app).
-- Same columns as before; Id is the new CategoryID (dim.vPBProcedureCodes.ProcedureCodeCategoryId uses the same IDs).
SELECT c.CategoryID                                   AS Id
      ,c.CategoryName                                 AS ProcedureCategory
      ,c.CategoryPriority                             AS ProcedureCategoryPriority
      ,vt.VisitTypeName                               AS ProcedureCategoryVisitType
      ,CAST(CASE WHEN c.IsActive = 1 THEN 0 ELSE 1 END AS bit) AS IsDeleted
      ,c.Priority
      ,c.CreatedDatetime                              AS CreatedDate
      ,c.UpdatedDatetime                              AS ModifiedDate
      ,c.ModifiedBy
      ,CAST(NULL AS datetime)                         AS DeletedDate
      ,CAST(NULL AS varchar(100))                     AS DeletedBy
      ,c.IsActive
FROM dim.PBProcedureCategories c
    LEFT JOIN dim.PBProcedureVisitTypes vt ON vt.VisitTypeID = c.VisitTypeID

--SELECT [Id]
--      ,[ProcedureCategory]
--      ,[ProcedureCategoryPriority]
--      ,[ProcedureCategoryVisitType]
--      ,[IsDeleted]
--      ,[Priority]
--      ,[CreatedDate]
--      ,[ModifiedDate]
--      ,[ModifiedBy]
--      ,[DeletedDate]
--      ,[DeletedBy]
--      ,[IsActive]
--  FROM hero.PBProcedureCategoriess --[hpi_etl].[dbo].[PBProcedureCategoriess]
GO
