CREATE PROCEDURE [stg].[spEPICReloadFactSelfPayFull] 
AS
/* 
-- =============================================
-- Author:		Eric Silvestri
-- Create date: Aug 22 2025 11:47AM
-- Edit date:   
-- Description:	Full reload for fact.SelfPay from HPI App
-- ============================================= 
*/
BEGIN

/*-----INSERT INTO @StagingTable-----*/
	PRINT 'Creating @StagingTable....'
	DECLARE @StagingTable table 
	(SelfPayTransactionID varchar(50)
	,SelfPayDataSourceID int
	,SelfPayTransactionSourceID varchar(50)
	,SelfPayVisitID varchar(50)
	,SelfPayPatientID varchar(50)
	,SelfPayType varchar(50)
	,SelfPayDateOfService datetime
	,SelfPayPostDate datetime
	,SelfPayPostDateAge int
	,SelfPayPostDateAgeBucket varchar(50)
	,SelfPayAgeDate datetime
	,SelfPayAge int
	,SelfPayAgeBucket varchar(50)
	,SelfPayFinancialClass varchar(50)
	,SelfPayBalance money
	,SelfPayPatientResponsibility money
	,SelfPayOutstandingBalance money
	,SelfPayUpdateDate datetime
	)
	
	PRINT 'Inserting records from Datasource into @StagingTable....'
	INSERT INTO @StagingTable 
	(SelfPayTransactionID       
	,SelfPayDataSourceID
	,SelfPayTransactionSourceID
	,SelfPayVisitID
	,SelfPayPatientID
	,SelfPayType
	,SelfPayDateOfService
	,SelfPayPostDate
	,SelfPayPostDateAge
	,SelfPayPostDateAgeBucket
	,SelfPayAgeDate
	,SelfPayAge
	,SelfPayAgeBucket
	,SelfPayFinancialClass
	,SelfPayBalance
	,SelfPayPatientResponsibility
	,SelfPayOutstandingBalance
	,SelfPayUpdateDate
	)



SELECT 
	CONCAT('5~',sp.TX_ID) AS SelfPayTransactionID
	,5 AS SelfPayDataSourceID
	,sp.TX_ID AS SelfPayTransactionSourceID
	,CONCAT('5~',sp.PAT_ENC_CSN_ID) AS SelfPayVisitID
	,CONCAT('5~',p.PAT_ID) AS SelfPayPatientID
	,sp.TX_TYPE AS SelfPayType
	,sp.SERVICE_DATE AS SelfPayDateOfService
	,sp.POST_DATE AS SelfPayPostDate
	,MAX(sp.POST_DATE_AGE) AS SelfPayPostDateAge
	,MAX(sp.POST_DATE_AGE_BKT) AS SelfPayPostDateAgeBucket
	,sp.SELF_PAY_AGE_DATE AS SelfPayAgeDate
	,MAX(sp.SELF_PAY_AGE) AS SelfPayAge
	,MAX(sp.SELF_PAY_AGE_BKT) AS SelfPayAgeBucket
	,sp.CURRENT_FINANCIAL_CLASS_NAME AS SelfPayFinancialClass
	,sp.OUTSTANDING_SELF_PAY_AMOUNT AS SelfPayBalance
	,t.PATIENT_AMT AS SelfPayPatientResponsibility
	,t.OUTSTANDING_AMT AS SelfPayOutstandingBalance
	,GETDATE() AS SelfPayUpdateDate
FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].V_ARPB_ATB_TX_DETAIL sp
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].PAT_ENC p ON p.PAT_ENC_CSN_ID = sp.PAT_ENC_CSN_ID
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ARPB_TRANSACTIONS t on t.TX_ID = sp.TX_ID
WHERE sp.CURRENT_FINANCIAL_CLASS_NAME = 'Self-Pay'
	AND sp.TX_TYPE = 'Charge'
	AND sp.SERV_AREA_ID in ('430','425','452000')
	--and sp.PAT_ENC_CSN_ID = '30174721359'
