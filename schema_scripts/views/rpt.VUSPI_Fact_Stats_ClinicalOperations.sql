CREATE VIEW [rpt].[VUSPI_Fact_Stats_ClinicalOperations] AS
SELECT 
    a.AccountLocationID AS facility_id,
    l.LocationName AS facility_name,
    CAST(a.AccountDateOfAdmission AS DATE) AS service_date,
    'Clinical Operations' AS master_department,
    CASE 
        WHEN a.AccountClass = 'Inpatient' THEN 'Inpatient'
        ELSE 'Observation'
    END AS sub_department,
    'Patient Days' AS unit_of_service,
    'days' AS unit_type,
    SUM(DATEDIFF(day, a.AccountDateOfAdmission, a.AccountDateOfDischarge)) AS actual_volume
FROM fact.vAccounts a
LEFT JOIN dim.vLocations l ON l.LocationID = a.AccountLocationID
WHERE a.AccountDataSourceID = 5
  AND a.AccountIsActive = 1
  AND (a.AccountClass = 'Inpatient' OR (a.AccountClass = 'Outpatient' AND a.AccountType = 'Observation'))
  AND a.AccountLocationID IN (
      '5~43001006','5~43001007','5~43001008','5~43002001','5~43004001',
      '5~43004002','5~43004003','5~43004004','5~43005005','5~43005006',
      '5~43005007','5~43005008','5~43006001','5~43006002','5~43006003',
      '5~43006004','5~430050061'
  )
  AND a.AccountDateOfAdmission IS NOT NULL
  AND a.AccountDateOfDischarge IS NOT NULL
  AND DATEDIFF(day, a.AccountDateOfAdmission, a.AccountDateOfDischarge) >= 1
GROUP BY 
    a.AccountLocationID,
    l.LocationName,
    CAST(a.AccountDateOfAdmission AS DATE),
    CASE 
        WHEN a.AccountClass = 'Inpatient' THEN 'Inpatient'
        ELSE 'Observation'
    END;
GO
