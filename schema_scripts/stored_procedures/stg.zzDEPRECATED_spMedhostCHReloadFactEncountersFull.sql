-- =============================================
-- Author:		Jacob Roan
-- Create date: 03/15/2023
-- Description:	Extracts, Transforms and Loads encounter Data from pims/medhost Source System into a dim Table
-- Change Control
--	1. 03/15/2023 - Jacob Roan - Initial build of procedure
-- 2. 7/5 - jacob roan - added encounterissurgical
-- =============================================
CREATE PROCEDURE [stg].[spMedhostCHReloadFactEncountersFull]
AS
BEGIN
SET NOCOUNT ON;

-- HOSP: CH, SERVER: HOSPF110, SOURCEID: 8

DELETE FROM fact.Encounters WHERE EncounterDataSourceID = 8

insert into fact.Encounters
select
	concat('8~', e.orcase) [EncounterID]
	,'8' [EncounterDataSourceID]
	,orcase [EncounterSourceID]
	,concat('8~', e.orcase) as ParentEncounterID
	,concat('8~', e.adtcasenumber) [EncounterVisitID]
	,concat('8~', e.medicalrecord) [EncounterPatientID]
	,'8~110' [EncounterLocationID]
	,'' [EncounterDepartmentID]
	,e.[Location] [EncounterRoom]
	,concat('8~', s.pnum) [EncounterPrimaryProviderID]
	,NULL [EncounterAdmittingProviderID]
	,NULL [EncounterAttendingProviderID]
	,NULL [EncounterReferringProviderID]
	,e.surgerydate [EncounterDateOfService]
	,NULL [EncounterDateOfScheduling]
	,NULL [EncounterDateOfRegistration]
	,e.StartTime as [EncounterBeginDatetime]
	,e.EndTime as [EncounterEndDatetime]
	,e.cancelleddatetime as [EncounterDateOfCancellation]
	,e.ReasonCategory as [EncounterCancelledReason]
	,CASE WHEN e.Cancelled = 1 THEN 'Cancelled'
		  WHEN e.surgerydate > getdate() THEN 'Scheduled'
		  ELSE 'Complete' END [EncounterStatus]
	,e.ScheduledService as [EncounterClass]
	,e.CaseType as [EncounterType]
	,e.[Procedure_] as [EncounterReason]
	,1 as EncounterIsSurgical
	,1 as [EncounterIsActive]
	,GETDATE() as [EncounterUpdatedDatetime]
FROM [CORHPIVMAP14].[DATA_PIMS_OK_OklahomaCity_CommunityHospital].[dbo].[ORSched] e
left join [CORHPIVMAP14].[DATA_PIMS_OK_OklahomaCity_CommunityHospital].[dbo].[List_Surgeons] s on e.surgeonid = s.surgeonid


END
GO
