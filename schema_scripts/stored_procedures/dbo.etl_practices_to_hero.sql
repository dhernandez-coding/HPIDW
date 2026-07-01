CREATE PROCEDURE [dbo].[etl_practices_to_hero]
AS

insert into [HERO-DB].[hpi].[stg].[Practicess]

(PracticePracticeID
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
	  , [PracticeSpecialtyId]
	  ,[PracticeCompanyId]
      ,[SpecialtyID]
	  ,[CreatedDate]
	  ,[ModifiedDate]
	  ,[ModifiedBy]
	  ,[DeletedDate]
	  ,[DeletedBy]
	  ,[IsDeleted]
	  , [ApApproverUserIds]
	  ,[ApPreparerUserIds]
      ,[IsActive]
	  ,[CompanyID] 
	  ,[RequiredPermissions]
	  ,[DepartmentId]
	  ,[IncludeInBlueBooks]
)

--MERGE INTO  HPIApp.dbo.Practices AS target
Select 

      [PracticeID] as PracticePracticeID
      ,cast([PracticeDataSourceID] as float) as [PracticeDataSourceID]
      ,[PracticeSourceID]
      ,[PracticeName]
      ,[PracticeAbbreviation]
      ,[PracticeDataSource]
      ,[PracticeIsActive]
      ,[PracticeUpdatedDatetime]
      ,[PracticeGLLocationID]
      ,[PracticeGLLocation]
      ,[PracticeGLPracticeID]
      ,specialty.SpecialtyID as [PracticeSpecialtyId]
      ,company.CompanyID as [PracticeCompanyId]
      ,[SpecialtyID]
      ,GetDate() as [CreatedDate]
      ,GetDate() as [ModifiedDate]
      ,'System' as [ModifiedBy]
      ,null as [DeletedDate]
      ,null as [DeletedBy]
      ,0 as [IsDeleted]
      ,null as [ApApproverUserIds]
      ,null as [ApPreparerUserIds]
      ,1 as [IsActive]
      ,company.CompanyID [CompanyID] 
      ,'' as [RequiredPermissions]
      ,null as [DepartmentId]
	  ,Cast(0 as bit) as [IncludeInBlueBooks]

from HPIDW.dim.vPractices prac
left join [HERO-DB].[hpi].dbo.Companiess company on prac.PracticeCompany = company.CompanyName
left join [HERO-DB].[hpi].dbo.Specialtiess specialty on prac.PracticeSpecialty = specialty.SpecialtyName
--left join hpi_etl.dbo.Departmentss department on prac.Department = company.CompanyName
where prac.PracticeID not in (select PracticePracticeID from [HERO-DB].[hpi].dbo.Practicess)

exec [HERO-DB].[hpi].[stg].[usp_UpsertPracticesFromStaging]
GO
