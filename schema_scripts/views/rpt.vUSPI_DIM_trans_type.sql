CREATE VIEW rpt.vUSPI_DIM_trans_type AS
SELECT 
    '5' AS company_code,                                      -- Static company code
    NULL AS facility_code,                                    -- Placeholder for facility code
    CAST(tx.TX_TYPE_HA_C AS VARCHAR(10)) AS transaction_code, -- Transaction type code
    CASE 
        WHEN tx.TX_TYPE_HA_C = 1 THEN 'Charge - New'
        WHEN tx.TX_TYPE_HA_C = 2 THEN 'Payment - Regular'
        WHEN tx.TX_TYPE_HA_C = 3 THEN 'Adjustment - Debit'
        WHEN tx.TX_TYPE_HA_C = 4 THEN 'Adjustment - Credit'
        ELSE 'Unknown Transaction Type'
    END AS transaction_desc,                                 -- Transaction type description
    CASE 
        WHEN tx.TX_TYPE_HA_C = 1 THEN 'Charge'
        WHEN tx.TX_TYPE_HA_C = 2 THEN 'Payment'
        WHEN tx.TX_TYPE_HA_C IN (3, 4) THEN 'Adjustment'
        ELSE 'Other'
    END AS transaction_category_code,                        -- Transaction category
    'EPIC' AS source_system,                                 -- Static source system
    GETDATE() AS create_date,                                -- Record creation timestamp
     GETDATE() AS update_date,                                     -- Placeholder for update timestamp
    NULL AS std_transaction_category_code                     -- Standardized transaction category code
FROM 
    [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].HSP_TRANSACTIONS tx
WHERE 
    tx.TX_TYPE_HA_C IS NOT NULL                             -- Ensure only valid transaction types are included
GROUP BY 
    tx.TX_TYPE_HA_C
GO
