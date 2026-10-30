/*==============================================================================
  rpt.spSelectAJRRProcedures2027
  AJRR Hip and Knee Arthroplasty - Procedure Layout, MDD version 2026

  Output matches the "Procedure Layout" tab of Generic_MDD_AJRR.xlsx column for
  column (101 columns, same names, same order).

  Requires : SQL Server 2017+ (STRING_AGG), dim.AJRRTriggerCode, dim.AJRRFacility
             (see 01_AJRR_reference_tables.sql)

  2026 MDD rules applied
    - "NR" is never output. Anything not recorded = '9999'.
    - Multi-value fields are single columns, values separated by |
        PX                          up to 10 CPT / ICD-10-PCS trigger codes
        DX                          principal diagnosis (see @MaxDxCodes)
        ComponentName^Mfg^Cat^Lot   one ^-delimited set per implant
        CoM^POA                     secondary dx code ^ POA flag, up to 20
    - Dates YYYY-MM-DD, datetimes YYYY-MM-DDTHH:MM:SS, times HH:MM:SS
    - Bilateral cases are split into one row per side (MDD, PX element)
    - Case selection uses the AAOS trigger list (dim.AJRRTriggerCode) instead
      of Epic grouper 122095. Hip/knee arthroplasty qualifies on a primary
      procedure code alone; a 2026 Hip Fracture case needs a hip fracture
      procedure code AND a hip fracture principal diagnosis (AAOS, 2026-10).
    - 600-character limits apply to the whole cell (AAOS); not enforced here.
    - Symbols are allowed in ComponentName / Mfg (AAOS); only ^ and | are scrubbed.

  Remaining assumptions (search "ASSUMPTION")
  Items needing a local mapping before they can carry real values (search "TODO")

  Linked-server pattern: every Clarity read is a single OPENQUERY scoped by
  @LogFilter (in-scope OR logs), so filtering happens on the Clarity side and
  only the needed rows cross the link. All joins / aggregation are local.
==============================================================================*/
CREATE   PROCEDURE [rpt].[spSelectAJRRProcedures2027]
    @ExportToTable BIT = 0   -- 1 = write results to rpt.AJRRProcedures2027_Export (used by the CSV export proc)
AS
BEGIN
SET NOCOUNT ON;

/*------------------------------------------------------------------------------
  Parameters / constants
------------------------------------------------------------------------------*/
DECLARE @START_DATE DATE = DATEADD(MONTH, -5, CONVERT(DATE, GETDATE()));
DECLARE @END_DATE   DATE = DATEADD(MONTH,  1, CONVERT(DATE, GETDATE()));

DECLARE @NR              VARCHAR(4)   = '9999';                    -- "Not reported"
DECLARE @InstitutionName VARCHAR(600) = 'HPI COMMUNITY HOSPITAL';
DECLARE @InstitutionNPI  VARCHAR(10)  = '9999';                    -- TODO: system NPI if one applies

DECLARE @MaxPxCodes  INT = 10;   -- MDD: up to 10 procedure codes
DECLARE @MaxDxCodes  INT = 1;    -- AAOS confirmed: DX = principal dx only; secondary dx go to CoM
DECLARE @MaxComCodes INT = 20;   -- MDD: up to 20 comorbidities

DECLARE @LS NVARCHAR(200) = N'[CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM]';
DECLARE @StartKey CHAR(8) = CONVERT(CHAR(8), @START_DATE, 112);
DECLARE @EndKey   CHAR(8) = CONVERT(CHAR(8), @END_DATE,   112);
DECLARE @q   NVARCHAR(MAX);   -- remote query text (OPENQUERY limit is 8 KB)
DECLARE @sql NVARCHAR(MAX);

/* In-scope OR logs: service area 430, surgery date in window, at least one
   OR procedure carrying a 27xxx CPT (every primary trigger CPT is 27xxx).
   Final qualification against the trigger list happens locally.            */
DECLARE @LogFilter NVARCHAR(MAX) = N'
    SELECT ORL.LOG_ID
    FROM Clarity.ORGFILTER.OR_LOG ORL
    INNER JOIN Clarity.ORGFILTER.CLARITY_LOC LOC ON LOC.LOC_ID = ORL.LOC_ID
    WHERE ORL.SURGERY_DATE BETWEEN ''' + @StartKey + N''' AND ''' + @EndKey + N'''
      AND LOC.SERV_AREA_ID = 430
      AND EXISTS (SELECT 1
                  FROM Clarity.ORGFILTER.OR_LOG_ALL_PROC P
                  INNER JOIN Clarity.ORGFILTER.OR_PROC_CPT_ID C ON C.OR_PROC_ID = P.OR_PROC_ID
                  WHERE P.LOG_ID = ORL.LOG_ID
                    AND C.REAL_CPT_CODE LIKE ''27%'')';

DECLARE @HarFilter NVARCHAR(MAX) = N'
    SELECT ENC.HSP_ACCOUNT_ID
    FROM Clarity.ORGFILTER.PAT_OR_ADM_LINK LINK
    INNER JOIN Clarity.ORGFILTER.PAT_ENC_HSP ENC ON ENC.PAT_ENC_CSN_ID = LINK.OR_LINK_CSN
    WHERE LINK.LOG_ID IN (' + @LogFilter + N')';

DROP TABLE IF EXISTS #CASE, #PROCLINE, #CODING, #PAT, #RACE, #SURG, #TIMING, #TOURN,
                     #ROBOT, #ANES, #IMPLANT, #VITALS, #TRIG, #PXCAND, #SIDE, #PX, #DX,
                     #COM, #IMPLANTSTR, #ANESTYPE, #RACECODE, #TIMES, #VITALVAL, #OUT;

/*==============================================================================
  1. REMOTE PULLS (one OPENQUERY each)
==============================================================================*/

/*--- 1a. Case header ---------------------------------------------------------*/
CREATE TABLE #CASE (
     LOG_ID            VARCHAR(18)   NOT NULL PRIMARY KEY
    ,SURGERY_DATE      DATETIME
    ,ASA_RATE_C        VARCHAR(66)
    ,PAT_ID            VARCHAR(18)
    ,PRIMARY_PHYS_ID   VARCHAR(18)
    ,INPATIENT_DATA_ID VARCHAR(18)
    ,OR_LINK_CSN       NUMERIC(18,0)
    ,HSP_ACCOUNT_ID    NUMERIC(18,0)
    ,HOSP_ADMSN_TIME   DATETIME
    ,HOSP_DISCH_TIME   DATETIME
    ,DISCH_DISP_C      VARCHAR(66)
    ,PAT_CLASS_NAME    VARCHAR(254)
    ,REV_LOC_ID        NUMERIC(18,0)
    ,HOSPITAL_NAME     VARCHAR(600)
);
SET @q = N'
SELECT ORL.LOG_ID, ORL.SURGERY_DATE, ORL2.ASA_RATE_C, ORL.PAT_ID, ORL.PRIMARY_PHYS_ID,
       ORL.INPATIENT_DATA_ID, LINK.OR_LINK_CSN, ENC.HSP_ACCOUNT_ID, ENC.HOSP_ADMSN_TIME,
       ENC.HOSP_DISCH_TIME, ENC.DISCH_DISP_C, CLS.NAME AS PAT_CLASS_NAME, DEP.REV_LOC_ID,
       LOC2.LOC_NAME AS HOSPITAL_NAME
FROM Clarity.ORGFILTER.OR_LOG ORL
INNER JOIN Clarity.ORGFILTER.OR_LOG_2 ORL2   ON ORL2.LOG_ID = ORL.LOG_ID
INNER JOIN Clarity.ORGFILTER.OR_LOC ORLOC    ON ORLOC.LOC_ID = ORL.LOC_ID
INNER JOIN Clarity.ORGFILTER.CLARITY_DEP DEP ON DEP.DEPARTMENT_ID = ORLOC.OR_DEPARTMENT_ID
                                            AND DEP.SERV_AREA_ID = 430
