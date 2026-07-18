CREATE VIEW [rpt].[VUSPI_Fact_Pharmacy_Orders] AS
SELECT 
    d.DepartmentLocationID AS facility_id,
    l.LocationName AS facility_name,
    CAST(t.TransactionDateOfService AS DATE) AS service_date,
    'Pharmacy' AS master_department,
    'Pharmacy-Tech''s' AS sub_department,
    'Pharmacy units' AS unit_of_service,
    'count' AS unit_type,
    SUM(t.TransactionUnits) AS actual_volume
FROM fact.Transactions2 t
JOIN dim.vDepartments d ON t.TransactionDepartmentID = d.DepartmentID
LEFT JOIN dim.vLocations l ON l.LocationID = d.DepartmentLocationID
WHERE t.TransactionDatasourceID = 5
  AND t.TransactionIsActive = 1
  AND t.TransactionType = 'Charge'
  AND t.TransactionDateOfVoid IS NULL
  AND d.DepartmentLocationID IN (
      '5~43001006','5~43001007','5~43001008','5~43002001','5~43004001',
      '5~43004002','5~43004003','5~43004004','5~43005005','5~43005006',
      '5~43005007','5~43005008','5~43006001','5~43006002','5~43006003',
      '5~43006004','5~430050061'
  )
  AND (d.DepartmentName LIKE '%Pharmacy%' 
    OR d.DepartmentName LIKE '%Pharm%')
  AND t.TransactionRevenueCode in (
      '250','251','252','253','254','255','257','258','259','260','261','262','263','264','269','630','631','632','633','634','635','636','637',
      '0250','0251','0252','0253','0254','0255','0257','0258','0259','0260','0261','0262','0263','0264','0269','0630','0631','0632','0633','0634','0635','0636','0637'
  )
GROUP BY 
    d.DepartmentLocationID,
    l.LocationName,
    CAST(t.TransactionDateOfService AS DATE);
GO
