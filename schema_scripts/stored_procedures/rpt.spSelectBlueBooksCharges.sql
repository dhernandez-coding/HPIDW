CREATE PROCEDURE  [rpt].[spSelectBlueBooksCharges]

	@CurrentYear int 
	,@CurrentPeriod int 
	,@Practice varchar(10)
	,@SpecialFilter varchar(50)
	--,@Provider varchar(100)
	
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
	  ,DATEFROMPARTS(FiscalYear,FiscalPeriod,1) AS FiscalYearPeriodDate
      ,[ReportSection]
      ,[ReportGroupLevel1]
      ,[ReportGroupLevel2]
	  ,[ReportGroupLevel4]
      ,bb.[PracticeID]
	  ,p.PracticeName
      ,[ReportingProviderID]
	  ,prv.ProviderFullName as ReportingProvider
	  ,pp.PracticeProviderIsPrimary as ReportingProviderIsPrimary
      ,[FiscalPeriodValue]
	  ,CASE WHEN bb.ReportSection in ('Expenses') THEN -bb.FiscalPeriodValue ELSE bb.FiscalPeriodValue END as FiscalPeriodValueNet
	  ,CASE WHEN bb.FiscalYear = @CurrentYear THEN 'Y' ELSE 'N' END as IsYTD
	  ,CASE WHEN bb.FiscalYear = @CurrentYear - 1 AND bb.FiscalPeriod <= @CurrentPeriod THEN 'Y' ELSE 'N' END as IsPYTD
	  ,CASE WHEN DATEFROMPARTS(bb.FiscalYear, bb.FiscalPeriod,1) between @6MonthStartDate AND DATEADD(DAY,-1,@EndDate) THEN 'Y' ELSE 'N' END as IsTrailing6Months
	  ,CASE WHEN DATEFROMPARTS(bb.FiscalYear, bb.FiscalPeriod,1) between @12MonthStartDate AND DATEADD(DAY,-1,@EndDate) THEN 'Y' ELSE 'N' END as IsTrailing12Months
	  ,CASE WHEN DATEFROMPARTS(bb.FiscalYear, bb.FiscalPeriod,1) between @12MonthStartDate AND @EndDate THEN 'Y' ELSE 'N' END as IsTrailing13Months
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
			,[ReportGroupLevel4]
			,[PracticeID]
			,[ReportingProviderID]
			,[FiscalPeriodValue]
			,[UpdatedDatetime]
		FROM [HPIDW].[rpt].[BlueBooks] b
		WHERE 1=1 
			AND b.ReportSection = 'Charges'
			AND DATEFROMPARTS(b.FiscalYear, b.FiscalPeriod,1) between @StartDate and @EndDate
  ) bb
	left join dim.vPractices p ON p.PracticeID = bb.PracticeID
	left join dim.vProviders prv ON prv.ProviderID = bb.ReportingProviderID 
	left join map.vPracticeProviders pp ON pp.PracticeID = bb.PracticeID AND pp.ProviderID = bb.ReportingProviderID
  WHERE 1=1
	AND DATEFROMPARTS(bb.FiscalYear, bb.FiscalPeriod,1) between @StartDate and @EndDate
	AND (@Practice = '0' OR p.PracticeSourceID = @Practice)
	--AND (@SpecialFilter = '0' or b.ReportGroupLevel4 = @SpecialFilter)
	AND ((@Practice <> 'EKK' AND (@SpecialFilter = '0' OR bb.ReportGroupLevel4 = @SpecialFilter))
			OR (
				(@Practice = 'EKK' AND @SpecialFilter != 'NoPI' AND (@SpecialFilter = '0' OR bb.ReportGroupLevel4 = @SpecialFilter))
					OR 
				(@SpecialFilter = 'NoPI' AND ISNULL(bb.ReportGroupLevel4,'') <> 'PI')
				)
			) /*Special filter to remove PI activity from EKK's main Blue Book*/



OPTION (OPTIMIZE FOR UNKNOWN)
GO
