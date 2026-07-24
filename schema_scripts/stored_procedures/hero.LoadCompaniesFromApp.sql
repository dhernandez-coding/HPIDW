create PROCEDURE hero.LoadCompaniesFromApp as 

truncate table hero.Companiess

--SET IDENTITY_INSERT hero.SourceSystems ON;


insert into hero.Companiess
(
 
[CompanyID]
      ,[CompanyName]
      ,[CreatedDate]
      ,[ModifiedDate]
      ,[ModifiedBy]
      ,[DeletedDate]
      ,[DeletedBy]
      ,[IsDeleted]
      ,[IsActive])
	  
select 
 
[CompanyID]
      ,[CompanyName]
      ,[CreatedDate]
      ,[ModifiedDate]
      ,[ModifiedBy]
      ,[DeletedDate]
      ,[DeletedBy]
      ,[IsDeleted]
      ,[IsActive]
from [hero-db].hpi.dbo.Companiess
GO
