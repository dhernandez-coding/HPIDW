CREATE VIEW [fact].[vVisitAvailabilityPB] AS


SELECT
	  VisitAvailabilityID
      ,va.VisitAvailabilityVisitID
      ,va.VisitAvailabilityDataSourceID
      ,va.VisitAvailabilityDate
      ,va.VisitAvailabilityPatientID
	  ,pt.PatientFullName as VisitAvailabilityPatientName
	  ,pd.PracticeID
	  ,pr.PracticeName
      ,va.VisitAvailabilityDepartmentID
	  ,d.DepartmentName as VisitAvailabilityDepartmentName
      ,va.VisitAvailabilitySpecialty
      ,va.VisitAvailabilityLocationID
	  ,l.LocationName as VisitAvailabilityLocationName
      ,va.VisitAvailabilityProviderID
	  ,p.ProviderFullName as VisitAvailabilityProviderName
      ,va.VisitAvailabilityAppointmentFlag
      ,va.VisitAvailabilityType
      ,va.VisitAvailabilityUnavailable
      ,va.VisitAvailabilityUnavailableReason
      ,va.VisitAvailabilityOutsideTemplate
      ,va.VisitAvailabilityOverbook
      ,va.VisitAvailabilityRegularOpening
      ,va.VisitAvailabilityOverbookOpening
      ,va.VisitAvailabilitySlotLength
      ,va.VisitAvailabilityBeginTime
      ,va.VisitAvailabilityEndTime
      ,va.VisitAvailabilityUpdateDate
FROM [HPIDW].[fact].[VisitAvailabilityPB] va
	LEFT JOIN dim.vProviders p on p.ProviderID = va.VisitAvailabilityProviderID
	LEFT JOIN dim.vDepartments d on d.DepartmentID = va.VisitAvailabilityDepartmentID
	LEFT JOIN dim.vPatients pt on pt.PatientID = va.VisitAvailabilityPatientID
	LEFT JOIN dim.vLocations l on l.LocationID = va.VisitAvailabilityLocationID
	LEFT JOIN map.PracticeDepartments pd on pd.DepartmentID = va.VisitAvailabilityDepartmentID
	LEFT JOIN dim.Practices pr on pr.PracticeID = pd.PracticeID
WHERE 1=1 
	AND p.ProviderFullName NOT LIKE 'TPG%'
	AND p.ProviderFullName NOT LIKE 'HPIP%'
	AND p.ProviderFullName NOT LIKE 'CCC%'
	AND p.ProviderFullName NOT LIKE '%XR%'
	AND year(va.[VisitAvailabilityDate]) >= (year(getdate()) - 1)
GO
