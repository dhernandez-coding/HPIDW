CREATE VIEW [rpt].[vStatements] as
	
	
	SELECT 
		p.PRINT_ID					AS StatementID
		,p.GUAR_ACCT_ID				AS StatementAccountID
		,p.RESPONSIBLE_PARTY_NAME	AS StatementPatientName
		,CASE WHEN p.SERV_AREA_ID = 425
			THEN 'TPG'
			WHEN p.SERV_AREA_ID = 430
				THEN 'HPIP' END		AS Statement
		,p.IS_DEMAND_STMT_YN		AS StatementDemand
		,p.STMT_END_BATCH_DATE		AS StatementBatchDate
		,p.STMT_PROC_DATE			AS StatementDate
		,t.NAME						AS StatementRunType
		,p.PAT_ENC_CSN_ID			AS StatementVisitID
		,p.IS_MYCHART_NOTIF_YN		AS StatementMyChart
		,m.NAME						AS StatementDeliveryMethod
		,s.NAME						AS StatementScenario
		,d.TOT_CHG_AMT				AS StatementTotalCharges
		,d.TOT_PMT_AMT				AS StatementTotalPayments
		,d.TOT_ADJ_AMT				AS StatementTotalAdjustments
		,d.CURR_PAT_BAL				AS StatementPatientBalance
	FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].STMT_PRINT p
		LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].STMT_PB_DETAIL d ON d.PRINT_ID = p.PRINT_ID
		LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].ZC_STMT_SCENARIO s ON s.STMT_SCENARIO_C = p.STMT_SCENARIO_C
		LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].ZC_DELIVERY_MTD m ON m.DELIVERY_MTD_C = p.DELIVERY_MTD_C
		LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].ZC_DB_HX_RUN_TYPE t ON t.DB_HX_RUN_TYPE_C = p.BILL_RUN_TYPE_C	
	WHERE p.STMT_END_BATCH_DATE >= '2025-01-01'
GO
