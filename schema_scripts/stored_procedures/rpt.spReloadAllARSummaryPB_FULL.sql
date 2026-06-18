CREATE PROCEDURE [rpt].[spReloadAllARSummaryPB_FULL] AS
/* 
-- =============================================
-- Author:		Robert Beaird
-- Create date: May 29 2024  4:30PM
-- Edit date:   
-- Description:	Load for rpt.ARSummaryPB from HPIDW
-- ============================================= 
*/

--DECLARE @MaxHistoryDate DATE

--SELECT @MaxHistoryDate = MAX(ARHistoryDate) FROM [HPIDW].[rpt].[ARHistoryPB];

/* Delete historical records over 3 years old and ALL current records */

DELETE FROM [rpt].[ARSummaryPB]
WHERE [ARHistoryDate] < DATEADD(MONTH, -36, GETDATE())
	OR [PeriodCategory] = 'Current'

/* Previous Month Historic AR */

INSERT INTO [rpt].[ARSummaryPB](
	[ARHistoryDate]
    ,[TransactionDataSourceID]
    ,[TransactionDepartmentID]
    ,[CurrentFinancialClass]
    ,[CurrentPayerID]
    ,[TransactionBillingProviderID]
    ,[TransactionOriginalAmount]
    ,[TransactionARAmountAll]
    ,[TransactionARAmountSelfPay]
    ,[TransactionARAmountInsurance]
    ,[TransactionARAmountActive]
    ,[TransactionARAmountBadDebt]
    ,[TransactionARAgingBucketSort]
    ,[TransactionARAgingBucket]
    ,[IsARCredit]
    ,[PeriodCategory]
)

SELECT
	arh.ARHistoryDate
	,arh.TransactionDataSourceID
	,arh.TransactionDepartmentID
	,arh.CurrentFinancialClass
	,arh.CurrentPayerID
	,arh.TransactionBillingProviderID
	,SUM(arh.TransactionOriginalAmount) AS TransactionOriginalAmount
	,SUM(arh.TransactionARAmountAll) AS TransactionARAmountAll
	,SUM(arh.TransactionARAmountSelfPay) AS TransactionARAmountSelfPay
	,SUM(arh.TransactionARAmountInsurance) AS TransactionARAmountInsurance
	,SUM(arh.TransactionARAmountActive) AS TransactionARAmountActive
	,SUM(arh.TransactionARAmountBadDebt) AS TransactionARAmountBadDebt
	,CASE
		WHEN arh.TransactionServiceDateAge BETWEEN 0 AND 30
			THEN '0'
		WHEN arh.TransactionServiceDateAge BETWEEN 31 AND 60 
			THEN '1'
		WHEN arh.TransactionServiceDateAge BETWEEN 61 AND 90 
			THEN '2'
		WHEN arh.TransactionServiceDateAge BETWEEN 91 AND 120 
			THEN '3'
		WHEN arh.TransactionServiceDateAge > 120 
			THEN '4'
		ELSE NULL
	END AS TransactionARAgingBucketSort
	,CASE
		WHEN arh.TransactionServiceDateAge BETWEEN 0 AND 30
			THEN '0-30'
		WHEN arh.TransactionServiceDateAge BETWEEN 31 AND 60 
			THEN '31-60'
		WHEN arh.TransactionServiceDateAge BETWEEN 61 AND 90 
			THEN '61-90'
		WHEN arh.TransactionServiceDateAge BETWEEN 91 AND 120 
			THEN '91-120'
		WHEN arh.TransactionServiceDateAge > 120 
			THEN '121+'
		ELSE NULL
	END AS TransactionARAgingBucket
	,CASE
		WHEN SUM(arh.[TransactionARAmountAll]) < 0
			THEN 1
		ELSE 0
	END AS IsARCredit
	,'Snapshot' AS PeriodCategory
FROM [HPIDW].[rpt].[ARHistoryPB] arh

/* limit insert to records from the previous month */

WHERE 1=1
	AND ARHistoryDate >= DATEFROMPARTS(YEAR(DATEADD(MONTH, -1, GETDATE())), MONTH(DATEADD(MONTH, -1, GETDATE())), 1)
    AND ARHistoryDate <= EOMONTH(DATEADD(MONTH, -1, GETDATE()))

