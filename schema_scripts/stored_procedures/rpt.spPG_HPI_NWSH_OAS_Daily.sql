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
1/18/2024: Zeke Herrera: When patient is observation and DRG IS NULL then hardcode 999 into Final statement 
1/23/2024: Eric Silvestri: Included Department IDs 43006001001 for Med/Surg
1/23/2024: Eric Silvestri: Removed filter to exclude null account balances or $0 balances
1/23/2024: Eric Silvestri: Updated CTEConfidentialPatients to include 430 Service area only 
12/30/2025: Chris Cross: Updated Admission Source from zcas.ADMIT_SOURCE_C to zcas.ABBR
-- =============================================
*/


CREATE PROCEDURE [rpt].[spPG_HPI_NWSH_OAS_Daily] @STARTDATE date, @ENDDATE date
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


--SET @STARTDATE = DATEADD(DAY,-7,GETDATE())
--SET @ENDDATE = DATEADD(DAY,-1,GETDATE())
--SET @STARTDATE = '2023-09-11'
--SET @ENDDATE = '2023-09-15'

SET @path = 'C:\Users\Public\PressGaney\PressGaney_Output\'
SET @filename
     = 'HPI_NWSH_OAS_Daily_' + CONVERT(NVARCHAR(10), @STARTDATE, 112) + '_to_' + CONVERT(NVARCHAR(10), @ENDDATE, 112)


/*Clear out Temp Tables used in Query*/
IF OBJECT_ID(N'tempdb..#TempAccounts') IS NOT NULL
BEGIN
DROP TABLE #TempAccounts
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

IF OBJECT_ID(N'tempdb..##TempNWOAS') IS NOT NULL
BEGIN
DROP TABLE ##TempNWOAS
END

IF OBJECT_ID(N'tempdb..#TempRef_Bill_Code') IS NOT NULL
BEGIN
DROP TABLE #TempRef_Bill_Code
END

IF OBJECT_ID(N'tempdb..#TempRef_Bill_Code2') IS NOT NULL
BEGIN
DROP TABLE #TempRef_Bill_Code2
END


/*INSERT Filtered Records into #TempAccounts*/
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
	INTO #TempAccounts
	from [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].HSP_ACCOUNT a
		INNER JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].PAT_ENC_HSP eh ON eh.PAT_ENC_CSN_ID = a.PRIM_ENC_CSN_ID
		LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].PAT_ENC e ON e.PAT_ENC_CSN_ID = eh.PAT_ENC_CSN_ID
		LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].pat_enc_hsp_2 e2 on e.pat_enc_csn_id = e2.pat_enc_csn_id
		LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].clarity_dep cd ON eh.department_id = cd.department_id
	where 1=1
		and a.SERV_AREA_ID in (430)
		and eh.adt_pat_class_c IN (164, 155, 106, 104) /*Surgery Outpatient - Extended Recovery, Outpatient Extended Recovery, Outpatient Surgery, Observation*/
--		and CONVERT(DATE,eh.HOSP_DISCH_TIME) between @STARTDATE and @ENDDATE
		AND CONVERT(DATE, a.CODING_DATETIME) BETWEEN @STARTDATE and @ENDDATE
		AND a.CODING_STATUS_C IN (4)
--		AND CONVERT(DATE,a.CODING_DATETIME) = @ENDDATE
--		AND eh.DEPARTMENT_ID IN (43006001010)



/*Getting only the hsp_account_id, with their respective CPT_Codes FROM HSP_TRANSACTIONS*/
;WITH CTE AS (
	SELECT DISTINCT
	px.HSP_ACCOUNT_ID
	,px.REF_BILL_CODE as CPT_CODE
	,ROW_NUMBER() OVER (PARTITION BY px.HSP_ACCOUNT_ID ORDER BY ISNULL(px.CODING_INFO_CPT_LINE,999), px.LINE) AS ROW_NUM
	FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].V_CODING_ALL_DX_PX_LIST px 
		INNER JOIN #TempAccounts A ON px.HSP_ACCOUNT_ID = A.hsp_account_id
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
/*	select
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
	,eh.bed_id HospBed					
	,zcpc.name AS PatientClass
	,zcps.name AS PService
	,REPLACE(CONVERT(VARCHAR(10), a.adm_date_time, 101), '/', '') AdmitDate	
	,REPLACE(CONVERT(VARCHAR(10), a.disch_date_time, 101), '/', '') DischargeDate
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
			WHEN pls.name = 'Deceased' THEN 'Y' 
			ELSE pls.name END AS PatientLivingStatus
,ISNULL(REPLACE(a.pat_home_phone, '-', ''), '') PatientCellPhone
,'' as FreeSpace
,'$' EORIndicator
INTO ##TempNWOAS
FROM #TempAccounts SUB
	INNER JOIN #TempPivot TP ON sub.hsp_account_id = TP.hsp_account_id
    INNER JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].HSP_ACCOUNT a ON sub.hsp_account_id = a.hsp_account_id
	INNER JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].PAT_ENC_HSP eh ON eh.PAT_ENC_CSN_ID = a.PRIM_ENC_CSN_ID
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].PAT_ENC e ON e.PAT_ENC_CSN_ID = eh.PAT_ENC_CSN_ID
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].pat_enc_hsp_2 e2 on e.pat_enc_csn_id = e2.pat_enc_csn_id
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].hsp_account_3 a3 on a3.hsp_account_id = a.hsp_account_id
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
	AND sub.DEPARTMENT_ID IN (43006001010, 43006001001) /*HPI NWSH MAIN OR, HPI NWSH MED/SURG*/
	--and (sub.TOT_ACCT_BAL is null or sub.TOT_ACCT_BAL <> 0) /*AccountBalance <> 0*/
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
'CAST(EORIndicator as varchar(1)) FROM ##TempNWOAS'



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
END


/*Clean up tables after use*/
DROP TABLE #TempAccounts
DROP TABLE #TempAccounts2
DROP TABLE #TempAccounts3
DROP TABLE #TempPivot
--DROP TABLE #cteConfidentialPatients
DROP TABLE #cteProviders
DROP TABLE ##TempNWOAS
DROP TABLE #TempRef_Bill_Code 
DROP TABLE #TempRef_Bill_Code2
	

end
GO
