CREATE VIEW [fact].[vVisitCaseStaff] as
SELECT
[VisitCaseStaffID]
,[VisitCaseStaffDatasourceID]
,[VisitCaseStaffSourceID]
,[VisitCaseID]
,[VisitCaseStaffLine]
,[VisitCaseStaffName]
,[VisitCaseStaffCred]
,[VisitCaseStaffType]
,[VisitCaseStaffSubtype]
,[VisitCaseStaffAccountableStaff]
,[VisitCaseStaffDurationMinutes]
,[VisitCaseStaffIsActive]
,[VisitCaseStaffUpdatedDatetime]
,CASE 
	WHEN VisitCaseStaffType = 'Anesthesia Assistant' THEN 10
	WHEN VisitCaseStaffType = 'Anesthesia Staff' THEN 10
	WHEN VisitCaseStaffType = 'Anesthesia Technician' THEN 10
	WHEN VisitCaseStaffType = 'Anesthesiologist' THEN 10
	WHEN VisitCaseStaffType = 'Assisting' THEN 10
	WHEN VisitCaseStaffType = 'Baby Advocate' THEN 10
	WHEN VisitCaseStaffType = 'Cath Lab Nurse' THEN 10
	WHEN VisitCaseStaffType = 'Cath Lab Scrub' THEN 10
	WHEN VisitCaseStaffType = 'Cell Saver Operator' THEN 10
	WHEN VisitCaseStaffType = 'Circulator' THEN 10
	WHEN VisitCaseStaffType = 'Control Room Technologist' THEN 10
	WHEN VisitCaseStaffType = 'CRNA' THEN 10
	WHEN VisitCaseStaffType = 'CRNA Student' THEN 10
	WHEN VisitCaseStaffType = 'Documenter' THEN 10
	WHEN VisitCaseStaffType = 'Endoscopy Nurse' THEN 10
	WHEN VisitCaseStaffType = 'Endoscopy Technician' THEN 10
	WHEN VisitCaseStaffType = 'Fellow' THEN 10
	WHEN VisitCaseStaffType = 'Fourth Circulator' THEN 10
	WHEN VisitCaseStaffType = 'Fourth Surgical Technologist' THEN 10
	WHEN VisitCaseStaffType = 'Interventionalist/Radiologist' THEN 10
	WHEN VisitCaseStaffType = 'Laser Staff' THEN 10
	WHEN VisitCaseStaffType = 'Mammography Technologist' THEN 10
	WHEN VisitCaseStaffType = 'MCS Coordinator' THEN 10
	WHEN VisitCaseStaffType = 'Monitoring Staff' THEN 10
	WHEN VisitCaseStaffType = 'Nurse Practitioner' THEN 10
	WHEN VisitCaseStaffType = 'Perfusionist' THEN 10
	WHEN VisitCaseStaffType = 'Phase II Nurse' THEN 10
	WHEN VisitCaseStaffType = 'Physician' THEN 10
	WHEN VisitCaseStaffType = 'Physician Assistant' THEN 10
	WHEN VisitCaseStaffType = 'Post-op Nurse' THEN 10
	WHEN VisitCaseStaffType = 'Pre-Procedural Nurse' THEN 10
	WHEN VisitCaseStaffType = 'Preprocedure Nurse' THEN 10
	WHEN VisitCaseStaffType = 'Primary' THEN 10
	WHEN VisitCaseStaffType = 'Private Dental Assistant' THEN 10
	WHEN VisitCaseStaffType = 'Private Surgical Technologist' THEN 10
	WHEN VisitCaseStaffType = 'Pulmonologist' THEN 10
	WHEN VisitCaseStaffType = 'Radiology Nurse' THEN 10
	WHEN VisitCaseStaffType = 'Radiology PA' THEN 10
	WHEN VisitCaseStaffType = 'Radiology Technologist' THEN 10
	WHEN VisitCaseStaffType = 'Recovery Nurse' THEN 10
	WHEN VisitCaseStaffType = 'Registered Nurse First Assistant' THEN 10
	WHEN VisitCaseStaffType = 'Relief Circulator' THEN 10
	WHEN VisitCaseStaffType = 'Relief Laser Staff' THEN 10
	WHEN VisitCaseStaffType = 'Relief Surgical Technologist' THEN 10
	WHEN VisitCaseStaffType = 'Resident - Assisting' THEN 10
	WHEN VisitCaseStaffType = 'Resident - Observing' THEN 10
	WHEN VisitCaseStaffType = 'Respiratory Therapist' THEN 10
	WHEN VisitCaseStaffType = 'Second Circulator' THEN 10
	WHEN VisitCaseStaffType = 'Second Surgical Technologist' THEN 10
	WHEN VisitCaseStaffType = 'Sedation Nurse' THEN 10
	WHEN VisitCaseStaffType = 'Sonographer' THEN 10
	WHEN VisitCaseStaffType = 'Surgical Technologist' THEN 10
	WHEN VisitCaseStaffType = 'Surgical Technologist First Assistant' THEN 10
	WHEN VisitCaseStaffType = 'Telemedicine Consult - APRN' THEN 10
	WHEN VisitCaseStaffType = 'Telemedicine Consult - Cardiology' THEN 10
	WHEN VisitCaseStaffType = 'Telemedicine Consult - CRNA/AA' THEN 10
	WHEN VisitCaseStaffType = 'Third Circulator' THEN 10
	WHEN VisitCaseStaffType = 'Third Surgical Technologist' THEN 10
	WHEN VisitCaseStaffType = 'Treatment Nurse' THEN 10
	WHEN VisitCaseStaffType = 'Urologist' THEN 10
	WHEN VisitCaseStaffType = 'Urologist' THEN 10
	END AS HourlyRate,
	FORMAT(cast([VisitCaseStaffDurationMinutes] as decimal(6,2)) * CAST(
	CASE 
	WHEN VisitCaseStaffType = 'Anesthesia Assistant' THEN 10
	WHEN VisitCaseStaffType = 'Anesthesia Staff' THEN 10
	WHEN VisitCaseStaffType = 'Anesthesia Technician' THEN 10
	WHEN VisitCaseStaffType = 'Anesthesiologist' THEN 10
	WHEN VisitCaseStaffType = 'Assisting' THEN 10
	WHEN VisitCaseStaffType = 'Baby Advocate' THEN 10
	WHEN VisitCaseStaffType = 'Cath Lab Nurse' THEN 10
	WHEN VisitCaseStaffType = 'Cath Lab Scrub' THEN 10
	WHEN VisitCaseStaffType = 'Cell Saver Operator' THEN 10
	WHEN VisitCaseStaffType = 'Circulator' THEN 10
	WHEN VisitCaseStaffType = 'Control Room Technologist' THEN 10
	WHEN VisitCaseStaffType = 'CRNA' THEN 10
	WHEN VisitCaseStaffType = 'CRNA Student' THEN 10
	WHEN VisitCaseStaffType = 'Documenter' THEN 10
	WHEN VisitCaseStaffType = 'Endoscopy Nurse' THEN 10
	WHEN VisitCaseStaffType = 'Endoscopy Technician' THEN 10
	WHEN VisitCaseStaffType = 'Fellow' THEN 10
	WHEN VisitCaseStaffType = 'Fourth Circulator' THEN 10
	WHEN VisitCaseStaffType = 'Fourth Surgical Technologist' THEN 10
	WHEN VisitCaseStaffType = 'Interventionalist/Radiologist' THEN 10
	WHEN VisitCaseStaffType = 'Laser Staff' THEN 10
	WHEN VisitCaseStaffType = 'Mammography Technologist' THEN 10
	WHEN VisitCaseStaffType = 'MCS Coordinator' THEN 10
	WHEN VisitCaseStaffType = 'Monitoring Staff' THEN 10
	WHEN VisitCaseStaffType = 'Nurse Practitioner' THEN 10
	WHEN VisitCaseStaffType = 'Perfusionist' THEN 10
	WHEN VisitCaseStaffType = 'Phase II Nurse' THEN 10
	WHEN VisitCaseStaffType = 'Physician' THEN 10
	WHEN VisitCaseStaffType = 'Physician Assistant' THEN 10
	WHEN VisitCaseStaffType = 'Post-op Nurse' THEN 10
	WHEN VisitCaseStaffType = 'Pre-Procedural Nurse' THEN 10
	WHEN VisitCaseStaffType = 'Preprocedure Nurse' THEN 10
	WHEN VisitCaseStaffType = 'Primary' THEN 10
	WHEN VisitCaseStaffType = 'Private Dental Assistant' THEN 10
	WHEN VisitCaseStaffType = 'Private Surgical Technologist' THEN 10
	WHEN VisitCaseStaffType = 'Pulmonologist' THEN 10
	WHEN VisitCaseStaffType = 'Radiology Nurse' THEN 10
	WHEN VisitCaseStaffType = 'Radiology PA' THEN 10
	WHEN VisitCaseStaffType = 'Radiology Technologist' THEN 10
	WHEN VisitCaseStaffType = 'Recovery Nurse' THEN 10
	WHEN VisitCaseStaffType = 'Registered Nurse First Assistant' THEN 10
	WHEN VisitCaseStaffType = 'Relief Circulator' THEN 10
	WHEN VisitCaseStaffType = 'Relief Laser Staff' THEN 10
	WHEN VisitCaseStaffType = 'Relief Surgical Technologist' THEN 10
	WHEN VisitCaseStaffType = 'Resident - Assisting' THEN 10
	WHEN VisitCaseStaffType = 'Resident - Observing' THEN 10
	WHEN VisitCaseStaffType = 'Respiratory Therapist' THEN 10
	WHEN VisitCaseStaffType = 'Second Circulator' THEN 10
	WHEN VisitCaseStaffType = 'Second Surgical Technologist' THEN 10
	WHEN VisitCaseStaffType = 'Sedation Nurse' THEN 10
	WHEN VisitCaseStaffType = 'Sonographer' THEN 10
	WHEN VisitCaseStaffType = 'Surgical Technologist' THEN 10
	WHEN VisitCaseStaffType = 'Surgical Technologist First Assistant' THEN 10
	WHEN VisitCaseStaffType = 'Telemedicine Consult - APRN' THEN 10
	WHEN VisitCaseStaffType = 'Telemedicine Consult - Cardiology' THEN 10
	WHEN VisitCaseStaffType = 'Telemedicine Consult - CRNA/AA' THEN 10
	WHEN VisitCaseStaffType = 'Third Circulator' THEN 10
	WHEN VisitCaseStaffType = 'Third Surgical Technologist' THEN 10
	WHEN VisitCaseStaffType = 'Treatment Nurse' THEN 10
	WHEN VisitCaseStaffType = 'Urologist' THEN 10
	WHEN VisitCaseStaffType = 'Urologist' THEN 10 END as decimal(6,2)) / CAST(60 as decimal(6,2)), 'N2') AS TotalStaffCost 
	FROM [HPIDW].[fact].[VisitCaseStaff] vc
GO
