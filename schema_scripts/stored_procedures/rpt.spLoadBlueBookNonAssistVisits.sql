CREATE PROCEDURE  [rpt].[spLoadBlueBookNonAssistVisits] as

	--@CurrentYear int 
	--,@CurrentPeriod int 
	--,@Practice varchar(10)
	

/*
Change Control:
	1. 9/4/24 - Chris Cross - Replaced fact.Transactions2 with fact.TransactionsPB
	2. 6/4/25 - Eric Silvestri - Added datasource 12 to the where clause to include HPI Customer data 
	3. 3/18/26 - Diego Hernandez - Added THP volume 
	4. 3/24/26 - Chris Cross - Updated procedure category mapping to reference HPIApp tables
	5. 6/2/2026 - Chris Cross - Replaced HPIApp.dbo.PBProcedureCategories with [HERO-DB].hpi.dbo.PBProcedureCategoriess to look at new HERO app
	6. 6/11/2026 - Diego Hernandez - Added Data Source 15
*/

SET NOCOUNT OFF

DECLARE @Practice varchar(10) = '0' /*0 - All*/  --'DRW'
DECLARE @AsOfDate date = DATEADD(DAY,-1,DATEFROMPARTS(YEAR(GETDATE()),MONTH(GETDATE()),1))  
DECLARE @CurrentYear int = YEAR(@AsOfDate) --2023
DECLARE @CurrentPeriod int = MONTH(@AsOfDate)
DECLARE @EndDate date = DATEFROMPARTS(@CurrentYear,@CurrentPeriod,1)
DECLARE @StartDate date = DATEFROMPARTS(@CurrentYear-1,1,1)
DECLARE @12MonthStartDate date = DATEADD(MONTH,-12,@EndDate)
DECLARE @6MonthStartDate date = DATEADD(MONTH,-6,@EndDate)


--select @Practice, @AsOfDate, @CurrentYear,@CurrentPeriod

