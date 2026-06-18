--Correct here charge_amount,payment_amount,writeoff_amount account num?? and transaction. 1-1 not aggregated

CREATE VIEW [rpt].[vUSPI_Fact_BC] as 
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
    SELECT AccountID, TotalCost as ImplantsCost
    FROM ItemCosts WHERE ItemType = 'Implants'
),
Supplies AS (
    SELECT AccountID, TotalCost as SuppliesCost
    FROM ItemCosts WHERE ItemType = 'Supplies'
),
ModifierCombination AS (
    SELECT
        t.TransactionAccountID,

        MAX(CONCAT(t.TransactionModifier1,'/',t.TransactionModifier2,'/',t.TransactionModifier3,'/',t.TransactionModifier4)) AS modifier_combination,
        MAX(CONCAT(t.TransactionModifier1,' ',t.TransactionModifier2,' ',t.TransactionModifier3,' ',t.TransactionModifier4)) AS modifier_combination_grouping
    FROM fact.vTransactions2 t
	WHERE 
    t.TransactionDatasourceID = '5'
	GROUP BY t.TransactionAccountID

	
),
AggregatedProcedures AS (
SELECT 
    t.TransactionAccountID,
    STRING_AGG(CONCAT(t.TransactionCPTCode, '/'), '') AS procedure_combination
FROM (
    SELECT DISTINCT 
        TransactionAccountID, 
        TransactionCPTCode
    FROM fact.vTransactions2
    WHERE TransactionDatasourceID = '5'
      AND TransactionType = 'Charge'
      AND TransactionCPTCode IS NOT NULL
) t
GROUP BY t.TransactionAccountID
)


SELECT
    'HPI' AS company_code,
	t.TransactionDateOfPosting AS date_posted,
    p.ProviderID AS physician_code,
    t.TransactionCPTCode,
    py.PayerID AS payor_code,
    'ph' AS payor_order,
    pat.PatientID AS patient_code,
    vc.VisitCaseLocationID AS facility_code,
    YEAR(vc.VisitCaseServiceDate) AS financial_year,
    MONTH(vc.VisitCaseServiceDate) AS financial_period,
    CASE WHEN t.TransactionType = 'Charge' then t.TransactionAmount ELSE 0 END AS charge_amount,
    CASE WHEN t.TransactionType = 'Payment' then t.TransactionAmount ELSE 0 END AS payment_amount,
	CASE WHEN t.TransactionType = 'Adjustment' then t.TransactionAmount ELSE 0 END AS writeoff_amount,
    vc.VisitCaseServiceDate AS date_of_service,
    t.TransactionDateOfPosting AS date_of_transaction,
    vc.VisitCaseID AS case_number,
    v.VisitType AS visit_type_code,
    t.TransactionID AS transaction_number,
    t.TransactionCode AS transaction_code,
    a.AccountSourceID AS account_number,
    t.TransactionID AS billing_number,
    vc.VisitCaseID AS case_id,
    a.AccountClass AS patient_type_code,
    vc.VisitCaseRoomID AS scheduled_room,
    NULL AS case_group,
    'Primary' AS payor_priority,
    NULL AS journal_code,
    CASE WHEN t.TransactionSubType = 'Adjustment - Credit'  THEN t.TransactionAmount ELSE NULL END AS refund_amount,
	NULL AS misc_charge_amount,
    NULL AS secondary_charge_amount,
    NULL AS transfer_amount,
    1 AS posted_ind,
    t.TransactionBillingProviderID AS billing_key,
    MONTH(vc.VisitCaseServiceDate) AS billing_period,
    'ph' AS unapplied_payment_amount,
    l.LocationSourceID AS entity_code,
    vc.VisitCaseScheduleStatus AS case_status,
    a.AccountClass AS patient_class_code,
    CASE WHEN t.TransactionType = 'Adjustment' then t.TransactionAmount ELSE 0 END AS tob_writeoff_amount,
    0 AS top_writeoff_amount,
    NULL AS bad_debt_writeoff_amount,
    t.TransactionModifier1 AS modifier1_code,
    t.TransactionModifier2 AS modifier2_code,
    t.TransactionModifier3 AS modifier3_code,
    t.TransactionModifier4 AS modifier4_code,
    NULL AS modifier5_code,
    t.TransactionRevenueCode AS charge_revenue_code,
    NULL AS row_sequence,
    'UNKNOWN' AS case_payor_status,
    a.AccountDateOfBilling AS original_bill_date,
    a.AccountDateOfBilling AS latest_bill_date,
    ap.procedure_combination AS procedure_combination,
    mc.modifier_combination,
    mc.modifier_combination_grouping,
    NULL AS refer_physician_code

FROM fact.VisitCases vc
LEFT JOIN fact.vVisits2 v ON v.VisitID = vc.VisitCaseVisitID
LEFT JOIN dim.vProviders p ON p.ProviderID = vc.VisitCasePrimaryProviderID
LEFT JOIN fact.vAccounts a ON a.AccountID = v.VisitAccountID 
LEFT JOIN fact.vTransactions2 t on t.TransactionAccountID = a.AccountID
LEFT JOIN dim.vPayers py ON py.PayerID = a.AccountPrimaryPayerID
LEFT JOIN dim.vPatients pat ON pat.PatientID = v.VisitPatientID
LEFT JOIN dim.Rooms r ON r.RoomID = vc.VisitCaseRoomID
LEFT JOIN dim.Locations l ON l.LocationID = vc.VisitCaseLocationID
--LEFT JOIN RankedProcedures rp ON rp.TransactionAccountID = a.AccountID
LEFT JOIN ModifierCombination mc ON mc.TransactionAccountID = a.AccountID
LEFT JOIN AggregatedProcedures ap ON ap.TransactionAccountID = a.AccountID
WHERE 1=1 
AND vc.VisitCaseDatesourceID = 5
GO
