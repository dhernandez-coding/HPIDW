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
--=============================================
*/

	CREATE PROCEDURE [rpt].[spPG_ED_Daily] @STARTDATE date, @ENDDATE date
	AS
	BEGIN
	SET NOCOUNT ON;

--Criteria:
---        Event Date = t-1
---        Service Area = 430
---        Location = COMMUNITY HOSPITAL NORTH, COMMUNITY HOSPITAL SOUTH
---        Event Types = Discharges
---        Unit = HPI CHN EMERGENCY, HPI CHS EMERGENCY
---        Exclude Confidential Patients
---        Only send the primary contact on the HAR [CER 732737]
---        Patient Class = Emergency
--Patient Living Status = Alive
--Patient Rules = Primary Contact on HAR


/*Clear out TempED table*/
IF OBJECT_ID(N'tempdb..##TempED') IS NOT NULL
BEGIN
DROP TABLE ##TempED
END


--DECLARE @STARTDATE AS DATE 
--DECLARE @ENDDATE AS DATE

--SET @STARTDATE = '2023-09-11'
--SET @ENDDATE = '2023-09-15'
DECLARE @sql      varchar(8000)
      , @path     varchar(100)
      , @filename varchar(100)

DECLARE @prevAdvancedOptions int
DECLARE @prevXpCmdshell int
 
--SET @STARTDATE = DATEADD(DAY,-2,GETDATE())
--SET @ENDDATE = DATEADD(DAY,-2,GETDATE())
SET @path = 'C:\Users\Public\PressGaney\PressGaney_Output\'
SET @filename
     = 'HPI_CH_ED_Daily_' + CONVERT(NVARCHAR(10), @STARTDATE, 112) + '_to_' + CONVERT(NVARCHAR(10), @ENDDATE, 112)






;with cteProviders as (
	select
		cs.prov_id
		,REPLACE(COALESCE(cs.EXTERNAL_NAME,cs.prov_name),',','') AS prov_name
		,zcsp.name ProviderSpeciality
	from [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].clarity_ser cs
			left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[CLARITY_SER_SPEC] ss on cs.PROV_ID = ss.PROV_ID and ss.line = 1
				left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[ZC_SPECIALTY] zcsp on ss.SPECIALTY_C = zcsp.SPECIALTY_C
), cteConfidentialPatients as (
	select
		pt.pat_id 
	from [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].patient_type pt
	    left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].PAT_ENC_HSP eh on pt.pat_id = eh.pat_id
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].zc_patient_type zcpt on pt.patient_type_c = zcpt.patient_type_c
	where zcpt.name not in ('VIP', 'Employee Confidential', 'Confidential') AND eh.ADT_SERV_AREA_ID = 430
	group by pt.pat_id
)


