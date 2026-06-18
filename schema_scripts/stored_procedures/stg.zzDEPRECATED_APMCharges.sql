-- =============================================
-- Author:		Ryan Tisserand
-- Create date: 08/12/2022
-- Description:	Pulls Payment and Charge Data from APM Source System
-- Change Control
--	1. 08/12/2022 - Initial build of procedure
-- =============================================
CREATE PROCEDURE [etl].[spAPMTransactions]
AS
BEGIN
SET NOCOUNT ON;

-------------------REBUILD----------------------
select top 10
	svc.Patient_ID PatientID, 
	svc.Voucher_ID VoucherID, 
	svc.Voucher_Number VoucherNumber, 
	svc.service_id ServiceID, 
	'C' AS TransType, 
	'Charge' AS TransCodeAbbr, 
	'Charge' AS TransCodeDescr, 
	1 AS Update_status, 
	CONVERT(DATETIME, svc.Posting_Date, 101) AS Posting_Date, 
	CONVERT(DATETIME, svc.Service_Date_From, 101) AS Service_Date_From, 
	--CONVERT(DATETIME, vch.voucher_service_date, 101) AS voucher_service_date, 
	--rp.abbreviation AS RptPd, 
	--CONVERT(DATETIME, rp.start_date, 101) AS RptPd_StartDt, 
	--CONVERT(DATETIME, isnull(rp.end_date, '2999-12-31'), 101) AS RptPd_EndDt, 
	svc.Actual_Dr_Abbr, 
	svc.Actual_Dr_Name, 
	svc.actual_dr_lfi, 
	svc.Billing_Dr_Abbr, 
	svc.Billing_Dr_Name, 
	svc.billing_dr_lfi, 
	svc.refer_dr_abbr, 
	svc.refer_dr_name, 
	svc.refer_dr_lfi, 
	svc.Billing_Carrier_ID AS CurrInsId, 
	svc.Billing_Carrier_Abbr AS CurrInsAbbr, 
	svc.Billing_Carrier_Name AS CurrInsName, 
	svc.Original_Carrier_ID AS OrigInsId, 
	svc.Original_Carrier_Abbr AS OrigInsAbbr, 
	svc.Original_Carrier_Name AS OrigInsName, 
	svc.Original_Carrier_ID AS TransInsID, 
	svc.Original_Carrier_Abbr AS TransInsAbbr, 
	svc.Original_Carrier_Name AS TransInsName, 
	svc.Department_Abbr, 
	svc.Department_Descr, 
	svc.Location_Abbr, 
	svc.Location_Descr, 
	svc.Procedure_Code, 
	svc.Procedure_Insurance_Descr, 
	svc.proc_category_abbr AS PrCtgy_Abbr, 
	svc.proc_category_descr AS PrCtgy_Desc, 
	svc.Modifiers, 
	svc.Primary_Diagnosis_Code, 
	svc.Primary_Diagnosis_Descr, 
	svc.Service_Units AS Units, 
	--isnull(pr.Work_RVUs, 0) AS work_rvu, 
	--isnull(pr.Practice_Expense_RVUs, 0) AS pract_rvu, 
	--isnull(pr.Malpractice_RVUs, 0) AS malpr_rvu, 
	svc.Service_Fee AS Amount, 
	svc.Service_Fee AS Charges, 
	0 AS Payments, 
	0 AS Adjustments, 
	0 AS Refunds, 
	0 AS Misc_Debits, 
	svc.Primary_Diag_Code_Set, 
	svc.Primary_Diag_Long_Descr, 
	svc.Tenant_ID, 
	--PRACTINFO.Name AS Tenant_Name, 
	NULL AS Service_PMT_ID
from TIEHPIVMDB03.Ntier_627200.PM.vwGenSvcInfo svc


-------------------COUNTS----------------------
--select count(1) from TIEHPIVMDB03.Ntier_627200.PM.vwGenSvcInfo -- 3625903
--select count(1) from TIEHPIVMDB03.Ntier_627200.PM.vwGenVouchInfo -- 1785210
--select count(1) from TIEHPIVMDB03.Ntier_627200.PM.Procedure_Codes -- 18093
--select count(1) from TIEHPIVMDB03.Ntier_627200.PM.reporting_periods -- 68
--select count(1) from TIEHPIVMDB03.Ntier_627200.PM.Practice_Information -- 1

