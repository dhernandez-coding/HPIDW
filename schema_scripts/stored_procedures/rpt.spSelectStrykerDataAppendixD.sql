CREATE PROCEDURE [rpt].[spSelectStrykerDataAppendixD] as

DECLARE @StartDate date = DATEFROMPARTS(YEAR(GETDATE())-1,1,1) 
DECLARE @EndDate date = DATEFROMPARTS(YEAR(GETDATE()),MONTH(GETDATE()),1)

SELECT
vc.VisitCaseID as 'CaseID'
,p.PatientMRN as 'MedicalRecordNumber'
,vc.VisitCaseProcedureEndDatetime as 'DateOfSurgery'
,pc.ProcedureCodeInsuranceDescription as 'TypeOfCase' 

FROM fact.VisitCases vc 
		LEFT JOIN fact.Visits2 v ON v.VisitID = vc.VisitCaseVisitID
		LEFT JOIN dim.Patients p ON p.PatientID = v.VisitPatientID
		LEFT JOIN fact.VisitProcedures vp on vp.VisitProcedureVisitID = vc.VisitCaseVisitID
		LEFT JOIN dim.vProcedureCodes pc on pc.ProcedureCode = vp.VisitProcedureCode
WHERE 1=1 

		AND vc.VisitCaseScheduleStatus <> 'Canceled'
		AND vc.VisitCaseServiceDate >= '5/1/2023' /*Epic Go-live*/
		AND vc.VisitCaseServiceDate >= @StartDate -- DATEFROMPARTS(YEAR(GETDATE())-1,1,1) 
		AND vc.VisitCaseServiceDate < @EndDate --DATEFROMPARTS(YEAR(GETDATE()),MONTH(GETDATE()),1)
		AND pc.ProcedureCodeSourceID IN ('186864','186880','231091','231105','231129','231149','231163','231179','232293','232311','232389','232413','232427','232435','237998','237999','257098'
										,'257100','257102','257104','257106','257108','257110','257112','257114','257116','257118','257120','259236','259238','274545','274789','274941','275244','275521')
GO
