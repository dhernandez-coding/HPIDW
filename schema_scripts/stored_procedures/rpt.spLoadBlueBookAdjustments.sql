CREATE PROCEDURE  [rpt].[spLoadBlueBookAdjustments] as



/*
Change Control:
	1. 9/4/24 - Chris Cross - Replaced fact.Transactions2 with fact.TransactionsPB
	2. 1/10/25 - Chris Cross - Excluded Payments - New and Payments - Distributed from visit detail due to undist payments being assigned to visits without a Billing Provider
	3. 4/30/25 - Chris Cross - Added "when t.TransactionDepartmentID = '5~42501006002' THEN 'Shadid Choctaw' --Checks if Choctaw department for Shadid" for ReportGroupLevel4
	4. 5/8/25 - Chris Cross - Added "when t.TransactionDepartmentID = '5~42501006001' THEN 'Shadid Edmond' --Checks if Edmond department for Shadid for ReportGroupLevel4
	5. 6/4/25 - Eric Silvestri - Added datasource 12 to the where clause to include HPI Customer data 
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


		
/*Delete and Reload*/
	DELETE FROM rpt.BlueBooks WHERE ReportSection in ('Adjustments') and FiscalYear >= @CurrentYear-1
	
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
      ,[UpdatedDatetime])

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
		,sub.ReportingProviderID
		,sum(sub.FiscalPeriodValue) as FiscalPeriodValue
		,GETDATE() as UpdateDatetime
	FROM (
		SELECT
		LEFT(t.TransactionReportPeriodDate,4) AS FiscalYear 
		,RIGHT(t.TransactionReportPeriodDate,2) AS FiscalPeriod 
		,FORMAT(DATEFROMPARTS(LEFT(t.TransactionReportPeriodDate,4),RIGHT(t.TransactionReportPeriodDate,2),1),'MMM-yy') AS FiscalYearPeriod 
		,'Adjustments' as ReportSection
		,ISNULL(vi.VisitType,'Other Visits') as ReportGroupLevel1
		,ISNULL(vi.VisitSubtype,'Misc') as ReportGroupLevel2 
		,ISNULL(t.TransactionARCategory,'99_No Category') as ReportGroupLevel3
		,CASE
			WHEN t.TransactionDepartmentID IN ('1~10','1~25') THEN 'PI' -- Checks if Personal Injury account for Kim
			WHEN t.TransactionBillingProviderID in ('1~18524','5~P1008411') THEN 'PI' --5.8.26 Mapped all Kevin Chessmore (EKK) activity to PI
			when t.TransactionDepartmentID = '5~42501006002' THEN 'SCS Choctaw' --Checks if Choctaw department for Shadid
			when t.TransactionDepartmentID = '5~42501006001' THEN 'SCS Edmond' --Checks if Choctaw department for Shadid
			WHEN (v.VisitLocationID = '1~135' OR t.TransactionDepartmentID = '5~42501041001') AND pt.PracticeID = '0~TDT' THEN 'Hinton' -- checks for location and provider for Thomason
			WHEN (v.VisitLocationID = '1~223' OR t.TransactionDepartmentID = '5~42501043001') AND pt.PracticeID = '0~TDT' THEN 'Binger'
			WHEN (v.VisitLocationID = '1~230' OR t.TransactionDepartmentID = '5~42501042001') AND pt.PracticeID = '0~TDT' THEN 'Hydro'
			WHEN v.VisitLocationID = '1~95' AND pt.PracticeID = '0~TDT' THEN 'Hinton'			
		END AS ReportGroupLevel4
		,pt.PracticeID as PracticeID 
		,t.TransactionBillingProviderID as ReportingProviderID 
		,SUM(t.TransactionActiveARAmount * -1) as FiscalPeriodValue 
		,GETDATE() AS UpdatedDatetime 

		--select pd.PracticeID,pp.PracticeID,pt.*,t.*
		FROM fact.vTransactionsPB t 
				--left join dim.Departments d ON d.DepartmentID = t.TransactionDepartmentID
				--left join map.ProviderLinking pl ON pl.ChildProviderID = t.TransactionBillingProviderID
				--left join map.PracticeDepartments pd ON pd.DepartmentID = t.TransactionDepartmentID
				--left join map.vPracticeProviders pp ON pp.ParentProviderID = pl.ParentProviderID
				--						AND pp.PracticeProviderEffectiveDate <= t.TransactionDateOfPosting 
				--						AND pp.PracticeProviderEndDate >= t.TransactionDateOfPosting
				--						AND (/*This is here to handle duplicates with Murphi Scarborough at multiple practices*/
				--									(pl.ParentProviderID in ('0~1588209423') 
				--										AND (pp.PracticeID = pd.PracticeID OR (pd.PracticeID is null AND (t.TransactionDatasourceID = 5 AND pp.PracticeID = '0~RGS')
				--																										  OR (t.TransactionDatasourceID = 1 AND pp.PracticeID = '0~RLN'))) )
				--									/*This is here to handle duplicates with Amy James at multiple practices*/
				--									OR (pl.ParentProviderID in ('0~1679132823') 
				--										AND (pp.PracticeID = pd.PracticeID OR (pd.PracticeID is null AND (t.TransactionDatasourceID = 5 AND pp.PracticeID = '0~MDW')
				--																										  OR (t.TransactionDatasourceID = 1 AND pp.PracticeID = '0~CGW'))) )
				--									/*Chris Cross - 10.7.24 - Added Olivo, Pape, and Dunkleberger due to practicing at PBJ, NMO, and NRJ; Defaults to PBJ if no mapped department defined in Epic*/
				--									OR (pl.ParentProviderID in ('0~1992746200','0~1891761136','0~1376509828') 
				--										AND (pp.PracticeID = pd.PracticeID OR (pd.PracticeID is null AND  pp.PracticeID = '0~PBJ') ) )
				--									/*Chris Cross - 02.18.25 - Added Jill Yingling due to practicing at MBJ and RLN; Defaults to RLN if no mapped department defined in Epic*/
				--									OR (pl.ParentProviderID in ('0~1245788231') 
				--										AND (pp.PracticeID = pd.PracticeID OR (pd.PracticeID is null AND pp.PracticeID = '0~RLN') ) )
				--									/*All other providers without specific mapping issues due to multiple practices as defined above*/
				--									OR pl.ParentProviderID not in ('0~1588209423','0~1679132823','0~1992746200','0~1891761136','0~1376509828','0~1245788231'))
				--left join dim.vPractices pt ON pt.PracticeID = COALESCE(pd.PracticeID,pp.PracticeID)
			/*Change this to VisitID eventually*/
			left join rpt.BlueBookVisitInfo vi ON vi.VisitID = t.TransactionVisitID AND vi.VisitDateOfService = t.TransactionDateOfService
												--  AND t.TransactionSubType not in ('Payment - Distributed','Payment - New') /*Chris Cross - excluded these on 1/10/25 due to undist payments being assigned to visits without a Billing Provider*/
			left join fact.Visits2 v on t.TransactionVisitID = v.VisitID
			left join dim.vPractices pt ON pt.PracticeID = t.TransactionPracticeID --<Replaced by practice mapping from view on 6/9/25 - Chris Cross
		WHERE 1=1
			AND t.TransactionBillingType = 'PB'
			AND t.TransactionType in ('Adjustment')
			--AND (pd.DepartmentID is not null OR t.TransactionDatasourceID IN (1, 12)) --<Replaced by practice mapping from view on 6/9/25 - Chris Cross
			AND t.TransactionPracticeID is not null --<Replaced by practice mapping from view on 6/9/25 - Chris Cross
			
			AND LEFT(t.TransactionReportPeriodDate,4) >= @CurrentYear-1
			AND (t.TransactionAmount <> 0 OR t.TransactionActiveARAmount <> 0) --AND t.TransactionAmount <> 0 -> Modifying this to fix AR Calc 5/22/2026 
			--AND t.TransactionBillingProviderID = '1~13953'
			--AND (t.TransactionModifier1 IS NULL or t.TransactionModifier1 <> 'TC')
			--AND t.TransactionAccountID = '1~25691320'
			and (@Practice = '0' OR pt.PracticeSourceID = @Practice)
			--AND LEFT(t.TransactionReportingPeriodID, 4)
			--and d.DepartmentName like '%Diesselhorst%'
		GROUP BY
			t.TransactionReportPeriodDate
			,vi.VisitType
			,vi.VisitSubtype
			,t.TransactionARCategory
			,CASE
				WHEN t.TransactionDepartmentID IN ('1~10','1~25') THEN 'PI'
				WHEN t.TransactionBillingProviderID in ('1~18524','5~P1008411') THEN 'PI' --5.8.26 Mapped all Kevin Chessmore (EKK) activity to PI
				when t.TransactionDepartmentID = '5~42501006002' THEN 'SCS Choctaw' --Checks if Choctaw department for Shadid
				when t.TransactionDepartmentID = '5~42501006001' THEN 'SCS Edmond' --Checks if Choctaw department for Shadid
				WHEN (v.VisitLocationID = '1~135' OR t.TransactionDepartmentID = '5~42501041001') AND pt.PracticeID = '0~TDT' THEN 'Hinton' -- checks for location and provider for Thomason
				WHEN (v.VisitLocationID = '1~223' OR t.TransactionDepartmentID = '5~42501043001') AND pt.PracticeID = '0~TDT' THEN 'Binger'
				WHEN (v.VisitLocationID = '1~230' OR t.TransactionDepartmentID = '5~42501042001') AND pt.PracticeID = '0~TDT' THEN 'Hydro'
				WHEN v.VisitLocationID = '1~95' AND pt.PracticeID = '0~TDT' THEN 'Hinton'			
			END
			,pt.PracticeID
			,t.TransactionBillingProviderID
		--,p.ProviderID

	/*Add in Zero Values as placeholder*/
		UNION ALL

		select
			@CurrentYear as FiscalYear
			,@CurrentPeriod as FiscalPeriod
			,FORMAT(DATEFROMPARTS(@CurrentYear,@CurrentPeriod,1),'MMM-yy') AS FiscalYearPeriod 
			,bbg.ReportSection
			,bbg.ReportGroupLevel1
			,bbg.ReportGroupLevel2 as ReportGroupLevel2
			,bbg.ReportGroupLevel3 as ReportGroupLevel3
			,NULL as ReportGroupLevel4
			,p.PracticeID
			,pp.ProviderID
			,0 as FiscalPeriodValue
			,GETDATE()
		from dim.vPractices p
			left join map.vPracticeProviders pp ON pp.PracticeID = p.PracticeID
			cross join (SELECT bb.ReportSection, bb.ReportGroupLevel1, max(ReportGroupLevel2) as ReportGroupLevel2, max(ReportGroupLevel3) as ReportGroupLevel3
						FROM rpt.BlueBooks bb
						WHERE bb.ReportSection in ('Adjustments') and bb.ReportGroupLevel1 is not null
						GROUP BY bb.ReportSection, bb.ReportGroupLevel1) bbg
		where p.PracticeIsActive = 1
		) sub

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
		,sub.ReportingProviderID
GO
