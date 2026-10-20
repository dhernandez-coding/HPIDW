/*
-- =============================================
-- Author:		Zeke Herrera
-- Create date: 09/22/2023
-- Description:	compiles data for press ganey export
-- Change Control
12/14/2023: Zeke Herrera: Added logic to strip commas out of the address line
12/14/2023: Zeke Herrera: Adjusting stored procedure to be sent out daily
1/18/2024: Zeke Herrera: Renamed OriginPoint (AdmissionSource), DischargeDisposition (DischargeStatus) to account for missing values
1/18/2024: Zeke Herrera: Limited CPT Codes: 10004 - 69990, G0104, G0105, G0121, G0260 as per Press Ganey Technical manual
1/18/2024: Zeke Herrera: Adjusted logic to filter on Coding_Datetime and not Completion_dt_tm
1/18/2024: Zeke Herrera: When patient is observation and DRG IS NULL then hardcode 999 into Final statement 
1/23/2024: Eric Silvestri: Included Department IDs 43004001001, 43005005001 for Med/Surg
1/23/2024: Eric Silvestri: Removed filter to exclude null account balances or $0 balances
1/23/2024: Eric Silvestri: Updated CTEConfidentialPatients to include 430 Service area only
12/30/2025: Chris Cross: Updated Admission Source from zcas.ADMIT_SOURCE_C to zcas.ABBR
10/16/2026: Eric Silvestri: Converted linked server queries to OPENQUERY
-- =============================================
*/

CREATE PROCEDURE [rpt].[spPG_HPI_CH_OAS_Daily] @STARTDATE date, @ENDDATE date
AS
BEGIN
SET NOCOUNT ON;

--Criteria:
---		   Event Date = t-7 to t-1
---		   Service Area = 430
---		   Location = COMMUNITY HOSPITAL NORTH, COMMUNITY HOSPITAL SOUTH
---		   Event Types = Discharges
---		   Unit = HPI CHN MAIN OR, HPI CHS MAIN OR, HPI CHN ENDOSCOPY, HPI CHS ENDOSCOPY, HPI CHN PAIN, HPI CHS PAIN,
---		          HPI CHS OPHTHALMOLOGIC, HPI CHS MED/SURG, HPI CHN MED/SURG
---		   Exclude: Surgical cases where the procedure was not performed 
---		   Patient Classes: Outpatient Extended Recovery, Surgery Outpatient - Extended Recovery, Outpatient Surgery, Observation

--DECLARE @STARTDATE AS DATE = '2026-10-01'
--DECLARE @ENDDATE AS DATE = '2026-10-07'
DECLARE @sql      varchar(8000)
      , @path     varchar(100)
      , @filename varchar(100)
	  , @OQ       nvarchar(max)  /*holds the OPENQUERY statements that need the date parameters*/

DECLARE @prevAdvancedOptions int
DECLARE @prevXpCmdshell int

SET @path = 'C:\Users\Public\PressGaney\PressGaney_Output\'
SET @filename
     = 'HPI_CH_OAS_Daily_' + CONVERT(NVARCHAR(10), @STARTDATE, 112) + '_to_' + CONVERT(NVARCHAR(10), @ENDDATE, 112)


/*Clear out Temp Tables used in Query*/
IF OBJECT_ID(N'tempdb..#TempAccounts1') IS NOT NULL DROP TABLE #TempAccounts1
IF OBJECT_ID(N'tempdb..#TempAccounts2') IS NOT NULL DROP TABLE #TempAccounts2
IF OBJECT_ID(N'tempdb..#TempAccounts3') IS NOT NULL DROP TABLE #TempAccounts3
IF OBJECT_ID(N'tempdb..#TempPivot') IS NOT NULL DROP TABLE #TempPivot
IF OBJECT_ID(N'tempdb..#cteProviders') IS NOT NULL DROP TABLE #cteProviders
IF OBJECT_ID(N'tempdb..#TempFinal') IS NOT NULL DROP TABLE #TempFinal
IF OBJECT_ID(N'tempdb..##TempCHOAS') IS NOT NULL DROP TABLE ##TempCHOAS
IF OBJECT_ID(N'tempdb..#TempRef_Bill_Code') IS NOT NULL DROP TABLE #TempRef_Bill_Code
IF OBJECT_ID(N'tempdb..#TempRef_Bill_Code2') IS NOT NULL DROP TABLE #TempRef_Bill_Code2



/*=====================================================================
  #TempAccounts1
  =====================================================================*/
CREATE TABLE #TempAccounts1 (
	 HSP_ACCOUNT_ID      numeric(18,0)
	,PRIM_ENC_CSN_ID     numeric(18,0)
	,EXP_ADMISSION_TIME  datetime
	,HOSP_ADMSN_TIME     datetime
	,HOSP_DISCH_TIME     datetime
	,EFFECTIVE_DATE_DT   datetime
	,ADT_PATIENT_STAT_C  varchar(66)
	,APPT_STATUS_C       varchar(66)
	,DEPARTMENT_ID       numeric(18,0)
	,Survey_Opt_Out_YN   varchar(1)
	,DISCH_LOC_ID        numeric(18,0)
	,DEPARTMENT_NAME     varchar(254)
	,TOT_ACCT_BAL        numeric(18,2)
);

