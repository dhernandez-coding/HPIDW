CREATE VIEW  [rpt].[vUSPI_Daily_CaseDetails] AS

	/* 
	=============================================
	 Author:		Chris Cross
	 Create date: 09/11/2024
	 Edits:
		1. 
	 Description:	This view provides a row for every hospital account with a surgical case.  It was custom built for the USPI/Tenet partnership to give them direct access to query hospital case information.
	 2. Edited by Diego Hernandez adding patient contact information, emergency status and diagnosis , I include height, weight,BMI and other information required by USPI
	 3.Edited by Diego Hernandez adding Medicare Number, and pivot procedures, laterality and diagnosis
	 4. Edited by Chris Cross to add Patient MRN
	 5. Edited by Diego Hernandez - ETL needed data to fact tables and create a with to deal with agregation in a better way
	 6. Edited by Diego Hernandez - ETL the suscriber number to transactions and to vTransactions to include it on this rpt as PrimarySubscriberNumber 
	 7. Edited by Diego Hernandez - CTE for SecondarySubscriber number and SecondaryPayor.
	 8. Edited by Diego Hernandez - Added CSN.
		
	=============================================
	--*/

/*Version 5 */

WITH AggDiagnosis as (
SELECT 
VisitDiagnosisVisitID,
CAST (STRING_AGG(VisitDiagnosisCode,'/') AS VARCHAR(256)) as Diagnoses
FROM fact.VisitDiagnoses
GROUP BY 
VisitDiagnosisVisitID
)
,SecondaryProviders as (

select 
	CONCAT('5~',h.HSP_ACCOUNT_ID) as AccountID ,
    -- Pivot for PAYOR_ID
    -- Payor Pivot
    MAX(CASE WHEN h.LINE = 1 THEN p.PayerName END) AS PrimaryPayor,
    MAX(CASE WHEN h.LINE = 2 THEN p.PayerName END) AS SecondaryPayor,
    MAX(CASE WHEN h.LINE = 3 THEN p.PayerName END) AS ThirdPayor,
    MAX(CASE WHEN h.LINE = 4 THEN p.PayerName END) AS FourthPayor,

    -- Subscriber Number Pivot
    MAX(CASE WHEN h.LINE = 1 THEN c.SUBSCR_NUM END) AS PrimarySubscriber,
    MAX(CASE WHEN h.LINE = 2 THEN c.SUBSCR_NUM END) AS SecondarySubscriber,
    MAX(CASE WHEN h.LINE = 3 THEN c.SUBSCR_NUM END) AS ThirdSubscriber,
    MAX(CASE WHEN h.LINE = 4 THEN c.SUBSCR_NUM END) AS FourthSubscriber

from [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].HSP_ACCT_CVG_LIST h  
left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].COVERAGE C ON h.COVERAGE_ID= C.COVERAGE_ID
left join dim. vPayers p  on p.PayerID = CONCAT('5~',c.PAYOR_ID)
where HSP_ACCOUNT_ID like '6%'
GROUP BY h.HSP_ACCOUNT_ID

)


