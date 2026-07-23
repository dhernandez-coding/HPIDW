Create view dim.vDHSCategories as 


SELECT [DHSCategoryID]
      ,[DHSCategoryName]
      ,[DHSCategoryIsActive]
      ,[DHSCategoryCreatedDate]
      ,[DHSCategoryCreatedByUserID]
      ,[DHSCategoryModifiedDate]
      ,[DHSCategoryModifiedByUserID]
      ,[CreatedDate]
      ,[ModifiedDate]
      ,[ModifiedBy]
      ,[DeletedDate]
      ,[DeletedBy]
      ,[IsDeleted]
      ,[IsActive]
  FROM [hpi_etl].[dbo].[DHSCategoriess]
GO
