CREATE PROCEDURE [rpt].[spLoadBlueBookChargeLag] 

	--@CurrentYear int 
	--,@CurrentPeriod int 
	--,@Practice varchar(10)
	
as

/*
Change Control:
	1. 9/4/24 - Chris Cross - Replaced fact.Transactions2 with fact.TransactionsPB
	2. 6/4/25 - Eric Silvestri - Added datasource 12 to the where clause to include HPI Customer data 
	3. 8/12/25 - Chris Cross - Added ReportGroupLevel4 for SCS location-specific reports
	
	4. 7/17/26 - Logan Richardson - Replaced ProviderLinking with vProviderLinking
*/

SET NOCOUNT ON

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
IF OBJECT_ID('tempdb..#TempChargeLag') IS NOT NULL DROP TABLE #TempChargeLag

	SELECT
		LEFT(t.TransactionReportingPeriodID,4) AS FiscalYear 
		,RIGHT(t.TransactionReportingPeriodID,2) AS FiscalPeriod 
		,FORMAT(DATEFROMPARTS(LEFT(t.TransactionReportingPeriodID,4),RIGHT(t.TransactionReportingPeriodID,2),1),'MMM-yy') AS FiscalYearPeriod 
		,'Charges' as ReportSection
		,CASE WHEN vi.VisitType = 'Surgical Visits' THEN vi.VisitType ELSE 'Non-surgical Visits' END as ReportGroupLevel1
		,pg.PayerGroupName as ReportGroupLevel2 
		,NULL as ReportGroupLevel3
		,case 
			when t.TransactionDepartmentID IN ('1~10','1~25') then 'PI' -- Checks if Personal Injury account for Kim
			WHEN t.TransactionBillingProviderID in ('1~18524','5~P1008411') THEN 'PI' --5.8.26 Mapped all Kevin Chessmore (EKK) activity to PI
			when t.TransactionDepartmentID = '5~42501006002' THEN 'SCS Choctaw' --Checks if Choctaw department for Shadid
			when t.TransactionDepartmentID = '5~42501006001' THEN 'SCS Edmond' --Checks if Choctaw department for Shadid
			WHEN (v.VisitLocationID = '1~135' OR t.TransactionDepartmentID = '5~42501041001') AND pt.PracticeID = '0~TDT' THEN 'Hinton' -- checks for location and provider for Thomason
			WHEN (v.VisitLocationID = '1~223' OR t.TransactionDepartmentID = '5~42501043001') AND pt.PracticeID = '0~TDT' THEN 'Binger'
			WHEN (v.VisitLocationID = '1~230' OR t.TransactionDepartmentID = '5~42501042001') AND pt.PracticeID = '0~TDT' THEN 'Hydro'
			WHEN v.VisitLocationID = '1~95' AND pt.PracticeID = '0~TDT' THEN 'Hinton'			
		 end as ReportGroupLevel4
		,pt.PracticeID as PracticeID 
		,MIN(t.TransactionBillingProviderID) AS ReportingProviderID -- Here we replace the min for ParentProviderID min(t.TransactionBillingProviderID)
		,SUM(DATEDIFF(DAY,t.TransactionDateOfService,t.TransactionDateOfPosting)) as FiscalPeriodNumerator
		,COUNT(t.TransactionID) as FiscalPeriodDenominator
		,GETDATE() AS UpdatedDatetime 
	INTO #TempChargeLag
	FROM fact.TransactionsPB t
		left join dim.Departments d ON d.DepartmentID = t.TransactionDepartmentID
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
		left join dim.Payers py ON py.PayerID = t.TransactionPayerID
		--left join dim.PayerCategories pc ON pc.PayerCategoryID = py.PayerCategoryID
		left join dim.PayerGroups pg ON pg.PayerGroupID = py.PayerGroupID
		left join rpt.BlueBookVisitInfo vi ON vi.VisitID = t.TransactionVisitID AND vi.VisitDateOfService = t.TransactionDateOfService
		left join fact.Visits2 v on t.TransactionVisitID = v.VisitID

	WHERE 1=1
		AND t.TransactionBillingType = 'PB'
		AND t.TransactionType = 'Charge'
		AND t.TransactionSubType = 'Charge - New' /*Exclude Voids*/
		AND DATEDIFF(DAY,t.TransactionDateOfService,t.TransactionDateOfPosting) <= 60 /*Only include postings within 60 days of service*/
		--AND (pd.DepartmentID is not null OR t.TransactionDatasourceID = 1)
		AND (pd.DepartmentID is not null OR t.TransactionDatasourceID IN (1, 12,15))
		AND LEFT(t.TransactionReportingPeriodID,4) >= @CurrentYear-1 --and @EndDate --'9/1/2022' and '9/30/2023'
		AND t.TransactionAmount <> 0
		--AND t.TransactionBillingProviderID = '1~13953'
		--AND (t.TransactionModifier1 IS NULL or t.TransactionModifier1 <> 'TC')
		--AND t.TransactionAccountID = '1~25691320'
		and (@Practice = '0' OR pt.PracticeSourceID = @Practice)
		--AND LEFT(t.TransactionReportingPeriodID, 4)
		--and d.DepartmentName like '%Diesselhorst%'
	GROUP BY
		t.TransactionReportingPeriodID
		,vi.VisitType
		,pg.PayerGroupName
		,case 
			when t.TransactionDepartmentID IN ('1~10','1~25') then 'PI' -- Checks if Personal Injury account for Kim
			WHEN t.TransactionBillingProviderID in ('1~18524','5~P1008411') THEN 'PI' --5.8.26 Mapped all Kevin Chessmore (EKK) activity to PI
			when t.TransactionDepartmentID = '5~42501006002' THEN 'SCS Choctaw' --Checks if Choctaw department for Shadid
			when t.TransactionDepartmentID = '5~42501006001' THEN 'SCS Edmond' --Checks if Choctaw department for Shadid
			WHEN (v.VisitLocationID = '1~135' OR t.TransactionDepartmentID = '5~42501041001') AND pt.PracticeID = '0~TDT' THEN 'Hinton' -- checks for location and provider for Thomason
			WHEN (v.VisitLocationID = '1~223' OR t.TransactionDepartmentID = '5~42501043001') AND pt.PracticeID = '0~TDT' THEN 'Binger'
			WHEN (v.VisitLocationID = '1~230' OR t.TransactionDepartmentID = '5~42501042001') AND pt.PracticeID = '0~TDT' THEN 'Hydro'
			WHEN v.VisitLocationID = '1~95' AND pt.PracticeID = '0~TDT' THEN 'Hinton'			
		 end --as ReportGroupLevel4
		,pt.PracticeID
		--,p.ProviderID
		,pl.ParentProviderID
		--,t.TransactionBillingProviderID

