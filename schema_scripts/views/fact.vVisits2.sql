CREATE VIEW [fact].[vVisits2] AS
	select 
[VisitID]
,[VisitDatasourceID]
,[VisitSourceID]
,[VisitPatientID]
,[VisitAccountID]
,[VisitLocationID]
,[VisitDepartmentID]
,[VisitRoomID]
,[VisitPrimaryProviderID]
,[VisitAppointmentProviderID]
,[VisitAdmittingProviderID]
,[VisitAttendingProviderID]
,[VisitDischargeProviderID]
,[VisitType]
,[VisitService]
,[VisitStatus]
,[VisitDateOfService]
,[VisitDatetimeOfService]
,[VisitDateOfScheduling]
,[VisitDateOfAppointment]
,[VisitDateOfAdmission]
,[VisitDateOfDischarge]
,[VisitDateofClosing]
,[VisitDateOfCancellation]
,[VisitCancellationReason]
,[VisitIsPrimary]
,[VisitIsActive]
,[VisitUpdatedDatetime]
from fact.Visits2 v
GO
