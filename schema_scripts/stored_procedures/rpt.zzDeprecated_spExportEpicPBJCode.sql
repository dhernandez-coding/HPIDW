/*
-- =============================================
-- Author:		Eric Silvestri
-- Create date: 02/12/2024
-- Description:	compiles data for Code Technologies export for Dr. Jacobs
-- Change Control
-- =============================================
*/

CREATE PROCEDURE [rpt].[spExportEpicPBJCode] AS


BEGIN
SET NOCOUNT ON;


DECLARE @sql      varchar(MAX)
      , @path     varchar(100)
      , @filename varchar(100)

DECLARE @prevAdvancedOptions int
DECLARE @prevXpCmdshell int

 

SET @path = 'C:\Users\Public\Code\'
SET @filename
     = 'PBJ_Code_Patient_List'


IF OBJECT_ID(N'tempdb..#BASE') IS NOT NULL
BEGIN
DROP TABLE #BASE
END

IF OBJECT_ID(N'tempdb..#OR_CASE') IS NOT NULL
BEGIN
DROP TABLE #OR_CASE
END

IF OBJECT_ID(N'tempdb..#PAT_INFO') IS NOT NULL
BEGIN
DROP TABLE #PAT_INFO
END

IF OBJECT_ID(N'tempdb..#PHONE_CONTACT') IS NOT NULL
BEGIN
DROP TABLE #PHONE_CONTACT
END

IF OBJECT_ID(N'tempdb..#COVERAGE') IS NOT NULL
BEGIN
DROP TABLE #COVERAGE
END

IF OBJECT_ID(N'tempdb..#OR_CASE_PROC') IS NOT NULL
BEGIN
DROP TABLE #OR_CASE_PROC
END

IF OBJECT_ID(N'tempdb..#OR_PROC') IS NOT NULL
BEGIN
DROP TABLE #OR_PROC
END

IF OBJECT_ID(N'tempdb..#PIVOT_PROC') IS NOT NULL
BEGIN
DROP TABLE #PIVOT_PROC
END

IF OBJECT_ID(N'tempdb..#OR_CASE_INFO') IS NOT NULL
BEGIN
DROP TABLE #OR_CASE_INFO
END

IF OBJECT_ID(N'tempdb..#GET_CPT') IS NOT NULL
BEGIN
DROP TABLE #GET_CPT
END

IF OBJECT_ID(N'tempdb..#ANES_PRIMARY_NM') IS NOT NULL
BEGIN
DROP TABLE #ANES_PRIMARY_NM
END

IF OBJECT_ID(N'tempdb..#PREOPDX_INFO') IS NOT NULL
BEGIN
DROP TABLE #PREOPDX_INFO
END

IF OBJECT_ID(N'tempdb..#IMPLANT_INFO') IS NOT NULL
BEGIN
DROP TABLE #IMPLANT_INFO
END

IF OBJECT_ID(N'tempdb..#FIN_INFO') IS NOT NULL
BEGIN
DROP TABLE #FIN_INFO
END

IF OBJECT_ID(N'tempdb..#CPT_FINAL') IS NOT NULL
BEGIN
DROP TABLE #CPT_FINAL
END

IF OBJECT_ID(N'tempdb..##OUTPUT') IS NOT NULL
BEGIN
DROP TABLE ##OUTPUT
END

;

WITH CTE_BASE AS (SELECT DISTINCT 
                        oc.*
                 FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].OR_CASE OC
                  LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].CLARITY_LOC CL ON OC.LOC_ID = CL.LOC_ID
                  LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_OR_SCHED_STATUS ZOSS ON OC.SCHED_STATUS_C = ZOSS.SCHED_STATUS_C
                --LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].OR_CASE_AUDIT_TRL OCAT ON OC.OR_CASE_ID = OCAT.OR_CASE_ID
                  WHERE (OC.SURGERY_DATE >= (GETDATE() - 45) AND OC.SURGERY_DATE < (GETDATE() + 365)
                         OR (OC.SURGERY_DATE > (GETDATE() + 365) AND OC.SCHED_STATUS_C = 3))
                         AND CL.SERV_AREA_ID = 430  --HPI Service Area
						 AND OC.PRIMARY_PHYSICIAN_ID = '109844'
						 )

SELECT *
INTO #BASE
FROM CTE_BASE

--SELECT * FROM #BASE; 

--select top 1000* FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].CLARITY_SER where PROV_ID = '109844'
;

WITH CTE_OR_CASE AS (SELECT DISTINCT
                       OC.PAT_ID,
                       OC.OR_CASE_ID,
                       OL.LOG_ID,
                       OC.SERVICE_C,
                       OL.INPATIENT_DATA_ID,
                       PE.PAT_ENC_CSN_ID,
                       PE.CONTACT_DATE,
                       (PE.WEIGHT/16) AS WEIGHT,
                       PE.HEIGHT,
                       PE.BMI,
                     --  CL.SERV_AREA_ID,
                       ZS.TITLE AS OC_SERVICE,
                       OC.SURGERY_DATE,
                       ZPC.TITLE AS OC_PATIENT_CLASS,
                       OLZS.TITLE AS OLL_SERVICE,
                       OLZPC.TITLE AS OL_PATIENT_CLASS,
                       OC.SCHED_STATUS_C,
                       ZOSS.TITLE AS SCHEDULE_STATUS,
                       PE.ACCOUNT_ID,
                       ROW_NUMBER()OVER(PARTITION BY OC.PAT_ID, OC.OR_CASE_ID ORDER BY PE.CONTACT_DATE) AS RNK
                FROM #BASE CB
                INNER JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].OR_CASE OC ON CB.PAT_ID = OC.PAT_ID
                INNER JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].CLARITY_LOC CL ON OC.LOC_ID = CL.LOC_ID
                LEFT OUTER JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].OR_LOG OL ON OC.LOG_ID = OL.LOG_ID
                LEFT OUTER JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].PAT_ENC PE ON OL.INPATIENT_DATA_ID = PE.INPATIENT_DATA_ID
                LEFT OUTER JOIN  [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_OR_SERVICE ZS ON OC.SERVICE_C = ZS.SERVICE_C
                LEFT OUTER JOIN  [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_OR_SERVICE OLZS ON OL.SERVICE_C = OLZS.SERVICE_C
                LEFT OUTER JOIN  [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_PAT_CLASS ZPC ON OC.PAT_CLASS_C = ZPC.ADT_PAT_CLASS_C
                LEFT OUTER JOIN  [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_PAT_CLASS OLZPC ON OL.PAT_TYPE_C = OLZPC.ADT_PAT_CLASS_C
                LEFT OUTER JOIN  [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_OR_SCHED_STATUS ZOSS ON OC.SCHED_STATUS_C = ZOSS.SCHED_STATUS_C
                WHERE (OC.SURGERY_DATE >= (GETDATE() - 45) AND OC.SURGERY_DATE < (GETDATE() + 365)
                       OR (OC.SURGERY_DATE > (GETDATE() + 365) AND OC.SCHED_STATUS_C = 3))
                      AND CL.SERV_AREA_ID = 430
					  AND OC.PRIMARY_PHYSICIAN_ID = '109844'
                --ORDER BY ZS.TITLE
                )
               --WHERE RNK = 1
                --)
SELECT *
INTO #OR_CASE
FROM CTE_OR_CASE
WHERE RNK = 1


--SELECT * FROM #OR_CASE COC;
;

WITH CTE_PAT_INFO AS (SELECT   PAT.PAT_ID, 
                               PAT.PAT_MRN_ID AS MRN,  --STRIP OUT MRN WHERE LIKE <E...>
                               PAT.PAT_FIRST_NAME AS FIRST_NAME,
                               PAT.PAT_LAST_NAME AS LAST_NAME,
                               CASE WHEN PAT.SEX_C = 1 THEN 'F'
                                    WHEN PAT.SEX_C = 2 THEN 'M'
                                    ELSE 'N' 
                               END AS GENDER,
                               CAST(PAT.BIRTH_DATE AS DATE) AS "DATE OF BIRTH",
                                    EG.NAME AS "ETHNICITY",
                                    CAST(PAT.DEATH_DATE AS DATE) AS "DATE OF DEATH",
									ZC_LANGUAGE.NAME AS "LANGUAGE",
                                    --CASE WHEN PAT.LANGUAGE_C IN (52,76,77) THEN 'Chinese'
                                    --      WHEN PAT.LANGUAGE_C = 36 THEN 'Tonga (Tonga Islands)'
                                    --      WHEN PAT.LANGUAGE_C IN (45,1,2,67,100,51,68,69,46,7,8,10,11,12,13,107,50,47,61,14,16,18,19,101,20,21,82,104,78,80,24,65,26,27,28,58,30,48,49,32,42,33,34,43,57,35,37,59,39,40) THEN ZC_LANGUAGE.NAME
                                    --      ELSE NULL END AS LANGUAGE,
                                    CASE WHEN INTRPTR_NEEDED_YN = 'Y' THEN 'YES'
                                          ELSE  'NO' END AS "INTERPRETER NEEDED",
                                    CASE WHEN OI.OUTREACH_ID IS NOT NULL
                                         THEN 'Y'
                                         ELSE 'N'
                                         END AS SMS_CONSENT_STATUS,
                                    CASE WHEN UPPER(PAT.EMAIL_ADDRESS) LIKE '%NOEMAIL%'
                                         THEN NULL
                                         ELSE PAT.EMAIL_ADDRESS 
                                         END AS EMAIL_1,
                                    CASE WHEN UPPER(PE.EMAIL_ADDRESS) LIKE '%NOEMAIL@%'
                                         THEN NULL
                                         ELSE PE.EMAIL_ADDRESS 
                                         END AS "EMAIL_2",
                                    CASE WHEN MARITAL_STATUS_C = 1 THEN 'DIVORCED'
                                         WHEN MARITAL_STATUS_C = 2 THEN 'MARRIED'
                                         WHEN MARITAL_STATUS_C = 4 THEN 'WIDOWED'
                                         WHEN MARITAL_STATUS_C = 5 THEN 'LEGALLY SEPARATED'
                                         ELSE NULL
                                     END  AS "MARITAL STATUS",
                                    PAT.SSN AS SSN,  --4/24/2023 MASK ONLY SHOW LAST 4 DIGITS.
                                    PAT.CITY,
                                    ZS.TITLE AS STATE,
                                    ZC.TITLE AS COUNTRY,
                                    PAT.ZIP   
                      FROM #BASE CB 
                      INNER JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].PATIENT PAT ON CB.PAT_ID = PAT.PAT_ID AND PAT.PAT_MRN_ID NOT LIKE '%E%'
                      LEFT OUTER JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_ETHNIC_GROUP EG ON PAT.ETHNIC_GROUP_C = EG.ETHNIC_GROUP_C
                      LEFT OUTER JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].OUTREACH_INFO OI ON PAT.PAT_ID = OI.PATIENT_ID AND OUTREACH_METHOD_C = 13
                      LEFT OUTER JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_ETHNIC_GROUP ZEG ON PAT.ETHNIC_GROUP_C = ZEG.ETHNIC_GROUP_C
                      LEFT OUTER JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_LANGUAGE ON PAT.LANGUAGE_C =ZC_LANGUAGE.LANGUAGE_C
                      LEFT OUTER JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].PAT_EMAILADDRESS PE ON PAT.PAT_ID = PE.PAT_ID AND PE.LINE = 2
                      LEFT OUTER JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_STATE ZS ON PAT.STATE_C = ZS.STATE_C
                      LEFT OUTER JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_COUNTRY ZC ON PAT.COUNTRY_C = ZC.COUNTRY_C
					)

