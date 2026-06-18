CREATE PROCEDURE [rpt].[spLoadBlueBookRevenueExpenses] as 

	--@CurrentYear int 
	--,@CurrentPeriod int 
	--,@Practice varchar(10)
	
/*
Change Control:
	1. 4/30/25 - Chris Cross - Added "WHEN a.GLAccountLocationID = 34 AND a.PracticeID = '0~SCS' THEN 'Choctaw' --Checks if Choctaw location for Shadid" for ReportGroupLevel4
	2. 5/8/25 - Chris Cross - Added "WHEN a.GLAccountLocationID = 23 AND a.PracticeID = '0~SCS' THEN 'Shadid Edmond' --Checks if Edmond location for Shadid for ReportGroupLevel4
	3. 5/12/25 - Chris Cross - Updated join logic for #TEMP_ProviderAllocations to account for NULLS properly --> AND ISNULL(pp.PracticeProviderLocation,'0') = ISNULL(sub.PracticeProviderLocation,'0')
*/

SET NOCOUNT Off

DECLARE @Practice varchar(10) = '0' /*0 - All*/  --'DRW'
DECLARE @AsOfDate date = DATEADD(DAY,-1,DATEFROMPARTS(YEAR(GETDATE()),MONTH(GETDATE()),1))  
DECLARE @CurrentYear int = YEAR(@AsOfDate) --2023
DECLARE @CurrentPeriod int = MONTH(@AsOfDate)
DECLARE @EndDate date = DATEFROMPARTS(@CurrentYear,@CurrentPeriod,1)
DECLARE @StartDate date = DATEFROMPARTS(@CurrentYear-2,1,1)
DECLARE @12MonthStartDate date = DATEADD(MONTH,-12,@EndDate)
DECLARE @6MonthStartDate date = DATEADD(MONTH,-6,@EndDate)

/*Creates Allocation table for allocated expense accounts.  This table is needed due to the changes in overall allocation percents as mid-levels are added or removed over time*/
	Print 'Dropping #TEMP_ProviderAllocations'
	DROP TABLE IF EXISTS #TEMP_ProviderAllocations

	Print 'Inserting Into #TEMP_ProviderAllocations'
	SELECT
		sub.*
		,pp.ProviderID
		,pp.PracticeProviderEffectiveDate
		,pp.PracticeProviderEndDate
		,pp.PracticeProviderAllocationPercent
		,CASE WHEN sub.AllocationPercentTotal = 1.0 THEN pp.PracticeProviderAllocationPercent 
			  ELSE 1.0 / sub.ProviderCount END as PracticeProviderAllocationCalculated
	INTO #TEMP_ProviderAllocations
	FROM (
		select
			d.Date
			,pp1.PracticeID
			,pp1.PracticeProviderLocation
			,count(pp1.ProviderID) as ProviderCount
			,sum(pp1.PracticeProviderAllocationPercent) as AllocationPercentTotal
		from dim.Dates d 
			left join map.PracticeProviders pp1 ON pp1.PracticeProviderEffectiveDate <= d.Date
												  AND pp1.PracticeProviderEndDate >= d.Date
												  AND ISNULL(pp1.PracticeProviderAllocationPercent,0) > 0
		where 1=1
			and d.Date = d.FirstDayOfMonth
			and d.Date >= '1/1/2021' and d.Date <= GETDATE()
			--and pp1.PracticeID = '0~RSG'
		group by 
			d.Date
			,pp1.PracticeID
			,pp1.PracticeProviderLocation
		) sub
		LEFT JOIN map.PracticeProviders pp ON pp.PracticeID = sub.PracticeID
											  --AND (pp.PracticeProviderLocation is null OR pp.PracticeProviderLocation = sub.PracticeProviderLocation)
											  AND ISNULL(pp.PracticeProviderLocation,'0') = ISNULL(sub.PracticeProviderLocation,'0')
											  AND pp.PracticeProviderEffectiveDate <= sub.Date
											  AND pp.PracticeProviderEndDate >= sub.Date
											  AND ISNULL(pp.PracticeProviderAllocationPercent,0) > 0
	
/*DELETE AND RELOAD*/
Print 'Deleting last 2 years + YTD...'
DELETE FROM rpt.BlueBooks WHERE ReportSection in ('Revenue','Expenses') and FiscalYear >= @CurrentYear-2

Print 'Inserting new records...'
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
	sub2.FiscalYear 
	,sub2.FiscalPeriod 
	,sub2.FiscalYearPeriod 
	,sub2.ReportSection
	,sub2.ReportGroupLevel1
	,sub2.ReportGroupLevel2 
	,sub2.ReportGroupLevel3
	,sub2.ReportGroupLevel4
	,sub2.PracticeID 
	,sub2.ReportingProviderID 
	,SUM(sub2.FiscalPeriodValue) as FiscalPeriodValue
	,GETDATE() AS UpdatedDatetime 
