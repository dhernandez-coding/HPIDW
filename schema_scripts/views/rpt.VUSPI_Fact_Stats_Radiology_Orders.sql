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
    'Radiology units' AS unit_of_service,
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
  AND (d.DepartmentName LIKE '%Radiology%' 
    OR d.DepartmentName LIKE '%MRI%' 
    OR d.DepartmentName LIKE '%CT%' 
    OR d.DepartmentName LIKE '%Ultrasound%' 
    OR d.DepartmentName LIKE '%Mammo%' 
    OR d.DepartmentName LIKE '%Imaging%')
  AND (
      t.TransactionRevenueCode in (
          '320','321','322','323','324','329','330','331','332','333','335','339','340','341','342','349','350','351','352','359','400','401','402','403','409','483','610','611','612','614','615','619','921',
          '0320','0321','0322','0323','0324','0329','0330','0331','0332','0333','0335','0339','0340','0341','0342','0349','0350','0351','0352','0359','0400','0401','0402','0403','0409','0483','0610','0611','0612','0614','0615','0619','0921'
      )
      OR t.TransactionCode in (
          '4192471','4192472','4192473','4192474','4192476','4192477','4192478','4192480','4192482','4192483','4192484','4192485','4192486','4192487','4192488','4192489','4192490','4192491','4192492','4192493','4192494','4192495','4192496','4192497','4192498','4192502','4192503','4192505','4193000','4193002','4193003','4193004','4193005','4193006','4193007','4193008','4193009','4192512','4192521','4193010','4193011','4192488','4192490','4192493','4192495','4193002','4193007'
      )
  )
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