SELECT *
INTO #PAT_INFO
FROM CTE_PAT_INFO

--SELECT * FROM #PAT_INFO;
;

WITH CTE_PHONE_CONTACT AS (
    SELECT 
        PAT_ID, 
        [HOME] AS PHONE_1, 
        'HOME PHONE' AS PHONE_TYPE_1,
        [WORK] AS PHONE_2,
        'WORK PHONE' AS PHONE_TYPE_2,
        [MOBILE] AS PHONE_3,
        'MOBILE' AS PHONE_TYPE_3
    FROM (
        SELECT *
        FROM (
            SELECT 
                OC.PAT_ID,
                OC.OTHER_COMMUNIC_NUM,
                ZOC.TITLE
            FROM #PAT_INFO CPI
            INNER JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].OTHER_COMMUNCTN OC ON CPI.PAT_ID = OC.PAT_ID AND OC.LINE IN (1, 2, 3)
            LEFT OUTER JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_OTHER_COMMUNIC ZOC ON OC.OTHER_COMMUNIC_C = ZOC.OTHER_COMMUNIC_C
        ) AS SourceTable
        PIVOT (
            MAX(OTHER_COMMUNIC_NUM) 
            FOR TITLE IN ([HOME], [WORK], [MOBILE])
        ) AS PivotTable
    ) AS PC
)				

SELECT *
INTO #PHONE_CONTACT
FROM CTE_PHONE_CONTACT

--SELECT * FROM #PHONE_CONTACT;
;

WITH CTE_COVERAGE AS  (SELECT CB.PAT_ID,
                        PAC.FIN_CLASS,
                        CF.FIN_CLASS_TITLE AS FINANCIAL_CLASS,
                        COV.SUBSCR_NUM AS "MEDICARE ID",
                        ROW_NUMBER()OVER(PARTITION BY CB.PAT_ID ORDER BY CF.FIN_CLASS_TITLE DESC) AS RNK 
                 FROM #BASE CB
                 INNER JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].PAT_ACCT_CVG PAC ON PAC.PAT_ID = CB.PAT_ID
                 INNER JOIN #PAT_INFO CPI ON PAC.PAT_ID = CPI.PAT_ID
                 INNER JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].CLARITY_FC CF ON PAC.FIN_CLASS = CF.FINANCIAL_CLASS
                 LEFT OUTER JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].COVERAGE COV ON PAC.COVERAGE_ID = COV.COVERAGE_ID
                 WHERE PAC.FIN_CLASS IN (113, --MCARE RISK PLNS(HMO)
                                         2,   --MEDICARE
                                         109) --MEDICAREFFS
                 )
    
SELECT *
INTO #COVERAGE
FROM CTE_COVERAGE
WHERE RNK = 1

--SELECT * FROM #COVERAGE 
;

WITH CTE_OR_CASE_PROC AS (
				SELECT 
					OR_CASE_ID
					,CASE_PROCEDURE_DATE
					,MAX(CASE WHEN SourceTable.LINE = 1 THEN SourceTable.CASE_PROCEDURE_ID END) as ProcID_1
				    ,MAX(CASE WHEN SourceTable.LINE = 2 THEN SourceTable.CASE_PROCEDURE_ID END) as ProcID_2
				    ,MAX(CASE WHEN SourceTable.LINE = 3 THEN SourceTable.CASE_PROCEDURE_ID END) as ProcID_3
				    ,MAX(CASE WHEN SourceTable.LINE = 4 THEN SourceTable.CASE_PROCEDURE_ID END) as ProcID_4
				    ,MAX(CASE WHEN SourceTable.LINE = 5 THEN SourceTable.CASE_PROCEDURE_ID END) as ProcID_5
				    ,MAX(CASE WHEN SourceTable.LINE = 6 THEN SourceTable.CASE_PROCEDURE_ID END) as ProcID_6
				    ,MAX(CASE WHEN SourceTable.LINE = 1 THEN SourceTable.CASE_PROCEDURE_NAME END) as ProcName_1
				    ,MAX(CASE WHEN SourceTable.LINE = 2 THEN SourceTable.CASE_PROCEDURE_NAME END) as ProcName_2
				    ,MAX(CASE WHEN SourceTable.LINE = 3 THEN SourceTable.CASE_PROCEDURE_NAME END) as ProcName_3
				    ,MAX(CASE WHEN SourceTable.LINE = 4 THEN SourceTable.CASE_PROCEDURE_NAME END) as ProcName_4
				    ,MAX(CASE WHEN SourceTable.LINE = 5 THEN SourceTable.CASE_PROCEDURE_NAME END) as ProcName_5
				    ,MAX(CASE WHEN SourceTable.LINE = 6 THEN SourceTable.CASE_PROCEDURE_NAME END) as ProcName_6
				    ,MAX(CASE WHEN SourceTable.LINE = 1 THEN SourceTable.CASE_ORIENTATION END) as Orientation_1
				    ,MAX(CASE WHEN SourceTable.LINE = 2 THEN SourceTable.CASE_ORIENTATION END) as Orientation_2
				    ,MAX(CASE WHEN SourceTable.LINE = 3 THEN SourceTable.CASE_ORIENTATION END) as Orientation_3
				    ,MAX(CASE WHEN SourceTable.LINE = 4 THEN SourceTable.CASE_ORIENTATION END) as Orientation_4
				    ,MAX(CASE WHEN SourceTable.LINE = 5 THEN SourceTable.CASE_ORIENTATION END) as Orientation_5
				    ,MAX(CASE WHEN SourceTable.LINE = 6 THEN SourceTable.CASE_ORIENTATION END) as Orientation_6
				FROM (
					SELECT 
						OCAP.OR_CASE_ID,
						CB.SURGERY_DATE AS CASE_PROCEDURE_DATE,
						OCAP.OR_PROC_ID AS CASE_PROCEDURE_ID,
						PRC.PROC_NAME AS CASE_PROCEDURE_NAME,
						LRB.NAME AS CASE_ORIENTATION,
						OCAP.LINE
					FROM #OR_CASE CB
					INNER JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].OR_CASE_ALL_PROC OCAP ON CB.OR_CASE_ID = OCAP.OR_CASE_ID
					LEFT OUTER JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].OR_PROC PRC ON OCAP.OR_PROC_ID = PRC.OR_PROC_ID
					LEFT OUTER JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_OR_LRB LRB ON OCAP.LRB_C = LRB.LRB_C
				) AS SourceTable
				GROUP BY OR_CASE_ID
						,CASE_PROCEDURE_DATE
				
			) 

