-- =============================================
-- Create date: 9/1/2023
-- Description:	Extracts Accounts data from HSP_Account and loads into Fact.Accounts
-- Change control: 
-- 1. 05/09/2025 - Diego Hernandez - Adding safe load
-- 2. 10/21/2025 - Chris Cross - Added UNION to INSERT accounts with no coded procedures
-- =============================================
CREATE procedure [stg].[spEPICReloadFactVisitProceduresFull] 
AS 
BEGIN
	SET NOCOUNT OFF;

DROP TABLE IF EXISTS #StagingTable
CREATE TABLE #StagingTable  (
        [VisitProcedureID] VARCHAR(100),
        [VisitProcedureDataSourceID] INT,
        [VisitProcedureSourceID] VARCHAR(100),
        [VisitProcedureVisitID] VARCHAR(100),
        [VisitProcedureAccountID] VARCHAR(100),
        [VisitProcedureType] VARCHAR(100),
        [VisitProcedureSequence] INT,
        [VisitProcedureCodeType] VARCHAR(100),
        [VisitProcedureCode] VARCHAR(100),
        [VisitProcedureDescription] VARCHAR(1000),
        [VisitProcedureMod1] VARCHAR(100),
        [VisitProcedureMod2] VARCHAR(100),
        [VisitProcedureMod3] VARCHAR(100),
        [VisitProcedureMod4] VARCHAR(100),
        [VisitProcedureProviderID] VARCHAR(100),
        [VisitProcedureDate] DATETIME,
        [VisitProcedureIsPrimary] BIT,
        [VisitProcedureIsActive] BIT,
        [VisitProcedureUpdatedDatetime] DATETIME
    );

INSERT INTO #StagingTable
--	select * from [NXDC1DBSQ016.CORP.INTEGRIS-HEALTH.COM].[Revenue].dbo.FactVisitProcedures
	select
		CONCAT('5~',px.SOURCE_KEY,'~',COALESCE(a.PRIM_ENC_CSN_ID,csn.PAT_ENC_CSN_ID),'~',COALESCE(px.CODING_INFO_CPT_LINE,px.LINE)) as  VisitProcedureID 
		,5 as VisitProcedureDataSourceID 
		,CONCAT(px.SOURCE_KEY,'~',COALESCE(a.PRIM_ENC_CSN_ID,csn.PAT_ENC_CSN_ID),'~',COALESCE(px.CODING_INFO_CPT_LINE,px.LINE)) as VisitProcedureSourceID 
		,CONCAT('5~',COALESCE(a.PRIM_ENC_CSN_ID,csn.PAT_ENC_CSN_ID)) as VisitProcedureVisitID 
		,CONCAT('5~',px.HSP_ACCOUNT_ID) as VisitProcedureAccountID 
		,CASE WHEN COALESCE(px.CODING_INFO_CPT_LINE,px.LINE) = 1 THEN 'Principal' 
			  ELSE 'Secondary' END as VisitProcedureType 
		,COALESCE(px.CODING_INFO_CPT_LINE,px.LINE)  as VisitProcedureSequence 
		,CASE WHEN px.SOURCE_KEY in (11) THEN 'ICD10'
			  WHEN px.SOURCE_KEY in (13,21,22,23) THEN 'CPT'
			  ELSE px.SOURCE_ABBR END as VisitProcedureCodeType 
		,px.REF_BILL_CODE as VisitProcedureCode 
		,px.NAME as VisitProcedureDescription 
		,px.CODE_INT_MOD_1_CODE as VisitProcedureMod1 
		,px.CODE_INT_MOD_2_CODE as VisitProcedureMod2
		,px.CODE_INT_MOD_3_CODE as VisitProcedureMod3 
		,px.CODE_INT_MOD_4_CODE as VisitProcedureMod4 
		,CASE WHEN px.PX_PERF_PROV_ID is not null THEN CONCAT('5~',px.PX_PERF_PROV_ID) END as VisitProcedureProviderID 
		,px.PX_DATE as VisitProcedureDate 
		,CASE WHEN COALESCE(px.CODING_INFO_CPT_LINE,px.LINE) = 1 THEN 1 ELSE 0 END as VisitProcedureIsPrimary
		,1 as VisitProcedureIsActive 
		,getdate() as VisitProcedureUpdatedDatetime
		--, select px.* 
	from [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].HSP_ACCOUNT a
		INNER JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].V_CODING_ALL_DX_PX_LIST px ON px.HSP_ACCOUNT_ID = a.HSP_ACCOUNT_ID
		LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].HSP_ACCT_PAT_CSN csn ON csn.HSP_ACCOUNT_ID = a.HSP_ACCOUNT_ID and csn.LINE = 1
	where 1=1 
		AND px.SOURCE_KEY IN (11 /*ICD Procedures*/
							 ,13 /*Inpatient CPT*/
							 --,21 /*Charge CPT - Excluding from VisitProcedures as these are supplies, implants, and equipment; Not performed procedures*/
							 ,22 /*Coding CPT*/
							 ,23 /*Combined CPT - Charged and Coded*/
							 ) /*CPT and ICD Procedures*/
		AND COALESCE(a.PRIM_ENC_CSN_ID,csn.PAT_ENC_CSN_ID) is NOT null

