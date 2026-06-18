-- =============================================
-- Author:		XX
-- Create date: 08/11/2023
-- Description:	
-- Change Control
--	
-- =============================================
create PROCEDURE [rpt].[zz_deprecated_spSelectADNEncounter] @GO_LIVE date, @STARTDATE date, @ENDDATE date
AS
BEGIN
SET NOCOUNT ON;

 --DECLARE @STARTDATE AS DATE 
 --DECLARE @ENDDATE AS DATE
 --DECLARE @GO_LIVE AS DATE
 
 --SET @STARTDATE =DATEADD(MONTH,-1,DATEFROMPARTS(YEAR(GETDATE()),MONTH(GETDATE()),1)); 
 --SET @ENDDATE = DATEADD(DAY,-1,DATEFROMPARTS(YEAR(GETDATE()),MONTH(GETDATE()),1)); 
 --SET @GO_LIVE = '4/29/2022';

DROP TABLE IF EXISTS #OP_TEMP;
DROP TABLE IF EXISTS #IP_TEMP;
drop table if exists #pat_race;

select
    s2.pat_id
    ,case
        when s2.patient_race_c = 5 then 4 -- categorize pacific islander as asian
        else s2.patient_race_c
        end as patient_race_c
into #pat_race
from (
    select
        s1.pat_id
        ,case
            when s1.cnt > 1 then 6 -- multiple selected races = 6 other
            else pr.patient_race_c
            end patient_race_c
        from (
        select
            pat_id
            ,count(1) cnt
        FROM [DBSQ_CLARITY.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].patient_race
        group by pat_id
        ) s1
    left join [DBSQ_CLARITY.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].patient_race pr on s1.pat_id = pr.pat_id
) s2
group by s2.pat_id, s2.patient_race_c

SELECT
case
    when loc.loc_id like '43004%' or loc.loc_id like '43005%' then 370203
    when loc.loc_id like '43006%' then 370192 
end [Hospital Identifier]
,ISNULL(Cast(PE.PAT_ENC_CSN_ID as varchar),'') AS [Encounter/Patient Identifier/Billing ID]
,ISNULL(PAT.PAT_MRN_ID,'') AS [Medical Record Number]
,isnull(cast(convert(date,PAT.BIRTH_DATE,101) as varchar),'')  AS [Date of Birth]
,CASE WHEN PAT.ETHNIC_GROUP_C = 2 THEN 'Y'
      WHEN PAT.ETHNIC_GROUP_C = 3 THEN 'UTD'
      WHEN PAT.ETHNIC_GROUP_C IS NULL THEN 'UTD'
      ELSE'N' END AS [Hispanic Ethnicity Indicator]
,isnull(pr.patient_race_c, '') AS [Race] --Unsure how to populate this
,ISNULL(ZS.ABBR,'U') AS [Sex]
,isnull(cast(pat3.ped_birth_wt_num as varchar), '') AS [Birth Weight]  --Not sure that this applies since HPI doesn't have births
,ISNULL(LEFT(PAT.ZIP,5),'') AS [Zip Code]
,case
    when loc.loc_id like '43004%' or loc.loc_id like '43005%' then 110 -- community
    when loc.loc_id like '43006%' then 100 -- northwest
end AS [Internal Hospital ID]
,isnull(cast(convert(date,HA.ADM_DATE_TIME,101) as varchar),'')  AS [Admission Date]
,isnull(cast(convert(date,COALESCE(HA.DISCH_DATE_TIME,HA.ADM_DATE_TIME),101) as varchar),'') AS [Discharge Date]
,ISNULL(ha.PATIENT_STATUS_C,'') AS [Discharge Status/Disposition]
,ISNULL(zac.NAME,'') AS [Patient Type]
,CASE WHEN HA.ACCT_CLASS_HA_C IN ('134','135','153','154') THEN 'P' --Inpatient Psych
      WHEN HA.ACCT_BASECLS_HA_C = '1' then 'I'
      WHEN HA.ACCT_BASECLS_HA_C IN ('2','3') THEN 'O'
      ELSE 'O' END AS [Inpatient/Outpatient Flag]
