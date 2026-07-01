CREATE PROCEDURE [rpt].[spSelectTPGGLAccounts] 

	--@CurrentYear int 
	--,@CurrentPeriod int 
	--,@Practice varchar(10)
	
as

SET NOCOUNT ON

DECLARE @Practice varchar(10) = 'NRW'
DECLARE @CurrentYear int = 2024
DECLARE @CurrentPeriod int = 8
--DECLARE @EndDate date = DATEFROMPARTS(@CurrentYear,@CurrentPeriod,1)
--DECLARE @StartingDate date = DATEFROMPARTS(@CurrentYear-1,@CurrentPeriod,1)
--DECLARE @12MonthStartDate date = DATEADD(MONTH,-12,@EndDate)
--DECLARE @6MonthStartDate date = DATEADD(MONTH,-6,@EndDate)


SELECT
--sub.FiscalYear
--,sub.FiscalPeriod
--FORMAT(DATEFROMPARTS(sub.FiscalYear,sub.FiscalPeriod,1),'MMM-yy') as FiscalYearPeriod
CONCAT(glcy.GLPeriod,' - ',glcy.GLYear) as FiscalYearPeriod
,CASE WHEN left(a.GLAccountNumber,1) = 4 THEN 'Revenue'
	  WHEN left(a.GLAccountNumber,1) = 5 THEN 'Expenses'
	  WHEN left(a.GLAccountNumber,1) = 2 THEN 'Liability'
	  WHEN left(a.GLAccountNumber,1) = 3 THEN 'Equity'
	END as GLAccountReportSection
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
,prv.ProviderID as ReportingProviderID
,CONCAT(prv.ProviderLastName,', ',prv.ProviderFirstName,' ', prv.ProviderMiddleInitial) as ReportingProvider
--,prv.ProviderFullName as ReportingProvider
--,CASE WHEN prv2.ProviderLastName IS NOT NULL THEN CONCAT(prv2.ProviderLastName,', ',prv2.ProviderFirstName,' ', prv2.ProviderMiddleInitial)
--		  ELSE CONCAT(prv.ProviderLastName,', ',prv.ProviderFirstName,' ', prv.ProviderMiddleInitial) END as ReportingProvider
,a.GLAccountCategory
,a.GLAccountIsActive
,a.GLAccountReportType
,CASE WHEN a.GLAccountType = 'Trainers' THEN 'Trainer Expense' ELSE a.GLAccountReportGroupLevel1 END as GLAccountReportGroupLevel1
,CASE WHEN a.GLAccountType = 'Trainers' THEN 'Trainer Expense' ELSE a.GLAccountReportGroupLevel2 END as GLAccountReportGroupLevel2
,sub2.FiscalPeriodNetChange AS FiscalPeriodBeginningBalance -- added sub2 to be sum up to but not including current period
,sub.FiscalPeriodDebits 
,sub.FiscalPeriodCredits
,CASE WHEN a.GLAccountBalanceType = 'Credit' THEN sub.FiscalPeriodNetChange * -1 Else sub.FiscalPeriodNetChange END as FiscalPeriodNetChange
,(sub2.FiscalPeriodNetChange + sub.FiscalPeriodNetChange) AS FiscalPeriodEndingBalance -- added sub2 change to sub change
,glcy.GLAccountDescriptionID AS AcctDescSegment
,glcy.GLAccountTypeID AS AcctTypeSegment
,glcy.GLAccountLocationID AS AccountLocationSegment
,glcy.GLAccountProviderID AS AccountPhysicianSegment
,glcy.GLAccountProviderID AS AccountProviderSegment
,glcy.GLAccountDescription AS AcctDescription
,glcy.GLAccountType AS AcctType
,glcy.GLAccountLocation AS AcctLocation
,glcy.GLAccountPractice AS AcctPhysician
,glcy.GLAccountProvider AS AcctOtherProvider
,glcy.GLAccountReportingProvider AS ReportingProvider
--,CASE WHEN sub.FiscalYear = @CurrentYear AND sub.FiscalPeriod = @CurrentPeriod THEN 'Y' ELSE 'N' END as IsMTD
--,CASE WHEN sub.FiscalYear = @CurrentYear THEN 'Y' ELSE 'N' END as IsYTD
--,CASE WHEN sub.FiscalYear = @CurrentYear - 1 AND sub.FiscalPeriod <= @CurrentPeriod THEN 'Y' ELSE 'N' END as IsPYTD
--,CASE WHEN DATEFROMPARTS(sub.FiscalYear, sub.FiscalPeriod,1) between @6MonthStartDate AND DATEADD(DAY,-1,@EndDate) THEN 'Y' ELSE 'N' END as IsTrailing6Months
--,CASE WHEN DATEFROMPARTS(sub.FiscalYear, sub.FiscalPeriod,1) between @12MonthStartDate AND DATEADD(DAY,-1,@EndDate) THEN 'Y' ELSE 'N' END as IsTrailing12Months
--,CASE WHEN DATEFROMPARTS(sub.FiscalYear, sub.FiscalPeriod,1) between @12MonthStartDate AND @EndDate THEN 'Y' ELSE 'N' END as IsTrailing13Months