SELECT
    vc.VisitCaseLocationID AS FacilityNo,
    l.LocationName AS FacilityName,
    'HOSP' AS FacType,
    v.VisitType AS EncounterType,
    vc.VisitCaseService AS SpecialtyDescription,
    py.PayerCategoryName AS PayorDescription,
    vc.VisitCaseID AS CaseNumber,
    vc.VisitCaseServiceDate AS DateOfService,
    vc.VisitCaseScheduledDatetime AS ScheduledDate,
    vc.VisitCaseScheduleStatus AS CaseStatus,
    p.ProviderFullName AS PhysicianName,
    vc.VisitCaseService AS StandardSpecialty,
    pat.PatientMobilePhone,
    pat.PatientHomePhone,
    pat.PatientEmailAddress,
    ad.Diagnoses AS PrimaryDiagnoses, -- Consolidates all diagnoses
    py.PayerName AS StandardPayor,
    a.AccountTotalCharges AS ChargeAmount,
    a.AccountTotalAdjustments AS WriteOffAmount,
    1 AS CaseCount,
    NULL AS ReasonDescription,
    CASE WHEN vc.VisitCaseScheduleStatus = 'Canceled' THEN vc.VisitCaseCancelledDate END AS CancelDate,
    vc.VisitCaseService AS PhysicianSpecialty,
    NULL AS GenerateClaim,
    NULL AS ClaimGenerated,
    a.AccountTotalPayments AS PaidAmount,
    NULL AS PatientPart,
    STRING_AGG(vp.VisitProcedureCode, '/ ') AS ProcedureCodes, -- Consolidates all procedure codes
    STRING_AGG(vp.VisitProcedureDescription, '/ ') AS ProcedureDescriptions, -- Consolidates all procedure descriptions
	vc.VisitCasePrimaryScheduledProcedure AS PrimaryScheduledProcedure,
	vc.[VisitCaseLaterality] as Lateralities,
    r.RoomSourceID AS RoomNum,
    r.RoomName AS RoomName,
    vc.VisitCaseBeginDatetime AS ORBeginTime,
    vc.VisitCaseEndDatetime AS OREndTime,
    p.ProviderNPI AS PhysicianNPI,
    p.ProviderPhone AS PhysicianPhone,
    a.AccountSourceID AS AccountNum,
    CASE WHEN vc.VisitCaseScheduleStatus = 'Canceled' THEN ISNULL(vc.VisitCaseCancelledReason, 'Unspecified') END AS CancelCategory,
    pat.PatientLastName AS PatientLastName,
    pat.PatientFirstName AS PatientFirstName,
    pat.PatientDateOfBirth,
    NULL AS NursingUnit,
	vc.[VisitCaseEmergencyStatus] AS EmergencyStatus,
    1 AS SurgCaseCount,
    py.PayerName AS inscarrier_name,
    vc.VisitCaseService AS medical_service,
    a.AccountDRG AS DRG,
    a.AccountDRGDescription AS DRGDescription,
    a.AccountClass AS AccountClass,
    vc.VisitCaseWeight AS PatientWeight,
    vc.VisitCaseHeight AS PatientHeight,
    vc.VisitCaseBMI AS PatientBMI,
	a.AccountBeneficiaryNumber as PrimarySubscriberNumber,
	CASE WHEN sp.SecondaryPayor is not null then sp.SecondaryPayor else NULL end as SecondaryPayor,
	CASE WHEN sp.SecondarySubscriber is not null then sp.SecondarySubscriber else NULL end as SecondarySubscriberNumber,
	pat.PatientMRN as PatientMRN,
	vc.VisitCaseCSN as VisitCaseCSN


FROM fact.VisitCases vc
LEFT JOIN fact.vVisits2 v ON v.VisitID = vc.VisitCaseVisitID 
LEFT JOIN dim.vProviders p ON p.ProviderID = vc.VisitCasePrimaryProviderID
LEFT JOIN fact.vAccounts a ON a.AccountID = v.VisitAccountID
LEFT JOIN dim.vPayers py ON py.PayerID = a.AccountPrimaryPayerID
LEFT JOIN fact.VisitProcedures vp ON vp.VisitProcedureAccountID = a.AccountID AND vp.VisitProcedureIsPrimary = 1
LEFT JOIN dim.vPatients pat ON pat.PatientID = v.VisitPatientID
LEFT JOIN dim.Rooms r ON r.RoomID = vc.VisitCaseRoomID 
LEFT JOIN dim.Locations l ON l.LocationID = vc.VisitCaseLocationID
LEFT JOIN AggDiagnosis ad on ad.VisitDiagnosisVisitID = vc.VisitCaseVisitID
LEFT JOIN  SecondaryProviders sp on sp.AccountID = a.AccountID


WHERE 1=1 
AND vc.VisitCaseDatesourceID = 5

