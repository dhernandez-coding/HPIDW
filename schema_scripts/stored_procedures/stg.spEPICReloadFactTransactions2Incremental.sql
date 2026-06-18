CREATE PROCEDURE [stg].[spEPICReloadFactTransactions2Incremental] as


/*
Change Control:
	1. 9/4/24 - Chris Cross - Removed PB loading sections as those are now loading to fact.TransactionsPB
	2. 9/19/25 - Diego Hernandez - Including AdjCategory

*/

BEGIN

DECLARE @DaysToReload int = 10

/*Delete and reload HB transactions*/
PRINT 'Deleting HB records posted in the last' + convert(varchar(10),@DaysToReload) + ' days....'
DELETE FROM fact.Transactions2 WHERE TransactionDataSourceID = 5 AND TransactionBillingType = 'HB' AND TransactionDateOfPosting >= DATEADD(DAY,-@DaysToReload, convert(date,GETDATE())) /*Only load transactions from the last 10 days*/

PRINT 'Inserting HB records posted in the last' + convert(varchar(10),@DaysToReload) + ' days....'
INSERT INTO fact.Transactions2
	(--[TransactionID]
	  [TransactionDatasourceID]
      ,[TransactionSourceID]
	  ,TransactionParentSourceID 
      ,[TransactionVisitID]
	  ,TransactionAccountID
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
	  ,[TransactionDateOfVoid]
      ,[TransactionReportingPeriodID]
      ,[TransactionStatus]
      ,[TransactionIsActive]
      ,[TransactionUpdatedDateTime],
	  [TransactionAdjustmentCategory]
	  )

 /*HB Transactions*/
  SELECT 
	--CONCAT('8~CHG~',c.PATNO,'~',c.BATCH,'~',c.SEQ#,'~',c.REF#) as TransactionID /*This is not unique*/
	'5' as TransactionDatasourceID
	,CONCAT('HB~',tx.TX_ID) as TransactionSourceID
	,NULL AS TransactionParentSourceID
	,CASE WHEN tx.HSP_ACCOUNT_ID is not null THEN CONCAT('5~',tx.HSP_ACCOUNT_ID) END as TransactionVisitID
	,CASE WHEN tx.HSP_ACCOUNT_ID is not null THEN CONCAT('5~',tx.HSP_ACCOUNT_ID) END as TransactionAccountID
	,CASE WHEN a.PRIM_ENC_CSN_ID is not null THEN CONCAT('5~',a.PRIM_ENC_CSN_ID) END AS TransactionEncounterID
	,CASE WHEN tx.DEPARTMENT is not null THEN CONCAT('5~',tx.DEPARTMENT) END as TransactionDepartmentID
	,CASE WHEN COALESCE(tx.PAYOR_ID, epp.PAYOR_ID, a.PRIMARY_PAYOR_ID) is not null THEN CONCAT('5~',COALESCE(tx.PAYOR_ID, epp.PAYOR_ID, a.PRIMARY_PAYOR_ID)) END as TransactionPayerID
	,CASE WHEN COALESCE(op.AUTHRZING_PROV_ID,op.BILLING_PROV_ID,tx.BILLING_PROV_ID,tx.PERFORMING_PROV_ID) is not null THEN CONCAT('5~',COALESCE(op.AUTHRZING_PROV_ID,op.BILLING_PROV_ID,tx.BILLING_PROV_ID,tx.PERFORMING_PROV_ID)) END as TransactionBillingProviderID
	,'HB' as TransactionBillingType
	,CASE WHEN tx.TX_TYPE_HA_C = 1 THEN 'Charge'
		  WHEN tx.TX_TYPE_HA_C = 2 THEN 'Payment'
		  WHEN tx.TX_TYPE_HA_C in (3,4) THEN 'Adjustment' END as TransactionType
	,CASE WHEN tx.TX_TYPE_HA_C = 1 THEN 'Charge - New'
		  WHEN tx.TX_TYPE_HA_C = 2 AND tx.BAD_DEBT_FLAG_YN = 'Y' THEN 'Payment - Bad Debt'
		  WHEN tx.TX_TYPE_HA_C = 2 THEN 'Payment - Regular'
		  WHEN tx.TX_TYPE_HA_C in (3) THEN 'Adjustment - Debit'
		  WHEN tx.TX_TYPE_HA_C in (4) THEN 'Adjustment - Credit' END  as TransactionSubType
	,CASE WHEN LEFT(rc.REVENUE_CODE,1) = '0' THEN RIGHT(rc.REVENUE_CODE,3) ELSE rc.REVENUE_CODE END as TransactionRevenueCode
	,rc.BILL_DESC as TransactionRevenueCodeDescription
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
	,NULL AS TransactionDateOfVoid
	,CONCAT(YEAR(tx.TX_POST_DATE),' - ', RIGHT(concat('00',MONTH(tx.TX_POST_DATE)),2)) as TransactionReportingPeriodID
	,CASE WHEN sts.ACTIVE_TX_YN = 'Y' THEN 'Active' ELSE 'Inactive' END as TransactionStatus 
	,1 as TransactionIsActive
	,GETDATE() as TransactionUpdatedDatetime
	,cat.NAME as TransactionAdjustmentCategory

 --select EAP.* 
 FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].HSP_TRANSACTIONS tx
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].HSP_ACCOUNT a ON a.HSP_ACCOUNT_ID = tx.HSP_ACCOUNT_ID
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].CLARITY_EAP_2 eapp ON eapp.PROC_ID = tx.PROC_ID
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].ZC_ADJUSTMENT_CAT cat on cat.ADJUSTMENT_CAT_C =eapp.ADJUSTMENT_CAT_C
	--LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].ZC_TX_TYPE_HA typ ON typ.TX_TYPE_HA_C = tx.TX_TYPE_HA_C
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].CLARITY_EAP eap ON eap.PROC_ID = tx.PROC_ID
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].CL_UB_REV_CODE rc ON rc.UB_REV_CODE_ID = tx.UB_REV_CODE_ID
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].HSP_TX_STATUS sts ON sts.TX_ID = tx.TX_ID
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].CLARITY_EPP epp ON epp.BENEFIT_PLAN_ID = tx.PRIMARY_PLAN_ID
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].ORDER_PROC op ON op.ORDER_PROC_ID = tx.ORDER_ID
 WHERE 1=1 
 AND tx.TX_TYPE_HA_C in (1,2,3,4)
 AND tx.SERV_AREA_ID in (425,430)
 AND tx.TX_POST_DATE >= DATEADD(DAY,-@DaysToReload, convert(date,GETDATE())) /*Only load transactions from the last 10 days*/

