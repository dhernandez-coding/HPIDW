CREATE VIEW [rpt].[vUSPI_DIM_facility] AS
SELECT 
    '5~' + CAST(l.LOC_ID AS VARCHAR(50)) AS facility_code,
    5 AS company_code, -- Assuming constant value as an example
    l.LOC_NAME AS facility_name,
    l.POS_TYPE AS facility_type, 
    p.CITY AS city,
    s.ABBR AS state,
    NULL AS region, 
    'USA' AS country, 
    'EPIC' AS source_system, -- Assuming 'EPIC' as source
    '2024-12-26 17:27:48.257' AS create_date, -- Current date/time for ETL
    GETDATE() AS update_date, -- NULL for update_date initially
    l.LOC_ID AS source_facility_code,
    l.LOC_ID AS facility_npi 
FROM 
    [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[CLARITY_LOC] l
LEFT JOIN 
    [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[CLARITY_POS] p 
    ON l.LOC_ID = p.POS_ID
LEFT JOIN 
    [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[ZC_STATE] s 
    ON p.STATE_C = s.STATE_C
WHERE 
    l.SERV_AREA_ID IN (430); --Should we include TPG 425?
GO
