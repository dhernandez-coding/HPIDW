CREATE VIEW [rpt].[VUSPI_Fact_PhysicalTherapy_Orders] AS
SELECT 
    d.DepartmentLocationID AS facility_id,
    l.LocationName AS facility_name,
    CAST(t.TransactionDateOfService AS DATE) AS service_date,
    'Physical Therapy' AS master_department,
    CASE 
        WHEN d.DepartmentName LIKE '%South%' THEN 'Outpatient PT South - Therapist'
        WHEN d.DepartmentName LIKE '%Edmond%' OR d.DepartmentName LIKE '%Edmont%' THEN 'Outpatient PT Edmont - Therapist'
        WHEN d.DepartmentName LIKE '%Hand%' THEN 'Outpatient PT Hand - Therapist'
        ELSE 'Physical Therapy-Therapist'
    END AS sub_department,
    'PT units' AS unit_of_service,
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
  AND (d.DepartmentName LIKE '%PT%' 
    OR d.DepartmentName LIKE '%Therapy%' 
    OR d.DepartmentName LIKE '%Physical%')
  AND d.DepartmentName NOT LIKE '%RT%' -- Exclude Respiratory Therapy
  AND t.TransactionRevenueCode in (
      '420','421','422','423','424','429','430','431','432','433','434','439','440','441','442','443','444','449',
      '0420','0421','0422','0423','0424','0429','0430','0431','0432','0433','0434','0439','0440','0441','0442','0443','0444','0449'
  )
GROUP BY 
    d.DepartmentLocationID,
    l.LocationName,
    CAST(t.TransactionDateOfService AS DATE),
    CASE 
        WHEN d.DepartmentName LIKE '%South%' THEN 'Outpatient PT South - Therapist'
        WHEN d.DepartmentName LIKE '%Edmond%' OR d.DepartmentName LIKE '%Edmont%' THEN 'Outpatient PT Edmont - Therapist'
        WHEN d.DepartmentName LIKE '%Hand%' THEN 'Outpatient PT Hand - Therapist'
        ELSE 'Physical Therapy-Therapist'
    END;
GO
