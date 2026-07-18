CREATE VIEW [rpt].[VUSPI_Fact_Surgery_ORMinutes] AS

SELECT 
    vc.VisitCaseLocationID AS facility_id,
    l.LocationName AS facility_name,
    vc.VisitCaseServiceDate AS service_date,
    'Surgery' AS master_department,
    CASE 
        WHEN vc.VisitCaseService = 'Pain Management' THEN 'Pain Management-Rn''s' 
        ELSE 'Surgery-Rn''s' 
    END AS sub_department,
    'OR Minutes' AS unit_of_service,
    'Minutes' AS unit_type,
    SUM(CAST(vc.VisitCaseMinutesInOR AS DECIMAL(18,2))) AS actual_volume
FROM fact.VisitCases vc
LEFT JOIN dim.vLocations l ON l.LocationID = vc.VisitCaseLocationID
WHERE vc.VisitCaseDatesourceID = 5
  AND vc.VisitCaseLocationID IN (
      '5~43001006','5~43001007','5~43001008','5~43002001','5~43004001',
      '5~43004002','5~43004003','5~43004004','5~43005005','5~43005006',
      '5~43005007','5~43005008','5~43006001','5~43006002','5~43006003',
      '5~43006004','5~430050061'
  )
  AND vc.VisitCaseMinutesInOR IS NOT NULL
GROUP BY 
    vc.VisitCaseLocationID,
    l.LocationName,
    vc.VisitCaseServiceDate,
    CASE 
        WHEN vc.VisitCaseService = 'Pain Management' THEN 'Pain Management-Rn''s' 
        ELSE 'Surgery-Rn''s' 
    END;
GO
