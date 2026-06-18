CREATE PROCEDURE stg.spEPICReloadFactVisitDiagnosesFull as
		
/* 
-- =============================================
-- Author:		Chris Cross
-- Create date: Jul 30 2024  2:26PM
-- Edit date:   
-- Description:	INCREMENTAL reload for fact.VisitDiagnoses from EPIC
-- ============================================= 
*/
BEGIN

/*-----INSERT INTO @StagingTable-----*/
	PRINT 'Creating @StagingTable....'
	DECLARE @StagingTable table 
	(VisitDiagnosisID varchar(100)
	,VisitDiagnosisDataSourceID int
	,VisitDiagnosisSourceID varchar(100)
	,VisitDiagnosisVisitID varchar(100)
	,VisitDiagnosisAccountID varchar(100)
	,VisitDiagnosisType varchar(100)
	,VisitDiagnosisSequence int
	,VisitDiagnosisCodeType varchar(100)
	,VisitDiagnosisCode varchar(100)
	,VisitDiagnosisDescription varchar(1000)
	,VisitDiagnosisDate datetime
	,VisitDiagnosisIsPrimary bit
	,VisitDiagnosisIsActive bit
	,VisitDiagnosisUpdatedDatetime datetime
	)
	
	PRINT 'Inserting records from Datasource into @StagingTable....'
	INSERT INTO @StagingTable 
	(VisitDiagnosisID
	,VisitDiagnosisDataSourceID
	,VisitDiagnosisSourceID
	,VisitDiagnosisVisitID
	,VisitDiagnosisAccountID
	,VisitDiagnosisType
	,VisitDiagnosisSequence
	,VisitDiagnosisCodeType
	,VisitDiagnosisCode
	,VisitDiagnosisDescription
	,VisitDiagnosisDate
	,VisitDiagnosisIsPrimary
	,VisitDiagnosisIsActive
	,VisitDiagnosisUpdatedDatetime
	)

	select
		CONCAT('5~',COALESCE(csn.PAT_ENC_CSN_ID,a.PRIM_ENC_CSN_ID),'~',dx.LINE) AS VisitDiagnosisID
		,5 as VisitDiagnosisDataSourceID
		,CONCAT(COALESCE(csn.PAT_ENC_CSN_ID,a.PRIM_ENC_CSN_ID),'~',dx.LINE) as VisitDiagnosisSourceID
		,CONCAT('5~',COALESCE(csn.PAT_ENC_CSN_ID,a.PRIM_ENC_CSN_ID)) as VisitDiagnosisVisitID
		,CONCAT('5~',a.HSP_ACCOUNT_ID) as VisitDiagnosisAccountID
		,CASE WHEN dx.LINE = 1 THEN 'Principal'
			  ELSE 'Secondary' END as VisitDiagnosisType
		,dx.LINE as VisitDiagnosisSequence
		,'ICD10' AS VisitDiagnosisCodeType
		,dx.REF_BILL_CODE as VisitDiagnosisCode
		,dx.NAME as VisitDiagnosisCodeDescription
		,NULL as VisitDiagnosisDate
		,CASE WHEN dx.LINE = 1 THEN 1 ELSE 0 END as VisitDiagnosisIsPrimary
		,1 as VisitDiagnosisIsActive
		,getdate() as VisitDiagnosisUpdatedDatetime
		--, select a.*
	from [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].HSP_ACCOUNT a
		INNER JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].V_CODING_ALL_DX_PX_LIST dx ON dx.HSP_ACCOUNT_ID = a.HSP_ACCOUNT_ID
		LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].HSP_ACCT_PAT_CSN csn ON csn.HSP_ACCOUNT_ID = a.HSP_ACCOUNT_ID and csn.LINE = 1
	where 1=1 
		AND dx.SOURCE_KEY IN (3 /*Final Diagnoses*/) 
		AND a.HSP_ACCOUNT_ID like '6%' /*HB Accounts Only*/
		AND COALESCE(csn.PAT_ENC_CSN_ID,a.PRIM_ENC_CSN_ID) is NOT null
		