--select * from #TempChargeLag


/*Delete and Reload*/
	DELETE FROM rpt.BlueBooks WHERE ReportSection in ('Charge Lag By Type By Practice') and FiscalYear >= @CurrentYear-1
	
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
	  ,[FiscalPeriodNumerator]
	  ,[FiscalPeriodDenominator]
      ,[UpdatedDatetime])

	SELECT
	t.FiscalYear AS FiscalYear 
	,t.FiscalPeriod AS FiscalPeriod 
	,t.FiscalYearPeriod AS FiscalYearPeriod 
	,'Charge Lag By Type By Practice' as ReportSection
	,t.ReportGroupLevel1 as ReportGroupLevel1
	,NULL as ReportGroupLevel2 
	,NULL as ReportGroupLevel3
	--,t.ReportGroupLevel4 as ReportGroupLevel4
	,T.PracticeID as PracticeID 
	,null as ReportingProviderID 
	,CASE WHEN ISNULL(SUM(t.FiscalPeriodDenominator),0) = 0 THEN 0.00 ELSE  SUM(t.FiscalPeriodNumerator) /  SUM(t.FiscalPeriodDenominator) END as FiscalPeriodValue 
	,SUM(t.FiscalPeriodNumerator) as FiscalPeriodNumerator
	,SUM(t.FiscalPeriodDenominator) as FiscalPeriodDenominator
	,GETDATE() AS UpdatedDatetime 
	FROM #TempChargeLag t
	GROUP BY
		t.FiscalYear
		,t.FiscalPeriod
		,t.FiscalYearPeriod
		,t.ReportGroupLevel1
		--,t.ReportGroupLevel2
		--,t.ReportGroupLevel3
		--,t.ReportGroupLevel4 
		,t.PracticeID
		--,t.ReportingProviderID
		--,p.ProviderID


