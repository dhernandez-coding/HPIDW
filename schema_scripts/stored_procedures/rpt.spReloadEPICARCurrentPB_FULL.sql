CREATE PROCEDURE [rpt].[spReloadEPICARCurrentPB_FULL] as
		
/* 
-- =============================================
-- Author:		Robert Beaird
-- Create date: May 29 2024  11:30AM
-- Edit date:   
-- Description:	full reload for rpt.ARCurrentPB from EPIC
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
	CONCAT('5~',FORMAT(GETDATE(),'MM-dd-yyyy'),'~',tx.TX_ID) as ARHistoryID
	,FORMAT(GETDATE(),'MM-dd-yyyy') AS ARHistoryDate
	,'5' AS TransactionDataSourceID
	,CONCAT('PB~',tx.TX_ID) as TransactionSourceID
	,tt.[NAME] AS TransactionType
	,CONCAT('5~',tx.LOC_ID) AS TransactionLocationID
	,CONCAT('5~',tx.DEPARTMENT_ID) AS TransactionDepartmentID
	,CASE WHEN tx.POS_ID is not null THEN CONCAT('5~',tx.POS_ID) END as TransactionPlaceOfServiceID
	,CONVERT(VARCHAR(50),p.POS_NAME) AS TransactionPlaceOfServiceType
	,tx.ACCOUNT_ID as TransactionGuarantorID
	,acc.GUAR_VERIF_ID AS TransactionGuarantorType --placeholder
	,CONCAT('5~',m.HOSP_ACCT_ID) AS TransactionAccountID
	,a.AccountClass AS TransactionAccountClass
	,CASE WHEN tx.PAT_ENC_CSN_ID is not null THEN CONCAT('5~',tx.PAT_ENC_CSN_ID) END as TransactionVisitID
	,vv.VisitType AS TransactionVisitType
	,ISNULL(fc.FINANCIAL_CLASS_NAME, 'Self-Pay') AS CurrentFinancialClass --
	,CONCAT('5~',ISNULL(tx.PAYOR_ID,'0')) AS CurrentPayerID
	,NULL AS CurrentPayerPlanID
	,ISNULL(ofc.FINANCIAL_CLASS_NAME, 'Self-Pay') AS OriginalFinancialClass
	,CONCAT('5~',ISNULL(tx.ORIGINAL_EPM_ID,'0')) AS OriginalPayerID
	,NULL AS OriginalPayerPlanID
	,CASE WHEN tx.SERV_PROVIDER_ID is not null THEN CONCAT('5~', tx.SERV_PROVIDER_ID) END AS TransactionServiceProviderID
	,CASE WHEN tx.BILLING_PROV_ID is not null THEN CONCAT('5~', tx.BILLING_PROV_ID) END AS TransactionBillingProviderID
	,eap.PROC_CODE AS TransactionCode
	,eap.PROC_NAME AS TransactionDescription
	,tx.CPT_CODE AS TransactionCPTCode
	,tx.MODIFIER_ONE as TransactionModifier1
	,tx.MODIFIER_TWO as TransactionModifier2
	,tx.MODIFIER_THREE as TransactionModifier3
	,tx.MODIFIER_four as TransactionModifier4
	,tx.PROCEDURE_QUANTITY as TransactionUnits
	,CASE
		WHEN tx.DEBIT_CREDIT_FLAG = 1
			THEN 'Debit'
		ELSE 'Credit'
	END	AS TransactionLedgerType
	,tx.AMOUNT as TransactionOriginalAmount
	,tx.OUTSTANDING_AMT as TransactionARAmountAll
	,tx.PATIENT_AMT as TransactionARAmountSelfPay
	,tx.INSURANCE_AMT as TransactionARAmountInsurance
	,CASE
		WHEN m.AR_CLASS_C IN (2,4)
		THEN 0
		ELSE tx.OUTSTANDING_AMT
	END  as TransactionARAmountActive
	,CASE
		WHEN m.AR_CLASS_C IN (2,4)
		THEN tx.OUTSTANDING_AMT
		ELSE 0
	END as TransactionARAmountBadDebt
	,tx.SERVICE_DATE AS TransactionServiceDate
	,DATEDIFF(D,tx.SERVICE_DATE,GETDATE()) AS TransactionServiceDateAge
	,tx.POST_DATE as TransactionPostDate
	,DATEDIFF(D,tx.POST_DATE,GETDATE()) AS TransactionServiceDateAge
	,m.INS_AGING_DATE as TransactionInsuranceAgeDate
	,DATEDIFF(D,m.INS_AGING_DATE,GETDATE()) as TransactionInsuranceAge
	,tx.CLAIM_DATE as TransactionFirstClaimDate
	,tx.CLAIM_DATE as TransactionLastClaimDate
	,m.PAT_AGING_DATE as TransactionSelfPayAgeDate
	,DATEDIFF(D,m.PAT_AGING_DATE,GETDATE()) as TransactionSelfPayAge
	,GETDATE() as ARHistoryUpdatedDatetime
from [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].CLARITY.[ORGFILTER].ARPB_TRANSACTIONS tx 
	LEFT JOIN dim.Dates gd
		ON FORMAT(getdate(), 'yyyy-MM-dd') = gd.[Date]
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].CLARITY.[ORGFILTER].ZC_TRAN_TYPE tt
		ON tx.TX_TYPE_C = tt.TRAN_TYPE
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].CLARITY.[ORGFILTER].ARPB_TX_MODERATE m
		ON tx.TX_ID = m.TX_ID
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].CLARITY.[ORGFILTER].CLARITY_EPM epm
		ON tx.PAYOR_ID = epm.PAYOR_ID
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].CLARITY.[ORGFILTER].CLARITY_FC fc
		ON epm.FINANCIAL_CLASS = fc.FINANCIAL_CLASS
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].CLARITY.[ORGFILTER].CLARITY_FC ofc
		ON tx.ORIGINAL_FC_C = ofc.FINANCIAL_CLASS
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].CLARITY.[ORGFILTER].CLARITY_EAP eap
		ON tx.PROC_ID = eap.PROC_ID
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].CLARITY.[ORGFILTER].CLARITY_POS p
		ON tx.POS_ID = p.POS_ID
	LEFT JOIN fact.Accounts a
		ON CONCAT('5~',m.HOSP_ACCT_ID) = a.AccountID
	LEFT JOIN fact.Visits2 vv
		ON CONCAT('5~',m.HOSP_ACCT_ID) = vv.VisitAccountID
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].CLARITY.[ORGFILTER].ACCOUNT acc
		ON tx.ACCOUNT_ID = acc.ACCOUNT_ID
where 1=1
	--AND t.TRAN_TYPE = 1  -- ???????????????????????
	--AND t.DETAIL_TYPE < 40 -- ???????????????????????
	AND tx.ZERO_BALANCE_YN = 'N'
		

IF (SELECT COUNT(1) FROM @StagingTable) >= 10
	BEGIN 
	PRINT 'At least 10 records exist in the staging table.  Proceed with delete and reload...'

/*-----DELETE/DEACTIVATE old records----*/
	PRINT 'Deleting records in Datasource....'
	DELETE FROM rpt.ARCurrentPB
	WHERE TransactionDataSourceID = '5'


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
