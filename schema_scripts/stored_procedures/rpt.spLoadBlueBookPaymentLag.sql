CREATE PROCEDURE [rpt].[spLoadBlueBookPaymentLag] as

/*
Change Control:
	1. 9/4/24 - Chris Cross - Replaced fact.Transactions2 with fact.TransactionsPB
	2. 6/4/25 - Eric Silvestri - Added datasource 12 to the where clause to include HPI Customer data 
	3. 8/12/25 - Chris Cross - Added ReportGroupLevel4 for SCS location-specific reports
	4. 1/8/26 - Diego Hernandez - Added datasource 15 to the where clause to include Modmed 
	5. 1/12/26 - Diego Hernandez - Changed ParentProviderID to ProviderID  

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


/*Load Temp Table with consolidated payment data*/
IF OBJECT_ID('tempdb..#TempPaymentLag') IS NOT NULL DROP TABLE #TempPaymentLag

		SELECT
			sub.FiscalYear
			,sub.FiscalPeriod
			,sub.FiscalYearPeriod
			,sub.ReportSection
			,sub.ReportGroupLevel1
			,sub.ReportGroupLevel2
			,sub.ReportGroupLevel3
			,sub.ReportGroupLevel4
			,sub.PracticeID
			,min(sub.ReportingProviderID) as ReportingProviderID -- Here we replace the min for ParentProviderID
			--,sub.ReportingProviderID
			,SUM(sub.PaymentDays) as FiscalPeriodNumerator
			,Sum(sub.PaymentCount) as FiscalPeriodDenominator
			,GETDATE() AS UpdatedDatetime 
		INTO #TempPaymentLag
		FROM (
		select 
			ROW_NUMBER() OVER(PARTITION BY t.TransactionVisitID ORDER BY t.TransactionDateOfPosting) as TransactionOrder
			,LEFT(t.TransactionReportingPeriodID,4) AS FiscalYear 
			,RIGHT(t.TransactionReportingPeriodID,2) AS FiscalPeriod 
			,FORMAT(DATEFROMPARTS(LEFT(t.TransactionReportingPeriodID,4),RIGHT(t.TransactionReportingPeriodID,2),1),'MMM-yy') AS FiscalYearPeriod 
			,'Payment Lag' as ReportSection
			,ISNULL(pg.PayerGroupName,'Other Commercial') as ReportGroupLevel1
			,NULL as ReportGroupLevel2 
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
			,t.TransactionBillingProviderID as ReportingProviderID 
			,DATEDIFF(DAY,t.TransactionDateOfService,t.TransactionDateOfPosting) as PaymentDays
			,1 AS PaymentCount
			--,t.*
		FROM fact.TransactionsPB t
			left join dim.Departments d ON d.DepartmentID = t.TransactionDepartmentID
			left join map.ProviderLinking pl ON pl.ChildProviderID = t.TransactionBillingProviderID
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
												/*All other providers without specific mapping issues due to multiple practices as defined above*/
												OR pl.ParentProviderID not in ('0~1588209423','0~1679132823','0~1992746200','0~1891761136','0~1376509828','0~1245788231','0~1376507665','0~1063484251'))
			left join dim.Practices pt ON pt.PracticeID = COALESCE(pd.PracticeID,pp.PracticeID)
			left join dim.Payers py ON py.PayerID = t.TransactionPayerID
			left join dim.PayerGroups pg ON pg.PayerGroupID = py.PayerGroupID
			left join fact.Visits2 v on t.TransactionVisitID = v.VisitID
			
			/*Change this to VisitID eventually*/
			--left join rpt.BlueBookVisitInfo vi ON  vi.EncounterID = t.TransactionEncounterID --AND vi.AccountID = t.TransactionAccountID 
		WHERE 1=1
			AND t.TransactionBillingType = 'PB'
			AND t.TransactionType in ('Payment')
			--AND (pd.DepartmentID is not null OR t.TransactionDatasourceID = 1)
			AND (pd.DepartmentID is not null OR t.TransactionDatasourceID IN (1, 12 , 15))
			--AND t.TransactionBillingProviderID = '1~17422'
			--AND t.TransactionAccountID = '1~25691320'
			AND t.TransactionAmount <> 0
			AND T.TransactionDateOfPosting >= DATEADD(DAY,2,t.TransactionDateOfService) /*Exclude Date of Service Collections*/
			AND t.TransactionDateOfService >= @StartDate /*CC - 10.30.24 - Modified to only include dates of service in the last year forward to exclude long outliers*/
			and (@Practice = '0' OR pt.PracticeSourceID = @Practice)
		) sub
		left join dim.vProviders p ON p.ProviderID = sub.ReportingProviderID
		WHERE 1=1
			AND sub.TransactionOrder = 1			
			--AND LEFT(t.TransactionReportingPeriodID, 4)
			--and d.DepartmentName like '%Diesselhorst%'
		GROUP BY
			sub.FiscalYear
			,sub.FiscalPeriod
			,sub.FiscalYearPeriod
			,sub.ReportSection
			,sub.ReportGroupLevel1
			,sub.ReportGroupLevel2
			,sub.ReportGroupLevel3
			,sub.ReportGroupLevel4
			,sub.PracticeID
			,sub.ReportingProviderID  --Here 
			--,sub.ReportingProviderID

