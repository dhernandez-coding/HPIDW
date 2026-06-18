CREATE view [dim].[vDepartments] as

SELECT
	d.[DepartmentID]
	,[DepartmentDataSourceID]
	,[DepartmentSourceID]
	,[DepartmentName]
	,[DepartmentLocationID]
	,l.LocationName as DepartmentLocation
	,[DepartmentParentLocationID]
	,pl.LocationName as DepartmentParentLocation
	,[DepartmentServiceAreaLocationID]
	,sa.LocationName as DepartmentServiceAreaLocation
	,[DepartmentAbbreviation]
	,[DepartmentDescription]
	,[DepartmentStreetAddress1]
	,[DepartmentStreetAddress2]
	,[DepartmentCity]
	,[DepartmentState]
	,[DepartmentZipCode]
	,[DepartmentPhone]
	,[DepartmentFederalTaxID]
	,[DepartmentIsActive]
	,[DepartmentUpdatedDateTime]
	,pd.PracticeID
	,pd.PracticeIDNew
FROM [HPIDW].[dim].[Departments] d 
	LEFT JOIN dim.Locations l ON l.LocationID = d.DepartmentLocationID
	LEFT JOIN dim.Locations pl ON pl.LocationID = d.DepartmentParentLocationID
	LEFT JOIN dim.Locations sa ON sa.LocationID = d.DepartmentServiceAreaLocationID
	LEFT JOIN map.PracticeDepartments pd ON pd.DepartmentID = d.DepartmentID AND pd.PracticeDepartmentIsActive = 1
GO
