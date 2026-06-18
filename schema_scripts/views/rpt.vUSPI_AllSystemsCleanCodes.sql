/* 
====================================================
 Author:      Diego Hernandez
 Create date: 10/17/2025
 Description: View built from rpt.vUSPI_Fact_CE to match 
              uspidnaproddata.edw_mgdcare.allsystemscleancodes structure.
====================================================
*/

CREATE   VIEW [rpt].[vUSPI_AllSystemsCleanCodes] AS


SELECT 
    ROW_NUMBER() OVER (ORDER BY vc.VisitCaseID) AS rowcounter,

    -- Identifiers and location
    vc.VisitCaseLocationID AS coid,
    l.LocationName AS commonname,
    l.LocationName AS facilityname,

    -- Financial / Payor data
    a.AccountClass AS financialclass,
    py.PayerName AS payor,
    v.VisitType AS inpt,

    -- Account / Patient info
    a.AccountID AS accountnumber,
    pat.PatientFullName AS patientname,
    vc.VisitCaseID AS casenum,
    NULL AS billingnumber,
	 
    -- Dates and encounter info
    vc.VisitCaseServiceDate AS dateofservice,
    a.AccountDRG AS drg,
    NULL AS revenuecode,
    DATEDIFF(DAY, vc.VisitCaseBeginDatetime, vc.VisitCaseEndDatetime) AS lengthofstay,

    -- CPT and related fields
    vp.VisitProcedureCode AS cptcode,
    ac.TransactionCPTCode AS cptcoderaw,
    NULL AS nonsurgeryrelatedcodes,

    -- OR times
    CONVERT(VARCHAR(20), vc.VisitCaseORBeginDatetime, 120) AS or_begintime,
    CONVERT(VARCHAR(20), vc.VisitCaseOREndDatetime, 120) AS or_endtime,

    -- Physician
    p.ProviderID AS physicianid,
    p.ProviderNPI AS npi,
    p.ProviderFullName AS physicianname,
    p.ParentSpecialtyID AS physicianspecialty,

    -- Financials
    ac.charge_amount AS chargeamount,
    a.AccountTotalPayments AS paymentamount,
    a.AccountTotalAdjustments AS adjustments,
    (a.AccountTotalCharges - a.AccountTotalPayments - a.AccountTotalAdjustments) AS balancedue,
    (a.AccountTotalPayments - a.AccountTotalAdjustments) AS netrevenue,

    -- Standardization placeholders
    p.ParentSpecialtyID AS standardspecialtyname,
    py.PayerName AS standardpayor,
    CASE WHEN vp.VisitProcedureIsPrimary = 1 THEN 'Y' ELSE 'N' END AS primaryprocflag,

    -- Metadata
    vc.VisitCaseBeginDatetime AS startdate,
    vc.VisitCaseEndDatetime AS enddate,
    NULL AS createuser,
    vc.VisitCaseServiceDate AS createdate,

    -- Units and contracts
    NULL AS units,
    NULL AS contract_num,
    NULL AS contract_name,

    -- Claim office info (not available)
    NULL AS claim_office_num,
    NULL AS claim_office_quick_code,
    NULL AS claim_office_name,

    -- Source system tracking
    'EPIC' AS source_system_id,
    GETDATE() AS load_ts

FROM fact.VisitCases vc
LEFT JOIN fact.vVisits2 v ON v.VisitID = vc.VisitCaseVisitID
LEFT JOIN dim.vProviders p ON p.ProviderID = vc.VisitCasePrimaryProviderID
LEFT JOIN fact.vAccounts a ON a.AccountID = v.VisitAccountID
LEFT JOIN dim.vPayers py ON py.PayerID = a.AccountPrimaryPayerID
LEFT JOIN fact.VisitProcedures vp ON vp.VisitProcedureAccountID = a.AccountID AND vp.VisitProcedureIsPrimary = 1
LEFT JOIN dim.vPatients pat ON pat.PatientID = v.VisitPatientID
LEFT JOIN dim.Locations l ON l.LocationID = vc.VisitCaseLocationID
LEFT JOIN rpt.vUSPI_Fact_CE ce ON ce.case_id = vc.VisitCaseID
LEFT JOIN (
    SELECT 
        sub.TransactionAccountID,
        sub.TransactionCPTCode,
        SUM(sub.TransactionAmount) AS charge_amount
    FROM fact.vTransactions2 sub
    WHERE sub.TransactionType = 'Charge'
      AND sub.TransactionDatasourceID = '5'
      AND sub.TransactionCPTCode IS NOT NULL
    GROUP BY sub.TransactionAccountID, sub.TransactionCPTCode
) AS ac ON ac.TransactionAccountID = a.AccountID
WHERE vc.VisitCaseDatesourceID = 5;
GO
