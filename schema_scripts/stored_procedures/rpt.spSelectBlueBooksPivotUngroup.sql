CREATE PROCEDURE [rpt].[spSelectBlueBooksPivotUngroup] AS

	--	@CurrentYear int 
	--	,@CurrentPeriod int 
	--	,@Practice varchar(10)
	--	,@SpecialFilter varchar(50)
	
	
	--as

SET NOCOUNT ON

----DECLARE @AsOfDate date = '8/31/2023' --DATEADD(DAY,-1,DATEFROMPARTS(YEAR(GETDATE()),MONTH(GETDATE()),1))  
--DECLARE @CurrentYear int = 2025 --YEAR(@AsOfDate) --2023
--DECLARE @CurrentPeriod int = 1 --MONTH(@AsOfDate)
--DECLARE @Practice varchar(10) = 'bjb' /*0 - All*/  --'DRW'
--DECLARE @SpecialFilter varchar(50) = '0'
----select @Practice,@SpecialFilter	

--DECLARE @EndDate date = DATEFROMPARTS(@CurrentYear,@CurrentPeriod,1)
--DECLARE @StartDate date = DATEFROMPARTS(@CurrentYear-2,1,1)
--DECLARE @12MonthStartDate date = DATEADD(MONTH,-12,@EndDate)
--DECLARE @6MonthStartDate date = DATEADD(MONTH,-6,@EndDate)

