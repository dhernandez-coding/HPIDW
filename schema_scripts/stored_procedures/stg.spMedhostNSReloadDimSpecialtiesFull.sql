-- =============================================
-- Author:		Chris Cross
-- Create date: 03/14/2023
-- Description:	Extracts, Transforms and Loads Specialty Data from MEDHOST Source System into a dim Table
-- Change Control
--	1. 03/14/2023 - Chris Cross - Initial build of procedure
-- =============================================
CREATE PROCEDURE [stg].[spMedhostNSReloadDimSpecialtiesFull]
AS
BEGIN
SET NOCOUNT ON;

-- HOSP: NS, SERVER: HOSPF100, SOURCEID: 2

 DELETE FROM dim.Specialties WHERE SpecialtyDataSourceID = 2

insert into dim.Specialties

SELECT 
	  CONCAT('2~',s.SPECOD) as [SpecialtyID]
      ,2 as [SpecialtyDataSourceID]
      ,s.SPECOD as [SpecialtySourceID]
      ,s.SPEDSC as [SpecialtyName]
      ,RIGHT(s.SPECOD,2) as [SpecialtyAbbreviation]
      ,NULL AS [SpecialtyDescription]
      ,1 AS [SpecialtyIsActive]
      ,null as [SpecialtyCoPayApplies]
      ,GETDATE() as [SpecialtyUpdatedDateTime]
  FROM OPENQUERY([hmsls],'
	select
	*
	from ISF100.SPECMST 
	where 1=1 
	') s

END
GO
