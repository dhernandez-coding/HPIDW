CREATE PROCEDURE [stg].[spReloadModMedTransactionsPB] AS
BEGIN
    SET NOCOUNT off;

    PRINT 'Step 1: Creating #Staging table…';

    IF OBJECT_ID('tempdb..#Staging') IS NOT NULL DROP TABLE #Staging;

    CREATE TABLE #Staging
    (
        TransactionID                   varchar(100),
        TransactionDatasourceID         int,
        TransactionSourceID             varchar(100),
        TransactionParentSourceID       varchar(100),
        TransactionVisitID              varchar(100),
        TransactionAccountID            varchar(100),
        TransactionDepartmentID         varchar(100), -- Column 7 - MUST be aligned
        TransactionPayerID              varchar(100),
        TransactionBillingProviderID    varchar(100),
        TransactionBillingType          varchar(100),
        TransactionType                 varchar(100),
        TransactionSubType              varchar(100),
        TransactionRevenueCode          varchar(100),
        TransactionRevenueCodeDescription varchar(1000),
        TransactionCode                 varchar(100),
        TransactionDescription          varchar(1000),
        TransactionCPTCode              varchar(100),
        TransactionCPTDescription       varchar(1000),
        TransactionModifier1            varchar(50),
        TransactionModifier2            varchar(50),
        TransactionModifier3            varchar(50),
        TransactionModifier4            varchar(50),
        TransactionICD10Dx1             varchar(50),
        TransactionICD10Dx2             varchar(50),
        TransactionICD10Dx3             varchar(50),
        TransactionICD10Dx4             varchar(50),
        TransactionICD10Dx5             varchar(50),
        TransactionUnits                decimal(9,2),
        TransactionAmount               money,
        TransactionRVU                  decimal(9,2),
        TransactionDateOfService        datetime,
        TransactionDateOfPosting        datetime,
        TransactionDateOfBilling        datetime,
        TransactionDateOfVoid           datetime,
        TransactionReportingPeriodID    varchar(100),
        TransactionPlaceOfServiceCode   varchar(50), -- Column 36
        TransactionPlaceOfServiceType   varchar(100),-- Column 37
        TransactionPatientID            varchar(50),
        TransactionGLType               varchar(10),
        TransactionStatus               varchar(100),
        TransactionIsActive             bit,
        TransactionUpdatedDateTime      datetime,
        TransactionPayerPlanID          varchar(50),
        TransactionPlaceOfService       varchar(100), -- Column 45
        TransactionActiveARAmount       money
    );

    PRINT 'Step 1.1: Loading data from stg tables…';

    INSERT INTO #Staging
    (
        TransactionID, TransactionDatasourceID, TransactionSourceID, TransactionParentSourceID,
        TransactionVisitID, TransactionAccountID, TransactionDepartmentID, TransactionPayerID,
        TransactionBillingProviderID, TransactionBillingType, TransactionType, TransactionSubType,
        TransactionRevenueCode, TransactionRevenueCodeDescription, TransactionCode, TransactionDescription,
        TransactionCPTCode, TransactionCPTDescription, TransactionModifier1, TransactionModifier2,
        TransactionModifier3, TransactionModifier4, TransactionICD10Dx1, TransactionICD10Dx2,
        TransactionICD10Dx3, TransactionICD10Dx4, TransactionICD10Dx5, TransactionUnits,
        TransactionAmount, TransactionRVU, TransactionDateOfService, TransactionDateOfPosting,
        TransactionDateOfBilling, TransactionDateOfVoid, TransactionReportingPeriodID,
        TransactionPlaceOfServiceCode, TransactionPlaceOfServiceType, TransactionPatientID,
        TransactionGLType, TransactionStatus, TransactionIsActive, TransactionUpdatedDateTime,
        TransactionPayerPlanID, TransactionPlaceOfService, TransactionActiveARAmount
    )
    
    ----===============================================================
    ----  1. ChargesPB: One row per CHARGE ID (48 columns)
    ----===============================================================
    SELECT
          '15~' + CAST(c.charges_id AS varchar(100))        AS TransactionID
        , 15                                                AS TransactionDatasourceID
        , CAST(c.charges_id AS varchar(100))                AS TransactionSourceID
        , CAST(c.charges_id AS varchar(100))        AS TransactionParentSourceID

        -- Visit / Account
        , '15~' + CAST(b.visit_id AS varchar(100))          AS TransactionVisitID
        , '15~' + CAST(c.bill_id AS varchar(100))           AS TransactionAccountID
        , CASE 
			    WHEN c.provider_id IN ('219144-pod37', '16609184-pod37') 
			        THEN '15~42'   -- Nguyen & Gillette → Department 42
			
			    WHEN c.provider_id = '18914534-pod37' 
			        THEN '15~45'   -- Buford → Department 45
			
			    ELSE NULL
			END AS TransactionDepartmentID                                             

        -- Financial / Ownership
        , '15~' + 
			CASE 
				WHEN c.payer_id is null and c.coverage_type = 'Self-Pay' THEN '53623-pod37'
				ELSE CAST(c.payer_id AS varchar(100))   END AS TransactionPayerID
			        
        , '15~' + CAST(c.provider_id AS varchar(100))       AS TransactionBillingProviderID
        , 'PB'                                              AS TransactionBillingType

        -- Types
        , 'Charge'                                          AS TransactionType
        , CASE WHEN c.activity_type = 'CHARGE' then 'Charge - New'
				WHEN c.activity_type ='VOID_CHARGE' then 'Charge - Void'   END AS TransactionSubType -- c.bill_status

        -- Revenue / CPT
        , bi.revenue_code                                   AS TransactionRevenueCode
        , c.code_category                                   AS TransactionRevenueCodeDescription
        , COALESCE(bi.code,c.cpt_product)                   AS TransactionCode
        , COALESCE(bi.code_description,c.cpt_product_description) AS TransactionDescription
        , COALESCE(bi.code,c.cpt_product)                   AS TransactionCPTCode
        , COALESCE(bi.code_description,c.cpt_product_description) AS TransactionCPTDescription

        -- Modifiers
        , bi.first_modifier                                 AS TransactionModifier1
        , bi.second_modifier                                AS TransactionModifier2
        , bi.third_modifier                                 AS TransactionModifier3
        , bi.fourth_modifier                                AS TransactionModifier4

        -- ICD — ModMed charges does NOT store DX (5 NULLs)
        , NULL AS TransactionICD10Dx1
        , NULL AS TransactionICD10Dx2
        , NULL AS TransactionICD10Dx3
        , NULL AS TransactionICD10Dx4
        , NULL AS TransactionICD10Dx5

        -- Units / Amount
        , c.ledger_units                                    AS TransactionUnits
        , c.ledger_charge_amount                            AS TransactionAmount
        , bi.wrvu                                           AS TransactionRVU

        -- Dates
        , TRY_CONVERT(datetime, c.service_date_from_ld)     AS TransactionDateOfService
        , TRY_CONVERT(datetime, c.post_date_ld)             AS TransactionDateOfPosting
        , TRY_CONVERT(datetime, b.finalized_date)           AS TransactionDateOfBilling
        , NULL                                              AS TransactionDateOfVoid

        -- Reporting period
        , CONCAT(YEAR(c.post_date_ld), ' - ',
                 RIGHT('00' + CAST(MONTH(c.post_date_ld) AS varchar(2)), 2)) AS TransactionReportingPeriodID

        -- Location / Patient / Status (ALIGNED with #Staging)
        , c.service_location_pos_code      --'15~' + CAST(c.facility_id AS varchar(100))       AS TransactionPlaceOfServiceCode -- ALIGNED
        , NULL                                              AS TransactionPlaceOfServiceType -- ALIGNED
        , '15~' + CAST(bi.patient_id AS varchar(100))        AS TransactionPatientID
        ,CASE --WHEN tx.[Appt_Type_Abbr] in ('SB','SB GWILL') or tx.[Appt_Resource_Descr] like '%smartbeat%' and tx.CPT_CODE in ('92250','93000','93308','93321','93325','93882','93922','93979','94010') THEN 'Smartbeat'
			WHEN bi.code  in ('MPDC', '93922') THEN 'MaxPulse'
			WHEN bi.code  like '7%' and (bi.first_modifier = 'TC' OR bi.second_modifier = 'TC') THEN 'RadTC'
			WHEN pc.[ProcedureCodeCategory] = 'XRAY Only Visits' THEN 'Xray'
			WHEN pc.[ProcedureCodeServiceLine] = 'DME' THEN 'DME'
			WHEN pc.[ProcedureCodeCategory] = 'Ultrasound Only Visit' THEN 'Ultrasound' 
			WHEN pc.[ProcedureCodeCategory] = 'Lab Only Visit' THEN 'Lab' 
			--WHEN (tx.[Appt_Type_Abbr] = 'ANS GWIL' or tx.[Appt_Resource_Descr] = 'AUTONOMIC NERVE TESTING-GWIL') and (tx.[Patient_ID] is not null) and (tx.[Appt_Status] <> 'X' and tx.[Appt_Status] <> 'N')  THEN 'ANS'  
			WHEN bi.code  in ('51729', '51797', '51784', '51741') THEN 'URO'  
			WHEN bi.code  in ('99453', '99454', '99457', '99458', '95249', '95250', '95251') THEN 'Heartcloud'
			WHEN bi.code  in ('95250', '95251', '95249') THEN 'CGM' END as TransactionGLType                                
        , 'Active'                                          AS TransactionStatus
        , 1                                                 AS TransactionIsActive

        -- Audit metadata
        , c.LoadDateTime                                    AS TransactionUpdatedDateTime

        -- Payer plan / Facility
        , '15~' + CAST(c.insurance_policy_id AS varchar(50)) AS TransactionPayerPlanID
        , c.service_location_pos_code                       AS TransactionPlaceOfService 

        -- AR amount
        , CASE WHEN TRY_CAST(c.ledger_charge_amount AS money) IS NULL
               THEN 0
               ELSE TRY_CAST(c.ledger_charge_amount AS money)
          END                                               AS TransactionActiveARAmount

    FROM stg.ModMed_Charges c
    LEFT JOIN stg.ModMed_BillItems bi  ON bi.bill_item_id = c.bill_item_id
    LEFT JOIN stg.ModMed_Bills b       ON b.bill_id       = c.bill_id
	LEFT JOIN [HPIDW].[dim].[vPBProcedureCodeCategories] pc ON pc.ProcedureCode = COALESCE(bi.code, c.cpt_product)



    UNION ALL

    ----===============================================================
    ----  2. AdjPB: One row per Adj (48 columns)
    ----===============================================================

    SELECT
         '15~' + CAST(c.charges_id AS varchar(100)) + '~' + a.adjustment_id AS TransactionID
        , 15                                                AS TransactionDatasourceID
        , CAST(a.adjustment_id AS varchar(100))             AS TransactionSourceID
        , CAST(c.charges_id AS varchar(100))        AS TransactionParentSourceID

        -- Visit / Account
        , '15~' + CAST(b.visit_id AS varchar(100))          AS TransactionVisitID
        , '15~' + CAST(c.bill_id AS varchar(100))           AS TransactionAccountID
        , CASE 
			    WHEN c.provider_id IN ('219144-pod37', '16609184-pod37') 
			        THEN '15~42'   -- Nguyen & Gillette → Department 42
			
			    WHEN c.provider_id = '18914534-pod37' 
			        THEN '15~45'   -- Buford → Department 45
			
			    ELSE NULL
			END AS TransactionDepartmentID

        -- Financial / Ownership
        , '15~' + 
			CASE 
				WHEN c.payer_id is null and c.coverage_type = 'Self-Pay' THEN '53623-pod37'
				ELSE CAST(c.payer_id AS varchar(100))   END AS TransactionPayerID
        , '15~' + CAST(c.provider_id AS varchar(100))       AS TransactionBillingProviderID
        , 'PB'                                              AS TransactionBillingType

        -- Types
        , 'Adjustment'                                      AS TransactionType
        , CASE WHEN a.activity_type =   'ADJUSTMENT'   then 'Adjustment'
				WHEN a.activity_type =   'VOID_ADJUSTMENT' then 'Adjustment - Void'
				WHEN a.activity_type =   'CHARGE_ADJUSTMENT' then 'Adjustment - Charge' END AS TransactionSubType --a.bill_item_adjustment_status]

        -- Revenue / CPT
        , NULL                                              AS TransactionRevenueCode
        , NULL                                              AS TransactionRevenueCodeDescription
        , a.[bill_item_adjustment_reason_code]              AS TransactionCode
        , a.adjustment_reason                               AS TransactionDescription
        , a.cpt_product                                     AS TransactionCPTCode
        , a.[cpt_product_description]                       AS TransactionCPTDescription

        -- Modifiers
        , bi.first_modifier                                 AS TransactionModifier1
        , bi.second_modifier                                AS TransactionModifier2
        , bi.third_modifier                                 AS TransactionModifier3
        , bi.fourth_modifier                                AS TransactionModifier4

        -- ICD — ModMed charges does NOT store DX (5 NULLs)
        , NULL AS TransactionICD10Dx1
        , NULL AS TransactionICD10Dx2
        , NULL AS TransactionICD10Dx3
        , NULL AS TransactionICD10Dx4
        , NULL AS TransactionICD10Dx5

        -- Units / Amount
        , c.ledger_units                                    AS TransactionUnits
        , a.adjustment_amount    * -1                       AS TransactionAmount
        , bi.wrvu                                           AS TransactionRVU

        -- Dates
        , TRY_CONVERT(datetime, a.service_date_from_ld)     AS TransactionDateOfService
        , TRY_CONVERT(datetime, a.posted_date)             AS TransactionDateOfPosting
        , TRY_CONVERT(datetime, b.finalized_date)           AS TransactionDateOfBilling
        , NULL                                              AS TransactionDateOfVoid

        -- Reporting period
        , CONCAT(YEAR(a.posted_date), ' - ',
                 RIGHT('00' + CAST(MONTH(a.posted_date) AS varchar(2)), 2)) AS TransactionReportingPeriodID

        -- Location / Patient / Status (ALIGNED with #Staging)
        , '15~' + CAST(c.facility_id AS varchar(100))       AS TransactionPlaceOfServiceCode -- ALIGNED
        , NULL                                              AS TransactionPlaceOfServiceType -- ALIGNED
        , '15~' + CAST(bi.patient_id AS varchar(100))        AS TransactionPatientID
        , NULL                                              AS TransactionGLType
        , 'Active'                                          AS TransactionStatus
        , 1                                                 AS TransactionIsActive

        -- Audit metadata
        , c.LoadDateTime                                    AS TransactionUpdatedDateTime

        -- Payer plan / Facility
        , '15~' + CAST(c.insurance_policy_id AS varchar(50)) AS TransactionPayerPlanID
        , c.service_location_pos_code                       AS TransactionPlaceOfService -- ALIGNED

        -- AR amount
        , a.adjustment_amount * -1 AS TransactionActiveARAmount  
		/*CASE WHEN TRY_CAST(c.ledger_charge_amount AS money) IS NULL
               THEN 0
               ELSE TRY_CAST(c.ledger_charge_amount AS money)
          END                     * -1                              AS TransactionActiveARAmount*/ --cc - 6/5/26 - Replaced with a.adjustment_amount*-1 as this is what is needed for this column

    FROM stg.ModMed_Adjustments a
		LEFT JOIN stg.ModMed_Charges c on c.[charge_link_key] = a.[charge_link_key]
		LEFT JOIN stg.ModMed_BillItems bi  ON bi.bill_item_id = c.bill_item_id
		LEFT JOIN stg.ModMed_Bills b       ON b.bill_id       = c.bill_id
	WHERE 1=1 
		AND (bill_item_adjustment_status NOT IN ('IGNORE','TRANSFER_RESPONSIBILITY') /*cc - 6/5/26 - Excluded Transfers from Adjustments as they are creating a credit balance*/
			OR bill_item_adjustment_status IS NULL) /*cc - 6/5/26 - Added parentheses around OR statement*/

    UNION ALL

    ----===============================================================
    ----  3. PaymentPB: One row per Payment ID (48 columns)
    ----===============================================================

    SELECT
		
          CASE
			    WHEN p.activity_type = 'PAYMENT' THEN
			        '15~' 
			        + CAST(c.charges_id AS varchar(100)) 
			        + '~' 
			        + CAST(p.payments_posted_id AS varchar(100))
			
			    WHEN p.activity_type = 'VOID_PAYMENT' THEN
			        '15~' 
			        + CAST(c.charges_id AS varchar(100)) 
			        + '~' 
			        + CAST(p.payments_posted_id AS varchar(100))
			        + '~VOID'
			
			    ELSE NULL
			END AS TransactionID
        , 15                                                AS TransactionDatasourceID
        , CAST(p.[payments_posted_id] AS varchar(100))      AS TransactionSourceID
        , CAST(c.charges_id AS varchar(100))        AS TransactionParentSourceID

        -- Visit / Account
        , '15~' + CAST(b.visit_id AS varchar(100))          AS TransactionVisitID
        , '15~' + CAST(c.bill_id AS varchar(100))           AS TransactionAccountID
        , CASE 
			    WHEN c.provider_id IN ('219144-pod37', '16609184-pod37') 
			        THEN '15~42'   -- Nguyen & Gillette → Department 42
			
			    WHEN c.provider_id = '18914534-pod37' 
			        THEN '15~45'   -- Buford → Department 45
			
			    ELSE NULL
			END AS TransactionDepartmentID

        -- Financial / Ownership
        , '15~' + 
			CASE 
				WHEN c.payer_id is null and c.coverage_type = 'Self-Pay' THEN '53623-pod37'
				ELSE CAST(c.payer_id AS varchar(100))   END AS TransactionPayerID
        , '15~' + CAST(p.provider_id AS varchar(100))       AS TransactionBillingProviderID
        , 'PB'                                              AS TransactionBillingType

        -- Types
        , 'Payment'                                          AS TransactionType
        , CASE WHEN p.activity_type =  'PAYMENT' then 'Payment - New'
				WHEN p.activity_type =  'VOID_PAYMENT' then 'Payment - Void' END AS TransactionSubType --p.activity_type p.payment_code                                    AS TransactionSubType --p.activity_type   

        -- Revenue / CPT
        , NULL                                              AS TransactionRevenueCode
        , NULL                                              AS TransactionRevenueCodeDescription
        , p.payment_code                                    AS TransactionCode
        , p.payment_code_description                        AS TransactionDescription
        , p.cpt_product                                     AS TransactionCPTCode
        , p.cpt_product_description                         AS TransactionCPTDescription

        -- Modifiers
        , bi.first_modifier                                 AS TransactionModifier1
        , bi.second_modifier                                AS TransactionModifier2
        , bi.third_modifier                                 AS TransactionModifier3
        , bi.fourth_modifier                                AS TransactionModifier4

        -- ICD — ModMed charges does NOT store DX (5 NULLs)
        , NULL AS TransactionICD10Dx1
        , NULL AS TransactionICD10Dx2
        , NULL AS TransactionICD10Dx3
        , NULL AS TransactionICD10Dx4
        , NULL AS TransactionICD10Dx5

        -- Units / Amount
        , c.ledger_units                                    AS TransactionUnits
        , p.ledger_payment_amount                      * -1 AS TransactionAmount
        , bi.wrvu                                           AS TransactionRVU

        -- Dates
        , TRY_CONVERT(datetime, p.service_date_from_ld)     AS TransactionDateOfService
        , TRY_CONVERT(datetime, P.post_date_ld)             AS TransactionDateOfPosting
        , TRY_CONVERT(datetime, b.finalized_date)           AS TransactionDateOfBilling
        , NULL                                              AS TransactionDateOfVoid

        -- Reporting period
        , CONCAT(YEAR( P.post_date_ld), ' - ',
                 RIGHT('00' + CAST(MONTH( P.post_date_ld) AS varchar(2)), 2)) AS TransactionReportingPeriodID

        -- Location / Patient / Status (ALIGNED with #Staging)
        , '15~' + CAST(c.facility_id AS varchar(100))       AS TransactionPlaceOfServiceCode -- ALIGNED
        , NULL                                              AS TransactionPlaceOfServiceType -- ALIGNED
        , '15~' + CAST(bi.patient_id AS varchar(100))        AS TransactionPatientID
        , NULL                                              AS TransactionGLType
        , 'Active'                                          AS TransactionStatus
        , 1                                                 AS TransactionIsActive

        -- Audit metadata
        , c.LoadDateTime                                    AS TransactionUpdatedDateTime

        -- Payer plan / Facility
        , '15~' + CAST(c.insurance_policy_id AS varchar(50)) AS TransactionPayerPlanID
        , p.service_location_pos_code                       AS TransactionPlaceOfService -- ALIGNED

        -- AR amount
        , p.ledger_payment_amount * -1 AS TransactionActiveARAmount /*cc - 6/5/26 - Replaced with a.adjustment_amount*-1 as this is what is needed for this column*/
		 /*CASE WHEN TRY_CAST(c.ledger_charge_amount AS money) IS NULL
               THEN 0
               ELSE TRY_CAST(c.ledger_charge_amount AS money)
          END                                        * -1           AS TransactionActiveARAmount*/ 

    FROM [stg].[ModMed_Payments] p
    LEFT JOIN (
		SELECT *
		FROM stg.ModMed_Charges
		WHERE activity_type <> 'VOID_CHARGE'
		) c 
    ON c.charge_link_key = p.charge_link_key
    LEFT JOIN stg.ModMed_BillItems bi  ON bi.bill_item_id = c.bill_item_id
    LEFT JOIN stg.ModMed_Bills b       ON b.bill_id       = c.bill_id
	WHERE p.activity_type in ('VOID_PAYMENT','PAYMENT')


UNION ALL
    ----===============================================================
    ----  4. RefundPB: One row per Refund ID 
    ----===============================================================
    SELECT
          '15~' + CAST(c.charges_id AS varchar(100)) + '~' + CAST(r.refunds_id AS varchar(100)) AS TransactionID
        , 15                                                AS TransactionDatasourceID
        , CAST(r.refunds_id AS varchar(100))                AS TransactionSourceID
        , CAST(c.charges_id AS varchar(100))                AS TransactionParentSourceID
        -- Visit / Account
        , '15~' + CAST(b.visit_id AS varchar(100))          AS TransactionVisitID
        , '15~' + CAST(c.bill_id AS varchar(100))           AS TransactionAccountID
        , CASE 
                WHEN c.provider_id IN ('219144-pod37', '16609184-pod37') 
                    THEN '15~42'   -- Nguyen & Gillette → Department 42
                WHEN c.provider_id = '18914534-pod37' 
                    THEN '15~45'   -- Buford → Department 45
                ELSE NULL
            END AS TransactionDepartmentID
        -- Financial / Ownership
        , '15~' + 
            CASE 
                WHEN c.payer_id IS NULL AND c.coverage_type = 'Self-Pay' THEN '53623-pod37'
                ELSE CAST(c.payer_id AS varchar(100)) END AS TransactionPayerID
        , '15~' + CAST(c.provider_id AS varchar(100))       AS TransactionBillingProviderID
        , 'PB'                                              AS TransactionBillingType
        -- Types (Following Epic Pattern)
        , 'Payment'                                         AS TransactionType
        , 'Refund'                                          AS TransactionSubType
        -- Revenue / CPT
        , NULL                                              AS TransactionRevenueCode
        , NULL                                              AS TransactionRevenueCodeDescription
        , r.refund_method                                   AS TransactionCode
        , COALESCE(r.ledger_refund_notes, r.notes)          AS TransactionDescription
        , c.cpt_product                                     AS TransactionCPTCode
        , c.cpt_product_description                         AS TransactionCPTDescription
        -- Modifiers
        , bi.first_modifier                                 AS TransactionModifier1
        , bi.second_modifier                                AS TransactionModifier2
        , bi.third_modifier                                 AS TransactionModifier3
        , bi.fourth_modifier                                AS TransactionModifier4
        -- ICD
        , NULL AS TransactionICD10Dx1
        , NULL AS TransactionICD10Dx2
        , NULL AS TransactionICD10Dx3
        , NULL AS TransactionICD10Dx4
        , NULL AS TransactionICD10Dx5
        -- Units / Amount (Refunds increase balance, offsetting payments)
        , c.ledger_units                                    AS TransactionUnits
        , r.ledger_refund_amount                            AS TransactionAmount
        , bi.wrvu                                           AS TransactionRVU
        -- Dates
        , TRY_CONVERT(datetime, r.ledger_refund_date_created_ld) AS TransactionDateOfService
        , TRY_CONVERT(datetime, r.ledger_refund_date_created_ld) AS TransactionDateOfPosting
        , TRY_CONVERT(datetime, b.finalized_date)           AS TransactionDateOfBilling
        , NULL                                              AS TransactionDateOfVoid
        -- Reporting period
        , CONCAT(YEAR(r.ledger_refund_date_created_ld), ' - ',
                 RIGHT('00' + CAST(MONTH(r.ledger_refund_date_created_ld) AS varchar(2)), 2)) AS TransactionReportingPeriodID
        -- Location / Patient / Status
        , '15~' + CAST(c.facility_id AS varchar(100))       AS TransactionPlaceOfServiceCode
        , NULL                                              AS TransactionPlaceOfServiceType
        , '15~' + CAST(COALESCE(bi.patient_id, r.patient_id) AS varchar(100)) AS TransactionPatientID
        , NULL                                              AS TransactionGLType
        , 'Active'                                          AS TransactionStatus
        , 1                                                 AS TransactionIsActive
        -- Audit metadata
        , r.LoadDateTime                                    AS TransactionUpdatedDateTime
        -- Payer plan / Facility
        , '15~' + CAST(c.insurance_policy_id AS varchar(50)) AS TransactionPayerPlanID
        , r.time_zone                                       AS TransactionPlaceOfService 
        -- AR amount (Mirroring the refund impact)
        , r.ledger_refund_amount                            AS TransactionActiveARAmount
    FROM stg.ModMed_Refunds r
    LEFT JOIN (
        -- NEW LOGIC: Deduplicate payments and link on original_payment_link_key
        SELECT *, ROW_NUMBER() OVER(PARTITION BY payment_link_key ORDER BY (CASE WHEN activity_type = 'PAYMENT' THEN 1 ELSE 2 END), LoadDateTime DESC) as rn
        FROM stg.ModMed_Payments
    ) p ON p.payment_link_key = r.original_payment_link_key AND p.rn = 1
    LEFT JOIN (
        SELECT *
        FROM stg.ModMed_Charges
        WHERE activity_type <> 'VOID_CHARGE'
    ) c ON c.charge_link_key = p.charge_link_key
    LEFT JOIN stg.ModMed_BillItems bi ON bi.bill_item_id = c.bill_item_id
    LEFT JOIN stg.ModMed_Bills b ON b.bill_id = c.bill_id
    WHERE p.payments_posted_id IS NOT NULL




    PRINT 'Step 2: Checking #Staging count…';

    IF (SELECT COUNT(1) FROM #Staging) > 100
    BEGIN
        PRINT 'Step 2.1: More than 100 rows — performing DELETE…';

        DELETE FROM fact.TransactionsPB
        WHERE TransactionDatasourceID = 15;

        PRINT 'Step 2.2: Inserting into fact.TransactionsPB…';

        INSERT INTO fact.TransactionsPB
        (
            TransactionID, TransactionDatasourceID, TransactionSourceID, TransactionParentSourceID,
            TransactionVisitID, TransactionAccountID, TransactionDepartmentID, TransactionPayerID,
            TransactionBillingProviderID, TransactionBillingType, TransactionType, TransactionSubType,
            TransactionRevenueCode, TransactionRevenueCodeDescription, TransactionCode, TransactionDescription,
            TransactionCPTCode, TransactionCPTDescription, TransactionModifier1, TransactionModifier2,
            TransactionModifier3, TransactionModifier4, TransactionICD10Dx1, TransactionICD10Dx2,
            TransactionICD10Dx3, TransactionICD10Dx4, TransactionICD10Dx5, TransactionUnits,
            TransactionAmount, TransactionRVU, TransactionDateOfService, TransactionDateOfPosting,
            TransactionDateOfBilling, TransactionDateOfVoid, TransactionReportingPeriodID,
            TransactionPlaceOfServiceCode, TransactionPlaceOfServiceType, TransactionPatientID,
            TransactionGLType, TransactionStatus, TransactionIsActive, TransactionUpdatedDateTime,
            TransactionPayerPlanID, TransactionPlaceOfService, TransactionActiveARAmount
        )
        SELECT
            TransactionID, TransactionDatasourceID, TransactionSourceID, TransactionParentSourceID,
            TransactionVisitID, TransactionAccountID, TransactionDepartmentID, TransactionPayerID,
            TransactionBillingProviderID, TransactionBillingType, TransactionType, TransactionSubType,
            TransactionRevenueCode, TransactionRevenueCodeDescription, TransactionCode, TransactionDescription,
            TransactionCPTCode, TransactionCPTDescription, TransactionModifier1, TransactionModifier2,
            TransactionModifier3, TransactionModifier4, TransactionICD10Dx1, TransactionICD10Dx2,
            TransactionICD10Dx3, TransactionICD10Dx4, TransactionICD10Dx5, TransactionUnits,
            TransactionAmount, TransactionRVU, TransactionDateOfService, TransactionDateOfPosting,
            TransactionDateOfBilling, TransactionDateOfVoid, TransactionReportingPeriodID,
            TransactionPlaceOfServiceCode, TransactionPlaceOfServiceType, TransactionPatientID,
            TransactionGLType, TransactionStatus, TransactionIsActive, TransactionUpdatedDateTime,
            TransactionPayerPlanID, TransactionPlaceOfService, TransactionActiveARAmount
        FROM #Staging;
    END
    ELSE
    BEGIN
        PRINT 'Less than 100 rows — stopping.';
    END

END
GO
