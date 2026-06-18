-- =============================================
-- Author:		Ryan Tisserand
-- Create date: 08/12/2022
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE etl.APMChargesBuild
AS
BEGIN
SET NOCOUNT ON;
--PM.vwGenSvcInfo

-----------COUNTS-----------
--declare @Counts table(TableName varchar(50), Records int)
--insert into @Counts select 'Vourchers',count(1) from tiehpivmdb03.Ntier_627200.PM.Vouchers
--insert into @Counts select 'Patients',count(1) from tiehpivmdb03.Ntier_627200.PM.Patients
--insert into @Counts select 'Practitioners',count(1) from tiehpivmdb03.Ntier_627200.PM.Practitioners
--insert into @Counts select 'Services',count(1) from tiehpivmdb03.Ntier_627200.PM.[Services]
--insert into @Counts select 'Diagnosis Codes',count(1) from tiehpivmdb03.Ntier_627200.PM.Diagnosis_Codes
--insert into @Counts select 'Diagnosis Categories',count(1) from tiehpivmdb03.Ntier_627200.PM.Diagnosis_Categories
--insert into @Counts select 'Carriers',count(1) from tiehpivmdb03.Ntier_627200.PM.Carriers
--insert into @Counts select 'Insurance Categories',count(1) from tiehpivmdb03.Ntier_627200.PM.Insurance_Categories
--insert into @Counts select 'Locations',count(1) from tiehpivmdb03.Ntier_627200.PM.Locations
--insert into @Counts select 'Departments',count(1) from tiehpivmdb03.Ntier_627200.PM.Departments
--insert into @Counts select 'Places Of Service',count(1) from tiehpivmdb03.Ntier_627200.PM.Places_Of_Service
--insert into @Counts select 'Types Of Service',count(1) from tiehpivmdb03.Ntier_627200.PM.Types_Of_Service
--insert into @Counts select 'Accounts',count(1) from tiehpivmdb03.Ntier_627200.PM.Accounts
--insert into @Counts select 'Procedure Codes',count(1) from tiehpivmdb03.Ntier_627200.PM.Procedure_Codes
--insert into @Counts select 'Procedure Categories',count(1) from tiehpivmdb03.Ntier_627200.PM.Procedure_Categories
--insert into @Counts select 'Practice Information',count(1) from tiehpivmdb03.Ntier_627200.PM.Practice_Information
--select * from @Counts

-----------Top 10 Records-----------
--select top 10 * from tiehpivmdb03.Ntier_627200.PM.Vouchers
--select top 10 * from tiehpivmdb03.Ntier_627200.PM.Patients
--select top 10 * from tiehpivmdb03.Ntier_627200.PM.Practitioners
--select top 10 * from tiehpivmdb03.Ntier_627200.PM.[Services]
--select top 10 * from tiehpivmdb03.Ntier_627200.PM.Diagnosis_Codes
--select top 10 * from tiehpivmdb03.Ntier_627200.PM.Diagnosis_Categories
--select top 10 * from tiehpivmdb03.Ntier_627200.PM.Carriers
--select top 10 * from tiehpivmdb03.Ntier_627200.PM.Insurance_Categories
--select top 10 * from tiehpivmdb03.Ntier_627200.PM.Locations
--select top 10 * from tiehpivmdb03.Ntier_627200.PM.Departments
--select top 10 * from tiehpivmdb03.Ntier_627200.PM.Places_Of_Service
--select top 10 * from tiehpivmdb03.Ntier_627200.PM.Types_Of_Service
--select top 10 * from tiehpivmdb03.Ntier_627200.PM.Accounts
--select top 10 * from tiehpivmdb03.Ntier_627200.PM.Procedure_Codes
--select top 10 * from tiehpivmdb03.Ntier_627200.PM.Procedure_Categories
--select top 10 * from tiehpivmdb03.Ntier_627200.PM.Practice_Information

