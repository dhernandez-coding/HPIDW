CREATE view [rpt].[vEKKInvoice] as
SELECT
    gs.Service_Date_From as EKKInvoiceDateOfService,
    gs.Actual_Dr_Name as EKKInvoiceActualProvider, 
    gs.Update_Status as EKKInvoiceUpdateStatus,
    gs.Department_Abbr as EKKInvoiceDepartment,
    gs.Procedure_Insurance_Descr as EKKInvoiceProcedureDescription,
    CASE 
        WHEN gs.Modifiers IS NULL THEN gs.Procedure_Code 
        ELSE gs.Procedure_Code + '-' + gs.Modifiers  
    END as EKKInvoiceProcedureModifier,
    gs.Modifiers as EKKInvoiceModifier,
    gs.Procedure_Code as EKKInvoiceProcedureCode,
    gs.Service_Units as EKKInvoiceUnits,
    gs.Voucher_Number as EKKInvoiceVoucherNumber,
	gs.Claim_Number as EKKInvoiceClaimNumber,
    gs.Service_Fee as EKKInvoiceServiceFee,
    gs.Patient_Number as EKKInvoicePatientNumber,
    gs.Primary_Diagnosis_Code as EKKInvoicePrimaryDiagCode,
    MAX(CASE WHEN sd.Service_Diagnosis_Position = 2 AND gs.Update_Status = 1 THEN sd.Diagnosis_Code END) as EKKInvoiceSecondDiagnosisCode,
    MAX(CASE WHEN sd.Service_Diagnosis_Position = 3 AND gs.Update_Status = 1 THEN sd.Diagnosis_Code END) as EKKInvoiceThirdDiagnosisCode,
    ds.National_Drug_Code as EKKInvoiceNDC,
    gp.Patient_Name as EKKInvoicePatientName,
    gp.Prim_Policy_Certificate_No as EKKInvoicePolicyNumber,
    gp.Prim_Policy_Certificate_Suffix as EKKInvoicePolicyCertificate,
	gs.Billing_Carrier_Name as EKKPayerName,
    gp.Patient_Street1 as EKKInvoiceAddress1,
    gp.Patient_Street2 as EKKInvoiceAddress2,
    gp.Patient_City as EKKInvoiceCity,
    gp.Patient_State as EKKInvoiceState,
    gp.Patient_Zip_Code as EKKInvoiceZip
FROM tievmdb03.Ntier_627200.PM.vwGenSvcInfo gs
LEFT JOIN tievmdb03.Ntier_627200.PM.vwGenPatInfo gp 
    ON gp.Patient_ID = gs.Patient_ID 
LEFT JOIN tievmdb03.Ntier_627200.PM.Drug_Services ds 
    ON ds.Service_ID = gs.Service_ID
LEFT JOIN tievmdb03.Ntier_627200.PM.vwGenSvcDiagInfo sd  
    ON sd.Service_ID = gs.Service_ID
WHERE gs.Department_Abbr IN ('FKVP', 'FKVPRXS') 
    AND gs.Update_Status = 1
    --AND gs.Patient_Number = '1754080'
GROUP BY
    gs.Service_Date_From,
    gs.Actual_Dr_Name,
    gs.Update_Status,
    gs.Department_Abbr,
    gs.Procedure_Insurance_Descr,
    gs.Modifiers,
    gs.Procedure_Code,
    gs.Service_Units,
    gs.Voucher_Number,
	gs.Claim_Number,
    gs.Service_Fee,
    gs.Patient_Number,
    gs.Primary_Diagnosis_Code,
    ds.National_Drug_Code,
    gp.Patient_Name,
    gp.Prim_Policy_Certificate_No,
    gp.Prim_Policy_Certificate_Suffix,
	gs.Billing_Carrier_Name,
    gp.Patient_Street1,
    gp.Patient_Street2,
    gp.Patient_City,
    gp.Patient_State,
    gp.Patient_Zip_Code
GO
