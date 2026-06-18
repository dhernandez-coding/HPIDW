CREATE VIEW [rpt].[vUSPI_FACT_SD] AS

WITH ProcedureCombination AS (
SELECT 
    vp.VisitProcedureVisitID,
    STRING_AGG(vp.VisitProcedureCode, '/ ') AS procedure_combination
FROM (
    SELECT DISTINCT VisitProcedureVisitID, VisitProcedureCode
    FROM fact.vVisitProcedures
    WHERE VisitProcedureDatasourceID = '5'
) vp
GROUP BY vp.VisitProcedureVisitID

)

SELECT
    'HPI' AS company_code,
    v.VisitLocationID AS facility_code,
    v.VisitPatientID AS patient_code,
    vc.VisitCaseID AS case_number,
    vc.VisitCasePhysician AS physician_code,
    'ph' AS physician_group_code,
    'ph' AS refer_physician_code,
    vp.VisitProcedureCode AS procedure_code,
    vc.VisitCaseRoomID AS scheduled_room,
    vc.VisitCaseAnesthesiaType AS anesthesia_type,
    vc.VisitCaseID AS case_id,
    v.VisitID AS appt_code,
    vc.VisitCaseScheduleStatus  AS appt_status,
    v.VisitDateOfScheduling AS appt_create_date,
    v.VisitType AS appt_type_code,
    vc.VisitCaseCancelledReason AS appt_cancel_reason,
    vc.VisitCaseServiceDate AS appt_date,
    DATENAME(WEEKDAY, vc.VisitCaseServiceDate) AS day_of_week,
    CAST(vc.VisitCaseORBeginDatetime AS TIME) AS appt_start_time,
    CAST(vc.VisitCaseOREndDatetime AS TIME) AS appt_end_time,
    DATEDIFF(MINUTE, vc.VisitCaseORBeginDatetime, vc.VisitCaseOREndDatetime) AS appt_duration,
    --DATEDIFF(DAY, vc.VisitCaseCreateDatetime, vc.VisitCaseServiceDate) AS appt_sched_lag,
    1 AS appt_count,
    vc.VisitCaseCancelledReason  AS appt_cancel_reason_quick_code,
    vc.VisitCaseRoomTurnoverDuration AS or_time,
    'ph' AS or_duration_diff_bucket_mins,
    'ph' AS or_duration_diff_bucket_desc,
    'ph' AS or_duration_diff_bucket_group,
    vc.VisitCaseTotalTimeNeeded AS surgery_duration,
    'ph' AS duration_diff_bucket_mins,
    'ph' AS duration_diff_bucket_desc,
    'ph' AS duration_diff_bucket_group,
    a.AccountSourceID AS account_number,
    DATEDIFF(MINUTE, v.VisitDateOfAdmission, vc.VisitCaseORBeginDatetime) AS admission_time_lag,
    DATEDIFF(MINUTE, vc.VisitCaseOREndDatetime, v.VisitDateOfDischarge) AS dismissal_time_lag,
    'ph' AS delayed_start_time,
    'ph' AS block_code,
    ROW_NUMBER() OVER (PARTITION BY vc.VisitCaseID ORDER BY vp.VisitProcedureCode) AS row_sequence,
    pc.procedure_combination,
    vp.VisitProcedureCodeType AS procedure_type,
    'ph' AS server_id,
    'ph' AS database_id

FROM fact.VisitCases vc
LEFT JOIN fact.vVisits2 v ON v.VisitID = vc.VisitCaseVisitID
LEFT JOIN fact.vAccounts a ON a.AccountID = v.VisitAccountID
LEFT JOIN fact.VisitProcedures vp ON vp.VisitProcedureAccountID = a.AccountID AND vp.VisitProcedureIsPrimary = 1
LEFT JOIN ProcedureCombination pc ON pc.VisitProcedureVisitID = v.VisitID
LEFT JOIN dim.Locations l ON l.LocationID = vc.VisitCaseLocationID
LEFT JOIN dim.vPatients pat ON pat.PatientID = v.VisitPatientID


WHERE vc.VisitCaseDatesourceID = 5

GROUP BY
    v.VisitLocationID,
    v.VisitPatientID,
    vc.VisitCaseID,
    vc.VisitCasePhysician,
    vp.VisitProcedureCode,
    vc.VisitCaseRoomID,
    vc.VisitCaseAnesthesiaType,
    vc.VisitCaseServiceDate,
    vc.VisitCaseORBeginDatetime,
    vc.VisitCaseOREndDatetime,
    --vc.VisitCaseCreateDatetime,
    vc.VisitCaseRoomTurnoverDuration,
    vc.VisitCaseTotalTimeNeeded,
    a.AccountSourceID,
    v.VisitDateOfAdmission,
    v.VisitDateOfDischarge,
	vc.VisitCaseScheduleStatus, 
    pc.procedure_combination,
	v.VisitDateOfScheduling,
	vc.VisitCaseCancelledReason,
	vp.VisitProcedureCodeType,
	v.VisitID,
	v.VisitType
GO