--select * from #TempPaymentLag

/*Delete and Reload*/
	DELETE FROM rpt.BlueBooks WHERE ReportSection in ('Payment Lag By Payer By Practice') and FiscalYear >= @CurrentYear-1
	
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
	,'Payment Lag By Payer By Practice' as ReportSection
	,t.ReportGroupLevel1 as ReportGroupLevel1
	,NULL as ReportGroupLevel2 
	,NULL as ReportGroupLevel3
	,T.PracticeID as PracticeID 
	,null as ReportingProviderID 
	,CASE WHEN ISNULL(SUM(t.FiscalPeriodDenominator),0) = 0 THEN 0.00 ELSE  SUM(t.FiscalPeriodNumerator) /  SUM(t.FiscalPeriodDenominator) END as FiscalPeriodValue 
	,SUM(t.FiscalPeriodNumerator) AS FiscalPeriodNumerator
	,SUM(t.FiscalPeriodDenominator) AS FiscalPeriodDenominator
	,GETDATE() AS UpdatedDatetime 
	FROM #TempPaymentLag t
	GROUP BY
		t.FiscalYear
		,t.FiscalPeriod
		,t.FiscalYearPeriod
		,t.ReportGroupLevel1
		--,t.ReportGroupLevel2
		,t.PracticeID
		--,t.ReportingProviderID
		--,p.ProviderID

	/*Delete and Reload*/
	DELETE FROM rpt.BlueBooks WHERE ReportSection in ('Payment Lag By Payer By Provider') and FiscalYear >= @CurrentYear-1
	
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
	,'Payment Lag By Payer By Provider' as ReportSection
	,t.ReportGroupLevel1 as ReportGroupLevel1
	,NULL as ReportGroupLevel2 
	,NULL as ReportGroupLevel3
	,T.PracticeID as PracticeID 
	,MIN(p.ProviderID) as ReportingProviderID 
	,CASE WHEN ISNULL(SUM(t.FiscalPeriodDenominator),0) = 0 THEN 0.00 ELSE  SUM(t.FiscalPeriodNumerator) /  SUM(t.FiscalPeriodDenominator) END as FiscalPeriodValue 
	,SUM(t.FiscalPeriodNumerator) AS FiscalPeriodNumerator
	,SUM(t.FiscalPeriodDenominator) AS FiscalPeriodDenominator
	,GETDATE() AS UpdatedDatetime 
	FROM #TempPaymentLag t
	left join dim.vProviders p ON p.ProviderID = t.ReportingProviderID
	GROUP BY
		t.FiscalYear
		,t.FiscalPeriod
		,t.FiscalYearPeriod
		,t.ReportGroupLevel1
		--,t.ReportGroupLevel2
		,t.PracticeID
		,p.ProviderID --,t.ReportingProviderID
		--,p.ProviderID

	/*Delete and Reload*/
	DELETE FROM rpt.BlueBooks WHERE ReportSection in ('Payment Lag By Practice') and FiscalYear >= @CurrentYear-1
	
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
	,'Payment Lag By Practice' as ReportSection
	,NULL as ReportGroupLevel1
	,NULL as ReportGroupLevel2 
	,NULL as ReportGroupLevel3
	,T.PracticeID as PracticeID 
	,null as ReportingProviderID 
	,CASE WHEN ISNULL(SUM(t.FiscalPeriodDenominator),0) = 0 THEN 0.00 ELSE  SUM(t.FiscalPeriodNumerator) /  SUM(t.FiscalPeriodDenominator) END as FiscalPeriodValue 
	,SUM(t.FiscalPeriodNumerator) AS FiscalPeriodNumerator
	,SUM(t.FiscalPeriodDenominator) AS FiscalPeriodDenominator
	,GETDATE() AS UpdatedDatetime 
	FROM #TempPaymentLag t
	GROUP BY
		t.FiscalYear
		,t.FiscalPeriod
		,t.FiscalYearPeriod
		--,t.ReportGroupLevel1
		--,t.ReportGroupLevel2
		,t.PracticeID
		--,t.ReportingProviderID
		--,p.ProviderID