-------------------TOP 10----------------------
--select top 10 * from TIEHPIVMDB03.Ntier_627200.PM.vwGenSvcInfo
--select top 10 * from TIEHPIVMDB03.Ntier_627200.PM.vwGenVouchInfo 
--select top 10 * from TIEHPIVMDB03.Ntier_627200.PM.Procedure_Codes
--select top 10 * from TIEHPIVMDB03.Ntier_627200.PM.reporting_periods
--select top 10 * from TIEHPIVMDB03.Ntier_627200.PM.Practice_Information


-------------------FROMS----------------------
--FROM PM.vwGenSvcInfo AS svc 
--INNER JOIN pm.vwGenVouchInfo vch ON svc.Tenant_ID = vch.Tenant_ID AND svc.voucher_id = vch.voucher_id 
--INNER JOIN PM.Procedure_Codes pr WITH (NOLOCK) ON svc.Procedure_Code = pr.Procedure_Code 
--LEFT OUTER JOIN pm.reporting_periods rp WITH (nolock) ON svc.Tenant_ID = rp.Tenant_ID AND svc.posting_date >= rp.start_date AND svc.posting_date <= isnull(rp.end_date, '2999-12-31') 
--LEFT JOIN PM.Practice_Information PRACTINFO ON PRACTINFO.Tenant_ID = svc.Tenant_ID
--WHERE  
--	(svc.Update_Status IN (1, 2, 3))

--FROM PM.vwGenSvcPmtInfo AS pmt 
--INNER JOIN pm.vwGenVouchInfo vch ON svc.Tenant_ID = vch.Tenant_ID AND svc.voucher_id = vch.voucher_id 
--INNER JOIN PM.vwGenSvcInfo svc ON pmt.Tenant_ID = svc.Tenant_ID AND pmt.Service_ID = svc.Service_ID 
--LEFT OUTER JOIN pm.reporting_periods rp WITH (nolock) ON pmt.Tenant_ID = rp.Tenant_ID AND pmt.posting_date >= rp.start_date AND pmt.posting_date <= isnull(rp.end_date, '2999-12-31') 
--LEFT JOIN PM.Practice_Information PRACTINFO ON PRACTINFO.Tenant_ID = pmt.Tenant_ID
--WHERE  
--	(pmt.Update_Status IN (1, 2, 3)) 
--	AND (pmt.Transaction_Type IN ('P', 'A', 'R', 'M'))

--FROM PM.vwGenSvcInfo AS svc 
--INNER JOIN pm.vwGenVouchInfo AS vch ON svc.Voucher_ID = vch.Voucher_ID 
--INNER JOIN PM.Procedure_Codes AS pr WITH (NOLOCK) ON svc.Tenant_ID = pr.Tenant_ID AND svc.Procedure_Code = pr.Procedure_Code 
--LEFT OUTER JOIN pm.reporting_periods rp WITH (nolock) ON vch.Tenant_ID = rp.Tenant_ID AND vch.date_voided >= rp.start_date AND vch.date_voided <= isnull(rp.end_date, '2999-12-31') 
--LEFT JOIN PM.Practice_Information PRACTINFO ON PRACTINFO.Tenant_ID = svc.Tenant_ID
--WHERE  
--	svc.Update_Status = 3

--FROM PM.vwGenSvcPmtInfo AS pmt 
--INNER JOIN PM.vwGenSvcInfo AS svc ON pmt.Tenant_ID = svc.Tenant_ID AND pmt.Service_ID = svc.Service_ID 
--INNER JOIN pm.vwGenVouchInfo AS vch ON svc.voucher_id = vch.voucher_id 
--LEFT OUTER JOIN pm.reporting_periods rp WITH (nolock) ON pmt.Tenant_ID = rp.Tenant_ID AND pmt.date_voided >= rp.start_date AND pmt.date_voided <= isnull(rp.end_date, '2999-12-31') 
--LEFT JOIN PM.Practice_Information PRACTINFO ON PRACTINFO.Tenant_ID = pmt.Tenant_ID
--WHERE  
--pmt.Update_Status = 3 
--AND pmt.Transaction_Type IN ('P', 'A', 'R', 'M')


