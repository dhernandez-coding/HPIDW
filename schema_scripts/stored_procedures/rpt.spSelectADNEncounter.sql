-- =============================================
-- Author:		XX
-- Create date: 08/11/2023
-- Description:	
-- Change Control
--	
-- =============================================

CREATE PROCEDURE [rpt].[spSelectADNEncounter] @GO_LIVE date, @STARTDATE date, @ENDDATE date
AS
BEGIN
SET NOCOUNT ON;

--DECLARE @STARTDATE AS DATE 
--DECLARE @ENDDATE AS DATE
--DECLARE @GO_LIVE AS DATE
 
--SET @STARTDATE = DATEADD(day,-2, GETDATE())
--SET @ENDDATE = DATEADD(day,-1, GETDATE())
--SET @GO_LIVE = '4/28/2023';

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
		FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].patient_race
		group by pat_id
	) s1
	left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].patient_race pr on s1.pat_id = pr.pat_id
) s2
group by s2.pat_id, s2.patient_race_c


select
	case
        when a.loc_id in ('43004', '43005') then 370203
        when a.loc_id in ('43006') then 370192 
		end [Hospital Identifier]
	,a.HSP_ACCOUNT_ID [Encounter/Patient Identifier/Billing ID]
	,p.pat_mrn_id [Medical Record Number]
	,isnull(cast(convert(date,p.BIRTH_DATE,101) as varchar),'')  AS [Date of Birth]
	,CASE
		WHEN p.ETHNIC_GROUP_C = 2 THEN 'Y'
		WHEN p.ETHNIC_GROUP_C = 3 THEN 'UTD'
		WHEN p.ETHNIC_GROUP_C IS NULL THEN 'UTD'
		ELSE'N'
		END AS [Hispanic Ethnicity Indicator]
	,isnull(pr.patient_race_c, '') AS [Race]
	,ISNULL(ZS.ABBR,'U') AS [Sex]
	,isnull(cast(p3.ped_birth_wt_num as varchar), 0) AS [Birth Weight]  --Not sure that this applies since HPI doesn't have births
	,ISNULL(LEFT(p.ZIP,5),'') AS [Zip Code]
	,case
        when a.loc_id in ('43004', '43005') then 110 -- community
        when a.loc_id in ('43006') then 100 -- northwest
		end [Internal Hospital ID]
	,isnull(cast(convert(date,a.ADM_DATE_TIME,101) as varchar),'')  AS [Admission Date]
	,isnull(cast(convert(date,a.DISCH_DATE_TIME, 101) as varchar),'') AS [Discharge Date]
	,ISNULL(a.PATIENT_STATUS_C,'UTD') AS [Discharge Status/Disposition]
	,ISNULL(ac.NAME,'') AS [Patient Type]
	,CASE
		WHEN a.ACCT_CLASS_HA_C IN ('134','135','153','154') THEN 'P' --Inpatient Psych
		WHEN a.ACCT_BASECLS_HA_C = '1' then 'I'
		ELSE 'O'
		END AS [Inpatient/Outpatient Flag]
	
from [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].hsp_account a
left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].patient p on a.pat_id = p.pat_id
left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].patient_3 p3 on a.pat_id = p3.pat_id
left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_ACCT_BASECLS_HA bc ON bc.ACCT_BASECLS_HA_C = a.ACCT_BASECLS_HA_C
left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_ACCT_CLASS_HA ac ON ac.ACCT_CLASS_HA_C = a.ACCT_CLASS_HA_C
left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_ACCT_BILLSTS_HA bs ON bs.ACCT_BILLSTS_HA_C = a.ACCT_BILLSTS_HA_C
left join #pat_race pr on p.pat_id = pr.pat_id
LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_SEX ZS ON ZS.RCPT_MEM_SEX_C = p.SEX_C
--LEFT JOIN [DBSQ_CLARITY.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].HSP_ACCT_DX_LIST dx ON dx.hsp_account_id = a.hsp_account_id

where 1=1 --a.disch_date_time between @STARTDATE and @ENDDATE /*Replaced with Coding Date Time on 3/14/24 */
	and a.disch_date_time >= @GO_LIVE
	and a.CODING_DATETIME between @STARTDATE and @ENDDATE
	and a.CODING_STATUS_C = 4 /*Completed*/
	--and a.completion_dt_tm is not null -- only complete coded accounts
	and a.loc_id  in ('43004', '43005', '43006') -- hpi hospitals only
	and p3.IS_TEST_PAT_YN = 'N' -- filter out test accounts



END
GO