IF (SELECT COUNT(1) FROM @StagingTable) >= 10 
	BEGIN 
	PRINT 'At least 10 records exist in the staging table.  Proceed with delete and reload...'

/*-----DELETE/DEACTIVATE old records----*/
	PRINT 'Deleting records in Datasource....'
	DELETE FROM fact.VisitDiagnoses WHERE VisitDiagnosisDataSourceID = 5 --AND <Insert Incremental Date Column> between 2024-06-30 AND 2024-07-30

/*-----UPDATE existing records----*/
/*----------Commented out for INCREMENTAL reload based on modified date range----------
	PRINT 'Updating records in Datasource from @StagingTable....'
	UPDATE target
	SET target.VisitDiagnosisID = source.VisitDiagnosisID
	,target.VisitDiagnosisDataSourceID = source.VisitDiagnosisDataSourceID
	,target.VisitDiagnosisSourceID = source.VisitDiagnosisSourceID
	,target.VisitDiagnosisVisitID = source.VisitDiagnosisVisitID
	,target.VisitDiagnosisAccountID = source.VisitDiagnosisAccountID
	,target.VisitDiagnosisType = source.VisitDiagnosisType
	,target.VisitDiagnosisSequence = source.VisitDiagnosisSequence
	,target.VisitDiagnosisCodeType = source.VisitDiagnosisCodeType
	,target.VisitDiagnosisCode = source.VisitDiagnosisCode
	,target.VisitDiagnosisDescription = source.VisitDiagnosisDescription
	,target.VisitDiagnosisDate = source.VisitDiagnosisDate
	,target.VisitDiagnosisIsPrimary = source.VisitDiagnosisIsPrimary
	,target.VisitDiagnosisIsActive = source.VisitDiagnosisIsActive
	,target.VisitDiagnosisUpdatedDatetime = source.VisitDiagnosisUpdatedDatetime
	
	FROM fact.VisitDiagnoses target
		INNER JOIN @StagingTable source ON source.VisitDiagnosisID = target.VisitDiagnosisID
*/

/*-----INSERT new records-----*/
	PRINT 'Inserting new records in Datasource from @StagingTable....'
	INSERT INTO fact.VisitDiagnoses
	(VisitDiagnosisID
	,VisitDiagnosisDataSourceID
	,VisitDiagnosisSourceID
	,VisitDiagnosisVisitID
	,VisitDiagnosisAccountID
	,VisitDiagnosisType
	,VisitDiagnosisSequence
	,VisitDiagnosisCodeType
	,VisitDiagnosisCode
	,VisitDiagnosisDescription
	,VisitDiagnosisDate
	,VisitDiagnosisIsPrimary
	,VisitDiagnosisIsActive
	,VisitDiagnosisUpdatedDatetime
	)

	SELECT
	source.VisitDiagnosisID
	,source.VisitDiagnosisDataSourceID
	,source.VisitDiagnosisSourceID
	,source.VisitDiagnosisVisitID
	,source.VisitDiagnosisAccountID
	,source.VisitDiagnosisType
	,source.VisitDiagnosisSequence
	,source.VisitDiagnosisCodeType
	,source.VisitDiagnosisCode
	,source.VisitDiagnosisDescription
	,source.VisitDiagnosisDate
	,source.VisitDiagnosisIsPrimary
	,source.VisitDiagnosisIsActive
	,source.VisitDiagnosisUpdatedDatetime
	
	FROM @StagingTable source
	--	LEFT JOIN fact.VisitDiagnoses target ON target.VisitDiagnosisID = source.VisitDiagnosisID
	WHERE 1=1
	--	AND target.VisitDiagnosisID IS NULL 

	END

ELSE
	BEGIN
	PRINT 'Less than 10 records in the staging table. Ending job without delete and reload...'
	END

END

--Completion time: 2024-07-30T14:26:22.7074490-05:00
GO