SELECT *
INTO #OR_CASE_PROC
FROM CTE_OR_CASE_PROC


--SELECT * FROM #OR_CASE_PROC;
;

--GET OR_LOG PROCEDURE INFO
WITH CTE_OR_PROC AS --(SELECT *
               --FROM
                (SELECT 
                       OCAP.LOG_ID,
                       CB.SURGERY_DATE AS PROCEDURE_DATE,
                       OCAP.OR_PROC_ID AS PROCEDURE_ID,
                       PRC.PROC_NAME AS PROCEDURE_NAME,
                       LRB.NAME AS ORIENTATION,
                       OCAP.LINE,
                       CB.ACCOUNT_ID,
                       OCAP.PROC_EAP_ID
                FROM #OR_CASE CB
                INNER JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].OR_LOG_ALL_PROC OCAP ON CB.LOG_ID = OCAP.LOG_ID
                left outer join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].OR_PROC prc on OCAP.OR_PROC_ID = PRC.OR_PROC_ID
                left outer join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_OR_LRB lrb ON OCAP.LRB_C = LRB.LRB_C)


SELECT *
INTO #OR_PROC
FROM CTE_OR_PROC

--SELECT * FROM #OR_PROC;
;

WITH CTE_PIVOT_PROC AS (
			SELECT 
				LOG_ID
				,PROCEDURE_DATE
				,MAX(CASE WHEN SourceTable.LINE = 1 THEN SourceTable.PROCEDURE_ID END) as ProcID_1
				,MAX(CASE WHEN SourceTable.LINE = 2 THEN SourceTable.PROCEDURE_ID END) as ProcID_2
				,MAX(CASE WHEN SourceTable.LINE = 3 THEN SourceTable.PROCEDURE_ID END) as ProcID_3
				,MAX(CASE WHEN SourceTable.LINE = 4 THEN SourceTable.PROCEDURE_ID END) as ProcID_4
				,MAX(CASE WHEN SourceTable.LINE = 5 THEN SourceTable.PROCEDURE_ID END) as ProcID_5
				,MAX(CASE WHEN SourceTable.LINE = 6 THEN SourceTable.PROCEDURE_ID END) as ProcID_6
				,MAX(CASE WHEN SourceTable.LINE = 1 THEN SourceTable.PROCEDURE_NAME END) as ProcName_1
				,MAX(CASE WHEN SourceTable.LINE = 2 THEN SourceTable.PROCEDURE_NAME END) as ProcName_2
				,MAX(CASE WHEN SourceTable.LINE = 3 THEN SourceTable.PROCEDURE_NAME END) as ProcName_3
				,MAX(CASE WHEN SourceTable.LINE = 4 THEN SourceTable.PROCEDURE_NAME END) as ProcName_4
				,MAX(CASE WHEN SourceTable.LINE = 5 THEN SourceTable.PROCEDURE_NAME END) as ProcName_5
				,MAX(CASE WHEN SourceTable.LINE = 6 THEN SourceTable.PROCEDURE_NAME END) as ProcName_6
				,MAX(CASE WHEN SourceTable.LINE = 1 THEN SourceTable.ORIENTATION END) as Orientation_1
				,MAX(CASE WHEN SourceTable.LINE = 2 THEN SourceTable.ORIENTATION END) as Orientation_2
				,MAX(CASE WHEN SourceTable.LINE = 3 THEN SourceTable.ORIENTATION END) as Orientation_3
				,MAX(CASE WHEN SourceTable.LINE = 4 THEN SourceTable.ORIENTATION END) as Orientation_4
				,MAX(CASE WHEN SourceTable.LINE = 5 THEN SourceTable.ORIENTATION END) as Orientation_5
				,MAX(CASE WHEN SourceTable.LINE = 6 THEN SourceTable.ORIENTATION END) as Orientation_6
            FROM
                (SELECT 
					CB.LOG_ID,
					CB.PROCEDURE_DATE,
					CB.PROCEDURE_ID,
					CB.PROCEDURE_NAME,
					CB.ORIENTATION,
					CB.LINE
				FROM #OR_PROC CB
			) AS SourceTable
			GROUP BY 
			LOG_ID
			,PROCEDURE_DATE
		  )
				

SELECT *
INTO #PIVOT_PROC
FROM CTE_PIVOT_PROC

--SELECT * FROM #PIVOT_PROC;
;
--GET OR_LOG PROCEDURE INFO
WITH CTE_GET_CPT AS  (SELECT 
                       OCAP.LOG_ID,
                       OCAP.PROCEDURE_DATE,
                       OCAP.PROCEDURE_ID,
                       OCAP.PROCEDURE_NAME,
                       OCAP.ORIENTATION,
                       OCAP.LINE,
                       OPCI.CPT_ID,
                       OCAP.ACCOUNT_ID,
                       RANK()OVER(PARTITION BY OCAP.LOG_ID, OPCI.CPT_ID ORDER BY OPCI.LINE, OCAP.LINE ) AS RNK
                FROM #OR_PROC OCAP
                INNER JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].OR_PROC_CPT_ID OPCI ON OCAP.PROCEDURE_ID = OPCI.OR_PROC_ID
)

SELECT *
INTO #GET_CPT
FROM CTE_GET_CPT

--SELECT * FROM #GET_CPT;
;

WITH ANES_PRIMARY_NM AS (SELECT COC.LOG_ID,
                           VLB.PRIMARY_ANES_TYPE_NM AS ANESTHESIA_TYPE
                    FROM #OR_CASE COC
                    INNER JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].V_LOG_BASED VLB ON COC.LOG_ID = VLB.LOG_ID
					)

SELECT *
INTO #ANES_PRIMARY_NM
FROM ANES_PRIMARY_NM

--select * from #ANES_PRIMARY_NM
;
--GET OR CASE INFO
WITH CTE_OR_CASE_INFO AS (SELECT OC.OR_CASE_ID,
                    CS.PROV_NAME,
					SUBSTRING(CS.PROV_NAME, 1, CHARINDEX(' ', CS.PROV_NAME) - 2) AS PROVIDER_FIRST_NAME,
					 CASE 
						  WHEN CHARINDEX(' ', CS.PROV_NAME) > 0 THEN
							 SUBSTRING(CS.PROV_NAME, CHARINDEX(' ', CS.PROV_NAME) + 1, LEN(CS.PROV_NAME))
						 ELSE
							 SUBSTRING(CS.PROV_NAME, CHARINDEX(' ', CS.PROV_NAME) + 1, LEN(CS.PROV_NAME))
					 END AS PROVIDER_LAST_NAME,
                     CS2.NPI AS PROVIDER_NPI,
                     LOC.LOC_NAME AS LOCATION,
                     'HEALTH System'      AS FACILITY_NAME, -- Will need to update this
                     'xxxxxxxxxx'           AS FACILITY_NPI  -- Will need to update this
             FROM #OR_CASE CTC
             INNER JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].OR_CASE OC ON CTC.OR_CASE_ID = OC.OR_CASE_ID
             INNER JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].CLARITY_SER CS ON OC.PRIMARY_PHYSICIAN_ID = CS.PROV_ID
             LEFT OUTER JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].CLARITY_SER_2 CS2 ON CS.PROV_ID = CS2.PROV_ID
             LEFT OUTER JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].CLARITY_LOC LOC on OC.LOC_ID = LOC.LOC_ID
             WHERE LOC.SERV_AREA_ID = 430 and CS2.NPI = 1548433345
			 ) --SA 425 is TPG

SELECT *
INTO #OR_CASE_INFO
FROM CTE_OR_CASE_INFO

--SELECT * FROM #OR_CASE_INFO;
;

