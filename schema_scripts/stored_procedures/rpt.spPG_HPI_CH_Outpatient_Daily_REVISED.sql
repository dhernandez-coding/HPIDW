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
-- =============================================
*/


CREATE PROCEDURE [rpt].[spPG_HPI_CH_Outpatient_Daily_REVISED] @STARTDATE date, @ENDDATE date AS


BEGIN
SET NOCOUNT ON;

--Criteria:
---        Event Date = t-1 to t-1
---        Service Area = 430
---        Location = COMMUNITY HOSPITAL NORTH, COMMUNITY HOSPITAL SOUTH
---        Event Types = Discharges, HOVs, Appointments
---		   Appointment Status = Arrived or Complete
---        Unit = HPI CHN CT, HPI CHN MRI, HPI CHN ULTRASOUND, HPI CHN MAMMO, HPI CHN DEXA, HPI CHN RADIOLOGY
--				  HPI CHS CT, HPI CHS MRI, HPI CHS ULTRASOUND, HPI CHS RADIOLOGY
---        Exclude: Confidential Patients
---        Only send the primary contact on the HAR [CER 732737]
---		   Survey Opt Out <> Yes
---        Patient Class = Outpatient
---		   Account Balance <> 0
--Patient Living Status = Alive
--Patient Rules = Primary Contact on HAR, HPI Coding Status Complete

--DECLARE @STARTDATE date = '11/2/2025'
--DECLARE @ENDDATE date = '11/3/2025'


IF OBJECT_ID(N'tempdb..##TempCHOP') IS NOT NULL
DROP TABLE ##TempCHOP


DECLARE @sql      varchar(8000)
      , @path     varchar(100)
      , @filename varchar(100)

DECLARE @prevAdvancedOptions int
DECLARE @prevXpCmdshell int
 
--SET @STARTDATE = '2023-09-11'
--SET @ENDDATE = '2023-09-15'


--SET @STARTDATE = DATEADD(DAY,-1,GETDATE())
--SET @ENDDATE = DATEADD(DAY,-1,GETDATE())

set @path = 'C:\Users\Public\PressGaney\PressGaney_Output\'
set @filename
     = 'HPI_CH_OP_Daily_' + CONVERT(NVARCHAR(10), @STARTDATE, 112) + '_to_' + CONVERT(NVARCHAR(10), @ENDDATE, 112)


