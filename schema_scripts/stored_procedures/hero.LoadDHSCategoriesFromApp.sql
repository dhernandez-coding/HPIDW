create PROCEDURE hero.LoadDHSCategoriesFromApp as 

truncate table hero.DHSCategoriess

--SET IDENTITY_INSERT hero.SourceSystems ON;


insert into hero.DHSCategoriess
(
[DHSCategoryID]
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
      ,[IsActive])
	  
select 
 [DHSCategoryID]
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
from [hero-db].hpi.dbo.DHSCategoriess
GO