LEFT JOIN Clarity.ORGFILTER.CLARITY_LOC LOC2 ON LOC2.LOC_ID = DEP.REV_LOC_ID
LEFT JOIN (SELECT LOG_ID, MIN(OR_LINK_CSN) AS OR_LINK_CSN
           FROM Clarity.ORGFILTER.PAT_OR_ADM_LINK
           WHERE LOG_ID IN (' + @LogFilter + N')
           GROUP BY LOG_ID) LINK ON LINK.LOG_ID = ORL.LOG_ID
LEFT JOIN Clarity.ORGFILTER.PAT_ENC_HSP ENC  ON ENC.PAT_ENC_CSN_ID = LINK.OR_LINK_CSN
LEFT JOIN Clarity.ORGFILTER.ZC_PAT_CLASS CLS ON CLS.ADT_PAT_CLASS_C = ENC.ADT_PAT_CLASS_C
WHERE ORL.LOG_ID IN (' + @LogFilter + N')';
SET @sql = N'INSERT INTO #CASE (LOG_ID, SURGERY_DATE, ASA_RATE_C, PAT_ID, PRIMARY_PHYS_ID, INPATIENT_DATA_ID,
                OR_LINK_CSN, HSP_ACCOUNT_ID, HOSP_ADMSN_TIME, HOSP_DISCH_TIME, DISCH_DISP_C,
                PAT_CLASS_NAME, REV_LOC_ID, HOSPITAL_NAME)
SELECT * FROM OPENQUERY(' + @LS + N', ''' + REPLACE(@q, N'''', N'''''') + N''')';
EXEC sp_executesql @sql;

/*--- 1b. OR procedure lines with every CPT on the procedure record ----------*/
CREATE TABLE #PROCLINE (
     LOG_ID          VARCHAR(18)
    ,PROC_LINE       INT
    ,ALL_APPROACH_C  VARCHAR(66)
    ,LRB_ABBR        VARCHAR(50)
    ,CPT_LINE        INT
    ,CPT_CODE        VARCHAR(20)
    ,PROC_NAME       VARCHAR(300)
);
SET @q = N'
SELECT P.LOG_ID, P.LINE AS PROC_LINE, P.ALL_APPROACH_C, LAT.ABBR AS LRB_ABBR,
       C.LINE AS CPT_LINE, C.REAL_CPT_CODE, PR.PROC_NAME
FROM Clarity.ORGFILTER.OR_LOG_ALL_PROC P
INNER JOIN Clarity.ORGFILTER.OR_PROC_CPT_ID C ON C.OR_PROC_ID = P.OR_PROC_ID
LEFT JOIN Clarity.ORGFILTER.OR_PROC PR        ON PR.OR_PROC_ID = P.OR_PROC_ID
LEFT JOIN Clarity.ORGFILTER.ZC_OR_LRB LAT     ON LAT.LRB_C = P.LRB_C
WHERE P.LOG_ID IN (' + @LogFilter + N')';
SET @sql = N'INSERT INTO #PROCLINE (LOG_ID, PROC_LINE, ALL_APPROACH_C, LRB_ABBR, CPT_LINE, CPT_CODE, PROC_NAME)
SELECT * FROM OPENQUERY(' + @LS + N', ''' + REPLACE(@q, N'''', N'''''') + N''')';
EXEC sp_executesql @sql;

/*--- 1c. HAR coding: final dx (3) and ICD-10 procedures (11) ----------------*/
CREATE TABLE #CODING (
     HSP_ACCOUNT_ID NUMERIC(18,0)
    ,SOURCE_KEY     INT
    ,LINE           INT
    ,CODE           VARCHAR(20)
    ,DX_POA_NAME    VARCHAR(254)
);
SET @q = N'
SELECT X.HSP_ACCOUNT_ID, X.SOURCE_KEY, X.LINE, X.REF_BILL_CODE, X.DX_POA_NAME
FROM Clarity.ORGFILTER.V_CODING_ALL_DX_PX_LIST X
WHERE X.SOURCE_KEY IN (3, 11)
  AND X.HSP_ACCOUNT_ID IN (' + @HarFilter + N')';
SET @sql = N'INSERT INTO #CODING (HSP_ACCOUNT_ID, SOURCE_KEY, LINE, CODE, DX_POA_NAME)
SELECT * FROM OPENQUERY(' + @LS + N', ''' + REPLACE(@q, N'''', N'''''') + N''')';
EXEC sp_executesql @sql;

/*--- 1d. Patient demographics ------------------------------------------------*/
CREATE TABLE #PAT (
     PAT_ID          VARCHAR(18) NOT NULL PRIMARY KEY
    ,PAT_MRN_ID      VARCHAR(102)
    ,SSN             VARCHAR(18)
    ,PAT_FIRST_NAME  VARCHAR(200)
    ,PAT_MIDDLE_NAME VARCHAR(200)
    ,PAT_LAST_NAME   VARCHAR(200)
    ,BIRTH_DATE      DATETIME
    ,DEATH_DATE      DATETIME
    ,SEX_NAME        VARCHAR(254)
    ,ETHNIC_GROUP_C  VARCHAR(66)
    ,CITY            VARCHAR(100)
    ,STATE_ABBR      VARCHAR(50)
    ,ZIP             VARCHAR(50)
    ,COUNTRY_NAME    VARCHAR(254)
    ,EMAIL_ADDRESS   VARCHAR(254)
    ,HOME_PHONE      VARCHAR(50)
);
SET @q = N'
SELECT PAT.PAT_ID, PAT.PAT_MRN_ID, PAT.SSN, PAT.PAT_FIRST_NAME, PAT.PAT_MIDDLE_NAME, PAT.PAT_LAST_NAME,
       PAT.BIRTH_DATE, PAT.DEATH_DATE, SEX.NAME AS SEX_NAME, PAT.ETHNIC_GROUP_C, PAT.CITY,
       ST.ABBR AS STATE_ABBR, PAT.ZIP, CTRY.NAME AS COUNTRY_NAME, PAT.EMAIL_ADDRESS, PAT.HOME_PHONE
FROM Clarity.ORGFILTER.PATIENT PAT
LEFT JOIN Clarity.ORGFILTER.ZC_SEX SEX      ON SEX.INTERNAL_ID  = PAT.SEX_C
LEFT JOIN Clarity.ORGFILTER.ZC_STATE ST     ON ST.INTERNAL_ID   = PAT.STATE_C
LEFT JOIN Clarity.ORGFILTER.ZC_COUNTRY CTRY ON CTRY.INTERNAL_ID = PAT.COUNTRY_C
WHERE PAT.PAT_ID IN (SELECT ORL.PAT_ID FROM Clarity.ORGFILTER.OR_LOG ORL
                     WHERE ORL.LOG_ID IN (' + @LogFilter + N'))';
SET @sql = N'INSERT INTO #PAT
SELECT * FROM OPENQUERY(' + @LS + N', ''' + REPLACE(@q, N'''', N'''''') + N''')';
EXEC sp_executesql @sql;

/*--- 1e. Patient race (multi-row) --------------------------------------------*/
CREATE TABLE #RACE (PAT_ID VARCHAR(18), RACE_NAME VARCHAR(254));
SET @q = N'
SELECT R.PAT_ID, ZR.NAME AS RACE_NAME
FROM Clarity.ORGFILTER.PATIENT_RACE R
LEFT JOIN Clarity.ORGFILTER.ZC_PATIENT_RACE ZR ON ZR.PATIENT_RACE_C = R.PATIENT_RACE_C
WHERE R.PAT_ID IN (SELECT ORL.PAT_ID FROM Clarity.ORGFILTER.OR_LOG ORL
                   WHERE ORL.LOG_ID IN (' + @LogFilter + N'))';
