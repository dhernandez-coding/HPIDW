CREATE VIEW [rpt].[vUSPI_DIM_patient_type] AS
SELECT 

/*Probably They are looking for patient / oupatient  
	SELECT * from [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[ZC_PAT_CLASS] */
    '5~' AS company_code,                      -- Static company code
    NULL AS facility_code,                     -- Placeholder for facility code
    zpt.PAT_TYPE_C AS patient_type_code,       -- Patient type code
    zpt.TITLE AS patient_type_desc,            -- Patient type description
    'EPIC' AS source_system,                   -- Static source system
    GETDATE() AS create_date,                  -- Current timestamp for creation
    GETDATE() AS update_date                   -- Current timestamp for updates
FROM 
    [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[dbo].[ZC_PAT_TYPE] zpt;
GO
