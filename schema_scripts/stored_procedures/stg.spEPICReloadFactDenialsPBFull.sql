CREATE PROCEDURE [stg].[spEPICReloadFactDenialsPBFull]	AS
BEGIN		
	-- ========================================================================
	-- Author:		Eric Silvestri
	-- Create date: 10-29-2024
	-- Description:	Loads PB denial records from EPIC into fact.PBDenials.
    -- Change Control: Diego Hernandez - Modify the script to OpenQUERY (3/6/2026)
	-- ========================================================================

	
-- Step 1: Delete existing records for the data source
	DELETE FROM fact.DenialsPB 
	WHERE DenialDataSourceID = 5;

-- Step 2: Insert into fact.DenialsPB
INSERT INTO fact.DenialsPB
    (
        DenialID,
        DenialDataSourceID,
        DenialTransactionID,
        DenialTransactionChargeID,
        ChargePostingDate,
        ChargeServiceDate,
        DenialReceiveDate,
        DenialProcedureID,
        DenialPatientID,
        DenialLocationID,
        DenialDepartmentID,
        DenialBillingProviderID,
        DenialServiceProviderID,
        DenialPayerID,
        DenialPayerPlanID,
        DenialProcedureCode,
        DenialDiagnosisID,
        DenialInvoiceNumber,
        DenialReasonCode,
        DenialReasonDescription,
        DenialCategory,
        DenialCause,
        DenialRootCause,
        DenialReasonGroup,
        DenialResolutionCategory,
        DenialStatus,
        DenialIsPrimary,
        DenialIsFirst,
        DenialPostingDate,
        DenialCompletionDate,
        DenialDaysToClose,
        DenialAmount,
        DenialRecoveryAmount,
        DenialAdjustmentAmount,
        DenialBillingAmount,
        DenialUpdateDate
    )
    SELECT
        CONCAT('5~', src.BDC_ID)                 AS DenialID,
        5                                        AS DenialDataSourceID,
        CONCAT('5~', src.PAYMENT_TRANSACTION_ID) AS DenialTransactionID,
        CONCAT('5~', src.CHARGE_TRANSACTION_ID)  AS DenialTransactionChargeID,
        src.CHARGE_POST_DATE                     AS ChargePostingDate,
        src.CHARGE_SERVICE_DATE                  AS ChargeServiceDate,
        src.DENIAL_RECEIVE_DATE                  AS DenialReceiveDate,
        CONCAT('5~', src.CHARGE_PROCEDURE_ID)    AS DenialProcedureID,
        CONCAT('5~', src.PATIENT_ID)             AS DenialPatientID,
        CONCAT('5~', src.LOCATION_ID)            AS DenialLocationID,
        CONCAT('5~', src.DEPARTMENT_ID)          AS DenialDepartmentID,
        CONCAT('5~', src.BILLING_PROVIDER_ID)    AS DenialBillingProviderID,
        CONCAT('5~', src.SERVICE_PROVIDER_ID)    AS DenialServiceProviderID,
        CONCAT('5~', src.PAYER_ID)               AS DenialPayerID,
        CONCAT('5~', src.BENEFIT_PLAN_ID)        AS DenialPayerPlanID,
        src.CHARGE_PROCEDURE_ID                  AS DenialProcedureCode,
        src.PRIMARY_DIAGNOSIS_ID                 AS DenialDiagnosisID,
        src.INVOICE_NUMBER                       AS DenialInvoiceNumber,
        src.REASON_CODE                          AS DenialReasonCode,
        src.REASON_CODE_NAME                     AS DenialReasonDescription,
        src.DENIAL_CATEGORY                      AS DenialCategory,
        src.DENIAL_CAUSE                         AS DenialCause,
        src.ROOT_CAUSE                           AS DenialRootCause,
        src.BDC_REASON_CODE_GROUP                AS DenialReasonGroup,
        src.RESOLUTION_CATEGORY                  AS DenialResolutionCategory,
        src.DENIAL_STATUS                        AS DenialStatus,
        src.PRIMARY_DENIAL_FLAG                  AS DenialIsPrimary,
        src.FIRST_DENIAL_FLAG                    AS DenialIsFirst,
        src.DENIAL_POST_DATE                     AS DenialPostingDate,
        src.DENIAL_COMPLETE_DATE                 AS DenialCompletionDate,
        src.DAYS_TO_CLOSE                        AS DenialDaysToClose,
        src.DENIED_AMOUNT                        AS DenialAmount,
        src.RECOVERY_AMOUNT                      AS DenialRecoveryAmount,
        src.ADJUSTMENT_AMOUNT                    AS DenialAdjustmentAmount,
        src.BILLED_AMOUNT                        AS DenialBillingAmount,
        GETDATE()                                AS DenialUpdateDate
    FROM OPENQUERY

