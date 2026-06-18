--USE [HPIDW]
--GO
--/****** Object:  StoredProcedure [stg].[spMedhostCHReloadFactTransactionsFull]    Script Date: 4/14/2023 3:47:42 PM ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [stg].[spEPICReloadFactTransactionsIncremental] as

BEGIN
--TRUNCATE TABLE fact.Transactions
DELETE FROM fact.Transactions WHERE TransactionDataSourceID = 5 AND TransactionDateOfPosting >= DATEADD(DAY,-10, convert(date,GETDATE())) /*Only load transactions from the last 10 days*/

/*Query for Transactions  - HB*/
INSERT INTO fact.Transactions
	(--[TransactionID]
	  [TransactionDatasourceID]
      ,[TransactionSourceID]
	  ,TransactionParentSourceID 
      ,[TransactionVisitID]
	  ,TransactionEncounterID 
      ,[TransactionDepartmentID]
      ,[TransactionPayerID]
      ,[TransactionBillingProviderID]
      ,[TransactionBillingType]
      ,[TransactionType]
      ,[TransactionSubType]
      ,[TransactionRevenueCode]
      ,[TransactionRevenueCodeDescription]
      ,[TransactionCode]
      ,[TransactionDescription]
      ,[TransactionCPTCode]
      ,[TransactionModifier1]
      ,[TransactionModifier2]
      ,[TransactionModifier3]
      ,[TransactionModifier4]
      ,[TransactionUnits]
      ,[TransactionAmount]
	  ,TransactionRVU
      ,[TransactionDateOfService]
      ,[TransactionDateOfPosting]
      ,[TransactionDateOfBilling]
      ,[TransactionReportingPeriodID]
      ,[TransactionStatus]
      ,[TransactionIsActive]
      ,[TransactionUpdatedDateTime]
	  )

 /*HB Transactions*/
  SELECT 
	--CONCAT('8~CHG~',c.PATNO,'~',c.BATCH,'~',c.SEQ#,'~',c.REF#) as TransactionID /*This is not unique*/
	'5' as TransactionDatasourceID
	,CONCAT('HB~',tx.TX_ID) as TransactionSourceID
	,NULL AS TransactionParentSourceID
	,CASE WHEN tx.HSP_ACCOUNT_ID is not null THEN CONCAT('5~',tx.HSP_ACCOUNT_ID) END as TransactionVisitID
	,CASE WHEN a.PRIM_ENC_CSN_ID is not null THEN CONCAT('5~',a.PRIM_ENC_CSN_ID) END AS TransactionEncounterID
	,CASE WHEN tx.DEPARTMENT is not null THEN CONCAT('5~',tx.DEPARTMENT) END as TransactionDepartmentID
	,CASE WHEN COALESCE(tx.PAYOR_ID, epp.PAYOR_ID, a.PRIMARY_PAYOR_ID) is not null THEN CONCAT('5~',COALESCE(tx.PAYOR_ID, epp.PAYOR_ID, a.PRIMARY_PAYOR_ID)) END as TransactionPayerID
	,CASE WHEN COALESCE(tx.BILLING_PROV_ID,tx.PERFORMING_PROV_ID) is not null THEN CONCAT('5~',COALESCE(tx.BILLING_PROV_ID,tx.PERFORMING_PROV_ID)) END as TransactionBillingProviderID
	,'HB' as TransactionBillingType
	,CASE WHEN tx.TX_TYPE_HA_C = 1 THEN 'Charge'
		  WHEN tx.TX_TYPE_HA_C = 2 THEN 'Payment'
		  WHEN tx.TX_TYPE_HA_C in (3,4) THEN 'Adjustment' END as TransactionType
	,CASE WHEN tx.TX_TYPE_HA_C = 1 THEN 'Charge'
		  WHEN tx.TX_TYPE_HA_C = 2 AND tx.BAD_DEBT_FLAG_YN = 'Y' THEN 'Payment - Bad Debt'
		  WHEN tx.TX_TYPE_HA_C = 2 THEN 'Payment - Regular'
		  WHEN tx.TX_TYPE_HA_C in (3) THEN 'Adjustment - Debit'
		  WHEN tx.TX_TYPE_HA_C in (4) THEN 'Adjustment - Credit' END  as TransactionSubType
	,rc.REVENUE_CODE as TransactionRevenueCode
	,rc.BILL_DESC as TransactionRevenueCode
	,eap.PROC_CODE as TransactionCode
	,COALESCE(tx.PROCEDURE_DESC, eap.BILL_DESC, eap.PROC_NAME) as TransactionDescription
	,CASE WHEN tx.TX_TYPE_HA_C = 1 AND LEN(tx.HCPCS_CODE) = 5 THEN tx.HCPCS_CODE
		  WHEN tx.TX_TYPE_HA_C = 1 AND LEN(tx.CPT_CODE) = 5 THEN tx.CPT_CODE
		  WHEN tx.TX_TYPE_HA_C = 1 AND LEN(eap.PROC_CODE) = 5 THEN eap.PROC_CODE
	 END as TransactionCPTCode
	,LEFT(tx.MODIFIERS,2) as TransactionModifier1
	,SUBSTRING(tx.MODIFIERS,3,2) as TransactionModifier2
	,SUBSTRING(tx.MODIFIERS,5,2) as TransactionModifier3
	,SUBSTRING(tx.MODIFIERS,7,2) as TransactionModifier4
	,tx.QUANTITY as TransactionUnits
	,tx.TX_AMOUNT as TransactionAmount
	,NULL AS TransactionRVU
	,tx.SERVICE_DATE as TransactionDateOfService
	,tx.TX_POST_DATE as TransactionDateOfPosting
	,tx.TX_POST_DATE as TransactionDateOfBilling
	,CONCAT(YEAR(tx.TX_POST_DATE),' - ', RIGHT(concat('00',MONTH(tx.TX_POST_DATE)),2)) as TransactionReportingPeriodID
	,CASE WHEN sts.ACTIVE_TX_YN = 'Y' THEN 'Active' ELSE 'Inactive' END as TransactionStatus 
	,1 as TransactionIsActive
	,GETDATE() as TransactionUpdatedDatetime
 --select EAP.* 
 FROM [100.65.16.148].[CLARITY].[ORGFILTER].HSP_TRANSACTIONS tx
	LEFT JOIN [100.65.16.148].[CLARITY].[ORGFILTER].HSP_ACCOUNT a ON a.HSP_ACCOUNT_ID = tx.HSP_ACCOUNT_ID
	--LEFT JOIN [100.65.16.148].[CLARITY].[ORGFILTER].ZC_TX_TYPE_HA typ ON typ.TX_TYPE_HA_C = tx.TX_TYPE_HA_C
	LEFT JOIN [100.65.16.148].[CLARITY].[ORGFILTER].CLARITY_EAP eap ON eap.PROC_ID = tx.PROC_ID
	LEFT JOIN [100.65.16.148].[CLARITY].[ORGFILTER].CL_UB_REV_CODE rc ON rc.UB_REV_CODE_ID = tx.UB_REV_CODE_ID
	LEFT JOIN [100.65.16.148].[CLARITY].[ORGFILTER].HSP_TX_STATUS sts ON sts.TX_ID = tx.TX_ID
	LEFT JOIN [100.65.16.148].[CLARITY].[ORGFILTER].CLARITY_EPP epp ON epp.BENEFIT_PLAN_ID = tx.PRIMARY_PLAN_ID
 WHERE tx.TX_TYPE_HA_C in (1,2,3,4)
 AND tx.TX_POST_DATE >= DATEADD(DAY,-10, convert(date,GETDATE())) /*Only load transactions from the last 10 days*/

 /*PB Transactions*/
UNION ALL 

SELECT
	'5' as TransactionDatasourceID
	,CONCAT('PB~',tx.TX_ID,CASE WHEN tdl.MATCH_TRX_ID IS NOT NULL THEN CONCAT('~',tdl.MATCH_TRX_ID,'~',tdl.TDL_ID) END) as TransactionSourceID
	,CONCAT('PB~',tx.TX_ID) AS TransactionParentSourceID
	,CASE WHEN tm.HOSP_ACCT_ID is not null THEN CONCAT('5~',tm.HOSP_ACCT_ID) END as TransactionVisitID
	,CASE WHEN tx.PAT_ENC_CSN_ID is not null THEN CONCAT('5~',tx.PAT_ENC_CSN_ID) END as TransactionEncounterID
	,CASE WHEN tdl.DEPT_ID is not null THEN CONCAT('5~',tdl.DEPT_ID) END as TransactionDepartmentID
	,CASE WHEN tx.ORIGINAL_FC_C = 4 and tdl.CUR_PAYOR_ID is null THEN '5~0' /*Hard-code selfpay when financial class is self pay*/
		  WHEN COALESCE(tdl.CUR_PAYOR_ID,tx.PAYOR_ID, tx.ORIGINAL_EPM_ID, a.PRIMARY_PAYOR_ID) is not null THEN CONCAT('5~',COALESCE(tdl.CUR_PAYOR_ID,tx.PAYOR_ID, tx.ORIGINAL_EPM_ID, a.PRIMARY_PAYOR_ID)) END as TransactionPayerID
	,CASE WHEN COALESCE(tdl.BILLING_PROVIDER_ID,tx.BILLING_PROV_ID,tx.SERV_PROVIDER_ID) is not null THEN CONCAT('5~',COALESCE(tx.BILLING_PROV_ID,tx.SERV_PROVIDER_ID)) END as TransactionBillingProviderID
	,'PB' as TransactionBillingType
	,CASE WHEN tdl.MATCH_TX_TYPE IS NULL AND tx.TX_TYPE_C = 1 THEN 'Charge'
		  WHEN tdl.MATCH_TX_TYPE = 2 THEN 'Payment'
		  WHEN tdl.MATCH_TX_TYPE = 3 THEN 'Adjustment' END as TransactionType
	, CASE WHEN tdl.DETAIL_TYPE = 1 THEN 'Charge'
		   WHEN tdl.DETAIL_TYPE = 20 THEN 'Payment - Regular'
		   WHEN tdl.DETAIL_TYPE = 21 THEN 'Adjustment - Credit'
		   --WHEN tdl.DETAIL_TYPE = 30 THEN 'Credit Adjustment to Charge'
		   --WHEN tdl.DETAIL_TYPE = 31 THEN 'Credit Adjustemnt to Debit Adjustment'
		   --WHEN tdl.DETAIL_TYPE = 32 THEN 'Payment to Charge'
		   --WHEN tdl.DETAIL_TYPE = 33 THEN 'Payment to Debit Adjustment'
		   ELSE CONVERT(VARCHAR,tdl.DETAIL_TYPE)
		   END as TransactionSubType
	,rc.REVENUE_CODE as TransactionRevenueCode
	,rc.BILL_DESC as TransactionRevenueCode
	,eap2.PROC_CODE as TransactionCode
	,COALESCE(eap2.BILL_DESC, eap2.PROC_NAME) as TransactionDescription
	,tx.CPT_CODE as TransactionCPTCode
	,CASE WHEN tdl.DETAIL_TYPE = 1 THEN tx.MODIFIER_ONE END as TransactionModifier1
	,CASE WHEN tdl.DETAIL_TYPE = 1 THEN tx.MODIFIER_TWO END as TransactionModifier2
	,CASE WHEN tdl.DETAIL_TYPE = 1 THEN tx.MODIFIER_THREE END as TransactionModifier3
	,CASE WHEN tdl.DETAIL_TYPE = 1 THEN tx.MODIFIER_FOUR END as TransactionModifier4
	,tdl.PROCEDURE_QUANTITY as TransactionUnits
	,tdl.AMOUNT as TransactionAmount
	,tdl.RELATIVE_VALUE_UNIT as TransactionRVU
	,tdl.ORIG_SERVICE_DATE as TransactionDateOfService
	,tdl.POST_DATE as TransactionDateOfPosting
	,tx.POST_DATE as TransactionDateOfBilling
	,CONCAT(YEAR(tdl.POST_DATE),' - ', RIGHT(concat('00',MONTH(tdl.POST_DATE)),2)) as TransactionReportingPeriodID
	,'Active' as TransactionStatus 
	,1 as TransactionIsActive
	,GETDATE() as TransactionUpdatedDatetime
FROM [100.65.16.148].[CLARITY].[ORGFILTER].ARPB_TRANSACTIONS tx 
	LEFT JOIN [100.65.16.148].[CLARITY].[ORGFILTER].CLARITY_TDL_TRAN tdl ON tx.TX_ID = tdl.TX_ID 
																		AND tdl.DETAIL_TYPE <> 10 /*Voided charges are handled in WHERE clause*/
																		AND tdl.DETAIL_TYPE < 40 /*Only Include New and Matching transaction types*/
	LEFT JOIN [100.65.16.148].[CLARITY].[ORGFILTER].[ZC_TRAN_TYPE] t ON t.TRAN_TYPE = tx.TX_TYPE_C
	LEFT JOIN [100.65.16.148].[CLARITY].[ORGFILTER].[ARPB_TX_MODERATE] tm ON tm.TX_ID = tx.TX_ID
	LEFT JOIN [100.65.16.148].[CLARITY].[ORGFILTER].[HSP_ACCOUNT] a ON a.HSP_ACCOUNT_ID = tm.HOSP_ACCT_ID
	LEFT JOIN [100.65.16.148].[CLARITY].[ORGFILTER].[CLARITY_EAP] eap1 ON eap1.PROC_ID = tx.PROC_ID
	LEFT JOIN [100.65.16.148].[CLARITY].[ORGFILTER].[CLARITY_EAP] eap2 ON eap2.PROC_ID = tdl.PROC_ID
	LEFT JOIN [100.65.16.148].[CLARITY].[ORGFILTER].[CL_UB_REV_CODE] rc ON rc.UB_REV_CODE_ID = eap1.UB_REV_CODE_ID
WHERE 1=1 
	AND tx.TX_TYPE_C = 1 /*Charges*/
	AND tx.VOID_DATE is null /*Exclude voided charges*/
	AND tdl.TDL_ID IS NOT NULL 
	--AND tx.TX_ID = 37387992
	AND tdl.POST_DATE >= DATEADD(DAY,-10, convert(date,GETDATE())) /*Only load transactions from the last 10 days*/

END
GO
