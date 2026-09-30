CREATE view [dim].[vDHSCategories] as 

-- 9/29/2026 - Repointed from hpi_etl.dbo.DHSCategoriess to dim.PBProcedureDHSCategories (maintained by the HPI app).
SELECT d.DHSCategoryID
      ,d.DHSCategoryName
      ,d.IsActive                                     AS DHSCategoryIsActive
      ,d.CreatedDatetime                              AS DHSCategoryCreatedDate
      ,CAST(NULL AS int)                              AS DHSCategoryCreatedByUserID
      ,d.UpdatedDatetime                              AS DHSCategoryModifiedDate
      ,CAST(NULL AS int)                              AS DHSCategoryModifiedByUserID
      ,d.CreatedDatetime                              AS CreatedDate
      ,d.UpdatedDatetime                              AS ModifiedDate
      ,d.ModifiedBy
      ,CAST(NULL AS datetime)                         AS DeletedDate
      ,CAST(NULL AS varchar(100))                     AS DeletedBy
      ,CAST(CASE WHEN d.IsActive = 1 THEN 0 ELSE 1 END AS bit) AS IsDeleted
      ,d.IsActive
FROM dim.PBProcedureDHSCategories d

--SELECT [DHSCategoryID]
--      ,[DHSCategoryName]
--      ,[DHSCategoryIsActive]
--      ,[DHSCategoryCreatedDate]
--      ,[DHSCategoryCreatedByUserID]
--      ,[DHSCategoryModifiedDate]
--      ,[DHSCategoryModifiedByUserID]
--      ,[CreatedDate]
--      ,[ModifiedDate]
--      ,[ModifiedBy]
--      ,[DeletedDate]
--      ,[DeletedBy]
--      ,[IsDeleted]
--      ,[IsActive]
--  FROM [hpi_etl].[dbo].[DHSCategoriess]
GO
