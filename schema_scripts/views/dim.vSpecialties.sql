/****** Script for SelectTopNRows command from SSMS  ******/
create view dim.vSpecialties as
	select
		[SpecialtyID]
      ,[SpecialtyDataSourceID]
      ,[SpecialtySourceID]
      ,[SpecialtyName]
	  ,	case
		when SpecialtyName like 'ENT' then '0~1'
		when SpecialtyName like '%Eyes%' then '0~2'
		when SpecialtyName like 'Gastro%' then '0~3'
		when SpecialtyName like '%General%' then '0~4'
		when SpecialtyName like '%Gynecology%' then '0~5'
		when SpecialtyName like '%Ortho%' then '0~6'
		when SpecialtyName like '%Spine%' then '0~7'
		when SpecialtyName like '%Urology%' then '0~8'
		when SpecialtyName like '%Pain%' then '0~9'
		else '0~22' end as SpecialtyParentID
      ,[SpecialtyAbbreviation]
      ,[SpecialtyDescription]
      ,[SpecialtyIsActive]
      ,[SpecialtyCoPayApplies]
      ,[SpecialtyUpdatedDateTime]
  FROM [HPIDW].[dim].[Specialties]
GO
