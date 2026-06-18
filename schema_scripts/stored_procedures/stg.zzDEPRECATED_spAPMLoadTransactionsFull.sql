-- =============================================
-- Author:		Ryan Tisserand
-- Create date: 08/19/2022
-- Description:	Extracts, Transforms and Loads Locations Data from APM Source System into a Staging Table
-- Change Control
--	1. 08/10/2022 - Initial build of procedure
-- =============================================
CREATE PROCEDURE [stg].[spAPMLoadTransactionsFull]
AS
BEGIN
SET NOCOUNT ON;
truncate table stg.Transactions
insert into stg.Transactions
select
	1 MasterDataSourceID,
	Patient_ID SourceTransactionPatientID,
	Voucher_ID SourceTransactionVisitID,
	Voucher_Number SourceTransactionVisitNumber,
	service_id SourceTransactionServiceID,
	--'1' + '~' + 
	--	cast(Patient_ID as varchar(50)) + '~' +
	--	cast(Voucher_ID as varchar(50)) + '~' +
	--	cast(Voucher_Number as varchar(50)) + '~' +
	--	cast(service_id as varchar(50))
	--SourceCompositeID,
	TransType SourceTransactionType,
	TransCodeAbbr SourceTransactionCodeAbbreviation,
	TransCodeDescr SourceTransactionCodeDescription,
	Update_status SourceTransactionUpdateStatus,
	Posting_Date SourceTransactionDateOfPosting,
	Service_Date_From SourceTransactionDateOfService,
	RptPd SourceTransactionReportingPeriod,
	RptPd_StartDt SourceTransactionDateOfReportPeriodStart,
	RptPd_EndDt SourceTransactionDateOfReportPeriodEnd,
	Actual_Dr_Abbr SourceTransactionAttendingPractitionerAbbreviation,
	Actual_Dr_Name SourceTransactionAttendingPractitionerName,
	Billing_Dr_Abbr SourceTransactionBillingPractitionerAbbreviation,
	Billing_Dr_Name SourceTransactionBillingPractitionerName,
	refer_dr_abbr SourceTransactionReferringPractitionerAbbreviation,
	refer_dr_name SourceTransactionReferringPractitionerName,
	CurrInsId SourceTransactionCurrentInsuranceID,
	CurrInsAbbr SourceTransactionCurrentInsuranceAbbreviation,
	CurrInsName SourceTransactionCurrentInsuranceName,
	OrigInsId SourceTransactionOriginalInsuranceID,
	OrigInsAbbr SourceTransactionOriginalInsuranceAbbreviation,
	OrigInsName SourceTransactionOriginalInsuranceName,
	TransInsID SourceTransactionTransactionInsuranceID,
	TransInsAbbr SourceTransactionTransactionInsuranceAbbreviation,
	TransInsName SourceTransactionTransactionInsuranceName,
	Department_Abbr SourceTransactionDepartmentAbbreviation,
	Department_Descr SourceTransactionDepartmentDescription,
	Location_Abbr SourceTransactionLocationAbbreviation,
	Location_Descr SourceTransactionLocationDescription,
	Procedure_Code SourceTransactionProcedureCode,
	Procedure_Insurance_Descr SourceTransactionProcedureInsuranceDescription,
	PrCtgy_Abbr SourceTransactionProcedureCategoryAbbreviation,
	PrCtgy_Desc SourceTransactionProcedureCategoryDescription,
	Modifiers SourceTransactionModifiers,
	Primary_Diagnosis_Code SourceTransactionPrimaryDiagnosisCode,
	Primary_Diagnosis_Descr SourceTransactionPrimaryDiagnosisDescription,
	Units SourceTransactionUnits,
	work_rvu SourceTransactionWorkRVU,
	pract_rvu SourceTransactionPracticeRVU,
	malpr_rvu SourceTransactionMalpracticeRVU,
	Amount SourceTransactionAmount,
	Charges SourceTransactionCharges,
	Payments SourceTransactionPayments,
	Adjustments SourceTransactionAdjustments,
	Refunds SourceTransactionRefunds,
	Misc_Debits SourceTransactionMiscellaneousDebits,
	Primary_Diag_Code_Set SourceTransactionPrimaryDiagnosisCodeSet
	--Primary_Diag_Long_Descr SourceTransactionPrimaryDiagnosisLongDescription
from tievmdb03.Ntier_627200.dbo.DG_vw_GenProdAnalysis
END
GO
