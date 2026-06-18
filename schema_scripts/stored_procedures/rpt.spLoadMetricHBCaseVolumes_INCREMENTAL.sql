CREATE PROCEDURE [rpt].[spLoadMetricHBCaseVolumes_INCREMENTAL]	AS
BEGIN		
	-- =============================================
	-- Author:		Eric Silvestri
	-- Create date: 1-28-2025
	-- Edit date:   
	-- Description:	Generates the metric query for Visit Cases volumes.
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
	AND MetricID = 18

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
	18									AS MetricID		 
	,CAST(dop.FirstDayOfMonth AS DATE)	AS MetricValueDate
	,vc.VisitCaseDatesourceID			AS DataSourceID
	,vc.VisitCaseLocationID				AS LocationID
	,v.VisitDepartmentID				AS [DepartmentID]
	,vc.VisitCasePrimaryProviderID		AS [ProviderID]
	,NULL								AS [PracticeID]
	,NULL								AS PayerID
	,s.ServiceLineName 					AS ServiceLine
	,vc.VisitCaseScheduleStatus			AS [ReportGroup1] --Schedule Status
	,p.ProviderSuffix					AS [ReportGroup2] 
	,vc.VisitCasePatientClass			AS [ReportGroup3] --Patient Class
	,vc.VisitCaseService				AS [ReportGroup4] --Service Line
	,vp.VisitProcedureDescription		AS [ReportGroup5] --Procedure
	,NULL								AS [ReportGroup6] 
	,NULL								AS [ReportGroup7] 
	,null								AS [MetricValueNumerator]
	,null								AS [MetricValueDenominator]
	,COUNT(DISTINCT(vc.VisitCaseID))	AS [MetricValue]
	,GETDATE()							AS [UpdateDatetime] 
FROM [HPIDW].[fact].[vVisitCases] vc
	LEFT JOIN dim.Dates dop	ON FORMAT(vc.VisitCaseServiceDate, 'yyyy-dd-MM') = FORMAT(dop.[Date], 'yyyy-dd-MM')
	LEFT JOIN dim.Providers p ON vc.VisitCasePrimaryProviderID = p.ProviderID
	LEFT JOIN dim.ServiceLines s on s.ServiceLineID = vc.VisitCaseServiceLineID
	LEFT JOIN fact.vVisits2 v on v.VisitID = vc.VisitCaseVisitID
	LEFT JOIN fact.vVisitProcedures vp on vp.VisitProcedureVisitID = vc.VisitCaseVisitID
											AND vp.VisitProcedureSequence = 1
WHERE 1=1
	AND dop.[Date] between @QueryBeginDate and @QueryEndDate
	AND (v.VisitIsPrimary = 1 and v.VisitIsActive = 1)
GROUP BY
	dop.FirstDayOfMonth
	,vc.VisitCaseDatesourceID		
	,vc.VisitCaseLocationID		
	,v.VisitDepartmentID
	,vc.VisitCasePrimaryProviderID							
	,vc.VisitCaseService			
	,vc.VisitCaseScheduleStatus		
	,p.ProviderSuffix				
	,vc.VisitCasePatientClass		
	,s.ServiceLineName	
	,vp.VisitProcedureDescription	
	,vc.VisitCaseID



    END TRY
    BEGIN CATCH
        -- Capture and handle errors
        PRINT 'An error occurred during the execution of the procedure.'

    END CATCH
END
GO
