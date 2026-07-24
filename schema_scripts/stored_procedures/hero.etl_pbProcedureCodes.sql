CREATE Procedure [hero].[etl_pbProcedureCodes] as

                EXECUTE ('TRUNCATE TABLE [hpi].[stg].[PBProcedureCodess]') at [hero-db];
insert into [HERO-DB].[hpi].[stg].[PBProcedureCodess] ([ProcedureCode]
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
Select 

      [ProcedureCode]
      ,[CptDescription]
      ,0 as [IsDeleted]
      ,[ChargeCount]
      ,[TotalCharges]
      ,[LastPostDate]
      ,Coalesce([ProcedureCodeIsLocationDependent], 0) as [ProcedureCodeIsLocationDependent]
      ,Coalesce([ProcedureCodeInPlay], 0) as [ProcedureCodeInPlay]
      ,Coalesce([ProcedureCodeTHPLab], 0) as [ProcedureCodeTHPLab]
      ,[ProcedureCodeCategoryId]
      ,[ProcedureCodeServiceLineId]
      ,[ProcedureCodeDHSCategoryId]
      ,[FirstPostDate]
      --,GetDate() as [ValidFrom]
      --,GetDate() as [ValidTo]
      ,GetDate() as [CreatedDate]
      ,GetDate() as [ModifiedDate]
      ,'ETL' as[ModifiedBy]
      ,GetDate() as [DeletedDate]
      ,'' as [DeletedBy]
      ,1 as [IsActive]
      ,IsMapped as [Mapped]
from HPIDW.[dbo].[zzMIGRATE_mapPBProcedureCodeCategories]

exec [HERO-DB].[hpi].[stg].[usp_UpsertPBProcedureCodesFromStaging]
GO
