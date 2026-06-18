CREATE VIEW rpt.vUSPI_DIM_revenue_code AS
SELECT 
    '5' AS company_code,                        -- Static company code
    NULL AS facility_code,                      -- Placeholder for facility code
    rc.REVENUE_CODE AS revenue_code,                -- Revenue code from the table
    rc.REVENUE_CODE_NAME AS revenue_desc,                -- Revenue description
    'EPIC' AS source_system,                    -- Static source system
    GETDATE() AS create_date,                   -- Current date/time for record creation
    GETDATE() AS update_date                         -- Placeholder for update date
FROM 
    [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].CL_UB_REV_CODE rc
WHERE 
    rc.REVENUE_CODE IS NOT NULL;
GO