/*Load Temp Table with consolidated charge data*/
IF OBJECT_ID('tempdb..#TempCharges') IS NOT NULL DROP TABLE #TempCharges

	SELECT
			ds.DataSourceName as Datasource
			,pt.PracticeID 
			,pt.PracticeName as Practice
			,d.DepartmentID as BillingDepartmentID
			,d.DepartmentName as BillingDepartment
			,p.ProviderID as ReportingProviderID
			,p.ProviderFullName as ReportingProvider
			,c.ProcedureCodeIsLocationDependent
			,CASE WHEN c.ProcedureCodeIsLocationDependent = 1 and t.TransactionPlaceOfServiceCode in ('21','22') THEN 'Outpatient Procedures' 
				  WHEN c.ProcedureCodeIsLocationDependent = 1 and t.TransactionPlaceOfServiceCode not in ('21','22') THEN 'In Office Procedures'
				  ELSE c.ProcedureCodeCategory END AS ProcedureCodeCategory
			,pc.ProcedureCategoryPriority as ProcedureCategoryPriority
			,pc.ProcedureCategoryVisitType
			,t.TransactionAccountID
			,t.TransactionVisitID
			--,t.TransactionEncounterID
			--,t.TransactionDepartmentID
			--,t.TransactionPayerID
			--,t.TransactionBillingProviderID
			--,t.TransactionBillingType
			--,t.TransactionCode
			--,t.TransactionDescription
			--,t.TransactionCPTCode
			--,t.TransactionCPTDescription
			--,max(t.TransactionModifier1) as Modifier1
			,t.TransactionPlaceOfServiceCode
			,t.TransactionDateOfService
			,DATEFROMPARTS(YEAR(t.TransactionDateOfService), MONTH(t.TransactionDateOfService),1) as ServiceMonth
			,DATEFROMPARTS(LEFT(t.TransactionReportingPeriodID,4),right(t.TransactionReportingPeriodID,2),1) as ReportingPeriod
			,min(t.TransactionDateOfPosting) as FirstPostDate
			,max(t.TransactionDateOfPosting) as LastPostDate
			,max(t.TransactionDateOfVoid) as TransactionDateOfVoid
			--,DATEFROMPARTS(YEAR(t.TransactionDateOfPosting), MONTH(t.TransactionDateOfPosting),1) as PostMonth
			,sum(t.TransactionUnits) as TotalUnits
			,sum(t.TransactionAmount) as TotalAmount
			,max(CASE WHEN t.TransactionModifier1 IN ('80','81','82','AS') THEN 1 ELSE 0 END) AS IsAssist
	into #TempCharges

	--select t.*
	FROM fact.TransactionsPB t
		left join dim.Departments d ON d.DepartmentID = t.TransactionDepartmentID
		left join dim.vProviders p ON p.ProviderID = t.TransactionBillingProviderID
		left join dim.DataSources ds ON ds.DataSourceID = t.TransactionDatasourceID
		left join dim.vPBProcedureCodeCategories c ON c.ProcedureCode = COALESCE(t.TransactionCPTCode,t.TransactionCode)
		left join [HERO-DB].hpi.dbo.PBProcedureCategoriess pc ON pc.ProcedureCategory = CASE WHEN c.ProcedureCodeIsLocationDependent = 1 and t.TransactionPlaceOfServiceCode in ('21','22') THEN 'Outpatient Procedures' 
																				WHEN c.ProcedureCodeIsLocationDependent = 1 and t.TransactionPlaceOfServiceCode not in ('21','22') THEN 'In Office Procedures'
																				ELSE c.ProcedureCodeCategory END
		left join map.vProviderLinking pl ON pl.ChildProviderID = t.TransactionBillingProviderID
		left join map.PracticeDepartments pd ON pd.DepartmentID = t.TransactionDepartmentID
		left join map.vPracticeProviders pp ON pp.ParentProviderID = pl.ParentProviderID
									AND pp.PracticeProviderEffectiveDate <= t.TransactionDateOfPosting 
									AND pp.PracticeProviderEndDate >= t.TransactionDateOfPosting
									AND (/*This is here to handle duplicates with Murphi Scarborough at multiple practices*/
												(pl.ParentProviderID in ('0~1588209423') 
													AND (pp.PracticeID = pd.PracticeID OR (pd.PracticeID is null AND (t.TransactionDatasourceID = 5 AND pp.PracticeID = '0~RGS')
																													  OR (t.TransactionDatasourceID = 1 AND pp.PracticeID = '0~RLN'))) )
												/*This is here to handle duplicates with Amy James at multiple practices*/
												OR (pl.ParentProviderID in ('0~1679132823') 
													AND (pp.PracticeID = pd.PracticeID OR (pd.PracticeID is null AND (t.TransactionDatasourceID = 5 AND pp.PracticeID = '0~MDW')
																													  OR (t.TransactionDatasourceID = 1 AND pp.PracticeID = '0~CGW'))) )
												/*Chris Cross - 10.7.24 - Added Olivo, Pape, and Dunkleberger due to practicing at PBJ, NMO, and NRJ; Defaults to PBJ if no mapped department defined in Epic*/
												OR (pl.ParentProviderID in ('0~1992746200','0~1891761136','0~1376509828') 
													AND (pp.PracticeID = pd.PracticeID OR (pd.PracticeID is null AND  pp.PracticeID = '0~PBJ') ) )
												/*Chris Cross - 02.18.25 - Added Jill Yingling due to practicing at MBJ and RLN; Defaults to RLN if no mapped department defined in Epic*/
												OR (pl.ParentProviderID in ('0~1245788231') 
													AND (pp.PracticeID = pd.PracticeID OR (pd.PracticeID is null AND pp.PracticeID = '0~RLN') ) )
												/*This is here to handle duplicates with Paul Maitino at multiple practices*/
												OR (pl.ParentProviderID in ('0~1376507665') 
													AND (pp.PracticeID = pd.PracticeID OR (pd.PracticeID is null AND (t.TransactionDepartmentID = '12~45' AND pp.PracticeID = '0~JRS')
																													  OR (t.TransactionDepartmentID = '12~46' AND pp.PracticeID = '0~OPCL'))) )
												 /*This is here to handle duplicates with Calvin Johnson at multiple practices*/
												OR (pl.ParentProviderID in ('0~1063484251') 
													AND (pp.PracticeID = pd.PracticeID OR (pd.PracticeID is null AND (t.TransactionDepartmentID = '12~48' AND pp.PracticeID = '0~JCJ')
																													  OR (t.TransactionDepartmentID = '12~36' AND pp.PracticeID = '0~JCJ')
																													  OR (t.TransactionDepartmentID = '1~19' AND pp.PracticeID = '0~JCJ2')
																													  OR (t.TransactionDepartmentID = '1~5' AND pp.PracticeID = '0~JCJ2'))) )
												/*This is here to handle duplicates with Joseph Broome at multiple practices*/
												OR (pl.ParentProviderID in ('0~1306817887') 
													AND (pp.PracticeID = pd.PracticeID OR (pd.PracticeID is null AND pp.PracticeID = '0~JCB') ) )
												
												/*All other providers without specific mapping issues due to multiple practices as defined above*/
												OR pl.ParentProviderID not in ('0~1588209423','0~1679132823','0~1992746200','0~1891761136','0~1376509828','0~1245788231','0~1376507665','0~1063484251','0~1306817887'))
												
		left join dim.vPractices pt ON pt.PracticeID = COALESCE(pd.PracticeID,pp.PracticeID)
	WHERE 1=1
		AND t.TransactionBillingType = 'PB'
		AND t.TransactionType = 'Charge'
		--AND t.TransactionSubType = 'Charge - Void'
		--AND (pd.DepartmentID is not null OR t.TransactionDatasourceID = 1)
		AND (pd.DepartmentID is not null OR t.TransactionDatasourceID IN (1, 12, 15))
		AND DATEFROMPARTS(LEFT(t.TransactionReportingPeriodID,4),right(t.TransactionReportingPeriodID,2),1) >= @StartDate --and @EndDate --'9/1/2022' and '9/30/2023'
		AND (t.TransactionModifier1 IS NULL or t.TransactionModifier1 NOT IN ('TC','80','81','82','AS')) /*Exclude Technical Components and Surgery Assists*/
		--AND t.TransactionAccountID = '1~25691320'
		and (@Practice = '0' OR pt.PracticeSourceID = @Practice)
		--AND LEFT(t.TransactionReportingPeriodID, 4)
		--and d.DepartmentName like '%Diesselhorst%'
	GROUP BY
		ds.DataSourceName 
		,pt.PracticeID
		,pt.PracticeName 
		,d.DepartmentID
		,d.DepartmentName
		,p.ProviderID
		,p.ProviderFullName
		,c.ProcedureCodeIsLocationDependent
		,c.ProcedureCodeCategory 
		,pc.ProcedureCategoryPriority
		,pc.ProcedureCategoryVisitType
		,t.TransactionAccountID
		,t.TransactionVisitID
		--,t.TransactionEncounterID
		--,t.TransactionDepartmentID
		--,t.TransactionPayerID
		--,t.TransactionBillingProviderID
		--,t.TransactionBillingType
		--,t.TransactionCode
		--,t.TransactionDescription
		--,t.TransactionCPTCode
		--,t.TransactionCPTDescription
		--,t.TransactionModifier1
		,t.TransactionPlaceOfServiceCode
		,t.TransactionDateOfService
		--,t.TransactionDateOfPosting
		,t.TransactionReportingPeriodID
		--,DATEFROMPARTS(YEAR(t.TransactionDateOfPosting), MONTH(t.TransactionDateOfPosting),1)

	--select * from #TempCharges c where c.TransactionAccountID = '1~25691320'
	--select * from fact.Transactions2 t where t.TransactionAccountID = '1~25691320'

