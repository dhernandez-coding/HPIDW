/*
-- =============================================
-- Author:		Zeke Herrera
-- Create date: 08/31/2023
-- Description:	compiles data for press ganey export
-- Change Control
12/14/2023: Zeke Herrera: Added logic to strip commas out of the address line
12/14/2023: Zeke Herrera: Adjusting stored procedure to be sent out daily
1/23/2024: Eric Silvestri: Changed from completion date to coding completion date
1/23/2024: Eric Silvestri: Updated CTEConfidentialPatients to include 430 Service area only 
12/30/2025: Chris Cross: Updated Admission Source from zcas.ADMIT_SOURCE_C to zcas.ABBR
10/16/2026: Eric Silvestri: Converted linked server queries to OPENQUERY
-- =============================================
*/

CREATE PROCEDURE [rpt].[spPG_HPI_CH_Outpatient_Daily_NEW] @STARTDATE date, @ENDDATE date
AS
BEGIN
SET NOCOUNT ON;

--Criteria:
---		   Event Date = t-1 to t-1
---		   Service Area = 430
---		   Location = COMMUNITY HOSPITAL NORTH, COMMUNITY HOSPITAL SOUTH
---		   Event Types = Discharges, HOVs, Appointments
---		   Appointment Status = Arrived or Complete
---		   Unit = HPI CHN CT, HPI CHN MRI, HPI CHN ULTRASOUND, HPI CHN MAMMO, HPI CHN DEXA, HPI CHN RADIOLOGY
--				  HPI CHS CT, HPI CHS MRI, HPI CHS ULTRASOUND, HPI CHS RADIOLOGY
---		   Survey Opt Out <> Yes
---		   Patient Class = Outpatient
---		   Account Balance <> 0


IF OBJECT_ID(N'tempdb..##TempCHOP') IS NOT NULL DROP TABLE ##TempCHOP
IF OBJECT_ID(N'tempdb..#cteProviders') IS NOT NULL DROP TABLE #cteProviders
IF OBJECT_ID(N'tempdb..#TempFinal') IS NOT NULL DROP TABLE #TempFinal


--DECLARE @STARTDATE AS DATE = '2026-10-01'
--DECLARE @ENDDATE AS DATE = '2026-10-01'
DECLARE @sql      varchar(8000)
      , @path     varchar(100)
      , @filename varchar(100)
	  , @OQ       nvarchar(max)  /*holds the OPENQUERY statements that need the date parameters*/

DECLARE @prevAdvancedOptions int
DECLARE @prevXpCmdshell int

set @path = 'C:\Users\Public\PressGaney\PressGaney_Output\'
set @filename
     = 'HPI_CH_OP_Daily_' + CONVERT(NVARCHAR(10), @STARTDATE, 112) + '_to_' + CONVERT(NVARCHAR(10), @ENDDATE, 112)



/*=====================================================================
  #cteProviders (no date parameters - static OPENQUERY)
  =====================================================================*/
select
	prov_id
	,REPLACE(prov_name, ',', '') AS prov_name
	,ProviderSpeciality
into #cteProviders
from OPENQUERY([CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM], '
	select
		cs.prov_id
		,COALESCE(cs.EXTERNAL_NAME, cs.prov_name) AS prov_name
		,zcsp.name AS ProviderSpeciality
	from CLARITY.ORGFILTER.clarity_ser cs
		left join CLARITY.ORGFILTER.CLARITY_SER_SPEC ss on cs.PROV_ID = ss.PROV_ID and ss.line = 1
		left join CLARITY.ORGFILTER.ZC_SPECIALTY zcsp on ss.SPECIALTY_C = zcsp.SPECIALTY_C
')

/*cteConfidentialPatients was defined but never referenced (filter commented out) - not pulled*/



/*=====================================================================
  #TempFinal - Clarity columns for the final select
  (raw columns only; formatting stays in the local final select below)
  =====================================================================*/
CREATE TABLE #TempFinal (
	 hsp_account_id        numeric(18,0)
	,prim_enc_csn_id       numeric(18,0)
	,hospital_area_id      numeric(18,0)
	,pat_last_name         varchar(200)
	,pat_middle_name       varchar(200)
	,pat_first_name        varchar(200)
	,add_line_1            varchar(254)
	,add_line_2            varchar(254)
	,city                  varchar(100)
	,state_abbr            varchar(50)
	,zip                   varchar(50)
	,pat_mrn_id            varchar(50)
	,birth_date            datetime
	,sex_abbr              varchar(50)
	,language_c            varchar(66)
	,admit_source_abbr     varchar(50)
	,department_name       varchar(254)
	,acct_basecls_ha_c     varchar(66)
	,adm_date_time         datetime
	,patient_status_c      varchar(66)
	,attending_prov_id     varchar(18)
	,email_address         varchar(254)
	,no_email_reason       varchar(254)
	,pat_home_phone        varchar(50)
);