GROUP BY
	sp.TX_ID
	,sp.TX_TYPE
	,sp.PAT_ENC_CSN_ID
	,p.PAT_ID
	,sp.SERVICE_DATE
	,sp.POST_DATE
	,sp.SELF_PAY_AGE_DATE
	,sp.CURRENT_FINANCIAL_CLASS_NAME
	,sp.OUTSTANDING_SELF_PAY_AMOUNT
	,t.PATIENT_AMT
	,t.OUTSTANDING_AMT


IF (SELECT COUNT(1) FROM @StagingTable) >= 10 
	BEGIN 
	PRINT 'At least 10 records exist in the staging table.  Proceed with delete and reload...'

/*-----DELETE/DEACTIVATE old records----*/
	PRINT 'Deleting records in Datasource....'
	DELETE FROM fact.SelfPay WHERE SelfPayDataSourceID = 5

/*-----UPDATE existing records----*/
/*----------Commented out for INCREMENTAL reload based on modified date range----------
	PRINT 'Updating records in Datasource from @StagingTable....'
	UPDATE target
	SET target.SelfPayTransactionID = source.SelfPayTransactionID

	,target.source.SelfPayTransactionID       
	,target.source.SelfPayDataSourceID
	,target.source.SelfPayTransactionSourceID
	,target.source.SelfPayVisitID
	,target.source.SelfPayPatientID
	,target.source.SelfPayType
	,target.source.SelfPayDateOfService
	,target.source.SelfPayPostDate
	,target.source.SelfPayPostDateAge
	,target.source.SelfPayPostDateAgeBucket
	,target.source.SelfPayAgeDate
	,target.source.SelfPayAge
	,target.source.SelfPayAgeBucket
	,target.source.SelfPayFinancialClass
	,target.source.SelfPayBalance
	,target.source.SelfPayUpdateDate
	
	FROM fact.SelfPAy target
		INNER JOIN @StagingTable source ON source.ClaimID = target.ClaimID
*/

/*-----INSERT new records-----*/
	PRINT 'Inserting new records in Datasource from @StagingTable....'
	INSERT INTO fact.SelfPay
	(SelfPayTransactionID       
	,SelfPayDataSourceID
	,SelfPayTransactionSourceID
	,SelfPayVisitID
	,SelfPayPatientID
	,SelfPayType
	,SelfPayDateOfService
	,SelfPayPostDate
	,SelfPayPostDateAge
	,SelfPayPostDateAgeBucket
	,SelfPayAgeDate
	,SelfPayAge
	,SelfPayAgeBucket
	,SelfPayFinancialClass
	,SelfPayBalance
	,SelfPayPatientResponsibility
	,SelfPayOutstandingBalance
	,SelfPayUpdateDate
	)

	SELECT
	source.SelfPayTransactionID       
	,source.SelfPayDataSourceID
	,source.SelfPayTransactionSourceID
	,source.SelfPayVisitID
	,source.SelfPayPatientID
	,source.SelfPayType
	,source.SelfPayDateOfService
	,source.SelfPayPostDate
	,source.SelfPayPostDateAge
	,source.SelfPayPostDateAgeBucket
	,source.SelfPayAgeDate
	,source.SelfPayAge
	,source.SelfPayAgeBucket
	,source.SelfPayFinancialClass
	,source.SelfPayBalance
	,source.SelfPayPatientResponsibility
	,source.SelfPayOutstandingBalance
	,source.SelfPayUpdateDate
	
	
	FROM @StagingTable source
	--	LEFT JOIN fact.Claims target ON target.ClaimID = source.ClaimID
	WHERE 1=1
	--	AND target.ClaimID IS NULL 

	END

ELSE
	BEGIN
	PRINT 'Less than 10 records in the staging table. Ending job without delete and reload...'
	END

END
GO
