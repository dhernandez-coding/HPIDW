CREATE PROCEDURE [rpt].[spReloadEPICARHistoryPB_INCREMENTAL] as
		
/* 
-- =============================================
-- Author:		Chris Cross
-- Create date: May 22 2024  3:50PM
-- Edit date:   
-- Description:	incremental reload for rpt.ARHistoryPB from EPIC
-- ============================================= 
*/
--BEGIN


/* Create variable of the first day of the previous month */
DECLARE @StartDate DATE = DATEFROMPARTS(YEAR(DATEADD(month,-1,getdate())),MONTH(DATEADD(month,-1,getdate())),1)

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

	select
		CONCAT('5~',FORMAT(t.AGING_DATE,'MM-dd-yyyy'),'~',t.TX_ID) as ARHistoryID
		,t.AGING_DATE as ARHistoryDate
		,5 as TransactionDataSourceID
		,CONCAT('PB~',t.TX_ID) as TransactionSourceID
		,t.TX_TYPE as TransactionType
		--,t.SERV_AREA_ID
		,CONCAT('5~',t.LOC_ID) as TransactionLocationID
		,CONCAT('5~',t.DEPARTMENT_ID) as TransactionDepartmentID
		,CONCAT('5~',t.POS_ID) as TransactionPlaceOfServiceID
		,t.POS_TYPE as TransactionPlaceOfServiceType
		,t.GUARANTOR_ID as TransactionGuarantorID
		--,t.GUARANTOR_NAME as TransactionGuarantorName
		,t.GUARANTOR_TYPE_NAME as TransactionGuarantorType
		,CASE WHEN t.HSP_ACCOUNT_ID is not null THEN CONCAT('5~',t.HSP_ACCOUNT_ID) END as TransactionAccountID
		,t.HSP_ACCOUNT_BASE_CLASS as TransactionAccountClass
		,CASE WHEN t.PAT_ENC_CSN_ID is not null THEN CONCAT('5~',t.PAT_ENC_CSN_ID) END as TransactionVisitID
		,t.ENCOUNTER_TYPE as TransactionVisitType
		,t.CURRENT_FINANCIAL_CLASS_NAME as CurrentFinancialClass  
		,CONCAT('5~',ISNULL(t.CURRENT_PAYER_ID,'0')) AS CurrentPayerID
		,CASE WHEN t.CURRENT_PLAN_ID is not null THEN CONCAT('5~',t.CURRENT_PLAN_ID) END AS CurrentPayerPlanID
		,t.ORIGINAL_FINANCIAL_CLASS_NAME as OriginalFinancialClass  
		,CONCAT('5~',ISNULL(t.ORIGINAL_PAYER_ID,'0')) AS OriginalPayerID
		,CASE WHEN t.ORIGINAL_PLAN_ID is not null THEN CONCAT('5~',t.ORIGINAL_PLAN_ID) END AS OriginalPayerPlanID
		,CASE WHEN t.SERVICE_PROVIDER_ID is not null THEN CONCAT('5~', t.SERVICE_PROVIDER_ID) END AS TransactionServiceProviderID
		,CASE WHEN t.BILLING_PROVIDER_ID is not null THEN CONCAT('5~', t.BILLING_PROVIDER_ID) END AS TransactionBillingProviderID
		,t.PROCEDURE_CODE as TransactionCode
		,t.PROCEDURE_NAME as TransactionDescription
		,t.PROCEDURE_CPT_CODE as TransactionCPTCode
		,t.MODIFIER_ONE as TransactionModifier1
		,t.MODIFIER_TWO as TransactionModifier2
		,t.MODIFIER_THREE as TransactionModifier3
		,t.MODIFIER_four as TransactionModifier4
		,t.PROCEDURE_QUANTITY as TransactionUnits
		,t.CREDIT_OR_DEBIT as TransactionLedgerType
		,t.ORIGINAL_AMOUNT as TransactionOriginalAmount
		,t.OUTSTANDING_AMOUNT as TransactionARAmountAll
		,t.OUTSTANDING_SELF_PAY_AMOUNT as TransactionARAmountSelfPay
		,t.OUTSTANDING_INSURANCE_AMOUNT as TransactionARAmountInsurance
		,t.ACTIVE_AMOUNT as TransactionARAmountActive
		,t.BAD_DEBT_AMOUNT as TransactionARAmountBadDebt
		,t.SERVICE_DATE as TransactionServiceDate
		,t.SERVICE_DATE_AGE as TransactionServiceDateAge
		,t.POST_DATE as TransactionPostDate
		,t.POST_DATE_AGE as TransactionPostDateAge
		,t.INSURANCE_AGE_DATE as TransactionInsuranceAgeDate
		,t.INSURANCE_AGE as TransactionInsuranceAge
		,t.FIRST_CLAIM_DATE as TransactionFirstClaimDate
		,t.LAST_CLAIM_DATE as TransactionLastClaimDate
		,t.SELF_PAY_AGE_DATE as TransactionSelfPayAgeDate
		,t.SELF_PAY_AGE as TransactionSelfPayAge
		,GETDATE() as ARHistoryUpdatedDatetime
	from [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].CLARITY.[ORGFILTER].V_ARPB_ATB_TX_DETAIL t 
	where 1=1
		AND AGING_DATE >= @StartDate
		--AND t.TX_ID in (73686935,73687002)
		

IF (SELECT COUNT(1) FROM @StagingTable) >= 10
	BEGIN 
	PRINT 'At least 10 records exist in the staging table.  Proceed with delete and reload...'

/*-----DELETE old records from the month being loaded in order to handle potential duplicates----*/
	PRINT 'Deleting records in Datasource....'
	DELETE FROM rpt.ARHistoryPB WHERE TransactionDataSourceID = 5 AND ARHistoryDate >= @StartDate


/*-----INSERT new records-----*/
	PRINT 'Inserting new records in Datasource from @StagingTable....'
	INSERT INTO rpt.ARHistoryPB
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
	--	LEFT JOIN rpt.ARHistoryPB target ON target.ARHistoryID = source.ARHistoryID
	WHERE 1=1
	--	AND target.ARHistoryID IS NULL 

	END

ELSE
	BEGIN
	PRINT 'Less than 10 records in the staging table. Ending job without delete and reload...'
	END

--END
GO
