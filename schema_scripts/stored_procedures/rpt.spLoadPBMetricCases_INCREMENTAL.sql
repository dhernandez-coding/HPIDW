CREATE PROCEDURE [rpt].[spLoadPBMetricCases_INCREMENTAL]	AS
BEGIN		
	-- =============================================
	-- Author:		Robert Beaird
	-- Create date: 6-26-2024
	-- Edit date:   
	-- Description:	Generates the metric query for Cases.
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
	AND MetricID = 7

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
	7									AS MetricID		 
	,CAST(dop.FirstDayOfMonth AS DATE)	AS MetricValueDate
	,t.TransactionDatasourceID			AS DataSourceID
	,t.TransactionVisitLocationID		AS LocationID
	,t.TransactionDepartmentID			AS [DepartmentID]
	,t.TransactionBillingProviderID		AS [ProviderID]
	,t.TransactionPracticeID			AS [PracticeID]
	,t.ChargePayerID					AS PayerID
	,null								AS ServiceLine
	,null								AS [ReportGroup1]
	,p.ProviderSuffix					AS [ReportGroup2] -- Provider role
	,null								AS [ReportGroup3]
	,null								AS [ReportGroup4]
	,null								AS [ReportGroup5]
	,null								AS [ReportGroup6]
	,null								AS [ReportGroup7]
	,null								AS [MetricValueNumerator]
	,null								AS [MetricValueDenominator]
	,COUNT(*)							AS [MetricValue]
	,GETDATE()							AS [UpdateDatetime] 
FROM fact.vPBCharges t

--LEFT JOIN fact.Accounts a ON t.TransactionAccountID = a.AccountID
LEFT JOIN dim.Dates dop	ON FORMAT(t.TransactionDateOfPosting, 'yyyy-dd-MM') = FORMAT(dop.[Date], 'yyyy-dd-MM')
LEFT JOIN dim.vProviders p ON t.TransactionBillingProviderID = p.ProviderID
--LEFT JOIN dim.dates gd
--	ON FORMAT(GETDATE(), 'yyyy-dd-MM') = FORMAT(gd.[Date], 'yyyy-dd-MM')

WHERE 1=1
	AND t.TransactionType IN ('Charge')
	--AND t.TransactionParentSourceID NOT LIKE '%VOID%'
	AND dop.[Date] between @QueryBeginDate and @QueryEndDate
GROUP BY
	dop.FirstDayOfMonth
	,t.TransactionDatasourceID
	,t.TransactionVisitLocationID
	,t.TransactionDepartmentID				
	,t.TransactionBillingProviderID	
	,t.TransactionPracticeID
	,t.ChargePayerID
	,p.ProviderSuffix

;END TRY
BEGIN CATCH
	PRINT ERROR_MESSAGE()
	PRINT 'ROLLING BACK DELETION'
	ROLLBACK;
END CATCH;

	
END
GO