-------------------ORIGINAL QUERY----------------------
--SELECT 
--	svc.Patient_ID, 
--	svc.Voucher_ID, 
--	svc.Voucher_Number, 
--	svc.service_id, 
--	'C' AS TransType, 
--	'Charge' AS TransCodeAbbr, 
--	'Charge' AS TransCodeDescr, 
--	1 AS Update_status, 
--	CONVERT(DATETIME, svc.Posting_Date, 101) AS Posting_Date, 
--	CONVERT(DATETIME, svc.Service_Date_From, 101) AS Service_Date_From, 
--	CONVERT(DATETIME, vch.voucher_service_date, 101) AS voucher_service_date, 
--	rp.abbreviation AS RptPd, 
--	CONVERT(DATETIME, rp.start_date, 101) AS RptPd_StartDt, 
--	CONVERT(DATETIME, isnull(rp.end_date, '2999-12-31'), 101) AS RptPd_EndDt, 
--	svc.Actual_Dr_Abbr, 
--	svc.Actual_Dr_Name, 
--	svc.actual_dr_lfi, 
--	svc.Billing_Dr_Abbr, 
--	svc.Billing_Dr_Name, 
--	svc.billing_dr_lfi, 
--	svc.refer_dr_abbr, 
--	svc.refer_dr_name, 
--	svc.refer_dr_lfi, 
--	svc.Billing_Carrier_ID AS CurrInsId, 
--	svc.Billing_Carrier_Abbr AS CurrInsAbbr, 
--	svc.Billing_Carrier_Name AS CurrInsName, 
--	svc.Original_Carrier_ID AS OrigInsId, 
--	svc.Original_Carrier_Abbr AS OrigInsAbbr, 
--	svc.Original_Carrier_Name AS OrigInsName, 
--	svc.Original_Carrier_ID AS TransInsID, 
--	svc.Original_Carrier_Abbr AS TransInsAbbr, 
--	svc.Original_Carrier_Name AS TransInsName, 
--	svc.Department_Abbr, 
--	svc.Department_Descr, 
--	svc.Location_Abbr, 
--	svc.Location_Descr, 
--	svc.Procedure_Code, 
--	svc.Procedure_Insurance_Descr, 
--	svc.proc_category_abbr AS PrCtgy_Abbr, 
--	svc.proc_category_descr AS PrCtgy_Desc, 
--	svc.Modifiers, 
--	svc.Primary_Diagnosis_Code, 
--	svc.Primary_Diagnosis_Descr, 
--	svc.Service_Units AS Units, 
--	isnull(pr.Work_RVUs, 0) AS work_rvu, 
--	isnull(pr.Practice_Expense_RVUs, 0) AS pract_rvu, 
--	isnull(pr.Malpractice_RVUs, 0) AS malpr_rvu, 
--	svc.Service_Fee AS Amount, 
--	svc.Service_Fee AS Charges, 
--	0 AS Payments, 
--	0 AS Adjustments, 
--	0 AS Refunds, 
--	0 AS Misc_Debits, 
--	svc.Primary_Diag_Code_Set, 
--	svc.Primary_Diag_Long_Descr, 
--	svc.Tenant_ID, 
--	PRACTINFO.Name AS Tenant_Name, 
--	NULL AS Service_PMT_ID
--FROM PM.vwGenSvcInfo AS svc 
--INNER JOIN pm.vwGenVouchInfo vch ON svc.Tenant_ID = vch.Tenant_ID AND svc.voucher_id = vch.voucher_id 
--INNER JOIN PM.Procedure_Codes pr WITH (NOLOCK) ON svc.Procedure_Code = pr.Procedure_Code 
--LEFT OUTER JOIN pm.reporting_periods rp WITH (nolock) ON svc.Tenant_ID = rp.Tenant_ID AND svc.posting_date >= rp.start_date AND svc.posting_date <= isnull(rp.end_date, '2999-12-31') 
--LEFT JOIN PM.Practice_Information PRACTINFO ON PRACTINFO.Tenant_ID = svc.Tenant_ID
--WHERE  
--	(svc.Update_Status IN (1, 2, 3))


