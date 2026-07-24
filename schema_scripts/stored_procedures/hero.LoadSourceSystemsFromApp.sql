create PROCEDURE hero.LoadSourceSystemsFromApp as 

truncate table hero.SourceSystems

--SET IDENTITY_INSERT hero.SourceSystems ON;


insert into hero.SourceSystems
(
[Id]
      ,[Name]
      ,[Description]
      ,[Value]
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
      ,[CreatedDate]
      ,[ModifiedDate]
      ,[ModifiedBy]
      ,[DeletedDate]
      ,[DeletedBy]
      ,[IsDeleted]
      ,[IsActive]
from [hero-db].hpi.dbo.SourceSystems
GO