SET @OQ = N'
INSERT INTO #TempAccounts1
SELECT * FROM OPENQUERY([CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM], ''
	select
	a.HSP_ACCOUNT_ID
	,a.PRIM_ENC_CSN_ID
	,eh.EXP_ADMISSION_TIME
	,eh.HOSP_ADMSN_TIME
	,eh.HOSP_DISCH_TIME
	,e.EFFECTIVE_DATE_DT
	,eh.ADT_PATIENT_STAT_C
	,e.APPT_STATUS_C
	,eh.department_id
	,ISNULL(e2.survey_opt_out_yn,''''N'''') AS Survey_Opt_Out_YN
	,a.DISCH_LOC_ID
	,cd.department_name
	,a.TOT_ACCT_BAL
	from CLARITY.ORGFILTER.HSP_ACCOUNT a
		INNER JOIN CLARITY.ORGFILTER.PAT_ENC_HSP eh ON eh.PAT_ENC_CSN_ID = a.PRIM_ENC_CSN_ID
		LEFT JOIN CLARITY.ORGFILTER.PAT_ENC e ON e.PAT_ENC_CSN_ID = eh.PAT_ENC_CSN_ID
		LEFT JOIN CLARITY.ORGFILTER.pat_enc_hsp_2 e2 on e.pat_enc_csn_id = e2.pat_enc_csn_id
		LEFT JOIN CLARITY.ORGFILTER.clarity_dep cd ON eh.department_id = cd.department_id
	where 1=1
		and a.SERV_AREA_ID in (430)
		and eh.adt_pat_class_c IN (164, 155, 106, 104) /*Surgery Outpatient - Extended Recovery, Outpatient Extended Recovery, Outpatient Surgery, Observation*/
		and CONVERT(DATE, a.CODING_DATETIME) between ''''' + CONVERT(char(8), @STARTDATE, 112) + ''''' and ''''' + CONVERT(char(8), @ENDDATE, 112) + '''''
		AND a.CODING_STATUS_C IN (4)
'')';
--PRINT @OQ
EXEC (@OQ);



/*=====================================================================
  #TempAccounts2 - CPT codes per account
  (original joined to #TempAccounts1 locally; same #TempAccounts1 filters applied remotely here)
  =====================================================================*/
CREATE TABLE #TempAccounts2 (
	 hsp_account_id  numeric(18,0)
	,CPT_CODE        varchar(254)
	,ROW_NUM         bigint
);

SET @OQ = N'
INSERT INTO #TempAccounts2
SELECT * FROM OPENQUERY([CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM], ''
WITH CTE AS (
	SELECT DISTINCT
	px.HSP_ACCOUNT_ID
	,px.REF_BILL_CODE as CPT_CODE
	,ROW_NUMBER() OVER (PARTITION BY px.HSP_ACCOUNT_ID ORDER BY ISNULL(px.CODING_INFO_CPT_LINE,999), px.LINE) AS ROW_NUM
	FROM CLARITY.ORGFILTER.V_CODING_ALL_DX_PX_LIST px 
		INNER JOIN CLARITY.ORGFILTER.HSP_ACCOUNT a ON px.HSP_ACCOUNT_ID = a.HSP_ACCOUNT_ID
		INNER JOIN CLARITY.ORGFILTER.PAT_ENC_HSP eh ON eh.PAT_ENC_CSN_ID = a.PRIM_ENC_CSN_ID
	WHERE 1=1 
		AND px.SOURCE_KEY IN (13 /*Inpatient CPT*/
							 ,21 /*Charge CPT*/
							 ,22 /*Coding CPT*/
							 ,23 /*Combined CPT - Charged and Coded*/
							 )
		/*same filters as #TempAccounts1*/
		and a.SERV_AREA_ID in (430)
		and eh.adt_pat_class_c IN (164, 155, 106, 104) /*Surgery Outpatient - Extended Recovery, Outpatient Extended Recovery, Outpatient Surgery, Observation*/
		and CONVERT(DATE, a.CODING_DATETIME) between ''''' + CONVERT(char(8), @STARTDATE, 112) + ''''' and ''''' + CONVERT(char(8), @ENDDATE, 112) + '''''
		AND a.CODING_STATUS_C IN (4)
)
SELECT
    C.hsp_account_id,
    C.CPT_CODE,
    ROW_NUMBER() OVER (PARTITION BY C.hsp_account_id ORDER BY C.CPT_CODE) AS ROW_NUM
FROM CTE C
'')';
--PRINT @OQ
EXEC (@OQ);



/*=====================================================================
  #TempRef_Bill_Code (no date parameters - static OPENQUERY)
  =====================================================================*/
