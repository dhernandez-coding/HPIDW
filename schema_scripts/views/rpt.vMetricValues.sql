CREATE VIEW rpt.vMetricValues AS

SELECT 
	--[MetricValueID]
	v.[MetricID]		
	,m.MetricName		
	,v.[MetricValueDate]
	,v.[DataSourceID]	
	,v.[LocationID]		
	,l.LocationName		
	,v.[DepartmentID]	
	,d.DepartmentName	
	,v.[ProviderID]		
	,CASE
		WHEN v.ProviderID IS NOT NULL
			THEN CONCAT(pv.ProviderLastName,', ',pv.ProviderFirstName)
		ELSE NULL
	END							AS ProviderFullName
	,v.[PracticeID]					
	,pc.PracticeName				
	,pc.PracticeAbbreviation		
	,v.[PayerID]					
	,py.PayerName					
	,pg.PayerGroupName				
	,v.[ServiceLine]
	,sl.ServiceLineName
	,slg.ServiceLineGroupName
	,v.[ReportGroup1]				
	,v.[ReportGroup2]				
	,v.[ReportGroup3]				
	,v.[ReportGroup4]				
	,v.[ReportGroup5]				
	,v.[ReportGroup6]				
	,v.[ReportGroup7]				
	,v.[MetricValueNumerator]		
	,v.[MetricValueDenominator]		
	,v.[MetricValue]				
	,v.[UpdateDatetime]				
FROM [HPIDW].[rpt].[MetricValues] v

LEFT JOIN dim.locations l
	ON v.LocationID = l.LocationID
LEFT JOIN rpt.Metrics m
	ON v.MetricID = m.MetricID
LEFT JOIN dim.departments d
	ON v.DepartmentID = d.DepartmentID
LEFT JOIN dim.vProviders pv
	ON v.ProviderID = pv.ProviderID
LEFT JOIN dim.vPractices pc
	ON v.PracticeID = pc.PracticeID
LEFT JOIN dim.Payers py
	ON v.PayerID = py.PayerID
LEFT JOIN dim.PayerGroups pg
	ON py.PayerGroupID = pg.PayerGroupID
LEFT JOIN dim.ServiceLines sl
	ON v.ServiceLine = sl.ServiceLineName
LEFT JOIN dim.ServiceLineGroups slg
	ON sl.ServiceLineGroupID = slg.ServiceLineGroupID
GO
