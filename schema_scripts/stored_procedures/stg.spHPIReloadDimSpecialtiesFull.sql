-- =============================================
-- Author:		Chris Cross
-- Create date: 03/14/2023
-- Description:	Extracts, Transforms and Loads Specialty Data from INTERNAL Source System into a dim Table
-- Change Control
--	1. 04/19/2023 - Chris Cross - Initial build of procedure
-- =============================================
CREATE PROCEDURE [stg].[spHPIReloadDimSpecialtiesFull]
AS
BEGIN
SET NOCOUNT ON;

-- HOSP: NS, SERVER: HOSPF100, SOURCEID: 2

 DELETE FROM dim.Specialties WHERE SpecialtyDataSourceID = 0

 INSERT INTO dim.Specialties
 ([SpecialtyID]
      ,[SpecialtyDataSourceID]
      ,[SpecialtySourceID]
      ,[SpecialtyName]
      ,[SpecialtyAbbreviation]
      ,[SpecialtyDescription]
      ,[SpecialtyIsActive]
      ,[SpecialtyCoPayApplies]
      ,[SpecialtyUpdatedDateTime]
	)

 SELECT
	concat('0~',s.SpecialtyID) as SpecialtyID
	,0 as SpecialtyDatasourceID
	,CONVERT(varchar(100),s.SpecialtyID) as SpecialtySourceID
	,s.SpecialtyName as [SpecialtyName]
	,LEFT(s.SpecialtyName,4) as [SpecialtyAbbreviation]
	,NULL as [SpecialtyDescription]
	,ISNULL(s.SpecialtyIsActive,1) as [SpecialtyIsActive]
	,NULL AS [SpecialtyCoPayApplies]
	,GETDATE() AS [SpecialtyUpdatedDateTime]
 FROM [HPIApp].dbo.Specialties s

/*
insert into dim.Specialties SELECT '0~BARI',0,'BARI','Bariatrics','BARI',NULL,1,NULL,GETDATE()
insert into dim.Specialties SELECT '0~DERM',0,'DERM','Dermatology','DERM',NULL,1,NULL,GETDATE()
insert into dim.Specialties SELECT '0~EMER',0,'EMER','Emergency Medicine','EMER',NULL,1,NULL,GETDATE()
insert into dim.Specialties SELECT '0~ENDO',0,'ENDO','Endocrinology','ENDO',NULL,1,NULL,GETDATE()
insert into dim.Specialties SELECT '0~FAMI',0,'FAMI','Family Medicine','FAMI',NULL,1,NULL,GETDATE()
insert into dim.Specialties SELECT '0~GAST',0,'GAST','Gastro','GAST',NULL,1,NULL,GETDATE()
insert into dim.Specialties SELECT '0~GENE',0,'GENE','General Surgery','GENE',NULL,1,NULL,GETDATE()
insert into dim.Specialties SELECT '0~INTE',0,'INTE','Internal Medicine','INTE',NULL,1,NULL,GETDATE()
insert into dim.Specialties SELECT '0~NEUR',0,'NEUR','Neurosurgery','NEUR',NULL,1,NULL,GETDATE()
insert into dim.Specialties SELECT '0~EYES',0,'EYES','Eyes','EYES',NULL,1,NULL,GETDATE()
insert into dim.Specialties SELECT '0~ORTH',0,'ORTH','Ortho','ORTH',NULL,1,NULL,GETDATE()
insert into dim.Specialties SELECT '0~PAIN',0,'PAIN','Pain Management','PAIN',NULL,1,NULL,GETDATE()
insert into dim.Specialties SELECT '0~PEDS',0,'PEDS','Pediatrics','PEDS',NULL,1,NULL,GETDATE()
insert into dim.Specialties SELECT '0~PLAS',0,'PLAS','Plastic Surgery','PLAS',NULL,1,NULL,GETDATE()
insert into dim.Specialties SELECT '0~RHEU',0,'RHEU','Rheumatology','RHEU',NULL,1,NULL,GETDATE()
insert into dim.Specialties SELECT '0~SPOR',0,'SPOR','Sports Medicine','SPOR',NULL,1,NULL,GETDATE()
insert into dim.Specialties SELECT '0~UROL',0,'UROL','Urology','UROL',NULL,1,NULL,GETDATE()
insert into dim.Specialties SELECT '0~GYNE',0,'GYNE','Gynecology','GYNE',NULL,1,NULL,GETDATE()
insert into dim.Specialties SELECT '0~SPIN',0,'SPIN','Spine','SPIN',NULL,1,NULL,GETDATE()
insert into dim.Specialties SELECT '0~ENT',0,'ENT','ENT','ENT',NULL,1,NULL,GETDATE()
*/


END
GO
