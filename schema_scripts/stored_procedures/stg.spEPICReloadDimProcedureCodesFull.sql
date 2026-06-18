CREATE PROCEDURE [stg].[spEPICReloadDimProcedureCodesFull] AS

BEGIN TRY
    BEGIN TRANSACTION; 

--------------------------------------------------------------------
-- Insert all procedure codes into a temporary table
PRINT 'Inserting all codes into a temp table...'
--------------------------------------------------------------------

DROP TABLE IF EXISTS #CODEBOI;


SELECT *
INTO #CODEBOI
FROM OPENQUERY([CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM],
'
    SELECT 
        CONCAT(''5~'', eap.PROC_ID) AS ProcedureCodeID,
        5 AS ProcedureCodeDataSourceID,
        eap.PROC_ID AS ProcedureCodeSourceID,
        eap.PROC_CODE AS ProcedureCode,
        eap.PROC_NAME AS ProcedureCodeInsuranceDescription,
        eap.PROC_NAME AS ProcedureCodeStatementDescription,
        NULL AS ProcedureCodeType,
        CONCAT(''5~'', eap.PROC_CAT_ID) AS ProcedureCodeCategoryID,
        NULL AS ProcedureCodeCategoryAbbreviation,
        epc.PROC_CAT_NAME AS ProcedureCodeCategoryDescription,
        CASE 
            WHEN cdp.SELFPAY_INSURANCE_INDICATOR IN (''Self-Pay'', ''Both'') THEN 1 
            ELSE 0 
        END AS ProcedureCodeSelfPay,
        0 AS ProcedureCodeEnableSplitBilling,
        0 AS ProcedureCodeInfusion,
        CASE 
            WHEN eap.IS_ACTIVE_YN = ''Y'' THEN 1 
            ELSE 0 
        END AS ProcedureCodeIsActive,
        GETDATE() AS ProcedureCodeUpdatedDateTime
    FROM [Clarity].[dbo].[CLARITY_EAP] eap
    LEFT JOIN [Clarity].[dbo].[EDP_PROC_CAT_INFO] epc 
        ON eap.PROC_CAT_ID = epc.PROC_CAT_ID
    LEFT JOIN [Clarity].[ORGFILTER].[V_CUBE_D_PROCEDURE] cdp 
        ON eap.PROC_ID = cdp.PROCEDURE_ID
    WHERE 1=1
        -- AND eap.PROC_CODE = ''G0444''
        AND eap.RECORD_STATE_EAP_C IS NULL
') AS ep;

--------------------------------------------------------------------
-- Delete procedure codes from the temp table if they are already in the dim table
PRINT 'Deleting codes from the dim.ProcedureCodes table...'
--------------------------------------------------------------------

DELETE FROM dim.ProcedureCodes WHERE ProcedureCodeDataSourceID = 5

--------------------------------------------------------------------
-- Insert new procedure codes intothe dim table
PRINT 'Inserting new codes into the dim table...'
--------------------------------------------------------------------

INSERT INTO dim.ProcedureCodes (
	[ProcedureCodeID]
	,[ProcedureCodeDataSourceID]
	,[ProcedureCodeSourceID]
	,[ProcedureCode]
	,[ProcedureCodeInsuranceDescription]
	,[ProcedureCodeStatementDescription]
	,[ProcedureCodeType]
	,[ProcedureCodeCategoryID]
	,[ProcedureCodeCategoryAbbreviation]
	,[ProcedureCodeCategoryDescription]
	,[ProcedureCodeSelfPay]
	,[ProcedureCodeEnableSplitBilling]
	,[ProcedureCodeInfusion]
	,[ProcedureCodeIsActive]
	,[ProcedureCodeUpdatedDateTime]
)
SELECT 
	[ProcedureCodeID]
	,[ProcedureCodeDataSourceID]
	,[ProcedureCodeSourceID]
	,[ProcedureCode]
	,[ProcedureCodeInsuranceDescription]
	,[ProcedureCodeStatementDescription]
	,[ProcedureCodeType]
	,[ProcedureCodeCategoryID]
	,[ProcedureCodeCategoryAbbreviation]
	,[ProcedureCodeCategoryDescription]
	,[ProcedureCodeSelfPay]
	,[ProcedureCodeEnableSplitBilling]
	,[ProcedureCodeInfusion]
	,[ProcedureCodeIsActive]
	,[ProcedureCodeUpdatedDateTime]
FROM #CODEBOI

	DROP TABLE #CODEBOI
    COMMIT TRANSACTION;  -- Commit the transaction if everything succeeds
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;  -- Rollback transaction on error

    -- Log error details
    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    SELECT 
        @ErrorMessage = ERROR_MESSAGE(),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE();

    -- Print or log the error information
    PRINT 'Error occurred: ' + @ErrorMessage;
    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH;

-- ############################## OLD QUERY ######################################

--BEGIN TRY
--    BEGIN TRANSACTION; 

----------------------------------------------------------------------
---- Insert all procedure codes into a temporary table
--PRINT 'Inserting all codes into a temp table...'
----------------------------------------------------------------------

--DROP TABLE IF EXISTS #CODEBOI;


--select 
--	CONCAT('5~',EAP.PROC_ID)											AS [ProcedureCodeID]
--	,5																	AS [ProcedureCodeDataSourceID]
--	,eap.PROC_ID															AS [ProcedureCodeSourceID]
--	,eap.PROC_CODE														AS [ProcedureCode]
--	,eap.[PROC_NAME]													AS [ProcedureCodeInsuranceDescription]
--	,eap.[PROC_NAME]													AS [ProcedureCodeStatementDescription]
--	,NULL																AS [ProcedureCodeType]
--	,CONCAT('5~',eap.PROC_CAT_ID)										AS [ProcedureCodeCategoryID]
--	,NULL																	AS [ProcedureCodeCategoryAbbreviation]
--	,epc.PROC_CAT_NAME													AS [ProcedureCodeCategoryDescription]
--	,CASE
--		WHEN cdp.SELFPAY_INSURANCE_INDICATOR IN('Self-Pay','Both')
--			THEN 1
--		ELSE 0
--	END																	AS [ProcedureCodeSelfPay]
--	,0																	AS [ProcedureCodeEnableSplitBilling]
--	,0																	AS [ProcedureCodeInfusion]
--	,CASE
--		WHEN eap.IS_ACTIVE_YN = 'Y'
--			THEN 1
--		ELSE 0
--	END																	AS [ProcedureCodeIsActive]
--	,GETDATE()															AS [ProcedureCodeUpdatedDateTime]
--INTO #CODEBOI
--FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].Clarity.[dbo].CLARITY_EAP eap

--LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].Clarity.[dbo].EDP_PROC_CAT_INFO epc
--	ON eap.PROC_CAT_ID = epc.PROC_CAT_ID
--LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].Clarity.[ORGFILTER].V_CUBE_D_PROCEDURE cdp
--	ON eap.PROC_ID = cdp.PROCEDURE_ID
--where 1=1
--	--AND eap.proc_code = 'G0444'
--	AND eap.RECORD_STATE_EAP_C is null /*Added to remove duplicate CPT codes*/

----------------------------------------------------------------------
---- Delete procedure codes from the temp table if they are already in the dim table
--PRINT 'Deleting codes from the dim.ProcedureCodes table...'
----------------------------------------------------------------------

--DELETE FROM dim.ProcedureCodes WHERE ProcedureCodeDataSourceID = 5

----------------------------------------------------------------------
---- Insert new procedure codes intothe dim table
--PRINT 'Inserting new codes into the dim table...'
----------------------------------------------------------------------

--INSERT INTO dim.ProcedureCodes (
--	[ProcedureCodeID]
--	,[ProcedureCodeDataSourceID]
--	,[ProcedureCodeSourceID]
--	,[ProcedureCode]
--	,[ProcedureCodeInsuranceDescription]
--	,[ProcedureCodeStatementDescription]
--	,[ProcedureCodeType]
--	,[ProcedureCodeCategoryID]
--	,[ProcedureCodeCategoryAbbreviation]
--	,[ProcedureCodeCategoryDescription]
--	,[ProcedureCodeSelfPay]
--	,[ProcedureCodeEnableSplitBilling]
--	,[ProcedureCodeInfusion]
--	,[ProcedureCodeIsActive]
--	,[ProcedureCodeUpdatedDateTime]
--)
--SELECT 
--	[ProcedureCodeID]
--	,[ProcedureCodeDataSourceID]
--	,[ProcedureCodeSourceID]
--	,[ProcedureCode]
--	,[ProcedureCodeInsuranceDescription]
--	,[ProcedureCodeStatementDescription]
--	,[ProcedureCodeType]
--	,[ProcedureCodeCategoryID]
--	,[ProcedureCodeCategoryAbbreviation]
--	,[ProcedureCodeCategoryDescription]
--	,[ProcedureCodeSelfPay]
--	,[ProcedureCodeEnableSplitBilling]
--	,[ProcedureCodeInfusion]
--	,[ProcedureCodeIsActive]
--	,[ProcedureCodeUpdatedDateTime]
--FROM #CODEBOI

--	DROP TABLE #CODEBOI
--    COMMIT TRANSACTION;  -- Commit the transaction if everything succeeds
--END TRY
--BEGIN CATCH
--    ROLLBACK TRANSACTION;  -- Rollback transaction on error

--    -- Log error details
--    DECLARE @ErrorMessage NVARCHAR(4000);
--    DECLARE @ErrorSeverity INT;
--    DECLARE @ErrorState INT;

--    SELECT 
--        @ErrorMessage = ERROR_MESSAGE(),
--        @ErrorSeverity = ERROR_SEVERITY(),
--        @ErrorState = ERROR_STATE();

--    -- Print or log the error information
--    PRINT 'Error occurred: ' + @ErrorMessage;
--    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
--END CATCH;
GO