;with cteProviders as (
	SELECT
	*
	FROM OPENQUERY([CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM],'
	select
		cs.prov_id
		,REPLACE(COALESCE(cs.EXTERNAL_NAME,cs.prov_name),'','','''') AS prov_name
		,zcsp.name ProviderSpeciality
	from [CLARITY].[ORGFILTER].clarity_ser cs
			left join [CLARITY].[ORGFILTER].[CLARITY_SER_SPEC] ss on cs.PROV_ID = ss.PROV_ID and ss.line = 1
			left join [CLARITY].[ORGFILTER].[ZC_SPECIALTY] zcsp on ss.SPECIALTY_C = zcsp.SPECIALTY_C
	')
), cteConfidentialPatients as (
	SELECT
	*
	FROM OPENQUERY([CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM],'
	select
		pt.pat_id 
	from [CLARITY].[ORGFILTER].patient_type pt
	    left join [CLARITY].[ORGFILTER].PAT_ENC_HSP eh on pt.pat_id = eh.pat_id
		left join [CLARITY].[ORGFILTER].zc_patient_type zcpt on pt.patient_type_c = zcpt.patient_type_c
	where zcpt.name not in (''VIP'', ''Employee Confidential'', ''Confidential'') AND eh.ADT_SERV_AREA_ID = 430
	group by pt.pat_id
	')
)


select
	'OU0102' PressGaneySurgeryDesignator -- ER0101 reporttype/file hardcode
		,case
		when sub.hospital_area_id like '43004%' or sub.hospital_area_id like '43005%' then 6987
		when sub.hospital_area_id like '43006%' then 7979 END ParentLocationID --6987 = community, 7979 = NW hospital
	,sub.pat_last_name LastName
	,ISNULL(LEFT(sub.pat_middle_name, 1), '') MiddleInitial
	,sub.pat_first_name FirstName					
	,Replace(sub.add_line_1, ',', '') PatientStreetAddressLine1		
	,Replace(sub.add_line_2, ',', '') PatientStreetAddressLine2			
	,sub.city PatientCity	
	,sub.PatientState PatientState
	,sub.zip PatientZIP
	,sub.HSP_ACCOUNT_ID HospitalAccountID
	,sub.PRIM_ENC_CSN_ID CSN
	,sub.pat_mrn_id MRN
	,REPLACE(CONVERT(VARCHAR(10), sub.birth_date, 101), '/', '') PatientDOB
	,dbo.GetAge(sub.birth_date, getdate()) as PatientAge
	,sub.sex_abbr sex_abbr
	,s.code lang
	,sub.OriginPoint --sub.admit_source_c OriginPoint
	,'' HospUnitLoc
	,sub.department_name	PGHospUnit
	,CASE 
		WHEN sub.acct_basecls_ha_c = 2 THEN 'Outpatient' END AS PatientClass
	,REPLACE(CONVERT(VARCHAR(10), sub.adm_date_time, 101), '/', '') ApptDate
	,'' ApptCheckoutTime --changed to blank to reflect extract
	,ISNULL(sub.PATIENT_STATUS_C, '') DischargeDisposition --place or setting? 
	,ISNULL(sub.attending_prov_id, '') AttendingProvID
	,ISNULL(attp.ProviderSpeciality, '') AttendingProviderSpeciality
	,ISNULL(attp.prov_name, '') AttendingProviderName
	,ISNULL(sub.email_address, '') PatientEmail
	,ISNULL(case when sub.email_address is null then sub.name end, '') PatientReasonforNoEmail
,ISNULL(REPLACE(sub.pat_home_phone, '-', ''), '') PatientCellPhone
,'$' EORIndicator	
INTO ##TempCHOP
FROM OPENQUERY([CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM],'
	select
		eh.hospital_area_id
		,p.pat_last_name
		,p.pat_middle_name
		,p.pat_first_name
		,p.add_line_1
		,p.add_line_2
		,p.city --PatientCity	
		,zcts.abbr as PatientState
		,p.zip --PatientZIP
		,a.HSP_ACCOUNT_ID --HospitalAccountID
		,a.PRIM_ENC_CSN_ID --CSN
		,p.pat_mrn_id --MRN
		,p.birth_date -- PatientDOB
		,zcs.abbr as sex_abbr
		,p.language_c
		--,s.code --lang
		,zcas.ABBR as OriginPoint --zcas.admit_source_c --OriginPoint
		,cd.department_name	--PGHospUnit
		,a.acct_basecls_ha_c --PatientClass
		,a.adm_date_time --ApptDate
		,a.PATIENT_STATUS_C
		,a.attending_prov_id
		--,attp.ProviderSpeciality
		--,attp.prov_name
		,p.email_address
		,zcer.name 
		,a.pat_home_phone

		,eh.pat_id
		,a.CODING_DATETIME
		,a.coding_status_c 
		,a.TOT_ACCT_BAL
		,a.TOT_CHGS
	from [CLARITY].[ORGFILTER].HSP_ACCOUNT a
		INNER JOIN [CLARITY].[ORGFILTER].PAT_ENC_HSP eh ON eh.PAT_ENC_CSN_ID = a.PRIM_ENC_CSN_ID
		LEFT JOIN [CLARITY].[ORGFILTER].PAT_ENC e ON e.PAT_ENC_CSN_ID = eh.PAT_ENC_CSN_ID
		LEFT JOIN [CLARITY].[ORGFILTER].pat_enc_hsp_2 e2 on e.pat_enc_csn_id = e2.pat_enc_csn_id
		LEFT JOIN [CLARITY].[ORGFILTER].hsp_account_3 a3 on a3.hsp_account_id = a.hsp_account_id
		LEFT JOIN [CLARITY].[ORGFILTER].PATIENT P ON eh.PAT_ID = p.PAT_ID
		LEFT JOIN [CLARITY].[ORGFILTER].patient_4 p4 on p.pat_id = p4.pat_id
		LEFT JOIN [CLARITY].[ORGFILTER].zc_no_email_reason zcer on p4.no_email_reason_c = zcer.no_email_reason_c
		LEFT JOIN [CLARITY].[ORGFILTER].clarity_dep cd ON eh.department_id = cd.department_id
		LEFT JOIN [CLARITY].[ORGFILTER].zc_tax_state zcts on p.state_c = zcts.tax_state_c 
		LEFT JOIN [CLARITY].[ORGFILTER].zc_sex zcs on p.sex_c = zcs.rcpt_mem_sex_c
		LEFT JOIN [CLARITY].[ORGFILTER].ZC_ADM_SOURCE zcas on eh.admit_source_c = zcas.admit_source_c
		--LEFT JOIN cteProviders attp on a.attending_prov_id = attp.prov_id
		--LEFT JOIN [map].[SurveyLanguageCodes] S ON p.language_c = s.language_c
	where 1=1
		and a.SERV_AREA_ID in (430)
		and (a.TOT_CHGS is null or a.TOT_CHGS <> 0)
		--and (a.TOT_ACCT_BAL is null or a.TOT_ACCT_BAL <> 0)
		and a.ACCT_BASECLS_HA_C = 2 /*Outpatient*/
		and eh.ADT_PATIENT_STAT_C in (3,6) /*Discharged, HOV*/
		and e.APPT_STATUS_C in (2,6) /*Arrived, Completed*/
		--and p.pat_id NOT IN (SELECT * FROM cteConfidentialPatients)
		and eh.DEPARTMENT_ID IN (43004001003, 43004001004, 43004001005, 43004001006, 43004001007, 43004001008, 43005005004, 43005005005, 43005005006, 43005005007)  --HPI CHN CT, HPI CHN MRI, HPI CHN ULTRASOUND, HPI CHN MAMMO, HPI CHN DEXA, HPI CHN RADIOLOGY HPI CHS CT, HPI CHS MRI, HPI CHS ULTRASOUND, HPI CHS RADIOLOGY
		and a.hsp_account_id LIKE ''6%''
		and ISNULL(e2.survey_opt_out_yn,''N'') <> ''Y''

		AND a.adm_date_time >= DATEADD(DAY,-365,GETDATE())
		AND CONVERT(DATE, a.CODING_DATETIME) is not null --BETWEEN @STARTDATE and @ENDDATE
		') sub
	LEFT JOIN cteProviders attp on sub.attending_prov_id = attp.prov_id
	LEFT JOIN [map].[SurveyLanguageCodes] S ON sub.language_c = s.language_c
WHERE 1=1
	AND sub.pat_id NOT IN (SELECT * FROM cteConfidentialPatients)
	AND CONVERT(DATE,sub.adm_date_time) between @STARTDATE and @ENDDATE
	--and CONVERT(DATE,sub.CODING_DATETIME)e between @STARTDATE and @ENDDATE


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

end
GO