--SELECT 
--	SVC.Service_ID, 
--	CONVERT(DATETIME, SVC.Date_From, 101) AS Service_Date_From, 
--	CONVERT(DATETIME, SVC.Date_Through, 101) AS Service_Date_To, 
--	VOUCH.Voucher_ID, VOUCH.Voucher_Number, VOUCH.Update_Status, 
--	VOUCH.Claim_Number, VOUCH.Original_Voucher_Number AS Orig_Voucher_Number, 
--	VOUCH.Hold_Paper_Claim, VOUCH.Hold_Electronic_Claim, VOUCH.Hold_From_Statement, 
--	CONVERT(DATETIME, VOUCH.Date_Updated, 101) AS Posting_Date, 
--	CONVERT(DATETIME, VOUCH.Billing_Date, 101) AS Billing_Date, 
--	CONVERT(DATETIME, VOUCH.Original_Billing_Date, 101) AS Original_Billing_Date, 
--	PAT.Patient_ID, PAT.Patient_Number, 
--	ACCT.Account_ID, 
--	ACCT.Account_Number, 
--	BILLINGCARR.Carrier_ID AS Billing_Carrier_ID, 
--	BILLINGCARR.Abbreviation AS Billing_Carrier_Abbr, 
--	BILLINGCARR.Name AS Billing_Carrier_Name, 
--	BILLINGCARRCAT.Abbreviation AS Billing_Carrier_Category_Abbr, 
--	BILLINGCARRCAT.Description AS Billing_Carrier_Category_Descr, 
--	ORIGCARR.Carrier_ID AS Original_Carrier_ID, 
--	ORIGCARR.Abbreviation AS Original_Carrier_Abbr, 
--	ORIGCARR.Name AS Original_Carrier_Name, 
--	ORIGCARRCAT.Abbreviation AS Original_Carrier_Category_Abbr, 
--	ORIGCARRCAT.Description AS Original_Carrier_Category_Descr, 
--	ACTPRACT.Practitioner_ID AS Actual_Dr_ID, 
--	ACTPRACT.Abbreviation AS Actual_Dr_Abbr, 
--	REPLACE(REPLACE(LTRIM(RTRIM(ISNULL(ACTPRACT.First_Name, '') + ' ' + ISNULL(ACTPRACT.Middle_Initial, '') + ' ' + ACTPRACT.Last_Name + ' ' + ISNULL(ACTPRACT.Suffix, ''))), SPACE(2), SPACE(1)), SPACE(2), SPACE(1)) AS Actual_Dr_Name, 
--	RTRIM(REPLACE(REPLACE(ACTPRACT.Last_Name + ', ' + ISNULL(ACTPRACT.First_Name, '') + ' ' + ISNULL(ACTPRACT.Middle_Initial, ''), CHAR(44) + SPACE(2), ''), SPACE(2), SPACE(1))) AS Actual_Dr_LFI, 
--	ACTPRACT.First_Name AS Actual_Dr_First_Name, 
--	ACTPRACT.Middle_Initial AS Actual_Dr_MI, 
--	ACTPRACT.Last_Name AS Actual_Dr_Last_Name, 
--	ACTPRACT.Suffix AS Actual_Dr_Suffix, 
--	ACTPRACT.Street1 AS Actual_Dr_Street1, 
--	ACTPRACT.Street2 AS Actual_Dr_Street2, 
--	ACTPRACT.City AS Actual_Dr_City, 
--	ACTPRACT.State AS Actual_Dr_State, 
--	ACTPRACT.Country_Code AS Actual_Dr_Country, 
--	ACTPRACT.Zip_Code AS Actual_Dr_Zip_Code, 
--	CONVERT(DATETIME, ACTPRACT.Inactivation_Date, 101) AS Actual_Dr_Inactivation_Date, 
--	BILLPRACT.Practitioner_ID AS Billing_Dr_ID, 
--	BILLPRACT.Abbreviation AS Billing_Dr_Abbr, 
--	REPLACE(REPLACE(LTRIM(RTRIM(ISNULL(BILLPRACT.First_Name, '') + ' ' + ISNULL(BILLPRACT.Middle_Initial, '') + ' ' + BILLPRACT.Last_Name + ' ' + ISNULL(BILLPRACT.Suffix, ''))), SPACE(2), SPACE(1)), SPACE(2), SPACE(1)) AS Billing_Dr_Name, 
--	RTRIM(REPLACE(REPLACE(BILLPRACT.Last_Name + ', ' + ISNULL(BILLPRACT.First_Name, '') + ' ' + ISNULL(BILLPRACT.Middle_Initial, ''), CHAR(44) + SPACE(2), ''), SPACE(2), SPACE(1))) AS Billing_Dr_LFI, 
--	BILLPRACT.First_Name AS Billing_Dr_First_Name, 
--	BILLPRACT.Middle_Initial AS Billing_Dr_MI, 
--	BILLPRACT.Last_Name AS Billing_Dr_Last_Name, 
--	BILLPRACT.Suffix AS Billing_Dr_Suffix, 
--	BILLPRACT.Street1 AS Billing_Dr_Street1, 
--	BILLPRACT.Street2 AS Billing_Dr_Street2, 
--	BILLPRACT.City AS Billing_Dr_City, 
--	BILLPRACT.State AS Billing_Dr_State, 
--	BILLPRACT.Country_Code AS Billing_Dr_Country, 
--	BILLPRACT.Zip_Code AS Billing_Dr_Zip_Code, 
--	CONVERT(DATETIME, BILLPRACT.Inactivation_Date, 101) AS Billing_Dr_Inactivation_Date, 
--	DEPT.Abbreviation AS Department_Abbr, 
--	DEPT.Description AS Department_Descr, 
--	POS.Abbreviation AS Place_of_Service_Abbr, 
--	POS.Description AS Place_of_Service_Descr, 
--	LOC.Abbreviation AS Location_Abbr, 
--	LOC.Description AS Location_Descr, 
--	REFDR.Practitioner_ID AS Refer_Dr_ID, REFDR.Abbreviation AS Refer_Dr_Abbr, 
--	REPLACE(REPLACE(LTRIM(RTRIM(ISNULL(REFDR.First_Name, '') + ' ' + ISNULL(REFDR.Middle_Initial, '') + ' ' + REFDR.Last_Name + ' ' + ISNULL(REFDR.Suffix, ''))), SPACE(2), SPACE(1)), SPACE(2), SPACE(1)) AS Refer_Dr_Name, 
--	RTRIM(REPLACE(REPLACE(REFDR.Last_Name + ', ' + ISNULL(REFDR.First_Name, '') + ' ' + ISNULL(REFDR.Middle_Initial, ''), CHAR(44) + SPACE(2), ''), SPACE(2), SPACE(1))) AS Refer_Dr_LFI, REFDR.First_Name AS Refer_Dr_First_Name, 
--	REFDR.Middle_Initial AS Refer_Dr_MI, 
--	REFDR.Last_Name AS Refer_Dr_Last_Name, 
--	REFDR.Suffix AS Refer_Dr_Suffix, 
--	REFDR.Street1 AS Refer_Dr_Street1, 
--	REFDR.Street2 AS Refer_Dr_Street2, 
--	REFDR.City AS Refer_Dr_City, 
--	REFDR.State AS Refer_Dr_State, 
--	REFDR.Country_Code AS Refer_Dr_Country, 
--	REFDR.Zip_Code AS Refer_Dr_Zip_Code, 
--	PROCCODE.Procedure_Code, SVC.Modifiers, 
--	PROCCODE.Insurance_Description AS Procedure_Insurance_Descr, 
--	PROCCODE.Cost AS Procedure_Cost, 
--	PROCCODE.Item_Number AS Procedure_Item_Number, 
--	PROCCODE.Item_Description AS Procedure_Item_Description, 
--	SVC.Units AS Service_Units, 
--	SVC.Fee AS Service_Fee, 
--	PROCCAT.Abbreviation AS Proc_Category_Abbr, 
--	PROCCAT.Description AS Proc_Category_Descr, 
--	DIAGCODE.Diagnosis_Code AS Primary_Diagnosis_Code, 
--	DIAGCODE.Description AS Primary_Diagnosis_Descr, 
--	DIAGCAT.Abbreviation AS Primary_Diag_Category_Abbr, 
--	DIAGCAT.Description AS Primary_Diag_Category_Descr, 
--	TOS.Abbreviation AS Type_of_Service_Abbr, 
--	TOS.Description AS Type_of_Service_Descr, 
--	DEPT.Abbreviation AS Practice_Abbr, 
--	DEPT.Description AS Practice_Descr, 
--	DIAGCODE.Code_Set AS Primary_Diag_Code_Set, 
--	DIAGCODE.Long_Description AS Primary_Diag_Long_Descr, 
--	VOUCH.Tenant_ID, 
--	PRACTINFO.Name AS Tenant_Name, 
--	VOUCH.Visit_Type_ID
--FROM tiehpivmdb03.Ntier_627200.PM.Vouchers AS VOUCH WITH (NOLOCK) 
--INNER JOIN tiehpivmdb03.Ntier_627200.PM.Patients AS PAT WITH (NOLOCK) ON PAT.Tenant_ID = VOUCH.Tenant_ID AND PAT.Patient_ID = VOUCH.Patient_ID 
--INNER JOIN tiehpivmdb03.Ntier_627200.PM.Practitioners AS BILLPRACT WITH (NOLOCK) ON BILLPRACT.Practitioner_ID = VOUCH.Billing_Prov_Practitioner_ID 
--LEFT OUTER JOIN tiehpivmdb03.Ntier_627200.PM.Practitioners AS REFDR WITH (NOLOCK) ON REFDR.Tenant_ID = VOUCH.Tenant_ID AND REFDR.Practitioner_ID = VOUCH.Ref_Practitioner_ID 
--INNER JOIN tiehpivmdb03.Ntier_627200.PM.Practitioners AS ACTPRACT WITH (NOLOCK) ON ACTPRACT.Practitioner_ID = VOUCH.Actual_Prov_Practitioner_ID 
--INNER JOIN tiehpivmdb03.Ntier_627200.PM.Services AS SVC WITH (NOLOCK) ON SVC.Voucher_ID = VOUCH.Voucher_ID 
--LEFT OUTER JOIN tiehpivmdb03.Ntier_627200.PM.Diagnosis_Codes AS DIAGCODE WITH (NOLOCK) ON DIAGCODE.Diagnosis_Code_ID =
--(
--	SELECT 
--		MIN(Service_Diagnosis_ID)
--    FROM tiehpivmdb03.Ntier_627200.PM.Service_Diagnoses WITH (NOLOCK)
--    WHERE 
--		Tenant_ID = SVC.Tenant_ID AND Service_ID = SVC.Service_ID
--)
--LEFT OUTER JOIN tiehpivmdb03.Ntier_627200.PM.Diagnosis_Categories AS DIAGCAT WITH (NOLOCK) ON DIAGCAT.Tenant_ID = DIAGCODE.Tenant_ID AND DIAGCAT.Diagnosis_Category_ID = DIAGCODE.Diagnosis_Category_ID 
--LEFT OUTER JOIN tiehpivmdb03.Ntier_627200.PM.Carriers AS BILLINGCARR WITH (NOLOCK) ON BILLINGCARR.Tenant_ID = VOUCH.Tenant_ID AND BILLINGCARR.Carrier_ID = VOUCH.Carrier_ID 
--LEFT OUTER JOIN tiehpivmdb03.Ntier_627200.PM.Insurance_Categories AS BILLINGCARRCAT WITH (NOLOCK) ON BILLINGCARRCAT.Tenant_ID = BILLINGCARR.Tenant_ID AND BILLINGCARRCAT.Insurance_Category_ID = BILLINGCARR.Insurance_Category_ID 
--LEFT OUTER JOIN tiehpivmdb03.Ntier_627200.PM.Carriers AS ORIGCARR WITH (NOLOCK) ON ORIGCARR.Tenant_ID = VOUCH.Tenant_ID AND ORIGCARR.Carrier_ID = VOUCH.Original_Carrier_ID 
--LEFT OUTER JOIN tiehpivmdb03.Ntier_627200.PM.Insurance_Categories AS ORIGCARRCAT WITH (NOLOCK) ON ORIGCARRCAT.Tenant_ID = ORIGCARR.Tenant_ID AND ORIGCARRCAT.Insurance_Category_ID = ORIGCARR.Insurance_Category_ID 
--INNER JOIN tiehpivmdb03.Ntier_627200.PM.Locations AS LOC WITH (NOLOCK) ON LOC.Location_ID = VOUCH.Location_ID 
--INNER JOIN tiehpivmdb03.Ntier_627200.PM.Departments AS DEPT WITH (NOLOCK) ON DEPT.Department_ID = VOUCH.Department_ID 
--INNER JOIN tiehpivmdb03.Ntier_627200.PM.Places_Of_Service AS POS WITH (NOLOCK) ON POS.Place_Of_Service_ID = VOUCH.Place_Of_Service_ID 
--INNER JOIN tiehpivmdb03.Ntier_627200.PM.Types_Of_Service AS TOS WITH (NOLOCK) ON TOS.Type_Of_Service_ID = SVC.Type_Of_Service_ID 
--INNER JOIN tiehpivmdb03.Ntier_627200.PM.Accounts AS ACCT WITH (NOLOCK) ON ACCT.Account_ID = PAT.Account_ID 
--INNER JOIN tiehpivmdb03.Ntier_627200.PM.Procedure_Codes AS PROCCODE WITH (NOLOCK) ON PROCCODE.Procedure_Code_ID = SVC.Procedure_Code_ID 
--INNER JOIN tiehpivmdb03.Ntier_627200.PM.Procedure_Categories AS PROCCAT WITH (NOLOCK) ON PROCCAT.Procedure_Category_ID = PROCCODE.Procedure_Category_ID 
--LEFT OUTER JOIN tiehpivmdb03.Ntier_627200.PM.Practice_Information AS PRACTINFO ON PRACTINFO.Tenant_ID = VOUCH.Tenant_ID

