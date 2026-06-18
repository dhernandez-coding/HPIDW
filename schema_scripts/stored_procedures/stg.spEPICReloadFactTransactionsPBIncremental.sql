--USE [HPIDW]
--GO

--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE [stg].[spEPICReloadFactTransactionsPBIncremental] as

-- =============================================
-- Author:		Chris Cross
-- Create date: 9/3/2024
-- Description:	Deletes and reloads all Epic PB Transactions
-- 10/28/2025 - Eric Silvestri - Added ICD10Dx codes to the charges
-- 12/1/2025 - Eric Silvestri	- Added TransactionActiveARAmount, and TransactionAmount
-- 2/5/2026 - Chris Cross - Revised substantially 
-- 3/31/2026 - Chris Cross - Added service area 452000 for Dr. Chris Harris
-- =============================================

BEGIN

/*Step 0:  Load temp table for procedure code mapping from HERO-DB...*/
PRINT 'Load #TEMP_ProcedureCodeMapping...'
	DROP TABLE IF EXISTS #TEMP_ProcedureCodeMapping

	SELECT 
		c.ProcedureCode as ProcedureCode
		,pc.ProcedureCategory as ProcedureCodeCategory
		,pc.ProcedureCategoryVisitType as ProcedureCodeSubCategory
		,sl.ServiceLineName as ProcedureCodeServiceLine
		,c.ProcedureCodeIsLocationDependent as ProcedureCodeIsLocationDependent
		,pc.ProcedureCategoryPriority as ProcedureCodePriority
		,dhs.DHSCategoryName as ProcedureCodeDHSCategory
		,Case When c.ProcedureCodeInPlay = 1 Then 'Y' else 'N' End as ProcedureCodeInPlay
		,Case When c.ProcedureCodeTHPLab = 1 Then 'Y' else 'N' End as ProcedureCodeTHPLab
		,c.ModifiedDate
		,c.ModifiedBy
	INTO #TEMP_ProcedureCodeMapping
	FROM [HERO-DB].hpi.dbo.PBProcedureCodess c 
		left join [HERO-DB].hpi.dbo.PBProcedureCategoriess pc ON pc.id = c.ProcedureCodeCategoryID
		left join [HERO-DB].hpi.dbo.ServiceLiness sl ON sl.ServiceLineid = c.ProcedureCodeServiceLineId
		left join [HERO-DB].hpi.dbo.DHSCategoriess dhs ON dhs.DHSCategoryID = c.ProcedureCodeDHSCategoryId
	WHERE 1=1
		AND c.ProcedureCodeCategoryID is not null
 
/*Step 1:  Load Staging Table with PB transactions...*/
Print 'Step 1:  Create Staging Table...'
DECLARE @DaysToReload int = 5
Print 'Setting Days To Reload:' + convert(varchar(10),@DaysToReload) + '...'

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
	[TransactionActiveARAmount] [money] NULL,
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

/*Load Transactions into #Staging*/
	Print 'Step 1.1:  Loading Transactions into #Staging...'
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
      ,CASE --WHEN tx.[Appt_Type_Abbr] in ('SB','SB GWILL') or tx.[Appt_Resource_Descr] like '%smartbeat%' and tx.CPT_CODE in ('92250','93000','93308','93321','93325','93882','93922','93979','94010') THEN 'Smartbeat'
			WHEN tx.TransactionCPTCode in ('MPDC', '93922') THEN 'MaxPulse'
			WHEN tx.TransactionCPTCode like '7%' and (tx.TransactionModifier1 = 'TC' OR tx.TransactionModifier2 = 'TC') THEN 'RadTC'
			WHEN pc.[ProcedureCodeCategory] = 'XRAY Only Visits' THEN 'Xray'
			WHEN pc.[ProcedureCodeServiceLine] = 'DME' THEN 'DME'
			WHEN pc.[ProcedureCodeServiceLine] = 'Allergy Evaluation' THEN 'Allergy' /*Added on 1/28/2026*/
			WHEN pc.[ProcedureCodeCategory] = 'Ultrasound Only Visit' THEN 'Ultrasound' 
			WHEN pc.[ProcedureCodeCategory] = 'Lab Only Visit' THEN 'Lab' 
			--WHEN (tx.[Appt_Type_Abbr] = 'ANS GWIL' or tx.[Appt_Resource_Descr] = 'AUTONOMIC NERVE TESTING-GWIL') and (tx.[Patient_ID] is not null) and (tx.[Appt_Status] <> 'X' and tx.[Appt_Status] <> 'N')  THEN 'ANS'  
			WHEN tx.TransactionCPTCode in ('51729', '51797', '51784', '51741') THEN 'URO'  
			WHEN tx.TransactionCPTCode in ('99453', '99454', '99457', '99458', '95249', '95250', '95251') THEN 'Heartcloud'
			WHEN tx.TransactionCPTCode in ('95250', '95251', '95249') THEN 'CGM' END as [TransactionGLType]
      ,tx.[TransactionStatus]
      ,tx.[TransactionIsActive]
      ,tx.[TransactionUpdatedDateTime]
	  ,tx.[TransactionPayerPlanID]
	  ,tx.[TransactionPlaceOfService]
