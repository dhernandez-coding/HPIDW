CREATE VIEW [fact].[vPBChargeVoids] as

  	SELECT
		CONCAT('5','~',tdl.TX_ID) as TransactionID
		,'5' AS TransactionDataSourceID
		,tdl.DETAIL_TYPE AS DetailType
		,'Y' AS IsVoid
	FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].CLARITY_TDL_TRAN tdl --ON tx.TX_ID = tdl.TX_ID 
	WHERE TDL.DETAIL_TYPE = 10 --AND tdl.DETAIL_TYPE <> 10 /*Voided charges are handled in WHERE clause*/
		--AND tdl.DETAIL_TYPE < 40 /*Only Include New and Matching transaction types*/
	GROUP BY
		tdl.TX_ID
		,tdl.DETAIL_TYPE

UNION


	SELECT
		CONCAT('1','~',tx.Service_ID) AS TransactionID
		,'1' AS TransactionDataSourceID
		,tx.Update_Status AS DetailType
		,'Y' AS IsVoid
	FROM [TIEVMDB03].[Ntier_627200].[PM].vwGenSvcInfo tx
	WHERE tx.Update_Status = 3
	GROUP BY
		tx.Service_ID
		,tx.Update_Status;
GO
