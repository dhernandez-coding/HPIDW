/*
--=============================================
--Author:		Jacob Roan
--Create date: 08/22/2023
--Description:	compiles data for press ganey export
--Change Control:
10/06/2023: Zeke Herrera: Added additional logic to export SP
12/14/2023: Zeke Herrera: Added logic to strip commas out of the address line
12/14/2023: Zeke Herrera: Adjusting stored procedure to be sent out daily
1/23/2024: Eric Silvestri: Changed from completion date to coding completion date
1/23/2024: Eric Silvestri: Updated CTEConfidentialPatients to include 430 Service area only 
10/16/2026: Eric Silvestri: Converted linked server queries to OPENQUERY
--=============================================
*/

CREATE PROCEDURE [rpt].[spPG_ED_Daily_NEW] @STARTDATE date, @ENDDATE date
AS
BEGIN
SET NOCOUNT ON;

--Criteria:
---		   Event Date = t-1
---		   Service Area = 430
---		   Location = COMMUNITY HOSPITAL NORTH, COMMUNITY HOSPITAL SOUTH
---		   Event Types = Discharges
---		   Unit = HPI CHN EMERGENCY, HPI CHS EMERGENCY
---		   Patient Class = Emergency
--Patient Living Status = Alive


IF OBJECT_ID(N'tempdb..##TempED') IS NOT NULL DROP TABLE ##TempED
IF OBJECT_ID(N'tempdb..#cteProviders') IS NOT NULL DROP TABLE #cteProviders
IF OBJECT_ID(N'tempdb..#TempFinal') IS NOT NULL DROP TABLE #TempFinal


--DECLARE @STARTDATE AS DATE = '2026-10-15'
--DECLARE @ENDDATE AS DATE = '2026-10-15'
DECLARE @sql      varchar(8000)
      , @path     varchar(100)
      , @filename varchar(100)
	  , @OQ       nvarchar(max)  /*holds the OPENQUERY statements that need the date parameters*/

DECLARE @prevAdvancedOptions int
DECLARE @prevXpCmdshell int

SET @path = 'C:\Users\Public\PressGaney\PressGaney_Output\'
SET @filename
     = 'HPI_CH_ED_Daily_' + CONVERT(NVARCHAR(10), @STARTDATE, 112) + '_to_' + CONVERT(NVARCHAR(10), @ENDDATE, 112)



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
	 hospital_area_id      numeric(18,0)
	,pat_last_name         varchar(200)
	,pat_middle_name       varchar(200)
	,pat_first_name        varchar(200)
	,add_line_1            varchar(254)
	,add_line_2            varchar(254)
	,city                  varchar(100)
	,state_abbr            varchar(50)
	,zip                   varchar(50)
	,hsp_account_id        numeric(18,0)
	,pat_enc_csn_id        numeric(18,0)
	,pat_mrn_id            varchar(50)
	,birth_date            datetime
	,sex_abbr              varchar(50)
	,lang_name             varchar(254)
	,adm_source_name       varchar(254)
	,department_id         numeric(18,0)
	,bed_id                varchar(50)
	,pat_class_name        varchar(254)
	,pat_service_name      varchar(254)
	,adm_date_time         datetime
	,disch_date_time       datetime
	,patient_status_c      varchar(66)
	,final_drg_id          varchar(50)
	,icu_department_id     numeric(18,0)
	,admission_prov_id     varchar(18)
	,attending_prov_id     varchar(18)
	,email_address         varchar(254)
	,no_email_reason       varchar(254)
	,pat_home_phone        varchar(50)
	,pat_living_stat_name  varchar(254)
	,survey_opt_out_yn     varchar(1)
);