SET @sql = N'INSERT INTO #RACE (PAT_ID, RACE_NAME)
SELECT * FROM OPENQUERY(' + @LS + N', ''' + REPLACE(@q, N'''', N'''''') + N''')';
EXEC sp_executesql @sql;

/*--- 1f. Surgeon -------------------------------------------------------------*/
CREATE TABLE #SURG (PROV_ID VARCHAR(18) NOT NULL PRIMARY KEY, PROV_NAME VARCHAR(200), NPI VARCHAR(20));
SET @q = N'
SELECT SER.PROV_ID, SER.PROV_NAME, SER2.NPI
FROM Clarity.ORGFILTER.CLARITY_SER SER
LEFT JOIN Clarity.ORGFILTER.CLARITY_SER_2 SER2 ON SER2.PROV_ID = SER.PROV_ID
WHERE SER.PROV_ID IN (SELECT ORL.PRIMARY_PHYS_ID FROM Clarity.ORGFILTER.OR_LOG ORL
                      WHERE ORL.LOG_ID IN (' + @LogFilter + N'))';
SET @sql = N'INSERT INTO #SURG (PROV_ID, PROV_NAME, NPI)
SELECT * FROM OPENQUERY(' + @LS + N', ''' + REPLACE(@q, N'''', N'''''') + N''')';
EXEC sp_executesql @sql;

/*--- 1g. OR timing events (700 in, 1000 incision, 1100 close, 1200 out) ----*/
CREATE TABLE #TIMING (LOG_ID VARCHAR(18), TIMING_EVENT_C VARCHAR(66), TIMING_EVENT_DTTM DATETIME);
SET @q = N'
SELECT T.LOG_ID, T.TIMING_EVENT_C, T.TIMING_EVENT_DTTM
FROM Clarity.ORGFILTER.OR_LOG_TIMING_EVENTS T
WHERE T.TIMING_EVENT_C IN (700, 1000, 1100, 1200)
  AND T.LOG_ID IN (' + @LogFilter + N')';
SET @sql = N'INSERT INTO #TIMING (LOG_ID, TIMING_EVENT_C, TIMING_EVENT_DTTM)
SELECT * FROM OPENQUERY(' + @LS + N', ''' + REPLACE(@q, N'''', N'''''') + N''')';
EXEC sp_executesql @sql;

/*--- 1h. Tourniquet ----------------------------------------------------------*/
CREATE TABLE #TOURN (LOG_ID VARCHAR(18) NOT NULL PRIMARY KEY);
SET @q = N'
SELECT DISTINCT T.LOG_ID
FROM Clarity.ORGFILTER.OR_LOG_LN_TOURN T
WHERE T.LOG_ID IN (' + @LogFilter + N')';
SET @sql = N'INSERT INTO #TOURN (LOG_ID)
SELECT * FROM OPENQUERY(' + @LS + N', ''' + REPLACE(@q, N'''', N'''''') + N''')';
EXEC sp_executesql @sql;

/*--- 1i. Robotic equipment (types 661, 1185) ---------------------------------*/
CREATE TABLE #ROBOT (LOG_ID VARCHAR(18) NOT NULL PRIMARY KEY);
SET @q = N'
SELECT DISTINCT E.OR_CASE_ID AS LOG_ID
FROM Clarity.ORGFILTER.OR_CASE_EQUIP_NEED E
WHERE E.EQUIPMENT_TYPE_C IN (661, 1185)
  AND E.OR_CASE_ID IN (' + @LogFilter + N')';
SET @sql = N'INSERT INTO #ROBOT (LOG_ID)
SELECT * FROM OPENQUERY(' + @LS + N', ''' + REPLACE(@q, N'''', N'''''') + N''')';
EXEC sp_executesql @sql;

/*--- 1j. Anesthesia types (all lines) ----------------------------------------*/
CREATE TABLE #ANES (LOG_ID VARCHAR(18), LINE INT, LOG_ANESTH_TYPE_C VARCHAR(66));
SET @q = N'
SELECT A.LOG_ID, A.LINE, A.LOG_ANESTH_TYPE_C
FROM Clarity.ORGFILTER.OR_LOG_ANES_TYPES A
WHERE A.LOG_ID IN (' + @LogFilter + N')';
SET @sql = N'INSERT INTO #ANES (LOG_ID, LINE, LOG_ANESTH_TYPE_C)
SELECT * FROM OPENQUERY(' + @LS + N', ''' + REPLACE(@q, N'''', N'''''') + N''')';
EXEC sp_executesql @sql;

/*--- 1k. Implants ------------------------------------------------------------*/
CREATE TABLE #IMPLANT (
     LOG_ID        VARCHAR(18)
    ,IMPLANT_ID    VARCHAR(18)
    ,IMPLANT_NAME  VARCHAR(600)
    ,MFG_NAME      VARCHAR(600)
    ,MODEL_NUMBER  VARCHAR(600)
    ,LOT_NUMBER    VARCHAR(600)
);
SET @q = N'
SELECT II.IMPLANT_LOG_ID, II.IMPLANT_ID, IMP.IMPLANT_NAME, MFG.NAME AS MFG_NAME,
       IMP.MODEL_NUMBER, IMP.LOT_NUMBER
FROM Clarity.ORGFILTER.OR_IMP_IMPLANT II
LEFT JOIN Clarity.ORGFILTER.OR_IMP IMP             ON IMP.IMPLANT_ID  = II.IMPLANT_ID
LEFT JOIN Clarity.ORGFILTER.ZC_OR_MANUFACTURER MFG ON MFG.INTERNAL_ID = IMP.MANUFACTURER_C
WHERE II.IMPLANT_LOG_ID IN (' + @LogFilter + N')';
SET @sql = N'INSERT INTO #IMPLANT (LOG_ID, IMPLANT_ID, IMPLANT_NAME, MFG_NAME, MODEL_NUMBER, LOT_NUMBER)
SELECT * FROM OPENQUERY(' + @LS + N', ''' + REPLACE(@q, N'''', N'''''') + N''')';
EXEC sp_executesql @sql;

/*--- 1l. Height (11, in), weight (14, oz), BMI (301070) ----------------------*/
CREATE TABLE #VITALS (INPATIENT_DATA_ID VARCHAR(18), FLO_MEAS_ID VARCHAR(18), MEAS_VALUE VARCHAR(2500), RECORDED_TIME DATETIME);
SET @q = N'
SELECT FR.INPATIENT_DATA_ID, MEA.FLO_MEAS_ID, MEA.MEAS_VALUE, MEA.RECORDED_TIME
FROM Clarity.ORGFILTER.IP_FLWSHT_REC FR
INNER JOIN Clarity.ORGFILTER.IP_FLWSHT_MEAS MEA ON MEA.FSD_ID = FR.FSD_ID
WHERE MEA.FLO_MEAS_ID IN (''11'', ''14'', ''301070'')
  AND MEA.MEAS_VALUE IS NOT NULL
  AND FR.INPATIENT_DATA_ID IN (SELECT ORL.INPATIENT_DATA_ID FROM Clarity.ORGFILTER.OR_LOG ORL
                               WHERE ORL.LOG_ID IN (' + @LogFilter + N'))';
SET @sql = N'INSERT INTO #VITALS (INPATIENT_DATA_ID, FLO_MEAS_ID, MEAS_VALUE, RECORDED_TIME)
SELECT * FROM OPENQUERY(' + @LS + N', ''' + REPLACE(@q, N'''', N'''''') + N''')';
EXEC sp_executesql @sql;

