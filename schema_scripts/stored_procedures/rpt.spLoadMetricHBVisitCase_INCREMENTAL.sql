CREATE PROCEDURE [rpt].[spLoadMetricHBVisitCase_INCREMENTAL]	AS
BEGIN		
	-- =============================================
	-- Author:		Eric Silvestri
	-- Create date: 2-5-2025
	-- Edit date:   
	-- Description:	Generates the metric query for Visit Cases Metrics like on time start.
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
	AND MetricID = 20

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
	20												AS MetricID		 
	,CAST(dop.FirstDayOfMonth AS DATE)				AS MetricValueDate
	,vc.VisitCaseDatesourceID						AS DataSourceID
	,vc.VisitCaseLocationID							AS LocationID
	,v.VisitDepartmentID							AS [DepartmentID]
	,vc.VisitCasePrimaryProviderID					AS [ProviderID]
	,NULL											AS [PracticeID]
	,NULL											AS PayerID
	,s.ServiceLineName								AS ServiceLine
	,vc.VisitCaseFirstCaseofDay						AS [ReportGroup1] --First Case of Day
	,vc.VisitCaseOnTimeStartStatus					AS [ReportGroup2] --Case Start Status
	,vc.VisitCaseLateStart							AS [ReportGroup3] --Case Late Start
	,vc.VisitCaseAccuracyStatus						AS [ReportGroup4] --Case Accuracy
	,CASE WHEN vc.VisitCaseMinutesInOR > 0 
		THEN '1' ELSE '0' END						AS [ReportGroup5] --Mins in OR Flag
	,SUM(vc.VisitCaseMinutesLate)					AS [ReportGroup6] --Case Start Mins Late
	,SUM(vc.VisitCaseProcedureTurnoverDuration)		AS [ReportGroup7] --Procedure Turnonver Time
	,NULL											AS [MetricValueNumerator]
	,NULL											AS [MetricValueDenominator]
	,COUNT(vc.VisitCaseID)							AS [MetricValue]
	,GETDATE()										AS [UpdateDatetime] 
FROM [HPIDW].[fact].[vVisitCases] vc
	LEFT JOIN dim.Dates dop	ON FORMAT(vc.VisitCaseServiceDate, 'yyyy-dd-MM') = FORMAT(dop.[Date], 'yyyy-dd-MM')
	LEFT JOIN dim.Providers p ON vc.VisitCasePrimaryProviderID = p.ProviderID
	LEFT JOIN dim.ServiceLines s on s.ServiceLineID = vc.VisitCaseServiceLineID
	LEFT JOIN fact.vVisits2 v on v.VisitID = vc.VisitCaseVisitID

WHERE 1=1
	AND dop.[Date] between @QueryBeginDate and @QueryEndDate
	AND (v.VisitIsPrimary = 1 and v.VisitIsActive = 1)
GROUP BY
	dop.FirstDayOfMonth
	,vc.VisitCaseDatesourceID		
	,vc.VisitCaseLocationID		
	,v.VisitDepartmentID
	,vc.VisitCasePrimaryProviderID							
	,s.ServiceLineName		
	,vc.VisitCaseFirstCaseofDay		
	,vc.VisitCaseOnTimeStartStatus	
	,vc.VisitCaseLateStart			
    ,vc.VisitCaseAccuracyStatus		
	,vc.VisitCaseMinutesInOR
	
	END TRY
    BEGIN CATCH
        -- Capture and handle errors
        PRINT 'An error occurred during the execution of the procedure.'

    END CATCH
END
GO