SET @OQ = N'
INSERT INTO #TempFinal
SELECT * FROM OPENQUERY([CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM], ''
	select
	e.hospital_area_id
	,p.pat_last_name
	,p.pat_middle_name
	,p.pat_first_name
	,p.add_line_1
	,p.add_line_2
	,p.city
	,zcts.abbr AS state_abbr
	,p.zip
	,e.hsp_account_id
	,e.pat_enc_csn_id
	,p.pat_mrn_id
	,p.birth_date
	,zcs.abbr AS sex_abbr
	,zcl.name AS lang_name
	,zcas.name AS adm_source_name
	,e.department_id
	,e.bed_id
	,zcpc.name AS pat_class_name
	,zcps.name AS pat_service_name
	,a.adm_date_time
	,a.disch_date_time
	,a.PATIENT_STATUS_C
	,a.final_drg_id
	,icu.department_id AS icu_department_id
	,e.admission_prov_id
	,a.attending_prov_id
	,p.email_address
	,zcer.name AS no_email_reason
	,a.pat_home_phone
	,pls.name AS pat_living_stat_name
	,e2.survey_opt_out_yn
	from CLARITY.ORGFILTER.PAT_ENC_HSP e
		left join CLARITY.ORGFILTER.pat_enc_hsp_2 e2 on e.pat_enc_csn_id = e2.pat_enc_csn_id
		left join CLARITY.ORGFILTER.f_pat_icu_location icu on e.pat_enc_csn_id = icu.pat_enc_csn_id
		left join CLARITY.ORGFILTER.ZC_ADM_SOURCE zcas on e.admit_source_c = zcas.admit_source_c
		left join CLARITY.ORGFILTER.ZC_PAT_CLASS zcpc on e.adt_pat_class_c = zcpc.adt_pat_class_c
		left join CLARITY.ORGFILTER.zc_pat_service zcps on e.hosp_serv_c = zcps.hosp_serv_c
		left join CLARITY.ORGFILTER.clarity_dep cd ON e.department_id = cd.department_id
		left join CLARITY.ORGFILTER.PATIENT p ON e.PAT_ID = p.PAT_ID
		left join CLARITY.ORGFILTER.patient_4 p4 on p.pat_id = p4.pat_id
		left join CLARITY.ORGFILTER.zc_pat_living_stat pls on p4.pat_living_stat_c = pls.pat_living_stat_c
		left join CLARITY.ORGFILTER.zc_no_email_reason zcer on p4.no_email_reason_c = zcer.no_email_reason_c
		left join CLARITY.ORGFILTER.zc_tax_state zcts on p.state_c = zcts.tax_state_c
		left join CLARITY.ORGFILTER.zc_sex zcs on p.sex_c = zcs.rcpt_mem_sex_c
		left join CLARITY.ORGFILTER.zc_language zcl on p.language_c = zcl.language_c
		left join CLARITY.ORGFILTER.hsp_account a ON e.hsp_account_id = a.hsp_account_id
	where
		cast(a.CODING_DATETIME as date) between ''''' + CONVERT(char(8), @STARTDATE, 112) + ''''' and ''''' + CONVERT(char(8), @ENDDATE, 112) + '''''
		and pls.name = ''''Alive''''
		AND cd.DEPARTMENT_ID IN (43004001002, 43005005003) /*HPI CHN EMERGENCY, HPI CHS EMERGENCY*/
		and e.adt_serv_area_id = 430
'')';
--PRINT @OQ
EXEC (@OQ);



/*=====================================================================
  Final select - local
  =====================================================================*/
