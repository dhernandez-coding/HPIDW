CREATE view [dim].[vPBProcedureCategories] as

SELECT [Id]
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
  FROM hero.PBProcedureCategoriess --[hpi_etl].[dbo].[PBProcedureCategoriess]
GO
