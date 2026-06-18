-- =============================================
-- Author:		XX
-- Create date: 08/11/2023
-- Description:	
-- Change Control
--	
-- =============================================
CREATE PROCEDURE [rpt].[spSelectADNPayerFile] @GO_LIVE date, @STARTDATE date, @ENDDATE date
AS
BEGIN
SET NOCOUNT ON;

--DECLARE @STARTDATE AS DATE 
--DECLARE @ENDDATE AS DATE
--DECLARE @GO_LIVE AS DATE
 
--SET @STARTDATE =DATEADD(DAY,-10,DATEFROMPARTS(YEAR(GETDATE()),MONTH(GETDATE()),1)); 
--SET @ENDDATE = DATEADD(DAY,-1,DATEFROMPARTS(YEAR(GETDATE()),MONTH(GETDATE()),1)); 
--SET @GO_LIVE = '4/28/2023'

SELECT 
	case
        when ha.loc_id in ('43004', '43005') then 370203
        when ha.loc_id in ('43006') then 370192 
		end [Hospital Identifier]
	,ISNULL(Cast(ha.hsp_account_id as varchar),'') AS [Encounter/Patient Identifier/Billing ID]
	,epm.PAYOR_ID AS [Payer/Insurance Code]
	,case when fc.FINANCIAL_CLASS in (2,101,140,220,300,301,302,303,304,305,306) THEN 1 --Medicare
		 when fc.FINANCIAL_CLASS in (3,215) THEN 2 --Medicaid
      	   when fc.FINANCIAL_CLASS in (5,240) THEN 3 --Worker's Comp
      	   when fc.FINANCIAL_CLASS = 6 THEN 4 --Tricare
      	   when fc.FINANCIAL_CLASS = 150 THEN 11 --Other HMO
      	   when fc.FINANCIAL_CLASS = 4 THEN 13 --Self Pay
      	   when fc.FINANCIAL_CLASS IS NULL THEN 13 --Self Pay
      	   else 10/*Other Commercial*/ end as [ADN Standard Payer Code]
	,HAC.LINE AS [Payer Type]
	--,'' AS [HIC Number]
FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].HSP_ACCOUNT HA
INNER JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].PATIENT PAT ON PAT.PAT_ID = HA.PAT_ID
INNER JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].PATIENT_3 p3 ON p3.PAT_ID = HA.PAT_ID
INNER JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].HSP_ACCT_CVG_LIST HAC ON ha.hsp_account_id = hac.hsp_account_id
INNER JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].Coverage c on c.COVERAGE_ID = HAC.COVERAGE_ID
INNER JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].CLARITY_EPM EPM ON EPM.PAYOR_ID = C.PAYOR_ID
INNER JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].CLARITY_FC FC ON FC.FINANCIAL_CLASS = EPM.FINANCIAL_CLASS
where 1=1 --a.disch_date_time between @STARTDATE and @ENDDATE /*Replaced with Coding Date Time on 3/14/24 */
	and ha.disch_date_time >= @GO_LIVE
	and ha.CODING_DATETIME between @STARTDATE and @ENDDATE
	and ha.CODING_STATUS_C = 4 /*Completed*/
	--and a.completion_dt_tm is not null -- only complete coded accounts
	and ha.loc_id  in ('43004', '43005', '43006') -- hpi hospitals only
	and p3.IS_TEST_PAT_YN = 'N' -- filter out test accounts


	end
GO