select
	'ER0101' PressGaneySurgeyDesignatorEPT
	,case
		when f.hospital_area_id like '43004%' or f.hospital_area_id like '43005%' then 6987
		when f.hospital_area_id like '43006%' then 7979
	end HospitalAreaClientID --6987 = community, 7979 = NW hospital hardcode
	,f.pat_last_name LastName
	,f.pat_middle_name MiddleName
	,f.pat_first_name FirstName
	,Replace(f.add_line_1, ',', '') PatientStreetAddressLine1
	,Replace(f.add_line_2, ',', '') PatientStreetAddressLine2
	,f.city PatientCity
	,f.state_abbr PatientState
	,f.zip PatientZIP
	,f.hsp_account_id HospitalAccountID
	,f.pat_enc_csn_id CSN
	,f.pat_mrn_id MRN
	,REPLACE(CONVERT(VARCHAR(10), f.birth_date, 101), '/', '') PatientDOB
	,dbo.GetAge(f.birth_date, getdate()) as PatientAge
	,f.sex_abbr sex_abbr
	,f.lang_name lang
	,f.adm_source_name adm_source_name
	,f.department_id OriginPoint
	,f.department_id HospUnitLoc
	,f.bed_id Bed
	,f.pat_class_name PatientClass
	,f.pat_service_name PatientService
	,REPLACE(CONVERT(VARCHAR(10), f.adm_date_time, 101), '/', '') AdmitDate		
	,REPLACE(CONVERT(VARCHAR(10), f.disch_date_time, 101), '/', '') DischargeDate
	,ISNULL(f.PATIENT_STATUS_C, '') HARDischargeDisposition
	,f.final_drg_id DRG
	,case when f.icu_department_id is not null then 'Y' else 'N' end as ICUStayIndicator
	,f.admission_prov_id AdmittingProviderID
	,admp.ProviderSpeciality AdmittingProviderSpeciality
	,admp.prov_name AdmittingProviderName
	,f.attending_prov_id AttendingProviderID
	,attp.ProviderSpeciality AttendingProviderSpeciality
	,attp.prov_name AttendingProviderName
	,f.email_address PatientEmail
	,case when f.email_address is null then f.no_email_reason end PatientReasonforNoEmail
	,replace(f.pat_home_phone,'-','') PatientCellPhone
	,CASE WHEN f.pat_living_stat_name = 'Alive' THEN 'N' 	
			WHEN f.pat_living_stat_name = 'Deceased' THEN 'Y' 
			ELSE f.pat_living_stat_name END AS PatientLivingStatus
	,isnull(f.survey_opt_out_yn, 'N') SurveyOptOut
	,' ' FreeSpace
	,case when f.birth_date > DATEADD(month, -2, getdate()) then 'Y' else 'N' end NewbornAdmission
	,'$' EORIndicator
INTO ##TempED
from #TempFinal f
	left join #cteProviders admp on f.admission_prov_id = admp.prov_id
	left join #cteProviders attp on f.attending_prov_id = attp.prov_id



/*=====================================================================
  Export - unchanged
  =====================================================================*/
DECLARE @query varchar(8000) = 'SET NOCOUNT ON;' + 
'SELECT CAST(PressGaneySurgeyDesignatorEPT as varchar(8)), '','',' + 
'CAST(HospitalAreaClientID as varchar(7)), '','',' + 
'CAST(LastName as varchar(25)), '','',' +
'CAST(MiddleName as varchar(1)), '','',' +
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
'CAST(adm_source_name as varchar(30)), '','',' +
'CAST(OriginPoint as varchar(20)), '','',' +
'CAST(HospUnitLoc as varchar(20)), '','',' +
'CAST(Bed as varchar(50)), '','',' +
'CAST(PatientClass as varchar(50)), '','',' +
'CAST(PatientService as varchar(50)), '','',' +
'CAST(AdmitDate as varchar(10)), '','',' +
'CAST(DischargeDate as varchar(10)), '','',' +
'CAST(HARDischargeDisposition as varchar(5)), '','',' +
'CAST(DRG as varchar(5)), '','',' +
'CAST(ICUStayIndicator as varchar(1)), '','',' +
'CAST(AdmittingProviderID as varchar(50)), '','',' +
'CAST(AdmittingProviderSpeciality as varchar(50)), '','',' +
'CAST(AdmittingProviderName as varchar(50)), '','',' +
'CAST(AttendingProviderID as varchar(50)), '','',' +
'CAST(AttendingProviderSpeciality as varchar(50)), '','',' +
'CAST(AttendingProviderName as varchar(50)), '','',' +
'CAST(PatientEmail as varchar(60)), '','',' +
'CAST(PatientReasonforNoEmail as varchar(30)), '','',' +
'CAST(PatientCellPhone as varchar(12)), '','',' +
'CAST(PatientLivingStatus as varchar(1)), '','',' +
'CAST(SurveyOptOut as varchar(1)), '','',' +
'CAST(FreeSpace as varchar(1)), '','',' +
'CAST(NewbornAdmission as varchar(1)), '','',' +
'CAST(EORIndicator as varchar(1)) FROM ##TempED'



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

/*Moved out of the IF block above - previously only dropped when advanced options was off*/
DROP TABLE ##TempED
DROP TABLE #cteProviders
DROP TABLE #TempFinal

END
GO
