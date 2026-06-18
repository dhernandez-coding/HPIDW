-- =============================================
-- Author:		Ryan Tisserand
-- Create date: 12/22/2022
-- Description:	Extracts, Transforms and Loads Patient Data from APM Source System into a dim Table
-- Change Control
--	1. 11/23/2022 - Ryan Tisserand - Initial build of procedure
--  2. 03/10/2023 - Ryan Tisserand - Added delete statement to replace truncate job step
-- =============================================
CREATE PROCEDURE [stg].[spAPMReloadDimPatientsFull]
AS
BEGIN
SET NOCOUNT ON;

delete from dim.Patients where PatientDataSourceID = 1

insert into dim.Patients
(
	PatientID,
	PatientDataSourceID,
	PatientSourceID,
	PatientMRN,
	PatientFirstName,
	PatientMiddleInitial,
	PatientLastName,
	PatientFullName,
	PatientGender,
	PatientDateOfBirth,
	PatientSSN,
	PatientHomePhone,
	PatientWorkPhone,
	PatientWorkPhoneExtension,
	PatientMobilePhone,
	PatientEmailAddress,
	PatientStreetAddress1,
	PatientStreetAddress2,
	PatientCity,
	PatientState,
	PatientZipCode,
	[PatientMaritalStatus],
    [PatientEthnicity],
    [PatientLanguage],
	PatientIsActive,
	PatientUpdatedDateTime
)

select
	'1~' + cast(p.Patient_ID as varchar(50)) as PatientID, --+ '~' + cast(p.Contact_ID as varchar(50)) PatientID,
	1 PatientDataSourceID,
	p.Patient_ID PatientSourceID,
	--p.Contact_ID SourceContactID,
	p.Patient_Number PatientMRN,
	c.First_Name PatientFirstName,
	c.Middle_Initial PatientMiddleInitial,
	c.Last_Name PatientLastName,
	CASE WHEN c.Middle_Initial IS NULL 
		THEN c.Last_Name + ', ' + c.First_Name
		ELSE c.Last_Name + ', ' + c.First_Name + ' ' + c.Middle_Initial END AS PatientFullName,
	c.Sex PatientGender,
	c.Date_Of_Birth PatientDateOfBirth,
	c.SSN PatientSSN,
	a.Phone PatientHomePhone,
	c.Work_Phone PatientWorkPhone,
	c.Work_Phone_Ext PatientWorkPhoneExtension,
	c.Cell_Phone PatientMobilePhone,
	c.Email_Address PatientEmailAddress,
	a.Street1 PatientStreetAddress,
	a.Street2 PatientStreetAddress2,
	a.City PatientCity,
	a.[State] PatientState,
	a.Zip_Code PatientZipCode,
	NULL AS [PatientMaritalStatus],
    NULL AS [PatientEthnicity],
    NULL AS [PatientLanguage],
	1 PatientIsActive, 
	getdate() PatientUpdatedDateTime
from tievmdb03.Ntier_627200.PM.Patients p
left join tievmdb03.Ntier_627200.PM.Contacts c on p.Contact_ID = c.Contact_ID
left join tievmdb03.Ntier_627200.PM.Addresses a on c.Address_ID = a.Address_ID

END
GO
