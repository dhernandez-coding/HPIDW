CREATE VIEW [rpt].[vUSPI_DIM_Case] as 

WITH ItemCosts AS (
    SELECT 
        AccountID,
        VisitID,
        ItemType,
        SUM(VisitItemExtendedCost) AS TotalCost
    FROM fact.VisitItems
    WHERE ItemType IN ('Implants', 'Supplies')
    GROUP BY AccountID, VisitID, ItemType
),
Implants AS (
    SELECT         
	AccountID,
        VisitID,
        ItemType,
         TotalCost as ImplantsCost
		 FROM ItemCosts WHERE ItemType = 'Implants'
),
Supplies AS (
    SELECT 
	AccountID,
        VisitID,
        ItemType,
         TotalCost as SuppliesCost
	FROM ItemCosts WHERE ItemType = 'Supplies'
),
ModifierCombination as (
		SELECT
		vp.VisitProcedureAccountID,
		CONCAT(vp.VisitProcedureMod1,'/',vp.VisitProcedureMod2,'/',vp.VisitProcedureMod3,'/',vp.VisitProcedureMod4) as modifier_combination,
		CONCAT(vp.VisitProcedureMod1,' ',vp.VisitProcedureMod2,' ',vp.VisitProcedureMod3,' ',vp.VisitProcedureMod4) as modifier_combination_grouping
		FROM fact.vVisitProcedures vp
	), 
CountProcedures as (
		SELECT 
		vp.VisitProcedureAccountID,
		MAX([VisitProcedureSequence]) as ProcedureCount
		FROM fact.vVisitProcedures vp
		GROUP BY
		vp.VisitProcedureAccountID
	
	),
AggregatedProcedures AS (
  SELECT
    vp.VisitProcedureAccountID,
    STRING_AGG(vp.VisitProcedureCode, '/ ') AS procedure_combination
  FROM fact.VisitProcedures vp
  GROUP BY vp.VisitProcedureAccountID
)

SELECT
    'HPI' AS company_code, 
    vc.VisitCaseLocationID AS facility_code,
    p.ProviderID AS physician_code,
    vp.VisitProcedureCode AS procedure_code,
    py.PayerID AS payor_code,
    pat.PatientID AS patient_code,
    vc.VisitCaseServiceDate AS date_of_service,
    vc.VisitCaseID AS case_id,
    a.AccountClass AS patient_type_code, 
    v.VisitType AS visit_type_code,
    1 AS case_count, -- Hardcoded value as seen in example query
    a.AccountTotalCharges AS case_charge_amount,
    a.AccountTotalPayments AS case_primary_payment_amount,
    NULL AS case_copay_payment_amount, -- Not available in example query
    a.AccountTotalAdjustments AS case_writeoff_amount,
    0 AS case_bad_debt_amount, -- Not available in example query
    (a.AccountTotalCharges + a.AccountTotalPayments + a.AccountTotalAdjustments) AS case_outstanding_bal_amount, -- Derived
    a.AccountBillingStatus AS balance_category, -- Placeholder
    0 AS net_revenue_pct, -- Placeholder
    cp.ProcedureCount AS procedure_count, -- Placeholder (assumes one primary procedure per case)
    YEAR(vc.VisitCaseServiceDate) AS financial_year,
    MONTH(vc.VisitCaseServiceDate) AS financial_period,
    vd.VisitDiagnosisCode AS icd9_code, -- Example ICD-9 diagnosis
    vc.VisitCaseService AS service_code,
    DATEDIFF(MINUTE, vc.VisitCaseBeginDatetime, vc.VisitCaseEndDatetime) AS or_minutes, -- Duration in minutes
    s.SuppliesCost AS supply_cost, -- Placeholder
    NULL AS staff_cost, -- Placeholder
    NULL AS equipment_cost, -- Placeholder
    i.ImplantsCost AS implant_cost, 
    NULL AS case_refund_amount, -- Placeholder
    NULL AS case_misc_charge_amount, -- Placeholder
    a.AccountDRG AS drg_code,
    NULL AS inpatient_days, -- Not available in example query
    a.AccountSourceID AS account_number,
    NULL AS case_unapplied_payment_amount, -- Placeholder
    MONTH(vc.VisitCaseServiceDate) AS billing_period,
    DATEDIFF(YEAR, pat.PatientDateOfBirth, GETDATE()) AS patient_age, -- Derived
    r.RoomName AS or_room,
    l.LocationSourceID AS entity_code, -- Derived from facility/location
    vc.VisitCaseScheduleStatus AS case_status,
    NULL AS case_tob_writeoff_amount, -- Placeholder
    NULL AS case_top_writeoff_amount, -- Placeholder
    a.AccountClass AS patient_class_code,
    (a.AccountTotalCharges + a.AccountTotalAdjustments) AS expected_collections, -- Placeholder
    0 AS expected_collections_est_ind, -- Placeholder
    a.AccountDateOfBilling AS original_bill_date, -- Placeholder
    vp.VisitProcedureMod1 AS modifier1_code, 
    vp.VisitProcedureMod2 AS modifier2_code, 
    vp.VisitProcedureMod3 AS modifier3_code, 
    vp.VisitProcedureMod4 AS modifier4_code, 
    NULL AS modifier5_code, -- Placeholder
    NULL AS charge_revenue_code, -- Placeholder
    NULL AS refer_physician_code, -- Placeholder
    NULL AS latest_bill_date, -- Placeholder
    procedure_combination  AS procedure_combination, -- Placeholder
    'UNKNOW' AS case_payor_status, -- Placeholder
    mc.modifier_combination AS modifier_combination, -- Placeholder
    mc.modifier_combination_grouping AS modifier_combination_grouping, -- Placeholder
    NULL AS total_asc_time, -- Placeholder
    vc.VisitCaseAnesthesiaProviderID AS anesthesia_provider_code,
    NULL AS fixed_cost, -- Placeholder
    NULL AS icd10_code -- Placeholder for ICD-10 codes

FROM fact.VisitCases vc
LEFT JOIN fact.vVisits2 v ON v.VisitID = vc.VisitCaseVisitID 
LEFT JOIN dim.vProviders p ON p.ProviderID = vc.VisitCasePrimaryProviderID
LEFT JOIN fact.vAccounts a ON a.AccountID = v.VisitAccountID
LEFT JOIN dim.vPayers py ON py.PayerID = a.AccountPrimaryPayerID
LEFT JOIN fact.VisitProcedures vp ON vp.VisitProcedureAccountID = a.AccountID AND vp.VisitProcedureIsPrimary = 1
LEFT JOIN dim.vPatients pat ON pat.PatientID = v.VisitPatientID
LEFT JOIN dim.Rooms r ON r.RoomID = vc.VisitCaseRoomID 
LEFT JOIN dim.Locations l ON l.LocationID = vc.VisitCaseLocationID
LEFT JOIN fact.VisitDiagnoses vd ON vd.VisitDiagnosisVisitID = vc.VisitCaseVisitID AND vd.VisitDiagnosisIsPrimary = '1'
left join Implants i on i.AccountID = a.AccountID
left join ModifierCombination mc on mc.VisitProcedureAccountID = a.AccountID
left join Supplies s on s.AccountID = a.AccountID
left join CountProcedures cp on cp.VisitProcedureAccountID = a.AccountID
left join AggregatedProcedures ap on ap.VisitProcedureAccountID = v.VisitAccountID
WHERE 1=1 
  AND vc.VisitCaseDatesourceID = 5
GO
