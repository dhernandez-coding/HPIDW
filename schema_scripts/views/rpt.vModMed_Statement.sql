CREATE VIEW [rpt].[vModMed_Statement] AS
/*
********************************************************************************
View Name: rpt.vModMed_Statement
Description: Patient Statement View.
             - Grain: ONE ROW PER BILL ITEM.
             - Logic: Filters out line items where insurance is pending (>0).
             - Totals: Synchronized to show only finalized patient balances.
********************************************************************************
*/
WITH ItemBalances AS (
    -- Calculate balances at the line-item level
    SELECT 
        ar.bill_item_id,
        ar.patient_id,
        MIN(ar.posted_date) AS posted_date,
        SUM(CASE WHEN ar.responsible = 'PATIENT' THEN ar.balance ELSE 0 END) AS patient_balance,
        SUM(CASE WHEN ar.responsible = 'INSURANCE' THEN ar.balance ELSE 0 END) AS insurance_balance
    FROM [HPIDW].[stg].[ModMed_AR] ar
    GROUP BY ar.bill_item_id, ar.patient_id
),
PatientTotals AS (
    -- Sum up totals, but only include lines that are NOT pending insurance
    -- This ensures the "Total Due" matches the finalized lines shown on the statement
    SELECT 
        patient_id,
        SUM(CASE WHEN insurance_balance <= 0 THEN patient_balance ELSE 0 END) AS total_patient_balance_finalized,
        SUM(CASE WHEN insurance_balance > 0 THEN insurance_balance ELSE 0 END) AS total_insurance_balance_pending
    FROM ItemBalances
    GROUP BY patient_id
),
Provider_Cleanup AS (
    -- Deduplicated provider info
    SELECT DISTINCT 
        staff_id, 
        first_name + ' ' + last_name AS provider_name
    FROM (
        SELECT staff_id, first_name, last_name,
               ROW_NUMBER() OVER (PARTITION BY staff_id ORDER BY (SELECT NULL)) as rn
        FROM stg.ModMed_Provider
    ) sub
    WHERE rn = 1
)
SELECT 
    '5.28.0' AS version,
    CAST(GETDATE() AS DATE) AS statementDate,
    'P-' + CAST(bi.patient_id AS VARCHAR(50)) AS statementNumber,
    CAST(p.mrn AS VARCHAR(50)) AS accountNumber,
    
    -- Practice / Remit Info
    'The Physicians Group' AS [name],
    'PO Box 1730' AS [address],
    'Lowell, AR 72745-1730' AS cityStateZip,
    'The Physicians Group' AS name2,
    'PO Box 1730' AS address3,
    'Lowell, AR 72745-1730' AS cityStateZip4,
    
    -- Patient Demographics
    p.first_name + ' ' + p.last_name AS name5,
    p.home_street1 AS address6,
    p.home_street2 AS line2Address,
    p.home_city AS city,
    p.home_state AS state,
    p.home_zipcode AS [zip],
    ISNULL(p.home_country, 'US') AS country,
    
    -- Guarantor Info
    p.first_name + ' ' + p.last_name AS name7,
    p.home_street1 AS address8,
    p.home_street2 AS line2Address9,
    p.home_city AS city10,
    p.home_state AS state11,
    p.home_zipcode AS zip12,
    'US' AS country13,
    
    -- Service Information
    CAST(bi.service_date_to AS DATE) AS dateOfService,
    ISNULL(pp.provider_name, 'Staff Provider') AS providerName,
    'Oklahoma Skin Associates' AS locationName,
    bi.code_description AS [description],
    
    -- Financials per line
    bi.charge AS chargeAmount,
    'Patient Statement' AS name14,
    CAST(ib.posted_date AS DATE) AS postingDate,
    ISNULL(bi.total_payments, 0) AS paidAmount,
    ISNULL(bi.applied_adjustments_total, 0) AS adjustmentAmount,
    ib.insurance_balance AS insuranceBalance,
    ib.patient_balance AS patientBalance,
    
    -- Metadata
    'Patient Pay' AS balanceBreakdown,
    bi.bill_id AS chargeId,
    
    -- Aging Buckets (Finalized Only)
    CASE WHEN DATEDIFF(DAY, ib.posted_date, GETDATE()) <= 30 THEN ib.patient_balance ELSE 0 END AS [current],
    CASE WHEN DATEDIFF(DAY, ib.posted_date, GETDATE()) BETWEEN 31 AND 60 THEN ib.patient_balance ELSE 0 END AS over30days,
    CASE WHEN DATEDIFF(DAY, ib.posted_date, GETDATE()) BETWEEN 61 AND 90 THEN ib.patient_balance ELSE 0 END AS over60days,
    CASE WHEN DATEDIFF(DAY, ib.posted_date, GETDATE()) BETWEEN 91 AND 120 THEN ib.patient_balance ELSE 0 END AS over90days,
    CASE WHEN DATEDIFF(DAY, ib.posted_date, GETDATE()) > 120 THEN ib.patient_balance ELSE 0 END AS over120days,
    
    '' AS dunningMessage,
    '' AS remitMessage,
    '' AS announcement,
    '' AS additionalMessage,
    
    -- Patient Totals (Finalized)
    0 AS patientCredit,
    pt.total_patient_balance_finalized AS totalPatientDue,
    0 AS totalInsuranceDue, -- Shows total insurance is currently processing
    CAST(p.date_of_birth AS DATE) AS patientDOB

FROM [HPIDW].[stg].[ModMed_BillItems] bi
JOIN stg.ModMed_Patient p on p.patient_id = bi.patient_id
LEFT JOIN stg.ModMed_Bills tb on tb.bill_id = bi.bill_id
JOIN ItemBalances ib on ib.bill_item_id = bi.bill_item_id
LEFT JOIN PatientTotals pt on pt.patient_id = bi.patient_id
LEFT JOIN Provider_Cleanup pp on pp.staff_id = tb.primary_provider_id 

WHERE ib.patient_balance <> 0 
  AND ib.insurance_balance <= 0; -- Exclude items where insurance is still pending
GO
