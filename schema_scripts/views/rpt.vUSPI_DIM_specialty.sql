CREATE VIEW rpt.vUSPI_DIM_specialty AS
SELECT 
    5 AS company_code, -- Static company code
    NULL AS facility_code,                                    -- Facility code as placeholder
    s.SPECIALTY_C AS specialty_code,                          -- Specialty code
    s.NAME AS specialty_desc,                                 -- Specialty description
    CAST(s.SPECIALTY_C AS NUMERIC(12, 0)) AS specialty_num,   -- Numeric representation of specialty
    'EPIC' AS source_system,                                  -- Static source system
    GETDATE() AS create_date,                                 -- Current timestamp for creation
    GETDATE() AS update_date                                  -- Current timestamp for updates
FROM 
    [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_SPECIALTY s;
GO
