-- =============================================
-- Author:		Zeke Herrera
-- Create date: 08/14/2023
-- Description:	Extracts, Transforms and Loads Encounter Data from pims/medhost Source System into a FACT Table
-- Change Control

-- =============================================
CREATE PROCEDURE [stg].[spMedhostCHReloadFactVisitCasesFull]
AS
BEGIN
SET NOCOUNT ON;

-- HOSP: CH, SERVER: HOSPF110, SOURCEID: 8

DELETE FROM fact.VisitCases WHERE VisitCaseDatesourceID = 8

insert into fact.VisitCases
(
VisitCaseID
,VisitCaseDatesourceID
,VisitCaseSourceID
,VisitCaseVisitID
,VisitCaseCSN
,VisitCaseLocationID
,VisitCaseServiceDate
,VisitCaseScheduledDatetime
,VisitCaseBeginDatetime
,VisitCaseEndDatetime
,VisitCaseCancelledDate
,VisitCaseCancelledReason
,VisitCaseIsRescheduled
,VisitCaseServiceID
,VisitCaseORID
,VisitCaseScheduleStatus
,VisitCasePatientClass
,VisitCaseService
,VisitCasePrimaryProviderID
,VisitCaseTotalTimeNeeded
,VisitCaseLogStatus
,VisitCaseUpdatedDatetime
)
select
	concat('8~', e.orcase) [VisitCaseID]
	,'8' [VisitCaseDataSourceID]
	,orcase [VisitCaseSourceID]
	,concat('8~', e.adtcasenumber) [VisitCaseVisitID]
	,e.adtcasenumber [VisitCaseCSN]
	,'8~110' [VisitCaseLocationID]
		,e.surgerydate [VisitCaseServiceDate]
	,e.StartTime_Orig [VisitCaseScheduledDatetime] 
	,e.StartTime [VisitCaseBeginDatetime] 
	,e.EndTime [VisitCaseEndDatetime]
	,e.cancelleddatetime as [VisitCaseCancelledDate]
	,e.ReasonCategory  [VisitCaseCancelledReason]
	,NULL as VisitCaseIsRescheduled
	,e.ScheduledService [VisitCaseServiceID]
	,'RoomNumber' [VisitCaseORID] 
	,CASE WHEN e.Cancelled = 1 THEN 'Canceled'
		  WHEN e.surgerydate > getdate() THEN 'Scheduled'
		  ELSE 'Completed' END [VisitCaseScheduleStatus] 
	,CASE WHEN e.Status = 'Outpt' THEN 'Outpatient Surgery'
		  WHEN e.Status = 'Outpatient' THEN 'Outpatient Surgery'
		  WHEN e.Status = 'Inpt'  THEN 'Inpatient'
		  WHEN e.Status = 'Inpatient' THEN 'Inpatient'
		  WHEN e.Status = 'Obs'   THEN 'Observation'
		  WHEN e.Status = 'E'	THEN 'Emergency' 
		  WHEN e.Status = 'R' THEN 'Surgery Admit'
		  ELSE NULL END [VisitCasePatientClass]
	,e.ScheduledService as [VisitCaseService]
	,concat('8~', s.pnum) [VisitCasePrimaryProviderID]
	,DATEDIFF(minute, e.starttime, e.endtime) VisitCaseTotalTimeNeeded
	,CASE WHEN e.Cancelled = 1 THEN 'Canceled'
	ELSE 'Posted' END [VisitCaseLogStatus] 
	,GETDATE() as [VisitCaseUpdatedDatetime]
FROM [CORHPIVMAP14].[DATA_PIMS_OK_OklahomaCity_CommunityHospital].[dbo].[ORSched] e
left join [CORHPIVMAP14].[DATA_PIMS_OK_OklahomaCity_CommunityHospital].[dbo].[List_Surgeons] s on e.surgeonid = s.surgeonid
where 1=1
and e.surgerydate <= '5/1/2023'	/*Cases moved to Epic after this date*/	


END
GO