END


/*  --Removed on 9/4/2024 by Chris Cross
/*Step 2:  Delete and reload PB transactions*/
PRINT 'Deleting PB records posted in the last' + convert(varchar(10),@DaysToReload) + ' days....'
DELETE FROM fact.Transactions2 WHERE TransactionDataSourceID = 5 AND TransactionBillingType = 'PB' AND TransactionDateOfPosting >= DATEADD(DAY,-@DaysToReload, convert(date,GETDATE())) /*Only load transactions from the last 10 days*/

PRINT 'Inserting PB records posted in the last' + convert(varchar(10),@DaysToReload) + ' days....'
INSERT INTO fact.Transactions2
	(--[TransactionID]
	  [TransactionDatasourceID]
      ,[TransactionSourceID]
	  ,TransactionParentSourceID 
      ,[TransactionVisitID]
	  ,TransactionAccountID
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
	  ,[TransactionDateOfVoid]
      ,[TransactionReportingPeriodID]
      ,[TransactionStatus]
      ,[TransactionIsActive]
      ,[TransactionUpdatedDateTime]
	  ,[TransactionCPTDescription]
	  ,[TransactionPlaceOfServiceCode]
	  ,[TransactionPlaceOfServiceType]
	  ,[TransactionGLType]
	  )
 /*PB Transactions - Charges and Credit Adjustments*/