SELECT ref_bill_code 
INTO #TempRef_Bill_Code 
FROM OPENQUERY([CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM], '
	SELECT DISTINCT ref_bill_code 
	FROM CLARITY.ORGFILTER.V_CODING_ALL_DX_PX_LIST
	WHERE ISNUMERIC(ref_bill_code) = 1
')


/*Local - unchanged*/
SELECT * 
INTO #TempRef_Bill_Code2
FROM #TempRef_Bill_Code
WHERE ref_bill_code >= 10004 AND ref_bill_code <= 69990


INSERT INTO #TempRef_Bill_Code2 (ref_bill_code)
VALUES('G0104'), ('G0105'), ('G0121'), ('G0260')


SELECT TA.* 
INTO #TempAccounts3
FROM #TempAccounts2 TA
LEFT JOIN #TempRef_Bill_Code2 TR
ON TA.CPT_CODE = TR.ref_bill_code
where TR.ref_bill_code IS NOT NULL 


/*Create pivot for single record - unchanged*/
CREATE TABLE #TempPivot (
    hsp_account_id INT,
    code1 VARCHAR(50), 
    code2 VARCHAR(50), 
    code3 VARCHAR(50),
	code4 VARCHAR(50),
	code5 VARCHAR(50),
	code6 VARCHAR(50),
);

INSERT INTO #TempPivot(hsp_account_id, code1, code2, code3, code4, code5, code6)
SELECT hsp_account_id 
,ISNULL([1], '') AS code1
,ISNULL([2], '') AS code2
,ISNULL([3], '') AS code3
,ISNULL([4], '') AS code4
,ISNULL([5], '') AS code5
,ISNULL([6], '') AS code6
FROM (
    SELECT hsp_account_id, CPT_CODE,
           ROW_NUM
    FROM #TempAccounts3
) AS src
PIVOT (
    MAX(CPT_CODE) FOR ROW_NUM IN ([1], [2], [3], [4], [5], [6])
) AS pvt;



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
	,bed_id                varchar(50)
	,pat_class_name        varchar(254)
	,pat_service_name      varchar(254)
	,adm_date_time         datetime
	,disch_date_time       datetime
	,patient_status_c      varchar(66)
	,adt_pat_class_c       varchar(66)
	,drg_number            varchar(50)
	,icu_department_id     numeric(18,0)
	,admission_prov_id     varchar(18)
	,attending_prov_id     varchar(18)
	,email_address         varchar(254)
	,no_email_reason       varchar(254)
	,pat_living_stat_name  varchar(254)
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
	,eh.bed_id
	,zcpc.name AS pat_class_name
	,zcps.name AS pat_service_name
	,a.adm_date_time
	,a.disch_date_time
	,a.PATIENT_STATUS_C
	,eh.adt_pat_class_c
	,drg.drg_number
	,icu.department_id AS icu_department_id
	,eh.admission_prov_id
	,a.attending_prov_id
	,p.email_address
	,zcer.name AS no_email_reason
	,pls.name AS pat_living_stat_name
	,a.pat_home_phone
	FROM CLARITY.ORGFILTER.HSP_ACCOUNT a
		INNER JOIN CLARITY.ORGFILTER.PAT_ENC_HSP eh ON eh.PAT_ENC_CSN_ID = a.PRIM_ENC_CSN_ID
		LEFT JOIN CLARITY.ORGFILTER.PATIENT P ON eh.PAT_ID = p.PAT_ID
		LEFT JOIN CLARITY.ORGFILTER.patient_4 p4 on p.pat_id = p4.pat_id
		LEFT JOIN CLARITY.ORGFILTER.zc_pat_living_stat pls on p4.pat_living_stat_c = pls.pat_living_stat_c
		LEFT JOIN CLARITY.ORGFILTER.CLARITY_DRG drg ON a.FINAL_DRG_ID = drg.DRG_ID
		LEFT JOIN CLARITY.ORGFILTER.f_pat_icu_location icu on eh.pat_enc_csn_id = icu.pat_enc_csn_id
		LEFT JOIN CLARITY.ORGFILTER.ZC_PAT_CLASS zcpc on eh.adt_pat_class_c = zcpc.adt_pat_class_c
		LEFT JOIN CLARITY.ORGFILTER.zc_pat_service zcps on eh.hosp_serv_c = zcps.hosp_serv_c
		LEFT JOIN CLARITY.ORGFILTER.zc_no_email_reason zcer on p4.no_email_reason_c = zcer.no_email_reason_c
		LEFT JOIN CLARITY.ORGFILTER.clarity_dep cd ON eh.department_id = cd.department_id
		LEFT JOIN CLARITY.ORGFILTER.zc_tax_state zcts on p.state_c = zcts.tax_state_c 
		LEFT JOIN CLARITY.ORGFILTER.zc_sex zcs on p.sex_c = zcs.rcpt_mem_sex_c
		LEFT JOIN CLARITY.ORGFILTER.ZC_ADM_SOURCE zcas on eh.admit_source_c = zcas.admit_source_c
	where 1=1
		/*same filters as #TempAccounts1*/
		and a.SERV_AREA_ID in (430)
		and eh.adt_pat_class_c IN (164, 155, 106, 104) /*Surgery Outpatient - Extended Recovery, Outpatient Extended Recovery, Outpatient Surgery, Observation*/
		and CONVERT(DATE, a.CODING_DATETIME) between ''''' + CONVERT(char(8), @STARTDATE, 112) + ''''' and ''''' + CONVERT(char(8), @ENDDATE, 112) + '''''
		AND a.CODING_STATUS_C IN (4)
		/*final select filters*/
		AND eh.ADT_PATIENT_STAT_C in (3) /*Discharged*/
		AND eh.DEPARTMENT_ID IN (43004001014, 43005005013, 43004001016, 43005005015, 43004001017, 43005005016, 43005005018, 43004001001, 43005005001) /*HPI CHN MAIN OR, HPI CHS MAIN OR, HPI CHN ENDOSCOPY, HPI CHS ENDOSCOPY, HPI CHN PAIN ,HPI CHS PAIN, HPI CHS OPHTHALMOLOGIC, HPI CHS MED/SURG HPI CHN MED/SURG*/
