create PROCEDURE hero.LoadPracticesFromApp as 

truncate table hero.Practicess

--SET IDENTITY_INSERT hero.SourceSystems ON;


insert into hero.Practicess
(
[PracticeID]
      ,[PracticePracticeID]
      ,[PracticeDataSourceID]
      ,[PracticeSourceID]
      ,[PracticeName]
      ,[PracticeAbbreviation]
      ,[PracticeDataSource]
      ,[PracticeIsActive]
      ,[PracticeUpdatedDatetime]
      ,[PracticeGLLocationID]
      ,[PracticeGLLocation]
      ,[PracticeGLPracticeID]
      ,[PracticeSpecialtyId]
      ,[PracticeCompanyId]
      ,[SpecialtyID]
      ,[CreatedDate]
      ,[ModifiedDate]
      ,[ModifiedBy]
      ,[DeletedDate]
      ,[DeletedBy]
      ,[IsDeleted]
      ,[ApApproverUserIds]
      ,[ApPreparerUserIds]
      ,[IsActive]
      ,[CompanyID]
      ,[RequiredPermissions]
      ,[DepartmentId]
      ,[SameStoreEndDate]
      ,[SameStoreStartDate]
      ,[AccountIDFromGreatPlains]
      ,[IncludeInBlueBooks])
	  
select 
[PracticeID]
      ,[PracticePracticeID]
      ,[PracticeDataSourceID]
      ,[PracticeSourceID]
      ,[PracticeName]
      ,[PracticeAbbreviation]
      ,[PracticeDataSource]
      ,[PracticeIsActive]
      ,[PracticeUpdatedDatetime]
      ,[PracticeGLLocationID]
      ,[PracticeGLLocation]
      ,[PracticeGLPracticeID]
      ,[PracticeSpecialtyId]
      ,[PracticeCompanyId]
      ,[SpecialtyID]
      ,[CreatedDate]
      ,[ModifiedDate]
      ,[ModifiedBy]
      ,[DeletedDate]
      ,[DeletedBy]
      ,[IsDeleted]
      ,[ApApproverUserIds]
      ,[ApPreparerUserIds]
      ,[IsActive]
      ,[CompanyID]
      ,[RequiredPermissions]
      ,[DepartmentId]
      ,[SameStoreEndDate]
      ,[SameStoreStartDate]
      ,[AccountIDFromGreatPlains]
      ,[IncludeInBlueBooks]
from [hero-db].hpi.dbo.Practicess
GO