SELECT
	'5' as TransactionDatasourceID
	,CONCAT('PB~',tx.TX_ID
				 ,CASE WHEN tdl.MATCH_TRX_ID IS NOT NULL THEN CONCAT('~',tdl.MATCH_TRX_ID,'~',tdl.TDL_ID) END
				 ,CASE WHEN tdl.DETAIL_TYPE = 10 THEN CONCAT('~','VOID') END )as TransactionSourceID
	,CONCAT('PB~',tx.TX_ID) AS TransactionParentSourceID
	,CASE WHEN tm.HOSP_ACCT_ID is not null THEN CONCAT('5~',tm.HOSP_ACCT_ID) END as TransactionVisitID
	,CASE WHEN tm.HOSP_ACCT_ID is not null THEN CONCAT('5~',tm.HOSP_ACCT_ID) END as TransactionAccountID
	,CASE WHEN tx.PAT_ENC_CSN_ID is not null THEN CONCAT('5~',tx.PAT_ENC_CSN_ID)
		  WHEN tx.PAT_ENC_CSN_ID is null THEN CONCAT('5~',tx.ENC_FORM_NUM) END  as TransactionEncounterID
	,CASE WHEN tdl.DEPT_ID is not null THEN CONCAT('5~',tdl.DEPT_ID) END as TransactionDepartmentID
	,CASE WHEN tx.ORIGINAL_FC_C = 4 and tdl.CUR_PAYOR_ID is null THEN '5~0' /*Hard-code selfpay when financial class is self pay*/
		  WHEN COALESCE(tdl.CUR_PAYOR_ID,tx.PAYOR_ID, tx.ORIGINAL_EPM_ID, a.PRIMARY_PAYOR_ID) is not null THEN CONCAT('5~',COALESCE(tdl.CUR_PAYOR_ID,tx.PAYOR_ID, tx.ORIGINAL_EPM_ID, a.PRIMARY_PAYOR_ID)) END as TransactionPayerID
	,CASE WHEN COALESCE(tdl.BILLING_PROVIDER_ID,tx.BILLING_PROV_ID,tx.SERV_PROVIDER_ID) is not null THEN CONCAT('5~',COALESCE(tx.BILLING_PROV_ID,tx.SERV_PROVIDER_ID)) END as TransactionBillingProviderID
	,'PB' as TransactionBillingType
	,CASE WHEN tdl.MATCH_TX_TYPE IS NULL AND tx.TX_TYPE_C = 1 THEN 'Charge'
		  --WHEN tdl.MATCH_TX_TYPE = 2 THEN 'Payment'
		  WHEN tdl.MATCH_TX_TYPE = 3 THEN 'Adjustment' END as TransactionType
	, CASE WHEN tdl.DETAIL_TYPE = 1 THEN 'Charge - New'
		   WHEN tdl.DETAIL_TYPE = 10 then 'Charge - Void'
		   --WHEN tdl.DETAIL_TYPE = 20 THEN 'Payment - Regular'
		   WHEN tdl.DETAIL_TYPE = 21 THEN 'Credit Adjustment - Matched to Charge'
		   --WHEN tdl.DETAIL_TYPE = 30 THEN 'Credit Adjustment to Charge'
		   --WHEN tdl.DETAIL_TYPE = 31 THEN 'Credit Adjustemnt to Debit Adjustment'
		   --WHEN tdl.DETAIL_TYPE = 32 THEN 'Payment to Charge'
		   --WHEN tdl.DETAIL_TYPE = 33 THEN 'Payment to Debit Adjustment'
		   ELSE CONVERT(VARCHAR,tdl.DETAIL_TYPE)
		   END as TransactionSubType
	,CASE WHEN LEFT(rc.REVENUE_CODE,1) = '0' THEN RIGHT(rc.REVENUE_CODE,3) ELSE rc.REVENUE_CODE END as TransactionRevenueCode
	,rc.BILL_DESC as TransactionRevenueCodeDescription
	,eap2.PROC_CODE as TransactionCode
	,COALESCE(eap2.BILL_DESC, eap2.PROC_NAME) as TransactionDescription
	,tx.CPT_CODE as TransactionCPTCode
	,CASE WHEN tdl.DETAIL_TYPE in (1,10) THEN tx.MODIFIER_ONE END as TransactionModifier1
	,CASE WHEN tdl.DETAIL_TYPE in (1,10) THEN tx.MODIFIER_TWO END as TransactionModifier2
	,CASE WHEN tdl.DETAIL_TYPE in (1,10) THEN tx.MODIFIER_THREE END as TransactionModifier3
	,CASE WHEN tdl.DETAIL_TYPE in (1,10) THEN tx.MODIFIER_FOUR END as TransactionModifier4
	,tdl.PROCEDURE_QUANTITY as TransactionUnits
	,tdl.AMOUNT as TransactionAmount
	,tdl.RELATIVE_VALUE_UNIT as TransactionRVU
	,tdl.ORIG_SERVICE_DATE as TransactionDateOfService
	,tdl.POST_DATE as TransactionDateOfPosting
	,tx.POST_DATE as TransactionDateOfBilling
	,tx.VOID_DATE as TransactionDateOfVoid
	,CONCAT(YEAR(tdl.POST_DATE),' - ', RIGHT(concat('00',MONTH(tdl.POST_DATE)),2)) as TransactionReportingPeriodID
	,CASE WHEN tx.VOID_DATE is null THEN 'Active' ELSE 'Voided' END as TransactionStatus 
	,1 as TransactionIsActive
	,GETDATE() as TransactionUpdatedDatetime
	,COALESCE(eap2.BILL_DESC, eap2.PROC_NAME) as TransactionCPTDescription
	,pos.POS_CODE AS TransactionPlaceOfServiceCode
	,pos.POS_TYPE as TransactionPlaceOfServiceType
	,CASE --WHEN a.[Appt_Type_Abbr] in ('SB','SB GWILL') or a.[Appt_Resource_Descr] like '%smartbeat%' and tx.CPT_CODE in ('92250','93000','93308','93321','93325','93882','93922','93979','94010') THEN 'Smartbeat'
		WHEN tx.CPT_CODE in ('MPDC', '93922') THEN 'MaxPulse'
		WHEN tdl.DETAIL_TYPE = 1 and tx.CPT_CODE like '7%' and (tx.MODIFIER_ONE = 'TC' OR tx.MODIFIER_TWO = 'TC') THEN 'RadTC'
		WHEN pc.[ProcedureCodeCategory] = 'XRAY Only Visits' THEN 'Xray'
		WHEN pc.[ProcedureCodeServiceLine] = 'DME' THEN 'DME'
		WHEN pc.[ProcedureCodeCategory] = 'Ultrasound Only Visit' THEN 'Ultrasound' 
		WHEN pc.[ProcedureCodeCategory] = 'Lab Only Visit' THEN 'Lab' 
		--WHEN (a.[Appt_Type_Abbr] = 'ANS GWIL' or a.[Appt_Resource_Descr] = 'AUTONOMIC NERVE TESTING-GWIL') and (a.[Patient_ID] is not null) and (a.[Appt_Status] <> 'X' and a.[Appt_Status] <> 'N')  THEN 'ANS'  
		WHEN tx.CPT_CODE in ('51729', '51797', '51784', '51741') THEN 'URO'  
		WHEN tx.CPT_CODE in ('99453', '99454', '99457', '99458', '95249', '95250', '95251') THEN 'Heartcloud'
		WHEN tx.CPT_CODE in ('95250', '95251', '95249') THEN 'CGM' END as TransactionGLType

FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].ARPB_TRANSACTIONS tx 
	INNER JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].CLARITY_TDL_TRAN tdl ON tx.TX_ID = tdl.TX_ID 
																		--AND tdl.DETAIL_TYPE <> 10 /*Voided charges are handled in WHERE clause*/
																		AND TDL.DETAIL_TYPE IN (1,10,21)
																		AND tdl.DETAIL_TYPE < 40 /*Only Include New and Matching transaction types*/
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].[ZC_TRAN_TYPE] t ON t.TRAN_TYPE = tx.TX_TYPE_C
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].[ARPB_TX_MODERATE] tm ON tm.TX_ID = tx.TX_ID
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].[HSP_ACCOUNT] a ON a.HSP_ACCOUNT_ID = tm.HOSP_ACCT_ID
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].[CLARITY_EAP] eap1 ON eap1.PROC_ID = tx.PROC_ID
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].[CLARITY_EAP] eap2 ON eap2.PROC_ID = case when tdl.DETAIL_TYPE IN (21) then tdl.MATCH_PROC_ID else tdl.PROC_ID end
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].[CL_UB_REV_CODE] rc ON rc.UB_REV_CODE_ID = eap1.UB_REV_CODE_ID
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].CLARITY_POS pos ON pos.POS_ID = tx.POS_ID
	LEFT JOIN [HPIDW].[stg].[PBProcedureCodeCategories] pc on tx.CPT_CODE = pc.[ProcedureCode]
