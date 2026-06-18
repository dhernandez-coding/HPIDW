CREATE PROCEDURE [stg].[spEPICReloadFactDenialsPBFull]	AS
BEGIN		
	-- ========================================================================
	-- Author:		Robert Beaird
	-- Create date: 7-18-2024
	-- Edit date:   7-23-2024
	-- Description:	Loads PB denial records from EPIC into fact.PBDenials.
	-- ========================================================================
--DECLARE @QueryLookbackDays int = 10
--DECLARE @QueryEndDate date = GETDATE() 
--DECLARE @QueryBeginDate date = DATEADD(DAY,-@QueryLookbackDays,@QueryEndDate)
--DECLARE @DeleteMessage varchar(200) = 'Deleting duplicate denial values between ' + CAST(@QueryBeginDate AS varchar(20)) + ' & ' + CAST(@QueryEndDate AS varchar(20))
--DECLARE @InsertMessage varchar(200) = 'Inserting new denial values between ' + CAST(@QueryBeginDate AS varchar(20)) + ' & ' + CAST(@QueryEndDate AS varchar(20))

BEGIN TRY

------------------------------------------------------------------------------------------------------------
/* Insert all denial values into a temp table */
------------------------------------------------------------------------------------------------------------


SELECT
	CONCAT('5~',d.BDC_ID)					AS DenialID
	,5										AS DenialDataSourceID
	,CONCAT('5~',d.PAYMENT_TRANSACTION_ID)	AS DenialTransactionID
	,CONCAT('5~',d.CHARGE_TRANSACTION_ID)	AS DenialTransactionChargeID
	,d.CHARGE_POST_DATE						AS ChargePostingDate
	,d.CHARGE_SERVICE_DATE					AS ChargeServiceDate
	,d.DENIAL_RECEIVE_DATE					AS DenialReceiveDate
	,CONCAT('5~',d.CHARGE_PROCEDURE_ID)		AS DenialProcedureID
	,CONCAT('5~',d.PATIENT_ID)				AS DenialPatientID
	,CONCAT('5~',d.LOCATION_ID)				AS DenialLocationID
	,CONCAT('5~',d.DEPARTMENT_ID)			AS DenialDepartmentID
	,CONCAT('5~',d.BILLING_PROVIDER_ID)		AS DenialBillingProviderID
	,CONCAT('5~',d.SERVICE_PROVIDER_ID)		AS DenialServiceProviderID
	,CONCAT('5~',d.PAYER_ID)				AS DenialPayerID
	,CONCAT('5~',d.BENEFIT_PLAN_ID)			AS DenialPayerPlanID
	,CONCAT('5~',d.CHARGE_PROCEDURE_ID)		AS DenialProcedureCode
	,d.PRIMARY_DIAGNOSIS_ID					AS DenialDiagnosisID
	,d.INVOICE_NUMBER						AS DenialInvoiceNumber
	,dr.REASON_CODE							AS DenialReasonCode
	,dr.REASON_CODE_NAME					AS DenialReasonDescription
	,d.DENIAL_CATEGORY						AS DenialCategory
	,d.DENIAL_CAUSE							AS DenialCause
	,d.ROOT_CAUSE							AS DenialRootCause
	,d.BDC_REASON_CODE_GROUP				AS DenialReasonGroup
	,d.RESOLUTION_CATEGORY					AS DenialResolutionCategory
	,d.DENIAL_STATUS						AS DenialStatus
	,d.PRIMARY_DENIAL_FLAG					AS DenialIsPrimary
	,d.FIRST_DENIAL_FLAG					AS DenialIsFirst
	,d.DENIAL_POST_DATE						AS DenialPostingDate
	,d.DENIAL_COMPLETE_DATE					AS DenialCompletionDate
	,d.DAYS_TO_CLOSE						AS DenialDaysToClose
	,d.DENIED_AMOUNT						AS DenialAmount
	,d.RECOVERY_AMOUNT						AS DenialRecoveryAmount
	,d.ADJUSTMENT_AMOUNT					AS DenialAdjustmentAmount
	,d.BILLED_AMOUNT						AS DenialBillingAmount
	,GETDATE()								AS DenialUpdateDate
INTO #TempDenials
FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].V_CUBE_F_PB_DENIALS d

LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].X_CUBE_D_REASON_CODE dr
	ON d.REASON_CODE_ID = dr.REASON_CODE_ID

	--DROP TABLE #TempDenials
------------------------------------------------------------------------------------------------------------
/* Delete dupicate denial values */
------------------------------------------------------------------------------------------------------------

PRINT 'Deleting old duplicate denial records...'
DELETE fact.DenialsPB
	WHERE 1=1
		AND DenialID IN(SELECT CONCAT('5~',DenialID) FROM #TempDenials)

------------------------------------------------------------------------------------------------------------
/* Insert new denial values */
------------------------------------------------------------------------------------------------------------

PRINT 'Inserting new denial records...'
INSERT INTO fact.DenialsPB(
	DenialID
	,DenialDataSourceID
	,DenialTransactionID
	,DenialTransactionChargeID
	,ChargePostingDate
	,ChargeServiceDate
	,DenialReceiveDate
	,DenialProcedureID
	,DenialPatientID
	,DenialLocationID
	,DenialDepartmentID
	,DenialBillingProviderID
	,DenialServiceProviderID
	,DenialPayerID
	,DenialPayerPlanID
	,DenialProcedureCode
	,DenialDiagnosisID
	,DenialInvoiceNumber
	,DenialReasonCode
	,DenialReasonDescription
	,DenialCategory
	,DenialCause
	,DenialRootCause
	,DenialReasonGroup
	,DenialResolutionCategory
	,DenialStatus
	,DenialIsPrimary
	,DenialIsFirst
	,DenialPostingDate
	,DenialCompletionDate
	,DenialDaysToClose
	,DenialAmount
	,DenialRecoveryAmount
	,DenialAdjustmentAmount
	,DenialBillingAmount
	,DenialUpdateDate
)
SELECT
	DenialID
	,DenialDataSourceID
	,DenialTransactionID
	,DenialTransactionChargeID
	,ChargePostingDate
	,ChargeServiceDate
	,DenialReceiveDate
	,DenialProcedureID
	,DenialPatientID
	,DenialLocationID
	,DenialDepartmentID
	,DenialBillingProviderID
	,DenialServiceProviderID
	,DenialPayerID
	,DenialPayerPlanID
	,DenialProcedureCode
	,DenialDiagnosisID
	,DenialInvoiceNumber
	,DenialReasonCode
	,DenialReasonDescription
	,DenialCategory
	,DenialCause
	,DenialRootCause
	,DenialReasonGroup
	,DenialResolutionCategory
	,DenialStatus
	,DenialIsPrimary
	,DenialIsFirst
	,DenialPostingDate
	,DenialCompletionDate
	,DenialDaysToClose
	,DenialAmount
	,DenialRecoveryAmount
	,DenialAdjustmentAmount
	,DenialBillingAmount
	,DenialUpdateDate
FROM #TempDenials

--WHERE 1=1

;END TRY
BEGIN CATCH
	PRINT ERROR_MESSAGE()
	PRINT 'ROLLING BACK DELETION'
	ROLLBACK;
END CATCH;

	
END
GO