select
	'ER0101' PressGaneySurgeyDesignatorEPT -- ER0101 reporttype/file hardcode
	,case
		when e.hospital_area_id like '43004%' or e.hospital_area_id like '43005%' then 6987
		when e.hospital_area_id like '43006%' then 7979
	end HospitalAreaClientID --6987 = community, 7979 = NW hospital hardcode
	,p.pat_last_name LastName
	,p.pat_middle_name MiddleName
	,p.pat_first_name FirstName
	,Replace(p.add_line_1, ',', '') PatientStreetAddressLine1
	,Replace(p.add_line_2, ',', '') PatientStreetAddressLine2
	,p.city PatientCity
	,zcts.abbr PatientState
	,p.zip PatientZIP
	,e.hsp_account_id HospitalAccountID --??? HAR?
	,e.pat_enc_csn_id CSN --,ept_csn?
	,p.pat_mrn_id MRN
	,REPLACE(CONVERT(VARCHAR(10), p.birth_date, 101), '/', '') PatientDOB
	,dbo.GetAge(p.birth_date, getdate()) as PatientAge
	,zcs.abbr sex_abbr
	,zcl.name lang
	,zcas.name adm_source_name
	,e.department_id OriginPoint
	,e.department_id HospUnitLoc
	,e.bed_id Bed
	,zcpc.name PatientClass
	,zcps.name PatientService
	,REPLACE(CONVERT(VARCHAR(10), a.adm_date_time, 101), '/', '') AdmitDate		
	,REPLACE(CONVERT(VARCHAR(10), a.disch_date_time, 101), '/', '') DischargeDate
	,ISNULL(a.PATIENT_STATUS_C, '') HARDischargeDisposition
	,a.final_drg_id DRG
	,case when icu.department_id is not null then 'Y' else 'N' end as ICUStayIndicator
	--,e.emer_adm_date
	,e.admission_prov_id AdmittingProviderID
	,admp.ProviderSpeciality AdmittingProviderSpeciality
	,admp.prov_name AdmittingProviderName
	,a.attending_prov_id AttendingProviderID
	,attp.ProviderSpeciality AttendingProviderSpeciality
	,attp.prov_name AttendingProviderName
	,p.email_address PatientEmail
	,case when p.email_address is null then zcer.name end PatientReasonforNoEmail
	,replace(a.pat_home_phone,'-','') PatientCellPhone
	,CASE WHEN pls.name = 'Alive' THEN 'N' 	
			WHEN pls.name = 'Deceased' THEN 'Y' 
			ELSE pls.name END AS PatientLivingStatus
	,isnull(e2.survey_opt_out_yn, 'N') SurveyOptOut -- not sure about this most are blank
	,' ' FreeSpace
	,case when p.birth_date > DATEADD(month, -2, getdate()) then 'Y' else 'N' end NewbornAdmission
	,'$' EORIndicator
INTO ##TempED
from [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].PAT_ENC_HSP e
--left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[ZC_DISP_ENC_TYPE] et ON e.ENC_TYPE_C = et.DISP_ENC_TYPE_C
	left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].pat_enc_hsp_2 e2 on e.pat_enc_csn_id = e2.pat_enc_csn_id
	left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].f_pat_icu_location icu on e.pat_enc_csn_id = icu.pat_enc_csn_id
	left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_ADM_SOURCE zcas on e.admit_source_c = zcas.admit_source_c
	left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_PAT_CLASS zcpc on e.adt_pat_class_c = zcpc.adt_pat_class_c
	left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].zc_pat_service zcps on e.hosp_serv_c = zcps.hosp_serv_c
	left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].clarity_dep cd ON e.department_id = cd.department_id
	left join cteProviders admp on e.admission_prov_id = admp.prov_id
	left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].PATIENT p ON e.PAT_ID = p.PAT_ID
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].patient_4 p4 on p.pat_id = p4.pat_id
			left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].zc_pat_living_stat pls on p4.pat_living_stat_c = pls.pat_living_stat_c
			left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].zc_no_email_reason zcer on p4.no_email_reason_c = zcer.no_email_reason_c
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].zc_tax_state zcts on p.state_c = zcts.tax_state_c
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].zc_sex zcs on p.sex_c = zcs.rcpt_mem_sex_c
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].zc_language zcl on p.language_c = zcl.language_c
	left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].hsp_account a ON e.hsp_account_id = a.hsp_account_id
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].hsp_account_3 a3 on a.hsp_account_id = a3.hsp_account_id
		left join cteProviders attp on a.attending_prov_id = attp.prov_id
			--left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].zc_disch_disp zcdd on a3.pat_sts_ept_c = zcdd.disch_disp_c
where
	cast(a.CODING_DATETIME as date) between @STARTDATE and @ENDDATE  -- date filter
	--and zcpc.name /*PatientClass*/ = 'outpatient' -- or e.emer_adm_date is not null) -- filter to all current or previous emergency cases that were admitted
	and pls.name /*PatientLivingStatus*/ = 'Alive'
	AND cd.DEPARTMENT_ID IN (43004001002,43005005003) --HPI CHN EMERGENCY, HPI CHS EMERGENCY
	and e.adt_serv_area_id = 430
	--and p.pat_id not in (select * from cteConfidentialPatients)
	

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


/*Clean up tables after use*/
DROP TABLE ##TempED

END
end
GO