'')';
--PRINT @OQ
EXEC (@OQ);



/*=====================================================================
  Final select - local
  =====================================================================*/
select 
	'AS0101' HospitalUnitSurveyDesignator -- AS0101 reporttype/file hardcode
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
	,f.admit_source_abbr as AdmissionSource
	,'' HospUnitLoc			
	,f.department_name PGHospUnit
	,f.bed_id HospBed
	,f.pat_class_name AS PatientClass
	,f.pat_service_name AS PService
	,REPLACE(CONVERT(VARCHAR(10), f.adm_date_time, 101), '/', '') AdmitDate	
	,REPLACE(CONVERT(VARCHAR(10), f.disch_date_time, 101), '/', '') DischargeDate
	,ISNULL(f.PATIENT_STATUS_C, '') DischargeStatus
	, CASE WHEN f.adt_pat_class_c IN (104) THEN ISNULL(RIGHT(f.drg_number, 3), 999) --Added ISNULL 999 for Observation patients
		ELSE ISNULL(RIGHT(f.drg_number, 3), '') END AS DRG
	,code1 as CPTCode1
	,code2 as CPTCode2
	,code3 as CPTCode3
	,code4 as CPTCode4
	,code5 as CPTCode5
	,code6 as CPTCode6
	,case when f.icu_department_id is not null then 1 else 0 end as ICUStayIndicator 
	,f.admission_prov_id AdmittingProviderID
	,admp.ProviderSpeciality AdmittingProviderSpeciality
	,admp.prov_name AdmittingProviderName
	,ISNULL(f.attending_prov_id, '') AttendingProvID
	,ISNULL(attp.ProviderSpeciality, '') AttendingProviderSpeciality
	,ISNULL(attp.prov_name, '') AttendingProviderName
	,ISNULL(f.email_address, '') PatientEmail
	,ISNULL(case when f.email_address is null then f.no_email_reason end, '') PatientReasonforNoEmail
	,CASE WHEN f.pat_living_stat_name = 'Alive' THEN 'N' 	
			WHEN f.pat_living_stat_name = 'Deceased' THEN 'Y'  END AS PatientLivingStatus
,ISNULL(REPLACE(f.pat_home_phone, '-', ''), '') PatientCellPhone
,'' as FreeSpace
,'$' EORIndicator
INTO ##TempCHOAS
FROM #TempAccounts1 SUB
	INNER JOIN #TempPivot TP ON sub.hsp_account_id = TP.hsp_account_id
	INNER JOIN #TempFinal f ON f.hsp_account_id = sub.hsp_account_id
	LEFT JOIN #cteProviders admp on f.admission_prov_id = admp.prov_id
	LEFT JOIN #cteProviders attp on f.attending_prov_id = attp.prov_id
	LEFT JOIN [map].[SurveyLanguageCodes] S ON f.language_c = s.language_c
WHERE 1=1
	AND sub.ADT_PATIENT_STAT_C in (3) /*Discharged*/
	AND LEFT(sub.hsp_account_id,1) = '6' /*Only want Hospital*/
	AND sub.DEPARTMENT_ID IN (43004001014, 43005005013, 43004001016, 43005005015, 43004001017, 43005005016, 43005005018, 43004001001, 43005005001) /*HPI CHN MAIN OR, HPI CHS MAIN OR, HPI CHN ENDOSCOPY, HPI CHS ENDOSCOPY, HPI CHN PAIN ,HPI CHS PAIN, HPI CHS OPHTHALMOLOGIC, HPI CHS MED/SURG HPI CHN MED/SURG*/
	


/*=====================================================================
  Export - unchanged
  =====================================================================*/
DECLARE @query varchar(8000) = 'SET NOCOUNT ON;' + 
'SELECT CAST(HospitalUnitSurveyDesignator as varchar(8)), '','',' + 
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
'CAST(AdmissionSource as varchar(20)), '','',' +
'CAST(HospUnitLoc as varchar(20)), '','',' +
'CAST(PGHospUnit as varchar(50)), '','',' +
'CAST(HospBed as varchar(50)), '','',' +
'CAST(PatientClass as varchar(50)), '','',' +
'CAST(PService as varchar(50)), '','',' +
'CAST(AdmitDate as varchar(10)), '','',' +
'CAST(DischargeDate as varchar(10)), '','',' +
'CAST(DischargeStatus as varchar(2)), '','',' +
'CAST(DRG as varchar(3)), '','',' +
'CAST(CPTCode1 as varchar(10)), '','',' +
'CAST(CPTCode2 as varchar(10)), '','',' +
'CAST(CPTCode3 as varchar(10)), '','',' +
'CAST(CPTCode4 as varchar(10)), '','',' +
'CAST(CPTCode5 as varchar(10)), '','',' +
'CAST(CPTCode6 as varchar(10)), '','',' +
'CAST(ICUStayIndicator as varchar(1)), '','',' +
'CAST(AdmittingProviderID as varchar(50)), '','',' +
'CAST(AdmittingProviderSpeciality as varchar(50)), '','',' +
'CAST(AdmittingProviderName as varchar(50)), '','',' +
'CAST(AttendingProvID as varchar(50)), '','',' +
'CAST(AttendingProviderSpeciality as varchar(50)), '','',' +
'CAST(AttendingProviderName as varchar(50)), '','',' +
'CAST(PatientEmail as varchar(60)), '','',' +
'CAST(PatientReasonforNoEmail as varchar(30)), '','',' +
'CAST(PatientLivingStatus as varchar(2)), '','',' +
'CAST(PatientCellPhone as varchar(12)), '','',' +
'CAST(FreeSpace as varchar(1)), '','',' +
'CAST(EORIndicator as varchar(1)) FROM ##TempCHOAS'



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

