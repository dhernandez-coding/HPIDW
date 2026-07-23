create view dim.vPBProcedureCodes as 

SELECT [Id]
      ,[ProcedureCode]
      ,[CptDescription]
      ,[IsDeleted]
      ,[ChargeCount]
      ,[TotalCharges]
      ,[LastPostDate]
      ,[ProcedureCodeIsLocationDependent]
      ,[ProcedureCodeInPlay]
      ,[ProcedureCodeTHPLab]
      ,[ProcedureCodeCategoryId]
      ,[ProcedureCodeServiceLineId]
      ,[ProcedureCodeDHSCategoryId]
      ,[FirstPostDate]
      ,[CreatedDate]
      ,[ModifiedDate]
      ,[ModifiedBy]
      ,[DeletedDate]
      ,[DeletedBy]
      ,[IsActive]
      ,[Mapped]
  FROM [hpi_etl].[dbo].[PBProcedureCodess]
GO