(
        [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM],
        '
        SELECT
            d.BDC_ID,
            d.PAYMENT_TRANSACTION_ID,
            d.CHARGE_TRANSACTION_ID,
            d.CHARGE_POST_DATE,
            d.CHARGE_SERVICE_DATE,
            d.DENIAL_RECEIVE_DATE,
            d.CHARGE_PROCEDURE_ID,
            d.PATIENT_ID,
            d.LOCATION_ID,
            d.DEPARTMENT_ID,
            d.BILLING_PROVIDER_ID,
            d.SERVICE_PROVIDER_ID,
            d.PAYER_ID,
            d.BENEFIT_PLAN_ID,
            d.PRIMARY_DIAGNOSIS_ID,
            d.INVOICE_NUMBER,
            dr.REASON_CODE,
            dr.REASON_CODE_NAME,
            d.DENIAL_CATEGORY,
            d.DENIAL_CAUSE,
            d.ROOT_CAUSE,
            d.BDC_REASON_CODE_GROUP,
            d.RESOLUTION_CATEGORY,
            d.DENIAL_STATUS,
            d.PRIMARY_DENIAL_FLAG,
            d.FIRST_DENIAL_FLAG,
            d.DENIAL_POST_DATE,
            d.DENIAL_COMPLETE_DATE,
            d.DAYS_TO_CLOSE,
            d.DENIED_AMOUNT,
            d.RECOVERY_AMOUNT,
            d.ADJUSTMENT_AMOUNT,
            d.BILLED_AMOUNT
        FROM Clarity.ORGFILTER.V_CUBE_F_PB_DENIALS d
        LEFT JOIN Clarity.ORGFILTER.X_CUBE_D_REASON_CODE dr
            ON d.REASON_CODE_ID = dr.REASON_CODE_ID
        GROUP BY
            d.BDC_ID,
            d.PAYMENT_TRANSACTION_ID,
            d.CHARGE_TRANSACTION_ID,
            d.CHARGE_POST_DATE,
            d.CHARGE_SERVICE_DATE,
            d.DENIAL_RECEIVE_DATE,
            d.CHARGE_PROCEDURE_ID,
            d.PATIENT_ID,
            d.LOCATION_ID,
            d.DEPARTMENT_ID,
            d.BILLING_PROVIDER_ID,
            d.SERVICE_PROVIDER_ID,
            d.PAYER_ID,
            d.BENEFIT_PLAN_ID,
            d.PRIMARY_DIAGNOSIS_ID,
            d.INVOICE_NUMBER,
            dr.REASON_CODE,
            dr.REASON_CODE_NAME,
            d.DENIAL_CATEGORY,
            d.DENIAL_CAUSE,
            d.ROOT_CAUSE,
            d.BDC_REASON_CODE_GROUP,
            d.RESOLUTION_CATEGORY,
            d.DENIAL_STATUS,
            d.PRIMARY_DENIAL_FLAG,
            d.FIRST_DENIAL_FLAG,
            d.DENIAL_POST_DATE,
            d.DENIAL_COMPLETE_DATE,
            d.DAYS_TO_CLOSE,
            d.DENIED_AMOUNT,
            d.RECOVERY_AMOUNT,
            d.ADJUSTMENT_AMOUNT,
            d.BILLED_AMOUNT
        '
    ) src;

END;


---- Step 1: Delete existing records for the data source
--	DELETE FROM fact.DenialsPB 
--	WHERE DenialDataSourceID = 5;

---- Step 2: Insert into fact.DenialsPB
--INSERT INTO fact.DenialsPB(
--	DenialID
--	,DenialDataSourceID
--	,DenialTransactionID
--	,DenialTransactionChargeID
--	,ChargePostingDate
--	,ChargeServiceDate
--	,DenialReceiveDate
--	,DenialProcedureID
--	,DenialPatientID
--	,DenialLocationID
--	,DenialDepartmentID
--	,DenialBillingProviderID
--	,DenialServiceProviderID
--	,DenialPayerID
--	,DenialPayerPlanID
--	,DenialProcedureCode
--	,DenialDiagnosisID
--	,DenialInvoiceNumber
--	,DenialReasonCode
--	,DenialReasonDescription
--	,DenialCategory
--	,DenialCause
--	,DenialRootCause
--	,DenialReasonGroup
--	,DenialResolutionCategory
--	,DenialStatus
--	,DenialIsPrimary
--	,DenialIsFirst
--	,DenialPostingDate
--	,DenialCompletionDate
--	,DenialDaysToClose
--	,DenialAmount
--	,DenialRecoveryAmount
--	,DenialAdjustmentAmount
--	,DenialBillingAmount
--	,DenialUpdateDate
--)



