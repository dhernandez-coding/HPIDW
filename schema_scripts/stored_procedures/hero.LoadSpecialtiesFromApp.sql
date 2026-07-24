create PROCEDURE hero.LoadSpecialtiesFromApp as 

truncate table hero.Specialtiess

--SET IDENTITY_INSERT hero.SourceSystems ON;


insert into hero.Specialtiess
(
 [SpecialtyID]
      ,[SpecialtyName]
      ,[SpecialtyIsActive]
      ,[SpecialtyCreatedDate]
      ,[SpecialtyCreatedByUserID]
      ,[SpecialtyModifiedDate]
      ,[SpecialtyModifiedByUserID]
      ,[CreatedDate]
      ,[ModifiedDate]
      ,[ModifiedBy]
      ,[DeletedDate]
      ,[DeletedBy]
      ,[IsDeleted]
      ,[IsActive])
	  
select 
[SpecialtyID]
      ,[SpecialtyName]
      ,[SpecialtyIsActive]
      ,[SpecialtyCreatedDate]
      ,[SpecialtyCreatedByUserID]
      ,[SpecialtyModifiedDate]
      ,[SpecialtyModifiedByUserID]
      ,[CreatedDate]
      ,[ModifiedDate]
      ,[ModifiedBy]
      ,[DeletedDate]
      ,[DeletedBy]
      ,[IsDeleted]
      ,[IsActive]
from [hero-db].hpi.dbo.Specialtiess
GO
