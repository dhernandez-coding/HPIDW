CREATE PROCEDURE [rpt].[spLoadMetricHBImagingUnits_INCREMENTAL]	AS
BEGIN		
	-- =============================================
	-- Author:		Eric Silvestri
	-- Create date: 1-28-2025
	-- Edit date:   
	-- Description:	Generates the metric query for HB Imaging Units.
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
	AND MetricID = 17

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
	17									AS MetricID		 
	,CAST(dop.FirstDayOfMonth AS DATE)	AS MetricValueDate
	,t.TransactionDatasourceID			AS DataSourceID
	,a.AccountLocationID				AS LocationID
	,t.TransactionDepartmentID			AS [DepartmentID]
	,t.TransactionBillingProviderID		AS [ProviderID]
	,NULL								AS [PracticeID]
	,t.TransactionPayerID				AS PayerID
	,s.ServiceLineName					AS ServiceLine
	,NULL								AS [ReportGroup1]
	,p.ProviderSuffix					AS [ReportGroup2] -- Provider role
	,TransactionIsMRICharge				AS [ReportGroup3] --MRI Flag
    ,TransactionIsCTCharge				AS [ReportGroup4] --CT Flag
    ,TransactionIsUltrasoundCharge		AS [ReportGroup5] --US Flag														
	,null								AS [ReportGroup6]
	,null								AS [ReportGroup7]
	,null								AS [MetricValueNumerator]
	,null								AS [MetricValueDenominator]
	,SUM(t.TransactionUnits)			AS [MetricValue]
	,GETDATE()							AS [UpdateDatetime] 
FROM fact.vTransactions2 t

LEFT JOIN fact.Accounts a ON t.TransactionAccountID = a.AccountID
LEFT JOIN dim.Dates dop ON FORMAT(t.TransactionDateOfPosting, 'yyyy-dd-MM') = FORMAT(dop.[Date], 'yyyy-dd-MM')
LEFT JOIN dim.providers p ON t.TransactionBillingProviderID = p.ProviderID
LEFT JOIN dim.ServiceLines s on s.ServiceLineID = t.TransactionImagingType
WHERE 1=1
	AND t.TransactionType IN ('Charge')
	AND (t.TransactionIsMRICharge = 'Yes' or t.TransactionIsCTCharge	= 'Yes' or t.TransactionIsUltrasoundCharge = 'Yes')
	--AND t.TransactionParentSourceID NOT LIKE '%VOID%'
	AND dop.[Date] between @QueryBeginDate and @QueryEndDate

GROUP BY
	dop.FirstDayOfMonth
	,t.TransactionDatasourceID	
	,a.AccountLocationID	
	,t.TransactionDepartmentID		
	,t.TransactionBillingProviderID							
	,t.TransactionPayerID	
	,s.ServiceLineName
	,p.ProviderSuffix				
	,TransactionIsMRICharge	
	,TransactionIsCTCharge	
	,TransactionIsUltrasoundCharge
			

;END TRY
BEGIN CATCH
	PRINT ERROR_MESSAGE()
	PRINT 'ROLLING BACK DELETION'
	ROLLBACK;
END CATCH;

	
END
GO
