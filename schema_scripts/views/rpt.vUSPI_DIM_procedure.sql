CREATE VIEW [rpt].[vUSPI_DIM_procedure] AS
SELECT 
    '5' as company_code,         -- Static company code
    '5~430' AS facility_code,                                           -- Placeholder for facility code
    eap.PROC_CODE AS procedure_code,                                 -- Procedure code
    eap.PROC_NAME AS procedure_description,                          -- Procedure description
    eap.PROC_TYPE AS procedure_type,                                 -- Procedure type
    CASE 
        WHEN cdp.SELFPAY_INSURANCE_INDICATOR IN ('Self-Pay', 'Both') THEN 'Yes'
        ELSE 'No'
    END AS medicare_approved_flag,                                   -- Medicare approved flag
    NULL AS medicare_grouping,                          -- Procedure category description
    cdp.REVENUE_CODE AS revenue_code,                                -- Revenue code
    rc.REVENUE_CODE_NAME AS revenue_description,                       -- Revenue description (fallback to procedure name)
    NULL AS service_type,                            -- Service type from procedure category
    'EPIC' AS source_system,                                         -- Static source system
    GETDATE() AS create_date,                                        -- Current timestamp
    GETDATE() AS update_date,                                        -- Current timestamp for updates
    --ISNULL(MAX(ht.TX_AMOUNT), 0)
	NULL AS fee,                          -- Fee (average length for billing used as proxy)
    NULL AS apc_grouper,                                             -- Placeholder for APC grouper
    NULL AS apc_description,                                         -- Placeholder for APC description
    NULL AS cms_quality_code                                         -- Placeholder for CMS quality code
FROM 
    [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[dbo].[CLARITY_EAP] eap

LEFT JOIN 
    [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[V_CUBE_D_PROCEDURE] cdp
    ON eap.PROC_ID = cdp.PROCEDURE_ID

--LEFT JOIN 
--    [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[HSP_TRANSACTIONS] ht
--    ON eap.PROC_ID = ht.PROC_ID

LEFT JOIN
	[CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].CL_UB_REV_CODE rc
	ON rc.REVENUE_CODE = cdp.REVENUE_CODE

WHERE 
    eap.RECORD_STATE_EAP_C IS NULL                                 -- Filter out inactive or duplicate records
GO
