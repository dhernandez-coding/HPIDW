/* 
====================================================
 Author:      Diego Hernandez
 Create date: 10/17/2025
 Description: View created to align with USPI Aging Summary 
              structure for integration with EDW.
====================================================
*/

CREATE   VIEW [rpt].[vUSPI_ARAging_Summary] AS
SELECT
    -- Core identifiers
    a.AccountDatasourceID AS tis_client_num,
    a.AccountID AS ptaccountnum,
    pat.PatientID AS psnum,
    vc.VisitCaseID AS casenum,
    pat.PatientMRN AS pers_org_num_pt,

    -- Patient demographics
    pat.PatientLastName AS lastname,
    pat.PatientFirstName AS firstname,
    pat.PatientFullName AS patientname,
    vc.VisitCaseServiceDate AS dateofservice,
    a.AccountDateOfBilling AS billtransdate,
    pat.PatientDateOfBirth AS patientdob,
    CASE WHEN a.AccountStatus = 'Active' THEN 1 ELSE 0 END AS active,

    -- Specialty information
    p.ParentSpecialtyID AS specialty,
    p.ParentSpecialtyName AS standardspecialty,

    -- Financial amounts
    a.AccountTotalCharges AS chargeamount,
    a.AccountTotalPayments AS paidamount,
    a.AccountTotalAdjustments AS writtenoffamount,
    NULL AS debitedamount,
    (a.AccountTotalCharges - a.AccountTotalPayments - a.AccountTotalAdjustments) AS amtdue,

    -- Aging buckets (placeholder logic)
    CASE 
        WHEN DATEDIFF(DAY, a.AccountDateOfBilling, GETDATE()) <= 30 THEN 'Current'
        WHEN DATEDIFF(DAY, a.AccountDateOfBilling, GETDATE()) BETWEEN 31 AND 60 THEN '31-60'
        WHEN DATEDIFF(DAY, a.AccountDateOfBilling, GETDATE()) BETWEEN 61 AND 90 THEN '61-90'
        WHEN DATEDIFF(DAY, a.AccountDateOfBilling, GETDATE()) BETWEEN 91 AND 120 THEN '91-120'
        WHEN DATEDIFF(DAY, a.AccountDateOfBilling, GETDATE()) BETWEEN 121 AND 150 THEN '121-150'
        ELSE '151+' 
    END AS bucketname,

    -- Numeric buckets
    CASE WHEN DATEDIFF(DAY, a.AccountDateOfBilling, GETDATE()) <= 30 THEN (a.AccountTotalCharges - a.AccountTotalPayments - a.AccountTotalAdjustments) ELSE 0 END AS currentamt,
    CASE WHEN DATEDIFF(DAY, a.AccountDateOfBilling, GETDATE()) BETWEEN 31 AND 60 THEN (a.AccountTotalCharges - a.AccountTotalPayments - a.AccountTotalAdjustments) ELSE 0 END AS age31to60,
    CASE WHEN DATEDIFF(DAY, a.AccountDateOfBilling, GETDATE()) BETWEEN 61 AND 90 THEN (a.AccountTotalCharges - a.AccountTotalPayments - a.AccountTotalAdjustments) ELSE 0 END AS age61to90,
    CASE WHEN DATEDIFF(DAY, a.AccountDateOfBilling, GETDATE()) BETWEEN 91 AND 120 THEN (a.AccountTotalCharges - a.AccountTotalPayments - a.AccountTotalAdjustments) ELSE 0 END AS age91to120,
    CASE WHEN DATEDIFF(DAY, a.AccountDateOfBilling, GETDATE()) BETWEEN 121 AND 150 THEN (a.AccountTotalCharges - a.AccountTotalPayments - a.AccountTotalAdjustments) ELSE 0 END AS age121to150,
    CASE WHEN DATEDIFF(DAY, a.AccountDateOfBilling, GETDATE()) > 150 THEN (a.AccountTotalCharges - a.AccountTotalPayments - a.AccountTotalAdjustments) ELSE 0 END AS age151plus,

    -- Descriptive and insurance information
    a.AccountClass AS category_desc,
    NULL AS commenttext,
    a.AccountUpdatedDatetime AS lastmodifieddate,

    -- Insurance / guarantor structure
    NULL AS patientpart,
    NULL AS secondaryguarantor,
    a.AccountPrimaryPayerID AS primaryinsurance,
    NULL AS secondaryinsurance,
    NULL AS tertiaryinsurance,
    py.PayerName AS payorname,
    NULL AS inscarrquickcode,
    NULL AS payordesc,
    py.PayerName AS payor,

    -- Source metadata
    'EPIC' AS source_system_id,
    GETDATE() AS load_ts

FROM fact.vAccounts a
LEFT JOIN fact.vVisits2 v ON a.AccountID = v.VisitAccountID
LEFT JOIN fact.VisitCases vc ON vc.VisitCaseVisitID = v.VisitID
LEFT JOIN dim.vPatients pat ON pat.PatientID = v.VisitPatientID
LEFT JOIN dim.vProviders p ON p.ProviderID = vc.VisitCasePrimaryProviderID
LEFT JOIN dim.vPayers py ON py.PayerID = a.AccountPrimaryPayerID
WHERE a.AccountDatasourceID = 5;
GO
