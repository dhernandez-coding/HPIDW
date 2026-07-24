create PROCEDURE hero.LoadPBProcedureCodesFromApp as 

truncate table hero.PBProcedureCodess

--SET IDENTITY_INSERT hero.SourceSystems ON;


insert into hero.PBProcedureCodess
(
[Id]
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
      ,[Mapped])
	  
select 
 [Id]
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
from [hero-db].hpi.dbo.PBProcedureCodess
GO
