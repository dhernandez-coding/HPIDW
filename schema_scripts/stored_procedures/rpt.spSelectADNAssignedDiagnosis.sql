-- =============================================
-- Author:		XX
-- Create date: 08/11/2023
-- Description:	
-- Change Control
--	
-- =============================================
CREATE PROCEDURE [rpt].[spSelectADNAssignedDiagnosis] @GO_LIVE date, @STARTDATE date, @ENDDATE date
AS
BEGIN
SET NOCOUNT ON;

 --DECLARE @STARTDATE AS DATE 
 --DECLARE @ENDDATE AS DATE
 --DECLARE @GO_LIVE AS DATE
 
 --SET @STARTDATE = DATEADD(DAY, -1,DATEFROMPARTS(YEAR(GETDATE()),MONTH(GETDATE()),1)); 
 --SET @ENDDATE = DATEADD(DAY,-1,DATEFROMPARTS(YEAR(GETDATE()),MONTH(GETDATE()),1)); 
 --SET @GO_LIVE = '4/28/2023';

select
    case
        when a.loc_id in ('43004', '43005') then 370203
        when a.loc_id in ('43006') then 370192 
    end [Hospital Identifier]
	,a.hsp_account_id [Encounter/Patient Identifier]
	,icd.code [Diagnosis Code]
	,dx.line [Diagnosis Type]
from [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].hsp_account a
left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].patient_3 p3 on a.pat_id = p3.pat_id
inner join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].HSP_ACCT_DX_LIST dx on a.hsp_account_id = dx.hsp_account_id
left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].EDG_CURRENT_ICD10 ICD on ICD.DX_ID = dx.DX_ID
left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_ACCT_BASECLS_HA bc ON bc.ACCT_BASECLS_HA_C = a.ACCT_BASECLS_HA_C
left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_ACCT_CLASS_HA ac ON ac.ACCT_CLASS_HA_C = a.ACCT_CLASS_HA_C
left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_ACCT_BILLSTS_HA bs ON bs.ACCT_BILLSTS_HA_C = a.ACCT_BILLSTS_HA_C
where 1=1 --a.disch_date_time between @STARTDATE and @ENDDATE /*Replaced with Coding Date Time on 3/14/24 */
	and a.disch_date_time >= @GO_LIVE
	and a.CODING_DATETIME between @STARTDATE and @ENDDATE
	and a.CODING_STATUS_C = 4 /*Completed*/
	--and a.completion_dt_tm is not null -- only complete coded accounts
	and a.loc_id  in ('43004', '43005', '43006') -- hpi hospitals only
	and p3.IS_TEST_PAT_YN = 'N' -- filter out test accounts


END
GO
