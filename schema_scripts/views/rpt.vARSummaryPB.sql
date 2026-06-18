CREATE VIEW rpt.vARSummaryPB AS
/* 
-- =============================================
-- Author:		Robert Beaird
-- Create date: May 24 2024  3:30PM
-- Edit date:   
-- Description:	query for rpt.vARSummaryPB from HPIDW
-- ============================================= 
*/

--DECLARE @MaxHistoryDate DATE

--SELECT @MaxHistoryDate = MAX(ARHistoryDate) FROM [HPIDW].[rpt].[ARHistoryPB];

/*All Historic AR*/


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


WHERE 1=1
	--AND arh.ARHistoryDate > @MaxHistoryDate

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