--GET DX INFO
WITH CTE_PREOPDX_INFO AS  (SELECT LOG_ID
								  ,PRE_OP_DIAG AS PRE_OP_DX
								  ,MAX(CASE WHEN SourceTable.LINE = 1 THEN SourceTable.PRE_OP_DIAG END) as PREOPDX_1
								  ,MAX(CASE WHEN SourceTable.LINE = 2 THEN SourceTable.PRE_OP_DIAG END) as PREOPDX_2
								  ,MAX(CASE WHEN SourceTable.LINE = 3 THEN SourceTable.PRE_OP_DIAG END) as PREOPDX_3
								  ,MAX(CASE WHEN SourceTable.LINE = 4 THEN SourceTable.PRE_OP_DIAG END) as PREOPDX_4
								  ,MAX(CASE WHEN SourceTable.LINE = 5 THEN SourceTable.PRE_OP_DIAG END) as PREOPDX_5
								  ,MAX(CASE WHEN SourceTable.LINE = 6 THEN SourceTable.PRE_OP_DIAG END) as PREOPDX_6
								  ,MAX(CASE WHEN SourceTable.LINE = 1 THEN SourceTable.PRE_OP_DX END) as PREOPDX_DESC_1
								  ,MAX(CASE WHEN SourceTable.LINE = 2 THEN SourceTable.PRE_OP_DX END) as PREOPDX_DESC_2
								  ,MAX(CASE WHEN SourceTable.LINE = 3 THEN SourceTable.PRE_OP_DX END) as PREOPDX_DESC_3
								  ,MAX(CASE WHEN SourceTable.LINE = 4 THEN SourceTable.PRE_OP_DX END) as PREOPDX_DESC_4
								  ,MAX(CASE WHEN SourceTable.LINE = 5 THEN SourceTable.PRE_OP_DX END) as PREOPDX_DESC_5
								  ,MAX(CASE WHEN SourceTable.LINE = 6 THEN SourceTable.PRE_OP_DX END) as PREOPDX_DESC_6
                 FROM
                (SELECT OLP.LOG_ID,
                        OLP.PRE_OP_DIAG AS PRE_OP_DX,
						 CASE 
								WHEN CHARINDEX('[', OLP.PRE_OP_DIAG) > 0 AND CHARINDEX(']', OLP.PRE_OP_DIAG) > 0 THEN
									SUBSTRING(
										OLP.PRE_OP_DIAG, 
										CHARINDEX('[', OLP.PRE_OP_DIAG) + 1, 
										CHARINDEX(']', OLP.PRE_OP_DIAG) - CHARINDEX('[', OLP.PRE_OP_DIAG) - 1
									)
								ELSE
									NULL -- Handle cases where brackets are not found
							END AS PRE_OP_DIAG,
                        OLP.LINE
                FROM #OR_CASE COC
                INNER JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].OR_LOG_PREOPDX OLP ON COC.OR_CASE_ID = OLP.LOG_ID
                ) as SourceTable
			GROUP BY 
				LOG_ID
				,PRE_OP_DIAG

		)

SELECT *
INTO #PREOPDX_INFO
FROM CTE_PREOPDX_INFO

--SELECT * FROM #PREOPDX_INFO;        
;

--GET IMPLANT INFO 
WITH CTE_IMPLANT_INFO AS (SELECT LOG_ID
								 ,implant_log_id
								 ,pat_id
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 1 THEN SourceTable.IMPLANT_ID END) as IMPLANT_ID_1
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 2 THEN SourceTable.IMPLANT_ID END) as IMPLANT_ID_2
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 3 THEN SourceTable.IMPLANT_ID END) as IMPLANT_ID_3
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 4 THEN SourceTable.IMPLANT_ID END) as IMPLANT_ID_4
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 5 THEN SourceTable.IMPLANT_ID END) as IMPLANT_ID_5
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 6 THEN SourceTable.IMPLANT_ID END) as IMPLANT_ID_6
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 7 THEN SourceTable.IMPLANT_ID END) as IMPLANT_ID_7
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 8 THEN SourceTable.IMPLANT_ID END) as IMPLANT_ID_8
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 9 THEN SourceTable.IMPLANT_ID END) as IMPLANT_ID_9
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 10 THEN SourceTable.IMPLANT_ID END) as IMPLANT_ID_10
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 11 THEN SourceTable.IMPLANT_ID END) as IMPLANT_ID_11
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 12 THEN SourceTable.IMPLANT_ID END) as IMPLANT_ID_12
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 13 THEN SourceTable.IMPLANT_ID END) as IMPLANT_ID_13
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 14 THEN SourceTable.IMPLANT_ID END) as IMPLANT_ID_14
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 15 THEN SourceTable.IMPLANT_ID END) as IMPLANT_ID_15
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 16 THEN SourceTable.IMPLANT_ID END) as IMPLANT_ID_16
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 17 THEN SourceTable.IMPLANT_ID END) as IMPLANT_ID_17
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 18 THEN SourceTable.IMPLANT_ID END) as IMPLANT_ID_18
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 19 THEN SourceTable.IMPLANT_ID END) as IMPLANT_ID_19
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 20 THEN SourceTable.IMPLANT_ID END) as IMPLANT_ID_20
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 1 THEN SourceTable.MANUFACTURER END) as MANUFACTURER_1
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 2 THEN SourceTable.MANUFACTURER END) as MANUFACTURER_2
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 3 THEN SourceTable.MANUFACTURER END) as MANUFACTURER_3
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 4 THEN SourceTable.MANUFACTURER END) as MANUFACTURER_4
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 5 THEN SourceTable.MANUFACTURER END) as MANUFACTURER_5
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 6 THEN SourceTable.MANUFACTURER END) as MANUFACTURER_6
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 7 THEN SourceTable.MANUFACTURER END) as MANUFACTURER_7
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 8 THEN SourceTable.MANUFACTURER END) as MANUFACTURER_8
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 9 THEN SourceTable.MANUFACTURER END) as MANUFACTURER_9
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 10 THEN SourceTable.MANUFACTURER END) as MANUFACTURER_10
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 11 THEN SourceTable.MANUFACTURER END) as MANUFACTURER_11
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 12 THEN SourceTable.MANUFACTURER END) as MANUFACTURER_12
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 13 THEN SourceTable.MANUFACTURER END) as MANUFACTURER_13
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 14 THEN SourceTable.MANUFACTURER END) as MANUFACTURER_14
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 15 THEN SourceTable.MANUFACTURER END) as MANUFACTURER_15
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 16 THEN SourceTable.MANUFACTURER END) as MANUFACTURER_16
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 17 THEN SourceTable.MANUFACTURER END) as MANUFACTURER_17
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 18 THEN SourceTable.MANUFACTURER END) as MANUFACTURER_18
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 19 THEN SourceTable.MANUFACTURER END) as MANUFACTURER_19
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 20 THEN SourceTable.MANUFACTURER END) as MANUFACTURER_20
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 1 THEN SourceTable.COMPONENT_NAME END) as COMPONENT_NAME_1
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 2 THEN SourceTable.COMPONENT_NAME END) as COMPONENT_NAME_2
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 3 THEN SourceTable.COMPONENT_NAME END) as COMPONENT_NAME_3
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 4 THEN SourceTable.COMPONENT_NAME END) as COMPONENT_NAME_4
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 5 THEN SourceTable.COMPONENT_NAME END) as COMPONENT_NAME_5
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 6 THEN SourceTable.COMPONENT_NAME END) as COMPONENT_NAME_6
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 7 THEN SourceTable.COMPONENT_NAME END) as COMPONENT_NAME_7
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 8 THEN SourceTable.COMPONENT_NAME END) as COMPONENT_NAME_8
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 9 THEN SourceTable.COMPONENT_NAME END) as COMPONENT_NAME_9
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 10 THEN SourceTable.COMPONENT_NAME END) as COMPONENT_NAME_10
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 11 THEN SourceTable.COMPONENT_NAME END) as COMPONENT_NAME_11
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 12 THEN SourceTable.COMPONENT_NAME END) as COMPONENT_NAME_12
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 13 THEN SourceTable.COMPONENT_NAME END) as COMPONENT_NAME_13
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 14 THEN SourceTable.COMPONENT_NAME END) as COMPONENT_NAME_14
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 15 THEN SourceTable.COMPONENT_NAME END) as COMPONENT_NAME_15
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 16 THEN SourceTable.COMPONENT_NAME END) as COMPONENT_NAME_16
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 17 THEN SourceTable.COMPONENT_NAME END) as COMPONENT_NAME_17
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 18 THEN SourceTable.COMPONENT_NAME END) as COMPONENT_NAME_18
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 19 THEN SourceTable.COMPONENT_NAME END) as COMPONENT_NAME_19
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 20 THEN SourceTable.COMPONENT_NAME END) as COMPONENT_NAME_20
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 1 THEN SourceTable.CATALOG_NUMBER END) as CATALOG_NUMBER_1
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 2 THEN SourceTable.CATALOG_NUMBER END) as CATALOG_NUMBER_2
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 3 THEN SourceTable.CATALOG_NUMBER END) as CATALOG_NUMBER_3
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 4 THEN SourceTable.CATALOG_NUMBER END) as CATALOG_NUMBER_4
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 5 THEN SourceTable.CATALOG_NUMBER END) as CATALOG_NUMBER_5
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 6 THEN SourceTable.CATALOG_NUMBER END) as CATALOG_NUMBER_6
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 7 THEN SourceTable.CATALOG_NUMBER END) as CATALOG_NUMBER_7
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 8 THEN SourceTable.CATALOG_NUMBER END) as CATALOG_NUMBER_8
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 9 THEN SourceTable.CATALOG_NUMBER END) as CATALOG_NUMBER_9
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 10 THEN SourceTable.CATALOG_NUMBER END) as CATALOG_NUMBER_10
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 11 THEN SourceTable.CATALOG_NUMBER END) as CATALOG_NUMBER_11
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 12 THEN SourceTable.CATALOG_NUMBER END) as CATALOG_NUMBER_12
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 13 THEN SourceTable.CATALOG_NUMBER END) as CATALOG_NUMBER_13
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 14 THEN SourceTable.CATALOG_NUMBER END) as CATALOG_NUMBER_14
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 15 THEN SourceTable.CATALOG_NUMBER END) as CATALOG_NUMBER_15
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 16 THEN SourceTable.CATALOG_NUMBER END) as CATALOG_NUMBER_16
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 17 THEN SourceTable.CATALOG_NUMBER END) as CATALOG_NUMBER_17
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 18 THEN SourceTable.CATALOG_NUMBER END) as CATALOG_NUMBER_18
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 19 THEN SourceTable.CATALOG_NUMBER END) as CATALOG_NUMBER_19
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 20 THEN SourceTable.CATALOG_NUMBER END) as CATALOG_NUMBER_20
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 1 THEN SourceTable.LOT_NUMBER END) as LOT_NUMBER_1
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 2 THEN SourceTable.LOT_NUMBER END) as LOT_NUMBER_2
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 3 THEN SourceTable.LOT_NUMBER END) as LOT_NUMBER_3
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 4 THEN SourceTable.LOT_NUMBER END) as LOT_NUMBER_4
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 5 THEN SourceTable.LOT_NUMBER END) as LOT_NUMBER_5
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 6 THEN SourceTable.LOT_NUMBER END) as LOT_NUMBER_6
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 7 THEN SourceTable.LOT_NUMBER END) as LOT_NUMBER_7
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 8 THEN SourceTable.LOT_NUMBER END) as LOT_NUMBER_8
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 9 THEN SourceTable.LOT_NUMBER END) as LOT_NUMBER_9
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 10 THEN SourceTable.LOT_NUMBER END) as LOT_NUMBER_10
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 11 THEN SourceTable.LOT_NUMBER END) as LOT_NUMBER_11
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 12 THEN SourceTable.LOT_NUMBER END) as LOT_NUMBER_12
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 13 THEN SourceTable.LOT_NUMBER END) as LOT_NUMBER_13
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 14 THEN SourceTable.LOT_NUMBER END) as LOT_NUMBER_14
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 15 THEN SourceTable.LOT_NUMBER END) as LOT_NUMBER_15
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 16 THEN SourceTable.LOT_NUMBER END) as LOT_NUMBER_16
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 17 THEN SourceTable.LOT_NUMBER END) as LOT_NUMBER_17
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 18 THEN SourceTable.LOT_NUMBER END) as LOT_NUMBER_18
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 19 THEN SourceTable.LOT_NUMBER END) as LOT_NUMBER_19
								 ,MAX(CASE WHEN SourceTable.ROW_NUM = 20 THEN SourceTable.LOT_NUMBER END) as LOT_NUMBER_20
 	                     FROM
                     (SELECT     OL.LOG_ID
                                ,ori.implant_log_id                                                
                                ,ori.implant_id
                                ,imp.pat_id
                                ,zom.NAME AS manufacturer
                                ,imp.implant_name AS component_name
                                ,imp.model_number AS catalog_number
                                ,imp.lot_number
                                ,row_number() OVER(PARTITION BY OL.log_id ORDER BY ori.implant_id) AS row_num
                            FROM
                                [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].OR_LOG OL
                                INNER JOIN #OR_CASE COC ON OL.CASE_ID = COC.OR_CASE_ID     
                                INNER JOIN  [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].or_imp_implant      ori ON OL.log_id = ori.implant_log_id
                                INNER JOIN  [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].or_imp              imp ON ori.implant_id = imp.implant_id
                                LEFT JOIN   [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].zc_or_manufacturer  zom ON imp.manufacturer_c = zom.manufacturer_c
					) AS SourceTable
					GROUP BY LOG_ID
						 ,implant_log_id
						 ,pat_id
				  )