FROM 
(
	select 
		g.YEAR1 as FiscalYear
		, g.PERIODID as FiscalPeriod  --@Period as Period
		, g.ACTINDX as GLAccountSourceID
		, sum(g.DEBITAMT) as FiscalPeriodDebits
		, sum(g.CRDTAMNT) as FiscalPeriodCredits
		, convert(decimal(18,2),sum(g.DEBITAMT-g.CRDTAMNT)) as FiscalPeriodNetChange
		
	from CORVMAP22.TPG.dbo.GL11110 g  --GL
		left join CORVMAP22.TPG.dbo.GL40200 s4 ON s4.SGMNTID = g.ACTNUMBR_4 AND s4.SGMTNUMB = 4
	where g.ACCTTYPE = 1
	   and g.YEAR1 = @CurrentYear --(select min(YEAR1) from GL11110)
	   and g.PERIODID <= @CurrentPeriod
	   --and g.PSTNGTYP = 1 /* 1 - Profit and Loss, 0 - Balance Sheet */ 
	   and (@Practice = '0' /*0 - All*/ OR s4.DSCRIPTN = @Practice)
	group by 
		g.YEAR1
		, g.PERIODID
		, g.ACTINDX

UNION ALL

	select 
		g.YEAR1 as FiscalYear
		, g.PERIODID as FiscalPeriod  --@Period as Period
		, g.ACTINDX as GLAccountSourceID
		, sum(g.DEBITAMT) as FiscalPeriodDebits
		, sum(g.CRDTAMNT) as FiscalPeriodCredits
		, convert(decimal(18,2),sum(g.DEBITAMT-g.CRDTAMNT)) as FiscalPeriodNetChange
	from CORVMAP22.TPG.dbo.GL11111 g  --GL
		left join CORVMAP22.TPG.dbo.GL40200 s4 ON s4.SGMNTID = g.ACTNUMBR_4 AND s4.SGMTNUMB = 4
	where g.ACCTTYPE = 1
	   and g.YEAR1 = @CurrentYear - 1
	   --and g.PERIODID >= @CurrentPeriod
	   --and g.PSTNGTYP = 1 /* 1 - Profit and Loss, 0 - Balance Sheet */ 
	   and (@Practice = '0' /*0 - All*/ OR s4.DSCRIPTN = @Practice)
	group by 
		g.YEAR1
		, g.PERIODID
		, g.ACTINDX

) sub  
	inner join stg.vGLAccounts a ON a.GLAccountSourceID = sub.GLAccountSourceID 
								--AND (@Practice = '0' /*0 - All*/ OR a.GLAccountPractice = @Practice)
	left join dim.vPractices p ON p.PracticeSourceID = a.GLAccountPractice
	left join dim.vProviders prv ON prv.ProviderDataSourceID = 10 AND prv.ProviderSourceID = a.GLAccountReportingProvider
		--left join map.ProviderLinking pl on prv.ProviderID = pl.ChildProviderID
		--left join dim.vProviders prv2 on pl.ParentProviderID = prv2.ProviderID

	left join (
	select 
		g.YEAR1 as FiscalYear
		--, g.PERIODID as FiscalPeriod  --@Period as Period
		, g.ACTINDX as GLAccountSourceID
		, convert(decimal(18,2),sum(g.DEBITAMT-g.CRDTAMNT)) as FiscalPeriodNetChange
		
	from CORVMAP22.TPG.dbo.GL11110 g  --GL
		left join CORVMAP22.TPG.dbo.GL40200 s4 ON s4.SGMNTID = g.ACTNUMBR_4 AND s4.SGMTNUMB = 4
	where g.ACCTTYPE = 1
	   and g.YEAR1 = @CurrentYear --(select min(YEAR1) from GL11110)
	   --and g.YEAR1 = 2024
	   and g.PERIODID < @CurrentPeriod
	   --and g.PSTNGTYP = 1 /* 1 - Profit and Loss, 0 - Balance Sheet */ 
	   and (@Practice = '0' /*0 - All*/ OR s4.DSCRIPTN = @Practice)
	   --and s4.DSCRIPTN = 'BJB'
	group by 
		g.YEAR1
		, g.ACTINDX
		--, g.PERIODID
		

--UNION ALL

--	select 
--		g.YEAR1 as FiscalYear
--		, g.ACTINDX as GLAccountSourceID
--		, convert(decimal(18,2),sum(g.DEBITAMT-g.CRDTAMNT)) as FiscalPeriodNetChange
--	from CORVMAP22.TPG.dbo.GL11111 g  --GL
--		left join CORVMAP22.TPG.dbo.GL40200 s4 ON s4.SGMNTID = g.ACTNUMBR_4 AND s4.SGMTNUMB = 4
--	where g.ACCTTYPE = 1
--	   --and g.YEAR1 = @CurrentYear - 1
--	   and g.YEAR1 = 2023
--	   --and g.PERIODID >= @CurrentPeriod
--	   --and g.PSTNGTYP = 1 /* 1 - Profit and Loss, 0 - Balance Sheet */ 
--	   --and (@Practice = '0' /*0 - All*/ OR s4.DSCRIPTN = @Practice)
--	   and s4.DSCRIPTN = 'BJB'
--	group by 
--		g.YEAR1
--		--, g.PERIODID
--		, g.ACTINDX

) sub2 ON sub2.GLAccountSourceID = sub.GLAccountSourceID 

left join HPIDW.rpt.vGLTransactionsCurrentYear glcy ON CAST(glcy.GLAccountNumber as varchar) = CAST(a.GLAccountNumber as varchar)
where 1=1
	


	--select * from dim.vPractices p where p.PracticeIsActive = 1

	--select * from HPIDW.rpt.vGLTransactionsCurrentYear where glaccountnumber = '5200-01-08-054-000'                                                                                                             '
GO
