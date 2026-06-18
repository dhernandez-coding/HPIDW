--USE [HPIDW]
--GO

--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE [stg].[zzDEPRECATED_spEPICReloadFactTransactionsPBIncremental] as

-- =============================================
-- Author:		Chris Cross
-- Create date: 9/3/2024
-- Description:	Deletes and reloads all Epic PB Transactions
-- 10/28/2025 - Eric Silvestri - Added ICD10Dx codes to the charges
-- 1/27/2026 - Chris Cross - Revised substantially to remove unnecessary DETAIL_TYPEs (see zzDEPRECATED version for old logic)*/
-- =============================================

BEGIN
 
/*Step 1:  Load Staging Table with PB transactions...*/
Print 'Step 1:  Create Staging Table...'
DECLARE @DaysToReload int = 5
Print 'Setting Days To Reload:' + convert(varchar(10),@DaysToReload) + '...'



/* Load temporary table for Dx*/

	
IF OBJECT_ID('tempdb..#Temp_EPIC_Dx')  IS NOT NULL DROP TABLE #Temp_EPIC_Dx;

	CREATE TABLE #Temp_EPIC_Dx 
		(TransactionID varchar(100)							
		,ICD10_Dx_1 varchar(100)
		,ICD10_Dx_2 varchar(100)
		,ICD10_Dx_3 varchar(100)
		,ICD10_Dx_4 varchar(100)
		,ICD10_Dx_5 varchar(100)
		)

	INSERT INTO #Temp_EPIC_Dx														
	SELECT
	*
	FROM OPENQUERY([CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM],'
	SELECT 				
		t.TX_ID as TransactionID						
		,dx1.EXTERNAL_ID as ICD10_Dx_1						
		,dx2.EXTERNAL_ID as ICD10_Dx_2					
		,dx3.EXTERNAL_ID as ICD10_Dx_3						
		,dx4.EXTERNAL_ID as ICD10_Dx_4						
		,dx5.EXTERNAL_ID as ICD10_Dx_5		
	FROM [CLARITY].[ORGFILTER].CLARITY_TDL_TRAN t 							
		LEFT JOIN [CLARITY].[ORGFILTER].CLARITY_EDG dx1 ON dx1.DX_ID = t.DX_ONE_ID						
		LEFT JOIN [CLARITY].[ORGFILTER].CLARITY_EDG dx2 ON dx2.DX_ID = t.DX_TWO_ID						
		LEFT JOIN [CLARITY].[ORGFILTER].CLARITY_EDG dx3 ON dx3.DX_ID = t.DX_THREE_ID						
		LEFT JOIN [CLARITY].[ORGFILTER].CLARITY_EDG dx4 ON dx4.DX_ID = t.DX_FOUR_ID						
		LEFT JOIN [CLARITY].[ORGFILTER].CLARITY_EDG dx5 ON dx5.DX_ID = t.DX_FIVE_ID						
		--INNER JOIN #TEMP_EPIC_Transactions tv ON tv.TransactionID = t.TX_ID						
	WHERE 1=1							
		AND t.DETAIL_TYPE = 1
		AND t.POST_DATE >= DATEADD(DAY,-5, convert(date,GETDATE()))
	')


DROP TABLE IF EXISTS #Staging
CREATE TABLE #Staging 
	([TransactionID] varchar(100) primary key NOT NULL,
	[TransactionDatasourceID] [int] NULL,
	[TransactionSourceID] [varchar](100) NULL,
	[TransactionParentSourceID] [varchar](100) NULL,
	[TransactionVisitID] [varchar](100) NULL,
	[TransactionAccountID] [varchar](100) NULL,
	[TransactionDepartmentID] [varchar](100) NULL,
	[TransactionPayerID] [varchar](100) NULL,
	[TransactionBillingProviderID] [varchar](100) NULL,
	[TransactionBillingType] [varchar](100) NULL,
	[TransactionType] [varchar](100) NULL,
	[TransactionSubType] [varchar](100) NULL,
	[TransactionRevenueCode] [varchar](100) NULL,
	[TransactionRevenueCodeDescription] [varchar](1000) NULL,
	[TransactionCode] [varchar](100) NULL,
	[TransactionDescription] [varchar](1000) NULL,
	[TransactionCPTCode] [varchar](100) NULL,
	[TransactionCPTDescription] [varchar](1000) NULL,
	[TransactionModifier1] [varchar](50) NULL,
	[TransactionModifier2] [varchar](50) NULL,
	[TransactionModifier3] [varchar](50) NULL,
	[TransactionModifier4] [varchar](50) NULL,
	[TransactionICD10Dx1] [varchar](50) NULL,					
	[TransactionICD10Dx2] [varchar](50) NULL,					
	[TransactionICD10Dx3] [varchar](50) NULL,					
	[TransactionICD10Dx4] [varchar](50) NULL,					
	[TransactionICD10Dx5] [varchar](50) NULL,
	[TransactionUnits] [decimal](10, 2) NULL,
	[TransactionActiveARAmount] money null,
	[TransactionAmount] [money] NULL,
	[TransactionRVU] [decimal](18, 2) NULL,
	[TransactionDateOfService] [datetime] NULL,
	[TransactionDateOfPosting] [datetime] NULL,
	[TransactionDateOfBilling] [datetime] NULL,
	[TransactionDateOfVoid] [datetime] NULL,
	[TransactionReportingPeriodID] [varchar](100) NULL,
	[TransactionPlaceOfServiceCode] [varchar](50) NULL,
	[TransactionPlaceOfServiceType] [varchar](100) NULL,
	[TransactionPatientID] [varchar](50) NULL,
	[TransactionGLType] [varchar](10) NULL,
	[TransactionStatus] [varchar](100) NULL,
	[TransactionIsActive] [bit] NULL,
	[TransactionUpdatedDateTime] [date] NULL,
	[TransactionPayerPlanID] varchar(50) NULL,
	[TransactionPlaceOfService] varchar(100) NULL
	)

/*Load Charges into #Staging*/
	Print 'Step 1.1:  Loading Charges and Credit Adjustments into #Staging...'
	INSERT INTO #Staging
	([TransactionID]
      ,[TransactionDatasourceID]
      ,[TransactionSourceID]
      ,[TransactionParentSourceID]
      ,[TransactionVisitID]
      ,[TransactionAccountID]
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
      ,[TransactionCPTDescription]
      ,[TransactionModifier1]
      ,[TransactionModifier2]
      ,[TransactionModifier3]
      ,[TransactionModifier4]
	  ,[TransactionICD10Dx1]					
	  ,[TransactionICD10Dx2]					
	  ,[TransactionICD10Dx3]					
	  ,[TransactionICD10Dx4]					
	  ,[TransactionICD10Dx5]
      ,[TransactionUnits]
	  ,[TransactionActiveARAmount]
      ,[TransactionAmount]
      ,[TransactionRVU]
      ,[TransactionDateOfService]
      ,[TransactionDateOfPosting]
      ,[TransactionDateOfBilling]
      ,[TransactionDateOfVoid]
      ,[TransactionReportingPeriodID]
      ,[TransactionPlaceOfServiceCode]
      ,[TransactionPlaceOfServiceType]
      ,[TransactionPatientID]
      ,[TransactionGLType]
      ,[TransactionStatus]
      ,[TransactionIsActive]
      ,[TransactionUpdatedDateTime]
	  ,[TransactionPayerPlanID]
	  ,[TransactionPlaceOfService]
	)

SELECT
	CONCAT('5~',tx.TX_ID
				,CASE WHEN tx.MATCH_TRX_ID IS NOT NULL THEN CONCAT('~',tx.MATCH_TRX_ID,'~',tx.TDL_ID) END
				,CASE WHEN tx.DETAIL_TYPE = 10 THEN CONCAT('~','VOID') END) as TransactionID
		,'5' as TransactionDatasourceID
		,CONCAT(tx.TX_ID
				,CASE WHEN tx.MATCH_TRX_ID IS NOT NULL THEN CONCAT('~',tx.MATCH_TRX_ID,'~',tx.TDL_ID) END
				,CASE WHEN tx.DETAIL_TYPE = 10 THEN CONCAT('~','VOID') END) as TransactionSourceID
		,tx.TX_ID AS TransactionParentSourceID
		,CASE WHEN tx.PAT_ENC_CSN_ID is not null THEN CONCAT('5~',tx.PAT_ENC_CSN_ID)
			  WHEN tx.PAT_ENC_CSN_ID is null THEN CONCAT('5~',tx.ENC_FORM_NUM) END as TransactionVisitID
		,CASE WHEN tx.HOSP_ACCT_ID is not null THEN CONCAT('5~',tx.HOSP_ACCT_ID) END as TransactionAccountID
		,CASE WHEN tx.DEPT_ID is not null THEN CONCAT('5~',tx.DEPT_ID) END as TransactionDepartmentID
		,CASE WHEN tx.ORIGINAL_FC_C = 4 and tx.CUR_PAYOR_ID is null THEN '5~0' /*Hard-code selfpay when financial class is self pay*/
			  WHEN COALESCE(tx.ORIGINAL_PAYOR_ID,tx.CUR_PAYOR_ID,tx.ORIGINAL_EPM_ID, tx.PAYOR_ID, tx.PRIMARY_PAYOR_ID) is not null THEN CONCAT('5~',COALESCE(tx.ORIGINAL_PAYOR_ID,tx.CUR_PAYOR_ID,tx.ORIGINAL_EPM_ID, tx.PAYOR_ID,tx.PRIMARY_PAYOR_ID)) END as TransactionPayerID
		
		,CASE WHEN COALESCE(tx.tdlBILLING_PROVIDER_ID,tx.txBILLING_PROV_ID,tx.SERV_PROVIDER_ID) is not null THEN CONCAT('5~',COALESCE(tx.tdlBILLING_PROVIDER_ID,tx.txBILLING_PROV_ID,tx.SERV_PROVIDER_ID)) END as TransactionBillingProviderID
		,'PB' as TransactionBillingType
		,CASE WHEN tx.MATCH_TX_TYPE IS NULL AND tx.TX_TYPE_C = 1 THEN 'Charge'
			  --WHEN tx.MATCH_TX_TYPE = 2 THEN 'Payment'
			  WHEN tx.MATCH_TX_TYPE = 3 THEN 'Adjustment' END as TransactionType
		,CASE WHEN tx.DETAIL_TYPE = 1 THEN 'Charge - New'
			   WHEN tx.DETAIL_TYPE = 10 then 'Charge - Void'
			   --WHEN tx.DETAIL_TYPE = 20 THEN 'Payment - Regular'
			   WHEN tx.DETAIL_TYPE = 21 THEN 'Credit Adjustment - Matched to Charge'
			   --WHEN tx.DETAIL_TYPE = 30 THEN 'Credit Adjustment to Charge'
			   --WHEN tx.DETAIL_TYPE = 31 THEN 'Credit Adjustemnt to Debit Adjustment'
			   --WHEN tx.DETAIL_TYPE = 32 THEN 'Payment to Charge'
			   --WHEN tx.DETAIL_TYPE = 33 THEN 'Payment to Debit Adjustment'
			   ELSE CONVERT(VARCHAR,tx.DETAIL_TYPE)
			   END as TransactionSubType
		,CASE WHEN LEFT(tx.REVENUE_CODE,1) = '0' THEN RIGHT(tx.REVENUE_CODE,3) ELSE tx.REVENUE_CODE END as TransactionRevenueCode
		,tx.rcBILL_DESC as TransactionRevenueCodeDescription
		,tx.PROC_CODE as TransactionCode
		,COALESCE(tx.eap2BILL_DESC, tx.PROC_NAME) as TransactionDescription
		,tx.CPT_CODE as TransactionCPTCode
		,COALESCE(tx.eap2BILL_DESC, tx.PROC_NAME) as TransactionCPTDescription
		,CASE WHEN tx.DETAIL_TYPE in (1,10) THEN tx.MODIFIER_ONE END as TransactionModifier1
		,CASE WHEN tx.DETAIL_TYPE in (1,10) THEN tx.MODIFIER_TWO END as TransactionModifier2
		,CASE WHEN tx.DETAIL_TYPE in (1,10) THEN tx.MODIFIER_THREE END as TransactionModifier3
		,CASE WHEN tx.DETAIL_TYPE in (1,10) THEN tx.MODIFIER_FOUR END as TransactionModifier4
		,max(dx.ICD10_Dx_1) as TransactionICD10Dx1					
		,max(dx.ICD10_Dx_2) as TransactionICD10Dx2					
		,max(dx.ICD10_Dx_3) as TransactionICD10Dx3					
		,max(dx.ICD10_Dx_4) as TransactionICD10Dx4					
		,max(dx.ICD10_Dx_5) as TransactionICD10Dx5	
		,tx.PROCEDURE_QUANTITY as TransactionUnits
		,tx.ACTIVE_AR_AMOUNT as TransactionActiveARAmount 
		,tx.AMOUNT as TransactionAmount
		,tx.RELATIVE_VALUE_UNIT as TransactionRVU
		,tx.ORIG_SERVICE_DATE as TransactionDateOfService
		,tx.tdlPOST_DATE as TransactionDateOfPosting
		,tx.txPOST_DATE as TransactionDateOfBilling
		,tx.VOID_DATE as TransactionDateOfVoid
		,CONCAT(YEAR(tdlPOST_DATE),' - ', RIGHT(concat('00',MONTH(tx.tdlPOST_DATE)),2)) as TransactionReportingPeriodID
		,tx.POS_CODE AS TransactionPlaceOfServiceCode
		,tx.POS_TYPE as TransactionPlaceOfServiceType
		,CASE WHEN tx.INT_PAT_ID IS NOT NULL THEN CONCAT('5~',tx.INT_PAT_ID) END as TransactionPatientID
		,CASE --WHEN tx.[Appt_Type_Abbr] in ('SB','SB GWILL') or tx.[Appt_Resource_Descr] like '%smartbeat%' and tx.CPT_CODE in ('92250','93000','93308','93321','93325','93882','93922','93979','94010') THEN 'Smartbeat'
			WHEN tx.CPT_CODE in ('MPDC', '93922') THEN 'MaxPulse'
			WHEN tx.DETAIL_TYPE = 1 and tx.CPT_CODE like '7%' and (tx.MODIFIER_ONE = 'TC' OR tx.MODIFIER_TWO = 'TC') THEN 'RadTC'
			WHEN pc.[ProcedureCodeCategory] = 'XRAY Only Visits' THEN 'Xray'
			WHEN pc.[ProcedureCodeServiceLine] = 'DME' THEN 'DME'
			WHEN pc.[ProcedureCodeCategory] = 'Ultrasound Only Visit' THEN 'Ultrasound' 
			WHEN pc.[ProcedureCodeCategory] = 'Lab Only Visit' THEN 'Lab' 
			--WHEN (tx.[Appt_Type_Abbr] = 'ANS GWIL' or tx.[Appt_Resource_Descr] = 'AUTONOMIC NERVE TESTING-GWIL') and (tx.[Patient_ID] is not null) and (tx.[Appt_Status] <> 'X' and tx.[Appt_Status] <> 'N')  THEN 'ANS'  
			WHEN tx.CPT_CODE in ('51729', '51797', '51784', '51741') THEN 'URO'  
			WHEN tx.CPT_CODE in ('99453', '99454', '99457', '99458', '95249', '95250', '95251') THEN 'Heartcloud'
			WHEN tx.CPT_CODE in ('95250', '95251', '95249') THEN 'CGM' END as TransactionGLType
		,CASE WHEN tx.VOID_DATE is null THEN 'Active' ELSE 'Voided' END as TransactionStatus 
		,1 as TransactionIsActive 
		,GETDATE() as TransactionUpdatedDatetime
		,CASE WHEN tx.ORIGINAL_FC_C = 4 and tx.CUR_PAYOR_ID is null THEN '5~0' /*Hard-code selfpay when financial class is self pay*/
			  WHEN COALESCE(tx.ORIGINAL_PLAN_ID,tx.CUR_PLAN_ID) is not null THEN CONCAT('5~',COALESCE(tx.ORIGINAL_PLAN_ID,tx.CUR_PLAN_ID)) END as TransactionPayerPlanID
		,tx.POS_NAME as TransactionPlaceOfService
FROM OPENQUERY([CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM],'
	SELECT
		tx.TX_ID
		,tdl.MATCH_TRX_ID 
		,tdl.TDL_ID
		,tx.PAT_ENC_CSN_ID
		,tx.ENC_FORM_NUM
		,tm.HOSP_ACCT_ID
		,tdl.DEPT_ID 
		,tdl.ORIGINAL_PAYOR_ID
		,tdl.CUR_PAYOR_ID
		,tx.ORIGINAL_EPM_ID
		,tx.PAYOR_ID
		,a.PRIMARY_PAYOR_ID
		,tdl.BILLING_PROVIDER_ID as tdlBILLING_PROVIDER_ID
		,tx.BILLING_PROV_ID as txBILLING_PROV_ID
		,tx.SERV_PROVIDER_ID
		,tx.TX_TYPE_C
		,tdl.MATCH_TX_TYPE
		,rc.REVENUE_CODE
		,rc.BILL_DESC as rcBILL_DESC
		,eap2.PROC_CODE 
		,tx.CPT_CODE 
		,eap2.BILL_DESC as eap2BILL_DESC
		,eap2.PROC_NAME
		,tx.MODIFIER_ONE 
		,tx.MODIFIER_TWO 
		,tx.MODIFIER_THREE
		,tx.MODIFIER_FOUR
		,NULL AS TransactionICD10Dx1 --max(dx.ICD10_Dx_1) as TransactionICD10Dx1					
		,NULL AS TransactionICD10Dx2 --max(dx.ICD10_Dx_2) as TransactionICD10Dx2					
		,NULL AS TransactionICD10Dx3 --max(dx.ICD10_Dx_3) as TransactionICD10Dx3					
		,NULL AS TransactionICD10Dx4 --max(dx.ICD10_Dx_4) as TransactionICD10Dx4					
		,NULL AS TransactionICD10Dx5 --max(dx.ICD10_Dx_5) as TransactionICD10Dx5	
		,tdl.PROCEDURE_QUANTITY
		,tdl.AMOUNT 
		,tdl.ACTIVE_AR_AMOUNT
		,tdl.RELATIVE_VALUE_UNIT 
		,tdl.ORIG_SERVICE_DATE
		,tdl.POST_DATE AS tdlPOST_DATE
		,tx.POST_DATE AS txPOST_DATE
		,tx.VOID_DATE 
		,pos.POS_CODE
		,pos.POS_TYPE
		,tdl.INT_PAT_ID 
		,tdl.DETAIL_TYPE
		,tx.ORIGINAL_FC_C 
		,tdl.ORIGINAL_PLAN_ID
		,tdl.CUR_PLAN_ID
		,pos.POS_NAME 
	FROM [Clarity].[ORGFILTER].ARPB_TRANSACTIONS tx 
		INNER JOIN [Clarity].[ORGFILTER].CLARITY_TDL_TRAN tdl ON tx.TX_ID = tdl.TX_ID 
																			--AND tdl.DETAIL_TYPE <> 10 /*Voided charges are handled in WHERE clause*/
																			AND TDL.DETAIL_TYPE IN (1,10,21)
																			AND tdl.DETAIL_TYPE < 40 /*Only Include New and Matching transaction types*/
		LEFT JOIN [Clarity].[ORGFILTER].[ZC_TRAN_TYPE] t ON t.TRAN_TYPE = tx.TX_TYPE_C
		LEFT JOIN [Clarity].[ORGFILTER].[ARPB_TX_MODERATE] tm ON tm.TX_ID = tx.TX_ID
		LEFT JOIN [Clarity].[ORGFILTER].[HSP_ACCOUNT] a ON a.HSP_ACCOUNT_ID = tm.HOSP_ACCT_ID
		LEFT JOIN [Clarity].[ORGFILTER].[CLARITY_EAP] eap1 ON eap1.PROC_ID = tx.PROC_ID
		LEFT JOIN [Clarity].[ORGFILTER].[CLARITY_EAP] eap2 ON eap2.PROC_ID = case when tdl.DETAIL_TYPE IN (21) then tdl.MATCH_PROC_ID else tdl.PROC_ID end
		LEFT JOIN [Clarity].[ORGFILTER].[CL_UB_REV_CODE] rc ON rc.UB_REV_CODE_ID = eap1.UB_REV_CODE_ID
		LEFT JOIN [Clarity].[ORGFILTER].CLARITY_POS pos ON pos.POS_ID = tx.POS_ID
	WHERE 1=1 
		AND tx.SERVICE_AREA_ID in (425,430)
		AND tx.TX_TYPE_C = 1 /*Charges*/
		--AND tx.VOID_DATE is null /*Exclude voided charges --removed on 5/19 as voided charges may need to be included*/
		AND tdl.TDL_ID IS NOT NULL 
		AND tdl.POST_DATE >= ''1/1/2019''
		AND tdl.POST_DATE >= DATEADD(DAY,-5, convert(date,GETDATE()))
	'
	) tx
	LEFT JOIN [HPIDW].[dim].[vPBProcedureCodeCategories] pc ON pc.ProcedureCode = COALESCE(tx.CPT_CODE,tx.PROC_CODE)
	LEFT JOIN #Temp_EPIC_Dx	dx on dx.TransactionID = tx.TX_ID
GROUP BY
    CONCAT('5~',tx.TX_ID,
           CASE WHEN tx.MATCH_TRX_ID IS NOT NULL THEN CONCAT('~',tx.MATCH_TRX_ID,'~',tx.TDL_ID) END,
           CASE WHEN tx.DETAIL_TYPE = 10 THEN CONCAT('~','VOID') END),
    CONCAT(tx.TX_ID,
           CASE WHEN tx.MATCH_TRX_ID IS NOT NULL THEN CONCAT('~',tx.MATCH_TRX_ID,'~',tx.TDL_ID) END,
           CASE WHEN tx.DETAIL_TYPE = 10 THEN CONCAT('~','VOID') END),
    tx.TX_ID,
    CASE WHEN tx.PAT_ENC_CSN_ID IS NOT NULL THEN CONCAT('5~',tx.PAT_ENC_CSN_ID)
         WHEN tx.PAT_ENC_CSN_ID IS NULL THEN CONCAT('5~',tx.ENC_FORM_NUM) END,
    CASE WHEN tx.HOSP_ACCT_ID IS NOT NULL THEN CONCAT('5~',tx.HOSP_ACCT_ID) END,
    CASE WHEN tx.DEPT_ID IS NOT NULL THEN CONCAT('5~',tx.DEPT_ID) END,
    CASE WHEN tx.ORIGINAL_FC_C = 4 AND tx.CUR_PAYOR_ID IS NULL THEN '5~0'
         WHEN COALESCE(tx.ORIGINAL_PAYOR_ID,tx.CUR_PAYOR_ID,tx.ORIGINAL_EPM_ID,tx.PAYOR_ID,tx.PRIMARY_PAYOR_ID) IS NOT NULL
              THEN CONCAT('5~',COALESCE(tx.ORIGINAL_PAYOR_ID,tx.CUR_PAYOR_ID,tx.ORIGINAL_EPM_ID,tx.PAYOR_ID,tx.PRIMARY_PAYOR_ID)) END,
    CASE WHEN COALESCE(tx.tdlBILLING_PROVIDER_ID,tx.txBILLING_PROV_ID,tx.SERV_PROVIDER_ID) IS NOT NULL
              THEN CONCAT('5~',COALESCE(tx.tdlBILLING_PROVIDER_ID,tx.txBILLING_PROV_ID,tx.SERV_PROVIDER_ID)) END,
    CASE WHEN tx.MATCH_TX_TYPE IS NULL AND tx.TX_TYPE_C = 1 THEN 'Charge'
         WHEN tx.MATCH_TX_TYPE = 3 THEN 'Adjustment' END,
    CASE WHEN tx.DETAIL_TYPE = 1 THEN 'Charge - New'
         WHEN tx.DETAIL_TYPE = 10 THEN 'Charge - Void'
         WHEN tx.DETAIL_TYPE = 21 THEN 'Credit Adjustment - Matched to Charge'
         ELSE CONVERT(varchar,tx.DETAIL_TYPE) END,
    CASE WHEN LEFT(tx.REVENUE_CODE,1) = '0' THEN RIGHT(tx.REVENUE_CODE,3) ELSE tx.REVENUE_CODE END,
    tx.rcBILL_DESC,
    tx.PROC_CODE,
    COALESCE(tx.eap2BILL_DESC, tx.PROC_NAME),
    tx.CPT_CODE,
    CASE WHEN tx.DETAIL_TYPE IN (1,10) THEN tx.MODIFIER_ONE END,
    CASE WHEN tx.DETAIL_TYPE IN (1,10) THEN tx.MODIFIER_TWO END,
    CASE WHEN tx.DETAIL_TYPE IN (1,10) THEN tx.MODIFIER_THREE END,
    CASE WHEN tx.DETAIL_TYPE IN (1,10) THEN tx.MODIFIER_FOUR END,
    tx.PROCEDURE_QUANTITY,
    tx.ACTIVE_AR_AMOUNT, 
	tx.AMOUNT,
    tx.RELATIVE_VALUE_UNIT,
    tx.ORIG_SERVICE_DATE,
    tx.tdlPOST_DATE,
    tx.txPOST_DATE,
    tx.VOID_DATE,
    CONCAT(YEAR(tx.tdlPOST_DATE),' - ',RIGHT(CONCAT('00',MONTH(tx.tdlPOST_DATE)),2)),
    tx.POS_CODE,
    tx.POS_TYPE,
    CASE WHEN tx.INT_PAT_ID IS NOT NULL THEN CONCAT('5~',tx.INT_PAT_ID) END,
    CASE
         WHEN tx.CPT_CODE IN ('MPDC','93922') THEN 'MaxPulse'
         WHEN tx.DETAIL_TYPE = 1 AND tx.CPT_CODE LIKE '7%' AND (tx.MODIFIER_ONE='TC' OR tx.MODIFIER_TWO='TC') THEN 'RadTC'
         WHEN pc.ProcedureCodeCategory='XRAY Only Visits' THEN 'Xray'
         WHEN pc.ProcedureCodeServiceLine='DME' THEN 'DME'
         WHEN pc.ProcedureCodeCategory='Ultrasound Only Visit' THEN 'Ultrasound'
         WHEN pc.ProcedureCodeCategory='Lab Only Visit' THEN 'Lab'
         WHEN tx.CPT_CODE IN ('51729','51797','51784','51741') THEN 'URO'
         WHEN tx.CPT_CODE IN ('99453','99454','99457','99458','95249','95250','95251') THEN 'Heartcloud'
         WHEN tx.CPT_CODE IN ('95250','95251','95249') THEN 'CGM' END,
    CASE WHEN tx.VOID_DATE IS NULL THEN 'Active' ELSE 'Voided' END,
    CASE WHEN tx.ORIGINAL_FC_C = 4 AND tx.CUR_PAYOR_ID IS NULL THEN '5~0'
         WHEN COALESCE(tx.ORIGINAL_PLAN_ID,tx.CUR_PLAN_ID) IS NOT NULL THEN CONCAT('5~',COALESCE(tx.ORIGINAL_PLAN_ID,tx.CUR_PLAN_ID)) END,
    tx.POS_NAME;


/*Load Payments and other adjustments into #Staging*/

	Print 'Step 1.2:  Loading Payments into #Staging...'
	INSERT INTO #Staging
	([TransactionID]
      ,[TransactionDatasourceID]
      ,[TransactionSourceID]
      ,[TransactionParentSourceID]
      ,[TransactionVisitID]
      ,[TransactionAccountID]
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
      ,[TransactionCPTDescription]
      ,[TransactionModifier1]
      ,[TransactionModifier2]
      ,[TransactionModifier3]
      ,[TransactionModifier4]
	  ,[TransactionICD10Dx1]					
	  ,[TransactionICD10Dx2]					
	  ,[TransactionICD10Dx3]					
	  ,[TransactionICD10Dx4]					
	  ,[TransactionICD10Dx5]
      ,[TransactionUnits]
	  ,[TransactionActiveARAmount]
      ,[TransactionAmount]
      ,[TransactionRVU]
      ,[TransactionDateOfService]
      ,[TransactionDateOfPosting]
      ,[TransactionDateOfBilling]
      ,[TransactionDateOfVoid]
      ,[TransactionReportingPeriodID]
      ,[TransactionPlaceOfServiceCode]
      ,[TransactionPlaceOfServiceType]
      ,[TransactionPatientID]
      ,[TransactionGLType]
      ,[TransactionStatus]
      ,[TransactionIsActive]
      ,[TransactionUpdatedDateTime]
	  ,[TransactionPayerPlanID]
	  ,[TransactionPlaceOfService]
	)

SELECT
	  tx.[TransactionID]
      ,tx.[TransactionDatasourceID]
      ,tx.[TransactionSourceID]
      ,tx.[TransactionParentSourceID]
      ,tx.[TransactionVisitID]
      ,tx.[TransactionAccountID]
      ,tx.[TransactionDepartmentID]
      ,tx.[TransactionPayerID]
      ,tx.[TransactionBillingProviderID]
      ,tx.[TransactionBillingType]
      ,tx.[TransactionType]
      ,tx.[TransactionSubType]
      ,tx.[TransactionRevenueCode]
      ,tx.[TransactionRevenueCodeDescription]
      ,tx.[TransactionCode]
      ,tx.[TransactionDescription]
      ,tx.[TransactionCPTCode]
      ,tx.[TransactionCPTDescription]
      ,tx.[TransactionModifier1]
      ,tx.[TransactionModifier2]
      ,tx.[TransactionModifier3]
      ,tx.[TransactionModifier4]
	  ,tx.[TransactionICD10Dx1]					
	  ,tx.[TransactionICD10Dx2]					
	  ,tx.[TransactionICD10Dx3]					
	  ,tx.[TransactionICD10Dx4]					
	  ,tx.[TransactionICD10Dx5]
      ,tx.[TransactionUnits]
	  ,tx.[TransactionActiveARAmount]
      ,tx.[TransactionAmount]
      ,tx.[TransactionRVU]
      ,tx.[TransactionDateOfService]
      ,tx.[TransactionDateOfPosting]
      ,tx.[TransactionDateOfBilling]
      ,tx.[TransactionDateOfVoid]
      ,tx.[TransactionReportingPeriodID]
      ,tx.[TransactionPlaceOfServiceCode]
      ,tx.[TransactionPlaceOfServiceType]
      ,tx.[TransactionPatientID]
      ,tx.[TransactionGLType]
      ,tx.[TransactionStatus]
      ,tx.[TransactionIsActive]
      ,tx.[TransactionUpdatedDateTime]
	  ,tx.[TransactionPayerPlanID]
	  ,tx.[TransactionPlaceOfService]
FROM OPENQUERY([CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM],
	'select
		CONCAT(''5~'',CASE WHEN tdl.TransactionParentSourceID IS NOT NULL THEN concat(tdl.TransactionParentSourceID,''~'') END
					 ,tdl.TransactionSourceID
					 ,CASE WHEN tdl.TransactionParentSourceID IS NOT NULL THEN concat(''~'',tdl.TransactionTDLID) END) as TransactionID
		,''5'' as TransactionDatasourceID
		,CONCAT(CASE WHEN tdl.TransactionParentSourceID IS NOT NULL THEN concat(tdl.TransactionParentSourceID,''~'') END
					 ,tdl.TransactionSourceID
					 ,CASE WHEN tdl.TransactionParentSourceID IS NOT NULL THEN concat(''~'',tdl.TransactionTDLID) END) as TransactionSourceID
		,ISNULL(tdl.TransactionParentSourceID,tdl.TransactionSourceID) AS TransactionParentSourceID
		,CASE WHEN tx.PAT_ENC_CSN_ID is not null THEN CONCAT(''5~'',tx.PAT_ENC_CSN_ID)
			  WHEN tx.ENC_FORM_NUM is not null THEN CONCAT(''5~'',tx.ENC_FORM_NUM) 
			  WHEN tdl.TransactionEncounterID is not null THEN CONCAT(''5~'',tdl.TransactionEncounterID) END  as TransactionVisitID
		,CASE WHEN tm.HOSP_ACCT_ID is not null THEN CONCAT(''5~'',tm.HOSP_ACCT_ID) END as TransactionAccountID
		,CASE WHEN tdl.TransactionDepartmentID is not null THEN CONCAT(''5~'',tdl.TransactionDepartmentID) END as TransactionDepartmentID
		,CASE WHEN tx.PAYOR_ID IS NOT NULL THEN CONCAT(''5~'',tx.PAYOR_ID)
			  WHEN tx.ORIGINAL_FC_C = 4 and tx.PAYOR_ID is null THEN ''5~0'' /*Hard-code selfpay when financial class is self pay*/
			  WHEN COALESCE(tx.PAYOR_ID, tx.ORIGINAL_EPM_ID, tdl.TransactionCurrentPayorID, a.PRIMARY_PAYOR_ID) is not null THEN CONCAT(''5~'',COALESCE(tx.PAYOR_ID, tx.ORIGINAL_EPM_ID, tdl.TransactionCurrentPayorID, a.PRIMARY_PAYOR_ID)) END as TransactionPayerID
		,CASE WHEN tdl.TransactionBillingProvider is not null THEN CONCAT(''5~'',tdl.TransactionBillingProvider) END as TransactionBillingProviderID
		,''PB'' as TransactionBillingType
		,tdl.TransactionType as TransactionType
		,tdl.TransactionSubtype as TransactionSubType
		,CASE WHEN LEFT(rc.REVENUE_CODE,1) = ''0'' THEN RIGHT(rc.REVENUE_CODE,3) ELSE rc.REVENUE_CODE END as TransactionRevenueCode
		,rc.BILL_DESC as TransactionRevenueCodeDescription
		,eap2.PROC_CODE as TransactionCode
		,COALESCE(eap2.BILL_DESC, eap2.PROC_NAME) as TransactionDescription
		,NULL as TransactionCPTCode
		,NULL AS TransactionCPTDescription
		,NULL as TransactionModifier1
		,NULL as TransactionModifier2
		,NULL as TransactionModifier3
		,NULL as TransactionModifier4
		,NULL as TransactionICD10Dx1					
		,NULL as TransactionICD10Dx2					
		,NULL as TransactionICD10Dx3					
		,NULL as TransactionICD10Dx4					
		,NULL as TransactionICD10Dx5
		,tdl.TransactionUnits as TransactionUnits
		,tdl.TransactionActiveARAmount as TransactionActiveARAmount
		,tdl.TransactionAmount as TransactionAmount
		,NULL as TransactionRVU
		,tdl.TransactionOriginalServiceDate as TransactionDateOfService
		,tdl.TransactionPostDate as TransactionDateOfPosting
		,tx.POST_DATE as TransactionDateOfBilling
		,tx.VOID_DATE as TransactionDateOfVoid
		,CONCAT(YEAR(tdl.TransactionPostDate),'' - '', RIGHT(concat(''00'',MONTH(tdl.TransactionPostDate)),2)) as TransactionReportingPeriodID
		,NULL AS TransactionPlaceOfServiceCode
		,NULL AS TransactionPlaceOfServiceType
		,CASE WHEN tdl.TransactionPatientID is not null THEN CONCAT(''5~'',tdl.TransactionPatientID) END as TransactionPatientID
		,null as TransactionGLType
		,CASE WHEN tx.VOID_DATE is null THEN ''Active'' ELSE ''Voided'' END as TransactionStatus 
		,1 as TransactionIsActive
		,GETDATE() as TransactionUpdatedDatetime
		,NULL as TransactionPayerPlanID
		,NULL as [TransactionPlaceOfService]
	from (
		select 
		t.TDL_ID as TransactionTDLID
		,CASE WHEN t.DETAIL_TYPE IN (2,5,11,33) THEN t.TX_ID 
			  WHEN t.DETAIL_TYPE IN (32,20,22) THEN t.MATCH_TRX_ID END as TransactionSourceID
		,CASE WHEN t.DETAIL_TYPE IN (2,5) THEN NULL
			  WHEN t.DETAIL_TYPE IN (11,32,33) THEN t.TX_ID
			  WHEN t.DETAIL_TYPE IN (20,22) THEN t.TX_ID END as TransactionParentSourceID
		,COALESCE(ar.PAT_ENC_CSN_ID,ar.ENC_FORM_NUM) as TransactionEncounterID
		,''Payment'' as TransactionType
		,CASE WHEN t.DETAIL_TYPE IN (2) THEN ''Payment - New''
			 WHEN t.DETAIL_TYPE IN (5) THEN ''Payment - Reversal''
			 WHEN t.DETAIL_TYPE IN (11) THEN ''Payment - Void''
			 WHEN t.DETAIL_TYPE IN (32,33) THEN ''Payment - Distributed''
			 WHEN t.DETAIL_TYPE IN (20) THEN ''Payment - Matched to Charge'' 
			 WHEN t.DETAIL_TYPE IN (22) THEN ''Payment - Matched to Debit Adj''END as TransactionSubtype
		,t.PROCEDURE_QUANTITY as TransactionUnits
		,t.ACTIVE_AR_AMOUNT as TransactionActiveARAmount 
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
		,t.INT_PAT_ID as TransactionPatientID
		from [Clarity].[ORGFILTER].CLARITY_TDL_TRAN t
			LEFT JOIN [Clarity].[ORGFILTER].ZC_DETAIL_TYPE dt ON dt.DETAIL_TYPE = t.DETAIL_TYPE
			LEFT JOIN [Clarity].[ORGFILTER].ARPB_TRANSACTIONS ar ON ar.TX_ID = t.TX_ID
		where 1=1
			AND t.SERV_AREA_ID IN (425,430)
			AND t.post_date >= ''1/1/2019'' 
			AND t.DETAIL_TYPE IN (2,5,11,20,22,32,33) /*6.2.24 Chris - Added Payment Reversals Type 5*/
			AND t.POST_DATE >= DATEADD(DAY,-5, convert(date,GETDATE())) /*Only load transactions from the last 10 days*/

		) tdl
		LEFT JOIN [Clarity].[ORGFILTER].ARPB_TRANSACTIONS tx ON tx.TX_ID = tdl.TransactionSourceID
		LEFT JOIN [Clarity].[ORGFILTER].[ARPB_TX_MODERATE] tm ON tm.TX_ID = tdl.TransactionSourceID
		LEFT JOIN [Clarity].[ORGFILTER].[HSP_ACCOUNT] a ON a.HSP_ACCOUNT_ID = tm.HOSP_ACCT_ID
		LEFT JOIN [Clarity].[ORGFILTER].[CLARITY_EAP] eap1 ON eap1.PROC_ID = tx.PROC_ID
		LEFT JOIN [Clarity].[ORGFILTER].[CLARITY_EAP] eap2 ON eap2.PROC_ID = tx.PROC_ID
		LEFT JOIN [Clarity].[ORGFILTER].[CL_UB_REV_CODE] rc ON rc.UB_REV_CODE_ID = eap1.UB_REV_CODE_ID
	'
	) tx

/*Load Debit adjustments into #Staging*/
	Print 'Step 1.3:  Loading Payments into #Staging...'
	INSERT INTO #Staging
	([TransactionID]
      ,[TransactionDatasourceID]
      ,[TransactionSourceID]
      ,[TransactionParentSourceID]
      ,[TransactionVisitID]
      ,[TransactionAccountID]
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
      ,[TransactionCPTDescription]
      ,[TransactionModifier1]
      ,[TransactionModifier2]
      ,[TransactionModifier3]
      ,[TransactionModifier4]
	  ,[TransactionICD10Dx1]					
	  ,[TransactionICD10Dx2]					
	  ,[TransactionICD10Dx3]					
	  ,[TransactionICD10Dx4]					
	  ,[TransactionICD10Dx5]
      ,[TransactionUnits]
	  ,[TransactionActiveARAmount]
      ,[TransactionAmount]
      ,[TransactionRVU]
      ,[TransactionDateOfService]
      ,[TransactionDateOfPosting]
      ,[TransactionDateOfBilling]
      ,[TransactionDateOfVoid]
      ,[TransactionReportingPeriodID]
      ,[TransactionPlaceOfServiceCode]
      ,[TransactionPlaceOfServiceType]
      ,[TransactionPatientID]
      ,[TransactionGLType]
      ,[TransactionStatus]
      ,[TransactionIsActive]
      ,[TransactionUpdatedDateTime]
	  ,[TransactionPayerPlanID]
	  ,[TransactionPlaceOfService]
	)

SELECT
	tx.[TransactionID]
      ,tx.[TransactionDatasourceID]
      ,tx.[TransactionSourceID]
      ,tx.[TransactionParentSourceID]
      ,tx.[TransactionVisitID]
      ,tx.[TransactionAccountID]
      ,tx.[TransactionDepartmentID]
      ,tx.[TransactionPayerID]
      ,tx.[TransactionBillingProviderID]
      ,tx.[TransactionBillingType]
      ,tx.[TransactionType]
      ,tx.[TransactionSubType]
      ,tx.[TransactionRevenueCode]
      ,tx.[TransactionRevenueCodeDescription]
      ,tx.[TransactionCode]
      ,tx.[TransactionDescription]
      ,tx.[TransactionCPTCode]
      ,tx.[TransactionCPTDescription]
      ,tx.[TransactionModifier1]
      ,tx.[TransactionModifier2]
      ,tx.[TransactionModifier3]
      ,tx.[TransactionModifier4]
	  ,tx.[TransactionICD10Dx1]					
	  ,tx.[TransactionICD10Dx2]					
	  ,tx.[TransactionICD10Dx3]					
	  ,tx.[TransactionICD10Dx4]					
	  ,tx.[TransactionICD10Dx5]
      ,tx.[TransactionUnits]
	  ,tx.[TransactionActiveARAmount]
      ,tx.[TransactionAmount]
      ,tx.[TransactionRVU]
      ,tx.[TransactionDateOfService]
      ,tx.[TransactionDateOfPosting]
      ,tx.[TransactionDateOfBilling]
      ,tx.[TransactionDateOfVoid]
      ,tx.[TransactionReportingPeriodID]
      ,tx.[TransactionPlaceOfServiceCode]
      ,tx.[TransactionPlaceOfServiceType]
      ,tx.[TransactionPatientID]
      ,tx.[TransactionGLType]
      ,tx.[TransactionStatus]
      ,tx.[TransactionIsActive]
      ,tx.[TransactionUpdatedDateTime]
	  ,tx.[TransactionPayerPlanID]
	  ,tx.[TransactionPlaceOfService]
FROM OPENQUERY([CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM],
	'
	select
		CONCAT(''5~'',CASE WHEN tdl.TransactionParentSourceID IS NOT NULL THEN concat(tdl.TransactionParentSourceID,''~'') END
					 ,tdl.TransactionSourceID
					 ,CASE WHEN tdl.TransactionParentSourceID IS NOT NULL THEN concat(''~'',tdl.TransactionTDLID) END) as TransactionID
		,''5'' as TransactionDatasourceID
		,CONCAT(CASE WHEN tdl.TransactionParentSourceID IS NOT NULL THEN concat(tdl.TransactionParentSourceID,''~'') END
					 ,tdl.TransactionSourceID
					 ,CASE WHEN tdl.TransactionParentSourceID IS NOT NULL THEN concat(''~'',tdl.TransactionTDLID) END
					 ) as TransactionSourceID
		,ISNULL(tdl.TransactionParentSourceID,tdl.TransactionSourceID) AS TransactionParentSourceID
		,CASE WHEN tx.PAT_ENC_CSN_ID is not null THEN CONCAT(''5~'',tx.PAT_ENC_CSN_ID)
			  WHEN tx.PAT_ENC_CSN_ID is null THEN CONCAT(''5~'',tx.ENC_FORM_NUM) END as TransactionVisitID
		,CASE WHEN tm.HOSP_ACCT_ID is not null THEN CONCAT(''5~'',tm.HOSP_ACCT_ID) END as TransactionAccountID
		
		,CASE WHEN tdl.TransactionDepartmentID is not null THEN CONCAT(''5~'',tdl.TransactionDepartmentID) END as TransactionDepartmentID
		,CASE WHEN tx.PAYOR_ID IS NOT NULL THEN CONCAT(''5~'',tx.PAYOR_ID)
			  WHEN tx.ORIGINAL_FC_C = 4 and tx.PAYOR_ID is null THEN ''5~0'' /*Hard-code selfpay when financial class is self pay*/
			  WHEN COALESCE(tdl.TransactionCurrentPayorID,tx.PAYOR_ID, tx.ORIGINAL_EPM_ID, a.PRIMARY_PAYOR_ID) is not null THEN CONCAT(''5~'',COALESCE(tdl.TransactionCurrentPayorID,tx.PAYOR_ID, tx.ORIGINAL_EPM_ID, a.PRIMARY_PAYOR_ID)) END as TransactionPayerID
		,CASE WHEN tdl.TransactionBillingProvider is not null THEN CONCAT(''5~'',tdl.TransactionBillingProvider) END as TransactionBillingProviderID
		,''PB'' as TransactionBillingType
		,tdl.TransactionType as TransactionType
		,tdl.TransactionSubtype as TransactionSubType
		,CASE WHEN LEFT(rc.REVENUE_CODE,1) = ''0'' THEN RIGHT(rc.REVENUE_CODE,3) ELSE rc.REVENUE_CODE END as TransactionRevenueCode
		,rc.BILL_DESC as TransactionRevenueCodeDescription
		,eap2.PROC_CODE as TransactionCode
		,COALESCE(eap2.BILL_DESC, eap2.PROC_NAME) as TransactionDescription
		,NULL as TransactionCPTCode
		,NULL AS TransactionCPTDescription
		,NULL as TransactionModifier1
		,NULL as TransactionModifier2
		,NULL as TransactionModifier3
		,NULL as TransactionModifier4
		,NULL as TransactionICD10Dx1					
		,NULL as TransactionICD10Dx2					
		,NULL as TransactionICD10Dx3					
		,NULL as TransactionICD10Dx4					
		,NULL as TransactionICD10Dx5
		,tdl.TransactionUnits as TransactionUnits
		,tdl.TransactionActiveARAmount as TransactionActiveARAmount
		,tdl.TransactionAmount as TransactionAmount
		,NULL as TransactionRVU
		,tdl.TransactionOriginalServiceDate as TransactionDateOfService
		,tdl.TransactionPostDate as TransactionDateOfPosting
		,tx.POST_DATE as TransactionDateOfBilling
		,tx.VOID_DATE as TransactionDateOfVoid
		,CONCAT(YEAR(tdl.TransactionPostDate),'' - '', RIGHT(concat(''00'',MONTH(tdl.TransactionPostDate)),2)) as TransactionReportingPeriodID
		,NULL AS TransactionPlaceOfServiceCode
		,NULL AS TransactionPlaceOfServiceType
		,CASE WHEN tdl.TransactionPatientID is not null THEN CONCAT(''5~'',tdl.TransactionPatientID) END as TransactionPatientID
		,NULL as TransactionGLType
		,CASE WHEN tx.VOID_DATE is null THEN ''Active'' ELSE ''Voided'' END as TransactionStatus 
		,1 as TransactionIsActive
		,GETDATE() as TransactionUpdatedDatetime
		,CASE WHEN tx.PAYOR_ID IS NOT NULL THEN CONCAT(''5~'',tx.PAYOR_ID)
			  WHEN tx.ORIGINAL_FC_C = 4 and tx.PAYOR_ID is null THEN ''5~0'' /*Hard-code selfpay when financial class is self pay*/
			  WHEN COALESCE(tdl.TransactionCurrentPayerPlanID,tdl.TransactionOriginalPayerPlanID) is not null THEN CONCAT(''5~'',COALESCE(tdl.TransactionCurrentPayerPlanID,tdl.TransactionOriginalPayerPlanID)) END as TransactionPayerPlanID
		,NULL as [TransactionPlaceOfService]
	from (
		select 
		t.TDL_ID as TransactionTDLID
		,CASE WHEN t.DETAIL_TYPE IN (3,12) THEN t.TX_ID 
			  WHEN t.DETAIL_TYPE IN (23) THEN t.MATCH_TRX_ID END as TransactionSourceID
		,CASE WHEN t.DETAIL_TYPE IN (3) THEN NULL
			  WHEN t.DETAIL_TYPE IN (12) THEN t.TX_ID
			  WHEN t.DETAIL_TYPE IN (23) THEN t.TX_ID END as TransactionParentSourceID
		,''Adjustment'' as TransactionType
		,CASE WHEN t.DETAIL_TYPE IN (3) THEN ''Debit Adjustment - New''
			 WHEN t.DETAIL_TYPE IN (12) THEN ''Debit Adjustment - Void''
			 WHEN t.DETAIL_TYPE in (23) THEN ''Credit Adjustment - Matched to Debit Adjustment''
			END as TransactionSubtype
		,t.PROCEDURE_QUANTITY as TransactionUnits
		,t.ACTIVE_AR_AMOUNT as TransactionActiveARAmount 
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
		,t.ORIGINAL_PAYOR_ID as TransactionOriginalPayorID
		,t.CUR_PLAN_ID as TransactionCurrentPayerPlanID
		,t.ORIGINAL_PLAN_ID as TransactionOriginalPayerPlanID
		,t.ORIG_SERVICE_DATE as TransactionOriginalServiceDate
		,t.INT_PAT_ID as TransactionPatientID
		from [Clarity].[ORGFILTER].CLARITY_TDL_TRAN t
			LEFT JOIN [Clarity].[ORGFILTER].ZC_DETAIL_TYPE dt ON dt.DETAIL_TYPE = t.DETAIL_TYPE
		where 1=1
			AND t.SERV_AREA_ID IN (425,430)
			AND t.post_date >= ''1/1/2019'' 
			AND t.DETAIL_TYPE IN (3,12,23)
			AND t.POST_DATE >= DATEADD(DAY,-5, convert(date,GETDATE())) /*Only load transactions from the last 10 days*/
		
		) tdl
		LEFT JOIN [Clarity].[ORGFILTER].ARPB_TRANSACTIONS tx ON tx.TX_ID = tdl.TransactionSourceID
		LEFT JOIN [Clarity].[ORGFILTER].[ARPB_TX_MODERATE] tm ON tm.TX_ID = tdl.TransactionSourceID
		LEFT JOIN [Clarity].[ORGFILTER].[HSP_ACCOUNT] a ON a.HSP_ACCOUNT_ID = tm.HOSP_ACCT_ID
		LEFT JOIN [Clarity].[ORGFILTER].[CLARITY_EAP] eap1 ON eap1.PROC_ID = tx.PROC_ID
		LEFT JOIN [Clarity].[ORGFILTER].[CLARITY_EAP] eap2 ON eap2.PROC_ID = tx.PROC_ID
		LEFT JOIN [Clarity].[ORGFILTER].[CL_UB_REV_CODE] rc ON rc.UB_REV_CODE_ID = eap1.UB_REV_CODE_ID
	') tx


/*Check #Staging records and delete/reload into fact.TransactionsPB*/
	Print 'Step 2:  Checking number of records in #Staging...'
	IF (SELECT COUNT(1) FROM #Staging) > 100 
		BEGIN
		Print 'Step 2.1:  More than 100 records exist in #Staging.  Proceeding with DELETE...'
		DELETE FROM fact.TransactionsPB WHERE TransactionDatasourceID = 5 AND TransactionDateOfPosting >= DATEADD(DAY,-@DaysToReload, convert(date,GETDATE())) 

		Print 'Step 2.2:  Proceeding with INSERT...'
		INSERT INTO fact.TransactionsPB
		([TransactionID]
		  ,[TransactionDatasourceID]
		  ,[TransactionSourceID]
		  ,[TransactionParentSourceID]
		  ,[TransactionVisitID]
		  ,[TransactionAccountID]
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
		  ,[TransactionCPTDescription]
		  ,[TransactionModifier1]
		  ,[TransactionModifier2]
		  ,[TransactionModifier3]
		  ,[TransactionModifier4]
		  ,[TransactionICD10Dx1]					
		  ,[TransactionICD10Dx2]					
		  ,[TransactionICD10Dx3]					
		  ,[TransactionICD10Dx4]					
		  ,[TransactionICD10Dx5]
		  ,[TransactionUnits]
		  ,[TransactionActiveARAmount]
		  ,[TransactionAmount]
		  ,[TransactionRVU]
		  ,[TransactionDateOfService]
		  ,[TransactionDateOfPosting]
		  ,[TransactionDateOfBilling]
		  ,[TransactionDateOfVoid]
		  ,[TransactionReportingPeriodID]
		  ,[TransactionPlaceOfServiceCode]
		  ,[TransactionPlaceOfServiceType]
		  ,[TransactionPatientID]
		  ,[TransactionGLType]
		  ,[TransactionStatus]
		  ,[TransactionIsActive]
		  ,[TransactionUpdatedDateTime]
		  ,[TransactionPayerPlanID]
		  ,[TransactionPlaceOfService]
		)

	SELECT [TransactionID]
		  ,[TransactionDatasourceID]
		  ,[TransactionSourceID]
		  ,[TransactionParentSourceID]
		  ,[TransactionVisitID]
		  ,[TransactionAccountID]
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
		  ,[TransactionCPTDescription]
		  ,[TransactionModifier1]
		  ,[TransactionModifier2]
		  ,[TransactionModifier3]
		  ,[TransactionModifier4]
		  ,[TransactionICD10Dx1]					
		  ,[TransactionICD10Dx2]					
		  ,[TransactionICD10Dx3]					
		  ,[TransactionICD10Dx4]					
		  ,[TransactionICD10Dx5]
		  ,[TransactionUnits]
		  ,[TransactionActiveARAmount]
		  ,[TransactionAmount]
		  ,[TransactionRVU]
		  ,[TransactionDateOfService]
		  ,[TransactionDateOfPosting]
		  ,[TransactionDateOfBilling]
		  ,[TransactionDateOfVoid]
		  ,[TransactionReportingPeriodID]
		  ,[TransactionPlaceOfServiceCode]
		  ,[TransactionPlaceOfServiceType]
		  ,[TransactionPatientID]
		  ,[TransactionGLType]
		  ,[TransactionStatus]
		  ,[TransactionIsActive]
		  ,[TransactionUpdatedDateTime]
		  ,[TransactionPayerPlanID]
		  ,[TransactionPlaceOfService]
	FROM #Staging
	--WHERE TransactionID = '5~42294501~82061025~42294501200441'

	END
	ELSE
	Print 'Less than 100 records in #Staging. Ending Job...'
END



/* 
/*Step 2:  Delete and reload PB transactions*/
--DELETE FROM fact.Transactions2 WHERE TransactionDataSourceID = 5 AND TransactionBillingType = 'PB'
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
		  WHEN tx.PAT_ENC_CSN_ID is null THEN CONCAT('5~',tx.ENC_FORM_NUM) END as TransactionEncounterID
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
	AND tdl.post_Date >= '1/1/2019'

 /*PB Transactions - Payments*/
UNION ALL 

select
'5' as TransactionDatasourceID
	,CONCAT('PB~',CASE WHEN tdl.TransactionParentSourceID IS NOT NULL THEN concat(tdl.TransactionParentSourceID,'~') END
				 ,tdl.TransactionSourceID) as TransactionSourceID
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
	and t.post_date >= '1/1/2019' --'1/1/2023'
	and t.DETAIL_TYPE IN (2,5,11,20,22,32,33) /*6.2.24 Chris - Added Payment Reversals Type 5*/
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
		  WHEN tx.PAT_ENC_CSN_ID is null THEN CONCAT('5~',tx.ENC_FORM_NUM) END as TransactionEncounterID
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
	and t.post_date >= '1/1/2019' --'1/1/2023'
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


	*/
GO