,RANK() Over(PARTITION BY PE.PAT_ENC_CSN_ID Order by HA.COMPLETION_DT_TM DESC,HA.HSP_ACCOUNT_ID DESC) AS HA_RANK
INTO #OP_TEMP
FROM [DBSQ_CLARITY.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].HSP_ACCOUNT HA
INNER JOIN [DBSQ_CLARITY.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].PATIENT PAT ON PAT.PAT_ID = HA.PAT_ID
INNER JOIN [DBSQ_CLARITY.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].PATIENT_3 PAT3 ON PAT3.PAT_ID = HA.PAT_ID
INNER JOIN [DBSQ_CLARITY.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].PAT_ENC PE ON PE.PAT_ENC_CSN_ID = HA.PRIM_ENC_CSN_ID
left join #pat_race pr on pat.pat_id = pr.pat_id
LEFT OUTER JOIN [DBSQ_CLARITY.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_SEX ZS ON ZS.RCPT_MEM_SEX_C = PAT.SEX_C
LEFT OUTER JOIN [DBSQ_CLARITY.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_ACCT_CLASS_HA zac on zac.ACCT_CLASS_HA_C = ha.ACCT_CLASS_HA_C
-- LEFT OUTER JOIN [DBSQ_CLARITY.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_MC_PAT_STATUS ZMP ON ZMP.PAT_STATUS_C = ha.PATIENT_STATUS_C
LEFT OUTER JOIN [DBSQ_CLARITY.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].CLARITY_LOC LOC ON LOC.LOC_ID = HA.LOC_ID
LEFT OUTER JOIN [DBSQ_CLARITY.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].CMS_MU_LOC CML ON CML.LOC_ID = LOC.LOC_ID
LEFT OUTER JOIN [DBSQ_CLARITY.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].CMS_MU_INFO CMI ON CMI.CMS_MU_ID = CML.CMS_MU_ID
WHERE HA.SERV_AREA_ID = '430' --HPI
AND PAT3.IS_TEST_PAT_YN = 'N'
AND PE.CONTACT_DATE >= @STARTDATE AND PE.CONTACT_DATE <= @ENDDATE
AND PE.CONTACT_DATE >= @GO_LIVE
--AND PE.APPT_STATUS_C IN ('2','6') --COMPLETED / ARRIVED
AND HA.ACCT_BASECLS_HA_C <> 1 --Outpatient
--AND HA.COMPLETN_STS_HA_C = '5'--COMPLETED Should this criteria be included?  Patients may not be listed on the Diagnosis, Payor, Procedure files without complete accounts


SELECT
-- ISNULL(CMI.FACILITY_GROUP_ID,'') AS [Hospital Identifier] -- Not populated in Clarity for HPI
case
    when loc.loc_id like '43004%' or loc.loc_id like '43005%' then 370203
    when loc.loc_id like '43006%' then 370192 
end [Hospital Identifier]
,ISNULL(Cast(PE.PAT_ENC_CSN_ID as varchar),'') AS [Encounter/Patient Identifier/Billing ID]
,ISNULL(PAT.PAT_MRN_ID,'') AS [Medical Record Number]
,isnull(cast(convert(date,PAT.BIRTH_DATE,101) as varchar),'')  AS [Date of Birth]
,CASE WHEN PAT.ETHNIC_GROUP_C = 2 THEN 'Y'
      WHEN PAT.ETHNIC_GROUP_C = 3 THEN 'UTD'
      WHEN PAT.ETHNIC_GROUP_C IS NULL THEN 'UTD'
      ELSE'N' END AS [Hispanic Ethnicity Indicator]
,pr.patient_race_c AS [Race] --Unsure how to populate this
,ISNULL(ZS.ABBR,'U') AS [Sex]
,isnull(cast(pat3.ped_birth_wt_num as varchar), '') AS [Birth Weight]  --Not sure that this applies since HPI doesn't have births
,ISNULL(LEFT(PAT.ZIP,5),'') AS [Zip Code]
,case
    when loc.loc_id like '43004%' or loc.loc_id like '43005%' then 110 -- community
    when loc.loc_id like '43006%' then 100 -- northwest
end AS [Internal Hospital ID]
,isnull(cast(convert(date,HA.ADM_DATE_TIME,101) as varchar),'')  AS [Admission Date]
,isnull(cast(convert(date,HA.DISCH_DATE_TIME,101) as varchar),'') AS [Discharge Date]
,ISNULL(ha.PATIENT_STATUS_C,'') AS [Discharge Status/Disposition]
,ISNULL(zac.NAME,'') AS [Patient Type]
,CASE WHEN HA.ACCT_CLASS_HA_C IN ('134','135','153','154') THEN 'P' --Inpatient Psych
      WHEN HA.ACCT_BASECLS_HA_C = '1' then 'I'
      WHEN HA.ACCT_BASECLS_HA_C IN ('2','3') THEN 'O'
      ELSE 'O' END AS [Inpatient/Outpatient Flag]
,RANK() Over(PARTITION BY PE.PAT_ENC_CSN_ID Order by HA.COMPLETION_DT_TM DESC,HA.HSP_ACCOUNT_ID DESC) AS HA_RANK
INTO #IP_TEMP
FROM [DBSQ_CLARITY.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].HSP_ACCOUNT HA
INNER JOIN [DBSQ_CLARITY.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].PATIENT PAT ON PAT.PAT_ID = HA.PAT_ID
INNER JOIN [DBSQ_CLARITY.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].PATIENT_3 PAT3 ON PAT3.PAT_ID = HA.PAT_ID
LEFT OUTER JOIN [DBSQ_CLARITY.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].PAT_ENC PE ON PE.PAT_ENC_CSN_ID = HA.PRIM_ENC_CSN_ID
left join #pat_race pr on pat.pat_id = pr.pat_id
LEFT OUTER JOIN [DBSQ_CLARITY.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_SEX ZS ON ZS.RCPT_MEM_SEX_C = PAT.SEX_C
LEFT OUTER JOIN [DBSQ_CLARITY.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_ACCT_CLASS_HA zac on zac.ACCT_CLASS_HA_C = ha.ACCT_CLASS_HA_C
-- LEFT OUTER JOIN [DBSQ_CLARITY.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_MC_PAT_STATUS ZMP ON ZMP.PAT_STATUS_C = ha.PATIENT_STATUS_C
LEFT OUTER JOIN [DBSQ_CLARITY.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].CLARITY_LOC LOC ON LOC.LOC_ID = HA.LOC_ID
LEFT OUTER JOIN [DBSQ_CLARITY.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].CMS_MU_LOC CML ON CML.LOC_ID = LOC.LOC_ID
LEFT OUTER JOIN [DBSQ_CLARITY.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].CMS_MU_INFO CMI ON CMI.CMS_MU_ID = CML.CMS_MU_ID
WHERE HA.SERV_AREA_ID = '430' --HPI
AND PAT3.IS_TEST_PAT_YN = 'N'
AND HA.DISCH_DATE_TIME >= @STARTDATE AND HA.DISCH_DATE_TIME <= @ENDDATE
AND HA.DISCH_DATE_TIME >= @GO_LIVE
AND HA.ACCT_BASECLS_HA_C = 1  --Inpatient
--AND HA.COMPLETN_STS_HA_C = '5'--COMPLETED Should this criteria be included?  Patients may not be listed on the Diagnosis, Payor, Procedure files without complete accounts

select
    [Hospital Identifier]
    ,[Encounter/Patient Identifier/Billing ID]
    ,[Medical Record Number]
    ,[Date of Birth]
    ,[Hispanic Ethnicity Indicator]
    ,[Race]
    ,[Sex]
    ,isnull([Birth Weight], 0) [Birth Weight]
    ,[Zip Code]
    ,[Internal Hospital ID]
    ,[Admission Date]
    ,[Discharge Date]
    ,isnull(nullif([Discharge Status/Disposition], ''), 'UTD') [Discharge Status/Disposition]
    ,[Patient Type]
    ,[Inpatient/Outpatient Flag]
from (
    SELECT
    [Hospital Identifier]
    ,[Encounter/Patient Identifier/Billing ID]
    ,[Medical Record Number]
    ,[Date of Birth]
    ,[Hispanic Ethnicity Indicator]
    ,[Race]
    ,[Sex]
    ,[Birth Weight]
    ,[Zip Code]
    ,[Internal Hospital ID]
    ,[Admission Date]
    ,[Discharge Date]
    ,[Discharge Status/Disposition]
    ,[Patient Type]
    ,[Inpatient/Outpatient Flag]
    FROM #OP_TEMP
    WHERE HA_RANK = 1

    UNION

    SELECT
    [Hospital Identifier]
    ,[Encounter/Patient Identifier/Billing ID]
    ,[Medical Record Number]
    ,[Date of Birth]
    ,[Hispanic Ethnicity Indicator]
    ,[Race]
    ,[Sex]
    ,[Birth Weight]
    ,[Zip Code]
    ,[Internal Hospital ID]
    ,[Admission Date]
    ,[Discharge Date]
    ,[Discharge Status/Disposition]
    ,[Patient Type]
    ,[Inpatient/Outpatient Flag]
    FROM #IP_TEMP
    WHERE HA_RANK = 1
) s1
where [Hospital Identifier] is not null

END
GO