/*Delete and Reload*/
	DELETE FROM rpt.BlueBooks WHERE ReportSection in ('Payment Lag By Provider') and FiscalYear >= @CurrentYear-1
	
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
	,'Payment Lag By Provider' as ReportSection
	,NULL as ReportGroupLevel1
	,NULL as ReportGroupLevel2 
	,NULL as ReportGroupLevel3
	,T.PracticeID as PracticeID 
	,MIN(p.ProviderID) as ReportingProviderID 
	,CASE WHEN ISNULL(SUM(t.FiscalPeriodDenominator),0) = 0 THEN 0.00 ELSE  SUM(t.FiscalPeriodNumerator) /  SUM(t.FiscalPeriodDenominator) END as FiscalPeriodValue 
	,SUM(t.FiscalPeriodNumerator) AS FiscalPeriodNumerator
	,SUM(t.FiscalPeriodDenominator) AS FiscalPeriodDenominator
	,GETDATE() AS UpdatedDatetime 
	FROM #TempPaymentLag t
	left join dim.vProviders p ON p.ProviderID = t.ReportingProviderID
	GROUP BY
		t.FiscalYear
		,t.FiscalPeriod
		,t.FiscalYearPeriod
		--,t.ReportGroupLevel1
		--,t.ReportGroupLevel2
		,t.PracticeID
		,p.ProviderID --,t.ReportingProviderID --We update this to ProviderID instead of parent
		--,p.ProviderID

/*Delete and Reload*/
	DELETE FROM rpt.BlueBooks WHERE ReportSection in ('Payment Lag By Payer') and FiscalYear >= @CurrentYear-1
	
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
	,'Payment Lag By Payer' as ReportSection
	,t.ReportGroupLevel1 as ReportGroupLevel1
	,NULL as ReportGroupLevel2 
	,NULL as ReportGroupLevel3
	,NULL as PracticeID 
	,NULL as ReportingProviderID 
	,CASE WHEN ISNULL(SUM(t.FiscalPeriodDenominator),0) = 0 THEN 0.00 ELSE  SUM(t.FiscalPeriodNumerator) /  SUM(t.FiscalPeriodDenominator) END as FiscalPeriodValue 
	,SUM(t.FiscalPeriodNumerator) AS FiscalPeriodNumerator
	,SUM(t.FiscalPeriodDenominator) AS FiscalPeriodDenominator
	,GETDATE() AS UpdatedDatetime 
	FROM #TempPaymentLag t
	GROUP BY
		t.FiscalYear
		,t.FiscalPeriod
		,t.FiscalYearPeriod
		,t.ReportGroupLevel1
		--,t.ReportGroupLevel2
		--,t.PracticeID
		--,t.ReportingProviderID
		--,p.ProviderID
	
