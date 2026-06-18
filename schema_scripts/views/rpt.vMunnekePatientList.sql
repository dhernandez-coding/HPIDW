CREATE VIEW [rpt].[vMunnekePatientList] AS

SELECT 
	p.PatientFullName
	,p.PatientMRN
	,p.PatientDateOfBirth
	,p.PatientSSN
	,MAX(t.TransactionDateOfService)  as DateOfService
FROM fact.TransactionsPB t
	LEFT JOIN dim.Patients p on p.PatientID = t.TransactionPatientID
WHERE t.TransactionDepartmentID = '12~36'
GROUP BY
	p.PatientFullName
	,p.PatientMRN
	,p.PatientDateOfBirth
	,p.PatientSSN
GO
