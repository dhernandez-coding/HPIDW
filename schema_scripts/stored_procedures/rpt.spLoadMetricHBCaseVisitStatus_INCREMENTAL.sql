CREATE PROCEDURE [rpt].[spLoadMetricHBCaseVisitStatus_INCREMENTAL]	AS
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
	AND MetricID = 15

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
	15									AS MetricID		 
	,CAST(dop.FirstDayOfMonth AS DATE)	AS MetricValueDate
	,cs.CaseScheduleDataSourceID		AS DataSourceID
	,cs.CaseScheduleLocationID			AS LocationID
	,v.VisitDepartmentID				AS [DepartmentID]
	,cs.CaseScheduleProviderID			AS [ProviderID]
	,NULL								AS [PracticeID]
	,NULL								AS PayerID
	,s.ServiceLineName					AS ServiceLine
	,cs.CaseScheduleStatus				AS [ReportGroup1] --Schedule Status
	,p.ProviderSuffix					AS [ReportGroup2] --Provider role
	,cs.CaseScheduleCancellationReason	AS [ReportGroup3] --Cancellation Reason
	,cs.CaseSchedueVisitType			AS [ReportGroup4] --Visit Type
	,cs.CaseScheduleVisitClass			AS [ReportGroup5] --Visit Class
	,cs.CaseSchedulePrimaryProcedure	AS [ReportGroup6] --Primary Procedure
	,cs.CaseScheduleDateOfCancellation	AS [ReportGroup7] --Cancellation Date
	,null								AS [MetricValueNumerator]
	,null								AS [MetricValueDenominator]
	,SUM(cs.CaseScheduleVisitVolume)	AS [MetricValue]
	,GETDATE()							AS [UpdateDatetime] 
FROM [HPIDW].[fact].[CaseSchedule] cs
	LEFT JOIN fact.vVisitCases vc on  vc.VisitCaseID = cs.CaseScheduleID
	LEFT JOIN dim.ServiceLines s on s.ServiceLineID = vc.VisitCaseServiceLineID
	LEFT JOIN fact.vVisits2 v on v.VisitID = vc.VisitCaseVisitID
	LEFT JOIN dim.Dates dop	ON FORMAT(vc.VisitCaseServiceDate, 'yyyy-dd-MM') = FORMAT(dop.[Date], 'yyyy-dd-MM')
	LEFT JOIN dim.Providers p ON cs.CaseScheduleProviderID = p.ProviderID


WHERE 1=1
	AND dop.[Date] between @QueryBeginDate and @QueryEndDate
	AND (v.VisitIsPrimary = 1 and v.VisitIsActive = 1)
	--and vc.VisitCaseServiceDate between '2024-12-01' and '2024-12-31'
GROUP BY
	dop.FirstDayOfMonth
	,cs.CaseScheduleDataSourceID
	,cs.CaseScheduleLocationID	
	,v.VisitDepartmentID	
	,cs.CaseScheduleProviderID						
	,s.ServiceLineName	
	,cs.CaseScheduleStatus
	,p.ProviderSuffix
	,cs.CaseScheduleCancellationReason
	,cs.CaseSchedueVisitType		
	,cs.CaseScheduleVisitClass		
	,cs.CaseSchedulePrimaryProcedure
	,cs.CaseScheduleDateOfCancellation

    END TRY
    BEGIN CATCH
        -- Capture and handle errors
        PRINT 'An error occurred during the execution of the procedure.'

    END CATCH
END
GO
