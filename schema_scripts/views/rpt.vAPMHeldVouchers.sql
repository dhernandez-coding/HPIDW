CREATE view [rpt].[vAPMHeldVouchers] as
SELECT        
	hv.Voucher_Number APMHeldVouchersVoucherNumber
	,hv.Service_Date APMHeldVouchersDateOfService
	,hv.Patient_Number APMHeldVouchersPatientNumber
	,hv.Patient_Last APMHeldVouchersPatientLastName
	,hv.Patient_First APMHeldVouchersPatientFirstName
	,hv.Held_Paper_Claim APMHeldVouchersHeldPaperClaim
	,hv.Held_Elec_Claim APMHeldVouchersHeldElecClaim
	,hv.Held_From_Statement APMHeldVouchersHeldFromStatement
	--,hv.Ins_Category_Abbreviation
	,hv.Held_Voucher_Reason_Abbr APMHeldVouchersReasonAbbr
	,gv.Voucher_Balance APMHeldVouchersBalance
	,hv.Chg_Amt APMHeldVouchersCharges
	--,hv.Ins_Rpt_Class_Description
	,hv.Carrier_Name APMHeldVouchersCarrierName
	,gv.Update_Status APMHeldVouchersUpdateStatus
	,gv.Posted_Payments APMHeldVouchersPayments
	,gv.Posted_Adjustments APMHeldVouchersAdjustments
	,gv.Fees APMHeldVouchersFees
	,gv.Billing_Dr_Name APMHeldVouchersBillingProvider
FROM  tievmdb03.Ntier_627200.PM.vwGenVouchInfo gv
	 INNER JOIN tievmdb03.Ntier_627200.PM.vwHeldVouchersList hv ON gv.Voucher_Number = hv.Voucher_Number
WHERE gv.Voucher_Balance <> 0 AND gv.Update_Status <> 3
GO