/*Delete and Reload*/
	DELETE FROM rpt.BlueBooks WHERE ReportSection in ('Non-Assist Visits') and FiscalYear >= @CurrentYear-1

	INSERT INTO rpt.BlueBooks 

	([FiscalYear]
      ,[FiscalPeriod]
      ,[FiscalYearPeriod]
      ,[ReportSection]
      ,[ReportGroupLevel1]
      ,[ReportGroupLevel2]
      ,[ReportGroupLevel3]
      --,[ReportGroupLevel4]
      ,[PracticeID]
      ,[ReportingProviderID]
      ,[FiscalPeriodValue]
      ,[UpdatedDatetime])
	
	SELECT
		sub.FiscalYear
		,sub.FiscalPeriod
		,sub.FiscalYearPeriod
		,sub.ReportSection
		,sub.ReportGroupLevel1
		,sub.ReportGroupLevel2
		,sub.ReportGroupLevel3
		,sub.PracticeID
		,sub.ReportingProviderID
		,sum(sub.FiscalPeriodValue) as FiscalPeriodValue
		,GETDATE() as UpdateDatetime
	FROM (
		SELECT
		sub.FiscalYear 
		,sub.FiscalPeriod 
		,sub.FiscalYearPeriod 
		,sub.ReportSection
		,sub.ReportGroupLevel1
		,sub.ReportGroupLevel2
		,sub.ReportGroupLevel3
		,sub.PracticeID 
		,sub.ReportingProviderID 
		,SUM(sub.VisitCount) as FiscalPeriodValue 
		,GETDATE() AS UpdatedDatetime 
		FROM (
		SELECT
				'Non-Assist Visits' as ReportSection
				,YEAR(c.ReportingPeriod) as FiscalYear
				,MONTH(c.ReportingPeriod) as FiscalPeriod
				,FORMAT(DATEFROMPARTS(YEAR(c.ReportingPeriod),MONTH(c.ReportingPeriod),1),'MMM-yy') as FiscalYearPeriod
				,c.TransactionAccountID as Account
				,c.TransactionVisitID as CSN
				,c.TransactionDateOfService as ServiceDate
				,ROW_NUMBER() OVER(PARTITION BY c.TransactionAccountID, c.TransactionVisitID, c.TransactionDateOfService, c.ReportingPeriod ORDER BY c.TransactionAccountID, c.TransactionVisitID, c.TransactionDateOfService, c.ProcedureCategoryPriority) as ProcedureSort
				,c.ProcedureCategoryVisitType as ReportGroupLevel1
				,c.ProcedureCodeCategory as ReportGroupLevel2
				,NULL as ReportGroupLevel3
				,c.PracticeID
				,c.Practice
				,c.ReportingProviderID
				,c.ReportingProvider
				--,c.TransactionCode
				--,c.TransactionCPTCode
				--,c.TransactionCPTDescription
				--,ISNULL(c.Modifier1,'') as Modifier
				,c.TransactionPlaceOfServiceCode as POS
				,c.FirstPostDate
				,c.LastPostDate
				,c.TransactionDateOfVoid as VoidDate
				,c.ServiceMonth as ServiceMonth
				--,c.PostMonth as PostMonth
				,c.ReportingPeriod as ReportingPeriod
				,c.ProcedureCategoryPriority as CategoryPriority
				,c.ProcedureCodeCategory as Category
				,c.ProcedureCategoryVisitType as VisitType
				,c.ProcedureCodeIsLocationDependent as IsLocationDependent
				,c.Datasource
				,c.BillingDepartment
				,c.TotalUnits
				,c.TotalAmount
				,CASE WHEN c.TotalUnits < 0 THEN -1 
					  WHEN c.TotalUnits = 0 THEN 0 
					  WHEN c.TotalUnits > 0 THEN 1 END as VisitCount
				,CASE WHEN c.TransactionDateOfVoid is not null THEN 'Yes' ELSE 'No' END as IsVoided
				,c.IsAssist
			FROM #TempCharges c
			WHERE 1=1 
				--AND ISNULL(c.Modifier1,'0') <> 'TC' /*Exclude Technical Components*/
				--AND c.TransactionAccountID = '5~120158092'
				AND c.TotalUnits <> 0
				--AND c.TransactionAccountID like '%24383950%'
				--AND c.PracticeID = '0~nrj'
				--AND c.ReportingPeriod >= '6/1/2023'
		) sub

		WHERE 1=1
			AND sub.ProcedureSort = 1 /*only return highest ranked procedure code*/
			AND sub.IsAssist = 0 /*Exclude surgical assist visit types*/
			--AND sub.Modifier <> 'TC' /*Exclude Technical Components*/

		GROUP BY 
		FiscalYear 
		,FiscalPeriod 
		,FiscalYearPeriod 
		,ReportSection
		,ReportGroupLevel1
		,ReportGroupLevel2 
		,ReportGroupLevel3
		,PracticeID 
		,ReportingProviderID 

	/*Add in Zero Values as placeholder*/
		UNION ALL

		select
			@CurrentYear as FiscalYear
			,@CurrentPeriod as FiscalPeriod
			,FORMAT(DATEFROMPARTS(@CurrentYear,@CurrentPeriod,1),'MMM-yy') AS FiscalYearPeriod 
			,bbg.ReportSection
			,bbg.ReportGroupLevel1
			,bbg.ReportGroupLevel2 as ReportGroupLevel2
			,NULL as ReportGroupLevel3
			,p.PracticeID
			,pp.ProviderID
			,0 as FiscalPeriodValue
			,GETDATE()
		from dim.vPractices p
			left join map.vPracticeProviders pp ON pp.PracticeID = p.PracticeID
			cross join (SELECT bb.ReportSection, bb.ReportGroupLevel1, max(ReportGroupLevel2) as ReportGroupLevel2
						FROM rpt.BlueBooks bb
						WHERE bb.ReportSection in ('Non-Assist Visits') and bb.ReportGroupLevel1 is not null
						GROUP BY bb.ReportSection, bb.ReportGroupLevel1) bbg
		where p.PracticeIsActive = 1

		UNION ALL

		/* THP DATA */ 
		SELECT
		    YEAR(v.Month) AS FiscalYear,
		    MONTH(v.Month) AS FiscalPeriod,
		    FORMAT(v.Month,'MMM-yy') AS FiscalYearPeriod,
		
		    'Non-Assist Visits' AS ReportSection,
		    'Office Visits' AS ReportGroupLevel1,
		    NULL AS ReportGroupLevel2,
		    NULL AS ReportGroupLevel3,
		
		    p.PracticeID,
		    ISNULL(pl.ParentProviderID, 'UNKNOWN'),
		
		    SUM(v.Claim_Count) AS FiscalPeriodValue,
		    GETDATE() AS UpdatedDatetime
		
		FROM [HPIDW].[stg].[THPVolumes] v
		
		LEFT JOIN dim.Providers pp
		    ON UPPER(LTRIM(RTRIM(pp.ProviderSourceID))) = UPPER(LTRIM(RTRIM(v.Provider)))
		    AND pp.ProviderDataSourceID = 17
		
		LEFT JOIN map.vProviderLinking pl 
		    ON pl.ChildProviderID = pp.ProviderID
		
		LEFT JOIN map.PracticeProviders mpp
		    ON mpp.ProviderID = pp.ProviderID
		
		LEFT JOIN dim.Practices p
		    ON p.PracticeID = ISNULL(mpp.PracticeID, v.Practice)
		
		WHERE v.Claim_Count IS NOT NULL
		  AND v.Month >= @StartDate
		  AND v.Month < @EndDate
		
		GROUP BY
		    YEAR(v.Month),
		    MONTH(v.Month),
		    FORMAT(v.Month,'MMM-yy'),
		    p.PracticeID,
		    ISNULL(pl.ParentProviderID, 'UNKNOWN')


		) sub

		GROUP BY  
		sub.FiscalYear
		,sub.FiscalPeriod
		,sub.FiscalYearPeriod
		,sub.ReportSection
		,sub.ReportGroupLevel1
		,sub.ReportGroupLevel2
		,sub.ReportGroupLevel3
		,sub.PracticeID
		,sub.ReportingProviderID
GO
