CREATE VIEW [rpt].[vUSPI_Fact_Stats_Respiratory_Treatments] AS
SELECT 
    d.DepartmentLocationID AS facility_id,
    l.LocationName AS facility_name,
    CAST(t.TransactionDateOfService AS DATE) AS service_date,
    'Respiratory' AS master_department,
    '' AS sub_department,
    'Respiratory treatments' AS unit_of_service,
    'count' AS unit_type,
    SUM(t.TransactionUnits) AS actual_volume

FROM fact.Transactions2 t
	LEFT JOIN dim.vDepartments d ON t.TransactionDepartmentID = d.DepartmentID
	LEFT JOIN dim.vLocations l ON l.LocationID = d.DepartmentLocationID
WHERE 1=1
  AND t.TransactionDatasourceID = 5
  AND t.TransactionIsActive = 1
  AND t.TransactionType = 'Charge'
  AND t.TransactionDateOfVoid IS NULL
  AND d.DepartmentLocationID IN (
      '5~43001006','5~43001007','5~43001008','5~43002001','5~43004001',
      '5~43004002','5~43004003','5~43004004','5~43005005','5~43005006',
      '5~43005007','5~43005008','5~43006001','5~43006002','5~43006003',
      '5~43006004','5~430050061'
  )
  --AND (d.DepartmentName LIKE '%RT%' 
		--OR d.DepartmentName LIKE '%Resp%')
  AND t.TransactionRevenueCode in (
      '976','410','412','419'
  )
GROUP BY 
    d.DepartmentLocationID,
    l.LocationName,
    CAST(t.TransactionDateOfService AS DATE);
GO