/*==============================================================================
  2. TRIGGER QUALIFICATION, PX, AND ROW GRAIN (one row per LOG_ID + side)
==============================================================================*/

/* Procedure-type trigger codes collapsed to the join key */
SELECT  T.CodeSystem
       ,T.BaseCode
       ,MAX(CAST(T.IsPrimaryTrigger AS INT))      AS IsPrimary
       ,MAX(CAST(T.IsHipFractureTrigger AS INT))  AS IsHipFx
       ,MAX(T.Joint)                              AS Joint
       ,MAX(T.Laterality)                         AS Laterality
INTO #TRIG
FROM dim.AJRRTriggerCode T
WHERE T.CodeSystem IN ('CPT4', 'HCPCS Level II', 'ICD10PCS')
  AND (T.IsPrimaryTrigger = 1 OR T.IsSupplementalTrigger = 1)
GROUP BY T.CodeSystem, T.BaseCode;

/* Candidate PX codes per case: OR CPTs (side from OR laterality) and
   HAR ICD-10-PCS (side embedded in the code). SortKey puts CPTs first. */
CREATE TABLE #PXCAND (
     LOG_ID    VARCHAR(18)
    ,Code      VARCHAR(20)
    ,Side      CHAR(1)        -- R / L / B / NULL
    ,IsPrimary INT
    ,IsHipFx   INT
    ,Joint     VARCHAR(5)
    ,ApproachC VARCHAR(66)
    ,SortKey   BIGINT
    ,ProcName  VARCHAR(300)
);

INSERT INTO #PXCAND
SELECT  PL.LOG_ID
       ,LTRIM(RTRIM(PL.CPT_CODE))
       ,CASE WHEN PL.LRB_ABBR LIKE 'B%' THEN 'B'
             WHEN PL.LRB_ABBR LIKE 'R%' THEN 'R'
             WHEN PL.LRB_ABBR LIKE 'L%' THEN 'L' END
       ,T.IsPrimary
       ,T.IsHipFx
       ,T.Joint
       ,PL.ALL_APPROACH_C
       ,1000000000 + CAST(PL.PROC_LINE AS BIGINT) * 1000 + PL.CPT_LINE
       ,PL.PROC_NAME
FROM #PROCLINE PL
INNER JOIN #CASE C  ON C.LOG_ID = PL.LOG_ID
INNER JOIN #TRIG T  ON T.CodeSystem IN ('CPT4', 'HCPCS Level II')
                   AND T.BaseCode = LTRIM(RTRIM(PL.CPT_CODE));

INSERT INTO #PXCAND
SELECT  C.LOG_ID
       ,REPLACE(X.CODE, '.', '')
       ,T.Laterality
       ,T.IsPrimary
       ,T.IsHipFx
       ,T.Joint
       ,NULL
       ,2000000000 + X.LINE
       ,NULL
FROM #CODING X
INNER JOIN #CASE C ON C.HSP_ACCOUNT_ID = X.HSP_ACCOUNT_ID
INNER JOIN #TRIG T ON T.CodeSystem = 'ICD10PCS'
                  AND T.BaseCode = REPLACE(X.CODE, '.', '')
WHERE X.SOURCE_KEY = 11;

/* Hip fracture rule: a hip fracture procedure code only counts as a primary
   trigger when the principal diagnosis (DX) is on the hip fracture dx list.
   Otherwise it is kept as an ordinary PX code but cannot qualify the case. */
UPDATE P
SET P.IsPrimary = 0
FROM #PXCAND P
WHERE P.IsHipFx = 1
  AND P.IsPrimary = 1
  AND NOT EXISTS (SELECT 1
                  FROM #CASE C
                  INNER JOIN #CODING X           ON X.HSP_ACCOUNT_ID = C.HSP_ACCOUNT_ID
                                                AND X.SOURCE_KEY = 3
                                                AND X.LINE = 1
                  INNER JOIN dim.AJRRTriggerCode T ON T.CodeSystem = 'ICD10CM'
                                                AND T.BaseCode = REPLACE(LTRIM(RTRIM(X.CODE)), '.', '')
                                                AND T.IsHipFractureTrigger = 1
                                                AND T.IsPrimaryTrigger = 1
                  WHERE C.LOG_ID = P.LOG_ID);

/* Row grain. A case qualifies only with at least one PRIMARY trigger code.
   Bilateral (B, or both R and L primaries) -> one R row and one L row.
   No laterality on any primary code -> one row with Side 'U' (DXLat 9999). */
CREATE TABLE #SIDE (
     LOG_ID    VARCHAR(18) NOT NULL
    ,Side      CHAR(1)     NOT NULL
    ,Joint     VARCHAR(5)
    ,ApproachC VARCHAR(66)
    ,ProcName  VARCHAR(300)
    ,IsRobotic BIT
    ,PRIMARY KEY (LOG_ID, Side)
);
INSERT INTO #SIDE (LOG_ID, Side)
SELECT DISTINCT P.LOG_ID, S.Side
FROM #PXCAND P
CROSS JOIN (VALUES ('R'), ('L')) S(Side)
WHERE P.IsPrimary = 1
  AND (P.Side = S.Side OR P.Side = 'B')
UNION
SELECT P.LOG_ID, 'U'
FROM #PXCAND P
WHERE P.IsPrimary = 1
GROUP BY P.LOG_ID
HAVING COUNT(P.Side) = 0;

/* Joint (Hip/Knee), approach and OR procedure name come from the first
   primary code on that side. Robotic = any OR procedure on that side named
   "...ROBOT-ASSISTED..." (Epic build: ALL_APPROACH_C is never populated and
   the robot is identified by procedure name, not equipment type).        */
UPDATE S
SET  S.Joint     = J.Joint
    ,S.ApproachC = J.ApproachC
    ,S.ProcName  = J.ProcName
    ,S.IsRobotic = CASE WHEN EXISTS (SELECT 1 FROM #PXCAND R
                                     WHERE R.LOG_ID = S.LOG_ID
                                       AND R.ProcName LIKE '%ROBOT%'
                                       AND (R.Side IS NULL OR S.Side = 'U' OR R.Side = S.Side OR R.Side = 'B'))
                        THEN 1 ELSE 0 END
FROM #SIDE S
OUTER APPLY (SELECT TOP 1 P.Joint, P.ApproachC, P.ProcName
             FROM #PXCAND P
             WHERE P.LOG_ID = S.LOG_ID
               AND P.IsPrimary = 1
               AND (P.Side IS NULL OR S.Side = 'U' OR P.Side = S.Side OR P.Side = 'B')
             ORDER BY CASE WHEN P.Joint IS NULL THEN 1 ELSE 0 END, P.SortKey) J;

/* PX: primary + supplemental codes for that side, max 10, | separated */
WITH X AS (
    SELECT S.LOG_ID, S.Side, P.Code, MIN(P.SortKey) AS SortKey
    FROM #SIDE S
    INNER JOIN #PXCAND P ON P.LOG_ID = S.LOG_ID
                        AND (P.Side IS NULL OR S.Side = 'U' OR P.Side = S.Side OR P.Side = 'B')
    GROUP BY S.LOG_ID, S.Side, P.Code
), R AS (
    SELECT X.*, ROW_NUMBER() OVER (PARTITION BY X.LOG_ID, X.Side ORDER BY X.SortKey) AS rn
    FROM X
)
SELECT  R.LOG_ID
       ,R.Side
       ,STRING_AGG(CONVERT(VARCHAR(MAX), R.Code), '|') WITHIN GROUP (ORDER BY R.rn) AS PX
       ,MAX(CASE WHEN R.Code IN ('20985', '0054T', '0055T') THEN 1 ELSE 0 END)      AS HasNavCode
