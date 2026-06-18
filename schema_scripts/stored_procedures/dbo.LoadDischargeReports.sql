CREATE Procedure [dbo].[LoadDischargeReports]
as

Create Table #ProcResult
(
results XML
)


delete from ComputedDischargeExports

Declare @startdate Datetime
Declare @enddate Datetime
Declare @Location int

DECLARE @MonthsToSubtract INT = -1; 
DECLARE @LastMonthBase DATE = DATEFROMPARTS(
    YEAR(DATEADD(MONTH, @MonthsToSubtract, GETDATE())), 
    MONTH(DATEADD(MONTH, @MonthsToSubtract, GETDATE())), 
    1
);

select @LastMonthBase
DECLARE @StartDay DATE = DATEFROMPARTS(YEAR(@LastMonthBase), MONTH(@LastMonthBase), 1);
DECLARE @StartMonth INT = MONTH(@StartDay);
DECLARE @StartYear INT = YEAR(@StartDay);



DECLARE @EndDay DATE = DATEADD(MONTH, 1, @StartDay);
DECLARE @EndMonth INT = MONTH(@EndDay);
DECLARE @EndYear INT = YEAR(@EndDay);

-- Verification Output
SELECT 
    @StartMonth AS StartMonth, 
    @StartYear AS StartYear, 
    @EndMonth AS EndMonth, 
    @EndYear AS EndYear,
    @StartDay AS [StartRange_Inclusive],
    @EndDay AS [EndRange_Exclusive];

SET @startdate = IsNull(@startdate, @StartDay);
SET @enddate = IsNull(@enddate, @EndDay);
select @startdate
select @enddate















DECLARE @reportingyear int = @StartYear
DECLARE @reportingperiod int = @StartMonth
SET @Location = 43004001

insert INTO #ProcResult
EXEC  [rpt].[spSelectStateDischargeReportOP] @Location=@Location, @startdate = @startdate, @enddate = @enddate

Insert into ComputedDischargeExports (LocationId, Period, Year, Value, Type)
VALUES(@Location,@reportingperiod, @reportingyear,
(select top 1 Cast(results as varchar(max)) from #ProcResult), 'OP'
)
Delete from #ProcResult

SET @Location = 43005005
insert INTO #ProcResult
EXEC  [rpt].[spSelectStateDischargeReportOP] @Location=@Location, @startdate = @startdate, @enddate = @enddate
Insert into ComputedDischargeExports (LocationId, Period, Year, Value, Type)
VALUES(@Location,@reportingperiod, @reportingyear,
(select top 1 Cast(results as varchar(max)) from #ProcResult), 'OP'
)
Delete from #ProcResult


SET @Location = 43006001
insert INTO #ProcResult
EXEC  [rpt].[spSelectStateDischargeReportOP] @Location=@Location, @startdate = @startdate, @enddate = @enddate
Insert into ComputedDischargeExports (LocationId, Period, Year, Value, Type)
VALUES(@Location,@reportingperiod, @reportingyear,
(select top 1 Cast(results as varchar(max)) from #ProcResult), 'OP'
)
Delete from #ProcResult




SET @Location = 43004001
insert INTO #ProcResult
EXEC  [rpt].[spSelectStateDischargeReportED] @Location=@Location, @startdate = @startdate, @enddate = @enddate

Insert into ComputedDischargeExports (LocationId, Period, Year, Value, Type)
VALUES(@Location,@reportingperiod, @reportingyear,
(select top 1 Cast(results as varchar(max)) from #ProcResult), 'ED'
)
Delete from #ProcResult

SET @Location = 43005005
insert INTO #ProcResult
EXEC  [rpt].[spSelectStateDischargeReportED] @Location=@Location, @startdate = @startdate, @enddate = @enddate
Insert into ComputedDischargeExports (LocationId, Period, Year, Value, Type)
VALUES(@Location,@reportingperiod, @reportingyear,
(select top 1 Cast(results as varchar(max)) from #ProcResult), 'ED'
)
Delete from #ProcResult


SET @Location = 43006001
insert INTO #ProcResult
EXEC  [rpt].[spSelectStateDischargeReportED] @Location=@Location, @startdate = @startdate, @enddate = @enddate
Insert into ComputedDischargeExports (LocationId, Period, Year, Value, Type)
VALUES(@Location,@reportingperiod, @reportingyear,
(select top 1 Cast(results as varchar(max)) from #ProcResult), 'ED'
)
Delete from #ProcResult

SET @Location = 43004001
insert INTO #ProcResult
EXEC  [rpt].[spSelectStateDischargeReportIP] @Location=@Location, @startdate = @startdate, @enddate = @enddate

Insert into ComputedDischargeExports (LocationId, Period, Year, Value, Type)
VALUES(@Location,@reportingperiod, @reportingyear,
(select top 1 Cast(results as varchar(max)) from #ProcResult), 'IP'
)
Delete from #ProcResult

SET @Location = 43005005
insert INTO #ProcResult
EXEC  [rpt].[spSelectStateDischargeReportIP] @Location=@Location, @startdate = @startdate, @enddate = @enddate
Insert into ComputedDischargeExports (LocationId, Period, Year, Value, Type)
VALUES(@Location,@reportingperiod, @reportingyear,
(select top 1 Cast(results as varchar(max)) from #ProcResult), 'IP'
)
Delete from #ProcResult


SET @Location = 43006001
insert INTO #ProcResult
EXEC  [rpt].[spSelectStateDischargeReportIP] @Location=@Location, @startdate = @startdate, @enddate = @enddate
Insert into ComputedDischargeExports (LocationId, Period, Year, Value, Type)
VALUES(@Location,@reportingperiod, @reportingyear,
(select top 1 Cast(results as varchar(max)) from #ProcResult), 'IP'
)
Delete from #ProcResult


DROP TABLE #ProcResult
GO
