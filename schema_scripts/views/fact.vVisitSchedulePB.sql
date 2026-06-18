CREATE VIEW [fact].[vVisitSchedulePB] AS


SELECT
	  vs.[VisitScheduleVisitID]
      ,vs.[VisitScheduleDataSourceID]
      ,vs.[VisitScheduleSourceID]
      ,vs.[VisitScheduleAccountID]
      ,vs.[VisitScheduleDate]
      ,vs.[VisitSchedulePatientID]
	  ,pt.PatientFullName as VisitSchedulePatientName
      ,vs.[VisitScheduleStatus]
	  ,pd.PracticeID
	  ,pr.PracticeName
      ,vs.[VisitScheduleDepartmentID]
	  ,d.DepartmentName as VisitScheduleDepartmentName
      ,vs.[VisitScheduleSpecialty]
      ,vs.[VisitScheduleLocationID]
	  ,l.LocationName as VisitScheduleLocatonName
      ,vs.[VisitScheduleProviderID]
	  ,vs.VisitSchedulePayerID
	  ,pp.PayerName
	  ,pp.PayerCategoryName
	  ,pp.PayerGroupName
	  ,p.ProviderFullName as VisitScheduleProviderName
      ,vs.[VisitScheduleType]
      ,vs.[VisitScheduleScheduleDate]
      ,vs.[VisitScheduleAppointmentDate]
      ,vs.[VisitScheduleCheckinTime]
      ,vs.[VisitScheduleInRoomTime]
      ,vs.[VisitScheduleProviderInTime]
      ,vs.[VisitScheduleEndTime]
      ,vs.[VisitScheduleCheckoutTime]
      ,vs.[VisitScheduleTimeToRoom]
      ,vs.[VisitScheduleTimeInRoom]
      ,vs.[VisitScheduleVisitDuration]
	  ,DATEDIFF(minute, vs.VisitScheduleTimeInRoom, vs.VisitScheduleProviderInTime) as VisitScheduleInRoomToProviderDuraton --something is wrong with the date formats.  not getting accurate numbers
	  ,DATEDIFF(minute, vs.VisitScheduleScheduleDate, vs.VisitScheduleAppointmentDate) as VisitScheduleTimeToAppointmentDuration
	  ,DATEDIFF(minute, vs.VisitScheduleAppointmentDate, vs.VisitScheduleTimeInRoom) as VisitScheduleLateStartMinutes --something is wrong with the date formats.  not getting accurate numbers
	  --,DATEDIFF(minute, vs.VisitScheduleAppointmentDate, vs.VisitScheduleCheckinTime) as test
	  ,CASE WHEN vs.VisitScheduleCheckinTime - vs.VisitScheduleAppointmentDate > 0 THEN 'Late Check In'
	  	--WHEN (vs.VisitScheduleCheckinTime - vs.VisitScheduleAppointmentDate < -10) and (vs.VisitScheduleCheckinTime - vs.VisitScheduleAppointmentDate <= 0) THEN 'On Time'
	  	WHEN vs.VisitScheduleCheckinTime - vs.VisitScheduleAppointmentDate >= -10 THEN 'Early Arrival'
		END as VisitScheduleArrivalStatus
      ,vs.[VisitScheduleSameDayCancellation]
      ,vs.[VisitScheduleConfirmationStatus]
      ,vs.[VisitScheduleConfirmationDate]
      ,vs.[VisitScheduleOverbook]
      ,vs.[VisitScheduleCancellationDate]
      ,vs.[VisitScheduleLateCancellation]
	  ,vs.VisitScheduleCopayDue
	  ,vs.VisitScheduleCopayCollected
      ,vs.[VisitScheduleUpdateDate]
  FROM [HPIDW].[fact].[VisitSchedulePB] vs
	LEFT JOIN dim.vProviders p on p.ProviderID = vs.VisitScheduleProviderID
	LEFT JOIN dim.vDepartments d on d.DepartmentID = vs.VisitScheduleDepartmentID
	LEFT JOIN dim.vPatients pt on pt.PatientID = vs.VisitSchedulePatientID
	LEFT JOIN dim.vLocations l on l.LocationID = vs.VisitScheduleLocationID
	LEFT JOIN map.PracticeDepartments pd on pd.DepartmentID = vs.VisitScheduleDepartmentID
	LEFT JOIN dim.Practices pr on pr.PracticeID = pd.PracticeID
	LEFT JOIN dim.vPayers pp on pp.PayerID = vs.VisitSchedulePayerID
WHERE 1=1 
	AND p.ProviderFullName NOT LIKE 'TPG%'
	AND p.ProviderFullName NOT LIKE 'HPIP%'
	AND p.ProviderFullName NOT LIKE 'CCC%'
	AND p.ProviderFullName NOT LIKE '%XR%'
	AND year(vs.[VisitScheduleDate]) >= (year(getdate()) - 2)
GO