/*Delete and Reload*/
	DELETE FROM rpt.BlueBooks WHERE ReportSection in ('Charge Lag By Type By Provider') and FiscalYear >= @CurrentYear-1
	
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
	  ,[FiscalPeriodNumerator]
	  ,[FiscalPeriodDenominator]
      ,[UpdatedDatetime])

	SELECT
	t.FiscalYear AS FiscalYear 
	,t.FiscalPeriod AS FiscalPeriod 
	,t.FiscalYearPeriod AS FiscalYearPeriod 
	,'Charge Lag By Type By Provider' as ReportSection
	,t.ReportGroupLevel1 as ReportGroupLevel1
	,NULL as ReportGroupLevel2 
	,NULL as ReportGroupLevel3
	--,t.ReportGroupLevel4 as ReportGroupLevel4
	,T.PracticeID as PracticeID
	,MIN(p.ProviderID) as ReportingProviderID  
	--,t.ReportingProviderID as ReportingProviderID 
	,CASE WHEN ISNULL(SUM(t.FiscalPeriodDenominator),0) = 0 THEN 0.00 ELSE  SUM(t.FiscalPeriodNumerator) /  SUM(t.FiscalPeriodDenominator) END as FiscalPeriodValue 
	,SUM(t.FiscalPeriodNumerator) as FiscalPeriodNumerator
	,SUM(t.FiscalPeriodDenominator) as FiscalPeriodDenominator
	,GETDATE() AS UpdatedDatetime 
	FROM #TempChargeLag t
	left join dim.vProviders p ON p.ProviderID = t.ReportingProviderID
	GROUP BY
		t.FiscalYear
		,t.FiscalPeriod
		,t.FiscalYearPeriod
		,t.ReportGroupLevel1
		--,t.ReportGroupLevel2
		--,t.ReportGroupLevel4 --as ReportGroupLevel4
		,t.PracticeID
		--,t.ReportingProviderID
		,p.ProviderID --Here I change to ProviderID Instead parent 
		--,p.ProviderID

/*Delete and Reload*/
	DELETE FROM rpt.BlueBooks WHERE ReportSection in ('Charge Lag By Practice') and FiscalYear >= @CurrentYear-1
	
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
	  ,[FiscalPeriodNumerator]
	  ,[FiscalPeriodDenominator]
      ,[UpdatedDatetime])

	SELECT
	t.FiscalYear AS FiscalYear 
	,t.FiscalPeriod AS FiscalPeriod 
	,t.FiscalYearPeriod AS FiscalYearPeriod 
	,'Charge Lag By Practice' as ReportSection
	,NULL as ReportGroupLevel1
	,NULL as ReportGroupLevel2 
	,NULL as ReportGroupLevel3
	--,t.ReportGroupLevel4 --as ReportGroupLevel4
	,T.PracticeID as PracticeID 
	,null as ReportingProviderID 
	,CASE WHEN ISNULL(SUM(t.FiscalPeriodDenominator),0) = 0 THEN 0.00 ELSE  SUM(t.FiscalPeriodNumerator) /  SUM(t.FiscalPeriodDenominator) END as FiscalPeriodValue 
	,SUM(t.FiscalPeriodNumerator) as FiscalPeriodNumerator
	,SUM(t.FiscalPeriodDenominator) as FiscalPeriodDenominator
	,GETDATE() AS UpdatedDatetime 
	FROM #TempChargeLag t
	GROUP BY
		t.FiscalYear
		,t.FiscalPeriod
		,t.FiscalYearPeriod
		--,t.ReportGroupLevel1
		--,t.ReportGroupLevel2
		--,t.ReportGroupLevel4 --as ReportGroupLevel4
		,t.PracticeID
		--,t.ReportingProviderID
		--,p.ProviderID