/*Clean up tables after use*/
DROP TABLE #TempAccounts1
DROP TABLE #TempAccounts2
DROP TABLE #TempAccounts3
DROP TABLE #TempPivot
DROP TABLE #cteProviders
DROP TABLE #TempFinal
DROP TABLE ##TempCHOAS
DROP TABLE #TempRef_Bill_Code
DROP TABLE #TempRef_Bill_Code2
	

end




/*====================OLD EXTRACT REPLACED 10-19-2026====================


/*
-- =============================================
-- Author:		Zeke Herrera
-- Create date: 09/22/2023
-- Description:	compiles data for press ganey export
-- Change Control
12/14/2023: Zeke Herrera: Added logic to strip commas out of the address line
12/14/2023: Zeke Herrera: Adjusting stored procedure to be sent out daily
1/18/2024: Zeke Herrera: Renamed OriginPoint (AdmissionSource), DischargeDisposition (DischargeStatus) to account for missing values
1/18/2024: Zeke Herrera: Limited CPT Codes: 10004 - 69990, G0104, G0105, G0121, G0260 as per Press Ganey Technical manual
1/18/2024: Zeke Herrera: Adjusted logic to filter on Coding_Datetime and not Completion_dt_tm
1/18/2024: Zeke Herrera: When patient is observation and DRG IS NULL then hardcode 999 into Final statement 
1/23/2024: Eric Silvestri: Included Department IDs 43004001001, 43005005001 for Med/Surg
1/23/2024: Eric Silvestri: Removed filter to exclude null account balances or $0 balances
1/23/2024: Eric Silvestri: Updated CTEConfidentialPatients to include 430 Service area only
12/30/2025: Chris Cross: Updated Admission Source from zcas.ADMIT_SOURCE_C to zcas.ABBR
-- =============================================
*/

ALTER PROCEDURE [rpt].[spPG_HPI_CH_OAS_Daily] @STARTDATE date, @ENDDATE date
AS


BEGIN
SET NOCOUNT ON;

--Criteria:
---        Event Date = t-7 to t-1
---        Service Area = 430
---        Location = COMMUNITY HOSPITAL NORTH, COMMUNITY HOSPITAL SOUTH
---        Event Types = Discharges
---        Unit = HPI CHN MAIN OR, HPI CHS MAIN OR, HPI CHN ENDOSCOPY, HPI CHS ENDOSCOPY, HPI CHN PAIN, HPI CHS PAIN
---        Exclude: Confidential Patients
---        Exclude: Surgical cases where the procedure was not performed 
---        Patient Classes: Outpatient Extended Recovery, Surgery Outpatient - Extended Recovery, Outpatient Surgery, Observation
---		   Account Balance <> 0

--DECLARE @STARTDATE AS DATE 
--DECLARE @ENDDATE AS DATE

DECLARE @sql      varchar(8000)
      , @path     varchar(100)
      , @filename varchar(100)

DECLARE @prevAdvancedOptions int
DECLARE @prevXpCmdshell int

 
--SET @STARTDATE = '2023-09-11'
--SET @ENDDATE = '2023-09-15'
SET @path = 'C:\Users\Public\PressGaney\PressGaney_Output\'
SET @filename
     = 'HPI_CH_OAS_Daily_' + CONVERT(NVARCHAR(10), @STARTDATE, 112) + '_to_' + CONVERT(NVARCHAR(10), @ENDDATE, 112)


/*Clear out Temp Tables used in Query*/
IF OBJECT_ID(N'tempdb..#TempAccounts1') IS NOT NULL
BEGIN
DROP TABLE #TempAccounts1
END

IF OBJECT_ID(N'tempdb..#TempAccounts2') IS NOT NULL
BEGIN
DROP TABLE #TempAccounts2
END

IF OBJECT_ID(N'tempdb..#TempAccounts3') IS NOT NULL
BEGIN
DROP TABLE #TempAccounts3
END

IF OBJECT_ID(N'tempdb..#TempPivot') IS NOT NULL
BEGIN
DROP TABLE #TempPivot
END

IF OBJECT_ID(N'tempdb..#cteProviders') IS NOT NULL
BEGIN
DROP TABLE #cteProviders
END

--IF OBJECT_ID(N'tempdb..#cteConfidentialPatients') IS NOT NULL
--BEGIN
--DROP TABLE #cteConfidentialPatients
--END

IF OBJECT_ID(N'tempdb..##TempCHOAS') IS NOT NULL
BEGIN
DROP TABLE ##TempCHOAS
END