INTO #PX
FROM R
WHERE R.rn <= @MaxPxCodes
GROUP BY R.LOG_ID, R.Side;

/*==============================================================================
  3. MULTI-VALUE FIELDS: DX, CoM^POA, IMPLANTS, ANESTHESIA
==============================================================================*/

/* DX: final coded diagnoses, principal first */
SELECT  X.HSP_ACCOUNT_ID
       ,STRING_AGG(CONVERT(VARCHAR(MAX), LTRIM(RTRIM(X.CODE))), '|') WITHIN GROUP (ORDER BY X.LINE) AS DX
INTO #DX
FROM #CODING X
WHERE X.SOURCE_KEY = 3
  AND X.LINE <= @MaxDxCodes
  AND X.CODE IS NOT NULL
GROUP BY X.HSP_ACCOUNT_ID;

/* CoM^POA: secondary final dx (line 2+), code^POA, | separated, max 20.
   POA values per MDD: Y, N, 1 (exempt), U, W, 9999. */
WITH D AS (
    SELECT  X.HSP_ACCOUNT_ID
           ,X.LINE
           ,REPLACE(REPLACE(LTRIM(RTRIM(X.CODE)), '^', ''), '|', '') AS Code
           ,CASE WHEN X.DX_POA_NAME = 'Yes'                  THEN 'Y'
                 WHEN X.DX_POA_NAME = 'No'                   THEN 'N'
                 WHEN X.DX_POA_NAME LIKE 'Exempt%'           THEN '1'
                 WHEN X.DX_POA_NAME LIKE 'Clinically Undet%' THEN 'W'
                 WHEN X.DX_POA_NAME LIKE 'Unknown%'          THEN 'U'
                 ELSE '9999' END AS POA
           ,ROW_NUMBER() OVER (PARTITION BY X.HSP_ACCOUNT_ID ORDER BY X.LINE) AS rn
    FROM #CODING X
    WHERE X.SOURCE_KEY = 3
      AND X.LINE > 1
      AND X.CODE IS NOT NULL
)
SELECT  D.HSP_ACCOUNT_ID
       ,STRING_AGG(CONVERT(VARCHAR(MAX), D.Code + '^' + D.POA), '|') WITHIN GROUP (ORDER BY D.LINE) AS CoM_POA
INTO #COM
FROM D
WHERE D.rn <= @MaxComCodes
GROUP BY D.HSP_ACCOUNT_ID;

/* Implants: ComponentName^Mfg^Cat^Lot, | separated.
   Delimiters, tabs and line breaks inside the data are replaced with spaces;
   any missing part is 9999 so the 4-part structure always holds.
   Epic supply names carry a " - SNA - LOG#######" (or " - SN - LOG") suffix and
   manufacturers an "HPI-" prefix; both are stripped (saves ~25 chars/component
   against the 600-character cell limit).
   TODO: bilateral cases currently carry all of the case's implants on both
         rows; split by side if Epic records implant laterality.            */
SELECT  I.LOG_ID
       ,STRING_AGG(CONVERT(VARCHAR(MAX), N.ComponentName + '^' + N.Mfg + '^' + N.Cat + '^' + N.Lot), '|')
            WITHIN GROUP (ORDER BY I.IMPLANT_ID) AS Implants
