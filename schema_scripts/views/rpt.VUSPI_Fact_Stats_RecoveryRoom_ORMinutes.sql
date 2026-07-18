CREATE VIEW [rpt].[VUSPI_Fact_RecoveryRoom_ORMinutes] AS

SELECT 
    vc.VisitCaseLocationID AS facility_id,
    l.LocationName AS facility_name,
    vc.VisitCaseServiceDate AS service_date,
    'Recovery Room' AS master_department,
    'Recovery-Rn''s' AS sub_department,
    'PACU Minutes (I+II)' AS unit_of_service,
    'Minutes' AS unit_type,
    SUM(CAST(COALESCE(vc.VisitCaseMinutesInRecovery, 0) + COALESCE(vc.VisitCaseMinutesInPhase2, 0) AS DECIMAL(18,2))) AS actual_volume
FROM fact.VisitCases vc
LEFT JOIN dim.vLocations l ON l.LocationID = vc.VisitCaseLocationID
WHERE vc.VisitCaseDatesourceID = 5
  AND vc.VisitCaseLocationID IN (
      '5~43001006','5~43001007','5~43001008','5~43002001','5~43004001',
      '5~43004002','5~43004003','5~43004004','5~43005005','5~43005006',
      '5~43005007','5~43005008','5~43006001','5~43006002','5~43006003',
      '5~43006004','5~430050061'
  )
  AND (vc.VisitCaseMinutesInRecovery IS NOT NULL OR vc.VisitCaseMinutesInPhase2 IS NOT NULL)
GROUP BY 
    vc.VisitCaseLocationID,
    l.LocationName,
    vc.VisitCaseServiceDate;
GO