SET @OQ = N'
INSERT INTO #TempFinal
SELECT * FROM OPENQUERY([CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM], ''
	select
	a.HSP_ACCOUNT_ID
	,a.PRIM_ENC_CSN_ID
	,eh.hospital_area_id
	,p.pat_last_name
	,p.pat_middle_name
	,p.pat_first_name
	,p.add_line_1
	,p.add_line_2
	,p.city
	,zcts.abbr AS state_abbr
	,p.zip
	,p.pat_mrn_id
	,p.birth_date
	,zcs.abbr AS sex_abbr
	,p.language_c
	,zcas.ABBR AS admit_source_abbr
	,cd.department_name
	,a.acct_basecls_ha_c
	,a.adm_date_time
	,a.PATIENT_STATUS_C
	,a.attending_prov_id
	,p.email_address
	,zcer.name AS no_email_reason
	,a.pat_home_phone
	from CLARITY.ORGFILTER.HSP_ACCOUNT a
		INNER JOIN CLARITY.ORGFILTER.PAT_ENC_HSP eh ON eh.PAT_ENC_CSN_ID = a.PRIM_ENC_CSN_ID
		LEFT JOIN CLARITY.ORGFILTER.PAT_ENC e ON e.PAT_ENC_CSN_ID = eh.PAT_ENC_CSN_ID
		LEFT JOIN CLARITY.ORGFILTER.pat_enc_hsp_2 e2 on e.pat_enc_csn_id = e2.pat_enc_csn_id
		LEFT JOIN CLARITY.ORGFILTER.PATIENT P ON eh.PAT_ID = p.PAT_ID
		LEFT JOIN CLARITY.ORGFILTER.patient_4 p4 on p.pat_id = p4.pat_id
		LEFT JOIN CLARITY.ORGFILTER.zc_no_email_reason zcer on p4.no_email_reason_c = zcer.no_email_reason_c
		LEFT JOIN CLARITY.ORGFILTER.clarity_dep cd ON eh.department_id = cd.department_id
		LEFT JOIN CLARITY.ORGFILTER.zc_tax_state zcts on p.state_c = zcts.tax_state_c 
		LEFT JOIN CLARITY.ORGFILTER.zc_sex zcs on p.sex_c = zcs.rcpt_mem_sex_c
		LEFT JOIN CLARITY.ORGFILTER.ZC_ADM_SOURCE zcas on eh.admit_source_c = zcas.admit_source_c
	where 1=1
		and a.SERV_AREA_ID in (430)
		and (a.TOT_ACCT_BAL is null or a.TOT_ACCT_BAL <> 0)
		and a.ACCT_BASECLS_HA_C = 2 /*Outpatient*/
		and eh.ADT_PATIENT_STAT_C in (3,6) /*Discharged, HOV*/
		and e.APPT_STATUS_C in (2,6) /*Arrived, Completed*/
		and eh.DEPARTMENT_ID IN (43004001003, 43004001004, 43004001005, 43004001006, 43004001007, 43004001008, 43005005004, 43005005005, 43005005006, 43005005007)  /*HPI CHN CT, HPI CHN MRI, HPI CHN ULTRASOUND, HPI CHN MAMMO, HPI CHN DEXA, HPI CHN RADIOLOGY HPI CHS CT, HPI CHS MRI, HPI CHS ULTRASOUND, HPI CHS RADIOLOGY*/
		and a.hsp_account_id LIKE ''''6%''''
		and ISNULL(e2.survey_opt_out_yn,''''N'''') <> ''''Y''''
		and CONVERT(DATE, a.CODING_DATETIME) between ''''' + CONVERT(char(8), @STARTDATE, 112) + ''''' and ''''' + CONVERT(char(8), @ENDDATE, 112) + '''''
'')';
--PRINT @OQ
EXEC (@OQ);



/*=====================================================================
  Final select - local
  =====================================================================*/
select
	'OU0102' PressGaneySurgeryDesignator
		,case
		when f.hospital_area_id like '43004%' or f.hospital_area_id like '43005%' then 6987
		when f.hospital_area_id like '43006%' then 7979 END ParentLocationID --6987 = community, 7979 = NW hospital
	,f.pat_last_name LastName
	,ISNULL(LEFT(f.pat_middle_name, 1), '') MiddleInitial
	,f.pat_first_name FirstName					
	,Replace(f.add_line_1, ',', '') PatientStreetAddressLine1		
	,Replace(f.add_line_2, ',', '') PatientStreetAddressLine2			
	,f.city PatientCity	
	,f.state_abbr PatientState
	,f.zip PatientZIP
	,f.HSP_ACCOUNT_ID HospitalAccountID
	,f.PRIM_ENC_CSN_ID CSN
	,f.pat_mrn_id MRN
	,REPLACE(CONVERT(VARCHAR(10), f.birth_date, 101), '/', '') PatientDOB
	,dbo.GetAge(f.birth_date, getdate()) as PatientAge
	,f.sex_abbr sex_abbr
	,s.code lang
	,f.admit_source_abbr as OriginPoint
	,'' HospUnitLoc
	,f.department_name PGHospUnit
	,CASE 
		WHEN f.acct_basecls_ha_c = 2 THEN 'Outpatient' END AS PatientClass
	,REPLACE(CONVERT(VARCHAR(10), f.adm_date_time, 101), '/', '') ApptDate
	,'' ApptCheckoutTime --changed to blank to reflect extract
	,ISNULL(f.PATIENT_STATUS_C, '') DischargeDisposition
	,ISNULL(f.attending_prov_id, '') AttendingProvID
	,ISNULL(attp.ProviderSpeciality, '') AttendingProviderSpeciality
	,ISNULL(attp.prov_name, '') AttendingProviderName
	,ISNULL(f.email_address, '') PatientEmail
	,ISNULL(case when f.email_address is null then f.no_email_reason end, '') PatientReasonforNoEmail
,ISNULL(REPLACE(f.pat_home_phone, '-', ''), '') PatientCellPhone
,'$' EORIndicator	
INTO ##TempCHOP
from #TempFinal f
	LEFT JOIN #cteProviders attp on f.attending_prov_id = attp.prov_id
	LEFT JOIN [map].[SurveyLanguageCodes] S ON f.language_c = s.language_c



/*=====================================================================
  Export - unchanged
  =====================================================================*/
DECLARE @query varchar(8000) = 'SET NOCOUNT ON;' + 
'SELECT CAST(PressGaneySurgeryDesignator as varchar(8)), '','',' + 
'CAST(ParentLocationID as varchar(7)), '','',' + 
'CAST(LastName as varchar(25)), '','',' +
'CAST(MiddleInitial as varchar(1)), '','',' +
'CAST(FirstName as varchar(20)), '','',' +
'CAST(PatientStreetAddressLine1 as varchar(40)), '','',' +
'CAST(PatientStreetAddressLine2 as varchar(40)), '','',' +
'CAST(PatientCity as varchar(25)), '','',' +
'CAST(PatientState as varchar(2)), '','',' +
'CAST(PatientZIP as varchar(10)), '','',' +
'CAST(HospitalAccountID as varchar(9)), '','',' +
'CAST(CSN as varchar(11)), '','',' +
'CAST(MRN as varchar(20)), '','',' +
'CAST(PatientDOB as varchar(10)), '','',' +
'CAST(PatientAge as varchar(3)), '','',' +
'CAST(sex_abbr as varchar(1)), '','',' +
'CAST(lang as varchar(50)), '','',' +
'CAST(OriginPoint as varchar(20)), '','',' +
'CAST(HospUnitLoc as varchar(20)), '','',' +
'CAST(PGHospUnit as varchar(50)), '','',' +
'CAST(PatientClass as varchar(50)), '','',' +
'CAST(ApptDate as varchar(8)), '','',' +
'CAST(ApptCheckoutTime as varchar(8)), '','',' +
'CAST(DischargeDisposition as varchar(2)), '','',' +
'CAST(AttendingProvID as varchar(50)), '','',' +
'CAST(AttendingProviderSpeciality as varchar(50)), '','',' +
'CAST(AttendingProviderName as varchar(50)), '','',' +
'CAST(PatientEmail as varchar(60)), '','',' +
'CAST(PatientReasonforNoEmail as varchar(30)), '','',' +
'CAST(PatientCellPhone as varchar(12)), '','',' +
'CAST(EORIndicator as varchar(1)) FROM ##TempCHOP'



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

select @sql
    = 'sqlcmd -S ' + @@SERVERNAME + ' -d HPIDW -E -h -1 -Q "' + @query + '"	-o "' + @path + @filename
      + '.csv" -s ""'



exec master..xp_cmdshell @sql



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


DROP TABLE ##TempCHOP
DROP TABLE #cteProviders
DROP TABLE #TempFinal

end
GO