--SELECT
--	CONCAT('5~',d.BDC_ID)					AS DenialID
--	,5										AS DenialDataSourceID
--	,CONCAT('5~',d.PAYMENT_TRANSACTION_ID)	AS DenialTransactionID
--	,CONCAT('5~',d.CHARGE_TRANSACTION_ID)	AS DenialTransactionChargeID
--	,d.CHARGE_POST_DATE						AS ChargePostingDate
--	,d.CHARGE_SERVICE_DATE					AS ChargeServiceDate
--	,d.DENIAL_RECEIVE_DATE					AS DenialReceiveDate
--	,CONCAT('5~',d.CHARGE_PROCEDURE_ID)		AS DenialProcedureID
--	,CONCAT('5~',d.PATIENT_ID)				AS DenialPatientID
--	,CONCAT('5~',d.LOCATION_ID)				AS DenialLocationID
--	,CONCAT('5~',d.DEPARTMENT_ID)			AS DenialDepartmentID
--	,CONCAT('5~',d.BILLING_PROVIDER_ID)		AS DenialBillingProviderID
--	,CONCAT('5~',d.SERVICE_PROVIDER_ID)		AS DenialServiceProviderID
--	,CONCAT('5~',d.PAYER_ID)				AS DenialPayerID
--	,CONCAT('5~',d.BENEFIT_PLAN_ID)			AS DenialPayerPlanID
--	,d.CHARGE_PROCEDURE_ID					AS DenialProcedureCode
--	,d.PRIMARY_DIAGNOSIS_ID					AS DenialDiagnosisID
--	,d.INVOICE_NUMBER						AS DenialInvoiceNumber
--	,dr.REASON_CODE							AS DenialReasonCode
--	,dr.REASON_CODE_NAME					AS DenialReasonDescription
--	,d.DENIAL_CATEGORY						AS DenialCategory
--	,d.DENIAL_CAUSE							AS DenialCause
--	,d.ROOT_CAUSE							AS DenialRootCause
--	,d.BDC_REASON_CODE_GROUP				AS DenialReasonGroup
--	,d.RESOLUTION_CATEGORY					AS DenialResolutionCategory
--	,d.DENIAL_STATUS						AS DenialStatus
--	,d.PRIMARY_DENIAL_FLAG					AS DenialIsPrimary
--	,d.FIRST_DENIAL_FLAG					AS DenialIsFirst
--	,d.DENIAL_POST_DATE						AS DenialPostingDate
--	,d.DENIAL_COMPLETE_DATE					AS DenialCompletionDate
--	,d.DAYS_TO_CLOSE						AS DenialDaysToClose
--	,d.DENIED_AMOUNT						AS DenialAmount
--	,d.RECOVERY_AMOUNT						AS DenialRecoveryAmount
--	,d.ADJUSTMENT_AMOUNT					AS DenialAdjustmentAmount
--	,d.BILLED_AMOUNT						AS DenialBillingAmount
--	,GETDATE()								AS DenialUpdateDate
--FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].V_CUBE_F_PB_DENIALS d

--LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].X_CUBE_D_REASON_CODE dr
--	ON d.REASON_CODE_ID = dr.REASON_CODE_ID
--GROUP BY 
--	d.BDC_ID
--	,d.PAYMENT_TRANSACTION_ID
--	,d.CHARGE_TRANSACTION_ID
--	,d.CHARGE_POST_DATE		
--	,d.CHARGE_SERVICE_DATE
--	,d.DENIAL_RECEIVE_DATE
--	,d.CHARGE_PROCEDURE_ID
--	,d.PATIENT_ID	
--	,d.LOCATION_ID	
--	,d.DEPARTMENT_ID
--	,d.BILLING_PROVIDER_ID
--	,d.SERVICE_PROVIDER_ID
--	,d.PAYER_ID
--	,d.BENEFIT_PLAN_ID
--	,d.CHARGE_PROCEDURE_ID
--	,d.PRIMARY_DIAGNOSIS_ID	
--	,d.INVOICE_NUMBER		
--	,dr.REASON_CODE			
--	,dr.REASON_CODE_NAME	
--	,d.DENIAL_CATEGORY		
--	,d.DENIAL_CAUSE			
--	,d.ROOT_CAUSE			
--	,d.BDC_REASON_CODE_GROUP
--	,d.RESOLUTION_CATEGORY	
--	,d.DENIAL_STATUS		
--	,d.PRIMARY_DENIAL_FLAG	
--	,d.FIRST_DENIAL_FLAG	
--	,d.DENIAL_POST_DATE		
--	,d.DENIAL_COMPLETE_DATE	
--	,d.DAYS_TO_CLOSE		
--	,d.DENIED_AMOUNT		
--	,d.RECOVERY_AMOUNT		
--	,d.ADJUSTMENT_AMOUNT	
--	,d.BILLED_AMOUNT	
--END;
GO