IF OBJECT_ID(N'tempdb..#TempRef_Bill_Code') IS NOT NULL
BEGIN
DROP TABLE #TempRef_Bill_Code
END

IF OBJECT_ID(N'tempdb..#TempRef_Bill_Code2') IS NOT NULL
BEGIN
DROP TABLE #TempRef_Bill_Code2
END

/*INSERT Filtered Records into #TempAccounts1*/
	select
	a.HSP_ACCOUNT_ID
	,a.PRIM_ENC_CSN_ID
	,eh.EXP_ADMISSION_TIME
	,eh.HOSP_ADMSN_TIME
	,eh.HOSP_DISCH_TIME
	,e.EFFECTIVE_DATE_DT
	,eh.ADT_PATIENT_STAT_C
	,e.APPT_STATUS_C
	,eh.department_id
	,ISNULL(e2.survey_opt_out_yn,'N') AS Survey_Opt_Out_YN
	,a.DISCH_LOC_ID
	,cd.department_name
	,a.TOT_ACCT_BAL
	INTO #TempAccounts1
	from [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].HSP_ACCOUNT a
		INNER JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].PAT_ENC_HSP eh ON eh.PAT_ENC_CSN_ID = a.PRIM_ENC_CSN_ID
		LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].PAT_ENC e ON e.PAT_ENC_CSN_ID = eh.PAT_ENC_CSN_ID
		LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].pat_enc_hsp_2 e2 on e.pat_enc_csn_id = e2.pat_enc_csn_id
		LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].clarity_dep cd ON eh.department_id = cd.department_id
	where 1=1
		and a.SERV_AREA_ID in (430)
		and eh.adt_pat_class_c IN (164, 155, 106, 104) /*Surgery Outpatient - Extended Recovery, Outpatient Extended Recovery, Outpatient Surgery, Observation*/
		and CONVERT(DATE,a.CODING_DATETIME) between @STARTDATE and @ENDDATE
		AND a.CODING_STATUS_C IN (4)
		--AND CONVERT(DATE,a.CODING_DATETIME) = @ENDDATE


/*Getting only the hsp_account_id, with their respective CPT_Codes FROM HSP_TRANSACTIONS*/
;WITH CTE AS (
	SELECT DISTINCT
	px.HSP_ACCOUNT_ID
	,px.REF_BILL_CODE as CPT_CODE
	,ROW_NUMBER() OVER (PARTITION BY px.HSP_ACCOUNT_ID ORDER BY ISNULL(px.CODING_INFO_CPT_LINE,999), px.LINE) AS ROW_NUM
	FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].V_CODING_ALL_DX_PX_LIST px 
		INNER JOIN #TempAccounts1 A ON px.HSP_ACCOUNT_ID = A.hsp_account_id
	WHERE 1=1 
		AND px.SOURCE_KEY IN (--11 /*ICD Procedures*/
							 13 /*Inpatient CPT*/
							 ,21 /*Charge CPT - Excluding from VisitProcedures as these are supplies, implants, and equipment; Not performed procedures*/
							 ,22 /*Coding CPT*/
							 ,23 /*Combined CPT - Charged and Coded*/
							 ) /*CPT and ICD Procedures*/
		--AND px.HSP_ACCOUNT_ID = 606367348	
)
SELECT
    C.hsp_account_id,
    C.CPT_CODE,
    ROW_NUMBER() OVER (PARTITION BY C.hsp_account_id ORDER BY C.CPT_CODE) AS ROW_NUM
INTO #TempAccounts2
FROM CTE C;


SELECT DISTINCT ref_bill_code 
INTO #TempRef_Bill_Code 
FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[V_CODING_ALL_DX_PX_LIST] 
WHERE ISNUMERIC(ref_bill_code) = 1


SELECT * 
INTO #TempRef_Bill_Code2
FROM #TempRef_Bill_Code
WHERE ref_bill_code >= 10004 AND ref_bill_code <= 69990


INSERT INTO #TempRef_Bill_Code2 (ref_bill_code)
VALUES('G0104'), ('G0105'), ('G0121'), ('G0260')


SELECT TA.* 
INTO #TempAccounts3
FROM #TempAccounts2 TA
LEFT JOIN #TempRef_Bill_Code2 TR
ON TA.CPT_CODE = TR.ref_bill_code
where TR.ref_bill_code IS NOT NULL 


/*Create pivot for single record*/
CREATE TABLE #TempPivot (
    hsp_account_id INT,
    code1 VARCHAR(50), 
    code2 VARCHAR(50), 
    code3 VARCHAR(50),
	code4 VARCHAR(50),
	code5 VARCHAR(50),
	code6 VARCHAR(50),
);

INSERT INTO #TempPivot(hsp_account_id, code1, code2, code3, code4, code5, code6)
SELECT hsp_account_id 
,ISNULL([1], '') AS code1
,ISNULL([2], '') AS code2
,ISNULL([3], '') AS code3
,ISNULL([4], '') AS code4
,ISNULL([5], '') AS code5
,ISNULL([6], '') AS code6
FROM (
    SELECT hsp_account_id, CPT_CODE,
           ROW_NUM
    FROM #TempAccounts3
) AS src
PIVOT (
    MAX(CPT_CODE) FOR ROW_NUM IN ([1], [2], [3], [4], [5], [6])
) AS pvt;