/*Delete and Reload*/
	DELETE FROM rpt.BlueBooks WHERE ReportSection in ('Charge Lag By Provider') and FiscalYear >= @CurrentYear-1
	
	INSERT INTO rpt.BlueBooks 

	([FiscalYear] 
      ,[FiscalPeriod]
      ,[FiscalYearPeriod]
      ,[ReportSection]
      ,[ReportGroupLevel1]
      ,[ReportGroupLevel2]
	  ,[ReportGroupLevel3]
	 -- ,[ReportGroupLevel4]
      ,[PracticeID]
      ,[ReportingProviderID]
      ,[FiscalPeriodValue]
	  ,[FiscalPeriodNumerator]
	  ,[FiscalPeriodDenominator]
      ,[UpdatedDatetime])

	SELECT
	t.FiscalYear AS FiscalYear 
	,t.FiscalPeriod AS FiscalPeriod 
	,t.FiscalYearPeriod AS FiscalYearPeriod 
	,'Charge Lag By Provider' as ReportSection
	,NULL as ReportGroupLevel1
	,NULL as ReportGroupLevel2 
	,NULL as ReportGroupLevel3
	--,t.ReportGroupLevel4 as ReportGroupLevel4
	,T.PracticeID as PracticeID 
	,MIN(p.ProviderID) as ReportingProviderID 
	--,t.ReportingProviderID as ReportingProviderID 
	,CASE WHEN ISNULL(SUM(t.FiscalPeriodDenominator),0) = 0 THEN 0.00 ELSE  SUM(t.FiscalPeriodNumerator) /  SUM(t.FiscalPeriodDenominator) END as FiscalPeriodValue 
	,SUM(t.FiscalPeriodNumerator) as FiscalPeriodNumerator
	,SUM(t.FiscalPeriodDenominator) as FiscalPeriodDenominator
	,GETDATE() AS UpdatedDatetime 
	FROM #TempChargeLag t
	left join dim.vProviders p ON p.ProviderID = t.ReportingProviderID
	GROUP BY
		t.FiscalYear
		,t.FiscalPeriod
		,t.FiscalYearPeriod
		--,t.ReportGroupLevel1
		--,t.ReportGroupLevel2
		--,t.ReportGroupLevel4 --as ReportGroupLevel4
		,t.PracticeID
		,p.ProviderID --Here I change to ProviderID Instead parent 
		--,t.ReportingProviderID
		--,p.ProviderID

/*Delete and Reload*/
	DELETE FROM rpt.BlueBooks WHERE ReportSection in ('Charge Lag By Type') and FiscalYear >= @CurrentYear-1
	
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
	  ,[FiscalPeriodNumerator]
	  ,[FiscalPeriodDenominator]
      ,[UpdatedDatetime])

	SELECT
	t.FiscalYear AS FiscalYear 
	,t.FiscalPeriod AS FiscalPeriod 
	,t.FiscalYearPeriod AS FiscalYearPeriod 
	,'Charge Lag By Type' as ReportSection
	,t.ReportGroupLevel1 as ReportGroupLevel1
	,NULL as ReportGroupLevel2 
	,NULL as ReportGroupLevel3
	--,t.ReportGroupLevel4 as ReportGroupLevel4
	,NULL as PracticeID 
	,null as ReportingProviderID 
	,CASE WHEN ISNULL(SUM(t.FiscalPeriodDenominator),0) = 0 THEN 0.00 ELSE  SUM(t.FiscalPeriodNumerator) /  SUM(t.FiscalPeriodDenominator) END as FiscalPeriodValue 
	,SUM(t.FiscalPeriodNumerator) as FiscalPeriodNumerator
	,SUM(t.FiscalPeriodDenominator) as FiscalPeriodDenominator
	,GETDATE() AS UpdatedDatetime 
	FROM #TempChargeLag t
	GROUP BY
		t.FiscalYear
		,t.FiscalPeriod
		,t.FiscalYearPeriod
		,t.ReportGroupLevel1
		--,t.ReportGroupLevel2
		--,t.ReportGroupLevel4 --as ReportGroupLevel4
		--,t.PracticeID
		--,t.ReportingProviderID
		--,p.ProviderID