--UNION ALL
--/*reversing charge entry*/ 
--SELECT 
	--svc.Patient_ID, 
	--svc.Voucher_ID, 
	--svc.Voucher_Number, 
	--svc.service_id, 
	--'C' AS TransType, 
	--'Charge' AS TransCodeAbbr, 
	--'Charge' AS TransCodeDescr, 
	--3 AS Update_status, 
	--vch.Date_Voided, 
	--svc.Service_Date_From, 
	--vch.voucher_service_date, 
	--rp.abbreviation AS RptPd, 
	--rp.start_date AS RptPd_StartDt, 
	--isnull(rp.end_date, '2999-12-31') AS RptPd_EndDt, 
	--svc.Actual_Dr_Abbr, 
	--svc.Actual_Dr_Name, 
	--svc.actual_dr_lfi, 
	--svc.Billing_Dr_Abbr, 
	--svc.Billing_Dr_Name, 
	--svc.billing_dr_lfi, 
	--svc.refer_dr_abbr, 
	--svc.refer_dr_name, 
	--svc.refer_dr_lfi, 
	--svc.Billing_Carrier_ID AS CurrInsId, 
	--svc.Billing_Carrier_Abbr AS CurrInsAbbr, 
	--svc.Billing_Carrier_Name AS CurrInsName, 
	--svc.Original_Carrier_ID AS OrigInsId, 
	--svc.Original_Carrier_Abbr AS OrigInsAbbr, 
	--svc.Original_Carrier_Name AS OrigInsName, 
	--svc.Original_Carrier_ID AS TransInsID, 
	--svc.Original_Carrier_Abbr AS TransInsAbbr, 
	--svc.Original_Carrier_Name AS TransInsName, 
	--svc.Department_Abbr, 
	--svc.Department_Descr, 
	--svc.Location_Abbr, 
	--svc.Location_Descr, 
	--svc.Procedure_Code, 
	--svc.Procedure_Insurance_Descr, 
	--svc.proc_category_abbr AS PrCtgy_Abbr, 
	--svc.proc_category_descr AS PrCtgy_Desc, 
	--svc.Modifiers, 
	--svc.Primary_Diagnosis_Code, 
	--svc.Primary_Diagnosis_Descr, 
	--svc.Service_Units * - 1 AS units, 
	--isnull(pr.Work_RVUs, 0) AS work_rvu, 
	--isnull(pr.Practice_Expense_RVUs, 0) AS pract_rvu, 
	--isnull(pr.Malpractice_RVUs, 0) AS malpr_rvu, 
	--svc.Service_Fee * - 1 AS amount, 
	--svc.Service_Fee * - 1 AS Charges, 
	--0 AS Payments, 
	--0 AS Adjustments, 
	--0 AS Refunds, 
	--0 AS [Misc_Debits], 
	--svc.Primary_Diag_Code_Set, 
	--svc.Primary_Diag_Long_Descr, 
	--svc.Tenant_ID, 
	--PRACTINFO.Name AS Tenant_Name, 
	--NULL AS Service_PMT_ID
--FROM PM.vwGenSvcInfo AS svc 
--INNER JOIN PM.Procedure_Codes AS pr WITH (NOLOCK) ON svc.Tenant_ID = pr.Tenant_ID AND svc.Procedure_Code = pr.Procedure_Code 
--INNER JOIN PM.vwGenVouchInfo AS vch ON svc.Voucher_ID = vch.Voucher_ID 
--LEFT OUTER JOIN pm.reporting_periods rp WITH (nolock) ON vch.Tenant_ID = rp.Tenant_ID AND vch.date_voided >= rp.start_date AND vch.date_voided <= isnull(rp.end_date, '2999-12-31') 
--LEFT JOIN PM.Practice_Information PRACTINFO ON PRACTINFO.Tenant_ID = svc.Tenant_ID
--WHERE  
--	svc.Update_Status = 3