SELECT *
INTO #IMPLANT_INFO
FROM CTE_IMPLANT_INFO

--SELECT * FROM #IMPLANT_INFO;
;

WITH CTE_FIN_INFO AS (SELECT COC.LOG_ID,
                        ZFC.TITLE AS FINANCIAL_CLASS,
                        CE.PAYOR_NAME,
                        EPP.BENEFIT_PLAN_NAME AS GROUP_NAME,
                        PEH.HOSP_ADMSN_TIME AS ADMIT_DATE,
                        PEH.HOSP_DISCH_TIME AS DISCHARGE_DATE,
                        (PEH.HOSP_DISCH_TIME - PEH.HOSP_ADMSN_TIME) AS LENGTH_OF_STAY,
                        ZDD.TITLE AS DISCHARGE_DISPOSITION
                 FROM #OR_CASE COC
                 INNER JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].PAT_ENC_HSP PEH ON COC.INPATIENT_DATA_ID = PEH.INPATIENT_DATA_ID
                 INNER JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].HSP_ACCOUNT HA ON PEH.HSP_ACCOUNT_ID = HA.HSP_ACCOUNT_ID
                 LEFT OUTER JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].COVERAGE CVG ON HA.COVERAGE_ID = CVG.COVERAGE_ID
                 LEFT OUTER JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].CLARITY_EPP EPP ON HA.PRIMARY_PLAN_ID = EPP.BENEFIT_PLAN_ID
                 LEFT OUTER JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].CLARITY_EPM CE ON HA.PRIMARY_PAYOR_ID = CE.PAYOR_ID
                 LEFT OUTER JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_DISCH_DISP ZDD ON PEH.DISCH_DISP_C = ZDD.DISCH_DISP_C
                 LEFT OUTER JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_FINANCIAL_CLASS ZFC ON HA.ACCT_FIN_CLASS_C = ZFC.FINANCIAL_CLASS
                  )

SELECT *
INTO #FIN_INFO
FROM CTE_FIN_INFO

--SELECT * FROM #FIN_INFO;
;
/***** THIS IS WHERE I LEFT OFF*****/
WITH CTE_CPT_FINAL AS   (SELECT   LOG_ID
							     ,PROCEDURE_DATE
                                 ,ACCOUNT_ID
								 ,MAX(CASE WHEN SourceTable.CPT_RNK = 1 THEN SourceTable.CPT_CODE END) as PX_1
								 ,MAX(CASE WHEN SourceTable.CPT_RNK = 2 THEN SourceTable.CPT_CODE END) as PX_2
								 ,MAX(CASE WHEN SourceTable.CPT_RNK = 3 THEN SourceTable.CPT_CODE END) as PX_3
								 ,MAX(CASE WHEN SourceTable.CPT_RNK = 4 THEN SourceTable.CPT_CODE END) as PX_4
								 ,MAX(CASE WHEN SourceTable.CPT_RNK = 5 THEN SourceTable.CPT_CODE END) as PX_5
								 ,MAX(CASE WHEN SourceTable.CPT_RNK = 6 THEN SourceTable.CPT_CODE END) as PX_6
								 ,MAX(CASE WHEN SourceTable.CPT_RNK = 7 THEN SourceTable.CPT_CODE END) as PX_7
								 ,MAX(CASE WHEN SourceTable.CPT_RNK = 8 THEN SourceTable.CPT_CODE END) as PX_8
								 ,MAX(CASE WHEN SourceTable.CPT_RNK = 9 THEN SourceTable.CPT_CODE END) as PX_9
								 ,MAX(CASE WHEN SourceTable.CPT_RNK = 10 THEN SourceTable.CPT_CODE END) as PX_10

                    FROM
					  (SELECT  DISTINCT
							   LOG_ID,
							   PROCEDURE_DATE,
							   ACCOUNT_ID,
							   CPT_CODE,
							   RANK()OVER(PARTITION BY LOG_ID ORDER BY TX_ID) AS CPT_RNK
					   FROM    
							(SELECT 
									   COP.LOG_ID,
									   COP.PROCEDURE_DATE,
									   AR.ACCOUNT_ID,
									   AR.CPT_CODE,
									   AR.TX_ID,
									ROW_NUMBER()OVER(PARTITION BY COP.LOG_ID, AR.CPT_CODE ORDER BY AR.TX_ID) AS RNK 
							  FROM #GET_CPT COP
							  INNER JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ARPB_TRANSACTIONS AR ON COP.ACCOUNT_ID = AR.ACCOUNT_ID 
										 AND COP.PROCEDURE_DATE = AR.SERVICE_DATE
							  WHERE COP.RNK = 1
							  AND AR.TX_TYPE_C = 1
							  AND AR.VOID_DATE IS NULL
							  AND AR.CPT_CODE >= '10000'
							  AND AR.CPT_CODE <= '69999'
								) AS SourceTable
					  WHERE RNK = 1
					  ) AS SourceTable
					  GROUP BY LOG_ID
							     ,PROCEDURE_DATE
                                 ,ACCOUNT_ID
                           

                  )

SELECT *
INTO #CPT_FINAL
FROM CTE_CPT_FINAL
  --               )
--SELECT * FROM #CPT_FINAL;

;

