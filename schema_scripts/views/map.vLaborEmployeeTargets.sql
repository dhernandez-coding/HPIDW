CREATE VIEW [map].[vLaborEmployeeTargets] AS 

WITH EmployeesByDateByDept AS (
	SELECT
		la.paydate,
		la.default_department,
		COUNT(la.paydate) as EmployeeCount
		--,employee_id 
	FROM rpt.vLaborAllocation la

	WHERE 1=1 
		AND paydate is not null

	GROUP BY 
		la.paydate
		,la.default_department
		--,employee_id
	--ORDER BY paydate,default_department
)

--select * from rpt.vLaborAllocation la where la.paydate = '2024-01-12' AND default_department = 'Acute Care Nsg Administration South'

SELECT 
	et.default_department							AS Department
	,et.paydate										AS PayPeriod
	,et.EmployeeCount								AS EmployeeCount
	,ldt.Target										AS DepartmentTarget
	,(ldt.Target/et.EmployeeCount)					AS EmployeeTarget 
	, CONCAT(et.default_department,et.paydate)		AS UniqueID

FROM map.LaborDepartmentTargets ldt
LEFT JOIN EmployeesByDateByDept et
	ON et.default_department = ldt.Department 
		AND et.paydate = ldt.paydate


WHERE et.default_department is not null

--ORDER BY et.paydate, et.default_department
	--AND ebd.row_num = 1

--GROUP BY
	--ebd.default_department,
	--ldt.Department,
	--ldt.Target


-- put the paydate in the department map and join on both
GO