--vwGenSvcPmtInfo
--SELECT 
--	SVCPMT.Service_Payment_ID, 
--	SVCPMT.Amount, 
--	SVCPMT.Service_ID, 
--	SVCPMT.Payment_ID, 
--	CONVERT(DATETIME, PMT.Date_Paid, 101) AS Date_Paid, 
--	PMT.Reference, 
--	PMT.Transaction_Type, 
--	TRANCODE.Abbreviation AS Transaction_Code_Abbr, 
--	TRANCODE.Description AS Transaction_Code_Descr, 
--	CONVERT(DATETIME, CONVERT(varchar(12), PMT.DateTime_Entered, 101)) AS Date_Entered, 
--	CONVERT(DATETIME, PMT.Date_Voided, 101) AS Date_Voided, 
--	PMT.Update_Status, 
--	CONVERT(DATETIME, PMT.Date_Updated, 101) AS Posting_Date, 
--	RPTPER.Abbreviation AS Payment_Reporting_Period, 
--	PMT.Remitting_Carrier_ID, 
--	REMITCARR.Abbreviation AS Remitting_Carrier_Abbr, 
--	REMITCARR.Name AS Remitting_Carrier_Name, 
--	PMT.Current_Carrier_ID, 
--	CURRCARR.Abbreviation AS Current_Carrier_Abbr, 
--	CURRCARR.Name AS Current_Carrier_Name, 
--	STMTMSG.Access_Description AS Statement_Message_Descr, 
--	CLAIMMSG.Access_Description AS Claim_Message_Descr, 
--	PMT.Trsf_To_Carrier_ID AS Transfer_To_Carrier_ID, 
--	TRANCARR.Abbreviation AS Transfer_To_Carrier_Abbr, 
--	TRANCARR.Name AS Transfer_To_Carrier_Name, BAT.Batch_Number, 
--	ISNULL(BATCAT.Abbreviation, 'none') AS Batch_Category_Abbr, 
--	ISNULL(BATCAT.Description, 'No Batch Category') AS Batch_Category_Descr, 
--	OP.Abbreviation AS Operator_Abbr, 
--	REIMBDET.Reimbursement_Detail_ID, 
--	REIMBDET.Allowed, REIMBDET.Deductible, 
--	REIMBDET.CoPayment, REIMBDET.CoInsurance, 
--	CONVERT(DATETIME, REIMBDET.EOB_Date, 101) AS EOB_Date, 
--	REIMBCOMM.Abbreviation AS Reimbursement_Comment_Abbr, 
--	REIMBCOMM.Description AS Reimbursement_Comment_Descr, 
--	REIMBDET.Pending, 
--	PMT.CC_Trans_ID, 
--	PMT.CC_Void_Trans_ID, 
--	PMT.CC_Auth_No, 
--	TZI.Abbreviation AS TimeZone_Abbreviation, 
--	SVCPMT.Tenant_ID, 
--	PRACTINFO.Name AS Tenant_Name
--FROM PM.Service_Payments AS SVCPMT WITH (NOLOCK) 
--INNER JOIN PM.Payments AS PMT WITH (NOLOCK) ON PMT.Tenant_ID = SVCPMT.Tenant_ID AND PMT.Payment_ID = SVCPMT.Payment_ID 
--INNER JOIN PM.Vouchers AS VOUCH WITH (NOLOCK) ON VOUCH.Voucher_ID = PMT.Voucher_ID 
--INNER JOIN PM.Services AS SVC WITH (NOLOCK) ON SVC.Service_ID = SVCPMT.Service_ID 
--LEFT OUTER JOIN PM.Carriers AS REMITCARR WITH (NOLOCK) ON REMITCARR.Tenant_ID = PMT.Tenant_ID AND REMITCARR.Carrier_ID = PMT.Remitting_Carrier_ID 
--LEFT OUTER JOIN PM.Carriers AS CURRCARR WITH (NOLOCK) ON CURRCARR.Tenant_ID = PMT.Tenant_ID AND CURRCARR.Carrier_ID = PMT.Current_Carrier_ID 
--LEFT OUTER JOIN PM.Carriers AS TRANCARR WITH (NOLOCK) ON TRANCARR.Tenant_ID = PMT.Tenant_ID AND TRANCARR.Carrier_ID = PMT.Trsf_To_Carrier_ID 
--LEFT OUTER JOIN PM.Transaction_Codes AS TRANCODE WITH (NOLOCK) ON TRANCODE.Tenant_ID = PMT.Tenant_ID AND TRANCODE.Transaction_Code_ID = PMT.Transaction_Code_ID 
--LEFT OUTER JOIN PM.Messages AS STMTMSG WITH (NOLOCK) ON STMTMSG.Tenant_ID = PMT.Tenant_ID AND STMTMSG.Message_ID = PMT.Statement_Message_ID 
--LEFT OUTER JOIN PM.Messages AS CLAIMMSG WITH (NOLOCK) ON CLAIMMSG.Tenant_ID = PMT.Tenant_ID AND CLAIMMSG.Message_ID = PMT.Claim_Message_ID 
--LEFT OUTER JOIN PM.Batches AS BAT WITH (NOLOCK) ON BAT.Tenant_ID = PMT.Tenant_ID AND BAT.Batch_ID = PMT.Batch_ID 
--LEFT OUTER JOIN PM.Batch_Categories AS BATCAT WITH (NOLOCK) ON BATCAT.Tenant_ID = BAT.Tenant_ID AND BATCAT.Batch_Category_ID = BAT.Batch_Category_ID 
--LEFT OUTER JOIN PM.Operators AS OP WITH (NOLOCK) ON OP.Tenant_ID = PMT.Tenant_ID AND OP.Operator_ID = PMT.Operator_ID 
--LEFT OUTER JOIN PM.Reimbursement_Detail AS REIMBDET WITH (NOLOCK) ON REIMBDET.Tenant_ID = SVC.Tenant_ID AND REIMBDET.Service_ID = SVC.Service_ID 
--LEFT OUTER JOIN PM.Reimbursement_Comments AS REIMBCOMM WITH (NOLOCK) ON REIMBCOMM.Tenant_ID = REIMBDET.Tenant_ID AND REIMBCOMM.Reimbursement_Comment_ID = REIMBDET.Reimbursement_Comment_ID 
--LEFT OUTER JOIN PM.Reporting_Periods AS RPTPER WITH (NOLOCK) ON RPTPER.Tenant_ID = PMT.Tenant_ID AND RPTPER.Start_Date <= PMT.Date_Updated AND COALESCE (RPTPER.End_Date, '12/31/9999') >= PMT.Date_Updated 
--LEFT OUTER JOIN HIE_PM.IB_TimeZone_Info AS TZI ON TZI.IB_TimeZone_Info_ID = PMT.TimeZone_Info_ID 
--LEFT OUTER JOIN PM.Practice_Information AS PRACTINFO ON PRACTINFO.Tenant_ID = VOUCH.Tenant_ID
END
GO