INTO #IMPLANTSTR
FROM #IMPLANT I
CROSS APPLY (
    SELECT  ImplantName = CASE WHEN PATINDEX('% - SN% - LOG[0-9]%', I.IMPLANT_NAME) > 0
                               THEN LEFT(I.IMPLANT_NAME, PATINDEX('% - SN% - LOG[0-9]%', I.IMPLANT_NAME) - 1)
                               ELSE I.IMPLANT_NAME END
           ,MfgName     = CASE WHEN I.MFG_NAME LIKE 'HPI-%' THEN SUBSTRING(I.MFG_NAME, 5, 600)
                               ELSE I.MFG_NAME END
) RAW
CROSS APPLY (
    SELECT  ComponentName = ISNULL(NULLIF(LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(RAW.ImplantName, '^', ' '), '|', ' '), CHAR(9), ' '), CHAR(10), ' '), CHAR(13), ' '))), ''), '9999')
           ,Mfg           = ISNULL(NULLIF(LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(RAW.MfgName,     '^', ' '), '|', ' '), CHAR(9), ' '), CHAR(10), ' '), CHAR(13), ' '))), ''), '9999')
           ,Cat           = ISNULL(NULLIF(LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(I.MODEL_NUMBER, '^', ' '), '|', ' '), CHAR(9), ' '), CHAR(10), ' '), CHAR(13), ' '))), ''), '9999')
           ,Lot           = ISNULL(NULLIF(LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(I.LOT_NUMBER,   '^', ' '), '|', ' '), CHAR(9), ' '), CHAR(10), ' '), CHAR(13), ' '))), ''), '9999')
) N
WHERE EXISTS (SELECT 1 FROM #SIDE S WHERE S.LOG_ID = I.LOG_ID)
GROUP BY I.LOG_ID;

/* Anesthesia (ZC_OR_ANESTH_TYPE confirmed):
     80  General                       -> 1 General
     240 Total Intravenous Anesthesia  -> 1 General (TIVA is general anesthesia)
     180 Spinal                        -> 2 Spinal
     40  Regional                      -> 4 Nerve block (hip) / 5 Nerve block (knee)
     160 Monitor Anesthesia Care       -> 6 MAC
   AJRR 3 (Epidural) has no Epic type in this build.
   DISTINCT collapses General + TIVA on the same case to a single 1. */
SELECT  A.LOG_ID
       ,A.Side
       ,STRING_AGG(A.AnesCode, ',') WITHIN GROUP (ORDER BY A.AnesCode) AS AnesthesiaType
INTO #ANESTYPE
FROM (
    SELECT DISTINCT S.LOG_ID, S.Side,
           CASE AN.LOG_ANESTH_TYPE_C
                WHEN '80'  THEN '1'
                WHEN '240' THEN '1'
                WHEN '180' THEN '2'
                WHEN '160' THEN '6'
                WHEN '40'  THEN CASE S.Joint WHEN 'Hip' THEN '4' WHEN 'Knee' THEN '5' END
           END AS AnesCode
    FROM #SIDE S
    INNER JOIN #ANES AN ON AN.LOG_ID = S.LOG_ID
) A
WHERE A.AnesCode IS NOT NULL
GROUP BY A.LOG_ID, A.Side;

/*==============================================================================
  4. SINGLE-VALUE LOOKUPS: RACE, TIMES, VITALS
==============================================================================*/

/* Race per MDD: 1 AmInd/AK Native, 2 Asian, 3 Black, 4 NH/PI, 5 White, 6 Two or more */
SELECT  R.PAT_ID
       ,CASE WHEN COUNT(DISTINCT R.RaceCode) > 1 THEN '6' ELSE MAX(R.RaceCode) END AS RaceCode
INTO #RACECODE
FROM (
    SELECT  PAT_ID
           ,CASE WHEN RACE_NAME LIKE '%American Indian%' OR RACE_NAME LIKE '%Alaska%'          THEN '1'
                 WHEN RACE_NAME LIKE 'Asian%'                                                  THEN '2'
                 WHEN RACE_NAME LIKE '%Black%' OR RACE_NAME LIKE '%African American%'          THEN '3'
                 WHEN RACE_NAME LIKE '%Hawaiian%' OR RACE_NAME LIKE '%Pacific Islander%'       THEN '4'
                 WHEN RACE_NAME LIKE 'White%' OR RACE_NAME LIKE 'Caucasian%'                   THEN '5'
            END AS RaceCode
    FROM #RACE
) R
WHERE R.RaceCode IS NOT NULL
GROUP BY R.PAT_ID;

SELECT  T.LOG_ID
       ,MIN(CASE WHEN T.TIMING_EVENT_C = '700'  THEN T.TIMING_EVENT_DTTM END) AS OREntry
       ,MIN(CASE WHEN T.TIMING_EVENT_C = '1200' THEN T.TIMING_EVENT_DTTM END) AS ORExit
       ,MIN(CASE WHEN T.TIMING_EVENT_C = '1000' THEN T.TIMING_EVENT_DTTM END) AS IncisionStart
       ,MIN(CASE WHEN T.TIMING_EVENT_C = '1100' THEN T.TIMING_EVENT_DTTM END) AS SkinClosure
INTO #TIMES
FROM #TIMING T
GROUP BY T.LOG_ID;

/* Vitals: MDD asks for the pre-operative value, so prefer the latest reading
   taken before OR entry; fall back to the latest reading on the encounter. */
WITH V AS (
    SELECT  C.LOG_ID
           ,V.FLO_MEAS_ID
           ,TRY_CONVERT(DECIMAL(10,2), V.MEAS_VALUE) AS Val
           ,ROW_NUMBER() OVER (PARTITION BY C.LOG_ID, V.FLO_MEAS_ID
                               ORDER BY CASE WHEN V.RECORDED_TIME <= ISNULL(TM.OREntry, C.SURGERY_DATE) THEN 0 ELSE 1 END,
                                        V.RECORDED_TIME DESC) AS rn
    FROM #CASE C
    INNER JOIN #VITALS V ON V.INPATIENT_DATA_ID = C.INPATIENT_DATA_ID
    LEFT JOIN #TIMES TM  ON TM.LOG_ID = C.LOG_ID
    WHERE TRY_CONVERT(DECIMAL(10,2), V.MEAS_VALUE) IS NOT NULL
)
SELECT  V.LOG_ID
       ,MAX(CASE WHEN V.FLO_MEAS_ID = '11'     THEN V.Val END) AS HeightIn
       ,MAX(CASE WHEN V.FLO_MEAS_ID = '14'     THEN V.Val END) AS WeightOz
       ,MAX(CASE WHEN V.FLO_MEAS_ID = '301070' THEN V.Val END) AS BMI
INTO #VITALVAL
FROM V
WHERE V.rn = 1
GROUP BY V.LOG_ID;

/*==============================================================================
  5. OUTPUT - Procedure Layout, 101 columns in layout order
==============================================================================*/
SELECT
     ROW_NUMBER() OVER (ORDER BY C.SURGERY_DATE, S.LOG_ID, S.Side) AS [ExportRowNum]
    ,'AJRR'                                                             AS [Registry]
    ,'Hip and Knee Arthroplasty'                                        AS [Module]
    ,'2026'                                                             AS [Version]
    ,'Procedure'                                                        AS [SubmissionType]
    ,ISNULL(F.RegistryAccountID, @NR)                                   AS [RegistryAccountID]
    ,@InstitutionName                                                   AS [InstitutionName]
    ,@InstitutionNPI                                                    AS [InstitutionNPI]
    ,ISNULL(NULLIF(F.Hospital_ASC_Name, ''), ISNULL(C.HOSPITAL_NAME, @NR)) AS [Hospital_ASC_Name]
    ,ISNULL(F.Hospital_ASC_NPI, @NR)                                    AS [Hospital_ASC_NPI]
    ,ISNULL(NULLIF(LTRIM(RTRIM(PAT.PAT_MRN_ID)), ''), @NR)              AS [Patient_MRN]
    ,ISNULL(NULLIF(LTRIM(RTRIM(PAT.SSN)), ''), @NR)                     AS [PatSSN]
    ,ISNULL(NULLIF(LTRIM(RTRIM(PAT.PAT_FIRST_NAME)), ''), @NR)          AS [PatFirstName]
    ,ISNULL(NULLIF(LTRIM(RTRIM(PAT.PAT_MIDDLE_NAME)), ''), @NR)         AS [PatMiddleName]
    ,ISNULL(NULLIF(LTRIM(RTRIM(PAT.PAT_LAST_NAME)), ''), @NR)           AS [PatLastName]
    ,ISNULL(CONVERT(VARCHAR(10), PAT.BIRTH_DATE, 23), @NR)              AS [PatDOB]
    ,ISNULL(CONVERT(VARCHAR(10), PAT.DEATH_DATE, 23), @NR)              AS [PatDeathDate]
    ,CASE WHEN PAT.SEX_NAME IN ('Male', 'Female') THEN PAT.SEX_NAME ELSE @NR END AS [PatSex]
    ,@NR                                                                AS [PatGender]       -- TODO: gender identity mapping (1-8)
    ,ISNULL(RC.RaceCode, @NR)                                           AS [PatRace]
    ,CASE PAT.ETHNIC_GROUP_C WHEN '2' THEN '1' WHEN '1' THEN '2' ELSE @NR END AS [PatEthnicity]
    ,ISNULL(NULLIF(LTRIM(RTRIM(PAT.CITY)), ''), @NR)                    AS [PatCity]
    ,ISNULL(NULLIF(LTRIM(RTRIM(PAT.STATE_ABBR)), ''), @NR)              AS [PatState]
    ,ISNULL(NULLIF(LTRIM(RTRIM(PAT.ZIP)), ''), @NR)                     AS [PatZip]
    ,ISNULL(NULLIF(LTRIM(RTRIM(PAT.COUNTRY_NAME)), ''), @NR)            AS [PatCountry]
    ,ISNULL(NULLIF(LTRIM(RTRIM(PAT.EMAIL_ADDRESS)), ''), @NR)           AS [PatEmail]
    ,CASE WHEN LEN(PH.Digits) = 10 AND PH.Digits NOT LIKE '%[^0-9]%'
          THEN '(' + LEFT(PH.Digits, 3) + ')' + SUBSTRING(PH.Digits, 4, 3) + '-' + RIGHT(PH.Digits, 4)
          ELSE @NR END                                                  AS [PatPhone]
    ,ISNULL(NULLIF(SN.FirstName, ''), @NR)                              AS [SurFirstName]
    ,ISNULL(NULLIF(SN.LastName, ''), @NR)                               AS [SurLastName]
    ,ISNULL(NULLIF(LTRIM(RTRIM(SURG.NPI)), ''), @NR)                    AS [SurNPI]
    ,CASE WHEN VT.HeightIn * 2.54 BETWEEN 15 AND 305
          THEN CONVERT(VARCHAR(10), CAST(ROUND(VT.HeightIn * 2.54, 1) AS DECIMAL(5,1))) ELSE @NR END AS [Pat_Height_cm]
    ,CASE WHEN VT.WeightOz * 0.0283495 BETWEEN 4 AND 500
          THEN CONVERT(VARCHAR(10), CAST(ROUND(VT.WeightOz * 0.0283495, 1) AS DECIMAL(5,1))) ELSE @NR END AS [Pat_Weight_kg]
    ,CASE WHEN VT.HeightIn BETWEEN 12 AND 107
          THEN CAST(CAST(ROUND(VT.HeightIn, 0) AS INT) / 12 AS VARCHAR(1)) + '-'
             + RIGHT('0' + CAST(CAST(ROUND(VT.HeightIn, 0) AS INT) % 12 AS VARCHAR(2)), 2) ELSE @NR END AS [Pat_Height_ftin]
    ,CASE WHEN VT.WeightOz / 16.0 BETWEEN 9 AND 1100
          THEN CONVERT(VARCHAR(10), CAST(ROUND(VT.WeightOz / 16.0, 1) AS DECIMAL(5,1))) ELSE @NR END AS [Pat_Weight_lbs]
    ,CASE WHEN VT.BMI BETWEEN 10 AND 100
          THEN CONVERT(VARCHAR(10), CAST(ROUND(VT.BMI, 1) AS DECIMAL(4,1))) ELSE @NR END AS [Pat_BMI]
    ,ISNULL(CONVERT(VARCHAR(10), C.SURGERY_DATE, 23), @NR)              AS [ProcedureDate]
    ,ISNULL(CONVERT(VARCHAR(19), C.HOSP_ADMSN_TIME, 126), @NR)          AS [AdmitDateTime]
    ,ISNULL(CONVERT(VARCHAR(19), C.HOSP_DISCH_TIME, 126), @NR)          AS [DischargeDateTime]
    ,CASE WHEN LOS.Mins IS NULL OR LOS.Mins < 0 THEN @NR
          ELSE CASE WHEN LOS.Mins / 1440 < 10 THEN '0' ELSE '' END + CAST(LOS.Mins / 1440 AS VARCHAR(5))
             + '-' + RIGHT('0' + CAST((LOS.Mins % 1440) / 60 AS VARCHAR(2)), 2)
             + ':' + RIGHT('0' + CAST(LOS.Mins % 60 AS VARCHAR(2)), 2) END AS [LengthofStay]
    ,CASE WHEN C.DISCH_DISP_C LIKE '[0-9]'      THEN '0' + C.DISCH_DISP_C   -- Epic codes confirmed = CMS status codes
          WHEN C.DISCH_DISP_C LIKE '[0-9][0-9]' THEN C.DISCH_DISP_C
          ELSE @NR END                                                  AS [DSCHDISPCODE]
    ,ISNULL(PX.PX, @NR)                                                 AS [PX]
    ,ISNULL(DX.DX, @NR)                                                 AS [DX]
    ,CASE WHEN S.Side IN ('R', 'L') THEN S.Side ELSE @NR END            AS [DXLat]
    ,CASE WHEN S.Joint <> 'Hip'                    THEN @NR          -- approach from OR procedure name;
          WHEN S.ProcName LIKE '%ANTERIOR%'          THEN '1'          -- ALL_APPROACH_C is not used in this build
          WHEN S.ProcName LIKE '%POSTERIOR%'         THEN '3'
          WHEN S.ProcName LIKE '% LATERAL%'          THEN '2'
          ELSE CASE S.ApproachC WHEN '1' THEN '1' WHEN '5' THEN '2' WHEN '2' THEN '3' WHEN '3' THEN '4' ELSE @NR END
     END                                                                AS [SurgicalApproachHip]
    ,@NR                                                                AS [SurgicalApproachKnee]   -- TODO: knee approach mapping (1-5)
    ,@NR                                                                AS [SurgicalApproachOther]
    ,@NR                                                                AS [SurgicalTechniqueHip]   -- OR_LOG_TECHNIQUE not documented for these cases
    ,@NR                                                                AS [SurgicalTechniqueKnee]  -- OR_LOG_TECHNIQUE not documented for these cases
    ,ISNULL(CONVERT(VARCHAR(8), TM.OREntry, 108), @NR)                  AS [OREntryTime]
    ,ISNULL(CONVERT(VARCHAR(8), TM.ORExit, 108), @NR)                   AS [ORExitTime]
    ,ISNULL(CONVERT(VARCHAR(8), TM.IncisionStart, 108), @NR)            AS [IncisionStartTime]
    ,ISNULL(CONVERT(VARCHAR(8), TM.SkinClosure, 108), @NR)              AS [SkinClosureTime]
    ,CASE WHEN TRN.LOG_ID IS NOT NULL THEN '1' ELSE '2' END             AS [TourniquetUse]
    ,CASE WHEN S.IsRobotic = 1 OR RBT.LOG_ID IS NOT NULL THEN '2'       -- MDD: CAN and RAN cannot both be Yes
          WHEN PX.HasNavCode = 1      THEN '1'
          ELSE @NR END                                                  AS [ComputerNavigation]
    ,CASE WHEN S.IsRobotic = 1 OR RBT.LOG_ID IS NOT NULL THEN '1' ELSE '2' END AS [RoboticAssistedSurgery]
    ,@NR                                                                AS [RoboticSystemName]
    ,@NR                                                                AS [RoboticSoftwareVersion]
    ,ISNULL(ANT.AnesthesiaType, @NR)                                     AS [AnesthesiaType]
    ,@NR                                                                AS [PeriarticularInjection]
    ,ISNULL(IMP.Implants, @NR)                                          AS [ComponentName^Mfg^Cat^Lot]
    ,CASE WHEN C.ASA_RATE_C IN ('1', '2', '3', '4', '5') THEN C.ASA_RATE_C ELSE @NR END AS [ASA_Class]  -- TODO: E (emergency) variants
    ,ISNULL(COM.CoM_POA, @NR)                                           AS [CoM^POA]
    ,@NR                                                                AS [Trainee]
    ,@NR                                                                AS [Substance_Use_Screening]
    ,@NR                                                                AS [Payer_Status]
    ,@NR                                                                AS [Charlson_Index]
    ,@NR                                                                AS [Rgnl_Ansth_Exemption]
    ,@NR                                                                AS [Ambulation]
    ,@NR                                                                AS [Discharge_Exclusion]
    ,@NR                                                                AS [Pat_Residence]
    ,@NR                                                                AS [Chronic_Narcotics_Use_>90]
    ,@NR                                                                AS [PatTobaccoUse]
    ,@NR                                                                AS [MBI]
    ,@NR                                                                AS [SharedDecision_ConservativeTx]
    ,@NR                                                                AS [Blood_Transfusion]
    ,@NR                                                                AS [Blood_Transfusion_Amount]
    ,@NR                                                                AS [Tranexamic_Acid_Usage]
    ,@NR                                                                AS [PT_Day_0]
    ,@NR                                                                AS [VTE_Prophylaxis]
    ,@NR                                                                AS [VTE_CV_Risk]
    ,@NR                                                                AS [Perioperative_Antibiotics]
    ,@NR                                                                AS [Pain_Management]
    ,CASE WHEN C.PAT_CLASS_NAME IN ('Inpatient', 'Surgery Admit')                   THEN '1'
          WHEN C.PAT_CLASS_NAME IN ('Outpatient Surgery', 'Outpatient', 'Observation') THEN '2'
          WHEN C.PAT_CLASS_NAME = 'Emergency'                                         THEN '3'
          ELSE @NR END                                                  AS [Encounter_Type]
    ,@NR                                                                AS [Lab_Test_CRP]
    ,@NR                                                                AS [CRP]
    ,@NR                                                                AS [Lab_Test_ESR]
    ,@NR                                                                AS [ESR]
    ,@NR                                                                AS [Lab_Test_SynFl_CellCnt]
    ,@NR                                                                AS [SynFl_CellCnt]
    ,@NR                                                                AS [Lab_Test_SynFl_Diff]
    ,@NR                                                                AS [SynFl_Diff]
    ,@NR                                                                AS [Lab_Test_SynFl_AeroCult]
    ,@NR                                                                AS [SynFl_AeroCult]
    ,@NR                                                                AS [Lab_Test_Synfl_AnaeroCult]
    ,@NR                                                                AS [Synfl_AnaeroCult]
    ,@NR                                                                AS [Lab_Test_Tiss_AeroCult]
    ,@NR                                                                AS [Tiss_AeroCult]
    ,@NR                                                                AS [Lab_Test_Tiss_AnaeroCult]
    ,@NR                                                                AS [Tiss_AnaeroCult]
    ,@NR                                                                AS [Dx_Study_Peripros_Osteolys]
    ,@NR                                                                AS [Dx_Study_Pros_Impl_Loos]
    ,@NR                                                                AS [Pract_Spec_Infec_Dis]
INTO #OUT
FROM #SIDE S
INNER JOIN #CASE C         ON C.LOG_ID = S.LOG_ID
LEFT JOIN dim.AJRRFacility F ON F.REV_LOC_ID = C.REV_LOC_ID
LEFT JOIN #PAT PAT         ON PAT.PAT_ID = C.PAT_ID
LEFT JOIN #RACECODE RC     ON RC.PAT_ID = C.PAT_ID
LEFT JOIN #SURG SURG       ON SURG.PROV_ID = C.PRIMARY_PHYS_ID
LEFT JOIN #TIMES TM        ON TM.LOG_ID = S.LOG_ID
LEFT JOIN #VITALVAL VT     ON VT.LOG_ID = S.LOG_ID
LEFT JOIN #TOURN TRN       ON TRN.LOG_ID = S.LOG_ID
LEFT JOIN #ROBOT RBT       ON RBT.LOG_ID = S.LOG_ID
LEFT JOIN #PX PX           ON PX.LOG_ID = S.LOG_ID AND PX.Side = S.Side
LEFT JOIN #ANESTYPE ANT    ON ANT.LOG_ID = S.LOG_ID AND ANT.Side = S.Side
LEFT JOIN #IMPLANTSTR IMP  ON IMP.LOG_ID = S.LOG_ID
LEFT JOIN #DX DX           ON DX.HSP_ACCOUNT_ID = C.HSP_ACCOUNT_ID
LEFT JOIN #COM COM         ON COM.HSP_ACCOUNT_ID = C.HSP_ACCOUNT_ID
/* Phone digits only */
CROSS APPLY (SELECT REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(PAT.HOME_PHONE, ''), '(', ''), ')', ''), '-', ''), ' ', ''), '.', '') AS Digits) PH
/* Surgeon "LAST, FIRST M" -> first / last */
CROSS APPLY (SELECT CHARINDEX(',', ISNULL(SURG.PROV_NAME, '')) AS CommaPos) SC
CROSS APPLY (SELECT LTRIM(SUBSTRING(ISNULL(SURG.PROV_NAME, ''), SC.CommaPos + 1, 200)) AS AfterComma) SA
CROSS APPLY (SELECT  CASE WHEN SC.CommaPos > 0 THEN LTRIM(RTRIM(LEFT(SURG.PROV_NAME, SC.CommaPos - 1)))
                          ELSE LTRIM(RTRIM(SURG.PROV_NAME)) END AS LastName
                    ,CASE WHEN SC.CommaPos = 0 THEN NULL
                          WHEN CHARINDEX(' ', SA.AfterComma) > 0 THEN LEFT(SA.AfterComma, CHARINDEX(' ', SA.AfterComma) - 1)
                          ELSE SA.AfterComma END AS FirstName) SN