/*Delete and Reload*/


	DELETE FROM rpt.BlueBooks WHERE ReportSection in ('Payment Lag') and FiscalYear >= @CurrentYear-1
	
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
	,'Payment Lag' as ReportSection
	,NULL as ReportGroupLevel1
	,NULL as ReportGroupLevel2 
	,NULL as ReportGroupLevel3
	,NULL as PracticeID 
	,NULL as ReportingProviderID 
	,CASE WHEN ISNULL(SUM(t.FiscalPeriodDenominator),0) = 0 THEN 0.00 ELSE  SUM(t.FiscalPeriodNumerator) /  SUM(t.FiscalPeriodDenominator) END as FiscalPeriodValue
	,SUM(t.FiscalPeriodNumerator) AS FiscalPeriodNumerator
	,SUM(t.FiscalPeriodDenominator) AS FiscalPeriodDenominator
	,GETDATE() AS UpdatedDatetime 
	FROM #TempPaymentLag t
	GROUP BY
		t.FiscalYear
		,t.FiscalPeriod
		,t.FiscalYearPeriod
		--,t.ReportGroupLevel1
		--,t.ReportGroupLevel2
		--,t.PracticeID
		--,t.ReportingProviderID
		--,p.ProviderID
	
/*8.12.25 - Chris Cross added for Special Filter reports*/

/*Delete and Reload*/
	DELETE FROM rpt.BlueBooks WHERE ReportSection in ('Payment Lag By Payer By Practice By Special Filter') and FiscalYear >= @CurrentYear-1
	
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
	,'Payment Lag By Payer By Practice By Special Filter' as ReportSection
	,t.ReportGroupLevel1 as ReportGroupLevel1
	,NULL as ReportGroupLevel2 
	,NULL as ReportGroupLevel3
	,t.ReportGroupLevel4
	,T.PracticeID as PracticeID 
	,null as ReportingProviderID 
	,CASE WHEN ISNULL(SUM(t.FiscalPeriodDenominator),0) = 0 THEN 0.00 ELSE  SUM(t.FiscalPeriodNumerator) /  SUM(t.FiscalPeriodDenominator) END as FiscalPeriodValue 
	,SUM(t.FiscalPeriodNumerator) AS FiscalPeriodNumerator
	,SUM(t.FiscalPeriodDenominator) AS FiscalPeriodDenominator
	,GETDATE() AS UpdatedDatetime 
	FROM #TempPaymentLag t
	GROUP BY
		t.FiscalYear
		,t.FiscalPeriod
		,t.FiscalYearPeriod
		,t.ReportGroupLevel1
		--,t.ReportGroupLevel2
		,t.ReportGroupLevel4
		,t.PracticeID
		--,t.ReportingProviderID
		--,p.ProviderID

	/*Delete and Reload*/
	DELETE FROM rpt.BlueBooks WHERE ReportSection in ('Payment Lag By Payer By Provider By Special Filter') and FiscalYear >= @CurrentYear-1
	
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
	,'Payment Lag By Payer By Provider By Special Filter' as ReportSection
	,t.ReportGroupLevel1 as ReportGroupLevel1
	,NULL as ReportGroupLevel2 
	,NULL as ReportGroupLevel3
	,t.ReportGroupLevel4
	,T.PracticeID as PracticeID 
	,MIN(p.ProviderID) as ReportingProviderID 
	,CASE WHEN ISNULL(SUM(t.FiscalPeriodDenominator),0) = 0 THEN 0.00 ELSE  SUM(t.FiscalPeriodNumerator) /  SUM(t.FiscalPeriodDenominator) END as FiscalPeriodValue 
	,SUM(t.FiscalPeriodNumerator) AS FiscalPeriodNumerator
	,SUM(t.FiscalPeriodDenominator) AS FiscalPeriodDenominator
	,GETDATE() AS UpdatedDatetime 
	FROM #TempPaymentLag t
	left join dim.vProviders p ON p.ProviderID = t.ReportingProviderID
	GROUP BY
		t.FiscalYear
		,t.FiscalPeriod
		,t.FiscalYearPeriod
		,t.ReportGroupLevel1
		--,t.ReportGroupLevel2
		,t.ReportGroupLevel4
		,t.PracticeID
		,p.ProviderID --,t.ReportingProviderID --Here we update to ProviderID Instead ParentProviderID
		--,p.ProviderID

	/*Delete and Reload*/
	DELETE FROM rpt.BlueBooks WHERE ReportSection in ('Payment Lag By Practice By Special Filter') and FiscalYear >= @CurrentYear-1
	
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
	,'Payment Lag By Practice By Special Filter' as ReportSection
	,NULL as ReportGroupLevel1
	,NULL as ReportGroupLevel2 
	,NULL as ReportGroupLevel3
	,t.ReportGroupLevel4
	,T.PracticeID as PracticeID 
	,null as ReportingProviderID 
	,CASE WHEN ISNULL(SUM(t.FiscalPeriodDenominator),0) = 0 THEN 0.00 ELSE  SUM(t.FiscalPeriodNumerator) /  SUM(t.FiscalPeriodDenominator) END as FiscalPeriodValue 
	,SUM(t.FiscalPeriodNumerator) AS FiscalPeriodNumerator
	,SUM(t.FiscalPeriodDenominator) AS FiscalPeriodDenominator
	,GETDATE() AS UpdatedDatetime 
	FROM #TempPaymentLag t
	GROUP BY
		t.FiscalYear
		,t.FiscalPeriod
		,t.FiscalYearPeriod
		--,t.ReportGroupLevel1
		--,t.ReportGroupLevel2
		,t.ReportGroupLevel4
		,t.PracticeID
		--,t.ReportingProviderID
		--,p.ProviderID


