CREATE VIEW [dim].[vPatients]
AS
SELECT
	PatientID
	, PatientDataSourceID
	, PatientSourceID
	, PatientMRN, PatientFirstName
	, PatientMiddleInitial
	, PatientLastName
	, PatientFullName
	, PatientGender
	, PatientDateOfBirth
	, PatientSSN
	, PatientHomePhone
	, PatientWorkPhone
	, PatientWorkPhoneExtension
	, PatientMobilePhone
	, PatientEmailAddress
	, PatientStreetAddress1
	, PatientStreetAddress2
	, PatientCity
	, PatientState
	, PatientZipCode
	, PatientIsActive
	, PatientUpdatedDateTime
	, PatientMedicareNumber
FROM dim.Patients p
WHERE (1 = 1) 
	AND (PatientDataSourceID IN (1,12,15)
	OR (PatientID IN (
			SELECT DISTINCT AccountPatientID
			FROM fact.Accounts a)))
GO