/*INSERT Filtered Records into #cteProviders*/
	select
		cs.prov_id
		,REPLACE(COALESCE(cs.EXTERNAL_NAME,cs.prov_name),',','') AS prov_name
		,zcsp.name ProviderSpeciality
	into #cteProviders
	from [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].clarity_ser cs
			left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[CLARITY_SER_SPEC] ss on cs.PROV_ID = ss.PROV_ID and ss.line = 1
				left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[ZC_SPECIALTY] zcsp on ss.SPECIALTY_C = zcsp.SPECIALTY_C

/*INSERT Filtered Records into #cteConfidentialPatients*/
	/*select
		pat_id 
	into #cteConfidentialPatients
	from [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].patient_type pt
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].zc_patient_type zcpt on pt.patient_type_c = zcpt.patient_type_c
	where zcpt.name not in ('VIP', 'Employee Confidential', 'Confidential')
	group by pat_id
*/
	--select
	--	pt.pat_id 
	--into #cteConfidentialPatients
	--from [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].patient_type pt
	--    left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].PAT_ENC_HSP eh on pt.pat_id = eh.pat_id
	--	left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].zc_patient_type zcpt on pt.patient_type_c = zcpt.patient_type_c
	--where zcpt.name not in ('VIP', 'Employee Confidential', 'Confidential') AND eh.ADT_SERV_AREA_ID = 430
	--group by pt.pat_id
	
	
select 
	'AS0101' HospitalUnitSurveyDesignator -- AS0101 reporttype/file hardcode
		,case
		when eh.hospital_area_id like '43004%' or eh.hospital_area_id like '43005%' then 6987
		when eh.hospital_area_id like '43006%' then 7979 END ParentLocationID --6987 = community, 7979 = NW hospital
	,p.pat_last_name LastName
	,ISNULL(LEFT(p.pat_middle_name, 1), '') MiddleInitial
	,p.pat_first_name FirstName					
	,Replace(p.add_line_1, ',', '') PatientStreetAddressLine1		
	,Replace(p.add_line_2, ',', '') PatientStreetAddressLine2			
	,p.city PatientCity	
	,zcts.abbr PatientState
	,p.zip PatientZIP
	,a.HSP_ACCOUNT_ID HospitalAccountID
	,a.PRIM_ENC_CSN_ID CSN
	,p.pat_mrn_id MRN
	,REPLACE(CONVERT(VARCHAR(10), p.birth_date, 101), '/', '') PatientDOB
	,dbo.GetAge(p.birth_date, getdate()) as PatientAge
	,zcs.abbr sex_abbr
	,s.code lang
	,zcas.ABBR as AdmissionSource --zcas.admit_source_c AdmissionSource --OriginPoint
	,'' HospUnitLoc			
	,cd.department_name	PGHospUnit
	,eh.bed_id HospBed					--??
	,zcpc.name AS PatientClass
	,zcps.name AS PService
	,REPLACE(CONVERT(VARCHAR(10), a.adm_date_time, 101), '/', '') AdmitDate	
	,REPLACE(CONVERT(VARCHAR(10), a.disch_date_time, 101), '/', '') DischargeDate
--	,ISNULL(zcdd.name, '') DischargeDispName
	,ISNULL(a.PATIENT_STATUS_C, '') DischargeStatus
--	,ISNULL(eh.ADT_PATIENT_STAT_C, '') DischargeStatus
	, CASE WHEN eh.adt_pat_class_c IN (104) THEN ISNULL(RIGHT(drg.drg_number, 3), 999) --Added ISNULL 999 for Observation patients
		ELSE ISNULL(RIGHT(drg.drg_number, 3), '') END AS DRG
	,code1 as CPTCode1
	,code2 as CPTCode2
	,code3 as CPTCode3
	,code4 as CPTCode4
	,code5 as CPTCode5
	,code6 as CPTCode6
	,case when icu.department_id is not null then 1 else 0 end as ICUStayIndicator 
	,eh.admission_prov_id AdmittingProviderID
	,admp.ProviderSpeciality AdmittingProviderSpeciality
	,admp.prov_name AdmittingProviderName
	,ISNULL(a.attending_prov_id, '') AttendingProvID
	,ISNULL(attp.ProviderSpeciality, '') AttendingProviderSpeciality
	,ISNULL(attp.prov_name, '') AttendingProviderName
	,ISNULL(p.email_address, '') PatientEmail
	,ISNULL(case when p.email_address is null then zcer.name end, '') PatientReasonforNoEmail
	,CASE WHEN pls.name = 'Alive' THEN 'N' 	
			WHEN pls.name = 'Deceased' THEN 'Y'  END AS PatientLivingStatus
