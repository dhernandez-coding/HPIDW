create procedure ETLProvidersFromDataWarehouseIntoApp as
-- Using OPENQUERY to force a fresh metadata check against the remote server
insert into OPENQUERY([hero-db], 
    'SELECT 
      [ProviderProviderID]
      ,[ProviderDataSourceID]
      ,[ProviderSourceID]
      ,[ProviderAbbreviation]
      ,[ProviderFirstName]
      ,[ProviderMiddleInitial]
      ,[ProviderLastName]
      ,[ProviderGender]
      ,[ProviderSuffix]
      ,[ProviderStreetAddress1]
      ,[ProviderStreetAddress2]
      ,[ProviderCity]
      ,[ProviderState]
      ,[ProviderZipCode]
      ,[ProviderPhone]
      ,[ProviderFax]
      ,[ProviderSpecialtyID]
      ,[ProviderUPIN]
      ,[ProviderNPI]
      ,[ProviderIsActive]
      ,[ProviderUpdatedDateTime]
      ,[IsDeleted]
      ,[CreatedDate]
      ,[ModifiedDate]
      ,[ModifiedBy]
      ,[DeletedDate]
      ,[DeletedBy]
      ,[IsActive]
 
    FROM hpi.dbo.Providerss
    WHERE 1=0'
)
select 
  [ProviderProviderID]      
      ,[ProviderDataSourceID]
      ,[ProviderSourceID]
      ,Coalesce([ProviderAbbreviation], '') as [ProviderAbbreviation]
	  ,Coalesce([ProviderFirstName], '') as [ProviderFirstName]
	  ,Coalesce([ProviderMiddleInitial], '') as [ProviderMiddleInitial]
	  ,Coalesce([ProviderLastName], '') as [ProviderLastName]
	  ,Coalesce([ProviderGender], '') as [ProviderGender]      
	  ,Coalesce([ProviderSuffix], '') as [ProviderSuffix]
	  ,Coalesce([ProviderStreetAddress1], '') as [ProviderStreetAddress1]
	  ,Coalesce([ProviderStreetAddress2], '') as [ProviderStreetAddress2]
	  ,Coalesce([ProviderCity], '') as [ProviderCity]
	  ,Coalesce([ProviderState], '') as [ProviderState]
	  ,Coalesce([ProviderZipCode], '') as [ProviderZipCode]
      ,Coalesce([ProviderPhone], '') as [ProviderPhone]
	  ,Coalesce([ProviderFax], '') as [ProviderFax]
	  ,Coalesce([ProviderSpecialtyID], -1) as [ProviderSpecialtyID]-- map to specialties table      
	  ,Coalesce([ProviderUPIN], '') as [ProviderUPIN]
	  ,Coalesce([ProviderNPI], '') as [ProviderNPI]      
	  ,ProviderIsActive as ProviderIsActive
      ,[ProviderUpdatedDateTime]
      ,0 as [IsDeleted]
  
      ,'2026-02-25 15:45:29.2773287' as [CreatedDate]
      ,'2026-02-25 15:45:29.2773287' as [ModifiedDate]
      ,'ETL' as [ModifiedBy]
      ,null as [DeletedDate]
      ,null as [DeletedBy]
	  ,ProviderIsActive as IsActive
--select * 
from vNewProviders
GO