WHERE 1=1 
	AND tx.SERVICE_AREA_ID in (425,430)
	AND tx.TX_TYPE_C = 1 /*Charges*/
	--AND tx.VOID_DATE is null /*Exclude voided charges --removed on 5/19 as voided charges may need to be included*/
	AND tdl.TDL_ID IS NOT NULL 
	AND tdl.POST_DATE >= DATEADD(DAY,-@DaysToReload, convert(date,GETDATE())) /*Only load transactions from the last 10 days*/

 /*PB Transactions - Payments*/
UNION ALL 

select
'5' as TransactionDatasourceID
	,CONCAT('PB~',CASE WHEN tdl.TransactionParentSourceID IS NOT NULL THEN concat(tdl.TransactionParentSourceID,'~') END
				 ,tdl.TransactionSourceID
				 ) as TransactionSourceID
	,CONCAT('PB~',ISNULL(tdl.TransactionParentSourceID,tdl.TransactionSourceID)) AS TransactionParentSourceID
	,CASE WHEN tm.HOSP_ACCT_ID is not null THEN CONCAT('5~',tm.HOSP_ACCT_ID) END as TransactionVisitID
	,CASE WHEN tm.HOSP_ACCT_ID is not null THEN CONCAT('5~',tm.HOSP_ACCT_ID) END as TransactionAccountID
	,CASE WHEN tx.PAT_ENC_CSN_ID is not null THEN CONCAT('5~',tx.PAT_ENC_CSN_ID)
		  WHEN tx.ENC_FORM_NUM is not null THEN CONCAT('5~',tx.ENC_FORM_NUM) 
		  WHEN tdl.TransactionEncounterID is not null THEN CONCAT('5~',tdl.TransactionEncounterID) END  as TransactionEncounterID
	,CASE WHEN tdl.TransactionDepartmentID is not null THEN CONCAT('5~',tdl.TransactionDepartmentID) END as TransactionDepartmentID
	,CASE WHEN tx.PAYOR_ID IS NOT NULL THEN CONCAT('5~',tx.PAYOR_ID)
		  WHEN tx.ORIGINAL_FC_C = 4 and tx.PAYOR_ID is null THEN '5~0' /*Hard-code selfpay when financial class is self pay*/
		  WHEN COALESCE(tdl.TransactionCurrentPayorID,tx.PAYOR_ID, tx.ORIGINAL_EPM_ID, a.PRIMARY_PAYOR_ID) is not null THEN CONCAT('5~',COALESCE(tdl.TransactionCurrentPayorID,tx.PAYOR_ID, tx.ORIGINAL_EPM_ID, a.PRIMARY_PAYOR_ID)) END as TransactionPayerID
	,CASE WHEN tdl.TransactionBillingProvider is not null THEN CONCAT('5~',tdl.TransactionBillingProvider) END as TransactionBillingProviderID
	,'PB' as TransactionBillingType
	,tdl.TransactionType as TransactionType
	,tdl.TransactionSubtype as TransactionSubType
	,CASE WHEN LEFT(rc.REVENUE_CODE,1) = '0' THEN RIGHT(rc.REVENUE_CODE,3) ELSE rc.REVENUE_CODE END as TransactionRevenueCode
	,rc.BILL_DESC as TransactionRevenueCodeDescription
	,eap2.PROC_CODE as TransactionCode
	,COALESCE(eap2.BILL_DESC, eap2.PROC_NAME) as TransactionDescription
	,NULL as TransactionCPTCode
	,NULL as TransactionModifier1
	,NULL as TransactionModifier2
	,NULL as TransactionModifier3
	,NULL as TransactionModifier4
	,tdl.TransactionUnits as TransactionUnits
	,tdl.TransactionAmount as TransactionAmount
	,NULL as TransactionRVU
	,tdl.TransactionOriginalServiceDate as TransactionDateOfService
	,tdl.TransactionPostDate as TransactionDateOfPosting
	,tx.POST_DATE as TransactionDateOfBilling
	,tx.VOID_DATE as TransactionDateOfVoid
	,CONCAT(YEAR(tdl.TransactionPostDate),' - ', RIGHT(concat('00',MONTH(tdl.TransactionPostDate)),2)) as TransactionReportingPeriodID
	,CASE WHEN tx.VOID_DATE is null THEN 'Active' ELSE 'Voided' END as TransactionStatus 
	,1 as TransactionIsActive
	,GETDATE() as TransactionUpdatedDatetime
	,NULL AS TransactionCPTDescription
	,NULL AS TransactionPlaceOfServiceCode
	,NULL AS TransactionPlaceOfServiceType
	,null as TransactionGLType
