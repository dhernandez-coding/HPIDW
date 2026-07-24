create PROCEDURE hero.LoadPBProcedureCodeCategoriesFromApp as 

truncate table hero.PBProcedureCategoriess

--SET IDENTITY_INSERT hero.SourceSystems ON;


insert into hero.PBProcedureCategoriess
(
 [Id]
      ,[ProcedureCategory]
      ,[ProcedureCategoryPriority]
      ,[ProcedureCategoryVisitType]
      ,[IsDeleted]
      ,[Priority]
      ,[CreatedDate]
      ,[ModifiedDate]
      ,[ModifiedBy]
      ,[DeletedDate]
      ,[DeletedBy]
      ,[IsActive])
	  
select 
  [Id]
      ,[ProcedureCategory]
      ,[ProcedureCategoryPriority]
      ,[ProcedureCategoryVisitType]
      ,[IsDeleted]
      ,[Priority]
      ,[CreatedDate]
      ,[ModifiedDate]
      ,[ModifiedBy]
      ,[DeletedDate]
      ,[DeletedBy]
      ,[IsActive]
from [hero-db].hpi.dbo.PBProcedureCategoriess
GO
