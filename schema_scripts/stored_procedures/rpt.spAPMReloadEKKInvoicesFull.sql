CREATE PROCEDURE rpt.spAPMReloadEKKInvoicesFull as
		
/* 
-- =============================================
-- Author:		Eric Silvestri
-- Create date: Mar 18 2026  1:56PM
-- Edit date:   
-- Description:	Full reload for rpt.EKKInvoices from APM
-- ============================================= 
*/
BEGIN

/*-----INSERT INTO @StagingTable-----*/
	PRINT 'Creating @StagingTable....'
	DECLARE @StagingTable table 
	(EKKInvoiceID varchar(100)
	,EKKInvoiceDatasourceID int
	,EKKInvoiceSourceID varchar(100)
	,EKKInvoiceDateOfService datetime
	,EKKInvoiceActualProvider varchar(100)
	,EKKInvoiceUpdateStatus varchar(100)
	,EKKInvoiceDepartment varchar(100)
	,EKKInvoiceProcedureDescription varchar(100)
	,EKKInvoiceProcedureModifier varchar(100)
	,EKKInvoiceModifier varchar(100)
	,EKKInvoiceProcedureCode varchar(100)
	,EKKInvoiceUnits varchar(100)
	,EKKInvoiceVoucherNumber varchar(100)
	,EKKInvoiceClaimNumber varchar(100)
	,EKKInvoiceServiceFee money
	,EKKInvoicePatientNumber varchar(100)
	,EKKInvoicePrimaryDiagCode varchar(100)
	,EKKInvoiceSecondDiagnosisCode varchar(100)
	,EKKInvoiceThirdDiagnosisCode varchar(100)
	,EKKInvoiceNDC varchar(100)
	,EKKInvoicePatientName varchar(100)
	,EKKInvoicePolicyNumber varchar(100)
	,EKKInvoicePolicyCertificate varchar(100)
	,EKKPayerName varchar(100)
	,EKKInvoiceAddress1 varchar(100)
	,EKKInvoiceAddress2 varchar(100)
	,EKKInvoiceCity varchar(100)
	,EKKInvoiceState varchar(100)
	,EKKInvoiceZip varchar(100)
	,EKKInvoiceIsActive bit
	,EKKInvoiceUpdateDatetime datetime
	)
	
	PRINT 'Inserting records from Datasource into @StagingTable....'
	INSERT INTO @StagingTable 
	(EKKInvoiceID
	,EKKInvoiceDatasourceID
	,EKKInvoiceSourceID
	,EKKInvoiceDateOfService
	,EKKInvoiceActualProvider
	,EKKInvoiceUpdateStatus
	,EKKInvoiceDepartment
	,EKKInvoiceProcedureDescription
	,EKKInvoiceProcedureModifier
	,EKKInvoiceModifier
	,EKKInvoiceProcedureCode
	,EKKInvoiceUnits
	,EKKInvoiceVoucherNumber
	,EKKInvoiceClaimNumber
	,EKKInvoiceServiceFee
	,EKKInvoicePatientNumber
	,EKKInvoicePrimaryDiagCode
	,EKKInvoiceSecondDiagnosisCode
	,EKKInvoiceThirdDiagnosisCode
	,EKKInvoiceNDC
	,EKKInvoicePatientName
	,EKKInvoicePolicyNumber
	,EKKInvoicePolicyCertificate
	,EKKPayerName
	,EKKInvoiceAddress1
	,EKKInvoiceAddress2
	,EKKInvoiceCity
	,EKKInvoiceState
	,EKKInvoiceZip
	,EKKInvoiceIsActive
	,EKKInvoiceUpdateDatetime
	)

	SELECT
	CONCAT('1~',gs.Service_ID) AS EKKInvoiceID
	,1 AS EKKInvoiceDataSourceID
	,gs.Service_ID AS EKKInvoiceSourceID
    ,gs.Service_Date_From as EKKInvoiceDateOfService
    ,gs.Actual_Dr_Name as EKKInvoiceActualProvider
    ,gs.Update_Status as EKKInvoiceUpdateStatus
    ,gs.Department_Abbr as EKKInvoiceDepartment
    ,gs.Procedure_Insurance_Descr as EKKInvoiceProcedureDescription
    ,CASE 
        WHEN gs.Modifiers IS NULL THEN gs.Procedure_Code 
        ELSE gs.Procedure_Code + '-' + gs.Modifiers  
    END as EKKInvoiceProcedureModifier
    ,gs.Modifiers as EKKInvoiceModifier
    ,gs.Procedure_Code as EKKInvoiceProcedureCode
    ,gs.Service_Units as EKKInvoiceUnits
    ,gs.Voucher_Number as EKKInvoiceVoucherNumber
	,gs.Claim_Number as EKKInvoiceClaimNumber
    ,gs.Service_Fee as EKKInvoiceServiceFee
    ,gs.Patient_Number as EKKInvoicePatientNumber
    ,gs.Primary_Diagnosis_Code as EKKInvoicePrimaryDiagCode
    ,MAX(CASE WHEN sd.Service_Diagnosis_Position = 2 AND gs.Update_Status = 1 THEN sd.Diagnosis_Code END) as EKKInvoiceSecondDiagnosisCode
    ,MAX(CASE WHEN sd.Service_Diagnosis_Position = 3 AND gs.Update_Status = 1 THEN sd.Diagnosis_Code END) as EKKInvoiceThirdDiagnosisCode
    ,ds.National_Drug_Code as EKKInvoiceNDC
    ,gp.Patient_Name as EKKInvoicePatientName
    ,gp.Prim_Policy_Certificate_No as EKKInvoicePolicyNumber
    ,gp.Prim_Policy_Certificate_Suffix as EKKInvoicePolicyCertificate
	,gs.Billing_Carrier_Name as EKKPayerName
    ,gp.Patient_Street1 as EKKInvoiceAddress1
    ,gp.Patient_Street2 as EKKInvoiceAddress2
    ,gp.Patient_City as EKKInvoiceCity
    ,gp.Patient_State as EKKInvoiceState
    ,gp.Patient_Zip_Code as EKKInvoiceZip
	,1 AS EKKInvoiceIsActive
	,GETDATE() AS EKKInvoiceUpdateDatetime