from (
	select 
	t.TDL_ID
	,CASE WHEN t.DETAIL_TYPE IN (2,5,11,32,33) THEN t.TX_ID 
		  WHEN t.DETAIL_TYPE IN (20,22) THEN t.MATCH_TRX_ID END as TransactionSourceID
	,CASE WHEN t.DETAIL_TYPE IN (2,5) THEN NULL
	      WHEN t.DETAIL_TYPE IN (11,32,33) THEN t.TX_ID
		  WHEN t.DETAIL_TYPE IN (20,22) THEN t.TX_ID END as TransactionParentSourceID
	,COALESCE(ar.PAT_ENC_CSN_ID,ar.ENC_FORM_NUM) as TransactionEncounterID
	,'Payment' as TransactionType
	,CASE WHEN t.DETAIL_TYPE IN (2) THEN 'Payment - New'
	     WHEN t.DETAIL_TYPE IN (5) THEN 'Payment - Reversal'
		 WHEN t.DETAIL_TYPE IN (11) THEN 'Payment - Void'
		 WHEN t.DETAIL_TYPE IN (32,33) THEN 'Payment - Distributed'
		 WHEN t.DETAIL_TYPE IN (20) THEN 'Payment - Matched to Charge' 
		 WHEN t.DETAIL_TYPE IN (22) THEN 'Payment - Matched to Debit Adj'END as TransactionSubtype
	,t.PROCEDURE_QUANTITY as TransactionUnits
	,t.AMOUNT as TransactionAmount
	,t.PATIENT_AMOUNT as PatientAmount
	,t.INSURANCE_AMOUNT as InsuranceAmount
	--,CASE WHEN t.DETAIL_TYPE IN (2,11,32,33) THEN t.ORIG_POST_DATE 
	--	  WHEN t.DETAIL_TYPE IN (20,22) THEN t.POST_DATE END as TransactionPostDate
	,t.POST_DATE as TransactionPostDate
	,t.ORIG_POST_DATE as TransactionOriginalPostDate
	,t.DEPT_ID as TransactionDepartmentID
	,t.BILLING_PROVIDER_ID as TransactionBillingProvider
	,t.CUR_PAYOR_ID as TransactionCurrentPayorID
	,t.ORIG_SERVICE_DATE as TransactionOriginalServiceDate
	from [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].CLARITY_TDL_TRAN t
		LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].ZC_DETAIL_TYPE dt ON dt.DETAIL_TYPE = t.DETAIL_TYPE
		LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].ARPB_TRANSACTIONS ar ON ar.TX_ID = t.TX_ID
	where 1=1
	and t.SERV_AREA_ID IN (425,430)
	AND t.POST_DATE >= DATEADD(DAY,-@DaysToReload, convert(date,GETDATE())) /*Only load transactions from the last 10 days*/
	and t.DETAIL_TYPE IN (2,5,11,20,22,32,33)
	--and t.DEPT_ID = 42501006001
	--and (t.TX_ID = 65970994 or t.MATCH_TRX_ID = 65970994)
	--order by TransactionSourceID, TransactionPostDate
	) tdl
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].ARPB_TRANSACTIONS tx ON tx.TX_ID = tdl.TransactionSourceID
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].[ARPB_TX_MODERATE] tm ON tm.TX_ID = tdl.TransactionSourceID
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].[HSP_ACCOUNT] a ON a.HSP_ACCOUNT_ID = tm.HOSP_ACCT_ID
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].[CLARITY_EAP] eap1 ON eap1.PROC_ID = tx.PROC_ID
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].[CLARITY_EAP] eap2 ON eap2.PROC_ID = tx.PROC_ID
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].[CL_UB_REV_CODE] rc ON rc.UB_REV_CODE_ID = eap1.UB_REV_CODE_ID

