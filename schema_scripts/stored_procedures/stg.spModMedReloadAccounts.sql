CREATE   PROCEDURE [etl].[spModMedReloadAccounts]
AS
BEGIN
    SET NOCOUNT ON;

    PRINT 'Step 1: Creating staging table...';

    IF OBJECT_ID('tempdb..#StagingAccounts') IS NOT NULL
        DROP TABLE #StagingAccounts;

    CREATE TABLE #StagingAccounts (
        AccountID                      VARCHAR(100),
        AccountDataSourceID            INT,
        AccountSourceID                VARCHAR(100),
        AccountReferenceNumber         VARCHAR(100),
        AccountPatientID               VARCHAR(100),
        AccountLocationID              VARCHAR(100),
        AccountDepartmentID            VARCHAR(100),
        AccountFinancialClassID        VARCHAR(100),
        AccountPrimaryPayerID          VARCHAR(100),
        AccountPrimaryPayerPlanID      VARCHAR(100),
        AccountPrimaryProviderID       VARCHAR(100),
        AccountAdmittingProviderID     VARCHAR(100),
        AccountAttendingProviderID     VARCHAR(100),
        AccountReferringProviderID     VARCHAR(100),
        AccountDateOfService           DATETIME2,
        AccountDateOfAdmission         DATETIME2,
        AccountDateOfDischarge         DATETIME2,
        AccountDateOfBilling           DATETIME2,
        AccountDateOfClosing           DATETIME2,
        AccountDateOfZeroBalance       DATETIME2,
        AccountDateOfBadDebtWriteOff   DATETIME2,
        AccountTotalCharges            DECIMAL(18,2),
        AccountTotalAdjustments        DECIMAL(18,2),
        AccountTotalPayments           DECIMAL(18,2),
        AccountTotalRefunds            DECIMAL(18,2),
        AccountTotalBalance            DECIMAL(18,2),
        AccountStatus                  VARCHAR(50),
        AccountClass                   VARCHAR(50),
        AccountType                    VARCHAR(50),
        AccountService                 VARCHAR(100),
        AccountBillingStatus           VARCHAR(50),
        AccountCodingStatus            VARCHAR(50),
        AccountCodingStatusDatetime    DATETIME2,
        AccountDRG                     VARCHAR(50),
        AccountDRGDescription          VARCHAR(255),
        AccountDRGType                 VARCHAR(50),
        AccountDRGMDC                  VARCHAR(50),
        AccountDRGCMI                  DECIMAL(10,4),
        AccountDRGGMLOS                DECIMAL(10,4),
        AccountIsRecurring             BIT,
        AccountIsActive                BIT,
        AccountUpdatedDatetime         DATETIME2,
        AccountEmployerName            VARCHAR(255),
        AccountBeneficiaryNumber       VARCHAR(100),
        AccountGuarantorName           VARCHAR(255),
        AccountGuarantorID             VARCHAR(100)
    );

    PRINT 'Step 2: Loading data into staging...';

    INSERT INTO #StagingAccounts
    SELECT
        '15~' + b.bill_id                                AS AccountID,
        15                                               AS AccountDataSourceID,
        '15~' +b.bill_id                                        AS AccountSourceID,
        b.bill_identifier                               AS AccountReferenceNumber,
        '15~' +b.patient_id                                    AS AccountPatientID,
        '15~' +b.practice_location_id                          AS AccountLocationID,
        '15~' +b.business_unit_id                              AS AccountDepartmentID,
        '15~' +b.financial_category_id                         AS AccountFinancialClassID,
        '15~' +b.fee_schedule_primary_payer_id                 AS AccountPrimaryPayerID,
        NULL                                             AS AccountPrimaryPayerPlanID,
        '15~' + COALESCE(b.primary_provider_id, b.operating_provider_id,  b.other_rendering_provider_id)                  AS AccountPrimaryProviderID,
        '15~' + COALESCE(b.primary_provider_id, operating_provider_id,  other_rendering_provider_id)                        AS AccountAdmittingProviderID,
        '15~' + COALESCE(b.primary_provider_id, operating_provider_id,  other_rendering_provider_id)                   AS AccountAttendingProviderID,
        '15~' +b.referral_staff_id                             AS AccountReferringProviderID,

        b.service_date                                  AS AccountDateOfService,
        b.bill_creation_date                            AS AccountDateOfAdmission,
        b.finalized_date                                AS AccountDateOfDischarge,
        b.bill_creation_date                            AS AccountDateOfBilling,
        b.finalized_date                                AS AccountDateOfClosing,
        NULL                                             AS AccountDateOfZeroBalance,
        NULL                                             AS AccountDateOfBadDebtWriteOff,

        b.total_charges                                 AS AccountTotalCharges,
        b.applied_adjustments_total                     AS AccountTotalAdjustments,
        b.total_payments                                AS AccountTotalPayments,
        NULL                                             AS AccountTotalRefunds,
        b.balance                                       AS AccountTotalBalance,

        b.bill_status                                   AS AccountStatus,
        b.bill_type                                     AS AccountClass,
        b.bill_charge_type                              AS AccountType,
        b.bill_visit_specialty                          AS AccountService,
        b.bill_status                                   AS AccountBillingStatus,
        NULL                                             AS AccountCodingStatus,
        NULL                                             AS AccountCodingStatusDatetime,

        NULL                                             AS AccountDRG,
        NULL                                             AS AccountDRGDescription,
        NULL                                             AS AccountDRGType,
        NULL                                             AS AccountDRGMDC,
        NULL                                             AS AccountDRGCMI,
        NULL                                             AS AccountDRGGMLOS,

        0                                                AS AccountIsRecurring,
        1                                                AS AccountIsActive,
        GETDATE()                                        AS AccountUpdatedDatetime,

        NULL                                             AS AccountEmployerName,
        NULL                                             AS AccountBeneficiaryNumber,
        NULL                                             AS AccountGuarantorName,
        NULL                                             AS AccountGuarantorID

    FROM stg.ModMed_Bills b;

    PRINT 'Step 3: Replacing fact.Accounts';

    IF (SELECT COUNT(*) FROM #StagingAccounts) > 0
    BEGIN
        DELETE FROM fact.Accounts
        WHERE AccountDataSourceID = 15;

        INSERT INTO fact.Accounts
        SELECT * FROM #StagingAccounts;
    END
    ELSE
    BEGIN
        PRINT 'No records found. Skipping insert.';
    END

END;
GO
