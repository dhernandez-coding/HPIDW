CREATE VIEW [rpt].[vUSPI_DIM_visittype] AS
SELECT 
    '5' AS company_code,                         -- Static company code
    NULL AS facility_code,                       -- Placeholder for facility code
    vt.VisitTypeSourceID AS visit_type_code,     -- Visit type code
    vt.VisitTypeName AS visit_type_desc,         -- Visit type description
    vt.VisitTypeID AS visit_type_num,            -- Visit type numeric ID
    'EPIC' AS source_system,                     -- Static source system
    GETDATE() AS create_date,                    -- Current date/time for record creation
    vt.VisitTypeUpdatedDatetime AS update_date   -- Last update datetime from the source
	 /*GEt rid of current visit_type_num*/
FROM 
    [HPIDW].[dim].[VisitTypes] vt
WHERE 
    vt.VisitTypeIsActive = 1
GO
