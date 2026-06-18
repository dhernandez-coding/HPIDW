CREATE PROCEDURE rpt.spLoadMetricARDays_INCREMENTAL	AS
BEGIN		
	-- =============================================
	-- Author:		Robert Beaird
	-- Create date: 6-26-2024
	-- Edit date:   
	-- Description:	Generates the metric query for AR days.
	-- =============================================
DECLARE @QueryLookbackMonths int = 3 --use 1 month for monthly load or 3 for monthly reload with lookback
DECLARE @QueryBeginDate date = DATEADD(MONTH,-1,DATEFROMPARTS(YEAR(DATEADD(MONTH,-@QueryLookbackMonths,GETDATE())),MONTH(DATEADD(MONTH,-@QueryLookbackMonths,GETDATE())),1)) 
DECLARE @QueryEndDate date = GETDATE() 
DECLARE @DeleteMessage varchar(200) = 'Deleting duplicate metric values between ' + CAST(@QueryBeginDate AS varchar(20)) + ' & ' + CAST(@QueryEndDate AS varchar(20))
DECLARE @InsertMessage varchar(200) = 'Inserting new metric values between ' + CAST(@QueryBeginDate AS varchar(20)) + ' & ' + CAST(@QueryEndDate AS varchar(20))

BEGIN TRY
------------------------------------------------------------------------------------------------------------
/* Delete dupicate metric values */
------------------------------------------------------------------------------------------------------------

PRINT @DeleteMessage
DELETE rpt.MetricValues
	WHERE 1=1
	AND MetricValueDate >= @QueryBeginDate 
	AND MetricID = 9

------------------------------------------------------------------------------------------------------------
/* Insert new metric values */
------------------------------------------------------------------------------------------------------------

PRINT @InsertMessage
INSERT INTO rpt.MetricValues(
    [MetricID]
    ,[MetricValueDate]
    ,[DataSourceID]
    ,[LocationID]
    ,[DepartmentID]
    ,[ProviderID]
    ,[PracticeID]
    ,[PayerID]
    ,[ServiceLine]
    ,[ReportGroup1]
    ,[ReportGroup2]
    ,[ReportGroup3]
    ,[ReportGroup4]
    ,[ReportGroup5]
    ,[ReportGroup6]
    ,[ReportGroup7]
    ,[MetricValueNumerator]
    ,[MetricValueDenominator]
    ,[MetricValue]
    ,[UpdateDatetime]
)


SELECT 
	9										AS MetricID		 
	,m.MetricValueDate						AS MetricValueDate
	,m.DataSourceID							AS DataSourceID
	,m.LocationID							AS LocationID
	,m.DepartmentID							AS [DepartmentID]
	,m.ProviderID							AS [ProviderID]
	,m.PracticeID							AS [PracticeID]
	,m.PayerID								AS PayerID
	,m.ServiceLine							AS ServiceLine
	,m2.ReportGroup1						AS [ReportGroup1]
	,m2.ReportGroup2						AS [ReportGroup2] 
	,m2.ReportGroup3						AS [ReportGroup3]
	,m2.ReportGroup4						AS [ReportGroup4]
	,m2.ReportGroup5						AS [ReportGroup5]
	,m2.ReportGroup6						AS [ReportGroup6]
	,m2.ReportGroup7						AS [ReportGroup7]
	,sum(m.MetricValue)						AS [MetricValueNumerator] -- Current Active AR
	,sum(m2.MetricValue)					AS [MetricValueDenominator] -- Avg Daily Charges = avg charge agmount per day over the last 90 days
	,sum(m.metricvalue)	/ sum(m2.MetricValue)	AS [MetricValue]
	,GETDATE()								AS [UpdateDatetime] 
FROM rpt.MetricValues m -- Total AR

	
--FROM rpt.ARCurrentPB ar
FULL OUTER JOIN rpt.MetricValues m2 -- Average Daily Charges
	ON m.DataSourceID = m2.DataSourceID
		--AND m.MetricValueDate = m2.MetricValueDate
		AND m.LocationID = m2.LocationID
		AND m.DepartmentID = m2.DepartmentID
		AND m.ProviderID = m2.ProviderID
		AND m.PracticeID = m2.PracticeID
		AND m.PayerID = m2.PayerID
		--AND m.ServiceLine = m2.ServiceLine
		--AND m.ReportGroup1 = m2.ReportGroup1 --ignore aging buckets
		--AND m.ReportGroup2 = m2.ReportGroup2 -- ignore period category
		--AND m.ReportGroup3 = m2.ReportGroup3
		--AND m.ReportGroup4 = m2.ReportGroup4
		--AND m.ReportGroup5 = m2.ReportGroup5
		--AND m.ReportGroup6 = m2.ReportGroup6
		--AND m.ReportGroup7 = m2.ReportGroup7
		AND m2.MetricID = 10
--LEFT JOIN dim.Dates d
--	ON FORMAT(ar.ARHistoryDate, 'yyyy-dd-MM') = FORMAT(d.[Date], 'yyyy-dd-MM')
--LEFT JOIN dim.dates gd
--	ON FORMAT(GETDATE(), 'yyyy-dd-MM') = FORMAT(gd.[Date], 'yyyy-dd-MM')

WHERE 1=1
	AND m.MetricID = 5 -- Total AR
	AND m.MetricValueDate between @QueryBeginDate and @QueryEndDate
	AND m2.MetricValueDate between @QueryBeginDate and @QueryEndDate

GROUP BY
	m.MetricValueDate
	,m.DataSourceID	
	,m.LocationID	
	,m.DepartmentID	
	,m.ProviderID	
	,m.PracticeID	
	,m.PayerID		
	,m.ServiceLine	
	,m2.ReportGroup1	
	,m2.ReportGroup2	
	,m2.ReportGroup3	
	,m2.ReportGroup4	
	,m2.ReportGroup5	
	,m2.ReportGroup6	
	,m2.ReportGroup7

HAVING sum(m2.MetricValue) > 0


;END TRY
BEGIN CATCH
	PRINT ERROR_MESSAGE()
	PRINT 'ROLLING BACK DELETION'
	ROLLBACK;
END CATCH;

	
END
GO
