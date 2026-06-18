CREATE VIEW [rpt].[vUSPI_DIM_financial_class] AS
SELECT 
    
    '5' AS company_code,                                                    
    '5~430' AS facility_code,
	'5~' + CAST(f.FINANCIAL_CLASS AS VARCHAR(50)) AS financial_class_code,
    f.FINANCIAL_CLASS_NAME AS financial_class_desc,                       -- Description of the financial class
    'EPIC' AS source_system,                                              -- Static source system
    GETDATE() AS create_date,                                             -- Record creation timestamp
    GETDATE() AS update_date                                                   -- Initially NULL for update tracking
FROM 
    [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[CLARITY_FC] f
WHERE 
    f.FINANCIAL_CLASS IS NOT NULL;
GO
