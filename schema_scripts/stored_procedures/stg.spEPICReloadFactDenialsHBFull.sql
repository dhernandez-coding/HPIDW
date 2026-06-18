CREATE PROCEDURE [stg].[spEPICReloadFactDenialsHBFull] 
AS
BEGIN
    -- Step 1: Delete existing records for the data source
    DELETE FROM fact.DenialsHB 
    WHERE DenialDataSourceID = 5;


    -- Step 4: Insert into fact.DenialsHB
    INSERT INTO fact.DenialsHB
    (
      DenialID
	  ,DenialSourceID
	  ,DenialDataSourceID
      ,DenialTransactionID
      ,DenialType
      ,DenialRemitID
      ,DenialRemitDescription
      ,DenialExternalRemitCode
      ,DenialRemarkStatus
      ,DenialCodeGroup
      ,DenailCodeCategory
      ,DenialResolution
      ,DenialSource
      ,DenialRootCause
      ,DenialCliniclCause
      ,DenialPreventable
	  ,DenialDateRecieved
      ,DenialDateCreated
      ,DenialDaysOpen
      ,DenialDateResolved
      ,DenialDateReopened
      ,DenialPayerCategoryID
      ,DenialPayerID
      ,DenialStatus
      ,DenialBalance
      ,DenialBucketStatus
      ,DenialBucketFinancialClass
      ,DenialBilledAmount
      ,DenialAllowedAmount
      ,DenialPaidAmount
      ,DenialDeniedAmount
      ,DenialAccountID
      ,DenialPatientName
	  ,DenialBillingProviderID
      ,DenialAccountStatus
      ,DenialAccountBalance
      ,DenialVisitClass
      ,DenialVisitType
      ,DeniallocationID
      ,DenialDepartmentID
      ,DenialDateOfAdmission
      ,DenialDateOfDischarge
      ,DenialEndOfDayBucketBalance
      ,DenialRepoenDays
      ,DenialClass
      ,DenialServiceLine
      ,DenialWriteOffAmount
      ,DenialRecoveryAmount
      ,DenialPaymentTotal
	  ,DenialUpdateDate 
    )

   SELECT
	*
   FROM OPENQUERY([CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM],'
   SELECT 
	  CONCAT(''5~'',d.[BDC_ID]) as DenialID
	  ,d.[BDC_ID] as DenialSourceID
	  ,5 as DenialDataSourceID
      ,CONCAT(''HB~'',d.[SOURCE_PMT_TX_ID]) as DenialTransactionID
      ,d.[BDC_TYPE] as DenialType
      ,d.[REMIT_CODE_ID] as DenialRemitID
      ,d.[REMIT_CODE_NAME] as DenialRemitDescription
      ,d.[EXTERNAL_REMIT_CODE] as DenialExternalRemitCode
      ,d.[DEN_RMK_CORR_STATUS] as DenialRemarkStatus
      ,d.[REMIT_CODE_GROUP] as DenialCodeGroup
      ,d.[REMIT_CODE_CATEGORY] as DenailCodeCategory
      ,d.[RESOLVE_REASON] as DenialResolution
      ,d.[SOURCE_AREA] as DenialSource
      ,d.[ROOT_CAUSE] as DenialRootCause
      ,d.[CLINICAL_ROOT_CAUSE] as DenialCliniclCause
      ,d.[PREVENTABLE_YN] as DenialPreventable
	  ,sub.RECEIVE_DATE as DenialDateRecieved
      ,d.[CREATE_DATE] as DenialDateCreated
      ,d.[OPEN_DAYS] as DenialDaysOpen
      ,d.[RESOLVE_DATE] as DenialDateResolved
      ,d.[REOPEN_DATE] as DenialDateReopened
      ,CONCAT(''5~'',d.[BUCKET_PAYOR_ID]) as DenialPayerCategoryID
      ,CONCAT(''5~'',d.[BUCKET_PLAN_ID]) as DenialPayerID
      ,d.[BUCKET_STATUS] as DenialStatus
      ,d.[BUCKET_BALANCE] as DenialBalance
      ,d.[BUCKET_TYPE] as DenialBucketStatus
      ,d.[BUCKET_FINANCIAL_CLASS] as DenialBucketFinancialClass
      ,d.[BILLED_AMT] as DenialBilledAmount
      ,d.[ALLOWED_AMT] as DenialAllowedAmount
      ,d.[PAID_AMT] as DenialPaidAmount
      ,d.[DENIED_AMT] as DenialDeniedAmount
      ,CONCAT(''5~'',d.[HSP_ACCOUNT_ID]) as DenialAccountID
      ,d.[HSP_ACCOUNT_NAME] as DenialPatientName
	  ,CONCAT(''5~'',sub.BILLING_PROV_ID) as DenialBillingProviderID
      ,d.[HAR_STATUS] as DenialAccountStatus
      ,d.[HAR_BALANCE] as DenialAccountBalance
      ,d.[HAR_BASE_CLASS] as DenialVisitClass
      ,d.[HAR_ACCOUNT_CLASS] as DenialVisitType
      ,CONCAT(''5~'',d.[LOC_ID]) as DeniallocationID
      ,CONCAT(''5~'',d.[DISCH_DEPT_ID]) as DenialDepartmentID
      ,d.[ADMIT_DATETIME] as DenialDateOfAdmission
      ,d.[DISCH_DATETIME] as DenialDateOfDischarge
      ,d.[END_OF_DAY_BUCKET_BALANCE] as DenialEndOfDayBucketBalance
      ,d.[REOPEN_DAYS] as DenialRepoenDays
      ,d.[DENIAL_CLASS] as DenialClass
      ,d.[PRIM_ENC_DEPT_SPEC] as DenialServiceLine
      ,d.[WRITE_OFF_AMT] as DenialWriteOffAmount
      ,d.[ACTUAL_RECOVERY_AMT] as DenialRecoveryAmount
      ,d.[BKT_PAYMENT_TOTAL] as DenialPaymentTotal
	  ,GETDATE() as DenialUpdateDate
  FROM [Clarity].[ORGFILTER].[V_ARHB_BDC] d
	LEFT JOIN (SELECT
					dv.[BDC_ID]
					,dv.BILLING_PROV_ID
					,MAX(dv.RECEIVE_DATE) as RECEIVE_DATE
				FROM [CLARITY].[ORGFILTER].V_CUBE_F_HB_DENIAL_VARIANCE dv
				GROUP BY 
					dv.[BDC_ID]
					,dv.BILLING_PROV_ID
					,dv.RECEIVE_DATE) sub on sub.BDC_ID = d.BDC_ID

  WHERE 1=1
	AND sub.RECEIVE_DATE >= ''2023-04-01''
 ') sub

END;
GO
