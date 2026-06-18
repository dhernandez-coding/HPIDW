CREATE PROCEDURE [stg].[spEPICReloadFactClaimsFull] 
AS
/* 
-- =============================================
-- Author:		Eric Silvestri
-- Create date: Aug 22 2025 11:47AM
-- Edit date:   
-- Description:	Full reload for fact.Claims from HPI App
-- ============================================= 
*/
BEGIN

/*-----INSERT INTO @StagingTable-----*/
	PRINT 'Creating @StagingTable....'
	DECLARE @StagingTable table 
	(ClaimID varchar(50)
	,ClaimDataSourceID int
	,ClaimSourceID varchar(50)
	,ClaimAcceptanceDate datetime
	,ClaimDateOfService datetime
	,ClaimFromDate datetime
	,ClaimThroughDate datetime
	,ClaimPayorID varchar(50)
	,ClaimPlanID varchar(50)
	,ClaimCoverageID varchar(50)
	,ClaimDefinitionID varchar(50)
	,ClaimInvoiceNumber varchar(50)
	,ClaimPatientID varchar(50)
	,ClaimProviderID varchar(50)
	,ClaimAccountID varchar(50)
	,ClaimLiabilityBucketID varchar(50)
	,ClaimLocationID varchar(50)
	,ClaimDepartmentID varchar(50)
	,ClaimConditionCode varchar(50)
	,ClaimConditionCodeDescription varchar(100)
	,ClaimFormType varchar(50)
	,ClaimType varchar(50)
	,ClaimAccountType varchar(50)
	,ClaimClassType varchar(50)
	,ClaimTotalCharges money
	,ClaimTotalDue money
	,ClaimNonCoveredAmount money
	,ClaimTotalPayments money
	,ClaimTotalAdjustments money
	,ClaimBillType varchar(50)
	,ClaimUpdateDateTime datetime
	)
	
	PRINT 'Inserting records from Datasource into @StagingTable....'
	INSERT INTO @StagingTable 
	(ClaimID
	,ClaimDataSourceID
	,ClaimSourceID
	,ClaimAcceptanceDate
	,ClaimDateOfService
	,ClaimFromDate
	,ClaimThroughDate
	,ClaimPayorID
	,ClaimPlanID
	,ClaimCoverageID
	,ClaimDefinitionID
	,ClaimInvoiceNumber
	,ClaimPatientID
	,ClaimProviderID
	,ClaimAccountID
	,ClaimLiabilityBucketID
	,ClaimLocationID
	,ClaimDepartmentID
	,ClaimConditionCode
	,ClaimConditionCodeDescription
	,ClaimFormType
	,ClaimType
	,ClaimAccountType
	,ClaimClassType
	,ClaimTotalCharges
	,ClaimTotalDue
	,ClaimNonCoveredAmount
	,ClaimTotalPayments
	,ClaimTotalAdjustments
	,ClaimBillType
	,ClaimUpdateDateTime
	)

SELECT
	CONCAT('5~', c.CLAIM_PRINT_ID,'~',cc.CONDITION_CODE_C) AS ClaimID
	,5 AS ClaimDataSourceID
	,c.CLAIM_PRINT_ID AS ClaimSourceID
	,c.CLAIM_ACCEPT_DTTM AS ClaimAcceptanceDate
	,c.MIN_SERVICE_DT AS ClaimDateOfService
	,c.UB_FROM_DT AS ClaimFromDate
	,c.UB_THROUGH_DT AS ClaimThroughDate
	,CONCAT('5~', c.SG_PAYOR_ID) AS ClaimPayorID
	,CONCAT('5~', c.SG_PLAN_ID) AS ClaimPlanID
	,CONCAT('5~', SG_CVG_ID) AS ClaimCoverageID
	,SG_CDF_ID AS ClaimDefinitionID
	,c.INVOICE_NUM AS ClaimInvoiceNumber
	,CONCAT('5~', c.SG_PAT_ID) AS ClaimPatientID
	,CONCAT('5~', c.SG_PROV_ID) AS ClaimProviderID
	,CONCAT('5~', c.HOSPITAL_ACCT_ID) AS ClaimAccountID
	,c.HLB_ID AS ClaimLiabilityBucketID
	,CONCAT('5~', c.SG_LOC_ID) AS ClaimLocationID
	,CONCAT('5~', c.SG_DEP_ID) AS ClaimDepartmentID
	,cc.CONDITION_CODE_C AS ClaimConditionCode
	,zc.NAME AS ClaimConditionCodeDescription
	,ft.NAME AS ClaimFormType
	,ct.NAME AS ClaimType
	,a.NAME AS ClaimAccountType
	,p.NAME AS ClaimClassType
	,c.TTL_CHRGS_AMT AS ClaimTotalCharges
	,c.TTL_DUE_AMT AS ClaimTotalDue
	,c.TTL_NONCVD_AMT AS ClaimNonCoveredAmount
	,c.TTL_PMT_AMT AS ClaimTotalPayments
	,c.TTL_ADJ_AMT AS ClaimTotalAdjustments
	,c.UB_BILL_TYPE AS ClaimBillType
	,GETDATE() AS ClaimUpdateDateTime
FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].HSP_CLAIM_DETAIL2 c
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_CLAIM_FRM_TYPE ft on ft.CLAIM_FORM_C = c.CLAIM_FRM_TYPE_C
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_CLAIM_FORM_TYPE ct on ct.CLAIM_FORM_TYPE_C = c.CLAIM_TYPE_C
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_ACCT_BASECLS_HA a on a.ACCT_BASECLS_HA_C = c.CLAIM_BASE_CLASS_C
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_PAT_CLASS p on p.ADT_PAT_CLASS_C = c.CLAIM_CLASS_C
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].HSP_ACCT_COND_HAR cc on cc.ACCT_ID = c.HOSPITAL_ACCT_ID
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_COND_CODES_HA zc on zc.COND_CODES_HA_C = cc.CONDITION_CODE_C
WHERE 1=1
	AND c.SA_ID = 430


IF (SELECT COUNT(1) FROM @StagingTable) >= 10 
	BEGIN 
	PRINT 'At least 10 records exist in the staging table.  Proceed with delete and reload...'

/*-----DELETE/DEACTIVATE old records----*/
	PRINT 'Deleting records in Datasource....'
	DELETE FROM fact.Claims WHERE ClaimDataSourceID = 5

/*-----UPDATE existing records----*/
/*----------Commented out for INCREMENTAL reload based on modified date range----------
	PRINT 'Updating records in Datasource from @StagingTable....'
	UPDATE target
	SET target.ClaimID = source.ClaimID
	,target.ClaimDataSourceID = source.ClaimDataSourceID
	,target.ClaimSourceID = source.ClaimSourceID
	,target.ClaimAcceptanceDate = source.ClaimAcceptanceDate
	,target.ClaimDateOfService = source.ClaimDateOfService
	,target.ClaimFromDate = source.ClaimFromDate
	,target.ClaimThroughDate = source.ClaimThroughDate
	,target.ClaimPayorID = source.ClaimPayorID
	,target.ClaimPlanID = source.ClaimPlanID
	,target.ClaimCoverageID = source.ClaimCoverageID
	,target.ClaimDefinitionID = source.ClaimDefinitionID
	,target.ClaimInvoiceNumber = source.ClaimInvoiceNumber
	,target.ClaimPatientID = source.ClaimPatientID
	,target.ClaimProviderID = source.ClaimProviderID
	,target.ClaimAccountID = source.ClaimAccountID
	,target.ClaimLiabilityBucketID = source.ClaimLiabilityBucketID
	,target.ClaimLocationID = source.ClaimLocationID
	,target.ClaimDepartmentID = source.ClaimDepartmentID
	,target.ClaimFormType = source.ClaimFormType
	,target.ClaimType = source.ClaimType
	,target.ClaimAccountType = source.ClaimAccountType
	,target.ClaimClassType = source.ClaimClassType
	,target.ClaimTotalCharges = source.ClaimTotalCharges
	,target.ClaimTotalDue = source.ClaimTotalDue
	,target.ClaimNonCoveredAmount = source.ClaimNonCoveredAmount
	,target.ClaimTotalPayments = source.ClaimTotalPayments
	,target.ClaimTotalAdjustments = source.ClaimTotalAdjustments
	,target.ClaimBillType = source.ClaimBillType
	,target.ClaimUpdateDateTime = source.ClaimUpdateDateTime
	
	FROM fact.Claims target
		INNER JOIN @StagingTable source ON source.ClaimID = target.ClaimID
*/

/*-----INSERT new records-----*/
	PRINT 'Inserting new records in Datasource from @StagingTable....'
	INSERT INTO fact.Claims
	(ClaimID
	,ClaimDataSourceID
	,ClaimSourceID
	,ClaimAcceptanceDate
	,ClaimDateOfService
	,ClaimFromDate
	,ClaimThroughDate
	,ClaimPayorID
	,ClaimPlanID
	,ClaimCoverageID
	,ClaimDefinitionID
	,ClaimInvoiceNumber
	,ClaimPatientID
	,ClaimProviderID
	,ClaimAccountID
	,ClaimLiabilityBucketID
	,ClaimLocationID
	,ClaimDepartmentID
	,ClaimConditionCode
	,ClaimConditionCodeDescription
	,ClaimFormType
	,ClaimType
	,ClaimAccountType
	,ClaimClassType
	,ClaimTotalCharges
	,ClaimTotalDue
	,ClaimNonCoveredAmount
	,ClaimTotalPayments
	,ClaimTotalAdjustments
	,ClaimBillType
	,ClaimUpdateDateTime
	)

	SELECT
	source.ClaimID
	,source.ClaimDataSourceID
	,source.ClaimSourceID
	,source.ClaimAcceptanceDate
	,source.ClaimDateOfService
	,source.ClaimFromDate
	,source.ClaimThroughDate
	,source.ClaimPayorID
	,source.ClaimPlanID
	,source.ClaimCoverageID
	,source.ClaimDefinitionID
	,source.ClaimInvoiceNumber
	,source.ClaimPatientID
	,source.ClaimProviderID
	,source.ClaimAccountID
	,source.ClaimLiabilityBucketID
	,source.ClaimLocationID
	,source.ClaimDepartmentID
	,source.ClaimConditionCode
	,source.ClaimConditionCodeDescription
	,source.ClaimFormType
	,source.ClaimType
	,source.ClaimAccountType
	,source.ClaimClassType
	,source.ClaimTotalCharges
	,source.ClaimTotalDue
	,source.ClaimNonCoveredAmount
	,source.ClaimTotalPayments
	,source.ClaimTotalAdjustments
	,source.ClaimBillType
	,source.ClaimUpdateDateTime
	
	FROM @StagingTable source
	--	LEFT JOIN fact.Claims target ON target.ClaimID = source.ClaimID
	WHERE 1=1
	--	AND target.ClaimID IS NULL 

	END

ELSE
	BEGIN
	PRINT 'Less than 10 records in the staging table. Ending job without delete and reload...'
	END

END
GO
