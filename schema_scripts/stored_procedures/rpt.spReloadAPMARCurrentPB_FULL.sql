CREATE PROCEDURE [rpt].[spReloadAPMARCurrentPB_FULL] as
		
/* 
-- =============================================
-- Author:		Chris Cross
-- Create date: May 24 2024  3:30PM
-- Edit date:   
-- Description:	full reload for rpt.ARCurrentPB from APM
-- ============================================= 
*/
BEGIN

/*-----INSERT INTO @StagingTable-----*/
	PRINT 'Creating @StagingTable....'
	DECLARE @StagingTable table						
	(ARHistoryID varchar(100)
	,ARHistoryDate date
	,TransactionDataSourceID int
	,TransactionSourceID varchar(50)
	,TransactionType varchar(50)
	,TransactionLocationID varchar(50)
	,TransactionDepartmentID varchar(50)
	,TransactionPlaceOfServiceID varchar(50)
	,TransactionPlaceOfServiceType varchar(50)
	,TransactionGuarantorID varchar(50)
	,TransactionGuarantorType varchar(50)
	,TransactionAccountID varchar(50)
	,TransactionAccountClass varchar(50)
	,TransactionVisitID varchar(50)
	,TransactionVisitType varchar(50)
	,CurrentFinancialClass varchar(50)
	,CurrentPayerID varchar(50)
	,CurrentPayerPlanID varchar(50)
	,OriginalFinancialClass varchar(50)
	,OriginalPayerID varchar(50)
	,OriginalPayerPlanID varchar(50)
	,TransactionServiceProviderID varchar(50)
	,TransactionBillingProviderID varchar(50)
	,TransactionCode varchar(50)
	,TransactionDescription varchar(300)
	,TransactionCPTCode varchar(30)
	,TransactionModifier1 varchar(30)
	,TransactionModifier2 varchar(30)
	,TransactionModifier3 varchar(30)
	,TransactionModifier4 varchar(30)
	,TransactionUnits decimal
	,TransactionLedgerType varchar(30)
	,TransactionOriginalAmount money
	,TransactionARAmountAll money
	,TransactionARAmountSelfPay money
	,TransactionARAmountInsurance money
	,TransactionARAmountActive money
	,TransactionARAmountBadDebt money
	,TransactionServiceDate date
	,TransactionServiceDateAge int
	,TransactionPostDate date
	,TransactionPostDateAge int
	,TransactionInsuranceAgeDate date
	,TransactionInsuranceAge int
	,TransactionFirstClaimDate date
	,TransactionLastClaimDate date
	,TransactionSelfPayAgeDate date
	,TransactionSelfPayAge int
	,ARHistoryUpdatedDatetime datetime
	)
	
	PRINT 'Inserting records from Datasource into @StagingTable....'
	INSERT INTO @StagingTable 
	(ARHistoryID
	,ARHistoryDate
	,TransactionDataSourceID
	,TransactionSourceID
	,TransactionType
	,TransactionLocationID
	,TransactionDepartmentID
	,TransactionPlaceOfServiceID
	,TransactionPlaceOfServiceType
	,TransactionGuarantorID
	,TransactionGuarantorType
	,TransactionAccountID
	,TransactionAccountClass
	,TransactionVisitID
	,TransactionVisitType
	,CurrentFinancialClass
	,CurrentPayerID
	,CurrentPayerPlanID
	,OriginalFinancialClass
	,OriginalPayerID
	,OriginalPayerPlanID
	,TransactionServiceProviderID
	,TransactionBillingProviderID
	,TransactionCode
	,TransactionDescription
	,TransactionCPTCode
	,TransactionModifier1
	,TransactionModifier2
	,TransactionModifier3
	,TransactionModifier4
	,TransactionUnits
	,TransactionLedgerType
	,TransactionOriginalAmount
	,TransactionARAmountAll
	,TransactionARAmountSelfPay
	,TransactionARAmountInsurance
	,TransactionARAmountActive
	,TransactionARAmountBadDebt
	,TransactionServiceDate
	,TransactionServiceDateAge
	,TransactionPostDate
	,TransactionPostDateAge
	,TransactionInsuranceAgeDate
	,TransactionInsuranceAge
	,TransactionFirstClaimDate
	,TransactionLastClaimDate
	,TransactionSelfPayAgeDate
	,TransactionSelfPayAge
	,ARHistoryUpdatedDatetime
	)

	SELECT
		CONCAT('1~',FORMAT(GETDATE(),'MM-dd-yyyy'),'~',a.Voucher_Number) as ARHistoryID
		,FORMAT(GETDATE(),'MM-dd-yyyy') AS ARHistoryDate
		,'1' AS TransactionDataSourceID
		,CONCAT('PB~',a.Voucher_Number) as TransactionSourceID
		,'Charge' AS TransactionType
		,CONCAT('1~',a.Location_ID) AS TransactionLocationID
		,CONCAT('1~',a.Department_ID) AS TransactionDepartmentID
		,CONCAT('1~',a.Place_Of_Service_ID) as TransactionPlaceOfServiceID --CASE WHEN t.ORIGINAL_PLAN_ID is not null THEN CONCAT('5~',t.ORIGINAL_PLAN_ID) 
		,NULL AS TransactionPlaceOfServiceType  --CLARITY_POS
		,a.Account_Number as TransactionGuarantorID
		,NULL AS TransactionGuarantorType --join on ACCOUNT (s?)
		,CONCAT('1~',a.Voucher_Number) AS TransactionAccountID
		,NULL AS TransactionAccountClass --JOIN fact.accounts
		,CASE WHEN a.Voucher_Number is not null THEN CONCAT('1~',a.Voucher_Number) END as TransactionVisitID
		,NULL AS TransactionVisitType -- JOIN fact.Visits2
		,ISNULL(pg.PayerGroupName,'Other Commercial') AS CurrentFinancialClass --
		,py.PayerID AS CurrentPayerID
		,NULL AS CurrentPayerPlanID
		,ISNULL(pga.PayerGroupName, 'Self-Pay') AS OriginalFinancialClass
		,pya.PayerID AS OriginalPayerID
		,NULL AS OriginalPayerPlanID
		,CASE WHEN a.Actual_Prov_Practitioner_ID is not null THEN CONCAT('1~', a.Actual_Prov_Practitioner_ID) END AS TransactionServiceProviderID
		,CASE WHEN a.Billing_Prov_Practitioner_ID is not null THEN CONCAT('1~', a.Billing_Prov_Practitioner_ID) END AS TransactionBillingProviderID
		,NULL AS TransactionCode
		,NULL AS TransactionDescription
		,NULL AS TransactionCPTCode
		,NULL as TransactionModifier1
		,NULL as TransactionModifier2
		,NULL as TransactionModifier3
		,NULL as TransactionModifier4
		,NULL as TransactionUnits
		,'Debit' AS TransactionLedgerType
		,ISNULL(a.Fees,0) as TransactionOriginalAmount
		,ISNULL(a.Fees,0) 
				- ISNULL(a.Posted_Adjustments,0) 
				- ISNULL(a.Posted_Payments,0) 
				+ ISNULL(a.Posted_Refunds,0) 
				+ ISNULL(a.Posted_Misc_Debits,0) as TransactionARAmountAll
		,CASE WHEN a.Ins_Rpt_Class_Abbreviation = 'Self-Pay' 
			  THEN ISNULL(a.Fees,0) 
				- ISNULL(a.Posted_Adjustments,0) 
				- ISNULL(a.Posted_Payments,0) 
				+ ISNULL(a.Posted_Refunds,0) 
				+ ISNULL(a.Posted_Misc_Debits,0)
			  ELSE 0 END as TransactionARAmountSelfPay
		,CASE WHEN a.Ins_Rpt_Class_Abbreviation <> 'Self-Pay' 
			  THEN ISNULL(a.Fees,0) 
				- ISNULL(a.Posted_Adjustments,0) 
				- ISNULL(a.Posted_Payments,0) 
				+ ISNULL(a.Posted_Refunds,0) 
				+ ISNULL(a.Posted_Misc_Debits,0)
			  ELSE 0 END  as TransactionARAmountInsurance
		,CASE WHEN a.Ins_Rpt_Class_Description <> 'Collections' 
			  THEN ISNULL(a.Fees,0) 
				- ISNULL(a.Posted_Adjustments,0) 
				- ISNULL(a.Posted_Payments,0) 
				+ ISNULL(a.Posted_Refunds,0) 
				+ ISNULL(a.Posted_Misc_Debits,0)
			  ELSE 0 END   as TransactionARAmountActive
		,CASE WHEN a.Ins_Rpt_Class_Description = 'Collections' 
			  THEN ISNULL(a.Fees,0) 
				- ISNULL(a.Posted_Adjustments,0) 
				- ISNULL(a.Posted_Payments,0) 
				+ ISNULL(a.Posted_Refunds,0) 
				+ ISNULL(a.Posted_Misc_Debits,0)
			  ELSE 0 END as TransactionARAmountBadDebt
		,a.Service_Date AS TransactionServiceDate
		,DATEDIFF(D,a.Service_Date,GETDATE()) AS TransactionServiceDateAge
		,a.Billing_Date as TransactionPostDate
		,DATEDIFF(D,a.Billing_Date,GETDATE()) AS TransactionServiceDateAge
		,a.Billing_Date as TransactionInsuranceAgeDate
		,DATEDIFF(D,a.Billing_Date,GETDATE()) as TransactionInsuranceAge
		,a.Billing_Date as TransactionFirstClaimDate
		,a.Billing_Date as TransactionLastClaimDate
		,a.Billing_Date as TransactionSelfPayAgeDate
		,DATEDIFF(D,a.Billing_Date,GETDATE()) as TransactionSelfPayAge
		,GETDATE() as ARHistoryUpdatedDatetime

	FROM tievmdb03.Ntier_627200.PM.[vwATB] a
		left join fact.Accounts ac ON ac.AccountID = CONCAT('1~',a.Voucher_Number)
		left join dim.Payers py ON py.PayerID =  CONCAT('1~',ISNULL(convert(varchar,a.Carrier_ID),'SELF')) /*If no assigned Payor then assign to self-pay*/
		left join dim.PayerGroups pg ON pg.PayerGroupID = py.PayerGroupID
		left join dim.Payers pya ON pya.PayerID = ac.AccountPrimaryPayerID
		left join dim.PayerGroups pga ON pga.PayerGroupID = pya.PayerGroupID
	WHERE 1=1
		AND (ISNULL(a.Fees,0) 
			- ISNULL(a.Posted_Adjustments,0) 
			- ISNULL(a.Posted_Payments,0) 
			+ ISNULL(a.Posted_Refunds,0) 
			+ ISNULL(a.Posted_Misc_Debits,0)) <> 0 /*Exclude Zero Balances*/
		--AND a.Ins_Rpt_Class_Description <> 'Collections' /*Exclude Bad Debt*/

		