FROM (
	/*Revenue and Expense data from Great Plains*/
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
	,SUM(sub.FiscalPeriodNetChange) as FiscalPeriodValue
	,GETDATE() AS UpdatedDatetime 
	FROM (
		SELECT
		sub.FiscalYear
		,sub.FiscalPeriod
		,FORMAT(DATEFROMPARTS(sub.FiscalYear,sub.FiscalPeriod,1),'MMM-yy') as FiscalYearPeriod
		,a.GLAccountNumber
		,a.GLAccountName
		,a.GLAccountDescriptionID
		,a.GLAccountTypeID
		,a.GLAccountLocationID
		,a.GLAccountPracticeID
		,a.GLAccountProviderID
		,a.GLAccountDescription
		,a.GLAccountType
		,a.GLAccountLocation
		,a.GLAccountPractice
		,a.GLAccountProvider
		,p.PracticeID as PracticeID
		,p.PracticeName as PracticeName

		,COALESCE(pp.ProviderID, prv.ProviderID) as ReportingProviderID
	
		,CONCAT(prv.ProviderLastName,', ',prv.ProviderFirstName,' ', prv.ProviderMiddleInitial) as ReportingProvider
		--,prv.ProviderFullName as ReportingProvider
		--,CASE WHEN prv2.ProviderLastName IS NOT NULL THEN CONCAT(prv2.ProviderLastName,', ',prv2.ProviderFirstName,' ', prv2.ProviderMiddleInitial)
		--		  ELSE CONCAT(prv.ProviderLastName,', ',prv.ProviderFirstName,' ', prv.ProviderMiddleInitial) END as ReportingProvider
		,a.GLAccountCategory
		,a.GLAccountIsActive
		,a.GLAccountReportType
		,CASE WHEN left(a.GLAccountNumber,1) = 4 THEN 'Revenue'
			  WHEN left(a.GLAccountNumber,1) = 5 THEN 'Expenses'
			END as ReportSection
		,CASE WHEN a.GLAccountType = 'Trainers' THEN '01_Labor Expense' ELSE a.GLAccountReportGroupLevel1 END as ReportGroupLevel1
		,CASE WHEN a.GLAccountType = 'Trainers' THEN '01_Payroll' ELSE a.GLAccountReportGroupLevel2 END as ReportGroupLevel2  -- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
		,CASE WHEN a.GLAccountType = 'Trainers' THEN '01_Labor Expense' ELSE a.GLAccountReportGroupLevel3 END as ReportGroupLevel3
		,CASE
			WHEN a.GLAccountType = 'PI' THEN 'PI'  -- Checks if Personal Injury account for Kim
			WHEN a.GLAccountProviderID = '064' AND a.PracticeID = '0~EKK' THEN 'PI' --Added 5.8.2026 to categorize all Kevin Chessmore at EKK as PI
			WHEN a.GLAccountLocationID = 34 AND a.PracticeID = '0~SCS' THEN 'SCS Choctaw' --Checks if Choctaw location for Shadid
			WHEN a.GLAccountLocationID = 23 AND a.PracticeID = '0~SCS' THEN 'SCS Edmond' --Checks if Edmond location for Shadid
			WHEN a.GLAccountLocationID = 22 AND a.PracticeID = '0~TDT' THEN 'Hinton'-- checks for location and provider for Thomason
			WHEN a.GLAccountLocationID = 30 AND a.PracticeID = '0~TDT' THEN 'Binger'
			WHEN a.GLAccountLocationID = 31 AND a.PracticeID = '0~TDT' THEN 'Hydro'
		END as ReportGroupLevel4
		,NULL AS FiscalPeriodBeginningBalance
		,sub.FiscalPeriodDebits 
		,sub.FiscalPeriodCredits
	
		,CASE WHEN a.GLAccountBalanceType = 'Credit' THEN (ISNULL(pp.PracticeProviderAllocationCalculated,1) * sub.FiscalPeriodNetChange) * -1 
			Else ISNULL(pp.PracticeProviderAllocationCalculated,1) * sub.FiscalPeriodNetChange 
			END as FiscalPeriodNetChange
	
		,NULL AS FiscalPeriodEndingBalance
		,CASE WHEN sub.FiscalYear = @CurrentYear AND sub.FiscalPeriod = @CurrentPeriod THEN 'Y' ELSE 'N' END as IsMTD
		,CASE WHEN sub.FiscalYear = @CurrentYear THEN 'Y' ELSE 'N' END as IsYTD
		,CASE WHEN sub.FiscalYear = @CurrentYear - 1 AND sub.FiscalPeriod <= @CurrentPeriod THEN 'Y' ELSE 'N' END as IsPYTD
		,CASE WHEN DATEFROMPARTS(sub.FiscalYear, sub.FiscalPeriod,1) between @6MonthStartDate AND DATEADD(DAY,-1,@EndDate) THEN 'Y' ELSE 'N' END as IsTrailing6Months
		,CASE WHEN DATEFROMPARTS(sub.FiscalYear, sub.FiscalPeriod,1) between @12MonthStartDate AND DATEADD(DAY,-1,@EndDate) THEN 'Y' ELSE 'N' END as IsTrailing12Months
		,CASE WHEN DATEFROMPARTS(sub.FiscalYear, sub.FiscalPeriod,1) between @12MonthStartDate AND @EndDate THEN 'Y' ELSE 'N' END as IsTrailing13Months

		FROM 
		(
			select 
				g.YEAR1 as FiscalYear
				, g.PERIODID as FiscalPeriod  --@Period as Period
				, CAST(g.ACTINDX as VARCHAR(100)) as GLAccountSourceID
				, sum(g.DEBITAMT) as FiscalPeriodDebits
				, sum(g.CRDTAMNT) as FiscalPeriodCredits
				, convert(decimal(18,2),sum(g.DEBITAMT-g.CRDTAMNT)) as FiscalPeriodNetChange
			--select distinct g.YEAR1
			from CORVMAP22.TPG.dbo.GL11110 g  --GL
				left join CORVMAP22.TPG.dbo.GL40200 s4 ON s4.SGMNTID = g.ACTNUMBR_4 AND s4.SGMTNUMB = 4
			where g.ACCTTYPE = 1
			   and (g.YEAR1 < @CurrentYear --(select min(YEAR1) from GL11110)
				   OR g.YEAR1 = @CurrentYear AND g.PERIODID <= @CurrentPeriod) /*Include all unclosed years up to current period*/
			   and g.PSTNGTYP = 1 /* 1 - Profit and Loss, 0 - Balance Sheet */ 
			   and g.ACTNUMBR_4 NOT IN ('046') /*Exclude Robert Glade activity..Robert Spender is now RSG*/
			   and (@Practice = '0' /*0 - All*/ OR s4.DSCRIPTN = @Practice)
			group by 
				g.YEAR1
				, g.PERIODID
				, g.ACTINDX

		UNION ALL

			select 
				g.YEAR1 as FiscalYear
				, g.PERIODID as FiscalPeriod  --@Period as Period
				, CAST(g.ACTINDX as VARCHAR(100)) as GLAccountSourceID
				, sum(g.DEBITAMT) as FiscalPeriodDebits
				, sum(g.CRDTAMNT) as FiscalPeriodCredits
				, convert(decimal(18,2),sum(g.DEBITAMT-g.CRDTAMNT)) as FiscalPeriodNetChange

			from CORVMAP22.TPG.dbo.GL11111 g  --GL
				left join CORVMAP22.TPG.dbo.GL40200 s4 ON s4.SGMNTID = g.ACTNUMBR_4 AND s4.SGMTNUMB = 4
			where g.ACCTTYPE = 1
			   and g.YEAR1 >= @CurrentYear - 2
			   --and g.PERIODID >= @CurrentPeriod
			   and g.PSTNGTYP = 1 /* 1 - Profit and Loss, 0 - Balance Sheet */ 
			   and g.ACTNUMBR_4 NOT IN ('046') /*Exclude Robert Glade activity..Robert Spender is now RSG*/
			   and (@Practice = '0' /*0 - All*/ OR s4.DSCRIPTN = @Practice)
			group by 
				g.YEAR1
				, g.PERIODID
				, g.ACTINDX

			UNION ALL
			-- I added this here to include THP data.
select 
	 YEAR(t.Date) as FiscalYear
	,MONTH(t.Date) as FiscalPeriod
	, CAST(a.GLAccountSourceID as varchar(255)) as GLAccountSourceID
	,sum(t.Debit) as FiscalPeriodDebits
	,sum(t.Credit) as FiscalPeriodCredits
	,SUM((ISNULL(t.Debit,0) - ISNULL(t.Credit,0))) as FiscalPeriodNetChange
from [HPIDW].[stg].[THPTransactions] t
INNER JOIN map.vTHPClass mc
	ON mc.[class] = t.[class]
	AND mc.Practice = t.Practice
LEFT JOIN  stg.vGLAccounts a on a.GLAccountName = CONCAT(t.account,'-',t.practice,'-',mc.FixedClass)
where 1=1
	-- 1. Exclude payments and rental income
	--AND t.Account NOT IN ('ACCOUNTS RECEIVABLE-TPG LAB', 'RENTAL INCOME')
	-- 2. Simplified Account Type Filter (Since AR is excluded above)
	AND (t.account_type LIKE '%Income%' OR t.account_type = 'Expense')
	AND t.account <> 'OTHER INCOME - NONTAX HTH INSUR' -- Excluding this because it was inflating other income for fy 2024
	AND a.GLAccountSourceID is not null
	AND YEAR(t.Date) >= @CurrentYear - 2 
    -- 3. Allocation filter removed completely to align expenses to the rounded targets
	
	-- 4. Exclude other entities (CVFC/THP classes) but keep Xray/Lab classes
	--AND mc.class NOT IN ('CVFC BUSINESS OFFICE', 'APCM',  'CVFC', 'THP') 
group by 
	 YEAR(t.Date)
	,MONTH(t.Date)
	,a.GLAccountSourceID

		) sub  
			inner join stg.vGLAccounts a ON a.GLAccountSourceID = sub.GLAccountSourceID 
										--AND (@Practice = '0' /*0 - All*/ OR a.GLAccountPractice = @Practice)
			left join dim.Practices p ON p.PracticeSourceID = a.GLAccountPractice
			left join dim.Providers prv ON prv.ProviderDataSourceID = 10 AND prv.ProviderSourceID = a.GLAccountReportingProvider
			left join #TEMP_ProviderAllocations pp ON pp.PracticeID = p.PracticeID
													  and a.GLAccountProviderID = '000' /*Not directly attributed to a provider*/
													  and (pp.PracticeProviderLocation is null OR pp.PracticeProviderLocation = TRIM(a.GLAccountLocation))
												      and DATEFROMPARTS(sub.FiscalYear,sub.FiscalPeriod,1) = pp.Date
													  and a.GLAccountIsAllocated = 1
												 
			/*left join map.PracticeProviders pp ON pp.PracticeID = p.PracticeID 
												  and a.GLAccountProviderID = '000' /*Not directly attributed to a provider*/
												  and (pp.PracticeProviderLocation is null OR pp.PracticeProviderLocation = a.GLAccountLocation)
												  and DATEFROMPARTS(sub.FiscalYear,sub.FiscalPeriod,1) between pp.PracticeProviderEffectiveDate AND pp.PracticeProviderEndDate
												  and ISNULL(pp.PracticeProviderAllocationPercent,0) > 0
												  and a.GLAccountIsAllocated = 1
			*/
		where 1=1
		--and a.GLAccountIsActive = 0
	) sub
	GROUP BY 
	FiscalYear 
	,FiscalPeriod 
	,FiscalYearPeriod 
	,ReportSection
	,ReportGroupLevel1
	,ReportGroupLevel2 
	,ReportGroupLevel3
	,ReportGroupLevel4
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
		,NULL as ReportGroupLevel4
		,p.PracticeID
		,pp.ProviderID
		,0 as FiscalPeriodValue
		,GETDATE()
	from dim.Practices p
		left join map.PracticeProviders pp ON pp.PracticeID = p.PracticeID
		cross join (SELECT bb.ReportSection, bb.ReportGroupLevel1, min(ReportGroupLevel2) as ReportGroupLevel2
					FROM rpt.BlueBooks bb
					WHERE ((bb.ReportSection in ('Revenue') and bb.ReportGroupLevel1 in ('05_Other Income','01_Total Professional Services'))
						OR (bb.ReportSection in ('Expenses') and bb.ReportGroupLevel2 NOT in ('01_Labor Expense')))
					GROUP BY bb.ReportSection, bb.ReportGroupLevel1) bbg  
	where p.PracticeIsActive = 1 AND p.PracticeCompany not in ('EXTERNAL','CH','UNK')
) sub2

GROUP BY
	sub2.FiscalYear 
	,sub2.FiscalPeriod 
	,sub2.FiscalYearPeriod 
	,sub2.ReportSection
	,sub2.ReportGroupLevel1
	,sub2.ReportGroupLevel2 
	,sub2.ReportGroupLevel3
	,sub2.ReportGroupLevel4
	,sub2.PracticeID 
	,sub2.ReportingProviderID 


	


	--select * from dim.Practices p where p.PracticeIsActive = 1
	--select * from map.PracticeProviders
	

	--exec rpt.spLoadBlueBookVisits
	--exec rpt.spLoadBlueBookVisitInfo
	--exec rpt.spLoadBlueBookCharges
	--exec rpt.spLoadBlueBookPayments
	--exec rpt.spLoadBlueBookChargeLag
GO
