CREATE VIEW [rpt].[vUSPI_DIM_icd9_code] AS
SELECT 
    '5' AS company_code,                                      -- Static value for company code
    '5~430' AS facility_code,                                     -- Facility code (add join logic if needed)
    edg.CURRENT_ICD9_LIST AS icd9_code,                                -- ICD-9 diagnosis code
    DX_NAME AS icd9_desc,                                         -- Description; add join logic if available
    NULL AS drg_with_complication,                             -- Placeholder for DRG complication flag
    NULL AS drg_no_complication,                               -- Placeholder for DRG non-complication flag
    'EPIC' AS source_system,                                   -- Static source identifier
    GETDATE() AS create_date,                                  -- Current ETL timestamp
    GETDATE() AS update_date                                        -- Initially NULL for updates
FROM 
    [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[CLARITY_EDG] edg
WHERE 
    edg.CURRENT_ICD9_LIST IS NOT NULL;
GO