/* Length of stay in minutes */
CROSS APPLY (SELECT DATEDIFF(MINUTE, C.HOSP_ADMSN_TIME, C.HOSP_DISCH_TIME) AS Mins) LOS

/* Either return the result set (default) or persist it for the CSV export.
   The export proc cannot capture this result with INSERT...EXEC because this
   proc already uses INSERT...EXEC internally, and SQL Server cannot nest them. */
IF @ExportToTable = 1
BEGIN
    DROP TABLE IF EXISTS rpt.AJRRProcedures2027_Export;
    SELECT * INTO rpt.AJRRProcedures2027_Export FROM #OUT;
END
ELSE
BEGIN
    SELECT
     [Registry]
    ,[Module]
    ,[Version]
    ,[SubmissionType]
    ,[RegistryAccountID]
    ,[InstitutionName]
    ,[InstitutionNPI]
    ,[Hospital_ASC_Name]
    ,[Hospital_ASC_NPI]
    ,[Patient_MRN]
    ,[PatSSN]
    ,[PatFirstName]
    ,[PatMiddleName]
    ,[PatLastName]
    ,[PatDOB]
    ,[PatDeathDate]
    ,[PatSex]
    ,[PatGender]
    ,[PatRace]
    ,[PatEthnicity]
    ,[PatCity]
    ,[PatState]
    ,[PatZip]
    ,[PatCountry]
    ,[PatEmail]
    ,[PatPhone]
    ,[SurFirstName]
    ,[SurLastName]
    ,[SurNPI]
    ,[Pat_Height_cm]
    ,[Pat_Weight_kg]
    ,[Pat_Height_ftin]
    ,[Pat_Weight_lbs]
    ,[Pat_BMI]
    ,[ProcedureDate]
    ,[AdmitDateTime]
    ,[DischargeDateTime]
    ,[LengthofStay]
    ,[DSCHDISPCODE]
    ,[PX]
    ,[DX]
    ,[DXLat]
    ,[SurgicalApproachHip]
    ,[SurgicalApproachKnee]
    ,[SurgicalApproachOther]
    ,[SurgicalTechniqueHip]
    ,[SurgicalTechniqueKnee]
    ,[OREntryTime]
    ,[ORExitTime]
    ,[IncisionStartTime]
    ,[SkinClosureTime]
    ,[TourniquetUse]
    ,[ComputerNavigation]
    ,[RoboticAssistedSurgery]
    ,[RoboticSystemName]
    ,[RoboticSoftwareVersion]
    ,[AnesthesiaType]
    ,[PeriarticularInjection]
    ,[ComponentName^Mfg^Cat^Lot]
    ,[ASA_Class]
    ,[CoM^POA]
    ,[Trainee]
    ,[Substance_Use_Screening]
    ,[Payer_Status]
    ,[Charlson_Index]
    ,[Rgnl_Ansth_Exemption]
    ,[Ambulation]
    ,[Discharge_Exclusion]
    ,[Pat_Residence]
    ,[Chronic_Narcotics_Use_>90]
    ,[PatTobaccoUse]
    ,[MBI]
    ,[SharedDecision_ConservativeTx]
    ,[Blood_Transfusion]
    ,[Blood_Transfusion_Amount]
    ,[Tranexamic_Acid_Usage]
    ,[PT_Day_0]
    ,[VTE_Prophylaxis]
    ,[VTE_CV_Risk]
    ,[Perioperative_Antibiotics]
    ,[Pain_Management]
    ,[Encounter_Type]
    ,[Lab_Test_CRP]
    ,[CRP]
    ,[Lab_Test_ESR]
    ,[ESR]
    ,[Lab_Test_SynFl_CellCnt]
    ,[SynFl_CellCnt]
    ,[Lab_Test_SynFl_Diff]
    ,[SynFl_Diff]
    ,[Lab_Test_SynFl_AeroCult]
    ,[SynFl_AeroCult]
    ,[Lab_Test_Synfl_AnaeroCult]
    ,[Synfl_AnaeroCult]
    ,[Lab_Test_Tiss_AeroCult]
    ,[Tiss_AeroCult]
    ,[Lab_Test_Tiss_AnaeroCult]
    ,[Tiss_AnaeroCult]
    ,[Dx_Study_Peripros_Osteolys]
    ,[Dx_Study_Pros_Impl_Loos]
    ,[Pract_Spec_Infec_Dis]
    FROM #OUT
    ORDER BY ExportRowNum;
END;

DROP TABLE IF EXISTS #CASE, #PROCLINE, #CODING, #PAT, #RACE, #SURG, #TIMING, #TOURN,
                     #ROBOT, #ANES, #IMPLANT, #VITALS, #TRIG, #PXCAND, #SIDE, #PX, #DX,
                     #COM, #IMPLANTSTR, #ANESTYPE, #RACECODE, #TIMES, #VITALVAL, #OUT;
END
GO