SELECT DISTINCT
       CPI.*,
       CASE WHEN CTC.PHONE_1 LIKE '000-%'
            THEN NULL
            WHEN CTC.PHONE_1 LIKE '999-%'
            THEN NULL
            ELSE CTC.PHONE_1
            END AS PHONE_1,
       CTC.PHONE_TYPE_1,
       CASE WHEN CTC.PHONE_2 LIKE '000-%'
            THEN NULL
            WHEN CTC.PHONE_1 LIKE '999-%'
            THEN NULL
            ELSE CTC.PHONE_2
            END AS PHONE_2,
       CTC.PHONE_TYPE_2,
       CASE WHEN CTC.PHONE_3 LIKE '000-%'
            THEN NULL
            WHEN CTC.PHONE_1 LIKE '999-%'
            THEN NULL
            ELSE CTC.PHONE_3
            END AS PHONE_3,
       CTC.PHONE_TYPE_3,
       CC."MEDICARE ID",
       COC.HEIGHT,
       COC.[WEIGHT],
       COC.BMI,
       COC.OR_CASE_ID AS OR_CASE_ID_PRIM,
       COC.SURGERY_DATE AS CASE_SURGERY_DATE,
       COC.SERVICE_C,
       --COC.SERV_AREA_ID,
       COC.OC_SERVICE,
       COC.OLL_SERVICE,
       COC.SCHEDULE_STATUS,
       COC.OC_PATIENT_CLASS,                
       COC.OL_PATIENT_CLASS,
       CONVERT(DATETIME, VLTE.PROCEDURE_START_DTTM, 100) AS LOG_PROCEDURE_START_TIME,
       CONVERT(DATETIME, VLTE.PROCEDURE_COMP_DTTM, 100) AS LOG_PROCEDURE_END_TIME,
       OCI.*,
	   COC.LOG_ID,
       CFI.FINANCIAL_CLASS,
       CFI.PAYOR_NAME,
       CFI.GROUP_NAME,
       CONVERT(DATETIME, CFI.ADMIT_DATE, 100) AS ADMIT_DATE,
       CONVERT(DATETIME, CFI.DISCHARGE_DATE, 100) AS DISCHARGE_DATE,
       CONVERT(INT, CFI.LENGTH_OF_STAY) AS LENGTH_OF_STAY,
       CFI.DISCHARGE_DISPOSITION,
	    CONVERT(DATETIME, COCP.CASE_PROCEDURE_DATE, 100) AS CASE_PROCEDURE_DATE,
	   COCP.ProcID_1,
	   COCP.ProcID_2,
	   COCP.ProcID_3,
	   COCP.ProcID_4,
	   COCP.ProcID_5,
	   COCP.ProcID_6,
	   COCP.ProcName_1,
	   COCP.ProcName_2,
	   COCP.ProcName_3,
	   COCP.ProcName_4,
	   COCP.ProcName_5,
	   COCP.ProcName_6,
	   COCP.Orientation_1,
	   COCP.Orientation_2,
	   COCP.Orientation_3,
	   COCP.Orientation_4,
	   COCP.Orientation_5,
	   COCP.Orientation_6,
	   --CPP.PROCEDURE_DATE,
	   --CPP.ProcID_1,
	   --CPP.ProcID_2,
	   --CPP.ProcID_3,
	   --CPP.ProcID_4,
	   --CPP.ProcID_5,
	   --CPP.ProcID_6,
	   --CPP.ProcName_1,
	   --CPP.ProcName_2,
	   --CPP.ProcName_3,
	   --CPP.ProcName_4,
	   --CPP.ProcName_5,
	   --CPP.ProcName_6,
	   --CPP.Orientation_1,
	   --CPP.Orientation_2,
	   --CPP.Orientation_3,
	   --CPP.Orientation_4,
	   --CPP.Orientation_5,
	   --CPP.Orientation_6,
	   CDX.PRE_OP_DX,
	   CDX.PREOPDX_1,
	   CDX.PREOPDX_2,
	   CDX.PREOPDX_3,
	   CDX.PREOPDX_4,
	   CDX.PREOPDX_5,
	   CDX.PREOPDX_6,
	   CDX.PREOPDX_DESC_1,
	   CDX.PREOPDX_DESC_2,
	   CDX.PREOPDX_DESC_3,
	   CDX.PREOPDX_DESC_4,
	   CDX.PREOPDX_DESC_5,
	   CDX.PREOPDX_DESC_6,
	   CPF.PROCEDURE_DATE,
       CPF.ACCOUNT_ID,
	   CPF.PX_1,
	   CPF.PX_2,
	   CPF.PX_3,
	   CPF.PX_4,
	   CPF.PX_5,
	   CPF.PX_6,
	   CPF.PX_7,
	   CPF.PX_8,
	   CPF.PX_9,
	   CPF.PX_10,
       CII.implant_log_id,
	   CII.IMPLANT_ID_1,
	   CII.IMPLANT_ID_2,
	   CII.IMPLANT_ID_3,
	   CII.IMPLANT_ID_4,
	   CII.IMPLANT_ID_5,
	   CII.IMPLANT_ID_6,
	   CII.IMPLANT_ID_7,
	   CII.IMPLANT_ID_8,
	   CII.IMPLANT_ID_9,
	   CII.IMPLANT_ID_10,
	   CII.IMPLANT_ID_11,
	   CII.IMPLANT_ID_12,
	   CII.IMPLANT_ID_13,
	   CII.IMPLANT_ID_14,
	   CII.IMPLANT_ID_15,
	   CII.IMPLANT_ID_16,
	   CII.IMPLANT_ID_17,
	   CII.IMPLANT_ID_18,
	   CII.IMPLANT_ID_19,
	   CII.IMPLANT_ID_20,
	   CII.MANUFACTURER_1,
	   CII.MANUFACTURER_2,
	   CII.MANUFACTURER_3,
	   CII.MANUFACTURER_4,
	   CII.MANUFACTURER_5,
	   CII.MANUFACTURER_6,
	   CII.MANUFACTURER_7,
	   CII.MANUFACTURER_8,
	   CII.MANUFACTURER_9,
	   CII.MANUFACTURER_10,
	   CII.MANUFACTURER_11,
	   CII.MANUFACTURER_12,
	   CII.MANUFACTURER_13,
	   CII.MANUFACTURER_14,
	   CII.MANUFACTURER_15,
	   CII.MANUFACTURER_16,
	   CII.MANUFACTURER_17,
	   CII.MANUFACTURER_18,
	   CII.MANUFACTURER_19,
	   CII.MANUFACTURER_20,
	   CII.COMPONENT_NAME_1,
	   CII.COMPONENT_NAME_2,
	   CII.COMPONENT_NAME_3,
	   CII.COMPONENT_NAME_4,
	   CII.COMPONENT_NAME_5,
	   CII.COMPONENT_NAME_6,
	   CII.COMPONENT_NAME_7,
	   CII.COMPONENT_NAME_8,
	   CII.COMPONENT_NAME_9,
	   CII.COMPONENT_NAME_10,
	   CII.COMPONENT_NAME_11,
	   CII.COMPONENT_NAME_12,
	   CII.COMPONENT_NAME_13,
	   CII.COMPONENT_NAME_14,
	   CII.COMPONENT_NAME_15,
	   CII.COMPONENT_NAME_16,
	   CII.COMPONENT_NAME_17,
	   CII.COMPONENT_NAME_18,
	   CII.COMPONENT_NAME_19,
	   CII.COMPONENT_NAME_20,
	   CII.CATALOG_NUMBER_1,
	   CII.CATALOG_NUMBER_2,
	   CII.CATALOG_NUMBER_3,
	   CII.CATALOG_NUMBER_4,
	   CII.CATALOG_NUMBER_5,
	   CII.CATALOG_NUMBER_6,
	   CII.CATALOG_NUMBER_7,
	   CII.CATALOG_NUMBER_8,
	   CII.CATALOG_NUMBER_9,
	   CII.CATALOG_NUMBER_10,
	   CII.CATALOG_NUMBER_11,
	   CII.CATALOG_NUMBER_12,
	   CII.CATALOG_NUMBER_13,
	   CII.CATALOG_NUMBER_14,
	   CII.CATALOG_NUMBER_15,
	   CII.CATALOG_NUMBER_16,
	   CII.CATALOG_NUMBER_17,
	   CII.CATALOG_NUMBER_18,
	   CII.CATALOG_NUMBER_19,
	   CII.CATALOG_NUMBER_20,
	   CII.LOT_NUMBER_1,
	   CII.LOT_NUMBER_2,
	   CII.LOT_NUMBER_3,
	   CII.LOT_NUMBER_4,
	   CII.LOT_NUMBER_5,
	   CII.LOT_NUMBER_6,
	   CII.LOT_NUMBER_7,
	   CII.LOT_NUMBER_8,
	   CII.LOT_NUMBER_9,
	   CII.LOT_NUMBER_10,
	   CII.LOT_NUMBER_11,
	   CII.LOT_NUMBER_12,
	   CII.LOT_NUMBER_13,
	   CII.LOT_NUMBER_14,
	   CII.LOT_NUMBER_15,
	   CII.LOT_NUMBER_16,
	   CII.LOT_NUMBER_17,
	   CII.LOT_NUMBER_18,
	   CII.LOT_NUMBER_19,
	   CII.LOT_NUMBER_20
       --APN.ANESTHESIA_TYPE