--UNION ALL
--/*original payment entry.   Transfer is FROM carrier*/ 
--SELECT 
	--svc.Patient_ID, 
	--svc.Voucher_ID, 
	--svc.Voucher_Number, 
	--svc.service_id, 
	--pmt.Transaction_Type AS TransType, 
	--transaction_code_abbr, 
	--transaction_code_descr, 
	--1 AS Update_status, 
	--pmt.Posting_Date, 
	--svc.Service_Date_From, 
	--vch.voucher_service_date, 
	--rp.abbreviation AS RptPd, 
	--rp.start_date AS RptPd_StartDt, 
	--isnull(rp.end_date, '2999-12-31') AS RptPd_EndDt, 
	--svc.Actual_Dr_Abbr, 
	--svc.Actual_Dr_Name, 
	--svc.actual_dr_lfi, 
	--svc.Billing_Dr_Abbr, 
	--svc.Billing_Dr_Name, 
	--svc.billing_dr_lfi, 
	--svc.refer_dr_abbr, 
	--svc.refer_dr_name, 
	--svc.refer_dr_lfi, 
	--svc.Billing_Carrier_ID AS CurrInsId, 
	--svc.Billing_Carrier_Abbr AS CurrInsAbbr, 
	--svc.Billing_Carrier_Name AS CurrInsName, 
	--svc.Original_Carrier_ID AS OrigInsId, 
	--svc.Original_Carrier_Abbr AS OrigInsAbbr, 
	--svc.Original_Carrier_Name AS OrigInsName, 
	--pmt.Remitting_Carrier_ID AS TransInsID, 
	--pmt.Remitting_Carrier_Abbr AS TransInsAbbr, 
	--pmt.Remitting_Carrier_Name AS TransInsName, 
	--svc.Department_Abbr, 
	--svc.Department_Descr, 
	--svc.Location_Abbr, 
	--svc.Location_Descr, 
	--svc.Procedure_Code, 
	--svc.Procedure_Insurance_Descr, 
	--svc.proc_category_abbr AS PrCtgy_Abbr, 
	--svc.proc_category_descr AS PrCtgy_Desc, 
	--svc.Modifiers, 
	--svc.Primary_Diagnosis_Code, 
	--svc.Primary_Diagnosis_Descr, 
	--0 AS Units, 
	--0 AS WorkUnits, 
	--0 AS practice_expense_rvus, 
	--0 AS malpractice_rvus, 
	--pmt.Amount * - 1 AS amount, 
	--0 AS Charges, 
	--CASE WHEN (pmt.Transaction_Type = 'P') THEN (pmt.Amount * - 1) ELSE (0) END AS Payments, 
	--CASE WHEN (pmt.Transaction_Type = 'A') THEN (pmt.Amount * - 1) ELSE (0) END AS Adjustments, 
	--CASE WHEN (pmt.Transaction_Type = 'R') THEN (pmt.Amount * - 1) ELSE (0) END AS Refunds, 
	--CASE WHEN (pmt.Transaction_Type = 'M') THEN (pmt.Amount * - 1) ELSE (0) END AS Misc_Debits, 
	--svc.Primary_Diag_Code_Set, 
	--svc.Primary_Diag_Long_Descr, 
	--pmt.Tenant_ID, 
	--PRACTINFO.Name AS Tenant_Name, 
	--pmt.Service_Payment_ID