SELECT
	
	sub.FiscalYearPeriod
	,sub.FiscalYear
	,sub.FiscalPeriod
	,sub.ReportSection
	,CASE WHEN sub.ReportSection in ('Revenue','Expenses') THEN CONVERT(varchar,LEFT(sub.ReportGroupLevel1,2)) 
		  WHEN sub.ReportSection in ('Visits') AND sub.ReportGroupLevel1 = 'Surgical Visits' THEN '1'
		  WHEN sub.ReportSection in ('Visits') AND sub.ReportGroupLevel1 = 'Office Visits' THEN '2'
		  WHEN sub.ReportSection in ('Visits') AND sub.ReportGroupLevel1 = 'Hospital Visits' THEN '3'
		  WHEN sub.ReportSection in ('Visits') AND sub.ReportGroupLevel1 = 'Other Visits' THEN '4'
		  WHEN sub.ReportSection in ('Payment Lag by Payer by Practice','Payment Lag by Payer by Provider','AR Aging') and sub.ReportGroupLevel1 = 'Medicare' THEN '1'		  
		  WHEN sub.ReportSection in ('Payment Lag by Payer by Practice','Payment Lag by Payer by Provider','AR Aging') and sub.ReportGroupLevel1 = 'Blue Cross Blue Shield' THEN '2'		  
		  WHEN sub.ReportSection in ('Payment Lag by Payer by Practice','Payment Lag by Payer by Provider','AR Aging') and sub.ReportGroupLevel1 = 'Other Commercial' THEN '3'
		  WHEN sub.ReportSection in ('Payment Lag by Payer by Practice','Payment Lag by Payer by Provider','AR Aging') and sub.ReportGroupLevel1 = 'Liability' THEN '4'
		  WHEN sub.ReportSection in ('Payment Lag by Payer by Practice','Payment Lag by Payer by Provider','AR Aging') and sub.ReportGroupLevel1 = 'Workers Comp' THEN '5'
		  WHEN sub.ReportSection in ('Payment Lag by Payer by Practice','Payment Lag by Payer by Provider','AR Aging') and sub.ReportGroupLevel1 = 'Medicaid' THEN '6'
		  WHEN sub.ReportSection in ('Payment Lag by Payer by Practice','Payment Lag by Payer by Provider','AR Aging') and sub.ReportGroupLevel1 = 'Self-Pay' THEN '7'
		  ELSE CONVERT(varchar,sub.ReportGroupLevel1) END as ReportGroupLevel1Sort 
	,CASE WHEN sub.ReportSection in ('Revenue','Expenses') THEN RIGHT(sub.ReportGroupLevel1,(LEN(sub.ReportGroupLevel1) - 3)) ELSE sub.ReportGroupLevel1 END as ReportGroupLevel1
	,CASE WHEN sub.ReportSection in ('Revenue','Expenses') THEN CONVERT(varchar,LEFT(sub.ReportGroupLevel2,2)) 
		  WHEN sub.ReportSection in ('Visits','Payments Per Visit Per Provider','Payments Per Visit Per Practice') AND sub.ReportGroupLevel2 = 'Surgical Visits' THEN '1'
		  WHEN sub.ReportSection in ('Visits','Payments Per Visit Per Provider','Payments Per Visit Per Practice') AND sub.ReportGroupLevel2 = 'Outpatient Procedures' THEN '2'
		  WHEN sub.ReportSection in ('Visits','Payments Per Visit Per Provider','Payments Per Visit Per Practice') AND sub.ReportGroupLevel2 = 'New PT Visits' THEN '3'
		  WHEN sub.ReportSection in ('Visits','Payments Per Visit Per Provider','Payments Per Visit Per Practice') AND sub.ReportGroupLevel2 = 'Established PT Visits' THEN '4'
		  WHEN sub.ReportSection in ('Visits','Payments Per Visit Per Provider','Payments Per Visit Per Practice') AND sub.ReportGroupLevel2 = 'Post Op Visits' THEN '5'
		  WHEN sub.ReportSection in ('Visits','Payments Per Visit Per Provider','Payments Per Visit Per Practice') AND sub.ReportGroupLevel2 = 'In Office Procedures' THEN '6'
		  WHEN sub.ReportSection in ('Visits','Payments Per Visit Per Provider','Payments Per Visit Per Practice') THEN '99'
		  ELSE CONVERT(varchar,sub.ReportGroupLevel2) END as ReportGroupLevel2Sort
	,CASE WHEN sub.ReportSection in ('Revenue','Expenses') THEN RIGHT(sub.ReportGroupLevel2,(LEN(sub.ReportGroupLevel2) - 3)) ELSE sub.ReportGroupLevel2 END as ReportGroupLevel2
	,CASE WHEN sub.ReportSection in ('Revenue','Expenses') THEN CONVERT(varchar,LEFT(sub.ReportGroupLevel3,2)) 
		  WHEN sub.ReportSection in ('Visits') AND sub.ReportGroupLevel3 = 'Surgical Visits' THEN '1'
		  WHEN sub.ReportSection in ('Visits') AND sub.ReportGroupLevel3 = 'Office Visits' THEN '2'
		  WHEN sub.ReportSection in ('Visits') AND sub.ReportGroupLevel3 = 'Hospital Visits' THEN '3'
		  WHEN sub.ReportSection in ('Visits') AND sub.ReportGroupLevel3 = 'Other Visits' THEN '4'
		  WHEN sub.ReportSection in ('Payment Lag by Payer by Practice','Payment Lag by Payer by Provider','AR Aging') and sub.ReportGroupLevel3 = 'Medicare' THEN '1'		  
		  WHEN sub.ReportSection in ('Payment Lag by Payer by Practice','Payment Lag by Payer by Provider','AR Aging') and sub.ReportGroupLevel3 = 'Blue Cross Blue Shield' THEN '2'		  
		  WHEN sub.ReportSection in ('Payment Lag by Payer by Practice','Payment Lag by Payer by Provider','AR Aging') and sub.ReportGroupLevel3 = 'Other Commercial' THEN '3'
		  WHEN sub.ReportSection in ('Payment Lag by Payer by Practice','Payment Lag by Payer by Provider','AR Aging') and sub.ReportGroupLevel3 = 'Liability' THEN '4'
		  WHEN sub.ReportSection in ('Payment Lag by Payer by Practice','Payment Lag by Payer by Provider','AR Aging') and sub.ReportGroupLevel3 = 'Workers Comp' THEN '5'
		  WHEN sub.ReportSection in ('Payment Lag by Payer by Practice','Payment Lag by Payer by Provider','AR Aging') and sub.ReportGroupLevel3 = 'Medicaid' THEN '6'
		  WHEN sub.ReportSection in ('Payment Lag by Payer by Practice','Payment Lag by Payer by Provider','AR Aging') and sub.ReportGroupLevel3 = 'Self-Pay' THEN '7'
		  ELSE CONVERT(varchar,sub.ReportGroupLevel3) END as ReportGroupLevel3Sort 
	,CASE WHEN sub.ReportSection in ('Revenue','Expenses') THEN RIGHT(sub.ReportGroupLevel3,(LEN(sub.ReportGroupLevel3) - 3)) ELSE sub.ReportGroupLevel3 END as ReportGroupLevel3
	,sub.ReportGroupLevel4
	,sub.PracticeID
	,sub.PracticeName
	,sub.PracticeCompany
	,sub.PracticeSpecialty
	,sub.PracticeIsActive
	,sub.PracticeIsSameStore
	,sub.ReportingProviderID
	,sub.ReportingProvider
	,sub.ReportingProviderIsPrimary
	,sub.ReportingProviderFTE
	,sub.ReportingProviderAllocationPercent
	,sub.PracticeProviderIsSpecialist
	,sub.PracticeProviderIsMidLevel
	,sub.PracticeProviderIsActive
	,sub.FiscalPeriodValueType
	,sub.FiscalPeriodNumerator
	,sub.FiscalPeriodDenominator
	,sub.FiscalPeriodValue

	/*
	,CASE WHEN sub.FiscalPeriodValueType = 'Fraction' THEN 
			CASE WHEN SUM(CASE WHEN sub.IsMonthLag12 = 'Y' THEN sub.FiscalPeriodDenominator ELSE 0 END) > 0 THEN
				   	  SUM(CASE WHEN sub.IsMonthLag12 = 'Y' THEN sub.FiscalPeriodNumerator ELSE 0 END) 
					/ SUM(CASE WHEN sub.IsMonthLag12 = 'Y' THEN sub.FiscalPeriodDenominator ELSE 0 END) ELSE 0 END
	             ELSE SUM(CASE WHEN sub.IsMonthLag12 = 'Y' THEN sub.FiscalPeriodValue ELSE 0 END) END as MonthLag12Value
	,CASE WHEN sub.FiscalPeriodValueType = 'Fraction' THEN 
			CASE WHEN SUM(CASE WHEN sub.IsMonthLag11 = 'Y' THEN sub.FiscalPeriodDenominator ELSE 0 END) > 0 THEN
				   	  SUM(CASE WHEN sub.IsMonthLag11 = 'Y' THEN sub.FiscalPeriodNumerator ELSE 0 END) 
					/ SUM(CASE WHEN sub.IsMonthLag11 = 'Y' THEN sub.FiscalPeriodDenominator ELSE 0 END) ELSE 0 END
	             ELSE SUM(CASE WHEN sub.IsMonthLag11 = 'Y' THEN sub.FiscalPeriodValue ELSE 0 END) END as MonthLag11Value
	,CASE WHEN sub.FiscalPeriodValueType = 'Fraction' THEN 
			CASE WHEN SUM(CASE WHEN sub.IsMonthLag10 = 'Y' THEN sub.FiscalPeriodDenominator ELSE 0 END) > 0 THEN
				   	  SUM(CASE WHEN sub.IsMonthLag10 = 'Y' THEN sub.FiscalPeriodNumerator ELSE 0 END) 
					/ SUM(CASE WHEN sub.IsMonthLag10 = 'Y' THEN sub.FiscalPeriodDenominator ELSE 0 END) ELSE 0 END
	             ELSE SUM(CASE WHEN sub.IsMonthLag10 = 'Y' THEN sub.FiscalPeriodValue ELSE 0 END) END as MonthLag10Value
	,CASE WHEN sub.FiscalPeriodValueType = 'Fraction' THEN 
			CASE WHEN SUM(CASE WHEN sub.IsMonthLag9 = 'Y' THEN sub.FiscalPeriodDenominator ELSE 0 END) > 0 THEN
				   	  SUM(CASE WHEN sub.IsMonthLag9 = 'Y' THEN sub.FiscalPeriodNumerator ELSE 0 END) 
					/ SUM(CASE WHEN sub.IsMonthLag9 = 'Y' THEN sub.FiscalPeriodDenominator ELSE 0 END) ELSE 0 END
	             ELSE SUM(CASE WHEN sub.IsMonthLag9 = 'Y' THEN sub.FiscalPeriodValue ELSE 0 END) END as MonthLag9Value
	,CASE WHEN sub.FiscalPeriodValueType = 'Fraction' THEN 
			CASE WHEN SUM(CASE WHEN sub.IsMonthLag8 = 'Y' THEN sub.FiscalPeriodDenominator ELSE 0 END) > 0 THEN
				   	  SUM(CASE WHEN sub.IsMonthLag8 = 'Y' THEN sub.FiscalPeriodNumerator ELSE 0 END) 
					/ SUM(CASE WHEN sub.IsMonthLag8 = 'Y' THEN sub.FiscalPeriodDenominator ELSE 0 END) ELSE 0 END
	             ELSE SUM(CASE WHEN sub.IsMonthLag8 = 'Y' THEN sub.FiscalPeriodValue ELSE 0 END) END as MonthLag8Value
	,CASE WHEN sub.FiscalPeriodValueType = 'Fraction' THEN 
			CASE WHEN SUM(CASE WHEN sub.IsMonthLag7 = 'Y' THEN sub.FiscalPeriodDenominator ELSE 0 END) > 0 THEN
				   	  SUM(CASE WHEN sub.IsMonthLag7 = 'Y' THEN sub.FiscalPeriodNumerator ELSE 0 END) 
					/ SUM(CASE WHEN sub.IsMonthLag7 = 'Y' THEN sub.FiscalPeriodDenominator ELSE 0 END) ELSE 0 END
	             ELSE SUM(CASE WHEN sub.IsMonthLag7 = 'Y' THEN sub.FiscalPeriodValue ELSE 0 END) END as MonthLag7Value
	,CASE WHEN sub.FiscalPeriodValueType = 'Fraction' THEN 
			CASE WHEN SUM(CASE WHEN sub.IsMonthLag6 = 'Y' THEN sub.FiscalPeriodDenominator ELSE 0 END) > 0 THEN
				   	  SUM(CASE WHEN sub.IsMonthLag6 = 'Y' THEN sub.FiscalPeriodNumerator ELSE 0 END) 
					/ SUM(CASE WHEN sub.IsMonthLag6 = 'Y' THEN sub.FiscalPeriodDenominator ELSE 0 END) ELSE 0 END
	             ELSE SUM(CASE WHEN sub.IsMonthLag6 = 'Y' THEN sub.FiscalPeriodValue ELSE 0 END) END as MonthLag6Value
	,CASE WHEN sub.FiscalPeriodValueType = 'Fraction' THEN 
			CASE WHEN SUM(CASE WHEN sub.IsMonthLag5 = 'Y' THEN sub.FiscalPeriodDenominator ELSE 0 END) > 0 THEN
				   	  SUM(CASE WHEN sub.IsMonthLag5 = 'Y' THEN sub.FiscalPeriodNumerator ELSE 0 END) 
					/ SUM(CASE WHEN sub.IsMonthLag5 = 'Y' THEN sub.FiscalPeriodDenominator ELSE 0 END) ELSE 0 END
	             ELSE SUM(CASE WHEN sub.IsMonthLag5 = 'Y' THEN sub.FiscalPeriodValue ELSE 0 END) END as MonthLag5Value
	,CASE WHEN sub.FiscalPeriodValueType = 'Fraction' THEN 
			CASE WHEN SUM(CASE WHEN sub.IsMonthLag4 = 'Y' THEN sub.FiscalPeriodDenominator ELSE 0 END) > 0 THEN
				   	  SUM(CASE WHEN sub.IsMonthLag4 = 'Y' THEN sub.FiscalPeriodNumerator ELSE 0 END) 
					/ SUM(CASE WHEN sub.IsMonthLag4 = 'Y' THEN sub.FiscalPeriodDenominator ELSE 0 END) ELSE 0 END
	             ELSE SUM(CASE WHEN sub.IsMonthLag4 = 'Y' THEN sub.FiscalPeriodValue ELSE 0 END) END as MonthLag4Value
	,CASE WHEN sub.FiscalPeriodValueType = 'Fraction' THEN 
			CASE WHEN SUM(CASE WHEN sub.IsMonthLag3 = 'Y' THEN sub.FiscalPeriodDenominator ELSE 0 END) > 0 THEN
				   	  SUM(CASE WHEN sub.IsMonthLag3 = 'Y' THEN sub.FiscalPeriodNumerator ELSE 0 END) 
					/ SUM(CASE WHEN sub.IsMonthLag3 = 'Y' THEN sub.FiscalPeriodDenominator ELSE 0 END) ELSE 0 END
	             ELSE SUM(CASE WHEN sub.IsMonthLag3 = 'Y' THEN sub.FiscalPeriodValue ELSE 0 END) END as MonthLag3Value
	,CASE WHEN sub.FiscalPeriodValueType = 'Fraction' THEN 
			CASE WHEN SUM(CASE WHEN sub.IsMonthLag2 = 'Y' THEN sub.FiscalPeriodDenominator ELSE 0 END) > 0 THEN
				   	  SUM(CASE WHEN sub.IsMonthLag2 = 'Y' THEN sub.FiscalPeriodNumerator ELSE 0 END) 
					/ SUM(CASE WHEN sub.IsMonthLag2 = 'Y' THEN sub.FiscalPeriodDenominator ELSE 0 END) ELSE 0 END
	             ELSE SUM(CASE WHEN sub.IsMonthLag2 = 'Y' THEN sub.FiscalPeriodValue ELSE 0 END) END as MonthLag2Value
	,CASE WHEN sub.FiscalPeriodValueType = 'Fraction' THEN 
			CASE WHEN SUM(CASE WHEN sub.IsMonthLag1 = 'Y' THEN sub.FiscalPeriodDenominator ELSE 0 END) > 0 THEN
				   	  SUM(CASE WHEN sub.IsMonthLag1 = 'Y' THEN sub.FiscalPeriodNumerator ELSE 0 END) 
					/ SUM(CASE WHEN sub.IsMonthLag1 = 'Y' THEN sub.FiscalPeriodDenominator ELSE 0 END) ELSE 0 END
	             ELSE SUM(CASE WHEN sub.IsMonthLag1 = 'Y' THEN sub.FiscalPeriodValue ELSE 0 END) END as MonthLag1Value
	,CASE WHEN sub.FiscalPeriodValueType = 'Fraction' THEN 
			CASE WHEN SUM(CASE WHEN sub.ISMTD = 'Y' THEN sub.FiscalPeriodDenominator ELSE 0 END) > 0 THEN
				   	  SUM(CASE WHEN sub.ISMTD = 'Y' THEN sub.FiscalPeriodNumerator ELSE 0 END) 
					/ SUM(CASE WHEN sub.ISMTD = 'Y' THEN sub.FiscalPeriodDenominator ELSE 0 END) ELSE 0 END
	             ELSE SUM(CASE WHEN sub.ISMTD = 'Y' THEN sub.FiscalPeriodValue ELSE 0 END) END as MTDValue
	,CASE WHEN sub.FiscalPeriodValueType = 'Fraction' THEN 
			CASE WHEN SUM(CASE WHEN sub.IsYTD = 'Y' THEN sub.FiscalPeriodDenominator ELSE 0 END) > 0 THEN
				   	  SUM(CASE WHEN sub.IsYTD = 'Y' THEN sub.FiscalPeriodNumerator ELSE 0 END) 
					/ SUM(CASE WHEN sub.IsYTD = 'Y' THEN sub.FiscalPeriodDenominator ELSE 0 END) ELSE 0 END
	             ELSE SUM(CASE WHEN sub.IsYTD = 'Y' THEN sub.FiscalPeriodValue ELSE 0 END) END as YTDValue
	,CASE WHEN sub.FiscalPeriodValueType = 'Fraction' THEN 
			CASE WHEN SUM(CASE WHEN sub.IsPYTD = 'Y' THEN sub.FiscalPeriodDenominator ELSE 0 END) > 0 THEN
				   	  SUM(CASE WHEN sub.IsPYTD = 'Y' THEN sub.FiscalPeriodNumerator ELSE 0 END) 
					/ SUM(CASE WHEN sub.IsPYTD = 'Y' THEN sub.FiscalPeriodDenominator ELSE 0 END) ELSE 0 END
	             ELSE SUM(CASE WHEN sub.IsPYTD = 'Y' THEN sub.FiscalPeriodValue ELSE 0 END) END as PYTDValue
	,CASE WHEN sub.FiscalPeriodValueType = 'Fraction' THEN 
			CASE WHEN SUM(CASE WHEN sub.IsPPYTD = 'Y' THEN sub.FiscalPeriodDenominator ELSE 0 END) > 0 THEN
				   	  SUM(CASE WHEN sub.IsPPYTD = 'Y' THEN sub.FiscalPeriodNumerator ELSE 0 END) 
					/ SUM(CASE WHEN sub.IsPPYTD = 'Y' THEN sub.FiscalPeriodDenominator ELSE 0 END) ELSE 0 END
	             ELSE SUM(CASE WHEN sub.IsPPYTD = 'Y' THEN sub.FiscalPeriodValue ELSE 0 END) END as PPYTDValue
	,CASE WHEN sub.FiscalPeriodValueType = 'Fraction' THEN 
			CASE WHEN SUM(CASE WHEN sub.IsPY = 'Y' THEN sub.FiscalPeriodDenominator ELSE 0 END) > 0 THEN
				   	  SUM(CASE WHEN sub.IsPY = 'Y' THEN sub.FiscalPeriodNumerator ELSE 0 END) 
					/ SUM(CASE WHEN sub.IsPY = 'Y' THEN sub.FiscalPeriodDenominator ELSE 0 END) ELSE 0 END
	             ELSE SUM(CASE WHEN sub.IsPY = 'Y' THEN sub.FiscalPeriodValue ELSE 0 END) END as PYValue
	,CASE WHEN sub.FiscalPeriodValueType = 'Fraction' THEN 
			CASE WHEN SUM(CASE WHEN sub.IsPPY = 'Y' THEN sub.FiscalPeriodDenominator ELSE 0 END) > 0 THEN
				   	  SUM(CASE WHEN sub.IsPPY = 'Y' THEN sub.FiscalPeriodNumerator ELSE 0 END) 
					/ SUM(CASE WHEN sub.IsPPY = 'Y' THEN sub.FiscalPeriodDenominator ELSE 0 END) ELSE 0 END
	             ELSE SUM(CASE WHEN sub.IsPPY = 'Y' THEN sub.FiscalPeriodValue ELSE 0 END) END as PPYValue
	,CASE WHEN sub.FiscalPeriodValueType = 'Fraction' THEN 
			CASE WHEN SUM(CASE WHEN sub.IsTrailing12Months = 'Y' THEN sub.FiscalPeriodDenominator ELSE 0 END) > 0 THEN
				   	  SUM(CASE WHEN sub.IsTrailing12Months = 'Y' THEN sub.FiscalPeriodNumerator ELSE 0 END) 
					/ SUM(CASE WHEN sub.IsTrailing12Months = 'Y' THEN sub.FiscalPeriodDenominator ELSE 0 END) ELSE 0 END
	             ELSE SUM(CASE WHEN sub.IsTrailing12Months = 'Y' THEN sub.FiscalPeriodValue ELSE 0 END) END as Trailing12MonthsValue
	,CASE WHEN sub.FiscalPeriodValueType = 'Fraction' THEN 
			CASE WHEN SUM(CASE WHEN sub.IsTrailing6Months = 'Y' THEN sub.FiscalPeriodDenominator ELSE 0 END) > 0 THEN
				   	  SUM(CASE WHEN sub.IsTrailing6Months = 'Y' THEN sub.FiscalPeriodNumerator ELSE 0 END) 
					/ SUM(CASE WHEN sub.IsTrailing6Months = 'Y' THEN sub.FiscalPeriodDenominator ELSE 0 END) ELSE 0 END
	             ELSE SUM(CASE WHEN sub.IsTrailing6Months = 'Y' THEN sub.FiscalPeriodValue ELSE 0 END) END as Trailing6MonthsValue
	,CASE WHEN sub.FiscalPeriodValueType = 'Fraction' THEN 
			CASE WHEN SUM(CASE WHEN sub.IsYearBegin = 'Y' THEN sub.FiscalPeriodDenominator ELSE 0 END) > 0 THEN
				   	  SUM(CASE WHEN sub.IsYearBegin = 'Y' THEN sub.FiscalPeriodNumerator ELSE 0 END) 
					/ SUM(CASE WHEN sub.IsYearBegin = 'Y' THEN sub.FiscalPeriodDenominator ELSE 0 END) ELSE 0 END
	             ELSE SUM(CASE WHEN sub.IsYearBegin = 'Y' THEN sub.FiscalPeriodValue ELSE 0 END) END as YearBeginValue
	,CASE WHEN pps.PracticeProviderCount >= 1 THEN 'Yes' ELSE 'No' End as HasPracticeProviders
	,max(sub.UpdatedDatetime) as UpdatedDatetime
	*/
