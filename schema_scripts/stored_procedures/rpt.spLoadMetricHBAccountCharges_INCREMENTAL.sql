CREATE PROCEDURE [rpt].[spLoadMetricHBAccountCharges_INCREMENTAL]	AS
BEGIN		
	-- =============================================
	-- Author:		Eric Silvestri
	-- Create date: 1-28-2025
	-- Edit date:   
	-- Description:	Generates the metric query for HB Accounts.
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
	AND MetricID = 19

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
	19									AS MetricID		 
	,CAST(dop.FirstDayOfMonth AS DATE)	AS MetricValueDate
	,a.AccountDataSourceID				AS DataSourceID
	,a.AccountLocationID				AS LocationID
	,a.AccountDepartmentID				AS [DepartmentID]
	,a.AccountPrimaryProviderID			AS [ProviderID]
	,NULL								AS [PracticeID]
	,a.AccountPrimaryPayerID			AS PayerID
	,NULL								AS ServiceLine
	,a.AccountBillingStatus				AS [ReportGroup1] --Billing Status
	,a.AccountStatus					AS [ReportGroup2] --Account Status
	,a.AccountClass						AS [ReportGroup3] --Account Class
	,a.AccountType						AS [ReportGroup4] --Account Type
	,CASE WHEN a.AccountDateOfService >= DATEADD(DAY, -90, GETDATE()) THEN 1 
        ELSE 0 
			END 						AS [ReportGroup5] --Rolling 90 Day Flag
	,NULL								AS [ReportGroup6]
	,NULL								AS [ReportGroup7]
	,null								AS [MetricValueNumerator]
	,null								AS [MetricValueDenominator]
	,SUM(a.AccountTotalCharges)			AS [MetricValue]
	,GETDATE()							AS [UpdateDatetime] 
FROM [HPIDW].[fact].vAccounts a
	LEFT JOIN dim.Dates dop	ON FORMAT(a.AccountDateOfService, 'yyyy-dd-MM') = FORMAT(dop.[Date], 'yyyy-dd-MM')
	LEFT JOIN dim.Providers p ON a.AccountPrimaryProviderID = p.ProviderID


WHERE 1=1
	AND dop.[Date] between @QueryBeginDate and @QueryEndDate
	AND a.AccountIsActive = 1
	--and vc.VisitCaseServiceDate between '2024-12-01' and '2024-12-31'
GROUP BY
	dop.FirstDayOfMonth
	,a.AccountDataSourceID			
	,a.AccountLocationID		
	,a.AccountDepartmentID	
	,a.AccountPrimaryProviderID
	,a.AccountPrimaryPayerID	
	,a.AccountBillingStatus			
	,a.AccountStatus				
	,a.AccountClass	
	,a.AccountDateOfService
	,a.AccountType												

    END TRY
    BEGIN CATCH
        -- Capture and handle errors
        PRINT 'An error occurred during the execution of the procedure.'

    END CATCH
END
GO