/*PB Transactions - Debit Adjustments*/
UNION ALL 

select
'5' as TransactionDatasourceID
	,CONCAT('PB~',CASE WHEN tdl.TransactionParentSourceID IS NOT NULL THEN concat(tdl.TransactionParentSourceID,'~') END
				 ,tdl.TransactionSourceID
				 ) as TransactionSourceID
	,CONCAT('PB~',ISNULL(tdl.TransactionParentSourceID,tdl.TransactionSourceID)) AS TransactionParentSourceID
	,CASE WHEN tm.HOSP_ACCT_ID is not null THEN CONCAT('5~',tm.HOSP_ACCT_ID) END as TransactionVisitID
	,CASE WHEN tm.HOSP_ACCT_ID is not null THEN CONCAT('5~',tm.HOSP_ACCT_ID) END as TransactionAccountID
	,CASE WHEN tx.PAT_ENC_CSN_ID is not null THEN CONCAT('5~',tx.PAT_ENC_CSN_ID)
		  WHEN tx.PAT_ENC_CSN_ID is null THEN CONCAT('5~',tx.ENC_FORM_NUM) END  as TransactionEncounterID
	,CASE WHEN tdl.TransactionDepartmentID is not null THEN CONCAT('5~',tdl.TransactionDepartmentID) END as TransactionDepartmentID
	,CASE WHEN tx.PAYOR_ID IS NOT NULL THEN CONCAT('5~',tx.PAYOR_ID)
		  WHEN tx.ORIGINAL_FC_C = 4 and tx.PAYOR_ID is null THEN '5~0' /*Hard-code selfpay when financial class is self pay*/
		  WHEN COALESCE(tdl.TransactionCurrentPayorID,tx.PAYOR_ID, tx.ORIGINAL_EPM_ID, a.PRIMARY_PAYOR_ID) is not null THEN CONCAT('5~',COALESCE(tdl.TransactionCurrentPayorID,tx.PAYOR_ID, tx.ORIGINAL_EPM_ID, a.PRIMARY_PAYOR_ID)) END as TransactionPayerID
	,CASE WHEN tdl.TransactionBillingProvider is not null THEN CONCAT('5~',tdl.TransactionBillingProvider) END as TransactionBillingProviderID
	,'PB' as TransactionBillingType
	,tdl.TransactionType as TransactionType
	,tdl.TransactionSubtype as TransactionSubType
	,CASE WHEN LEFT(rc.REVENUE_CODE,1) = '0' THEN RIGHT(rc.REVENUE_CODE,3) ELSE rc.REVENUE_CODE END as TransactionRevenueCode
	,rc.BILL_DESC as TransactionRevenueCodeDescription
	,eap2.PROC_CODE as TransactionCode
	,COALESCE(eap2.BILL_DESC, eap2.PROC_NAME) as TransactionDescription
	,NULL as TransactionCPTCode
	,NULL as TransactionModifier1
	,NULL as TransactionModifier2
	,NULL as TransactionModifier3
	,NULL as TransactionModifier4
	,tdl.TransactionUnits as TransactionUnits
	,tdl.TransactionAmount as TransactionAmount
	,NULL as TransactionRVU
	,tdl.TransactionOriginalServiceDate as TransactionDateOfService
	,tdl.TransactionPostDate as TransactionDateOfPosting
	,tx.POST_DATE as TransactionDateOfBilling
	,tx.VOID_DATE as TransactionDateOfVoid
	,CONCAT(YEAR(tdl.TransactionPostDate),' - ', RIGHT(concat('00',MONTH(tdl.TransactionPostDate)),2)) as TransactionReportingPeriodID
	,CASE WHEN tx.VOID_DATE is null THEN 'Active' ELSE 'Voided' END as TransactionStatus 
	,1 as TransactionIsActive
	,GETDATE() as TransactionUpdatedDatetime
	,NULL AS TransactionCPTDescription
	,NULL AS TransactionPlaceOfServiceCode
	,NULL as TransactionPlaceOfServiceType
	,null as TransactionGLType