/*Delete and Reload*/
	DELETE FROM rpt.BlueBooks WHERE ReportSection in ('Payment Lag By Provider By Special Filter') and FiscalYear >= @CurrentYear-1
	
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
	,'Payment Lag By Provider By Special Filter' as ReportSection
	,NULL as ReportGroupLevel1
	,NULL as ReportGroupLevel2 
	,NULL as ReportGroupLevel3
	,t.ReportGroupLevel4
	,T.PracticeID as PracticeID 
	,MIN(p.ProviderID) as ReportingProviderID 
	,CASE WHEN ISNULL(SUM(t.FiscalPeriodDenominator),0) = 0 THEN 0.00 ELSE  SUM(t.FiscalPeriodNumerator) /  SUM(t.FiscalPeriodDenominator) END as FiscalPeriodValue 
	,SUM(t.FiscalPeriodNumerator) AS FiscalPeriodNumerator
	,SUM(t.FiscalPeriodDenominator) AS FiscalPeriodDenominator
	,GETDATE() AS UpdatedDatetime 
	FROM #TempPaymentLag t
	left join dim.vProviders p ON p.ProviderID = t.ReportingProviderID
	GROUP BY
		t.FiscalYear
		,t.FiscalPeriod
		,t.FiscalYearPeriod
		--,t.ReportGroupLevel1
		--,t.ReportGroupLevel2
		,t.ReportGroupLevel4
		,t.PracticeID
		,p.ProviderID --,t.ReportingProviderID --Here
		--,p.ProviderID

/*Delete and Reload*/
	DELETE FROM rpt.BlueBooks WHERE ReportSection in ('Payment Lag By Payer By Special Filter') and FiscalYear >= @CurrentYear-1
	
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
	,'Payment Lag By Payer By Special Filter' as ReportSection
	,t.ReportGroupLevel1 as ReportGroupLevel1
	,NULL as ReportGroupLevel2 
	,NULL as ReportGroupLevel3
	,t.ReportGroupLevel4
	,NULL as PracticeID 
	,NULL as ReportingProviderID 
	,CASE WHEN ISNULL(SUM(t.FiscalPeriodDenominator),0) = 0 THEN 0.00 ELSE  SUM(t.FiscalPeriodNumerator) /  SUM(t.FiscalPeriodDenominator) END as FiscalPeriodValue 
	,SUM(t.FiscalPeriodNumerator) AS FiscalPeriodNumerator
	,SUM(t.FiscalPeriodDenominator) AS FiscalPeriodDenominator
	,GETDATE() AS UpdatedDatetime 
	FROM #TempPaymentLag t
	GROUP BY
		t.FiscalYear
		,t.FiscalPeriod
		,t.FiscalYearPeriod
		,t.ReportGroupLevel1
		--,t.ReportGroupLevel2
		,t.ReportGroupLevel4
		--,t.PracticeID
		--,t.ReportingProviderID
		--,p.ProviderID
GO
