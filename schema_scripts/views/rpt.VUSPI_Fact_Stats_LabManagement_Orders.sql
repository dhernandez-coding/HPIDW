CREATE VIEW [rpt].[VUSPI_Fact_LabManagement_Orders] AS
SELECT 
    d.DepartmentLocationID AS facility_id,
    l.LocationName AS facility_name,
    CAST(t.TransactionDateOfService AS DATE) AS service_date,
    'Lab Management' AS master_department,
    'Laboratory-Tech''s' AS sub_department,
    'Lab units' AS unit_of_service,
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
  AND (d.DepartmentName LIKE '%Laboratory%' 
    OR d.DepartmentName LIKE '%LAB%' 
    OR d.DepartmentName LIKE '%BLOOD BANK%')
  AND t.TransactionRevenueCode in (
      '300','301','302','303','304','305','306','307','309','310','311','312','314','319','390','391','392','399',
      '0300','0301','0302','0303','0304','0305','0306','0307','0309','0310','0311','0312','0314','0319','0390','0391','0392','0399'
  )
GROUP BY 
    d.DepartmentLocationID,
    l.LocationName,
    CAST(t.TransactionDateOfService AS DATE);
GO