FROM OPENQUERY([CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM],
	'select
		CONCAT(''5~'',t.TX_ID
				,CASE WHEN t.MATCH_TRX_ID IS NOT NULL THEN CONCAT(''~'',t.MATCH_TRX_ID,''~'',t.TDL_ID) END
				,CASE WHEN t.DETAIL_TYPE in (10,11,12,13) THEN CONCAT(''~'',''VOID'') END) as [TransactionID]
        ,5 AS [TransactionDatasourceID]
		,CONCAT(''5~'',t.TX_ID
				,CASE WHEN t.MATCH_TRX_ID IS NOT NULL THEN CONCAT(''~'',t.MATCH_TRX_ID,''~'',t.TDL_ID) END
				,CASE WHEN t.DETAIL_TYPE in (10,11,12,13) THEN CONCAT(''~'',''VOID'') END) AS [TransactionSourceID]
	   ,t.TX_ID AS [TransactionParentSourceID]
	   ,CASE WHEN t.PAT_ENC_CSN_ID is not null THEN CONCAT(''5~'',t.PAT_ENC_CSN_ID)
	         WHEN tx.ENC_FORM_NUM is not null THEN CONCAT(''5~'',tx.ENC_FORM_NUM) END AS [TransactionVisitID] 
       ,CASE WHEN t.HSP_ACCOUNT_ID is not null THEN CONCAT(''5~'',t.HSP_ACCOUNT_ID) END AS [TransactionAccountID]
	   ,CONCAT(''5~'',t.DEPT_ID) AS [TransactionDepartmentID]

       ,CASE WHEN t.DETAIL_TYPE in (20,21,22,23) THEN CONCAT(''5~'',ISNULL(convert(varchar(30),t.MATCH_PAYOR_ID),''0'')) /*cc - 6/5/2026 - Matched transaction payer / Hard-code selfpay*/  
			 WHEN t.CUR_PAYOR_ID is null AND t.CUR_FIN_CLASS = 4 THEN ''5~0'' /*Hard-code selfpay*/ 
		     WHEN t.ORIGINAL_PAYOR_ID is not null THEN CONCAT(''5~'',t.ORIGINAL_PAYOR_ID)
			 WHEN t.CUR_PAYOR_ID is not null THEN CONCAT(''5~'',t.CUR_PAYOR_ID) END AS [TransactionPayerID]

       ,CASE WHEN t.BILLING_PROVIDER_ID is not null THEN CONCAT(''5~'',t.BILLING_PROVIDER_ID) END AS [TransactionBillingProviderID]
       ,''PB'' AS [TransactionBillingType]

       ,CASE WHEN t.DETAIL_TYPE in (1,10) THEN ''Charge''
			  WHEN t.DETAIL_TYPE in (2,5,11,20,22,32,33) THEN ''Payment'' 
			  WHEN t.DETAIL_TYPE in (3,12) AND eap1.PROC_CODE in (''4007'',''6005'',''6009'') THEN ''Payment'' --Refunds
			  WHEN t.DETAIL_TYPE in (3,12) AND eap1.PROC_CODE not in (''4007'',''6005'',''6009'') THEN ''Adjustment''
			  WHEN t.DETAIL_TYPE in (4,6,13,21,23,30,31) THEN ''Adjustment''
			  END AS [TransactionType]

		,CASE WHEN t.DETAIL_TYPE in (1) THEN ''Charge - New''
			  WHEN t.DETAIL_TYPE in (10) then ''Charge - Void''
			  
			  WHEN t.DETAIL_TYPE IN (2) THEN ''Payment - New''
			  WHEN t.DETAIL_TYPE IN (11) THEN ''Payment - Void''
			  WHEN t.DETAIL_TYPE IN (5) THEN ''Payment - Reversal''
			  WHEN t.DETAIL_TYPE IN (20) THEN ''Payment - Matched to Charge''
			  WHEN t.DETAIL_TYPE IN (22) THEN ''Payment - Matched to Debit Adjustment''
			  WHEN t.DETAIL_TYPE IN (32) THEN ''Payment - Distributed to Charge''
			  WHEN t.DETAIL_TYPE IN (33) THEN ''Payment - Distributed to Debit Adjustment''
			  WHEN t.DETAIL_TYPE in (3,12) AND eap1.PROC_CODE in (''4007'',''6005'',''6009'') THEN ''Payment - Refund''
			  
			  WHEN t.DETAIL_TYPE in (3) AND eap1.PROC_CODE not in (''4007'',''6005'',''6009'') THEN ''Debit Adjustment - New''
			  WHEN t.DETAIL_TYPE in (12) AND eap1.PROC_CODE not in (''4007'',''6005'',''6009'') THEN ''Debit Adjustment - Void''
			  
			  WHEN t.DETAIL_TYPE in (4) THEN ''Credit Adjustment - New''
			  WHEN t.DETAIL_TYPE in (13) THEN ''Credit Adjustment - Void''
			  WHEN t.DETAIL_TYPE in (6) THEN ''Credit Adjustment - Reversal''
			  WHEN t.DETAIL_TYPE in (21) THEN ''Credit Adjustment - Matched to Charge''
			  WHEN t.DETAIL_TYPE in (23) THEN ''Credit Adjustment - Matched to Debit Adjustment''
			  WHEN t.DETAIL_TYPE in (30) THEN ''Credit Adjustment - Distributed to Charge''
			  WHEN t.DETAIL_TYPE in (31) THEN ''Credit Adjustment - Distributed to Debit Adjustment''
			  END AS [TransactionSubType]
       ,CASE WHEN LEFT(rc.REVENUE_CODE,1) = ''0'' THEN RIGHT(rc.REVENUE_CODE,3) 
			 ELSE rc.REVENUE_CODE END AS [TransactionRevenueCode]
	   ,rc.BILL_DESC AS [TransactionRevenueCodeDescription]

	   ,CASE WHEN t.DETAIL_TYPE in (20,21) THEN eap2.PROC_CODE ELSE eap1.PROC_CODE END as TransactionCode  --Updated on 2/19/2026 to bring in appropriate code for matched payments/credit adjustments
	   ,CASE WHEN t.DETAIL_TYPE in (20,21) THEN COALESCE(eap2.BILL_DESC,eap2.PROC_NAME) ELSE COALESCE(eap1.BILL_DESC,eap1.PROC_NAME) END as TransactionDescription --Updated on 2/19/2026

       ,t.CPT_CODE AS [TransactionCPTCode]
       ,COALESCE(eap1.BILL_DESC,eap1.PROC_NAME) AS [TransactionCPTDescription]
       ,t.MODIFIER_ONE AS [TransactionModifier1]
       ,t.MODIFIER_TWO AS [TransactionModifier2]
       ,t.MODIFIER_THREE AS [TransactionModifier3]
       ,t.MODIFIER_FOUR AS [TransactionModifier4]
	   ,dx1.EXTERNAL_ID AS [TransactionICD10Dx1]					
	   ,dx2.EXTERNAL_ID AS [TransactionICD10Dx2]					
	   ,dx3.EXTERNAL_ID AS [TransactionICD10Dx3]					
	   ,dx4.EXTERNAL_ID AS [TransactionICD10Dx4]					
	   ,dx5.EXTERNAL_ID AS [TransactionICD10Dx5]
	   ,t.PROCEDURE_QUANTITY AS [TransactionUnits]
	   ,t.ACTIVE_AR_AMOUNT AS [TransactionActiveARAmount]
	   ,t.AMOUNT AS [TransactionAmount]
	   ,t.RELATIVE_VALUE_UNIT AS [TransactionRVU]
	   ,t.ORIG_SERVICE_DATE AS [TransactionDateOfService]
	   ,t.POST_DATE AS [TransactionDateOfPosting]
	   ,t.POST_DATE AS [TransactionDateOfBilling]
	   ,tx.VOID_DATE AS [TransactionDateOfVoid]
	   ,CONCAT(YEAR(t.POST_DATE),'' - '', RIGHT(concat(''00'',MONTH(t.POST_DATE)),2)) AS [TransactionReportingPeriodID]
	   ,pos.POS_CODE AS [TransactionPlaceOfServiceCode]
	   ,pos.POS_TYPE AS [TransactionPlaceOfServiceType]
	    ,CASE WHEN t.INT_PAT_ID is not null THEN CONCAT(''5~'',t.INT_PAT_ID)
		     WHEN t.PAT_ID is not null THEN CONCAT(''5~'',t.PAT_ID) END AS [TransactionPatientID]
	   ,NULL AS [TransactionGLType]
	   ,CASE WHEN tx.VOID_DATE is null THEN ''Active'' ELSE ''Voided'' END AS [TransactionStatus]
	   ,1 AS [TransactionIsActive]
	   ,GETDATE() AS [TransactionUpdatedDateTime]
	   ,CASE WHEN t.CUR_PAYOR_ID is null AND t.CUR_FIN_CLASS = 4 THEN ''5~0'' /*Hard-code selfpay*/ 
		     WHEN t.ORIGINAL_PLAN_ID is not null THEN CONCAT(''5~'',t.ORIGINAL_PLAN_ID)
			 WHEN t.CUR_PLAN_ID is not null THEN CONCAT(''5~'',t.CUR_PLAN_ID) END AS [TransactionPayerPlanID]
	   ,pos.POS_NAME AS [TransactionPlaceOfService]
	from [Clarity].[dbo].CLARITY_TDL_TRAN t
		LEFT JOIN [Clarity].[dbo].ZC_DETAIL_TYPE dt ON dt.DETAIL_TYPE = t.DETAIL_TYPE
		LEFT JOIN [Clarity].[dbo].ARPB_TRANSACTIONS tx ON tx.TX_ID = t.TX_ID
		LEFT JOIN [Clarity].[dbo].CLARITY_DEP dep ON dep.DEPARTMENT_ID = t.DEPT_ID
		LEFT JOIN [Clarity].[dbo].CLARITY_EAP eap1 ON eap1.PROC_ID = t.PROC_ID
		LEFT JOIN [Clarity].[dbo].CLARITY_EAP eap2 ON eap2.PROC_ID = t.MATCH_PROC_ID
		LEFT JOIN [Clarity].[dbo].CL_UB_REV_CODE rc ON rc.UB_REV_CODE_ID = eap1.UB_REV_CODE_ID
		LEFT JOIN [Clarity].[dbo].CLARITY_EDG dx1 ON dx1.DX_ID = t.DX_ONE_ID						
		LEFT JOIN [Clarity].[dbo].CLARITY_EDG dx2 ON dx2.DX_ID = t.DX_TWO_ID						
		LEFT JOIN [Clarity].[dbo].CLARITY_EDG dx3 ON dx3.DX_ID = t.DX_THREE_ID						
		LEFT JOIN [Clarity].[dbo].CLARITY_EDG dx4 ON dx4.DX_ID = t.DX_FOUR_ID						
		LEFT JOIN [Clarity].[dbo].CLARITY_EDG dx5 ON dx5.DX_ID = t.DX_FIVE_ID			
		LEFT JOIN [Clarity].[dbo].CLARITY_POS pos ON pos.POS_ID = t.POS_ID
	where 1=1
		AND t.DETAIL_TYPE < 40
		AND (t.SERV_AREA_ID IN (425,430)
			 OR (t.SERV_AREA_ID IN (452000) AND t.ORIG_SERVICE_DATE >= ''3/23/2026''))
		AND t.POST_DATE >= ''1/1/2019''
		AND t.POST_DATE >= DATEADD(DAY,-5, convert(date,GETDATE()))
		--AND t.POST_DATE BETWEEN ''12/1/2025'' and ''12/31/2025''
		--AND t.DEPT_ID in (42501010001,42501010002) --''42501001001''			
	') tx
	LEFT JOIN #TEMP_ProcedureCodeMapping pc ON pc.ProcedureCode = COALESCE(tx.TransactionCPTCode,tx.TransactionCode)
WHERE 1=1


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

	DROP TABLE IF EXISTS #TEMP_ProcedureCodeMapping
	DROP TABLE IF EXISTS #Staging
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
