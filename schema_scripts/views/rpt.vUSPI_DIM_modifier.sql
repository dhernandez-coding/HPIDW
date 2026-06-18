CREATE VIEW [rpt].[vUSPI_DIM_modifier] AS
SELECT 
    5 AS company_code,                           -- Static company code
    '5~430' AS facility_code,                          -- Placeholder for facility code
    CAST(EXTERNAL_ID AS VARCHAR(250)) AS modifier_code, -- Corrected modifier code column
    CAST(EXTERNAL_ID AS VARCHAR(250)) AS modifier_key,                  -- Corrected modifier name column
	MODIFIER_NAME AS modifier_description, -- Corrected description column
    'EPIC' AS source_system,                        -- Static source system
    GETDATE() AS create_date,                       -- Current date/time for creation
    GETDATE() AS update_date                        -- Current date/time for updates
FROM 
    [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[dbo].[CLARITY_MOD] m;
GO