FROM tievmdb03.Ntier_627200.PM.vwGenSvcInfo gs
	LEFT JOIN tievmdb03.Ntier_627200.PM.vwGenPatInfo gp 
	    ON gp.Patient_ID = gs.Patient_ID 
	LEFT JOIN tievmdb03.Ntier_627200.PM.Drug_Services ds 
	    ON ds.Service_ID = gs.Service_ID
	LEFT JOIN tievmdb03.Ntier_627200.PM.vwGenSvcDiagInfo sd  
	    ON sd.Service_ID = gs.Service_ID
WHERE 1=1 AND gs.Department_Abbr IN ('FKVP', 'FKVPRXS') 
    AND gs.Update_Status = 1
    --AND gs.Patient_Number = '3527920'
GROUP BY
	gs.Service_ID,
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
ORDER BY 
	gs.Patient_Number
	,gs.Service_Date_From



IF (SELECT COUNT(1) FROM @StagingTable) >= 10 
	BEGIN 
	PRINT 'At least 10 records exist in the staging table.  Proceed with delete and reload...'

/*-----DELETE/DEACTIVATE old records----*/
	PRINT 'Deleting records in Datasource....'
	DELETE FROM rpt.EKKInvoices 

/*-----UPDATE existing records----*/
/*----------Commented out for INCREMENTAL reload based on modified date range----------
	PRINT 'Updating records in Datasource from @StagingTable....'
	UPDATE target
	SET target.EKKInvoiceID = source.EKKInvoiceID
	,target.EKKInvoiceDatasourceID = source.EKKInvoiceDatasourceID
	,target.EKKInvoiceSourceID = source.EKKInvoiceSourceID
	,target.EKKInvoiceDateOfService = source.EKKInvoiceDateOfService
	,target.EKKInvoiceActualProvider = source.EKKInvoiceActualProvider
	,target.EKKInvoiceUpdateStatus = source.EKKInvoiceUpdateStatus
	,target.EKKInvoiceDepartment = source.EKKInvoiceDepartment
	,target.EKKInvoiceProcedureDescription = source.EKKInvoiceProcedureDescription
	,target.EKKInvoiceProcedureModifier = source.EKKInvoiceProcedureModifier
	,target.EKKInvoiceModifier = source.EKKInvoiceModifier
	,target.EKKInvoiceProcedureCode = source.EKKInvoiceProcedureCode
	,target.EKKInvoiceUnits = source.EKKInvoiceUnits
	,target.EKKInvoiceVoucherNumber = source.EKKInvoiceVoucherNumber
	,target.EKKInvoiceClaimNumber = source.EKKInvoiceClaimNumber
	,target.EKKInvoiceServiceFee = source.EKKInvoiceServiceFee
	,target.EKKInvoicePatientNumber = source.EKKInvoicePatientNumber
	,target.EKKInvoicePrimaryDiagCode = source.EKKInvoicePrimaryDiagCode
	,target.EKKInvoiceSecondDiagnosisCode = source.EKKInvoiceSecondDiagnosisCode
	,target.EKKInvoiceThirdDiagnosisCode = source.EKKInvoiceThirdDiagnosisCode
	,target.EKKInvoiceNDC = source.EKKInvoiceNDC
	,target.EKKInvoicePatientName = source.EKKInvoicePatientName
	,target.EKKInvoicePolicyNumber = source.EKKInvoicePolicyNumber
	,target.EKKInvoicePolicyCertificate = source.EKKInvoicePolicyCertificate
	,target.EKKPayerName = source.EKKPayerName
	,target.EKKInvoiceAddress1 = source.EKKInvoiceAddress1
	,target.EKKInvoiceAddress2 = source.EKKInvoiceAddress2
	,target.EKKInvoiceCity = source.EKKInvoiceCity
	,target.EKKInvoiceState = source.EKKInvoiceState
	,target.EKKInvoiceZip = source.EKKInvoiceZip
	,target.EKKInvoiceIsActive = source.EKKInvoiceIsActive
	,target.EKKInvoiceUpdateDatetime = source.EKKInvoiceUpdateDatetime
	
	FROM rpt.EKKInvoices target
		INNER JOIN @StagingTable source ON source.EKKInvoiceID = target.EKKInvoiceID
*/

