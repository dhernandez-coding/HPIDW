CREATE PROCEDURE [rpt].[spLoadMetricHBBudgets_INCREMENTAL]	AS
BEGIN		
	-- =============================================
	-- Author:		Eric Silvestri
	-- Create date: 1-28-2025
	-- Edit date:   
	-- Description:	Generates the metric query for Visit Cases.
	-- =============================================

DECLARE @QueryLookbackMonths int = 1 --use 1 month for monthly load or 3 for monthly reload with lookback
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
	AND MetricID = 16

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
	16									AS MetricID		 
	,CAST(dop.FirstDayOfMonth AS DATE)	AS MetricValueDate
	,b.BudgetDatasourceID				AS DataSourceID
	,b.BudgetLocationID					AS LocationID
	,b.BudgetDepartmentID				AS [DepartmentID]
	,b.BudgetProviderID					AS [ProviderID]
	,NULL								AS [PracticeID]
	,NULL								AS PayerID
	,b.BudgetServiceLineName			AS ServiceLine
	,b.BudgetTypeName						AS [ReportGroup1] --Budget Type
	,NULL								AS [ReportGroup2]
	,NULL								AS [ReportGroup3]
	,NULL								AS [ReportGroup4]
	,NULL								AS [ReportGroup5]
	,NULL								AS [ReportGroup6]
	,NULL								AS [ReportGroup7]
	,null								AS [MetricValueNumerator]
	,null								AS [MetricValueDenominator]
	,SUM(b.BudgetValue)				AS [MetricValue]
	,GETDATE()							AS [UpdateDatetime] 
FROM [HPIDW].[fact].[vBudgets] b
	LEFT JOIN dim.Dates dop	ON FORMAT(b.BudgetDate, 'yyyy-dd-MM') = FORMAT(dop.[Date], 'yyyy-dd-MM')
	LEFT JOIN dim.Providers p ON b.BudgetProviderID	 = p.ProviderID

WHERE 1=1
	AND dop.[Date] between @QueryBeginDate and @QueryEndDate
GROUP BY
	dop.FirstDayOfMonth
	,b.BudgetDatasourceID	
	,b.BudgetLocationID		
	,b.BudgetDepartmentID	
	,b.BudgetProviderID				
	,b.BudgetServiceLineName
	,b.BudgetTypeName	

    END TRY
    BEGIN CATCH
        -- Capture and handle errors
        PRINT 'An error occurred during the execution of the procedure.'

    END CATCH
END
GO