--INTO ##OUTPUT
--FROM #PAT_INFO CPI
FROM #OR_CASE COC
		--LEFT OUTER JOIN #OR_CASE COC ON CPI.PAT_ID = COC.PAT_ID
		LEFT OUTER JOIN #PAT_INFO CPI on COC.PAT_ID = CPI.PAT_ID
		LEFT OUTER JOIN #PHONE_CONTACT CTC ON CPI.PAT_ID = CTC.PAT_ID
		LEFT OUTER JOIN #COVERAGE CC ON CPI.PAT_ID = CC.PAT_ID
		LEFT OUTER JOIN #OR_CASE_INFO OCI ON COC.OR_CASE_ID = OCI.OR_CASE_ID
		LEFT OUTER JOIN #PREOPDX_INFO  CDX ON COC.LOG_ID = CDX.LOG_ID
		LEFT OUTER JOIN #OR_CASE_PROC COCP ON COC.OR_CASE_ID = COCP.OR_CASE_ID
		LEFT OUTER JOIN #IMPLANT_INFO CII ON COC.LOG_ID = CII.LOG_ID
		LEFT OUTER JOIN #FIN_INFO CFI ON COC.LOG_ID = CFI.LOG_ID
		LEFT OUTER JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].V_LOG_TIMING_EVENTS VLTE ON COC.LOG_ID = VLTE.LOG_ID
		LEFT OUTER JOIN #CPT_FINAL CPF ON OCI.OR_CASE_ID = CPF.LOG_ID
		LEFT OUTER JOIN #PIVOT_PROC CPP ON COC.OR_CASE_ID = CPP.LOG_ID
		--LEFT OUTER JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ANES_PRIMARY_NM APN ON COC.LOG_ID = APN.LOG_ID
WHERE                   
	COC.OR_CASE_ID IS NOT NULL
	OR OCI.OR_CASE_ID IS NOT NULL
	--AND PROV_NAME IS NULL
ORDER BY COC.OC_SERVICE
-- select * from ##OUTPUT


DECLARE @query varchar(MAX) = 'SET NOCOUNT ON;' + 
'SELECT CAST(PAT_ID as varchar(20)), '','',' +
'CAST(MRN as varchar(20)), '','',' +
'CAST(FIRST_NAME as varchar(25)), '','',' +
'CAST(LAST_NAME as varchar(25)), '','',' +
'CAST(GENDER as varchar(1)), '','',' +
'CAST([DATE OF BIRTH] as varchar(10)), '','',' +
'CAST(ETHNICITY as varchar(25)), '','',' +
'CAST([DATE OF DEATH] as varchar(10)), '','',' +
'CAST(LANGUAGE as varchar(25)), '','',' +
'CAST([INTERPRETER NEEDED] as varchar(8)), '','',' +
'CAST(SMS_CONSENT_STATUS as varchar(1)), '','',' +
'CAST(EMAIL_1 as varchar(50)), '','',' +
'CAST(EMAIL_2 as varchar(50)), '','',' +
'CAST([MARITAL STATUS] as varchar(20)), '','',' +
'CAST(SSN as varchar(15)), '','',' +
'CAST(CITY as varchar(25)), '','',' +
'CAST(STATE as varchar(8)), '','',' +
'CAST(COUNTRY as varchar(25)), '','',' +
'CAST(ZIP as varchar(10)), '','',' +
'CAST(PHONE_1 as varchar(15)), '','',' +
'CAST(PHONE_TYPE_1 as varchar(15)), '','',' +
'CAST(PHONE_2 as varchar(15)), '','',' +
'CAST(PHONE_TYPE_2 as varchar(15)), '','',' +
'CAST(PHONE_3 as varchar(15)), '','',' +
'CAST(PHONE_TYPE_3 as varchar(15)), '','',' +
'CAST([MEDICARE ID] as varchar(15)), '','',' +
'CAST(HEIGHT as varchar(8)), '','',' +
'CAST(WEIGHT as varchar(8)), '','',' +
'CAST(BMI as varchar(8)), '','',' +
'CAST(OR_CASE_ID_PRIM as varchar(10)), '','',' +
'CAST(CASE_SURGERY_DATE as varchar(10)), '','',' +
'CAST(SERVICE_C as varchar(3)), '','',' +
'CAST(OC_SERVICE as varchar(25)), '','',' +
'CAST(OLL_SERVICE as varchar(25)), '','',' +
'CAST(SCHEDULE_STATUS as varchar(25)), '','',' +
'CAST(OC_PATIENT_CLASS as varchar(25)), '','',' +
'CAST(OL_PATIENT_CLASS as varchar(25)), '','',' +
'CAST(LOG_PROCEDURE_START_TIME as varchar(10)), '','',' +
'CAST(LOG_PROCEDURE_END_TIME as varchar(10)), '','',' +
'CAST(OR_CASE_ID as varchar(10)), '','',' +
'CAST(PROV_NAME as varchar(50)), '','',' +
'CAST(PROVIDER_FIRST_NAME as varchar(25)), '','',' +
'CAST(PROVIDER_LAST_NAME as varchar(25)), '','',' +
'CAST(PROVIDER_NPI as varchar(10)), '','',' +
'CAST(LOCATION as varchar(25)), '','',' +
'CAST(FACILITY_NAME as varchar(25)), '','',' +
'CAST(FACILITY_NPI as varchar(10)), '','',' +
'CAST(LOG_ID as varchar(8)), '','',' +
'CAST(FINANCIAL_CLASS as varchar(40)), '','',' +
'CAST(PAYOR_NAME as varchar(40)), '','',' +
'CAST(GROUP_NAME as varchar(40)), '','',' +
'CAST(ADMIT_DATE as varchar(10)), '','',' +
'CAST(DISCHARGE_DATE as varchar(10)), '','',' +
'CAST(LENGTH_OF_STAY as varchar(10)), '','',' +
'CAST(DISCHARGE_DISPOSITION as varchar(50)), '','',' +
'CAST(CASE_PROCEDURE_DATE as varchar(10)), '','',' +
'CAST(ProcID_1 as varchar(10)), '','',' +
'CAST(ProcID_2 as varchar(10)), '','',' +
'CAST(ProcID_3 as varchar(10)), '','',' +
'CAST(ProcID_4 as varchar(10)), '','',' +
'CAST(ProcID_5 as varchar(10)), '','',' +
'CAST(ProcID_6 as varchar(10)), '','',' +
'CAST(ProcName_1 as varchar(100)), '','',' +
'CAST(ProcName_2 as varchar(100)), '','',' +
'CAST(ProcName_3 as varchar(100)), '','',' +
'CAST(ProcName_4 as varchar(100)), '','',' +
'CAST(ProcName_5 as varchar(100)), '','',' +
'CAST(ProcName_6 as varchar(100)), '','',' +
'CAST(Orientation_1 as varchar(10)), '','',' +
'CAST(Orientation_2 as varchar(10)), '','',' +
'CAST(Orientation_3 as varchar(10)), '','',' +
'CAST(Orientation_4 as varchar(10)), '','',' +
'CAST(Orientation_5 as varchar(10)), '','',' +
'CAST(Orientation_6 as varchar(10)), '','',' +
'CAST(PRE_OP_DX as varchar(8)), '','',' +
'CAST(PREOPDX_1 as varchar(8)), '','',' +
'CAST(PREOPDX_2 as varchar(8)), '','',' +
'CAST(PREOPDX_3 as varchar(8)), '','',' +
'CAST(PREOPDX_4 as varchar(8)), '','',' +
'CAST(PREOPDX_5 as varchar(8)), '','',' +
'CAST(PREOPDX_6 as varchar(8)), '','',' +
'CAST(PREOPDX_DESC_1 as varchar(50)), '','',' +
'CAST(PREOPDX_DESC_2 as varchar(50)), '','',' +
'CAST(PREOPDX_DESC_3 as varchar(50)), '','',' +
'CAST(PREOPDX_DESC_4 as varchar(50)), '','',' +
'CAST(PREOPDX_DESC_5 as varchar(50)), '','',' +
'CAST(PREOPDX_DESC_6 as varchar(50)), '','',' +
'CAST(PROCEDURE_DATE as varchar(10)), '','',' +
'CAST(ACCOUNT_ID as varchar(10)), '','',' +
'CAST(PX_1 as varchar(8)), '','',' +
'CAST(PX_2 as varchar(8)), '','',' +
'CAST(PX_3 as varchar(8)), '','',' +
'CAST(PX_4 as varchar(8)), '','',' +
'CAST(PX_5 as varchar(8)), '','',' +
'CAST(PX_6 as varchar(8)), '','',' +
'CAST(PX_7 as varchar(8)), '','',' +
'CAST(PX_8 as varchar(8)), '','',' +
'CAST(PX_9 as varchar(8)), '','',' +
'CAST(PX_10 as varchar(8)), '','',' +
'CAST(implant_log_id as varchar(8)), '','',' +
'CAST(IMPLANT_ID_1 as varchar(8)), '','',' +
'CAST(IMPLANT_ID_2 as varchar(8)), '','',' +
'CAST(IMPLANT_ID_3 as varchar(8)), '','',' +
'CAST(IMPLANT_ID_4 as varchar(8)), '','',' +
'CAST(IMPLANT_ID_5 as varchar(8)), '','',' +
'CAST(IMPLANT_ID_6 as varchar(8)), '','',' +
'CAST(IMPLANT_ID_7 as varchar(8)), '','',' +
'CAST(IMPLANT_ID_8 as varchar(8)), '','',' +
'CAST(IMPLANT_ID_9 as varchar(8)), '','',' +
'CAST(IMPLANT_ID_10 as varchar(8)), '','',' +
'CAST(IMPLANT_ID_11 as varchar(8)), '','',' +
'CAST(IMPLANT_ID_12 as varchar(8)), '','',' +
'CAST(IMPLANT_ID_13 as varchar(8)), '','',' +
'CAST(IMPLANT_ID_14 as varchar(8)), '','',' +
'CAST(IMPLANT_ID_15 as varchar(8)), '','',' +
'CAST(IMPLANT_ID_16 as varchar(8)), '','',' +
'CAST(IMPLANT_ID_17 as varchar(8)), '','',' +
'CAST(IMPLANT_ID_18 as varchar(8)), '','',' +
'CAST(IMPLANT_ID_19 as varchar(8)), '','',' +
'CAST(IMPLANT_ID_20 as varchar(8)), '','',' +
'CAST(MANUFACTURER_1 as varchar(50)), '','',' +
'CAST(MANUFACTURER_2 as varchar(50)), '','',' +
'CAST(MANUFACTURER_3 as varchar(50)), '','',' +
'CAST(MANUFACTURER_4 as varchar(50)), '','',' +
'CAST(MANUFACTURER_5 as varchar(50)), '','',' +
'CAST(MANUFACTURER_6 as varchar(50)), '','',' +
'CAST(MANUFACTURER_7 as varchar(50)), '','',' +
'CAST(MANUFACTURER_8 as varchar(50)), '','',' +
'CAST(MANUFACTURER_9 as varchar(50)), '','',' +
'CAST(MANUFACTURER_10 as varchar(50)), '','',' +
'CAST(MANUFACTURER_11 as varchar(50)), '','',' +
'CAST(MANUFACTURER_12 as varchar(50)), '','',' +
'CAST(MANUFACTURER_13 as varchar(50)), '','',' +
'CAST(MANUFACTURER_14 as varchar(50)), '','',' +
'CAST(MANUFACTURER_15 as varchar(50)), '','',' +
'CAST(MANUFACTURER_16 as varchar(50)), '','',' +
'CAST(MANUFACTURER_17 as varchar(50)), '','',' +
'CAST(MANUFACTURER_18 as varchar(50)), '','',' +
'CAST(MANUFACTURER_19 as varchar(50)), '','',' +
'CAST(MANUFACTURER_20 as varchar(50)), '','',' +
'CAST(COMPONENT_NAME_1 as varchar(100)), '','',' +
'CAST(COMPONENT_NAME_2 as varchar(100)), '','',' +
'CAST(COMPONENT_NAME_3 as varchar(100)), '','',' +
'CAST(COMPONENT_NAME_4 as varchar(100)), '','',' +
'CAST(COMPONENT_NAME_5 as varchar(100)), '','',' +
'CAST(COMPONENT_NAME_6 as varchar(100)), '','',' +
'CAST(COMPONENT_NAME_7 as varchar(100)), '','',' +
'CAST(COMPONENT_NAME_8 as varchar(100)), '','',' +
'CAST(COMPONENT_NAME_9 as varchar(100)), '','',' +
'CAST(COMPONENT_NAME_10 as varchar(100)), '','',' +
'CAST(COMPONENT_NAME_11 as varchar(100)), '','',' +
'CAST(COMPONENT_NAME_12 as varchar(100)), '','',' +
'CAST(COMPONENT_NAME_13 as varchar(100)), '','',' +
'CAST(COMPONENT_NAME_14 as varchar(100)), '','',' +
'CAST(COMPONENT_NAME_15 as varchar(100)), '','',' +
'CAST(COMPONENT_NAME_16 as varchar(100)), '','',' +
'CAST(COMPONENT_NAME_17 as varchar(100)), '','',' +
'CAST(COMPONENT_NAME_18 as varchar(100)), '','',' +
'CAST(COMPONENT_NAME_19 as varchar(100)), '','',' +
'CAST(COMPONENT_NAME_20 as varchar(100)), '','',' +
'CAST(CATALOG_NUMBER_1 as varchar(10)), '','',' +
'CAST(CATALOG_NUMBER_2 as varchar(10)), '','',' +
'CAST(CATALOG_NUMBER_3 as varchar(10)), '','',' +
'CAST(CATALOG_NUMBER_4 as varchar(10)), '','',' +
'CAST(CATALOG_NUMBER_5 as varchar(10)), '','',' +
'CAST(CATALOG_NUMBER_6 as varchar(10)), '','',' +
'CAST(CATALOG_NUMBER_7 as varchar(10)), '','',' +
'CAST(CATALOG_NUMBER_8 as varchar(10)), '','',' +
'CAST(CATALOG_NUMBER_9 as varchar(10)), '','',' +
'CAST(CATALOG_NUMBER_10 as varchar(10)), '','',' +
'CAST(CATALOG_NUMBER_11 as varchar(10)), '','',' +
'CAST(CATALOG_NUMBER_12 as varchar(10)), '','',' +
'CAST(CATALOG_NUMBER_13 as varchar(10)), '','',' +
'CAST(CATALOG_NUMBER_14 as varchar(10)), '','',' +
'CAST(CATALOG_NUMBER_15 as varchar(10)), '','',' +
'CAST(CATALOG_NUMBER_16 as varchar(10)), '','',' +
'CAST(CATALOG_NUMBER_17 as varchar(10)), '','',' +
'CAST(CATALOG_NUMBER_18 as varchar(10)), '','',' +
'CAST(CATALOG_NUMBER_19 as varchar(10)), '','',' +
'CAST(CATALOG_NUMBER_20 as varchar(10)), '','',' +
'CAST(LOT_NUMBER_1 as varchar(10)), '','',' +
'CAST(LOT_NUMBER_2 as varchar(10)), '','',' +
'CAST(LOT_NUMBER_3 as varchar(10)), '','',' +
'CAST(LOT_NUMBER_4 as varchar(10)), '','',' +
'CAST(LOT_NUMBER_5 as varchar(10)), '','',' +
'CAST(LOT_NUMBER_6 as varchar(10)), '','',' +
'CAST(LOT_NUMBER_7 as varchar(10)), '','',' +
'CAST(LOT_NUMBER_8 as varchar(10)), '','',' +
'CAST(LOT_NUMBER_9 as varchar(10)), '','',' +
'CAST(LOT_NUMBER_10 as varchar(10)), '','',' +
'CAST(LOT_NUMBER_11 as varchar(10)), '','',' +
'CAST(LOT_NUMBER_12 as varchar(10)), '','',' +
'CAST(LOT_NUMBER_13 as varchar(10)), '','',' +
'CAST(LOT_NUMBER_14 as varchar(10)), '','',' +
'CAST(LOT_NUMBER_15 as varchar(10)), '','',' +
'CAST(LOT_NUMBER_16 as varchar(10)), '','',' +
'CAST(LOT_NUMBER_17 as varchar(10)), '','',' +
'CAST(LOT_NUMBER_18 as varchar(10)), '','',' +
'CAST(LOT_NUMBER_19 as varchar(10)), '','',' +
'CAST(LOT_NUMBER_20 as varchar(10)),' +
'FROM ##OUTPUT'



