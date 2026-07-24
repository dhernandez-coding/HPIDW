create PROCEDURE hero.LoadLocationsFromApp as 

truncate table hero.Locationss

--SET IDENTITY_INSERT hero.SourceSystems ON;


insert into hero.Locationss
(
 [LocationID]
      ,[LocationName]
      ,[LocationIsActive]
      ,[LocationCreatedDate]
      ,[LocationCreatedByUserID]
      ,[LocationModifiedDate]
      ,[LocationModifiedByUserID]
      ,[CreatedDate]
      ,[ModifiedDate]
      ,[ModifiedBy]
      ,[DeletedDate]
      ,[DeletedBy]
      ,[IsDeleted]
      ,[IsActive])
	  
select 
  [LocationID]
      ,[LocationName]
      ,[LocationIsActive]
      ,[LocationCreatedDate]
      ,[LocationCreatedByUserID]
      ,[LocationModifiedDate]
      ,[LocationModifiedByUserID]
      ,[CreatedDate]
      ,[ModifiedDate]
      ,[ModifiedBy]
      ,[DeletedDate]
      ,[DeletedBy]
      ,[IsDeleted]
      ,[IsActive]
from [hero-db].hpi.dbo.Locationss
GO
