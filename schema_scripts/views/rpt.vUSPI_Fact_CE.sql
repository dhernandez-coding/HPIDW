CREATE  VIEW [rpt].[vUSPI_Fact_CE] AS 

	/* 
	=============================================
	 Author:		Diego Hernandez
	 Create date: 04/04/2025
	 Edits:
		1. 
	 Description:	View Created following Sample Data send by Bantu (USPI) 

		
	=============================================
	--*/

WITH ItemCosts AS (
    SELECT 
        AccountID,
        VisitID,
        ItemType,
        SUM(VisitItemExtendedCost) AS TotalCost
    FROM fact.VisitItems
    WHERE ItemType IN ('Implants', 'Supplies') and VisitItemDatasourceID ='5'
    GROUP BY AccountID, VisitID, ItemType
),
Implants AS (
    SELECT AccountID, VisitID, TotalCost AS ImplantsCost
    FROM ItemCosts WHERE ItemType = 'Implants'
),
Supplies AS (
    SELECT AccountID, VisitID, TotalCost AS SuppliesCost
    FROM ItemCosts WHERE ItemType = 'Supplies'
),
ModifierCombination AS (
    SELECT
        vp.VisitProcedureVisitID,
        MAX(CONCAT(vp.VisitProcedureMod1, '/', vp.VisitProcedureMod2, '/', vp.VisitProcedureMod3, '/', vp.VisitProcedureMod4)) AS modifier_combination,
        MAX(CONCAT(vp.VisitProcedureMod1, ' ', vp.VisitProcedureMod2, ' ', vp.VisitProcedureMod3, ' ', vp.VisitProcedureMod4)) AS modifier_combination_grouping
    FROM fact.vVisitProcedures vp
	where vp.VisitProcedureDataSourceID ='5'
	GROUP BY vp.VisitProcedureVisitID
),
CountProcedures AS (
    SELECT VisitProcedureVisitID, COUNT(VisitProcedureVisitID) AS ProcedureCount
    FROM fact.vVisitProcedures vp
	where vp.VisitProcedureDataSourceID ='5' 
    GROUP BY VisitProcedureVisitID
),
AggregatedProcedures AS (
    SELECT vp.VisitProcedureVisitID,
           STRING_AGG(vp.VisitProcedureCode, '/ ') AS procedure_combination
    FROM fact.vVisitProcedures vp
	where vp.VisitProcedureDataSourceID ='5' 
    GROUP BY VisitProcedureVisitID
),
AggregatedCharges AS (
SELECT 
  sub.TransactionAccountID,
  sub.TransactionCPTCode,
  SUM(sub.TransactionAmount) AS charge_amount
FROM (
  SELECT * 
  FROM fact.vTransactions2 
  WHERE TransactionType = 'Charge'
  and TransactionDatasourceID = '5'
) AS sub
where sub.TransactionCPTCode is not null
GROUP BY
  sub.TransactionAccountID,
  sub.TransactionCPTCode)

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
    1 AS case_count,
    a.AccountTotalCharges AS case_charge_amount,
    a.AccountTotalPayments AS case_primary_payment_amount,
    NULL AS case_copay_payment_amount,
    a.AccountTotalAdjustments AS case_writeoff_amount,
    0 AS case_bad_debt_amount,
    cp.ProcedureCount AS procedure_count,
    YEAR(vc.VisitCaseServiceDate) AS financial_year,
    MONTH(vc.VisitCaseServiceDate) AS financial_period,
    vd.VisitDiagnosisCode AS icd9_code,
    vc.VisitCaseService AS service_code,
    DATEDIFF(MINUTE, vc.VisitCaseBeginDatetime, vc.VisitCaseEndDatetime) AS or_minutes,
    s.SuppliesCost AS supply_cost,
    NULL AS staff_cost,
    i.ImplantsCost AS implant_cost,
    NULL AS case_refund_amount,
    NULL AS case_misc_charge_amount,

    -- Placeholder fields
     ac.charge_amount AS cpt_charge_amount,
	 ac.TransactionCPTCode AS cpt_procedure_code,
    NULL AS net_rev_pct_rankbkt,
    NULL AS net_rev_dlr_rankbkt,
    NULL AS supply_cost_rankbkt,
    NULL AS sup_cost_pct_netrev_rankbkt,
    NULL AS net_rev_pct_rankdesc,
    NULL AS net_rev_dlr_rankdesc,
    NULL AS supply_cost_rankdesc,
    NULL AS sup_cost_pct_netrev_rankdesc,
    pat.PatientMRN AS account_name,

    a.AccountBillingStatus AS balance_category,
    a.AccountDRG AS drg_code,
    NULL AS inpatient_days,
    MONTH(vc.VisitCaseServiceDate) AS billing_period,
    NULL AS case_unapplied_payment_amount,
    cp.ProcedureCount AS case_procedure_count,
    DATEDIFF(YEAR, pat.PatientDateOfBirth, GETDATE()) AS patient_age,
    l.LocationSourceID AS entity_code,
    (a.AccountTotalCharges + a.AccountTotalPayments + a.AccountTotalAdjustments) AS case_outstanding_bal_amount,
    vc.VisitCaseScheduleStatus AS case_status,
    NULL AS case_tob_writeoff_amount,
    NULL AS case_top_writeoff_amount,
    a.AccountClass AS patient_class_code,
    (a.AccountTotalCharges + a.AccountTotalAdjustments) AS expected_collections,
    0 AS expected_collections_est_ind,
    a.AccountDateOfBilling AS billing_period_start_date,
    ap.procedure_combination,
    'UNKNOW' AS case_payor_status,
    r.RoomName AS or_room,
    NULL AS total_asc_time,
    NULL AS refer_physician_code,
    NULL AS fixed_cost,
    NULL AS icd10_code

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
LEFT JOIN Implants i ON i.VisitID = v.VisitID
LEFT JOIN Supplies s ON s.VisitID = v.VisitID
LEFT JOIN ModifierCombination mc ON mc.VisitProcedureVisitID = v.VisitID
LEFT JOIN CountProcedures cp ON cp.VisitProcedureVisitID = v.VisitID
LEFT JOIN AggregatedProcedures ap ON ap.VisitProcedureVisitID = vp.VisitProcedureVisitID
LEFT JOIN AggregatedCharges ac on ac.TransactionAccountID = a.AccountID
WHERE vc.VisitCaseDatesourceID = 5;
GO
