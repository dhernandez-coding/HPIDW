create PROCEDURE hero.LoadProviderAliasesFromApp as 

truncate table hero.providerAliases

--SET IDENTITY_INSERT hero.providerAliases ON;


insert into hero.providerAliases
(
[Id]
      ,[Name]
      ,[Description]
      ,[Value]
      ,[ProviderId]
      ,[SourceSystemId]
      ,[ValidFrom]
      ,[ValidTo]
      ,[CreatedDate]
      ,[ModifiedDate]
      ,[ModifiedBy]
      ,[DeletedDate]
      ,[DeletedBy]
      ,[IsDeleted]
      ,[IsActive])
	  
select 

[Id]
      ,[Name]
      ,[Description]
      ,[Value]
      ,[ProviderId]
      ,[SourceSystemId]
      ,[ValidFrom]
      ,[ValidTo]
      ,[CreatedDate]
      ,[ModifiedDate]
      ,[ModifiedBy]
      ,[DeletedDate]
      ,[DeletedBy]
      ,[IsDeleted]
      ,[IsActive]
from [hero-db].hpi.dbo.providerAliases
GO