GROUP BY
    vc.VisitCaseLocationID,
    l.LocationName,
    v.VisitType,
    vc.VisitCaseService,
    py.PayerCategoryName,
    vc.VisitCaseID,
    vc.VisitCaseServiceDate,
    vc.VisitCaseScheduledDatetime,
    vc.VisitCaseScheduleStatus,
    p.ProviderFullName,
    pat.PatientMobilePhone,
    pat.PatientHomePhone,
    pat.PatientEmailAddress,
    py.PayerName,
    a.AccountTotalCharges,
    a.AccountTotalAdjustments,
    vc.VisitCaseCancelledDate,
    r.RoomSourceID,
    r.RoomName,
    vc.VisitCaseBeginDatetime,
    vc.VisitCaseEndDatetime,
    p.ProviderNPI,
    p.ProviderPhone,
    a.AccountSourceID,
    vc.VisitCaseCancelledReason,
    pat.PatientLastName,
    pat.PatientFirstName,
    pat.PatientDateOfBirth,
    a.AccountDRG,
    a.AccountDRGDescription,
    a.AccountClass,
	a.AccountTotalPayments,
    vc.VisitCaseWeight,
    vc.VisitCaseHeight,
    vc.VisitCaseBMI,
	vc.VisitCasePrimaryScheduledProcedure,
	pat.PatientMRN,
	vc.[VisitCaseLaterality],
	pat.PatientMedicareNumber,
	vc.[VisitCaseEmergencyStatus],
	ad.Diagnoses,
	a.AccountBeneficiaryNumber,
	sp.SecondaryPayor,
	sp.SecondarySubscriber,
	vc.VisitCaseCSN




--/*Version 3*/
--SELECT
--    vc.VisitCaseLocationID AS FacilityNo,
--    l.LocationName AS FacilityName,
--    'HOSP' AS FacType,
--    v.VisitType AS EncounterType,
--    vc.VisitCaseService AS SpecialtyDescription,
--    py.PayerCategoryName AS PayorDescription,
--    vc.VisitCaseID AS CaseNumber,
--    vc.VisitCaseServiceDate AS DateOfService,
--    vc.VisitCaseScheduledDatetime AS ScheduledDate,
--    vc.VisitCaseScheduleStatus AS CaseStatus,
--    p.ProviderFullName AS PhysicianName,
--    vc.VisitCaseService AS StandardSpecialty,
--    pat.PatientMobilePhone,
--    pat.PatientHomePhone,
--    pat.PatientEmailAddress,
--    STRING_AGG(vd.[VisitDiagnosisDescription], '/ ') AS PrimaryDiagnoses, -- Consolidates all diagnoses
--    py.PayerName AS StandardPayor,
--    a.AccountTotalCharges AS ChargeAmount,
--    a.AccountTotalAdjustments AS WriteOffAmount,
--    1 AS CaseCount,
--    NULL AS ReasonDescription,
--    CASE WHEN vc.VisitCaseScheduleStatus = 'Canceled' THEN vc.VisitCaseCancelledDate END AS CancelDate,
--    vc.VisitCaseService AS PhysicianSpecialty,
--    NULL AS GenerateClaim,
--    NULL AS ClaimGenerated,
--    a.AccountTotalPayments AS PaidAmount,
--    NULL AS PatientPart,
--    STRING_AGG(vp.VisitProcedureCode, '/ ') AS ProcedureCodes, -- Consolidates all procedure codes
--    STRING_AGG(vp.VisitProcedureDescription, '/ ') AS ProcedureDescriptions, -- Consolidates all procedure descriptions
--    op.PROC_DISPLAY_NAME AS PrimaryScheduledProcedure,
--    STRING_AGG(lrb.NAME, '/ ') AS Lateralities, -- Consolidates all lateralities
--    r.RoomSourceID AS RoomNum,
--    r.RoomName AS RoomName,
--    vc.VisitCaseBeginDatetime AS ORBeginTime,
--    vc.VisitCaseEndDatetime AS OREndTime,
--    p.ProviderNPI AS PhysicianNPI,
--    p.ProviderPhone AS PhysicianPhone,
--    a.AccountSourceID AS AccountNum,
--    CASE WHEN vc.VisitCaseScheduleStatus = 'Canceled' THEN ISNULL(vc.VisitCaseCancelledReason, 'Unspecified') END AS CancelCategory,
--    pat.PatientLastName AS PatientLastName,
--    pat.PatientFirstName AS PatientFirstName,
--    pat.PatientDateOfBirth,
--    NULL AS NursingUnit,
--    orl.EMERG_STATUS_YN AS EmergencyStatus,
--    1 AS SurgCaseCount,
--    py.PayerName AS inscarrier_name,
--    vc.VisitCaseService AS medical_service,
--    a.AccountDRG AS DRG,
--    a.AccountDRGDescription AS DRGDescription,
--    a.AccountClass AS AccountClass,
--    vc.VisitCaseWeight AS PatientWeight,
--    vc.VisitCaseHeight AS PatientHeight,
--    vc.VisitCaseBMI AS PatientBMI,
--    pp.MEDICARE_NUM AS MedicareNumber,
--	pat.PatientMRN as PatientMRN



