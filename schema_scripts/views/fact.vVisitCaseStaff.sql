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
,cast(CASE 
WHEN VisitCaseStaffType = 'Anesthesia Provider' THEN 10
WHEN VisitCaseStaffType = 'Circulator' THEN 10
WHEN VisitCaseStaffType = 'General Staff' THEN 10
WHEN VisitCaseStaffType = 'Other Anesthesia Staff' THEN 10
WHEN VisitCaseStaffType = 'Phase II Nurse' THEN 40.50
WHEN VisitCaseStaffType = 'Physician' THEN 10
WHEN VisitCaseStaffType = 'Preprocedure Nurse' THEN 40.50
WHEN VisitCaseStaffType = 'Recovery Nurse' THEN 40.50
WHEN VisitCaseStaffType = 'Scrub Nurse' THEN 40.50
WHEN VisitCaseStaffType = 'Surgical Tech' THEN 29.50
END as decimal(18,2)) AS VisitCaseStaffHourlyRate,
CASE 
WHEN VisitCaseStaffType = 'Anesthesia Provider' THEN round(cast([VisitCaseStaffDurationMinutes] as money) * CAST(10 as money) / CAST(60 as money), 2)
WHEN VisitCaseStaffType = 'Circulator' THEN round(cast([VisitCaseStaffDurationMinutes] as money) * CAST(10 as money) / CAST(60 as money), 2)
WHEN VisitCaseStaffType = 'General Staff' THEN round(cast([VisitCaseStaffDurationMinutes] as money) * CAST(10 as money) / CAST(60 as money), 2)
WHEN VisitCaseStaffType = 'Other Anesthesia Staff' THEN round(cast([VisitCaseStaffDurationMinutes] as money) * CAST(10 as money) / CAST(60 as money), 2)
WHEN VisitCaseStaffType = 'Phase II Nurse' and svc.name = 'Pain Management' THEN round(cast(24 as money) * CAST(40.50 as money) /  CAST(60 as money), 2)
WHEN VisitCaseStaffType = 'Phase II Nurse' and svc.name = 'Endoscopy' THEN round(cast(35 as money) * CAST(40.50 as money) /  CAST(60 as money), 2)
WHEN VisitCaseStaffType = 'Phase II Nurse' and svc.name NOT IN ('Pain Management', 'Endoscopy') THEN round(cast(37 as money) * CAST(40.50 as money) /  CAST(60 as money), 2)
WHEN VisitCaseStaffType = 'Physician' THEN round(cast([VisitCaseStaffDurationMinutes] as money) * CAST(10 as money) / CAST(60 as money), 2)
WHEN VisitCaseStaffType = 'Preprocedure Nurse' and svc.name = 'Pain Management' THEN round(cast(25 as money) * CAST(40.50 as money) /  CAST(60 as money), 2)
WHEN VisitCaseStaffType = 'Preprocedure Nurse' and svc.name = 'Endoscopy' THEN round(cast(30 as money) * CAST(40.50 as money) /  CAST(60 as money), 2)
WHEN VisitCaseStaffType = 'Preprocedure Nurse' and svc.name NOT IN ('Pain Management', 'Endoscopy') THEN round(cast(41 as money) * CAST(40.50 as money) /  CAST(60 as money), 2)
WHEN VisitCaseStaffType = 'Recovery Nurse' and svc.name = 'Pain Management' THEN round(cast(0 as money) * CAST(40.50 as money) /  CAST(60 as money), 2)
WHEN VisitCaseStaffType = 'Recovery Nurse' and svc.name = 'Endoscopy' THEN round(cast(0 as money) * CAST(40.50 as money) /  CAST(60 as money), 2)
WHEN VisitCaseStaffType = 'Recovery Nurse' and svc.name NOT IN ('Pain Management', 'Endoscopy') THEN round(cast(43 as money) * CAST(40.50 as money) /  CAST(60 as money), 2)
WHEN VisitCaseStaffType = 'Scrub Nurse' THEN round(cast([VisitCaseStaffDurationMinutes] as money) * CAST(40.50 as money) / CAST(60 as money), 2)
WHEN VisitCaseStaffType = 'Surgical Tech' THEN round(cast([VisitCaseStaffDurationMinutes] as money) * CAST(29.50 as money) / CAST(60 as money), 2) END as VisitCaseStaffTotalStaffCost
FROM [HPIDW].[fact].[VisitCaseStaff] vs
LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].OR_CASE orc ON vs.VisitCaseID = CONCAT('5~',orc.or_case_id)
LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_OR_SERVICE svc ON orc.SERVICE_C = svc.SERVICE_C
GO