INSERT INTO #StagingTable
  /*10/21/2025 - This block of code ensures all surgical cases have at least 1 procedure in the VisitProcedures table*/
  select 
	CONCAT(a.AccountDataSourceID,'~99~',v.VisitID,'~1') 
	, a.AccountDataSourceID  as VisitProcedureDataSourceID
	, CONCAT('99~',v.VisitSourceID,'~1')  as VisitProcedureSourceID
	, v.VisitID  as VisitProcedureVisitID
	, a.AccountID as VisitProcedureAccountID
	, '<No Coded Procedure>' as VisitProcedureType
	, 1  as VisitProcedureSequence
	, 'Principal' as VisitProcedureCodeType
	, '99999'  as VisitProcedureCode
	, '<No Coded Procedure>'  as VisitProcedureDescription
	--, '99999 - <No Coded Procedure>' as VisitProcedureCodeWithDescription
	, NULL as VisitProcedureMod1
	, NULL as VisitProcedureMod2
	, NULL as VisitProcedureMod3
	, NULL as VisitProcedureMod4
	, MIN(vc.VisitCasePrimaryProviderID) as VisitProcedureProviderID
	, MIN(vc.VisitCaseServiceDate) as VisitProcedureDate
	, 1 as VisitProcedureIsPrimary
	, 1 as VisitProcedureIsActive
	, GETDATE() AS VisitProcedureUpdatedDatetime
  from fact.Accounts a
	INNER JOIN fact.Visits2 v ON v.VisitAccountID = a.AccountID AND v.VisitIsPrimary = 1
	INNER JOIN fact.VisitCases vc ON vc.VisitCaseVisitID = v.VisitID
	LEFT JOIN #StagingTable vp ON vp.VisitProcedureAccountID = a.AccountID
  where 1=1
    AND a.AccountDataSourceID = 5
	AND vc.VisitCaseScheduleStatus = 'Completed'
	AND vp.VisitProcedureID is null
  group by 
	a.AccountDataSourceID
	,a.AccountID
	,v.VisitID
	,v.VisitSourceID

 IF (SELECT COUNT(1) FROM #StagingTable s where s.VisitProcedureCode <> '99999') >= 10
    BEGIN
        BEGIN TRY
            BEGIN TRANSACTION;
                PRINT 'At least 10 procedures found. Deleting and reloading fact.VisitProcedures...';

                DELETE FROM fact.VisitProcedures WHERE VisitProcedureDataSourceID = 5;

                INSERT INTO fact.VisitProcedures (
                    VisitProcedureID, VisitProcedureDataSourceID, VisitProcedureSourceID, VisitProcedureVisitID,
                    VisitProcedureAccountID, VisitProcedureType, VisitProcedureSequence, VisitProcedureCodeType,
                    VisitProcedureCode, VisitProcedureDescription, VisitProcedureMod1, VisitProcedureMod2,
                    VisitProcedureMod3, VisitProcedureMod4, VisitProcedureProviderID, VisitProcedureDate,
                    VisitProcedureIsPrimary, VisitProcedureIsActive, VisitProcedureUpdatedDatetime
                )
                
				SELECT 
					VisitProcedureID
					, VisitProcedureDataSourceID
					, VisitProcedureSourceID
					, VisitProcedureVisitID
					, s.VisitProcedureAccountID
					, VisitProcedureType
					, VisitProcedureSequence
					, VisitProcedureCodeType
					, VisitProcedureCode
					, VisitProcedureDescription
					, VisitProcedureMod1
					, VisitProcedureMod2
					, VisitProcedureMod3
					, VisitProcedureMod4
					, VisitProcedureProviderID
					, VisitProcedureDate
					, CASE WHEN d.VisitProcedureAccountID is null THEN s.VisitProcedureIsPrimary
						   WHEN d.VisitProcedureAccountID is not null AND s.VisitProcedureIsPrimary = 1 AND s.VisitProcedureID = d.MinProcID THEN 1
						   WHEN d.VisitProcedureAccountID is not null AND s.VisitProcedureIsPrimary = 1 AND s.VisitProcedureID <> d.MinProcID THEN 0
						   ELSE s.VisitProcedureIsPrimary END as VisitProcedureIsPrimary
					, VisitProcedureIsActive
					, VisitProcedureUpdatedDatetime 
				FROM #StagingTable s
					LEFT JOIN (	select 
									p.VisitProcedureAccountID
									,count(1) ct
									,min(p.VisitProcedureID) as MinProcID
									,max(p.VisitProcedureID) as MaxProcID
								from #StagingTable p
								where 1=1
									AND p.VisitProcedureSequence = 1
									AND p.VisitProcedureIsPrimary = 1
									AND p.VisitProcedureDataSourceID = 5
								group by 
									p.VisitProcedureAccountID
								having count(1) > 1) d ON d.VisitProcedureAccountID = s.VisitProcedureAccountID
				

            COMMIT TRANSACTION;
        END TRY
        BEGIN CATCH
            ROLLBACK TRANSACTION;
            PRINT ERROR_MESSAGE();
        END CATCH
    END
    ELSE
    BEGIN
        PRINT 'Less than 10 procedures found. Skipping delete and reload.';
    END

	
DROP TABLE IF EXISTS #StagingTable
END;



/*--Old Code Replaced on 9/1/2023--*/
/*
	SELECT 
	CONCAT('5~','ICD~',a.prim_enc_csn_id,'~',px.LINE) as  VisitProcedureID 
	,5 as VisitProcedureDataSourceID 
	,CONCAT('ICD~',a.prim_enc_csn_id,'~',px.LINE) as VisitProcedureSourceID 
	,CONCAT('5~',a.prim_enc_csn_id) as VisitProcedureVisitID 
    ,CONCAT('5~',a.hsp_account_id) as VisitProcedureAccountID 
	,CASE WHEN px.LINE = 1 THEN 'Principal' 
		  ELSE 'Secondary' END as VisitProcedureType 
	,px.LINE as VisitProcedureSequence 
	,'ICD10' as VisitProcedureCodeType 
	,icd.PROC_MASTER_NM as VisitProcedureCode 
	,icd.PROCEDURE_NAME as VisitProcedureDescription 
	,null as VisitProcedureMod1 
	,null as VisitProcedureMod2
	,null as VisitProcedureMod3 
	,null as VisitProcedureMod4 
	,CONCAT('5~',px.PROC_PERF_PROV_ID) as VisitProcedureProviderID 
	,px.PROC_DATE as VisitProcedureDate 
	,CASE WHEN px.LINE = 1 THEN 1 ELSE 0 END as VisitProcedureIsPrimary
	,1 as VisitProcedureIsActive 
	,getdate() as VisitProcedureUpdatedDatetime
  --select * 
  FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].HSP_ACCOUNT a
	inner join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].HSP_ACCT_PX_LIST px ON a.HSP_ACCOUNT_ID = px.HSP_ACCOUNT_ID
	left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].CL_ICD_PX icd ON icd.ICD_PX_ID = px.FINAL_ICD_PX_ID 
  WHERE a.PRIM_ENC_CSN_ID is not null
  and a.HSP_ACCOUNT_ID IN (605951394)

	UNION ALL

	SELECT 
	CONCAT('5~','CPT~',a.prim_enc_csn_id,'~',px.LINE) as  VisitProcedureID 
	,5 as VisitProcedureDataSourceID 
	,CONCAT('CPT~',a.prim_enc_csn_id,'~',px.LINE) as VisitProcedureSourceID 
	,CONCAT('5~',a.prim_enc_csn_id) as VisitProcedureVisitID 
	,CONCAT('5~',a.hsp_account_id) as VisitProcedureAccountID 
	,CASE WHEN px.LINE = 1 THEN 'Principal' 
		  ELSE 'Secondary' END as VisitProcedureType 
	,px.LINE as VisitProcedureSequence 
	,'CPT' as VisitProcedureCodeType 
	,px.CPT_CODE as VisitProcedureCode 
	,px.CPT_CODE_DESC as VisitProcedureDescription 
	,LEFT(px.CPT_MODIFIERS,2) as VisitProcedureMod1 
	,SUBSTRING(px.CPT_MODIFIERS,3,2)  as VisitProcedureMod2
	,SUBSTRING(px.CPT_MODIFIERS,5,2) as VisitProcedureMod3 
	,SUBSTRING(px.CPT_MODIFIERS,7,2) as VisitProcedureMod4 
	,CONCAT('5~',px.CPT_PERF_PROV_ID) as VisitProcedureProviderID 
	,px.CPT_CODE_DATE as VisitProcedureDate 
	,CASE WHEN px.LINE = 1 THEN 1 ELSE 0 END as VisitProcedureIsPrimary
	,1 as VisitProcedureIsActive 
	,getdate() as VisitProcedureUpdatedDatetime
  --select * 
  FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].HSP_ACCOUNT a
	inner join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].HSP_ACCT_CPT_CODES px ON a.HSP_ACCOUNT_ID = px.HSP_ACCOUNT_ID
  WHERE a.PRIM_ENC_CSN_ID is not null
  */
	
--select * from [100.65.16.148].[CLARITY].[ORGFILTER].HSP_ACCT_DX_LIST dx where dx.HSP_ACCOUNT_ID in (600010745,600010766)
--select * from [100.65.16.148].[CLARITY].[ORGFILTER].HSP_ACCT_PX_LIST px --where px.HSP_ACCOUNT_ID in (600010745,600010766)
--select * from [100.65.16.148].[CLARITY].[ORGFILTER].HSP_ACCT_CPT_CODES cpt --WHERE cpt.HSP_ACCOUNT_ID  in (600010745,600010766)
--select * from [100.65.16.148].[CLARITY].[ORGFILTER].[CLARITY_EDG] edg where edg.DX_ID IN ('636649') 
--select * from [100.65.16.148].[CLARITY].[ORGFILTER].[V_CODING_ALL_DX_PX_LIST] WHERE HSP_ACCOUNT_ID in (600010745,600010766)
GO