select @prevAdvancedOptions = cast(value_in_use as int) from master.sys.configurations where name = 'show advanced options'
select @prevXpCmdshell = cast(value_in_use as int) from master.sys.configurations where name = 'xp_cmdshell'


if (@prevAdvancedOptions = 0)
begin
    exec sp_configure 'show advanced options', 1
    reconfigure
end

if (@prevXpCmdshell = 0)
begin
    exec sp_configure 'xp_cmdshell', 1
    reconfigure
end


/*Execute Command*/

SELECT 
	@sql = 'sqlcmd -S ' + @@SERVERNAME + ' -d HPIDW -E -h -1 -Q "' + @query + '" -o "' + @path + @filename	+ '.csv" -s ","'

EXEC master..xp_cmdshell @sql

PRINT @sql



if (@prevXpCmdshell = 0)
begin
    exec sp_configure 'xp_cmdshell', 0
    reconfigure
end

if (@prevAdvancedOptions = 0)
begin
    exec sp_configure 'show advanced options', 0
    reconfigure
end

/*Clean up tables after use*/
DROP TABLE #BASE
DROP TABLE #OR_CASE
DROP TABLE #PAT_INFO
DROP TABLE #PHONE_CONTACT
DROP TABLE #COVERAGE
DROP TABLE #OR_CASE_PROC
DROP TABLE #OR_PROC
DROP TABLE #PIVOT_PROC
DROP TABLE #OR_CASE_INFO
DROP TABLE #GET_CPT
DROP TABLE #ANES_PRIMARY_NM
DROP TABLE #PREOPDX_INFO
DROP TABLE #IMPLANT_INFO
DROP TABLE #FIN_INFO
DROP TABLE #CPT_FINAL
--DROP TABLE ##OUTPUT

END
GO
