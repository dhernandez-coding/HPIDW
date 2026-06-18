CREATE PROCEDURE [rpt].[spSelectBlueBookVisits] 

	@CurrentYear int 
	,@CurrentPeriod int 
	,@Practice varchar(10)
	
as

SET NOCOUNT ON

	--DECLARE @Practice varchar(10) = 'DRW'
	--DECLARE @CurrentYear int = 2023
	--DECLARE @CurrentPeriod int = 8
	DECLARE @EndDate date = DATEFROMPARTS(@CurrentYear,@CurrentPeriod,1)
	DECLARE @StartDate date = DATEFROMPARTS(@CurrentYear-1,1,1)
	DECLARE @12MonthStartDate date = DATEADD(MONTH,-12,@EndDate)
	DECLARE @6MonthStartDate date = DATEADD(MONTH,-6,@EndDate)

	IF OBJECT_ID('tempdb..#TempCharges') IS NOT NULL DROP TABLE #TempCharges

	SELECT
			ds.DataSourceName as Datasource
			,pt.PracticeName as Practice
			,d.DepartmentName as BillingDepartment
			,p.ProviderFullName as BillingProvider
			,c.ProcedureCodeIsLocationDependent
			,CASE WHEN c.ProcedureCodeIsLocationDependent = 1 and t.TransactionPlaceOfServiceCode in ('21','22') THEN 'Outpatient Procedures' 
				  WHEN c.ProcedureCodeIsLocationDependent = 1 and t.TransactionPlaceOfServiceCode not in ('21','22') THEN 'In Office Procedures'
				  ELSE c.ProcedureCodeCategory END AS ProcedureCodeCategory
			,pc.ProcedureCategoryPriority as ProcedureCategoryPriority
			,pc.ProcedureCategoryVisitType
			,t.TransactionAccountID
			,t.TransactionVisitID
			,t.TransactionEncounterID
			,t.TransactionDepartmentID
			--,t.TransactionPayerID
			,t.TransactionBillingProviderID
			,t.TransactionBillingType
			,t.TransactionCode
			,t.TransactionDescription
			,t.TransactionCPTCode
			,t.TransactionCPTDescription
			,max(t.TransactionModifier1) as Modifier1
			,t.TransactionPlaceOfServiceCode
			,t.TransactionDateOfService
			,DATEFROMPARTS(LEFT(t.TransactionReportingPeriodID,4),right(t.TransactionReportingPeriodID,2),1) as ReportingPeriod
			,min(t.TransactionDateOfPosting) as FirstPostDate
			,max(t.TransactionDateOfPosting) as LastPostDate
			,max(t.TransactionDateOfVoid) as TransactionDateOfVoid
			,DATEFROMPARTS(YEAR(t.TransactionDateOfService), MONTH(t.TransactionDateOfService),1) as ServiceMonth
			,DATEFROMPARTS(YEAR(t.TransactionDateOfPosting), MONTH(t.TransactionDateOfPosting),1) as PostMonth
			,sum(t.TransactionUnits) as TotalUnits
			,sum(t.TransactionAmount) as TotalAmount
	into #TempCharges

	--select t.*
	FROM fact.Transactions2 t
		left join dim.Departments d ON d.DepartmentID = t.TransactionDepartmentID
		left join dim.vProviders p ON p.ProviderID = t.TransactionBillingProviderID
		left join dim.DataSources ds ON ds.DataSourceID = t.TransactionDatasourceID
		left join stg.PBProcedureCodeCategories c ON c.ProcedureCode = t.TransactionCode
		left join stg.PBProcedureCategories pc ON pc.ProcedureCategory = CASE WHEN c.ProcedureCodeIsLocationDependent = 1 and t.TransactionPlaceOfServiceCode in ('21','22') THEN 'Outpatient Procedures' 
																				WHEN c.ProcedureCodeIsLocationDependent = 1 and t.TransactionPlaceOfServiceCode not in ('21','22') THEN 'In Office Procedures'
																				ELSE c.ProcedureCodeCategory END
		left join map.PracticeDepartments pd ON pd.DepartmentID = t.TransactionDepartmentID
		left join map.PracticeProviders pp ON pp.ProviderID = t.TransactionBillingProviderID AND pp.PracticeProviderEffectiveDate <= t.TransactionDateOfPosting and pp.PracticeProviderEndDate >= t.TransactionDateOfPosting
		left join dim.Practices pt ON pt.PracticeID = COALESCE(pd.PracticeID,pp.PracticeID)
	WHERE 1=1
		AND t.TransactionBillingType = 'PB'
		AND t.TransactionType = 'Charge'
		--AND t.TransactionSubType = 'Charge - Void'
		AND ((t.TransactionDatasourceID = 5 AND t.TransactionDepartmentID like '5~425%') OR t.TransactionDatasourceID = 1)
		AND t.TransactionDateOfPosting between @StartDate and @EndDate --'9/1/2022' and '9/30/2023'
		and pt.PracticeSourceID = @Practice
		--AND LEFT(t.TransactionReportingPeriodID, 4)
		--and d.DepartmentName like '%Diesselhorst%'
	GROUP BY
		ds.DataSourceName 
		,pt.PracticeName 
		,d.DepartmentName 
		,p.ProviderFullName
		,c.ProcedureCodeIsLocationDependent
		,c.ProcedureCodeCategory 
		,pc.ProcedureCategoryPriority
		,pc.ProcedureCategoryVisitType
		,t.TransactionAccountID
		,t.TransactionVisitID
		,t.TransactionEncounterID
		,t.TransactionDepartmentID
		--,t.TransactionPayerID
		,t.TransactionBillingProviderID
		,t.TransactionBillingType
		,t.TransactionCode
		,t.TransactionDescription
		,t.TransactionCPTCode
		,t.TransactionCPTDescription
		--,t.TransactionModifier1
		,t.TransactionPlaceOfServiceCode
		,t.TransactionDateOfService
		--,t.TransactionDateOfPosting
		,t.TransactionReportingPeriodID
		,DATEFROMPARTS(YEAR(t.TransactionDateOfPosting), MONTH(t.TransactionDateOfPosting),1)


		SELECT
			ROW_NUMBER() OVER(PARTITION BY c.TransactionAccountID, c.TransactionEncounterID, c.TransactionDateOfService ORDER BY c.TransactionAccountID, c.TransactionEncounterID, c.TransactionDateOfService, c.ProcedureCategoryPriority) as ProcedureSort
			,c.TransactionAccountID as Account
			,c.TransactionEncounterID as CSN
			,c.TransactionDateOfService as ServiceDate
			,c.FirstPostDate
			,c.LastPostDate
			,c.TransactionDateOfVoid as VoidDate
			,c.ServiceMonth as ServiceMonth
			,c.PostMonth as PostMonth
			,c.ReportingPeriod as ReportingPeriod
			,c.ProcedureCategoryPriority as CategoryPriority
			,c.ProcedureCodeCategory as Category
			,c.ProcedureCategoryVisitType as VisitType
			,c.ProcedureCodeIsLocationDependent as IsLocationDependent
			,c.TransactionCode
			,c.TransactionCPTCode
			,c.TransactionCPTDescription
			,c.Modifier1
			,c.TransactionPlaceOfServiceCode as POS
			,c.Datasource
			,c.Practice
			,c.BillingDepartment
			,c.BillingProvider
			,c.TotalUnits
			,c.TotalAmount
			,CASE WHEN c.TotalUnits < 0 THEN -1 
				  WHEN c.TotalUnits = 0 THEN 0 
				  WHEN c.TotalUnits > 0 THEN 1 END as VisitCount
			,CASE WHEN c.TransactionDateOfVoid is not null THEN 'Yes' ELSE 'No' END as IsVoided
		FROM #TempCharges c
		WHERE 1=1 
		--AND c.TransactionAccountID = '5~120158092'
		AND c.TotalUnits <> 0
GO