--FROM fact.VisitCases vc
--LEFT JOIN fact.vVisits2 v ON v.VisitID = vc.VisitCaseVisitID 
--LEFT JOIN dim.vProviders p ON p.ProviderID = vc.VisitCasePrimaryProviderID
--LEFT JOIN fact.vAccounts a ON a.AccountID = v.VisitAccountID
--LEFT JOIN dim.vPayers py ON py.PayerID = a.AccountPrimaryPayerID
--LEFT JOIN fact.VisitProcedures vp ON vp.VisitProcedureAccountID = a.AccountID AND vp.VisitProcedureIsPrimary = 1
--LEFT JOIN dim.vPatients pat ON pat.PatientID = v.VisitPatientID
--LEFT JOIN dim.Rooms r ON r.RoomID = vc.VisitCaseRoomID 
--LEFT JOIN dim.Locations l ON l.LocationID = vc.VisitCaseLocationID
--LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].OR_CASE_ALL_PROC op ON CONCAT('5~',op.OR_CASE_ID) = vc.VisitCaseID AND op.LINE = 1
--LEFT JOIN [fact].[VisitDiagnoses] vd on vd.VisitDiagnosisVisitID = vc.VisitCaseVisitID AND vd.[VisitDiagnosisIsPrimary] = '1'
--LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].OR_LOG orl on orl.CASE_ID = op.OR_CASE_ID
--LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[dbo].PATIENT pp ON CONCAT('5~', pp.PAT_ID)= pat.PatientID
--LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].OR_CASE_ALL_PROC oc ON CONCAT('5~', oc.OR_CASE_ID) = vc.VisitCaseID
--LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_OR_LRB lrb on lrb.LRB_C = oc.LRB_C 
--WHERE 1=1 
--AND vc.VisitCaseDatesourceID = 5

--GROUP BY
--    vc.VisitCaseLocationID,
--    l.LocationName,
--    v.VisitType,
--    vc.VisitCaseService,
--    py.PayerCategoryName,
--    vc.VisitCaseID,
--    vc.VisitCaseServiceDate,
--    vc.VisitCaseScheduledDatetime,
--    vc.VisitCaseScheduleStatus,
--    p.ProviderFullName,
--    pat.PatientMobilePhone,
--    pat.PatientHomePhone,
--    pat.PatientEmailAddress,
--    py.PayerName,
--    a.AccountTotalCharges,
--    a.AccountTotalAdjustments,
--    vc.VisitCaseCancelledDate,
--    op.PROC_DISPLAY_NAME,
--    r.RoomSourceID,
--    r.RoomName,
--    vc.VisitCaseBeginDatetime,
--    vc.VisitCaseEndDatetime,
--    p.ProviderNPI,
--    p.ProviderPhone,
--    a.AccountSourceID,
--    vc.VisitCaseCancelledReason,
--    pat.PatientLastName,
--    pat.PatientFirstName,
--    pat.PatientDateOfBirth,
--    orl.EMERG_STATUS_YN,
--    a.AccountDRG,
--    a.AccountDRGDescription,
--    a.AccountClass,
--	a.AccountTotalPayments,
--    vc.VisitCaseWeight,
--    vc.VisitCaseHeight,
--    vc.VisitCaseBMI,
--    pp.MEDICARE_NUM,
--	pat.PatientMRN
GO
