CREATE view [fact].[vEncounters] as

SELECT
	[EncounterID]
	,[EncounterDataSourceID]
	,d.DataSourceName as EncounterDatasource
	,[EncounterSourceID]
	,[EncounterVisitID]
	,[EncounterPatientID]
	,[EncounterLocationID]
	,COALESCE(l.LocationName,e.EncounterLocationID) as EncounterLocation
	,[EncounterDepartmentID]
	,COALESCE(dep.DepartmentName,e.EncounterDepartmentID) AS EncounterDepartment 
	,[EncounterRoom]
	,[EncounterPrimaryProviderID]
	,CASE WHEN [EncounterPrimaryProviderID] IS NOT NULL THEN COALESCE(npipf.ProviderName, CONCAT(prvpf.ProviderLastName,', ',prvpf.ProviderFirstName,' ', prvpf.ProviderMiddleInitial)) END as EncounterPrimaryProvider
	,COALESCE(npipf.ProviderSpecialty, spcpf.SpecialtyName) as EncounterPrimaryProviderSpecialty
	,[EncounterAdmittingProviderID]
	,CASE WHEN [EncounterAdmittingProviderID] IS NOT NULL THEN COALESCE(npiad.ProviderName, CONCAT(prvad.ProviderLastName,', ',prvad.ProviderFirstName,' ', prvad.ProviderMiddleInitial)) END as EncounterAdmittingProvider
	,COALESCE(npiad.ProviderSpecialty, spcad.SpecialtyName) as EncoutnerAdmittingProviderSpecialty
	,[EncounterAttendingProviderID]
	,CASE WHEN [EncounterAttendingProviderID] IS NOT NULL THEN COALESCE(npiat.ProviderName, CONCAT(prvat.ProviderLastName,', ',prvat.ProviderFirstName,' ', prvat.ProviderMiddleInitial)) END as EncounterAttendingProvider
	,COALESCE(npiat.ProviderSpecialty, spcat.SpecialtyName) as EncounterAttendingProviderSpecialty
	,[EncounterReferringProviderID]
	,[EncounterDateOfService]
	,[EncounterDateOfScheduling]
	,[EncounterDateOfRegistration]
	,[EncounterBeginDatetime]
	,[EncounterEndDatetime]
	,[EncounterDateOfCancellation]
	,[EncounterCancelledReason]
	,[EncounterStatus]
	,[EncounterClass]
	,[EncounterType]
	,CASE WHEN e.EncounterType in ('Surgery Admit','Outpatient Surgery','Outpatient', 'Observation','Inpatient','Emergent OR Case','OR Case') THEN spcpf.SpecialtyName
		  ELSE e.EncounterType END as EncounterServiceLine
	,[EncounterReason]
	,CASE WHEN e.EncounterID = e.ParentEncounterID THEN 'Yes' ELSE 'No' END as EncounterIsPrimary
	,EncounterIsSurgical
	,[EncounterIsActive]
	,[EncounterUpdatedDatetime]
FROM [HPIDW].[fact].[Encounters] e 
	left join dim.DataSources d ON d.DataSourceID = e.EncounterDataSourceID
	left join dim.Locations l ON l.LocationID = e.EncounterLocationID
	left join dim.Departments dep ON dep.DepartmentID = e.EncounterDepartmentID
	left join dim.Providers prvpf ON prvpf.ProviderID = e.EncounterPrimaryProviderID 
		left join dim.vProviderNPIs npipf ON npipf.ProviderNPI = prvpf.ProviderNPI
		left join dim.Specialties spcpf ON spcpf.SpecialtyID = prvpf.ProviderSpecialtyID
	left join dim.Providers prvad ON prvad.ProviderID = e.EncounterAdmittingProviderID 	
		left join dim.vProviderNPIs npiad ON npiad.ProviderNPI = prvad.ProviderNPI
		left join dim.Specialties spcad ON spcad.SpecialtyID = prvad.ProviderSpecialtyID
	left join dim.Providers prvat ON prvat.ProviderID = e.EncounterAttendingProviderID 
		left join dim.vProviderNPIs npiat ON npiat.ProviderNPI = prvat.ProviderNPI
		left join dim.Specialties spcat ON spcat.SpecialtyID = prvat.ProviderSpecialtyID
where year(EncounterDateOfService) >= (year(getdate()) - 2)
GO