/*-----INSERT new records-----*/
	PRINT 'Inserting new records in Datasource from @StagingTable....'
	INSERT INTO rpt.EKKInvoices
	(EKKInvoiceID
	,EKKInvoiceDatasourceID
	,EKKInvoiceSourceID
	,EKKInvoiceDateOfService
	,EKKInvoiceActualProvider
	,EKKInvoiceUpdateStatus
	,EKKInvoiceDepartment
	,EKKInvoiceProcedureDescription
	,EKKInvoiceProcedureModifier
	,EKKInvoiceModifier
	,EKKInvoiceProcedureCode
	,EKKInvoiceUnits
	,EKKInvoiceVoucherNumber
	,EKKInvoiceClaimNumber
	,EKKInvoiceServiceFee
	,EKKInvoicePatientNumber
	,EKKInvoicePrimaryDiagCode
	,EKKInvoiceSecondDiagnosisCode
	,EKKInvoiceThirdDiagnosisCode
	,EKKInvoiceNDC
	,EKKInvoicePatientName
	,EKKInvoicePolicyNumber
	,EKKInvoicePolicyCertificate
	,EKKPayerName
	,EKKInvoiceAddress1
	,EKKInvoiceAddress2
	,EKKInvoiceCity
	,EKKInvoiceState
	,EKKInvoiceZip
	,EKKInvoiceIsActive
	,EKKInvoiceUpdateDatetime
	)

	SELECT
	source.EKKInvoiceID
	,source.EKKInvoiceDatasourceID
	,source.EKKInvoiceSourceID
	,source.EKKInvoiceDateOfService
	,source.EKKInvoiceActualProvider
	,source.EKKInvoiceUpdateStatus
	,source.EKKInvoiceDepartment
	,source.EKKInvoiceProcedureDescription
	,source.EKKInvoiceProcedureModifier
	,source.EKKInvoiceModifier
	,source.EKKInvoiceProcedureCode
	,source.EKKInvoiceUnits
	,source.EKKInvoiceVoucherNumber
	,source.EKKInvoiceClaimNumber
	,source.EKKInvoiceServiceFee
	,source.EKKInvoicePatientNumber
	,source.EKKInvoicePrimaryDiagCode
	,source.EKKInvoiceSecondDiagnosisCode
	,source.EKKInvoiceThirdDiagnosisCode
	,source.EKKInvoiceNDC
	,source.EKKInvoicePatientName
	,source.EKKInvoicePolicyNumber
	,source.EKKInvoicePolicyCertificate
	,source.EKKPayerName
	,source.EKKInvoiceAddress1
	,source.EKKInvoiceAddress2
	,source.EKKInvoiceCity
	,source.EKKInvoiceState
	,source.EKKInvoiceZip
	,source.EKKInvoiceIsActive
	,source.EKKInvoiceUpdateDatetime
	
	FROM @StagingTable source
	--	LEFT JOIN rpt.EKKInvoices target ON target.EKKInvoiceID = source.EKKInvoiceID
	WHERE 1=1
	--	AND target.EKKInvoiceID IS NULL 

	END

ELSE
	BEGIN
	PRINT 'Less than 10 records in the staging table. Ending job without delete and reload...'
	END

END
GO