/*8.12.25 --Added in for location-specific reports*/

/*Delete and Reload*/
	DELETE FROM rpt.BlueBooks WHERE ReportSection in ('Charge Lag By Type By Practice By Special Filter') and FiscalYear >= @CurrentYear-1
	
	INSERT INTO rpt.BlueBooks 

	([FiscalYear] 
      ,[FiscalPeriod]
      ,[FiscalYearPeriod]
      ,[ReportSection]
      ,[ReportGroupLevel1]
      ,[ReportGroupLevel2]
	  ,[ReportGroupLevel3]
	  ,[ReportGroupLevel4]
      ,[PracticeID]
      ,[ReportingProviderID]
      ,[FiscalPeriodValue]
	  ,[FiscalPeriodNumerator]
	  ,[FiscalPeriodDenominator]
      ,[UpdatedDatetime])

	SELECT
	t.FiscalYear AS FiscalYear 
	,t.FiscalPeriod AS FiscalPeriod 
	,t.FiscalYearPeriod AS FiscalYearPeriod 
	,'Charge Lag By Type By Practice By Special Filter' as ReportSection
	,t.ReportGroupLevel1 as ReportGroupLevel1
	,NULL as ReportGroupLevel2 
	,NULL as ReportGroupLevel3
	,t.ReportGroupLevel4 as ReportGroupLevel4
	,T.PracticeID as PracticeID 
	,null as ReportingProviderID 
	,CASE WHEN ISNULL(SUM(t.FiscalPeriodDenominator),0) = 0 THEN 0.00 ELSE  SUM(t.FiscalPeriodNumerator) /  SUM(t.FiscalPeriodDenominator) END as FiscalPeriodValue 
	,SUM(t.FiscalPeriodNumerator) as FiscalPeriodNumerator
	,SUM(t.FiscalPeriodDenominator) as FiscalPeriodDenominator
	,GETDATE() AS UpdatedDatetime 
	FROM #TempChargeLag t
	GROUP BY
		t.FiscalYear
		,t.FiscalPeriod
		,t.FiscalYearPeriod
		,t.ReportGroupLevel1
		--,t.ReportGroupLevel2
		--,t.ReportGroupLevel3
		,t.ReportGroupLevel4 
		,t.PracticeID
		--,t.ReportingProviderID
		--,p.ProviderID


/*Delete and Reload*/
	DELETE FROM rpt.BlueBooks WHERE ReportSection in ('Charge Lag By Type By Provider By Special Filter') and FiscalYear >= @CurrentYear-1
	
	INSERT INTO rpt.BlueBooks 

	([FiscalYear] 
      ,[FiscalPeriod]
      ,[FiscalYearPeriod]
      ,[ReportSection]
      ,[ReportGroupLevel1]
      ,[ReportGroupLevel2]
	  ,[ReportGroupLevel3]
	  ,[ReportGroupLevel4]
      ,[PracticeID]
      ,[ReportingProviderID]
      ,[FiscalPeriodValue]
	  ,[FiscalPeriodNumerator]
	  ,[FiscalPeriodDenominator]
      ,[UpdatedDatetime])

	SELECT
	t.FiscalYear AS FiscalYear 
	,t.FiscalPeriod AS FiscalPeriod 
	,t.FiscalYearPeriod AS FiscalYearPeriod 
	,'Charge Lag By Type By Provider By Special Filter' as ReportSection
	,t.ReportGroupLevel1 as ReportGroupLevel1
	,NULL as ReportGroupLevel2 
	,NULL as ReportGroupLevel3
	,t.ReportGroupLevel4 as ReportGroupLevel4
	,T.PracticeID as PracticeID
	,MIN(p.ProviderID) as ReportingProviderID  
	--,t.ReportingProviderID as ReportingProviderID 
	,CASE WHEN ISNULL(SUM(t.FiscalPeriodDenominator),0) = 0 THEN 0.00 ELSE  SUM(t.FiscalPeriodNumerator) /  SUM(t.FiscalPeriodDenominator) END as FiscalPeriodValue 
	,SUM(t.FiscalPeriodNumerator) as FiscalPeriodNumerator
	,SUM(t.FiscalPeriodDenominator) as FiscalPeriodDenominator
	,GETDATE() AS UpdatedDatetime 
	FROM #TempChargeLag t
	left join dim.vProviders p ON p.ProviderID = t.ReportingProviderID
	GROUP BY
		t.FiscalYear
		,t.FiscalPeriod
		,t.FiscalYearPeriod
		,t.ReportGroupLevel1
		--,t.ReportGroupLevel2
		,t.ReportGroupLevel4 --as ReportGroupLevel4
		,t.PracticeID
		--,t.ReportingProviderID
		,p.ProviderID --Here I change to ProviderID Instead parent 
		--,p.ProviderID

