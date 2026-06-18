-- =============================================
-- Author:		XX
-- Create date: 08/11/2023
-- Description:	
-- Change Control
--	
-- =============================================
create PROCEDURE [rpt].[zz_deprecated_spSelectADNAssignedDiagnosis] @GO_LIVE date, @STARTDATE date, @ENDDATE date
AS
BEGIN
SET NOCOUNT ON;

 --DECLARE @STARTDATE AS DATE 
 --DECLARE @ENDDATE AS DATE
 --DECLARE @GO_LIVE AS DATE
 
 --SET @STARTDATE =DATEADD(day, -1,DATEFROMPARTS(YEAR(GETDATE()),MONTH(GETDATE()),1)); 
 --SET @ENDDATE = DATEADD(DAY,-1,DATEFROMPARTS(YEAR(GETDATE()),MONTH(GETDATE()),1)); 
 --SET @GO_LIVE = '4/28/2023';

 DROP TABLE IF EXISTS #tempDiag

 SELECT
			loc.loc_id
			,ISNULL(Cast(PE.PAT_ENC_CSN_ID as varchar),'') AS [Encounter/Patient Identifier]
			,ICD.CODE AS [Diagnosis Code]
			,ped.primary_dx_yn
			into #tempDiag
		FROM [DBSQ_CLARITY.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].PAT_ENC PE
		INNER JOIN [DBSQ_CLARITY.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].HSP_ACCOUNT HA ON PE.HSP_ACCOUNT_ID = HA.HSP_ACCOUNT_ID
		LEFT JOIN [DBSQ_CLARITY.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].CLARITY_LOC LOC ON LOC.LOC_ID = HA.LOC_ID
		INNER JOIN [DBSQ_CLARITY.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].PATIENT PAT ON PAT.PAT_ID = HA.PAT_ID
		INNER JOIN [DBSQ_CLARITY.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].PATIENT_3 PAT3 ON PAT3.PAT_ID = HA.PAT_ID
		INNER JOIN [DBSQ_CLARITY.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].PAT_ENC_DX PED ON PED.PAT_ENC_CSN_ID = PE.PAT_ENC_CSN_ID
		INNER JOIN [DBSQ_CLARITY.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].EDG_CURRENT_ICD10 ICD on ICD.DX_ID = PED.DX_ID
		WHERE HA.SERV_AREA_ID = '430' --HPI
			AND PAT3.IS_TEST_PAT_YN = 'N'
			AND HA.DISCH_DATE_TIME >= @STARTDATE AND HA.DISCH_DATE_TIME <= @ENDDATE
			AND HA.DISCH_DATE_TIME >= @GO_LIVE
		group by
			loc.loc_id
			,pe.pat_enc_csn_id
			,icd.code
			,ped.primary_dx_yn

select
    s2.[Hospital Identifier]
    ,s2.[Encounter/Patient Identifier]
    ,s2.[Diagnosis Code]
    ,ROW_NUMBER() over (PARTITION by s2.[Encounter/Patient Identifier] order by protoDiagType) [Diagnosis Type]
from (
    select
        case
            when s1.loc_id like '43004%' or s1.loc_id like '43005%' then 370203
            when s1.loc_id like '43006%' then 370192 
        end [Hospital Identifier]
        ,s1.[Encounter/Patient Identifier]
        ,s1.[Diagnosis Code]
        ,case
            when s1.primary_dx_yn = 'Y' then 1
            else 2
        end protoDiagType
    from (
		select * from #tempDiag
        ) s1
    ) s2
where [Hospital Identifier] is not null

END
GO