from (
	select 
	t.TDL_ID
	,CASE WHEN t.DETAIL_TYPE IN (3,12) THEN t.TX_ID 
		  WHEN t.DETAIL_TYPE IN (23) THEN t.MATCH_TRX_ID END as TransactionSourceID
	,CASE WHEN t.DETAIL_TYPE IN (3) THEN NULL
	      WHEN t.DETAIL_TYPE IN (12) THEN t.TX_ID
		  WHEN t.DETAIL_TYPE IN (23) THEN t.TX_ID END as TransactionParentSourceID
	,'Adjustment' as TransactionType
	,CASE WHEN t.DETAIL_TYPE IN (3) THEN 'Debit Adjustment - New'
		 WHEN t.DETAIL_TYPE IN (12) THEN 'Debit Adjustment - Void'
		 WHEN t.DETAIL_TYPE in (23) THEN 'Credit Adjustment - Matched to Debit Adjustment'
		END as TransactionSubtype
	,t.PROCEDURE_QUANTITY as TransactionUnits
	,t.AMOUNT as TransactionAmount
	,t.PATIENT_AMOUNT as PatientAmount
	,t.INSURANCE_AMOUNT as InsuranceAmount
	--,CASE WHEN t.DETAIL_TYPE IN (2,11,32,33) THEN t.ORIG_POST_DATE 
	--	  WHEN t.DETAIL_TYPE IN (20,22) THEN t.POST_DATE END as TransactionPostDate
	,t.POST_DATE as TransactionPostDate
	,t.ORIG_POST_DATE as TransactionOriginalPostDate
	,t.DEPT_ID as TransactionDepartmentID
	,t.BILLING_PROVIDER_ID as TransactionBillingProvider
	,t.CUR_PAYOR_ID as TransactionCurrentPayorID
	,t.ORIG_SERVICE_DATE as TransactionOriginalServiceDate
	from [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].CLARITY_TDL_TRAN t
		LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].ZC_DETAIL_TYPE dt ON dt.DETAIL_TYPE = t.DETAIL_TYPE
	where 1=1
	and t.SERV_AREA_ID IN (425,430)
	AND t.POST_DATE >= DATEADD(DAY,-@DaysToReload, convert(date,GETDATE())) /*Only load transactions from the last 10 days*/
	and t.DETAIL_TYPE IN (3,12,23)
	--and t.DEPT_ID = 42501006001
	--and (t.TX_ID = 65970994 or t.MATCH_TRX_ID = 65970994)
	) tdl
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].ARPB_TRANSACTIONS tx ON tx.TX_ID = tdl.TransactionSourceID
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].[ARPB_TX_MODERATE] tm ON tm.TX_ID = tdl.TransactionSourceID
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].[HSP_ACCOUNT] a ON a.HSP_ACCOUNT_ID = tm.HOSP_ACCT_ID
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].[CLARITY_EAP] eap1 ON eap1.PROC_ID = tx.PROC_ID
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].[CLARITY_EAP] eap2 ON eap2.PROC_ID = tx.PROC_ID
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].[CL_UB_REV_CODE] rc ON rc.UB_REV_CODE_ID = eap1.UB_REV_CODE_ID


END

*/
--select * from [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].ARPB_TRANSACTIONS tx where tx.TX_ID in (73350720,74091063,74077413)
--select * from [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].CLARITY_TDL_TRAN tdl where tdl.MATCH_TRX_ID in (73350720,74091063,74077413)
GO