IF (SELECT COUNT(1) FROM @StagingTable) >= 10
	BEGIN 
	PRINT 'At least 10 records exist in the staging table.  Proceed with delete and reload...'

/*-----DELETE/DEACTIVATE old records----*/
	PRINT 'Deleting records in Datasource....'
	DELETE FROM rpt.ARCurrentPB WHERE TransactionDataSourceID = 1


/*-----INSERT new records-----*/
	PRINT 'Inserting new records in Datasource from @StagingTable....'
	INSERT INTO rpt.ARCurrentPB
	(ARHistoryID
	,ARHistoryDate
	,TransactionDataSourceID
	,TransactionSourceID
	,TransactionType
	,TransactionLocationID
	,TransactionDepartmentID
	,TransactionPlaceOfServiceID
	,TransactionPlaceOfServiceType
	,TransactionGuarantorID
	,TransactionGuarantorType
	,TransactionAccountID
	,TransactionAccountClass
	,TransactionVisitID
	,TransactionVisitType
	,CurrentFinancialClass
	,CurrentPayerID
	,CurrentPayerPlanID
	,OriginalFinancialClass
	,OriginalPayerID
	,OriginalPayerPlanID
	,TransactionServiceProviderID
	,TransactionBillingProviderID
	,TransactionCode
	,TransactionDescription
	,TransactionCPTCode
	,TransactionModifier1
	,TransactionModifier2
	,TransactionModifier3
	,TransactionModifier4
	,TransactionUnits
	,TransactionLedgerType
	,TransactionOriginalAmount
	,TransactionARAmountAll
	,TransactionARAmountSelfPay
	,TransactionARAmountInsurance
	,TransactionARAmountActive
	,TransactionARAmountBadDebt
	,TransactionServiceDate
	,TransactionServiceDateAge
	,TransactionPostDate
	,TransactionPostDateAge
	,TransactionInsuranceAgeDate
	,TransactionInsuranceAge
	,TransactionFirstClaimDate
	,TransactionLastClaimDate
	,TransactionSelfPayAgeDate
	,TransactionSelfPayAge
	,ARHistoryUpdatedDatetime
	)

	SELECT
	source.ARHistoryID
	,source.ARHistoryDate
	,source.TransactionDataSourceID
	,source.TransactionSourceID
	,source.TransactionType
	,source.TransactionLocationID
	,source.TransactionDepartmentID
	,source.TransactionPlaceOfServiceID
	,source.TransactionPlaceOfServiceType
	,source.TransactionGuarantorID
	,source.TransactionGuarantorType
	,source.TransactionAccountID
	,source.TransactionAccountClass
	,source.TransactionVisitID
	,source.TransactionVisitType
	,source.CurrentFinancialClass
	,source.CurrentPayerID
	,source.CurrentPayerPlanID
	,source.OriginalFinancialClass
	,source.OriginalPayerID
	,source.OriginalPayerPlanID
	,source.TransactionServiceProviderID
	,source.TransactionBillingProviderID
	,source.TransactionCode
	,source.TransactionDescription
	,source.TransactionCPTCode
	,source.TransactionModifier1
	,source.TransactionModifier2
	,source.TransactionModifier3
	,source.TransactionModifier4
	,source.TransactionUnits
	,source.TransactionLedgerType
	,source.TransactionOriginalAmount
	,source.TransactionARAmountAll
	,source.TransactionARAmountSelfPay
	,source.TransactionARAmountInsurance
	,source.TransactionARAmountActive
	,source.TransactionARAmountBadDebt
	,source.TransactionServiceDate
	,source.TransactionServiceDateAge
	,source.TransactionPostDate
	,source.TransactionPostDateAge
	,source.TransactionInsuranceAgeDate
	,source.TransactionInsuranceAge
	,source.TransactionFirstClaimDate
	,source.TransactionLastClaimDate
	,source.TransactionSelfPayAgeDate
	,source.TransactionSelfPayAge
	,source.ARHistoryUpdatedDatetime
	
	FROM @StagingTable source
	--	LEFT JOIN rpt.ARCurrentPB target ON target.ARHistoryID = source.ARHistoryID
	WHERE 1=1
	--	AND target.ARHistoryID IS NULL 

	END

ELSE
	BEGIN
	PRINT 'Less than 10 records in the staging table. Ending job without delete and reload...'
	END

END
GO
