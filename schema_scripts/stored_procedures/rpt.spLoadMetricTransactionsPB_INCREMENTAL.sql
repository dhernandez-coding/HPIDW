CREATE PROCEDURE  [rpt].[spLoadMetricTransactionsPB_INCREMENTAL]	AS
BEGIN		
	-- =============================================
	-- Author:		Robert Beaird
	-- Create date: 6-26-2024
	-- Edit date:   
	--	1. 9/4/24 - Chris Cross - Replaced fact.Transactions2 with fact.TransactionsPB
	-- Description:	Generates the metric query for Transactions.
	-- =============================================
DECLARE @QueryLookbackMonths int = 1 --use 1 month for monthly load or 3 for monthly reload with lookback
DECLARE @QueryBeginDate date = '2023-01-01' -- DATEADD(MONTH,-1,DATEFROMPARTS(YEAR(DATEADD(MONTH,-@QueryLookbackMonths,GETDATE())),MONTH(DATEADD(MONTH,-@QueryLookbackMonths,GETDATE())),1))  -- '2023-01-01' --
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
		AND MetricID IN (2,3,4)

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
	CASE
		WHEN t.TransactionType = 'Charge'
			THEN 2
		WHEN t.TransactionType = 'Payment'
			THEN 4
		WHEN t.TransactionType = 'Adjustment'
			THEN 3
	END											AS MetricID	
	,drp.FirstDayOfMonth						AS MetricValueDate
	,t.TransactionDataSourceID					AS DataSourceID
	,t.TransactionVisitLocationID				AS LocationID --COALESCE(t.TransactionVisitLocationID,a.AccountLocationID,d.DepartmentLocationID)
	,t.TransactionDepartmentID					AS [DepartmentID]
	,t.TransactionBillingProviderID				AS [ProviderID] --,a.AccountPrimaryProviderID
	,t.TransactionPracticeID					AS [PracticeID] --COALESCE(ppt.PracticeID,ppa.PracticeID,pd.PracticeID,ppy.PracticeID)
	,t.TransactionPayerID						AS [PayerID]
	,null										AS [ServiceLine]
	,CASE
		WHEN t.TransactionCPTCode BETWEEN '00100' AND '00222' THEN 'HEAD'
		WHEN t.TransactionCPTCode BETWEEN '00300' AND '00352' THEN 'NECK'
		WHEN t.TransactionCPTCode BETWEEN '00400' AND '00474' THEN 'THORAX'
		WHEN t.TransactionCPTCode BETWEEN '00500' AND '00580' THEN 'INTRATHORACIC'
		WHEN t.TransactionCPTCode BETWEEN '00600' AND '00670' THEN 'SPINE AND SPINAL CORD'
		WHEN t.TransactionCPTCode BETWEEN '00700' AND '00797' THEN 'UPPPER ABDOMEN'
		WHEN t.TransactionCPTCode BETWEEN '00800' AND '00882' THEN 'LOWER ABDOMEN'
		WHEN t.TransactionCPTCode BETWEEN '00902' AND '00952' THEN 'PERINEUM'
		WHEN t.TransactionCPTCode BETWEEN '01112' AND '01173' THEN 'PELVIS'
		WHEN t.TransactionCPTCode BETWEEN '01200' AND '01274' THEN 'UPPER LEG'
		WHEN t.TransactionCPTCode BETWEEN '01320' AND '01444' THEN 'KNEE AREA'
		WHEN t.TransactionCPTCode BETWEEN '01462' AND '01522' THEN 'LOWER LEG'
		WHEN t.TransactionCPTCode BETWEEN '01610' AND '01680' THEN 'SHOULDER AND AXILLA'
		WHEN t.TransactionCPTCode BETWEEN '01710' AND '01782' THEN 'UPPER ARM AND ELBOW'
		WHEN t.TransactionCPTCode BETWEEN '01810' AND '01860' THEN 'FOREARM, WRIST, HAND'
		WHEN t.TransactionCPTCode BETWEEN '01916' AND '01942' THEN 'RADIOLOGICAL PROCEDURE'
		WHEN t.TransactionCPTCode BETWEEN '01951' AND '01953' THEN 'BURN EXCISIONS OR DEBRIDGEMENT'
		WHEN t.TransactionCPTCode BETWEEN '01958' AND '01969' THEN 'OBSTETRIC'
		WHEN t.TransactionCPTCode IS NULL THEN NULL
		ELSE 'OTHER'
	END											AS [ReportGroup1] -- Anesthesia procedure group
	,p.ProviderSuffix							AS [ReportGroup2] -- Provider role
	,null										AS [ReportGroup3]
	,null										AS [ReportGroup4]
	,null										AS [ReportGroup5]
	,null										AS [ReportGroup6]
	,null										AS [ReportGroup7]
	,null										AS [MetricValueNumerator]
	,null										AS [MetricValueDenominator]
	,sum(t.TransactionAmount)					AS [MetricValue]
	,GETDATE()									AS [UpdateDatetime]
