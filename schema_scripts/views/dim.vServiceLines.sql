CREATE view [dim].[vServiceLines] as 


-- 9/29/2026 - Repointed from hpi_etl.dbo.ServiceLiness to dim.PBProcedureServiceLines (maintained by the HPI app).
SELECT s.ServiceLineID
      ,s.ServiceLineName
      ,s.ServiceLineGroupID
      ,s.IsActive                                     AS ServiceLineIsActive
      ,s.CreatedDatetime                              AS ServiceLineCreatedDate
      ,CAST(NULL AS int)                              AS ServiceLineCreatedByUserID
      ,s.UpdatedDatetime                              AS ServiceLineModifiedDate
      ,CAST(NULL AS int)                              AS ServiceLineModifiedByUserID
      ,CAST(NULL AS datetime)                         AS ValidFrom
      ,CAST(NULL AS datetime)                         AS ValidTo
      ,s.CreatedDatetime                              AS CreatedDate
      ,s.UpdatedDatetime                              AS ModifiedDate
      ,s.ModifiedBy
      ,CAST(NULL AS datetime)                         AS DeletedDate
      ,CAST(NULL AS varchar(100))                     AS DeletedBy
      ,CAST(CASE WHEN s.IsActive = 1 THEN 0 ELSE 1 END AS bit) AS IsDeleted
      ,s.IsActive
FROM dim.PBProcedureServiceLines s


--Select [ServiceLineID]
--      ,[ServiceLineName]
--      ,[ServiceLineGroupID]
--      ,[ServiceLineIsActive]
--      ,[ServiceLineCreatedDate]
--      ,[ServiceLineCreatedByUserID]
--      ,[ServiceLineModifiedDate]
--      ,[ServiceLineModifiedByUserID]
--      ,[ValidFrom]
--      ,[ValidTo]
--      ,[CreatedDate]
--      ,[ModifiedDate]
--      ,[ModifiedBy]
--      ,[DeletedDate]
--      ,[DeletedBy]
--      ,[IsDeleted]
--      ,[IsActive]
--  FROM [hpi_etl].[dbo].[ServiceLiness]
--GO
