create view dim.vPBProcedureCategories as

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
  FROM [hpi_etl].[dbo].[PBProcedureCategoriess]
GO