/*Delete and Reload*/
	DELETE FROM rpt.BlueBooks WHERE ReportSection in ('Charge Lag By Practice By Special Filter') and FiscalYear >= @CurrentYear-1
	
	INSERT INTO rpt.BlueBooks 

	([FiscalYear] 
      ,[FiscalPeriod]
      ,[FiscalYearPeriod]
      ,[ReportSection]
      ,[ReportGroupLevel1]
      ,[ReportGroupLevel2]
	  ,[ReportGroupLevel3]
	  ,[ReportGroupLevel4]
      ,[PracticeID]
      ,[ReportingProviderID]
      ,[FiscalPeriodValue]
	  ,[FiscalPeriodNumerator]
	  ,[FiscalPeriodDenominator]
      ,[UpdatedDatetime])

	SELECT
	t.FiscalYear AS FiscalYear 
	,t.FiscalPeriod AS FiscalPeriod 
	,t.FiscalYearPeriod AS FiscalYearPeriod 
	,'Charge Lag By Practice By Special Filter' as ReportSection
	,NULL as ReportGroupLevel1
	,NULL as ReportGroupLevel2 
	,NULL as ReportGroupLevel3
	,t.ReportGroupLevel4 --as ReportGroupLevel4
	,T.PracticeID as PracticeID 
	,null as ReportingProviderID 
	,CASE WHEN ISNULL(SUM(t.FiscalPeriodDenominator),0) = 0 THEN 0.00 ELSE  SUM(t.FiscalPeriodNumerator) /  SUM(t.FiscalPeriodDenominator) END as FiscalPeriodValue 
	,SUM(t.FiscalPeriodNumerator) as FiscalPeriodNumerator
	,SUM(t.FiscalPeriodDenominator) as FiscalPeriodDenominator
	,GETDATE() AS UpdatedDatetime 
	FROM #TempChargeLag t
	GROUP BY
		t.FiscalYear
		,t.FiscalPeriod
		,t.FiscalYearPeriod
		--,t.ReportGroupLevel1
		--,t.ReportGroupLevel2
		,t.ReportGroupLevel4 --as ReportGroupLevel4
		,t.PracticeID
		--,t.ReportingProviderID
		--,p.ProviderID


