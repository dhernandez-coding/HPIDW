CREATE PROCEDURE [rpt].[spLoadMetricAvgDailyCharges_INCREMENTAL]	AS
BEGIN		
-- =============================================
-- Author:		Robert Beaird
-- Create date: 6-26-2024
-- Edit date:   
-- Description:	Generates the metric query for Average Daily Charges.
-- =============================================
DECLARE @QueryLookbackMonths int = 3 --use 1 month for monthly load or 3 for monthly reload with lookback
DECLARE @QueryEndDate date = EOMONTH(DATEADD(MONTH,-1,GETDATE()))
DECLARE @QueryBeginDate date = DATEADD(DAY,1,DATEADD(MONTH,-@QueryLookbackMonths,@QueryEndDate))
DECLARE @DeleteMessage varchar(200) = 'Deleting duplicate metric values between ' + CAST(@QueryBeginDate AS varchar(20)) + ' & ' + CAST(@QueryEndDate AS varchar(20))
DECLARE @InsertMessage varchar(200) = 'Inserting new metric values between ' + CAST(@QueryBeginDate AS varchar(20)) + ' & ' + CAST(@QueryEndDate AS varchar(20))
PRINT @DeleteMessage

BEGIN TRY
------------------------------------------------------------------------------------------------------------
/* Delete dupicate metric values */
------------------------------------------------------------------------------------------------------------

PRINT @DeleteMessage
DELETE rpt.MetricValues
	WHERE 1=1
	AND MetricValueDate >= @QueryEndDate 
	AND MetricID = 10

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
	10											AS MetricID		 
	,d.FirstDayOfMonth							AS MetricValueDate --	
	,m.DataSourceID								AS DataSourceID
	,m.LocationID								AS LocationID
	,m.DepartmentID								AS [DepartmentID]
	,m.ProviderID								AS [ProviderID]
	,m.PracticeID								AS [PracticeID]
	,m.PayerID									AS PayerID
	,m.ServiceLine								AS ServiceLine
	,m.ReportGroup1								AS [ReportGroup1]
	,m.ReportGroup2								AS [ReportGroup2] 
	,m.ReportGroup3								AS [ReportGroup3]
	,m.ReportGroup4								AS [ReportGroup4]
	,m.ReportGroup5								AS [ReportGroup5]
	,m.ReportGroup6								AS [ReportGroup6]
	,m.ReportGroup7								AS [ReportGroup7]
	,sum(m.MetricValue)							AS [MetricValueNumerator]
	,DATEDIFF(D,m.MetricValueDate,@QueryEndDate) + 1	AS [MetricValueDenominator]
	,sum(m.MetricValue) / (DATEDIFF(D,m.MetricValueDate,@QueryEndDate) + 1)	AS [MetricValue]
	,CONVERT(date,GETDATE())					AS [UpdateDatetime] 
FROM rpt.MetricValues m

--FROM fact.vTransactionsPB t

--LEFT JOIN fact.Accounts a 
--	ON t.TransactionAccountID = a.AccountID
LEFT JOIN dim.Dates d
	ON FORMAT(@QueryEndDate, 'yyyy-dd-MM') = FORMAT(d.[Date], 'yyyy-dd-MM')
--LEFT JOIN dim.dates gd
--	ON FORMAT(GETDATE(), 'yyyy-dd-MM') = FORMAT(gd.[Date], 'yyyy-dd-MM')

WHERE 1=1
	--AND t.TransactionParentSourceID NOT LIKE '%VOID%'
	AND m.MetricValueDate between @QueryBeginDate and @QueryEndDate
	AND m.MetricID = 2 -- charges only
	and m.MetricValue > 0

GROUP BY
	d.FirstDayOfMonth
	,m.DataSourceID	
	,m.LocationID	
	,m.DepartmentID	
	,m.ProviderID	
	,m.PracticeID	
	,m.PayerID		
	,m.ServiceLine	
	,m.ReportGroup1	
	,m.ReportGroup2	
	,m.ReportGroup3	
	,m.ReportGroup4	
	,m.ReportGroup5	
	,m.ReportGroup6	
	,m.ReportGroup7	
	,DATEDIFF(D,m.MetricValueDate,@QueryEndDate)

UNION

SELECT 
	10											AS MetricID		 
	,DATEADD(MONTH,1,d.FirstDayOfMonth)			AS MetricValueDate --	
	,m.DataSourceID								AS DataSourceID
	,m.LocationID								AS LocationID
	,m.DepartmentID								AS [DepartmentID]
	,m.ProviderID								AS [ProviderID]
	,m.PracticeID								AS [PracticeID]
	,m.PayerID									AS PayerID
	,m.ServiceLine								AS ServiceLine
	,m.ReportGroup1								AS [ReportGroup1]
	,m.ReportGroup2								AS [ReportGroup2] 
	,m.ReportGroup3								AS [ReportGroup3]
	,m.ReportGroup4								AS [ReportGroup4]
	,m.ReportGroup5								AS [ReportGroup5]
	,m.ReportGroup6								AS [ReportGroup6]
	,m.ReportGroup7								AS [ReportGroup7]
	,sum(m.MetricValue)							AS [MetricValueNumerator]
	,DATEDIFF(D,m.MetricValueDate,@QueryEndDate)	AS [MetricValueDenominator]
	,sum(m.MetricValue) / DATEDIFF(D,m.MetricValueDate,@QueryEndDate)	AS [MetricValue]
	,CONVERT(date,GETDATE())					AS [UpdateDatetime] 
FROM rpt.MetricValues m

--FROM fact.vTransactionsPB t

--LEFT JOIN fact.Accounts a 
--	ON t.TransactionAccountID = a.AccountID
LEFT JOIN dim.Dates d
	ON FORMAT(@QueryEndDate, 'yyyy-dd-MM') = FORMAT(d.[Date], 'yyyy-dd-MM')
--LEFT JOIN dim.dates gd
--	ON FORMAT(GETDATE(), 'yyyy-dd-MM') = FORMAT(gd.[Date], 'yyyy-dd-MM')

WHERE 1=1
	--AND t.TransactionParentSourceID NOT LIKE '%VOID%'
	AND m.MetricValueDate between @QueryBeginDate and @QueryEndDate
	AND m.MetricID = 2 -- charges only
	and m.MetricValue > 0

GROUP BY
	d.FirstDayOfMonth
	,m.DataSourceID	
	,m.LocationID	
	,m.DepartmentID	
	,m.ProviderID	
	,m.PracticeID	
	,m.PayerID		
	,m.ServiceLine	
	,m.ReportGroup1	
	,m.ReportGroup2	
	,m.ReportGroup3	
	,m.ReportGroup4	
	,m.ReportGroup5	
	,m.ReportGroup6	
	,m.ReportGroup7	
	,DATEDIFF(D,m.MetricValueDate,@QueryEndDate)

;END TRY
BEGIN CATCH
	PRINT ERROR_MESSAGE()
	PRINT 'ROLLING BACK DELETION'
	ROLLBACK;
END CATCH;

	
END
GO