FROM fact.vTransactionsPB t

LEFT JOIN dim.Dates dop
	ON FORMAT(t.TransactionDateOfPosting, 'yyyy-dd-MM') = FORMAT(dop.[Date], 'yyyy-dd-MM')
LEFT JOIN dim.Dates drp
	ON DATEFROMPARTS(LEFT(t.TransactionReportPeriodDate,4),RIGHT(t.TransactionReportPeriodDate,2),1) = drp.[Date]
--LEFT JOIN fact.Accounts a
--	ON t.TransactionAccountID = a.AccountID
--LEFT JOIN map.vPracticeProviders ppt
--	ON t.TransactionBillingProviderID = ppt.ProviderID
--LEFT JOIN map.vPracticeProviders ppa
--	ON a.AccountPrimaryProviderID = ppa.ProviderID
--LEFT JOIN map.PracticeDepartments pd
--	ON t.TransactionDepartmentID = pd.DepartmentID
--LEFT JOIN map.ProviderLinking pl
--	ON t.TransactionBillingProviderID = pl.ChildProviderID
--LEFT JOIN map.vPracticeProviders ppy
--	ON pl.ParentProviderID = ppy.ProviderID 
--LEFT JOIN dim.Departments d
--	on t.TransactionDepartmentID = d.DepartmentID
--LEFT JOIN dim.datasources ds
--	ON t.TransactionDataSource = ds.DataSourceName
LEFT JOIN dim.vProviders p
	ON t.TransactionBillingProviderID = p.ProviderID


WHERE 1=1
	AND t.TransactionType IN ('Charge','Adjustment','Payment')
	AND dop.[Date] between @QueryBeginDate and @QueryEndDate
	--and COALESCE(ppt.PracticeID,ppa.PracticeID,pd.PracticeID) is null

GROUP BY
	CASE
		WHEN t.TransactionType = 'Charge'
			THEN 2
		WHEN t.TransactionType = 'Payment'
			THEN 4
		WHEN t.TransactionType = 'Adjustment'
			THEN 3
	END							
	,drp.FirstDayOfMonth		
	,t.TransactionDataSourceID		
	,t.TransactionVisitLocationID	
	,t.TransactionDepartmentID		
	,t.TransactionBillingProviderID	
	,t.TransactionPracticeID		
	,t.TransactionPayerID
	,t.TransactionBillingType
	,CASE
		WHEN t.TransactionCPTCode BETWEEN '00100' AND '00222' THEN 'HEAD'
		WHEN t.TransactionCPTCode BETWEEN '00300' AND '00352' THEN 'NECK'
		WHEN t.TransactionCPTCode BETWEEN '00400' AND '00474' THEN 'THORAX'
		WHEN t.TransactionCPTCode BETWEEN '00500' AND '00580' THEN 'INTRATHORACIC'
		WHEN t.TransactionCPTCode BETWEEN '00600' AND '00670' THEN 'SPINE AND SPINAL CORD'
		WHEN t.TransactionCPTCode BETWEEN '00700' AND '00797' THEN 'UPPPER ABDOMEN'
		WHEN t.TransactionCPTCode BETWEEN '00800' AND '00882' THEN 'LOWER ABDOMEN'
		WHEN t.TransactionCPTCode BETWEEN '00902' AND '00952' THEN 'PERINEUM'
		WHEN t.TransactionCPTCode BETWEEN '01112' AND '01173' THEN 'PELVIS'
		WHEN t.TransactionCPTCode BETWEEN '01200' AND '01274' THEN 'UPPER LEG'
		WHEN t.TransactionCPTCode BETWEEN '01320' AND '01444' THEN 'KNEE AREA'
		WHEN t.TransactionCPTCode BETWEEN '01462' AND '01522' THEN 'LOWER LEG'
		WHEN t.TransactionCPTCode BETWEEN '01610' AND '01680' THEN 'SHOULDER AND AXILLA'
		WHEN t.TransactionCPTCode BETWEEN '01710' AND '01782' THEN 'UPPER ARM AND ELBOW'
		WHEN t.TransactionCPTCode BETWEEN '01810' AND '01860' THEN 'FOREARM, WRIST, HAND'
		WHEN t.TransactionCPTCode BETWEEN '01916' AND '01942' THEN 'RADIOLOGICAL PROCEDURE'
		WHEN t.TransactionCPTCode BETWEEN '01951' AND '01953' THEN 'BURN EXCISIONS OR DEBRIDGEMENT'
		WHEN t.TransactionCPTCode BETWEEN '01958' AND '01969' THEN 'OBSTETRIC'
		WHEN t.TransactionCPTCode IS NULL THEN NULL
		ELSE 'OTHER'
	END
	,p.ProviderSuffix

;END TRY
BEGIN CATCH
	PRINT ERROR_MESSAGE()
	PRINT 'ROLLING BACK DELETION'
	ROLLBACK;
END CATCH;

	
END
GO