GROUP BY 
	[ARHistoryDate]
	,[TransactionDataSourceID]
	,[TransactionDepartmentID]
	,[CurrentFinancialClass]
	,[CurrentPayerID]
	,[TransactionBillingProviderID]
	,CASE
		WHEN arh.TransactionServiceDateAge BETWEEN 0 AND 30
			THEN '0'
		WHEN arh.TransactionServiceDateAge BETWEEN 31 AND 60 
			THEN '1'
		WHEN arh.TransactionServiceDateAge BETWEEN 61 AND 90 
			THEN '2'
		WHEN arh.TransactionServiceDateAge BETWEEN 91 AND 120 
			THEN '3'
		WHEN arh.TransactionServiceDateAge > 120 
			THEN '4'
		ELSE NULL
	END
	,CASE
		WHEN arh.TransactionServiceDateAge BETWEEN 0 AND 30
			THEN '0-30'
		WHEN arh.TransactionServiceDateAge BETWEEN 31 AND 60 
			THEN '31-60'
		WHEN arh.TransactionServiceDateAge BETWEEN 61 AND 90 
			THEN '61-90'
		WHEN arh.TransactionServiceDateAge BETWEEN 91 AND 120 
			THEN '91-120'
		WHEN arh.TransactionServiceDateAge > 120 
			THEN '121+'
		ELSE NULL
	END
	
/* All Current AR */

UNION ALL

SELECT
	arc.ARHistoryDate
	,arc.TransactionDataSourceID
	,arc.TransactionDepartmentID
	,arc.CurrentFinancialClass
	,arc.CurrentPayerID
	,arc.TransactionBillingProviderID
	,SUM(arc.TransactionOriginalAmount) AS TransactionOriginalAmount
	,SUM(arc.TransactionARAmountAll) AS TransactionARAmountAll
	,SUM(arc.TransactionARAmountSelfPay) AS TransactionARAmountSelfPay
	,SUM(arc.TransactionARAmountInsurance) AS TransactionARAmountInsurance
	,SUM(arc.TransactionARAmountActive) AS TransactionARAmountActive
	,SUM(arc.TransactionARAmountBadDebt) AS TransactionARAmountBadDebt
	,CASE
		WHEN arc.TransactionServiceDateAge BETWEEN 0 AND 30
			THEN '0'
		WHEN arc.TransactionServiceDateAge BETWEEN 31 AND 60 
			THEN '1'
		WHEN arc.TransactionServiceDateAge BETWEEN 61 AND 90 
			THEN '2'
		WHEN arc.TransactionServiceDateAge BETWEEN 91 AND 120 
			THEN '3'
		WHEN arc.TransactionServiceDateAge > 120 
			THEN '4'
		ELSE NULL
	END AS TransactionARAgingBucketSort
	,CASE
		WHEN arc.TransactionServiceDateAge BETWEEN 0 AND 30
			THEN '0-30'
		WHEN arc.TransactionServiceDateAge BETWEEN 31 AND 60 
			THEN '31-60'
		WHEN arc.TransactionServiceDateAge BETWEEN 61 AND 90 
			THEN '61-90'
		WHEN arc.TransactionServiceDateAge BETWEEN 91 AND 120 
			THEN '91-120'
		WHEN arc.TransactionServiceDateAge > 120 
			THEN '121+'
		ELSE NULL
	END AS TransactionARAgingBucket
	,CASE
		WHEN SUM(arc.[TransactionARAmountAll]) < 0
			THEN 1
		ELSE 0
	END AS IsARCredit
	,'Current' AS PeriodCategory
FROM [HPIDW].[rpt].[ARCurrentPB] arc


--WHERE 1=1


GROUP BY 
	[ARHistoryDate]
	,[TransactionDataSourceID]
	,[TransactionDepartmentID]
	,[CurrentFinancialClass]
	,[CurrentPayerID]
	,[TransactionBillingProviderID]
	,CASE
		WHEN arc.TransactionServiceDateAge BETWEEN 0 AND 30
			THEN '0'
		WHEN arc.TransactionServiceDateAge BETWEEN 31 AND 60 
			THEN '1'
		WHEN arc.TransactionServiceDateAge BETWEEN 61 AND 90 
			THEN '2'
		WHEN arc.TransactionServiceDateAge BETWEEN 91 AND 120 
			THEN '3'
		WHEN arc.TransactionServiceDateAge > 120 
			THEN '4'
		ELSE NULL
	END
	,CASE
		WHEN arc.TransactionServiceDateAge BETWEEN 0 AND 30
			THEN '0-30'
		WHEN arc.TransactionServiceDateAge BETWEEN 31 AND 60 
			THEN '31-60'
		WHEN arc.TransactionServiceDateAge BETWEEN 61 AND 90 
			THEN '61-90'
		WHEN arc.TransactionServiceDateAge BETWEEN 91 AND 120 
			THEN '91-120'
		WHEN arc.TransactionServiceDateAge > 120 
			THEN '121+'
		ELSE NULL
	END
GO