--FROM PM.vwGenSvcPmtInfo AS pmt 
--INNER JOIN PM.vwGenSvcInfo AS svc ON pmt.Tenant_ID = svc.Tenant_ID AND pmt.Service_ID = svc.Service_ID 
--INNER JOIN pm.vwGenVouchInfo AS vch ON svc.Tenant_ID = vch.Tenant_ID AND svc.voucher_id = vch.voucher_id 
--LEFT OUTER JOIN pm.reporting_periods rp WITH (nolock) ON pmt.Tenant_ID = rp.Tenant_ID AND pmt.posting_date >= rp.start_date AND pmt.posting_date <= isnull(rp.end_date, '2999-12-31') 
--LEFT JOIN PM.Practice_Information PRACTINFO ON PRACTINFO.Tenant_ID = pmt.Tenant_ID
--WHERE  
--	(pmt.Update_Status IN (1, 2, 3)) 
--	AND (pmt.Transaction_Type IN ('P', 'A', 'R', 'M'))
--UNION ALL
--/*reversing payment entry.   Transfer is FROM Carrier*/ 
--SELECT 
	--svc.Patient_ID, 
	--svc.Voucher_ID, 
	--svc.Voucher_Number, 
	--svc.service_id, 
	--pmt.Transaction_Type AS TransType, 
	--transaction_code_abbr, 
	--transaction_code_descr, 
	--3 AS Update_status, 
	--pmt.Date_Voided, 
	--svc.Service_Date_From, 
	--vch.voucher_service_date, 
	--rp.abbreviation AS RptPd, 
	--rp.start_date AS RptPd_StartDt, 
	--isnull(rp.end_date, '2999-12-31') AS RptPd_EndDt, 
	--svc.Actual_Dr_Abbr, 
	--svc.Actual_Dr_Name, 
	--svc.actual_dr_lfi, 
	--svc.Billing_Dr_Abbr, 
	--svc.Billing_Dr_Name, 
	--svc.billing_dr_lfi, 
	--svc.refer_dr_abbr, 
	--svc.refer_dr_name, 
	--svc.refer_dr_lfi, 
	--svc.Billing_Carrier_ID AS CurrInsId, 
	--svc.Billing_Carrier_Abbr AS CurrInsAbbr, 
	--svc.Billing_Carrier_Name AS CurrInsName, 
	--svc.Original_Carrier_ID AS OrigInsId, 
	--svc.Original_Carrier_Abbr AS OrigInsAbbr, 
	--svc.Original_Carrier_Name AS OrigInsName, 
	--pmt.Remitting_Carrier_ID AS TransInsID, 
	--pmt.Remitting_Carrier_Abbr AS TransInsAbbr, 
	--pmt.Remitting_Carrier_Name AS TransInsName, 
	--svc.Department_Abbr, 
	--svc.Department_Descr, 
	--svc.Location_Abbr, 
	--svc.Location_Descr, 
	--svc.Procedure_Code, 
	--svc.Procedure_Insurance_Descr, 
	--svc.proc_category_abbr AS PrCtgy_Abbr, 
	--svc.proc_category_descr AS PrCtgy_Desc, 
	--svc.Modifiers, 
	--svc.Primary_Diagnosis_Code, 
	--svc.Primary_Diagnosis_Descr, 
	--0 AS Units, 
	--0 AS WorkUnits, 
	--0 AS practice_expense_rvus, 
	--0 AS malpractice_rvus, 
	--pmt.Amount, 
	--0 AS Charges, 
	--CASE WHEN (pmt.Transaction_Type = 'P') THEN (pmt.Amount) ELSE (0) END AS Payments, 
	--CASE WHEN (pmt.Transaction_Type = 'A') THEN (pmt.Amount) ELSE (0) END AS Adjustments, 
	--CASE WHEN (pmt.Transaction_Type = 'R') THEN (pmt.Amount) ELSE (0) END AS Refunds, 
	--CASE WHEN (pmt.Transaction_Type = 'M') THEN (pmt.Amount) ELSE (0) END AS Misc_Debits, 
	--svc.Primary_Diag_Code_Set, 
	--svc.Primary_Diag_Long_Descr, 
	--pmt.Tenant_ID, 
	--PRACTINFO.Name AS Tenant_Name, 
	--pmt.Service_Payment_ID
--FROM PM.vwGenSvcPmtInfo AS pmt 
--INNER JOIN PM.vwGenSvcInfo AS svc ON pmt.Tenant_ID = svc.Tenant_ID AND pmt.Service_ID = svc.Service_ID 
--INNER JOIN pm.vwGenVouchInfo AS vch ON svc.voucher_id = vch.voucher_id 
--LEFT OUTER JOIN pm.reporting_periods rp WITH (nolock) ON pmt.Tenant_ID = rp.Tenant_ID AND pmt.date_voided >= rp.start_date AND pmt.date_voided <= isnull(rp.end_date, '2999-12-31') 
--LEFT JOIN PM.Practice_Information PRACTINFO ON PRACTINFO.Tenant_ID = pmt.Tenant_ID
--WHERE  
--pmt.Update_Status = 3 
--AND pmt.Transaction_Type IN ('P', 'A', 'R', 'M')
END
GO
