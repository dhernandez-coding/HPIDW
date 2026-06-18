CREATE VIEW [rpt].[vUSPI_Fact_CL] as 

SELECT
'HPI' as company_code,
v.VisitLocationID as facility_code,
v.VisitPatientID as patient_code,
vc.VisitCaseID as case_number,
v.VisitDateOfAdmission as admission_date,
v.VisitDateOfDischarge as discharge_date,
v.VisitRoomID as or_room,
ROW_NUMBER() OVER (PARTITION BY vc.VisitCaseID ORDER BY vp.VisitProcedureCode) AS procedure_count,
vc.VisitCaseTotalTimeNeeded as surgery_time,
vc.VisitCaseMinutesInRecovery as recovery_time_phase_1,
vc.VisitCaseRoomTurnoverDuration as or_turnover_time,
'ph' as physician_delay_time,
'ph' as incident_count,
'ph' as twenty_three_hour_observation,
'ph' as days_to_complete_medical_record,
'ph' as days_to_complete_op_notes,
'ph' as days_to_complete_follow_up,
vc.VisitCaseTotalTimeNeeded as total_staff_hours,
'ph' as staff_count,
'ph' as procedure_physician_count,
vc.VisitCaseASARating as asa_status_code,
vc.VisitCaseAnesthesiaType as anesthesia_type,
pat.PatientGender as sex,
DATEDIFF(YEAR, pat.PatientDateOfBirth, v.VisitDateOfService) AS patient_age,
null as race_code,
vc.VisitCasePhysician as physician_code,
vp.VisitProcedureCode as procedure_code,
ROW_NUMBER() OVER (PARTITION BY vc.VisitCaseID ORDER BY v.VisitRoomID) as or_room_count,
ROW_NUMBER() OVER (PARTITION BY vc.VisitCaseID ORDER BY vp.VisitProcedureCode) AS procedure_room_count,
l.LocationState as 'state',
l.LocationCity as city,
l.LocationZipCode as zip,
CAST(v.VisitDateOfAdmission AS TIME)  as admission_time,
CAST(v.VisitDateOfDischarge AS TIME) as dismissal_time,
a.AccountSourceID as account_number,
CAST(vc.VisitCasePreOpBeginDatetime AS TIME) as preop_start_time,
CAST(vc.VisitCasePreOpEndDatetime AS TIME) as preop_end_time,
DATEDIFF(MINUTE, vc.VisitCasePreOpBeginDatetime, vc.VisitCasePreOpEndDatetime) as preop_time,
'ph' as cut_start_time,
'ph' as cut_end_time,
CAST(vc.VisitCaseORBeginDatetime AS TIME) as or_start_time,
CAST(vc.VisitCaseOREndDatetime AS TIME) as or_end_time,
vc.VisitCaseRoomTurnoverDuration as or_time,
'ph' as anes_start_time,
'ph' as anes_end_time,
CAST(vc.VisitCaseRecoveryBeginDatetime as TIME) as start_recovery_time_phase_1,
CAST(vc.VisitCaseRecoveryEndDatetime as TIME) as end_recovery_time_phase_1,
'ph' as start_recovery_time_phase_2,
'ph' as end_recovery_time_phase_2,
a.AccountPrimaryPayerID as payor_code,
vc.VisitCaseLogStatus,
vc.VisitCasePreOpBeginDatetime as preop_start_datetime,
vc.VisitCasePreOpEndDatetime as preop_end_datetime,
'ph' as cut_start_datetime,
'ph' as cut_end_datetime,
vc.VisitCaseORBeginDatetime as or_start_datetime,
vc.VisitCaseOREndDatetime as or_end_datetime,
'ph' as anes_start_datetime,
'ph' as anes_end_datetime,
vc.VisitCaseRecoveryBeginDatetime  as start_recovery_datetime_phase_1,
vc.VisitCaseRecoveryEndDatetime as end_recovery_datetime_phase_1,
vc.VisitCasePhase2BeginDatetime as start_recovery_datetime_phase_2,
vc.VisitCasePhase2EndDatetime as end_recovery_datetime_phase_2,
'ph' as start_overnight_datetime,
'ph' as end_overnight_datetime,
'ph' as start_overnight_time,
'ph' as end_overnight_time,
'ph' as overnight_time,
STRING_AGG(vp.VisitProcedureCode, '/ ') AS procedure_combination,
vc.VisitCaseAnesthesiaProviderID

FROM fact.VisitCases vc
LEFT JOIN fact.vVisits2 v ON v.VisitID = vc.VisitCaseVisitID 
LEFT JOIN dim.vProviders p ON p.ProviderID = vc.VisitCasePrimaryProviderID
LEFT JOIN fact.vAccounts a ON a.AccountID = v.VisitAccountID
LEFT JOIN dim.vPayers py ON py.PayerID = a.AccountPrimaryPayerID
LEFT JOIN fact.VisitProcedures vp ON vp.VisitProcedureAccountID = a.AccountID AND vp.VisitProcedureIsPrimary = 1
LEFT JOIN dim.vPatients pat ON pat.PatientID = v.VisitPatientID
LEFT JOIN dim.Rooms r ON r.RoomID = vc.VisitCaseRoomID 
LEFT JOIN dim.Locations l ON l.LocationID = vc.VisitCaseLocationID
left join fact.vVisitCaseTimes vct on vct.VisitCaseTimesCaseID=vc.VisitCaseID



WHERE 1=1 
AND vc.VisitCaseDatesourceID = 5 

GROUP BY
    v.VisitLocationID,
    v.VisitPatientID,
    vc.VisitCaseID,
    v.VisitDateOfAdmission,
    v.VisitDateOfDischarge,
    v.VisitRoomID,
    vc.VisitCaseTotalTimeNeeded,
    vc.VisitCaseMinutesInRecovery,
    vc.VisitCaseRoomTurnoverDuration,
    vc.VisitCaseASARating,
    vc.VisitCaseAnesthesiaType,
    pat.PatientGender,
    pat.PatientDateOfBirth,
    v.VisitDateOfService,  
    vc.VisitCasePhysician,
    vp.VisitProcedureCode,
    l.LocationState,
    l.LocationCity,
    l.LocationZipCode,
    a.AccountSourceID,
    vc.VisitCasePreOpBeginDatetime,
    vc.VisitCasePreOpEndDatetime,
    a.AccountPrimaryPayerID,
    vc.VisitCaseLogStatus,
	vc.VisitCaseORBeginDatetime,
    vc.VisitCaseRecoveryBeginDatetime,
    vc.VisitCaseRecoveryEndDatetime,
	vc.VisitCaseOREndDatetime,
	vc.VisitCasePhase2BeginDatetime,
    vc.VisitCaseAnesthesiaProviderID,
	vc.VisitCasePhase2EndDatetime,
    CAST(v.VisitDateOfAdmission AS TIME),
    CAST(v.VisitDateOfDischarge AS TIME),
    CAST(vc.VisitCasePreOpBeginDatetime AS TIME),
    CAST(vc.VisitCasePreOpEndDatetime AS TIME),
    CAST(vc.VisitCaseORBeginDatetime AS TIME),
    CAST(vc.VisitCaseOREndDatetime AS TIME),
    CAST(vc.VisitCaseRecoveryBeginDatetime AS TIME),
    CAST(vc.VisitCaseRecoveryEndDatetime AS TIME);
GO
