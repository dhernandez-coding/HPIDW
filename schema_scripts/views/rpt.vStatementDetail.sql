CREATE VIEW [rpt].[vStatementDetail] as	
	
	SELECT 
		md.PRINT_ID AS StatementDetailID
		,md.TX_ID	AS StatementDetailTransactionID
		,ph.ProviderFullName AS StatementDetailProviderName
		,t.TransactionPracticeID
		,t.TransactionCode AS StatementDetailCode
		,t.TransactionDescription AS StatementDetailDescription
		,t.TransactionAmount AS StatementDetailAmount
	FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].STMT_ETR_MATCH_DETAIL md
		LEFT JOIN fact.vTransactionsPB t on t.TransactionParentSourceID = CONCAT('5~',md.TX_ID) AND t.TransactionType = 'Charge'
		LEFT JOIN dim.vProviders ph on ph.ProviderID = t.TransactionBillingProviderID
	--WHERE md.PRINT_ID IN ('100223656')
	GROUP BY
		md.PRINT_ID
		,md.TX_ID
		,ph.ProviderFullName
		,t.TransactionPracticeID
		,t.TransactionCode
		,t.TransactionDescription
		,t.TransactionAmount
GO
