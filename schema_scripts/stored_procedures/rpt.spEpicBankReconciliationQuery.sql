CREATE PROCEDURE [rpt].[spEpicBankReconciliationQuery]
(
      @StartDate       DATE
    , @EndDate         DATE
    , @ServiceAreaID   INT           = 425
    , @FinancialClass  INT           = 4
    , @AccountID       VARCHAR(20)   = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    ----------------------------------------------------------------------
    -- Build dynamic SQL for OPENQUERY (Clarity)
    ----------------------------------------------------------------------
    DECLARE @sql NVARCHAR(MAX);

    SET @sql = '
SELECT
       ''PB'' AS Sys,
       tx.PostDate,
       tx.DepDate,
       tx.Department,
       tx.BatchID,
       tx.PaymentSource,
       tx.ORIG_REF_NUM AS ReferenceNumber,
       tx.ProcedureDesc AS PaymentCode,
       tx.AmountTotal AS Amount,
       tx.DetailType AS TxType,
       l.LocationName,
	   l.LocationAbbreviation
FROM OPENQUERY([CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM],
''
    SELECT
         tx2.INACTIVE_TYPE_C,
         tx.ACCOUNT_ID,
         tx.ORIGINAL_FC_C AS FinancialClasss,
         tdl.POSTING_BATCH_NUM AS BatchID,
         dt.NAME AS DetailType,
         tx2.INACTIVE_TYPE_C AS InactiveTypeID,
         it.NAME AS InactiveType,
         tdl.TX_ID AS TransactionID,
         tdl.DEPT_ID AS Department,
         tdl.CUR_FIN_CLASS AS FinancialClassCurrent,
         tdl.ORIGINAL_FIN_CLASS AS OriginalFinancialClass,
         tdl.ORIG_REF_NUM,
         tx.LOC_ID,
         tdl.PROC_ID AS ProcedureID,
         eap.PROC_NAME AS ProcedureDesc,
         tdl.PAYMENT_SOURCE_C AS PaymentSourceID,
         ps.NAME AS PaymentSource,
         tdl.POST_DATE AS PostDate,
         tdl.ORIG_SERVICE_DATE AS DepDate,
         tdl.ORIG_POST_DATE AS OriginalPostDate,
         tx.CREDIT_SRC_MODULE_C AS ModuleID,
         m.Name AS Module,
         tdl.AMOUNT AS AmountTotal,
         tdl.PATIENT_AMOUNT AS AmountPatient,
         tdl.INSURANCE_AMOUNT AS AmountInsurance,
         tx.VOID_DATE AS VoidDate,
         CASE WHEN tx.VOID_DATE IS NOT NULL THEN ''''Y'''' ELSE ''''N'''' END AS IsVoided
    FROM [Clarity].[ORGFILTER].[CLARITY_TDL_TRAN] tdl
    LEFT JOIN [Clarity].[ORGFILTER].[ZC_DETAIL_TYPE] dt 
           ON dt.DETAIL_TYPE = tdl.DETAIL_TYPE
    LEFT JOIN [Clarity].[ORGFILTER].[ZC_PAYMENT_SOURCE] ps 
           ON ps.PAYMENT_SOURCE_C = tdl.PAYMENT_SOURCE_C
    LEFT JOIN [Clarity].[ORGFILTER].[CLARITY_EAP] eap 
           ON eap.PROC_ID = tdl.PROC_ID
    LEFT JOIN [Clarity].[ORGFILTER].[ARPB_TRANSACTIONS] tx 
           ON tx.TX_ID = tdl.TX_ID
    LEFT JOIN [Clarity].[ORGFILTER].[ARPB_TRANSACTIONS2] tx2 
           ON tx2.TX_ID = tdl.TX_ID
    LEFT JOIN [Clarity].[ORGFILTER].[ZC_INACTIVE_TYPE] it 
           ON it.INACTIVE_TYPE_C = tx2.INACTIVE_TYPE_C
    LEFT JOIN [Clarity].[ORGFILTER].[ZC_MTCH_DIST_SRC] m 
           ON m.MTCH_TX_HX_DIST_C = tx.CREDIT_SRC_MODULE_C
    WHERE 1=1
      AND tdl.POST_DATE BETWEEN ''''' + CONVERT(VARCHAR(10), @StartDate, 120) + ''''' AND ''''' + CONVERT(VARCHAR(10), @EndDate, 120) + '''''
      AND tx.TX_TYPE_C = 2
	  AND tdl.POS_ID is not null
      AND tdl.SERV_AREA_ID = ' + CAST(@ServiceAreaID AS VARCHAR(10)) + '
      AND tdl.DETAIL_TYPE IN (2,11)
      AND tdl.ORIGINAL_FIN_CLASS = ' + CAST(@FinancialClass AS VARCHAR(10)) + '
--      AND (
--    tx2.INACTIVE_TYPE_C IS NULL
--    OR tx2.INACTIVE_TYPE_C <> ''''2''''
--    OR (
--        tx2.INACTIVE_TYPE_C = ''''2''''
--        AND tx.VOID_DATE BETWEEN ''''' + CONVERT(VARCHAR(10), @StartDate, 120) + '''''
--                            AND ''''' + CONVERT(VARCHAR(10), @EndDate, 120) + '''''
--    )
--)
      AND m.Name IN (''''Payment Collection'''',''''Electronic Remittance'''',''''Payment Posting'''')
';

    -- Optional account filter
    IF @AccountID IS NOT NULL
        SET @sql += '
      AND tx.ACCOUNT_ID = ''''' + @AccountID + ''''' ';

    SET @sql += '
    ORDER BY tdl.POSTING_BATCH_NUM
'') tx
LEFT JOIN [HPIDW].[dim].[Locations] l
       ON l.LocationSourceID = tx.LOC_ID;
';

    ----------------------------------------------------------------------
    -- Execute dynamic SQL
    ----------------------------------------------------------------------
    EXEC sp_executesql @sql;
END
GO