,ISNULL(REPLACE(a.pat_home_phone, '-', ''), '') PatientCellPhone
,'' as FreeSpace
,'$' EORIndicator
INTO ##TempCHOAS
FROM #TempAccounts1 SUB
	INNER JOIN #TempPivot TP ON sub.hsp_account_id = TP.hsp_account_id
    INNER JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].HSP_ACCOUNT a ON sub.hsp_account_id = a.hsp_account_id
	INNER JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].PAT_ENC_HSP eh ON eh.PAT_ENC_CSN_ID = a.PRIM_ENC_CSN_ID
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].PAT_ENC e ON e.PAT_ENC_CSN_ID = eh.PAT_ENC_CSN_ID
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].pat_enc_hsp_2 e2 on e.pat_enc_csn_id = e2.pat_enc_csn_id
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].hsp_account_3 a3 on a3.hsp_account_id = a.hsp_account_id
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].zc_disch_disp zcdd on a3.pat_sts_ept_c = zcdd.disch_disp_c
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].PATIENT P ON eh.PAT_ID = p.PAT_ID
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].patient_4 p4 on p.pat_id = p4.pat_id
	left join #cteProviders admp on eh.admission_prov_id = admp.prov_id
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].zc_pat_living_stat pls on p4.pat_living_stat_c = pls.pat_living_stat_c
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].CLARITY_DRG drg ON a.FINAL_DRG_ID = drg.DRG_ID
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].f_pat_icu_location icu on eh.pat_enc_csn_id = icu.pat_enc_csn_id
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_PAT_CLASS zcpc on eh.adt_pat_class_c = zcpc.adt_pat_class_c
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].zc_pat_service zcps on eh.hosp_serv_c = zcps.hosp_serv_c
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].zc_no_email_reason zcer on p4.no_email_reason_c = zcer.no_email_reason_c
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].clarity_dep cd ON eh.department_id = cd.department_id
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].zc_tax_state zcts on p.state_c = zcts.tax_state_c 
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].zc_sex zcs on p.sex_c = zcs.rcpt_mem_sex_c
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_ADM_SOURCE zcas on eh.admit_source_c = zcas.admit_source_c
	LEFT JOIN #cteProviders attp on a.attending_prov_id = attp.prov_id
	LEFT JOIN [map].[SurveyLanguageCodes] S ON p.language_c = s.language_c
WHERE 1=1
	AND sub.ADT_PATIENT_STAT_C in (3) /*Discharged*/
	AND LEFT(sub.hsp_account_id,1) = '6' /*Only want Hospital*/
	AND sub.DEPARTMENT_ID IN (43004001014, 43005005013, 43004001016, 43005005015, 43004001017, 43005005016, 43005005018, 43004001001, 43005005001) /*HPI CHN MAIN OR, HPI CHS MAIN OR, HPI CHN ENDOSCOPY, HPI CHS ENDOSCOPY, HPI CHN PAIN ,HPI CHS PAIN, HPI CHS OPHTHALMOLOGIC, HPI CHS MED/SURG HPI CHN MED/SURG*/
	--and (sub.TOT_ACCT_BAL is null or sub.TOT_ACCT_BAL <> 0)
	--AND p.pat_id not in (select * from #cteConfidentialPatients) 
	

DECLARE @query varchar(8000) = 'SET NOCOUNT ON;' + 
'SELECT CAST(HospitalUnitSurveyDesignator as varchar(8)), '','',' + 
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
'CAST(AdmissionSource as varchar(20)), '','',' +
'CAST(HospUnitLoc as varchar(20)), '','',' +
'CAST(PGHospUnit as varchar(50)), '','',' +
'CAST(HospBed as varchar(50)), '','',' +
'CAST(PatientClass as varchar(50)), '','',' +
'CAST(PService as varchar(50)), '','',' +
'CAST(AdmitDate as varchar(10)), '','',' +
'CAST(DischargeDate as varchar(10)), '','',' +
'CAST(DischargeStatus as varchar(2)), '','',' +
'CAST(DRG as varchar(3)), '','',' +
'CAST(CPTCode1 as varchar(10)), '','',' +
'CAST(CPTCode2 as varchar(10)), '','',' +
'CAST(CPTCode3 as varchar(10)), '','',' +
'CAST(CPTCode4 as varchar(10)), '','',' +
'CAST(CPTCode5 as varchar(10)), '','',' +
'CAST(CPTCode6 as varchar(10)), '','',' +
'CAST(ICUStayIndicator as varchar(1)), '','',' +
'CAST(AdmittingProviderID as varchar(50)), '','',' +
'CAST(AdmittingProviderSpeciality as varchar(50)), '','',' +
'CAST(AdmittingProviderName as varchar(50)), '','',' +
'CAST(AttendingProvID as varchar(50)), '','',' +
'CAST(AttendingProviderSpeciality as varchar(50)), '','',' +
'CAST(AttendingProviderName as varchar(50)), '','',' +
'CAST(PatientEmail as varchar(60)), '','',' +
'CAST(PatientReasonforNoEmail as varchar(30)), '','',' +
'CAST(PatientLivingStatus as varchar(2)), '','',' +
'CAST(PatientCellPhone as varchar(12)), '','',' +
'CAST(FreeSpace as varchar(1)), '','',' +
'CAST(EORIndicator as varchar(1)) FROM ##TempCHOAS'



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

/*Clean up tables after use*/
DROP TABLE #TempAccounts1
DROP TABLE #TempAccounts2
DROP TABLE #TempAccounts3
DROP TABLE #TempPivot
--DROP TABLE #cteConfidentialPatients
DROP TABLE #cteProviders
DROP TABLE ##TempCHOAS
DROP TABLE #TempRef_Bill_Code
DROP TABLE #TempRef_Bill_Code2
	

end

*/
GO