FROM (


	SELECT [FiscalYear]
		  ,[FiscalPeriod]
		  ,[FiscalYearPeriod]
		  ,[ReportSection]
		  ,[ReportGroupLevel1]
		  ,[ReportGroupLevel2]
		  ,[ReportGroupLevel3]
		  ,[ReportGroupLevel4]
		  ,bb.[PracticeID]
		  ,p.PracticeName
		  ,p.PracticeCompany
		  ,p.PracticeSpecialty
		  ,p.PracticeIsActive
		  ,p.PracticeIsSameStore
		  ,[ReportingProviderID]
		  ,prv.ProviderFullName as ReportingProvider
		  ,pp.PracticeProviderIsPrimary as ReportingProviderIsPrimary
		  ,pp.PracticeProviderFTE as ReportingProviderFTE
		  ,pp.PracticeProviderAllocationPercent as ReportingProviderAllocationPercent
		  ,pp.PracticeProviderIsSpecialist
		  ,pp.PracticeProviderIsMidLevel
		  ,pp.PracticeProviderIsActive
		  ,FiscalPeriodValueType
		  ,FiscalPeriodNumerator
		  ,FiscalPeriodDenominator
		  ,CASE WHEN bb.ReportSection in ('Expenses') THEN -bb.FiscalPeriodValue ELSE bb.FiscalPeriodValue END AS [FiscalPeriodValue]
		  ,CASE WHEN bb.ReportSection in ('Expenses') THEN -bb.FiscalPeriodValue ELSE bb.FiscalPeriodValue END as FiscalPeriodValueNet
		  
		  /*
		  ,CASE WHEN bb.FiscalYear = @CurrentYear AND bb.FiscalPeriod = 1 THEN 'Y' ELSE 'N' END as IsYearBegin
		  ,CASE WHEN bb.FiscalYear = @CurrentYear THEN 'Y' ELSE 'N' END as IsYTD
		  ,CASE WHEN bb.FiscalYear = @CurrentYear - 1 AND bb.FiscalPeriod <= @CurrentPeriod THEN 'Y' ELSE 'N' END as IsPYTD
		  ,CASE WHEN bb.FiscalYear = @CurrentYear - 2 AND bb.FiscalPeriod <= @CurrentPeriod THEN 'Y' ELSE 'N' END as IsPPYTD
		  ,CASE WHEN bb.FiscalYear = @CurrentYear - 1 THEN 'Y' ELSE 'N' END as IsPY
		  ,CASE WHEN bb.FiscalYear = @CurrentYear - 2 THEN 'Y' ELSE 'N' END as IsPPY
		  ,CASE WHEN DATEFROMPARTS(bb.FiscalYear, CASE WHEN bb.FiscalPeriod = 0 THEN 1 ELSE bb.FiscalPeriod END,1) between @6MonthStartDate AND DATEADD(DAY,-1,@EndDate) THEN 'Y' ELSE 'N' END as IsTrailing6Months
		  ,CASE WHEN DATEFROMPARTS(bb.FiscalYear, CASE WHEN bb.FiscalPeriod = 0 THEN 1 ELSE bb.FiscalPeriod END,1) between @12MonthStartDate AND DATEADD(DAY,-1,@EndDate) THEN 'Y' ELSE 'N' END as IsTrailing12Months
		  ,CASE WHEN DATEFROMPARTS(bb.FiscalYear, CASE WHEN bb.FiscalPeriod = 0 THEN 1 ELSE bb.FiscalPeriod END,1) between @12MonthStartDate AND @EndDate THEN 'Y' ELSE 'N' END as IsTrailing13Months
		  ,CASE WHEN DATEFROMPARTS(bb.FiscalYear, CASE WHEN bb.FiscalPeriod = 0 THEN 1 ELSE bb.FiscalPeriod END,1) between DATEADD(MONTH,-12,@EndDate) and DATEADD(DAY,-1,DATEADD(MONTH,-11,@EndDate)) THEN 'Y' ELSE 'N' END as IsMonthLag12
		  ,CASE WHEN DATEFROMPARTS(bb.FiscalYear, CASE WHEN bb.FiscalPeriod = 0 THEN 1 ELSE bb.FiscalPeriod END,1) between DATEADD(MONTH,-11,@EndDate) and DATEADD(DAY,-1,DATEADD(MONTH,-10,@EndDate)) THEN 'Y' ELSE 'N' END as IsMonthLag11
		  ,CASE WHEN DATEFROMPARTS(bb.FiscalYear, CASE WHEN bb.FiscalPeriod = 0 THEN 1 ELSE bb.FiscalPeriod END,1) between DATEADD(MONTH,-10,@EndDate) and DATEADD(DAY,-1,DATEADD(MONTH,-9,@EndDate)) THEN 'Y' ELSE 'N' END as IsMonthLag10
		  ,CASE WHEN DATEFROMPARTS(bb.FiscalYear, CASE WHEN bb.FiscalPeriod = 0 THEN 1 ELSE bb.FiscalPeriod END,1) between DATEADD(MONTH,-9,@EndDate) and DATEADD(DAY,-1,DATEADD(MONTH,-8,@EndDate)) THEN 'Y' ELSE 'N' END as IsMonthLag9
		  ,CASE WHEN DATEFROMPARTS(bb.FiscalYear, CASE WHEN bb.FiscalPeriod = 0 THEN 1 ELSE bb.FiscalPeriod END,1) between DATEADD(MONTH,-8,@EndDate) and DATEADD(DAY,-1,DATEADD(MONTH,-7,@EndDate)) THEN 'Y' ELSE 'N' END as IsMonthLag8
		  ,CASE WHEN DATEFROMPARTS(bb.FiscalYear, CASE WHEN bb.FiscalPeriod = 0 THEN 1 ELSE bb.FiscalPeriod END,1) between DATEADD(MONTH,-7,@EndDate) and DATEADD(DAY,-1,DATEADD(MONTH,-6,@EndDate)) THEN 'Y' ELSE 'N' END as IsMonthLag7
		  ,CASE WHEN DATEFROMPARTS(bb.FiscalYear, CASE WHEN bb.FiscalPeriod = 0 THEN 1 ELSE bb.FiscalPeriod END,1) between DATEADD(MONTH,-6,@EndDate) and DATEADD(DAY,-1,DATEADD(MONTH,-5,@EndDate)) THEN 'Y' ELSE 'N' END as IsMonthLag6
		  ,CASE WHEN DATEFROMPARTS(bb.FiscalYear, CASE WHEN bb.FiscalPeriod = 0 THEN 1 ELSE bb.FiscalPeriod END,1) between DATEADD(MONTH,-5,@EndDate) and DATEADD(DAY,-1,DATEADD(MONTH,-4,@EndDate)) THEN 'Y' ELSE 'N' END as IsMonthLag5
		  ,CASE WHEN DATEFROMPARTS(bb.FiscalYear, CASE WHEN bb.FiscalPeriod = 0 THEN 1 ELSE bb.FiscalPeriod END,1) between DATEADD(MONTH,-4,@EndDate) and DATEADD(DAY,-1,DATEADD(MONTH,-3,@EndDate)) THEN 'Y' ELSE 'N' END as IsMonthLag4
		  ,CASE WHEN DATEFROMPARTS(bb.FiscalYear, CASE WHEN bb.FiscalPeriod = 0 THEN 1 ELSE bb.FiscalPeriod END,1) between DATEADD(MONTH,-3,@EndDate) and DATEADD(DAY,-1,DATEADD(MONTH,-2,@EndDate)) THEN 'Y' ELSE 'N' END as IsMonthLag3
		  ,CASE WHEN DATEFROMPARTS(bb.FiscalYear, CASE WHEN bb.FiscalPeriod = 0 THEN 1 ELSE bb.FiscalPeriod END,1) between DATEADD(MONTH,-2,@EndDate) and DATEADD(DAY,-1,DATEADD(MONTH,-1,@EndDate)) THEN 'Y' ELSE 'N' END as IsMonthLag2
		  ,CASE WHEN DATEFROMPARTS(bb.FiscalYear, CASE WHEN bb.FiscalPeriod = 0 THEN 1 ELSE bb.FiscalPeriod END,1) between DATEADD(MONTH,-1,@EndDate) and DATEADD(DAY,-1,DATEADD(MONTH,-0,@EndDate)) THEN 'Y' ELSE 'N' END as IsMonthLag1
		  ,CASE WHEN bb.FiscalYear = @CurrentYear AND bb.FiscalPeriod = @CurrentPeriod THEN 'Y' ELSE 'N' END as IsMTD
			*/
		  ,[UpdatedDatetime]
	  FROM (
		   SELECT
				[FiscalYear]
				,[FiscalPeriod]
				,[FiscalYearPeriod]
				,[ReportSection]
				,[ReportGroupLevel1]
				,[ReportGroupLevel2]
				,[ReportGroupLevel3]
				,[ReportGroupLevel4]
				,[PracticeID]
				,[ReportingProviderID]
				,CASE WHEN ReportSection like '%Charge Lag%' OR ReportSection like '%Payment Lag%' THEN 'Fraction' ELSE 'Sum' END as FiscalPeriodValueType ------Testing------
				,FiscalPeriodNumerator --[FiscalPeriodValue] as FiscalPeriodNumerator
				,FiscalPeriodDenominator --1 as FiscalPeriodDenominator
				,[FiscalPeriodValue]
				,[UpdatedDatetime]
			FROM [HPIDW].[rpt].[BlueBooks] b
			WHERE 1=1 
				AND DATEFROMPARTS(b.FiscalYear, CASE WHEN b.FiscalPeriod = 0 THEN 1 ELSE b.FiscalPeriod END,1) between '1/1/2023' AND getdate() --@StartDate and @EndDate
				/*
				AND ((@Practice <> 'EKK' AND (@SpecialFilter = '0' OR b.ReportGroupLevel4 = @SpecialFilter))
						OR (
							(@Practice = 'EKK' AND @SpecialFilter != 'NoPI' AND (@SpecialFilter = '0' OR b.ReportGroupLevel4 = @SpecialFilter))
								OR 
							(@SpecialFilter = 'NoPI' AND ISNULL(b.ReportGroupLevel4,'') <> 'PI')
							)
						) /*Special filter to remove PI activity from EKK's main Blue Book*/
					*/
/*			
			UNION ALL

			SELECT
				b.[FiscalYear]
				,b.[FiscalPeriod]
				,[FiscalYearPeriod]
				,'Payments Per Visit Per Practice' as [ReportSection]
				,b.[ReportGroupLevel1]
				,b.ReportGroupLevel2 as [ReportGroupLevel2]
				,NULL AS ReportGroupLevel3
				,NULL AS ReportGroupLevel4
				,b.[PracticeID]
				,NULL AS [ReportingProviderID]
				,'Fraction' as FiscalPeriodValueType
				,SUM(CASE WHEN b.ReportSection = 'Payments' THEN b.FiscalPeriodValue ELSE 0 END) as FiscalPeriodNumerator
				,ISNULL(SUM(CASE WHEN b.ReportSection = 'Visits' THEN b.FiscalPeriodValue ELSE 0 END),0) as FiscalPeriodDenominator
				,CASE WHEN ISNULL(SUM(CASE WHEN b.ReportSection = 'Visits' THEN b.FiscalPeriodValue ELSE 0 END),0) = 0 THEN 0 ELSE 
					SUM(CASE WHEN b.ReportSection = 'Payments' THEN b.FiscalPeriodValue ELSE 0 END)
					/ SUM(CASE WHEN b.ReportSection = 'Visits' THEN b.FiscalPeriodValue ELSE 0 END) END AS [FiscalPeriodValue]
				,MAX([UpdatedDatetime]) AS UpdatedDatetime
			FROM [HPIDW].[rpt].[BlueBooks] b
			WHERE 1=1 
				AND DATEFROMPARTS(b.FiscalYear, CASE WHEN b.FiscalPeriod = 0 THEN 1 ELSE b.FiscalPeriod END,1) between @StartDate and @EndDate
				AND b.ReportSection in ('Visits','Payments')
				AND b.ReportGroupLevel1 in ('Surgical Visits','Office Visits','Hospital Visits','Other Visits')
				--AND (@SpecialFilter = '0' or b.ReportGroupLevel4 = @SpecialFilter)
				AND ((@Practice <> 'EKK' AND (@SpecialFilter = '0' OR b.ReportGroupLevel4 = @SpecialFilter))
						OR (
							(@Practice = 'EKK' AND @SpecialFilter != 'NoPI' AND (@SpecialFilter = '0' OR b.ReportGroupLevel4 = @SpecialFilter))
								OR 
							(@SpecialFilter = 'NoPI' AND ISNULL(b.ReportGroupLevel4,'') <> 'PI')
							)
						) /*Special filter to remove PI activity from EKK's main Blue Book*/
			GROUP BY
				b.FiscalYear
				,b.FiscalPeriod
				,b.FiscalYearPeriod
				,b.ReportGroupLevel1
				,b.ReportGroupLevel2 
				--,b.ReportGroupLevel3
				--,b.ReportGroupLevel4
				,b.PracticeID

			UNION ALL

			SELECT
				b.[FiscalYear]
				,b.[FiscalPeriod]
				,[FiscalYearPeriod]
				,'Charges Per Visit Per Practice' as [ReportSection]
				,b.[ReportGroupLevel1]
				,NULL as [ReportGroupLevel2]
				,NULL as [ReportGroupLevel3]
				,null as [ReportGroupLevel4]
				,b.[PracticeID]
				,NULL as [ReportingProviderID]
				,'Fraction' as FiscalPeriodValueType
				,SUM(CASE WHEN b.ReportSection = 'Charges' THEN b.FiscalPeriodValue ELSE 0 END) as FiscalPeriodNumerator
				,ISNULL(SUM(CASE WHEN b.ReportSection = 'Visits' THEN b.FiscalPeriodValue ELSE 0 END),0) as FiscalPeriodDenominator
				,CASE WHEN ISNULL(SUM(CASE WHEN b.ReportSection = 'Visits' THEN b.FiscalPeriodValue ELSE 0 END),0) = 0 THEN 0 ELSE 
					SUM(CASE WHEN b.ReportSection = 'Charges' THEN b.FiscalPeriodValue ELSE 0 END)
					/ SUM(CASE WHEN b.ReportSection = 'Visits' THEN b.FiscalPeriodValue ELSE 0 END) END AS [FiscalPeriodValue]
				,MAX([UpdatedDatetime]) AS UpdatedDatetime
			FROM [HPIDW].[rpt].[BlueBooks] b
			WHERE 1=1 
				AND DATEFROMPARTS(b.FiscalYear, CASE WHEN b.FiscalPeriod = 0 THEN 1 ELSE b.FiscalPeriod END,1) between @StartDate and @EndDate
				AND b.ReportSection in ('Visits','Charges')
				AND b.ReportGroupLevel1 in ('Surgical Visits','Office Visits','Hospital Visits','Other Visits')
				--AND (@SpecialFilter = '0' or b.ReportGroupLevel4 = @SpecialFilter)
				AND ((@Practice <> 'EKK' AND (@SpecialFilter = '0' OR b.ReportGroupLevel4 = @SpecialFilter))
						OR (
							(@Practice = 'EKK' AND @SpecialFilter != 'NoPI' AND (@SpecialFilter = '0' OR b.ReportGroupLevel4 = @SpecialFilter))
								OR 
							(@SpecialFilter = 'NoPI' AND ISNULL(b.ReportGroupLevel4,'') <> 'PI')
							)
						) /*Special filter to remove PI activity from EKK's main Blue Book*/
			GROUP BY
				b.FiscalYear
				,b.FiscalPeriod
				,b.FiscalYearPeriod
				,b.ReportGroupLevel1
				--,b.ReportGroupLevel4
				,b.PracticeID

			UNION ALL

			SELECT
				b.[FiscalYear]
				,b.[FiscalPeriod]
				,[FiscalYearPeriod]
				,'Payments Per Visit Per Provider' as [ReportSection]
				,b.[ReportGroupLevel1]
				,b.ReportGroupLevel2 as [ReportGroupLevel2]
				,NULL AS ReportGroupLevel3 
				,NULL AS ReportGroupLevel4
				,b.[PracticeID]
				,min(b.ReportingProviderID) as ReportingProviderID  --b.[ReportingProviderID]
				,'Fraction' as FiscalPeriodValueType
				,SUM(CASE WHEN b.ReportSection = 'Payments' THEN b.FiscalPeriodValue ELSE 0 END) as FiscalPeriodNumerator
				,ISNULL(SUM(CASE WHEN b.ReportSection = 'Visits' THEN b.FiscalPeriodValue ELSE 0 END),0) as FiscalPeriodDenominator
				,CASE WHEN ISNULL(SUM(CASE WHEN b.ReportSection = 'Visits' THEN b.FiscalPeriodValue ELSE 0 END),0) = 0 THEN 0 ELSE 
					SUM(CASE WHEN b.ReportSection = 'Payments' THEN b.FiscalPeriodValue ELSE 0 END)
					/ SUM(CASE WHEN b.ReportSection = 'Visits' THEN b.FiscalPeriodValue ELSE 0 END) END AS [FiscalPeriodValue]
				,MAX([UpdatedDatetime]) AS UpdatedDatetime
			FROM [HPIDW].[rpt].[BlueBooks] b
			left join dim.vproviders p on p.ProviderID = b.ReportingProviderID
			WHERE 1=1 
				AND DATEFROMPARTS(b.FiscalYear, CASE WHEN b.FiscalPeriod = 0 THEN 1 ELSE b.FiscalPeriod END,1) between @StartDate and @EndDate
				AND b.ReportSection in ('Visits','Payments')
				AND b.ReportGroupLevel1 in ('Surgical Visits','Office Visits','Hospital Visits','Other Visits')
				--AND (@SpecialFilter = '0' or b.ReportGroupLevel4 = @SpecialFilter)
				AND ((@Practice <> 'EKK' AND (@SpecialFilter = '0' OR b.ReportGroupLevel4 = @SpecialFilter))
						OR (
							(@Practice = 'EKK' AND @SpecialFilter != 'NoPI' AND (@SpecialFilter = '0' OR b.ReportGroupLevel4 = @SpecialFilter))
								OR 
							(@SpecialFilter = 'NoPI' AND ISNULL(b.ReportGroupLevel4,'') <> 'PI')
							)
						) /*Special filter to remove PI activity from EKK's main Blue Book*/
			GROUP BY
				b.FiscalYear
				,b.FiscalPeriod
				,b.FiscalYearPeriod
				,b.ReportGroupLevel1
				,b.ReportGroupLevel2
				--,b.ReportGroupLevel3
				--,b.ReportGroupLevel4
				,b.PracticeID
				--,b.ReportingProviderID
				,p.ParentProviderID

			UNION ALL

			SELECT
				b.[FiscalYear]
				,b.[FiscalPeriod]
				,[FiscalYearPeriod]
				,'Charges Per Visit Per Provider' as [ReportSection]
				,b.[ReportGroupLevel1]
				,NULL as [ReportGroupLevel2]
				,NULL as [ReportGroupLevel3]
				,NULL as ReportGroupLevel4
				,b.[PracticeID]
				,min(b.ReportingProviderID) as ReportingProviderID  --b.[ReportingProviderID]
				,'Fraction' as FiscalPeriodValueType
				,SUM(CASE WHEN b.ReportSection = 'Charges' THEN b.FiscalPeriodValue ELSE 0 END) as FiscalPeriodNumerator
				,ISNULL(SUM(CASE WHEN b.ReportSection = 'Visits' THEN b.FiscalPeriodValue ELSE 0 END),0) as FiscalPeriodDenominator
				,CASE WHEN ISNULL(SUM(CASE WHEN b.ReportSection = 'Visits' THEN b.FiscalPeriodValue ELSE 0 END),0) = 0 THEN 0 ELSE 
					SUM(CASE WHEN b.ReportSection = 'Charges' THEN b.FiscalPeriodValue ELSE 0 END)
					/ SUM(CASE WHEN b.ReportSection = 'Visits' THEN b.FiscalPeriodValue ELSE 0 END) END AS [FiscalPeriodValue]
				,MAX([UpdatedDatetime]) AS UpdatedDatetime
			FROM [HPIDW].[rpt].[BlueBooks] b
			left join dim.vproviders p on p.ProviderID = b.ReportingProviderID
			WHERE 1=1 
				AND DATEFROMPARTS(b.FiscalYear, CASE WHEN b.FiscalPeriod = 0 THEN 1 ELSE b.FiscalPeriod END,1) between @StartDate and @EndDate
				AND b.ReportSection in ('Visits','Charges')
				AND b.ReportGroupLevel1 in ('Surgical Visits','Office Visits','Hospital Visits')
				--AND (@SpecialFilter = '0' or b.ReportGroupLevel4 = @SpecialFilter)
				AND ((@Practice <> 'EKK' AND (@SpecialFilter = '0' OR b.ReportGroupLevel4 = @SpecialFilter))
						OR (
							(@Practice = 'EKK' AND @SpecialFilter != 'NoPI' AND (@SpecialFilter = '0' OR b.ReportGroupLevel4 = @SpecialFilter))
								OR 
							(@SpecialFilter = 'NoPI' AND ISNULL(b.ReportGroupLevel4,'') <> 'PI')
							)
						) /*Special filter to remove PI activity from EKK's main Blue Book*/
			GROUP BY
				b.FiscalYear
				,b.FiscalPeriod
				,b.FiscalYearPeriod
				,b.ReportGroupLevel1
				--,b.ReportGroupLevel4
				,b.PracticeID
				--,b.ReportingProviderID
				,p.ParentProviderID
*/
			
	  ) bb
		left join dim.Practices p ON p.PracticeID = bb.PracticeID
		left join dim.vProviders prv ON prv.ProviderID = bb.ReportingProviderID 
		left join ( SELECT pr.ParentProviderID, pr.ProviderFullName, p.* 
					FROM map.PracticeProviders p 
						left join dim.vProviders pr ON pr.ProviderID = p.ProviderID) pp ON pp.PracticeID = bb.PracticeID AND pp.ParentProviderID = prv.ParentProviderID--bb.ReportingProviderID
	  WHERE 1=1
		--AND DATEFROMPARTS(bb.FiscalYear, CASE WHEN bb.FiscalPeriod = 0 THEN 1 ELSE bb.FiscalPeriod END,1) between '1/1/2023' AND getdate()  --@StartDate and @EndDate
		AND p.PracticeCompany = 'TPG'
		--AND (@Practice = '0' OR p.PracticeSourceID = @Practice)
		--AND (@Provider = '0' OR prv.ParentProviderID = @Provider)
		--AND (@SpecialFilter = '0' or bb.ReportGroupLevel4 = @SpecialFilter)

	) sub
	left join (select
					p.PracticeID
					,count(distinct pp.ProviderID) PracticeProviderCount
				from dim.Practices p
					left join map.PracticeProviders pp ON  pp.PracticeID = p.PracticeID
				where 1=1
					and p.PracticeIsActive = 1
					and pp.PracticeProviderIsPrimary = 0
					and pp.PracticeProviderAllocationPercent is not null
				group by p.PracticeID
			 ) pps ON pps.PracticeID = sub.PracticeID

			 /*
GROUP BY
	sub.ReportSection
	,sub.ReportGroupLevel1
	,sub.ReportGroupLevel2
	,sub.ReportGroupLevel3
	,sub.ReportGroupLevel4
	,sub.PracticeID
	,sub.PracticeName
	,sub.PracticeCompany
	,sub.PracticeIsActive
	,sub.PracticeIsSameStore
	,sub.ReportingProviderID
	,sub.ReportingProvider
	,sub.ReportingProviderIsPrimary
	,sub.ReportingProviderFTE
	,sub.ReportingProviderAllocationPercent
	,sub.PracticeProviderIsSpecialist
	,sub.PracticeProviderIsMidLevel
	,sub.PracticeProviderIsActive
	,pps.PracticeProviderCount
	,sub.FiscalPeriodValueType



OPTION (OPTIMIZE FOR UNKNOWN)
*/
GO
