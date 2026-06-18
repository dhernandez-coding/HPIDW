-- =============================================
-- Author:		XX
-- Create date: 08/11/2023
-- Description:	
-- Change Control
--	
-- =============================================
create PROCEDURE [rpt].[zz_deprecated_spSelectADNAssignedPhysicians] @GO_LIVE date, @STARTDATE date, @ENDDATE date
AS
BEGIN
SET NOCOUNT ON;

-- DECLARE @STARTDATE AS DATE 
-- DECLARE @ENDDATE AS DATE
-- DECLARE @GO_LIVE AS DATE
 
-- SET @STARTDATE =DATEADD(MONTH,-1,DATEFROMPARTS(YEAR(GETDATE()),MONTH(GETDATE()),1)); 
-- SET @ENDDATE = DATEADD(DAY,-1,DATEFROMPARTS(YEAR(GETDATE()),MONTH(GETDATE()),1)); 
-- SET @GO_LIVE = '4/29/2022';

select
     *
from (
    select
        case
            when s1.loc_id like '43004%' or s1.loc_id like '43005%' then 370203
            when s1.loc_id like '43006%' then 370192 
        end [Hospital Identifier]
        ,s1.[Encounter/Patient Identifier]
        ,s1.[Physician ID]
        ,s1.[Physician Type]
    from (
        SELECT *
        from (
            SELECT
            loc.loc_id
            -- ISNULL(CMI.FACILITY_GROUP_ID,'') AS [Hospital Identifier] -- Not populated in Clarity for HPI
            ,ISNULL(Cast(PE.PAT_ENC_CSN_ID as varchar),'') AS [Encounter/Patient Identifier]
            ,ha.ADM_PROV_ID as [1]
            ,COALESCE(PE.VISIT_PROV_ID,ha.ATTENDING_PROV_ID) as [2]
            ,COALESCE(PE.PCP_PROV_ID,pat.CUR_PCP_PROV_ID) as [4]
        FROM [DBSQ_CLARITY.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].HSP_ACCOUNT HA
        INNER JOIN [DBSQ_CLARITY.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].PATIENT PAT ON PAT.PAT_ID = HA.PAT_ID
        INNER JOIN [DBSQ_CLARITY.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].PATIENT_3 PAT3 ON PAT3.PAT_ID = HA.PAT_ID
        INNER JOIN [DBSQ_CLARITY.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].PAT_ENC PE ON PE.PAT_ENC_CSN_ID = HA.PRIM_ENC_CSN_ID
        LEFT OUTER JOIN [DBSQ_CLARITY.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].CLARITY_LOC LOC ON LOC.LOC_ID = HA.LOC_ID
        LEFT OUTER JOIN [DBSQ_CLARITY.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].CMS_MU_LOC CML ON CML.LOC_ID = LOC.LOC_ID
        LEFT OUTER JOIN [DBSQ_CLARITY.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].CMS_MU_INFO CMI ON CMI.CMS_MU_ID = CML.CMS_MU_ID
        WHERE HA.SERV_AREA_ID = '430' --HPI
            AND PAT3.IS_TEST_PAT_YN = 'N'
            AND PE.CONTACT_DATE >= @STARTDATE AND PE.CONTACT_DATE <= @ENDDATE
            AND PE.CONTACT_DATE >= @GO_LIVE
            --AND HA.ACCT_BASECLS_HA_C = 1 --or PE.APPT_STATUS_C IN ('2','6')) --all inpatient, all COMPLETED / ARRIVED outpatient
        ) AS SOURCE
        UNPIVOT ([Physician ID] FOR [Physician Type] in ([1],[2],[4])) as PT1
    ) s1
) s2
where [Hospital Identifier] is not null

-- 5865 original run
-- 11502 with modified pat_enc acct join (distinct)

-- 11453 grouped run
-- 11453 distinct run

END
GO
