CREATE   VIEW [rpt].[VUSPI_Fact_Radiology_Orders] AS
SELECT 
    d.DepartmentLocationID AS facility_id,
    l.LocationName AS facility_name,
    CAST(t.TransactionDateOfService AS DATE) AS service_date,
    'Radiology' AS master_department,
    CASE 
        WHEN d.DepartmentName LIKE '%CT%' THEN 'Ct Scan-Tech''s'
        WHEN d.DepartmentName LIKE '%MRI%' THEN 'Mri-Tech''s'
        WHEN d.DepartmentName LIKE '%Ultrasound%' THEN 'Ultrasound-Tech''s'
        ELSE 'Radiology-Tech''s'
    END AS sub_department,
    'Radiology charge lines' AS unit_of_service,
    'count' AS unit_type,
    COUNT(t.TransactionID) AS actual_volume
FROM fact.Transactions2 t
JOIN dim.vDepartments d ON t.TransactionDepartmentID = d.DepartmentID
LEFT JOIN dim.vLocations l ON l.LocationID = d.DepartmentLocationID
WHERE t.TransactionDatasourceID = 5
  AND t.TransactionIsActive = 1
  AND t.TransactionDateOfVoid IS NULL
  AND d.DepartmentLocationID IN (
      '5~43001006','5~43001007','5~43001008','5~43002001','5~43004001',
      '5~43004002','5~43004003','5~43004004','5~43005005','5~43005006',
      '5~43005007','5~43005008','5~43006001','5~43006002','5~43006003',
      '5~43006004','5~430050061'
  )
  AND (d.DepartmentName LIKE '%Radiology%' 
    OR d.DepartmentName LIKE '%MRI%' 
    OR d.DepartmentName LIKE '%CT%' 
    OR d.DepartmentName LIKE '%Ultrasound%' 
    OR d.DepartmentName LIKE '%Mammo%' 
    OR d.DepartmentName LIKE '%Imaging%')
GROUP BY 
    d.DepartmentLocationID,
    l.LocationName,
    CAST(t.TransactionDateOfService AS DATE),
    CASE 
        WHEN d.DepartmentName LIKE '%CT%' THEN 'Ct Scan-Tech''s'
        WHEN d.DepartmentName LIKE '%MRI%' THEN 'Mri-Tech''s'
        WHEN d.DepartmentName LIKE '%Ultrasound%' THEN 'Ultrasound-Tech''s'
        ELSE 'Radiology-Tech''s'
    END;
GO
