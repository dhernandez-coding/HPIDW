CREATE VIEW [rpt].[vProcedureVolumes] as

SELECT
sub.BudgetTypeID
,bt.BudgetTypeName 
,sub.BudgetDate as VisitDate
,sub.BudgetDatasourceID as DatasourceID
,ds.DataSourceName as Datasource
,sub.BudgetLocationID as LocationID
,l.LocationName as Location
,sub.BudgetDepartmentID as DepartmentID
,d.DepartmentName as Department
,sub.BudgetServiceLineID as ServiceLineID
,sl.ServiceLineName as ServiceLine
--,sub.BudgetSpecialtyID as SpecialtyID
--,s.SpecialtyName as Specialty
,sub.BudgetProviderID as ProviderID
,prv.ProviderFullName as Provider
--,sub.BudgetPayerGroupID as PayerGroupID
--,pg.PayerGroupName as PayerGroup
--,sub.BudgetPayerCategoryID as PayerCategoryID
--,sub.BudgetPayerID as PayerID
--,sub.BudgetPayerPlanID as PayerPlanID
,sum(sub.VisitsBudgeted) as VisitsBudgeted
,sum(sub.VisitsCompleted) as VisitsCompleted
,sum(sub.VisitsScheduled) as VisitsScheduled
,sum(sub.VisitsCancelled) as VisitsCancelled

FROM (
	SELECT 
		b.BudgetTypeID
		,'Budget' as BudgetValueType
		,b.BudgetDate
		,b.BudgetDatasourceID
		,b.BudgetLocationID
		,b.BudgetDepartmentID
		,b.BudgetServiceLineID
		--,b.BudgetSpecialtyID
		,b.BudgetProviderID
		,b.BudgetPayerGroupID
		,b.BudgetPayerCategoryID
		,b.BudgetPayerID
		,b.BudgetPayerPlanID
		,sum(b.BudgetValue) as VisitsBudgeted
		,0 as VisitsCompleted
		,0 as VisitsScheduled
		,0 as VisitsCancelled
	FROM fact.Budgets b
	GROUP BY 
		b.BudgetTypeID
		,b.BudgetDate
		,b.BudgetDatasourceID
		,b.BudgetLocationID
		,b.BudgetDepartmentID
		,b.BudgetServiceLineID
		,b.BudgetSpecialtyID
		,b.BudgetProviderID
		,b.BudgetPayerGroupID
		,b.BudgetPayerCategoryID
		,b.BudgetPayerID
		,b.BudgetPayerPlanID

	UNION ALL 

	select
		'0~1' as BudgetTypeID
		,'Actual' as BudgetValueType
		,d.FirstDayOfMonth as BudgetDate
		,v.VisitDataSourceID
		,v.VisitLocationID
		,v.VisitDepartmentID
		,v.VisitServiceLineID
		--,v.VisitPrimaryProviderSpecialtyID
		,v.VisitPrimaryProviderID
		,NULL AS VisitPrimaryPayerGroupID
		,NULL AS VisitPrimaryPayerCategoryID
		,NULL AS VisitPrimaryPayerID
		,NULL AS VisitPrimaryPayerPlanID
		,0 AS VisitsBudgeted
		,SUM(case when v.VisitIsArrivedOrCompleted = 'Yes' OR v.VisitTotalCharges > 0 THEN 1 ELSE 0 END) as VisitsCompleted
		,SUM(case when v.VisitIsScheduled = 'Yes' THEN 1 ELSE 0 END) as VisitsScheduled
		,SUM(case when v.VisitIsCancelled = 'Yes' THEN 1 ELSE 0 END) as VisitsCancelled
	from fact.vVisits v
		left join dim.Dates d ON d.Date = v.VisitDateOfService
	where 1=1
		AND v.VisitIsSurgical = 'Yes'
		AND v.VisitIsHospital = 'Yes'
	group by 
		d.FirstDayOfMonth
		,v.VisitDataSourceID
		,v.VisitLocationID
		,v.VisitDepartmentID
		,v.VisitServiceLineID
		--,v.VisitPrimaryProviderSpecialtyID
		,v.VisitPrimaryProviderID
		--,v.VisitPrimaryPayerGroupID
		--,v.VisitPrimaryPayerCategoryID
		--,v.VisitPrimaryPayerID
		--,NULL AS VisitPrimaryPayerPlanID
) sub
	left join dim.BudgetTypes bt ON bt.BudgetTypeID = sub.BudgetTypeID
	left join dim.DataSources ds ON ds.DataSourceID = sub.BudgetDatasourceID
	left join dim.ServiceLines sl ON sl.ServiceLineID = sub.BudgetServiceLineID
	left join dim.vProviders prv ON prv.ProviderID = sub.BudgetProviderID
	--left join dim.Specialties s ON s.SpecialtyID = sub.BudgetSpecialtyID
	left join dim.PayerGroups pg ON pg.PayerGroupID = sub.BudgetPayerGroupID
	left join dim.Locations l ON l.LocationID = sub.BudgetLocationID
	left join dim.Departments d ON d.DepartmentID = sub.BudgetDepartmentID

GROUP BY 
	sub.BudgetTypeID
	,bt.BudgetTypeName 
	,sub.BudgetDate 
	,sub.BudgetDatasourceID 
	,ds.DataSourceName 
	,sub.BudgetLocationID 
	,l.LocationName 
	,sub.BudgetDepartmentID 
	,d.DepartmentName
	,sub.BudgetServiceLineID 
	,sl.ServiceLineName 
	--,sub.BudgetSpecialtyID 
	--,s.SpecialtyName
	,sub.BudgetProviderID 
	,prv.ProviderFullName 
	--,sub.BudgetPayerGroupID 
	--,pg.PayerGroupName
	--,sub.BudgetPayerCategoryID 
	--,sub.BudgetPayerID 
	--,sub.BudgetPayerPlanID
GO
