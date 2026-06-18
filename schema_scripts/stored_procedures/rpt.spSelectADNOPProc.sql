-- =============================================
-- Author:		XX
-- Create date: 08/11/2023
-- Description:	
-- Change Control
--	
-- =============================================

CREATE PROCEDURE [rpt].[spSelectADNOPProc] @GO_LIVE date, @STARTDATE date, @ENDDATE date
AS
BEGIN
SET NOCOUNT ON;

--DECLARE @STARTDATE AS DATE 
--DECLARE @ENDDATE AS DATE
--DECLARE @GO_LIVE AS DATE
 
--SET @STARTDATE =DATEADD(day,-7,DATEFROMPARTS(YEAR(GETDATE()),MONTH(GETDATE()),1)); 
--SET @ENDDATE = DATEADD(DAY,-1,DATEFROMPARTS(YEAR(GETDATE()),MONTH(GETDATE()),1)); 
--SET @GO_LIVE = '4/29/2023';

SELECT
	case
        when a.loc_id in ('43004', '43005') then 370203
        when a.loc_id in ('43006') then 370192 
		end [Hospital Identifier]
	,a.HSP_ACCOUNT_ID [Encounter/Patient Identifier]
	,px.ref_bill_code [CPT/HCPCS Code]
	,isnull(px.px_perf_prov_id, '') [Procedure Physician ID]
	,CAST(px.px_date AS DATE) AS [Procedure Date]
from [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].hsp_account a
left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].patient p on a.pat_id = p.pat_id
left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].patient_3 p3 on a.pat_id = p3.pat_id
inner join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].V_CODING_ALL_DX_PX_LIST px ON px.HSP_ACCOUNT_ID = a.HSP_ACCOUNT_ID
where 1=1 --a.disch_date_time between @STARTDATE and @ENDDATE /*Replaced with Coding Date Time on 3/14/24 */
	and a.disch_date_time >= @GO_LIVE
	and a.CODING_DATETIME between @STARTDATE and @ENDDATE
	and a.CODING_STATUS_C = 4 /*Completed*/
	--and a.completion_dt_tm is not null -- only complete coded accounts
	and a.loc_id  in ('43004', '43005', '43006') -- hpi hospitals only
	and p3.IS_TEST_PAT_YN = 'N' -- filter out test accounts
	and a.ACCT_BASECLS_HA_C <> 1 -- op only
	and px.source_abbr like '%CPT%' -- filter out icd10 codes
	and px.exclude_yn = 'N'

END
GO
