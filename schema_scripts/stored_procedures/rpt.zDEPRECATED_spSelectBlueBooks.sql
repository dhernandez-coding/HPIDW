CREATE PROCEDURE [rpt].[spSelectBlueBooks]

	@CurrentYear int 
	,@CurrentPeriod int 
	,@Practice varchar(10)
	
as

SET NOCOUNT ON

--DECLARE @Practice varchar(10) = 'PBJ' /*0 - All*/  --'DRW'
--DECLARE @AsOfDate date = '8/31/2023' --DATEADD(DAY,-1,DATEFROMPARTS(YEAR(GETDATE()),MONTH(GETDATE()),1))  
--DECLARE @CurrentYear int = YEAR(@AsOfDate) --2023
--DECLARE @CurrentPeriod int = MONTH(@AsOfDate)
DECLARE @EndDate date = DATEFROMPARTS(@CurrentYear,@CurrentPeriod,1)
DECLARE @StartDate date = DATEFROMPARTS(@CurrentYear-1,1,1)
DECLARE @12MonthStartDate date = DATEADD(MONTH,-12,@EndDate)
DECLARE @6MonthStartDate date = DATEADD(MONTH,-6,@EndDate)


SELECT [FiscalYear]
      ,[FiscalPeriod]
      ,[FiscalYearPeriod]
      ,[ReportSection]
		,CASE WHEN ReportSection in ('Revenue','Expenses') THEN CONVERT(varchar,LEFT(ReportGroupLevel1,2)) ELSE CONVERT(varchar,ReportGroupLevel1) END as ReportGroupLevel1Sort 
		,CASE WHEN ReportSection in ('Revenue','Expenses') THEN RIGHT(ReportGroupLevel1,(LEN(ReportGroupLevel1) - 3)) ELSE ReportGroupLevel1 END as ReportGroupLevel1
		,CASE WHEN ReportSection in ('Revenue','Expenses') THEN CONVERT(varchar,LEFT(ReportGroupLevel2,2)) ELSE CONVERT(varchar,ReportGroupLevel2) END as ReportGroupLevel2Sort
		,CASE WHEN ReportSection in ('Revenue','Expenses') THEN RIGHT(ReportGroupLevel2,(LEN(ReportGroupLevel2) - 3)) ELSE ReportGroupLevel2 END as ReportGroupLevel2
	  ,bb.[PracticeID]
	  ,p.PracticeName
      ,[ReportingProviderID]
	  ,prv.ProviderFullName as ReportingProvider
	  ,pp.PracticeProviderIsPrimary as ReportingProviderIsPrimary
	  ,pp.PracticeProviderFTE as ReportingProviderFTE
	  ,pp.PracticeProviderAllocationPercent as ReportingProviderAllocationPercent
      ,[FiscalPeriodValue]
	  ,CASE WHEN bb.ReportSection in ('Expenses') THEN -bb.FiscalPeriodValue ELSE bb.FiscalPeriodValue END as FiscalPeriodValueNet
	  ,CASE WHEN bb.FiscalYear = @CurrentYear THEN 'Y' ELSE 'N' END as IsYTD
	  ,CASE WHEN bb.FiscalYear = @CurrentYear - 1 AND bb.FiscalPeriod <= @CurrentPeriod THEN 'Y' ELSE 'N' END as IsPYTD
	  ,CASE WHEN DATEFROMPARTS(bb.FiscalYear, bb.FiscalPeriod,1) between @6MonthStartDate AND DATEADD(DAY,-1,@EndDate) THEN 'Y' ELSE 'N' END as IsTrailing6Months
	  ,CASE WHEN DATEFROMPARTS(bb.FiscalYear, bb.FiscalPeriod,1) between @12MonthStartDate AND DATEADD(DAY,-1,@EndDate) THEN 'Y' ELSE 'N' END as IsTrailing12Months
	  ,CASE WHEN DATEFROMPARTS(bb.FiscalYear, bb.FiscalPeriod,1) between @12MonthStartDate AND @EndDate THEN 'Y' ELSE 'N' END as IsTrailing13Months
	  ,CASE WHEN DATEFROMPARTS(bb.FiscalYear, bb.FiscalPeriod,1) between DATEADD(MONTH,-12,@EndDate) and DATEADD(DAY,-1,DATEADD(MONTH,-11,@EndDate)) THEN 'Y' ELSE 'N' END as IsMonthLag12
	  ,CASE WHEN DATEFROMPARTS(bb.FiscalYear, bb.FiscalPeriod,1) between DATEADD(MONTH,-11,@EndDate) and DATEADD(DAY,-1,DATEADD(MONTH,-10,@EndDate)) THEN 'Y' ELSE 'N' END as IsMonthLag11
	  ,CASE WHEN DATEFROMPARTS(bb.FiscalYear, bb.FiscalPeriod,1) between DATEADD(MONTH,-10,@EndDate) and DATEADD(DAY,-1,DATEADD(MONTH,-9,@EndDate)) THEN 'Y' ELSE 'N' END as IsMonthLag10
	  ,CASE WHEN DATEFROMPARTS(bb.FiscalYear, bb.FiscalPeriod,1) between DATEADD(MONTH,-9,@EndDate) and DATEADD(DAY,-1,DATEADD(MONTH,-8,@EndDate)) THEN 'Y' ELSE 'N' END as IsMonthLag9
	  ,CASE WHEN DATEFROMPARTS(bb.FiscalYear, bb.FiscalPeriod,1) between DATEADD(MONTH,-8,@EndDate) and DATEADD(DAY,-1,DATEADD(MONTH,-7,@EndDate)) THEN 'Y' ELSE 'N' END as IsMonthLag8
	  ,CASE WHEN DATEFROMPARTS(bb.FiscalYear, bb.FiscalPeriod,1) between DATEADD(MONTH,-7,@EndDate) and DATEADD(DAY,-1,DATEADD(MONTH,-6,@EndDate)) THEN 'Y' ELSE 'N' END as IsMonthLag7
	  ,CASE WHEN DATEFROMPARTS(bb.FiscalYear, bb.FiscalPeriod,1) between DATEADD(MONTH,-6,@EndDate) and DATEADD(DAY,-1,DATEADD(MONTH,-5,@EndDate)) THEN 'Y' ELSE 'N' END as IsMonthLag6
	  ,CASE WHEN DATEFROMPARTS(bb.FiscalYear, bb.FiscalPeriod,1) between DATEADD(MONTH,-5,@EndDate) and DATEADD(DAY,-1,DATEADD(MONTH,-4,@EndDate)) THEN 'Y' ELSE 'N' END as IsMonthLag5
	  ,CASE WHEN DATEFROMPARTS(bb.FiscalYear, bb.FiscalPeriod,1) between DATEADD(MONTH,-4,@EndDate) and DATEADD(DAY,-1,DATEADD(MONTH,-3,@EndDate)) THEN 'Y' ELSE 'N' END as IsMonthLag4
	  ,CASE WHEN DATEFROMPARTS(bb.FiscalYear, bb.FiscalPeriod,1) between DATEADD(MONTH,-3,@EndDate) and DATEADD(DAY,-1,DATEADD(MONTH,-2,@EndDate)) THEN 'Y' ELSE 'N' END as IsMonthLag3
	  ,CASE WHEN DATEFROMPARTS(bb.FiscalYear, bb.FiscalPeriod,1) between DATEADD(MONTH,-2,@EndDate) and DATEADD(DAY,-1,DATEADD(MONTH,-1,@EndDate)) THEN 'Y' ELSE 'N' END as IsMonthLag2
	  ,CASE WHEN DATEFROMPARTS(bb.FiscalYear, bb.FiscalPeriod,1) between DATEADD(MONTH,-1,@EndDate) and DATEADD(DAY,-1,DATEADD(MONTH,-0,@EndDate)) THEN 'Y' ELSE 'N' END as IsMonthLag1
	  ,CASE WHEN bb.FiscalYear = @CurrentYear AND bb.FiscalPeriod = @CurrentPeriod THEN 'Y' ELSE 'N' END as IsMTD
      ,[UpdatedDatetime]
  FROM (
	   SELECT
			[FiscalYear]
			,[FiscalPeriod]
			,[FiscalYearPeriod]
			,[ReportSection]
			,[ReportGroupLevel1]
			,[ReportGroupLevel2]
			,[PracticeID]
			,[ReportingProviderID]
			,[FiscalPeriodValue]
			,[UpdatedDatetime]
		FROM [HPIDW].[rpt].[BlueBooks] b
		WHERE 1=1 
			AND DATEFROMPARTS(b.FiscalYear, b.FiscalPeriod,1) between @StartDate and @EndDate

		UNION ALL

		SELECT
			b.[FiscalYear]
			,b.[FiscalPeriod]
			,[FiscalYearPeriod]
			,'Payments Per Visit Per Practice' as [ReportSection]
			,b.[ReportGroupLevel1]
			,NULL as [ReportGroupLevel2]
			,b.[PracticeID]
			,NULL AS [ReportingProviderID]
			,CASE WHEN ISNULL(SUM(CASE WHEN b.ReportSection = 'Visits' THEN b.FiscalPeriodValue ELSE 0 END),0) = 0 THEN 0 ELSE 
				SUM(CASE WHEN b.ReportSection = 'Payments' THEN b.FiscalPeriodValue ELSE 0 END)
				/ SUM(CASE WHEN b.ReportSection = 'Visits' THEN b.FiscalPeriodValue ELSE 0 END) END AS [FiscalPeriodValue]
			,MAX([UpdatedDatetime]) AS UpdatedDatetime
		FROM [HPIDW].[rpt].[BlueBooks] b
		WHERE 1=1 
			AND DATEFROMPARTS(b.FiscalYear, b.FiscalPeriod,1) between @StartDate and @EndDate
			AND b.ReportSection in ('Visits','Payments')
			AND b.ReportGroupLevel1 in ('Surgical Visits','Office Visits','Hospital Visits')
		GROUP BY
			b.FiscalYear
			,b.FiscalPeriod
			,b.FiscalYearPeriod
			,b.ReportGroupLevel1
			,b.PracticeID

		UNION ALL

		SELECT
			b.[FiscalYear]
			,b.[FiscalPeriod]
			,[FiscalYearPeriod]
			,'Charges Per Visit Per Practice' as [ReportSection]
			,b.[ReportGroupLevel1]
			,NULL as [ReportGroupLevel2]
			,b.[PracticeID]
			,NULL as [ReportingProviderID]
			,CASE WHEN ISNULL(SUM(CASE WHEN b.ReportSection = 'Visits' THEN b.FiscalPeriodValue ELSE 0 END),0) = 0 THEN 0 ELSE 
				SUM(CASE WHEN b.ReportSection = 'Charges' THEN b.FiscalPeriodValue ELSE 0 END)
				/ SUM(CASE WHEN b.ReportSection = 'Visits' THEN b.FiscalPeriodValue ELSE 0 END) END AS [FiscalPeriodValue]
			,MAX([UpdatedDatetime]) AS UpdatedDatetime
		FROM [HPIDW].[rpt].[BlueBooks] b
		WHERE 1=1 
			AND DATEFROMPARTS(b.FiscalYear, b.FiscalPeriod,1) between @StartDate and @EndDate
			AND b.ReportSection in ('Visits','Charges')
			AND b.ReportGroupLevel1 in ('Surgical Visits','Office Visits','Hospital Visits')
		GROUP BY
			b.FiscalYear
			,b.FiscalPeriod
			,b.FiscalYearPeriod
			,b.ReportGroupLevel1
			,b.PracticeID

		UNION ALL

		SELECT
			b.[FiscalYear]
			,b.[FiscalPeriod]
			,[FiscalYearPeriod]
			,'Payments Per Visit Per Provider' as [ReportSection]
			,b.[ReportGroupLevel1]
			,NULL as [ReportGroupLevel2]
			,b.[PracticeID]
			,b.[ReportingProviderID]
			,CASE WHEN ISNULL(SUM(CASE WHEN b.ReportSection = 'Visits' THEN b.FiscalPeriodValue ELSE 0 END),0) = 0 THEN 0 ELSE 
				SUM(CASE WHEN b.ReportSection = 'Payments' THEN b.FiscalPeriodValue ELSE 0 END)
				/ SUM(CASE WHEN b.ReportSection = 'Visits' THEN b.FiscalPeriodValue ELSE 0 END) END AS [FiscalPeriodValue]
			,MAX([UpdatedDatetime]) AS UpdatedDatetime
		FROM [HPIDW].[rpt].[BlueBooks] b
		WHERE 1=1 
			AND DATEFROMPARTS(b.FiscalYear, b.FiscalPeriod,1) between @StartDate and @EndDate
			AND b.ReportSection in ('Visits','Payments')
			AND b.ReportGroupLevel1 in ('Surgical Visits','Office Visits','Hospital Visits')
		GROUP BY
			b.FiscalYear
			,b.FiscalPeriod
			,b.FiscalYearPeriod
			,b.ReportGroupLevel1
			,b.PracticeID
			,b.ReportingProviderID

		UNION ALL

		SELECT
			b.[FiscalYear]
			,b.[FiscalPeriod]
			,[FiscalYearPeriod]
			,'Charges Per Visit Per Provider' as [ReportSection]
			,b.[ReportGroupLevel1]
			,NULL as [ReportGroupLevel2]
			,b.[PracticeID]
			,b.[ReportingProviderID]
			,CASE WHEN ISNULL(SUM(CASE WHEN b.ReportSection = 'Visits' THEN b.FiscalPeriodValue ELSE 0 END),0) = 0 THEN 0 ELSE 
				SUM(CASE WHEN b.ReportSection = 'Charges' THEN b.FiscalPeriodValue ELSE 0 END)
				/ SUM(CASE WHEN b.ReportSection = 'Visits' THEN b.FiscalPeriodValue ELSE 0 END) END AS [FiscalPeriodValue]
			,MAX([UpdatedDatetime]) AS UpdatedDatetime
		FROM [HPIDW].[rpt].[BlueBooks] b
		WHERE 1=1 
			AND DATEFROMPARTS(b.FiscalYear, b.FiscalPeriod,1) between @StartDate and @EndDate
			AND b.ReportSection in ('Visits','Charges')
			AND b.ReportGroupLevel1 in ('Surgical Visits','Office Visits','Hospital Visits')
		GROUP BY
			b.FiscalYear
			,b.FiscalPeriod
			,b.FiscalYearPeriod
			,b.ReportGroupLevel1
			,b.PracticeID
			,b.ReportingProviderID
  ) bb
	left join dim.Practices p ON p.PracticeID = bb.PracticeID
	left join dim.vProviders prv ON prv.ProviderID = bb.ReportingProviderID 
	left join map.PracticeProviders pp ON pp.PracticeID = bb.PracticeID AND pp.ProviderID = bb.ReportingProviderID
  WHERE 1=1
	AND DATEFROMPARTS(bb.FiscalYear, bb.FiscalPeriod,1) between @StartDate and @EndDate
	AND (@Practice = '0' OR p.PracticeSourceID = @Practice)
GO