/*Delete and Reload*/
	DELETE FROM rpt.BlueBooks WHERE ReportSection in ('Charge Lag By Provider By Special Filter') and FiscalYear >= @CurrentYear-1
	
	INSERT INTO rpt.BlueBooks 

	([FiscalYear] 
      ,[FiscalPeriod]
      ,[FiscalYearPeriod]
      ,[ReportSection]
      ,[ReportGroupLevel1]
      ,[ReportGroupLevel2]
	  ,[ReportGroupLevel3]
	  ,[ReportGroupLevel4]
      ,[PracticeID]
      ,[ReportingProviderID]
      ,[FiscalPeriodValue]
	  ,[FiscalPeriodNumerator]
	  ,[FiscalPeriodDenominator]
      ,[UpdatedDatetime])

	SELECT
	t.FiscalYear AS FiscalYear 
	,t.FiscalPeriod AS FiscalPeriod 
	,t.FiscalYearPeriod AS FiscalYearPeriod 
	,'Charge Lag By Provider By Special Filter' as ReportSection
	,NULL as ReportGroupLevel1
	,NULL as ReportGroupLevel2 
	,NULL as ReportGroupLevel3
	,t.ReportGroupLevel4 as ReportGroupLevel4
	,T.PracticeID as PracticeID 
	,MIN(p.ProviderID) as ReportingProviderID 
	--,t.ReportingProviderID as ReportingProviderID 
	,CASE WHEN ISNULL(SUM(t.FiscalPeriodDenominator),0) = 0 THEN 0.00 ELSE  SUM(t.FiscalPeriodNumerator) /  SUM(t.FiscalPeriodDenominator) END as FiscalPeriodValue 
	,SUM(t.FiscalPeriodNumerator) as FiscalPeriodNumerator
	,SUM(t.FiscalPeriodDenominator) as FiscalPeriodDenominator
	,GETDATE() AS UpdatedDatetime 
	FROM #TempChargeLag t
	left join dim.vProviders p ON p.ProviderID = t.ReportingProviderID
	GROUP BY
		t.FiscalYear
		,t.FiscalPeriod
		,t.FiscalYearPeriod
		--,t.ReportGroupLevel1
		--,t.ReportGroupLevel2
		,t.ReportGroupLevel4 --as ReportGroupLevel4
		,t.PracticeID
		,p.ProviderID --Here I change to ProviderID Instead parent 
		--,t.ReportingProviderID
		--,p.ProviderID

/*Delete and Reload*/
	DELETE FROM rpt.BlueBooks WHERE ReportSection in ('Charge Lag By Type By Special Filter') and FiscalYear >= @CurrentYear-1
	
	INSERT INTO rpt.BlueBooks 

	([FiscalYear] 
      ,[FiscalPeriod]
      ,[FiscalYearPeriod]
      ,[ReportSection]
      ,[ReportGroupLevel1]
      ,[ReportGroupLevel2]
	  ,[ReportGroupLevel3]
	  ,[ReportGroupLevel4]
      ,[PracticeID]
      ,[ReportingProviderID]
      ,[FiscalPeriodValue]
	  ,[FiscalPeriodNumerator]
	  ,[FiscalPeriodDenominator]
      ,[UpdatedDatetime])

	SELECT
	t.FiscalYear AS FiscalYear 
	,t.FiscalPeriod AS FiscalPeriod 
	,t.FiscalYearPeriod AS FiscalYearPeriod 
	,'Charge Lag By Type By Special Filter' as ReportSection
	,t.ReportGroupLevel1 as ReportGroupLevel1
	,NULL as ReportGroupLevel2 
	,NULL as ReportGroupLevel3
	,t.ReportGroupLevel4 as ReportGroupLevel4
	,NULL as PracticeID 
	,null as ReportingProviderID 
	,CASE WHEN ISNULL(SUM(t.FiscalPeriodDenominator),0) = 0 THEN 0.00 ELSE  SUM(t.FiscalPeriodNumerator) /  SUM(t.FiscalPeriodDenominator) END as FiscalPeriodValue 
	,SUM(t.FiscalPeriodNumerator) as FiscalPeriodNumerator
	,SUM(t.FiscalPeriodDenominator) as FiscalPeriodDenominator
	,GETDATE() AS UpdatedDatetime 
	FROM #TempChargeLag t
	GROUP BY
		t.FiscalYear
		,t.FiscalPeriod
		,t.FiscalYearPeriod
		,t.ReportGroupLevel1
		--,t.ReportGroupLevel2
		,t.ReportGroupLevel4 --as ReportGroupLevel4
		--,t.PracticeID
		--,t.ReportingProviderID
		--,p.ProviderID
GO
