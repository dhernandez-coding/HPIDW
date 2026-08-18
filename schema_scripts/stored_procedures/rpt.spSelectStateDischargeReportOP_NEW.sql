/*
================================================================================
 REWRITE NOTES (read before deploying)
================================================================================
 Problem with the original version:
   The @Dt XML block ran FOUR correlated subqueries against the linked server
   (ecode, diagnosis, principal-procedure, charge breakdown) once PER PATIENT
   ACCOUNT, plus the main driver join itself queried HSP_ACCOUNT/PATIENT/etc.
   directly via four-part names. For N accounts that's N+1 round trips to
   CLARITYRDBMS instead of a handful of bulk pulls.

 What changed:
   1. #TEMPChargeFilter - kept, same shape, but fixed the LEFT()/IN() type
      mismatch (varchar vs int) that was likely behind your syntax/conversion
      error, and removed the leftover commented-out INTO line.
   2. #TEMPAccounts - NEW. One bulk pull that replicates the old driving
      join (HSP_ACCOUNT + PATIENT + ZC_STATE + PATIENT_RACE + CLARITY_EPM +
      clarity_epp + clarity_ser_2) AND the old date/location/coding-status/
      self-pay filter logic, all pushed down to the remote server via
      dynamic SQL so only qualifying rows cross the wire.
   3. #TEMPDx, #TEMPEcode, #TEMPTransactions - NEW. Bulk pulls scoped to the
      account IDs found in #TEMPAccounts, replacing the four per-row
      correlated subqueries. #TEMPTransactions replaces BOTH the old
      "procs" and "charge" subqueries since they both hit HSP_TRANSACTIONS -
      pulling once and filtering twice locally instead of hitting the
      linked server twice per account.
   4. Three joins were unused in the original and have been dropped:
      clarity_drg (drg) - referenced only in a commented-out column.
      ZC_MC_ADM_SOURCE (zcadmin) - never referenced anywhere.
      PAT_ENC_HSP (enc) / CLARITY_DEP (dep) - never referenced anywhere.
      If any of these were placeholders for something you're about to add,
      flag it and I'll wire them back in via the same bulk-pull pattern.
   5. Preserved as-is (not "fixed", just carried over, since changing them
      changes output):
        - `order by '@id'` orders by a string literal, not the computed
          @id column - this is a pre-existing no-op, not something this
          rewrite touches.
        - TOP(6) ecode / TOP(17) oth_diag_code have no ORDER BY, so which
          6/17 rows you get is whatever order the engine feels like. Same
          behavior as before, just now against a local temp table instead
          of remote - if this ever mattered, it already mattered.

 Things you should verify before running against production:
   - Column data types in the CREATE TABLE statements below are reasonable
     guesses (nvarchar/int/datetime/decimal). Check them against the real
     Clarity DDL and tighten/loosen as needed - if a real column is wider
     than what's declared here the INSERT will truncate or error.
   - The self-pay/plan-exclusion EXISTS subquery and the FINANCIAL_CLASS/
     BENEFIT_PLAN_ID mapping logic were moved verbatim - no logic changes,
     just relocated to run once (or locally) instead of per row.
   - This assumes SERVICE_DATE, QUANTITY, TX_AMOUNT, CPT_CODE, UB_REV_CODE_ID
     all live on HSP_TRANSACTIONS, matching the original query.
================================================================================
*/

CREATE PROCEDURE [rpt].[spSelectStateDischargeReportOP_NEW] AS

DECLARE @startdate DATETIME
DECLARE @enddate DATETIME
DECLARE @Location INT
SET @startdate = '2026-07-01' --null,
SET @enddate = '2026-08-01' --null,
SET @Location = 43004001 --HPI CHN
 	--43005005 --HPI CHS
	--43006001 --HPI NWSH
BEGIN

SET NOCOUNT ON;

SET @startdate = IsNull(@startdate, DATEFROMPARTS(YEAR(GETDATE()), Month(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 1, 0)), 1));
SET @enddate   = IsNull(@enddate,   DATEFROMPARTS(YEAR(GETDATE()), Month(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 1, 0)) + 1, 1));

DECLARE @reportingyear   int = YEAR(@startdate);
DECLARE @reportingperiod int = MONTH(@startdate);

/* ============================================================
   0. Cleanup from any prior run in this session
   ============================================================ */
IF OBJECT_ID('tempdb..#TEMPChargeFilter')  IS NOT NULL DROP TABLE #TEMPChargeFilter;
IF OBJECT_ID('tempdb..#TEMPAccounts')      IS NOT NULL DROP TABLE #TEMPAccounts;
IF OBJECT_ID('tempdb..#TEMPDx')            IS NOT NULL DROP TABLE #TEMPDx;
IF OBJECT_ID('tempdb..#TEMPEcode')         IS NOT NULL DROP TABLE #TEMPEcode;
IF OBJECT_ID('tempdb..#TEMPTransactions')  IS NOT NULL DROP TABLE #TEMPTransactions;

/* ============================================================
   1. #TEMPChargeFilter
      Same as original - no parameters needed on the remote side,
      so this stays a plain static OPENQUERY. Fixed the LEFT()/IN()
      type mismatch (quoted the rev-code prefixes) and removed the
      dead --INTO comment.
   ============================================================ */
SELECT *
INTO #TEMPChargeFilter
FROM OPENQUERY([CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM],
'
select
	t.HSP_ACCOUNT_ID
	,SUM(t.TX_AMOUNT) Charges
from [CLARITY].[ORGFILTER].HSP_TRANSACTIONS t
where 1=1
	AND t.SERV_AREA_ID in (425,430)
	AND t.TX_TYPE_HA_C = 1 /*Charges*/
	AND LEFT(t.UB_REV_CODE_ID,2) IN (''36'',''48'',''49'',''75'',''76'')
group by
	t.HSP_ACCOUNT_ID
');

CREATE INDEX IX_TEMPChargeFilter_AcctID ON #TEMPChargeFilter (HSP_ACCOUNT_ID);

/* ============================================================
   2. #TEMPAccounts
      Bulk replacement for the old driving join. Pushes the date
      range, location, coding status, and self-pay/plan-exclusion
      filters down to the remote server via dynamic SQL, so only
      the accounts that would have ended up in the report are
      pulled across.
   ============================================================ */
CREATE TABLE #TEMPAccounts (
	HSP_ACCOUNT_ID      bigint       NOT NULL,
	PAT_ID              varchar(20)  NULL,
	DISCH_LOC_ID        int          NULL,
	ADM_DATE_TIME       datetime     NULL,
	DISCH_DATE_TIME     datetime     NULL,
	ADMISSION_SOURCE_C  int          NULL,
	ADMISSION_TYPE_C    int          NULL,
	PATIENT_STATUS_C    int          NULL,
	TOT_CHGS            decimal(18,2) NULL,
	PAT_MIDDLE_NAME     nvarchar(50) NULL,
	PAT_LAST_NAME       nvarchar(50) NULL,
	PAT_FIRST_NAME      nvarchar(50) NULL,
	ADD_LINE_1          nvarchar(100) NULL,
	CITY                nvarchar(50) NULL,
	ZIP                 nvarchar(10) NULL,
	SEX_C               int          NULL,
	BIRTH_DATE          datetime     NULL,
	SSN                 varchar(20)  NULL,
	PAT_MRN_ID          nvarchar(20) NULL,
	MARITAL_STATUS_C    int          NULL,
	ETHNIC_GROUP_C      int          NULL,
	StateAbbr           varchar(5)   NULL,
	PATIENT_RACE_C      int          NULL,
	FINANCIAL_CLASS     int          NULL,
	PAYOR_NAME          nvarchar(100) NULL,
	PAYOR_ID            int          NULL,
	BENEFIT_PLAN_NAME   nvarchar(100) NULL,
	BENEFIT_PLAN_ID     int          NULL,
	AttendingNPI        varchar(20)  NULL
);

DECLARE @startdateLit varchar(8)  = CONVERT(varchar(8), @startdate, 112); -- YYYYMMDD, unambiguous
DECLARE @enddateLit   varchar(8)  = CONVERT(varchar(8), @enddate, 112);
DECLARE @locationLit  varchar(20) = CAST(@Location AS varchar(20));
DECLARE @innerSql nvarchar(max);
DECLARE @sql      nvarchar(max);

/* Shared account-qualifying filter, reused (joined to HSP_ACCOUNT hsp) in
   every remote pull below. NOTE: this replaces the earlier approach of
   pulling a comma-separated list of qualifying HSP_ACCOUNT_IDs and
   splicing it into each OPENQUERY string - that blew past OPENQUERY's
   hard 8000-character query-text limit once there were more than a
   couple hundred accounts. Repeating this filter remotely in each pull
   keeps every OPENQUERY string small regardless of account volume. */
DECLARE @accountFilterSql nvarchar(max) = N'
	hsp.DISCH_DATE_TIME >= ''' + @startdateLit + N'''
	and hsp.DISCH_DATE_TIME <= ''' + @enddateLit + N'''
	and hsp.CODING_STATUS_C = 4
	and hsp.ACCT_BASECLS_HA_C = 2
	and TRY_CAST(hsp.HSP_ACCOUNT_ID as bigint) >= 600000000
	and hsp.TOT_CHGS > 0
	and hsp.pat_id is not null
	and hsp.DISCH_LOC_ID = ' + @locationLit + N'
	and (hsp.ACCT_FIN_CLASS_C = 4
		 or exists (select * from [CLARITY].[ORGFILTER].clarity_epp epp1
					 where epp1.BENEFIT_PLAN_NAME not in (''OKLAHOMA CITY POLICE DEPARTMENT'',''TURN KEY HEALTH CLINIC'',''SHARED SERVICE'',''SANE/YWCA'',''VALIR HOSPICE'',''WILLOW CREST HOSPITAL'')
					   and hsp.PRIMARY_PLAN_ID = epp1.BENEFIT_PLAN_ID))
';

SET @innerSql = N'
select
	hsp.HSP_ACCOUNT_ID, hsp.PAT_ID, hsp.DISCH_LOC_ID, hsp.ADM_DATE_TIME, hsp.DISCH_DATE_TIME,
	hsp.ADMISSION_SOURCE_C, hsp.ADMISSION_TYPE_C, hsp.PATIENT_STATUS_C, hsp.TOT_CHGS,
	p.PAT_MIDDLE_NAME, p.PAT_LAST_NAME, p.PAT_FIRST_NAME, p.ADD_LINE_1, p.CITY, p.ZIP, p.SEX_C,
	p.BIRTH_DATE, p.SSN, p.PAT_MRN_ID, p.MARITAL_STATUS_C, p.ETHNIC_GROUP_C,
	st.ABBR as StateAbbr, r.PATIENT_RACE_C,
	epm.FINANCIAL_CLASS, epm.PAYOR_NAME, epm.PAYOR_ID,
	epp.BENEFIT_PLAN_NAME, epp.BENEFIT_PLAN_ID,
	ser2.NPI as AttendingNPI
from [CLARITY].[ORGFILTER].HSP_ACCOUNT hsp
	left join [CLARITY].[ORGFILTER].PATIENT p on hsp.PAT_ID = p.PAT_ID
	left join [CLARITY].[ORGFILTER].ZC_STATE st on st.STATE_C = p.STATE_C
	left join [CLARITY].[ORGFILTER].PATIENT_RACE r on r.PAT_ID = p.PAT_ID and r.LINE = 1
	left join [CLARITY].[ORGFILTER].CLARITY_EPM epm on epm.PAYOR_ID = hsp.PRIMARY_PAYOR_ID
	left join [CLARITY].[ORGFILTER].clarity_epp epp on epp.BENEFIT_PLAN_ID = hsp.PRIMARY_PLAN_ID
	left join [CLARITY].[ORGFILTER].clarity_ser_2 ser2 on ser2.PROV_ID = hsp.ATTENDING_PROV_ID
where ' + @accountFilterSql + N'
';

SET @sql = N'
INSERT INTO #TEMPAccounts (
	HSP_ACCOUNT_ID, PAT_ID, DISCH_LOC_ID, ADM_DATE_TIME, DISCH_DATE_TIME,
	ADMISSION_SOURCE_C, ADMISSION_TYPE_C, PATIENT_STATUS_C, TOT_CHGS,
	PAT_MIDDLE_NAME, PAT_LAST_NAME, PAT_FIRST_NAME, ADD_LINE_1, CITY, ZIP, SEX_C,
	BIRTH_DATE, SSN, PAT_MRN_ID, MARITAL_STATUS_C, ETHNIC_GROUP_C,
	StateAbbr, PATIENT_RACE_C,
	FINANCIAL_CLASS, PAYOR_NAME, PAYOR_ID,
	BENEFIT_PLAN_NAME, BENEFIT_PLAN_ID,
	AttendingNPI
)
SELECT
	HSP_ACCOUNT_ID, PAT_ID, DISCH_LOC_ID, ADM_DATE_TIME, DISCH_DATE_TIME,
	ADMISSION_SOURCE_C, ADMISSION_TYPE_C, PATIENT_STATUS_C, TOT_CHGS,
	PAT_MIDDLE_NAME, PAT_LAST_NAME, PAT_FIRST_NAME, ADD_LINE_1, CITY, ZIP, SEX_C,
	BIRTH_DATE, SSN, PAT_MRN_ID, MARITAL_STATUS_C, ETHNIC_GROUP_C,
	StateAbbr, PATIENT_RACE_C,
	FINANCIAL_CLASS, PAYOR_NAME, PAYOR_ID,
	BENEFIT_PLAN_NAME, BENEFIT_PLAN_ID,
	AttendingNPI
FROM OPENQUERY([CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM], ''' + REPLACE(@innerSql, '''', '''''') + N''')
';

EXEC sp_executesql @sql;

CREATE INDEX IX_TEMPAccounts_AcctID ON #TEMPAccounts (HSP_ACCOUNT_ID);

/* ============================================================
   3. #TEMPDx
      Replaces the old princ_diag / oth_diag_code correlated
      subqueries (HSP_ACCT_DX_LIST joined to clarity_edg).
      Scoped via the same @accountFilterSql, joined remotely to
      HSP_ACCOUNT, instead of an account-ID list (see note above).
   ============================================================ */
CREATE TABLE #TEMPDx (
	HSP_ACCOUNT_ID    bigint NOT NULL,
	LINE              int NULL,
	current_icd10_list nvarchar(20) NULL
);

SET @innerSql = N'
select
	diag.HSP_ACCOUNT_ID, diag.LINE, dx.current_icd10_list
from [CLARITY].[ORGFILTER].[HSP_ACCT_DX_LIST] diag
	join [CLARITY].[ORGFILTER].clarity_edg dx on dx.dx_id = diag.dx_id
	join [CLARITY].[ORGFILTER].HSP_ACCOUNT hsp on hsp.HSP_ACCOUNT_ID = diag.HSP_ACCOUNT_ID
where ' + @accountFilterSql + N'
';

SET @sql = N'
INSERT INTO #TEMPDx (HSP_ACCOUNT_ID, LINE, current_icd10_list)
SELECT HSP_ACCOUNT_ID, LINE, current_icd10_list
FROM OPENQUERY([CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM], ''' + REPLACE(@innerSql, '''', '''''') + N''')
';
EXEC sp_executesql @sql;

/* ============================================================
   4. #TEMPEcode
      Replaces the old ecode correlated subquery
      (V_CODING_ALL_DX_PX_LIST). The ZC_DX_POA join in the
      original was never referenced in the output - dropped.
   ============================================================ */
CREATE TABLE #TEMPEcode (
	HSP_ACCOUNT_ID bigint NOT NULL,
	ref_bill_code  nvarchar(20) NULL
);

SET @innerSql = N'
select
	ecode.HSP_ACCOUNT_ID, ecode.ref_bill_code
from [CLARITY].[ORGFILTER].V_CODING_ALL_DX_PX_LIST ecode
	join [CLARITY].[ORGFILTER].HSP_ACCOUNT hsp on hsp.HSP_ACCOUNT_ID = ecode.HSP_ACCOUNT_ID
where ecode.SOURCE_name = ''External Cause of Injury Primary Code Set''
	and ' + @accountFilterSql + N'
';

SET @sql = N'
INSERT INTO #TEMPEcode (HSP_ACCOUNT_ID, ref_bill_code)
SELECT HSP_ACCOUNT_ID, ref_bill_code
FROM OPENQUERY([CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM], ''' + REPLACE(@innerSql, '''', '''''') + N''')
';
EXEC sp_executesql @sql;

/* ============================================================
   5. #TEMPTransactions
      Replaces BOTH the old "procs" (principal CPT) and
      "charge" (revenue-code breakdown) correlated subqueries -
      both hit HSP_TRANSACTIONS, so one pull now covers both.
   ============================================================ */
CREATE TABLE #TEMPTransactions (
	HSP_ACCOUNT_ID  bigint NOT NULL,
	UB_REV_CODE_ID  int NULL,
	CPT_CODE        varchar(20) NULL,
	SERVICE_DATE    datetime NULL,
	QUANTITY        decimal(18,2) NULL,
	TX_AMOUNT       decimal(18,2) NULL
);

SET @innerSql = N'
select
	t.HSP_ACCOUNT_ID, t.UB_REV_CODE_ID, t.CPT_CODE, t.SERVICE_DATE, t.QUANTITY, t.TX_AMOUNT
from [CLARITY].[ORGFILTER].[HSP_TRANSACTIONS] t
	join [CLARITY].[ORGFILTER].HSP_ACCOUNT hsp on hsp.HSP_ACCOUNT_ID = t.HSP_ACCOUNT_ID
where t.UB_REV_CODE_ID is not null
	and ' + @accountFilterSql + N'
';

SET @sql = N'
INSERT INTO #TEMPTransactions (HSP_ACCOUNT_ID, UB_REV_CODE_ID, CPT_CODE, SERVICE_DATE, QUANTITY, TX_AMOUNT)
SELECT HSP_ACCOUNT_ID, UB_REV_CODE_ID, CPT_CODE, SERVICE_DATE, QUANTITY, TX_AMOUNT
FROM OPENQUERY([CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM], ''' + REPLACE(@innerSql, '''', '''''') + N''')
';
EXEC sp_executesql @sql;

CREATE INDEX IX_TEMPDx_AcctID           ON #TEMPDx (HSP_ACCOUNT_ID, LINE);
CREATE INDEX IX_TEMPEcode_AcctID        ON #TEMPEcode (HSP_ACCOUNT_ID);
CREATE INDEX IX_TEMPTransactions_AcctID ON #TEMPTransactions (HSP_ACCOUNT_ID, UB_REV_CODE_ID);


/* ============================================================
   6. Location lookup values - unchanged from original
   ============================================================ */
DECLARE @LocationName varchar(100) = (SELECT case when @location = 43004001 then 'Community Hospital North'
												  when @location = 43005005 then 'Community Hospital South'
												  when @location = 43006001 then 'Northwest Surgical Hospital' end);
DECLARE @LocationAddress varchar(100) = (SELECT case when @location = 43004001 then '3100 SW 89th Street'
												  when @location = 43005005 then '3100 SW 89th Street'
												  when @location = 43006001 then '9204 North May' end);
DECLARE @LocationCity varchar(100) = (SELECT case when @location = 43004001 then 'OKC'
												  when @location = 43005005 then 'OKC'
												  when @location = 43006001 then 'OKC' end);
DECLARE @LocationZip varchar(100) = (SELECT case when @location = 43004001 then '73159'
												  when @location = 43005005 then '73159'
												  when @location = 43006001 then '73120' end);
DECLARE @LocationMedicareNumber varchar(100) = (SELECT case when @location = 43004001 then '370203'
												  when @location = 43005005 then '370203'
												  when @location = 43006001 then '370192' end);

/* ============================================================
   7. Header XML - unchanged from original
   ============================================================ */
DECLARE @Hd XML=
	(
	SELECT
		@reportingyear AS 'reporting_year',
		3 AS 'reporting_type', /*2 - quarterly; 3 - monthly*/
		@reportingperiod AS 'reporting_period',
		@LocationMedicareNumber AS 'medicare_provider_no',
		'O' as 'submission_type', /*O - Hospital Outpatient Surgery Data; I - Hospital Inpatient Data; E - Hospital Emergency Department Data*/
		@LocationName as 'org_name',
		(
			SELECT
			'Diana Waddell' AS 'name',
			'405-637-9017' AS 'phone',
			'dianaw@chcares.com' AS 'email',
			@LocationAddress AS 'street',
			@LocationCity as 'city',
			'OK' as 'state',
			@LocationZip as 'zip'
		for xml path('contact_person'), type
		)
	for XML Path('header'), TYPE
	);

/* ============================================================
   8. Detail XML - same output shape as the original, but every
      correlated remote reference now points at a local temp table.
   ============================================================ */
DECLARE @Dt XML=
	(
	SELECT
		(
			SELECT

			ROW_NUMBER() OVER(ORDER BY acct.PAT_ID ASC) AS '@id',

				(
					SELECT
					left(case
						 when acct.PAT_MIDDLE_NAME is null
						 then acct.PAT_LAST_NAME +', '+ acct.PAT_FIRST_NAME
						 else acct.PAT_LAST_NAME +', '+ acct.PAT_FIRST_NAME +' '+substring(acct.PAT_MIDDLE_NAME,1,1)
						   end, 30) as 'pat_name',
						 CASE WHEN len(acct.ADD_LINE_1) < 5 THEN 'Unknown' ELSE left(acct.ADD_LINE_1,70) end as 'pat_address',

						 	CASE WHEN acct.CITY is null THEN 'Oklahoma City'
							ELSE acct.CITY END  as 'pat_city',
						 case when acct.StateAbbr is null then 'ZZ'
							  when LEN(acct.StateAbbr) > 2 then 'XX'
							  else acct.StateAbbr
							  end as 'pat_state',

						 Case
						 when isnumeric(substring(acct.ZIP,1,5)) = 1 then substring(acct.ZIP,1,5)
						  When LEN(Trim(CAST(acct.ZIP as VARCHAR))) < 5 THEN 99990
						 else 99990 end as 'pat_zip',
					case
						 when acct.SEX_C = 1 then 'F'
						 when acct.SEX_C = 2 then 'M'
						 when acct.SEX_C = 3 then 'U'
						 when acct.SEX_C = 950 then 'U'
						 when acct.SEX_C = 951 then 'U'
						 when acct.SEX_C = 999 then 'U'
						 else 'U'
						  end as 'pat_gender',
				   case
						 when acct.PATIENT_RACE_C = 1 then 4
						 when acct.PATIENT_RACE_C = 2 then 3
						 when acct.PATIENT_RACE_C = 3 then 1
						 when acct.PATIENT_RACE_C = 4 then 2
						 when acct.PATIENT_RACE_C = 5 then 2
						 when acct.PATIENT_RACE_C = 6 then 5
						 when acct.PATIENT_RACE_C = 7 then 6
						 when acct.PATIENT_RACE_C = 8 then 6
						 ELSE 6
						  end as 'pat_race',

				  case
					   when acct.ETHNIC_GROUP_C = 1 then 2
					   when acct.ETHNIC_GROUP_C = 2 then 1
					   when acct.ETHNIC_GROUP_C = 3 then 6
					   when acct.ETHNIC_GROUP_C = 4 then 6
				   else 6
						end as 'pat_ethnicity',

				 case
					  when acct.MARITAL_STATUS_C = 1 then 'S'
					  when acct.MARITAL_STATUS_C = 2 then 'M'
					  when acct.MARITAL_STATUS_C = 3 then 'X'
					  when acct.MARITAL_STATUS_C = 4 then 'D'
					  when acct.MARITAL_STATUS_C = 5 then 'W'
					  when acct.MARITAL_STATUS_C = 6 then 'U'
					  when acct.MARITAL_STATUS_C = 7 then 'P'
					  when acct.MARITAL_STATUS_C = 100 then 'U'
					  else 'U'
					   end as 'pat_marital_stat',

				convert(date,acct.BIRTH_DATE,100) as 'pat_birth_date',

				case
	       			when substring(acct.SSN,8,4) < 4 then '300'
	           		when  substring(acct.SSN,8,4) in('0000','9999') then '300'
					WHEN substring(acct.SSN,8,4) IS NULL then '300'
					else substring(acct.SSN,8,4)
					   end as 'pat_ssn',

				acct.HSP_ACCOUNT_ID as 'pat_control_no',
				acct.PAT_MRN_ID as 'pat_medical_rec_no',
				CASE WHEN acct.DISCH_LOC_ID = 43004001 THEN '1275593337' --HPI CHN
					WHEN acct.DISCH_LOC_ID = 43005005 THEN '1275593337' --HPI CHS
					WHEN acct.DISCH_LOC_ID = 43006001 THEN '1942260971' --HPI NWSH
					END as 'national_provider_no',
				convert(date,acct.ADM_DATE_TIME,100) as 'admit_date',
           		 case datepart(HOUR, acct.ADM_DATE_TIME)
					WHEN 0 THEN   '12'
					WHEN 1 THEN   '01'
					WHEN 2 THEN   '02'
					WHEN 3 THEN   '03'
					WHEN 4 THEN   '04'
					WHEN 5 THEN   '05'
					WHEN 6 THEN   '06'
					WHEN 7 THEN   '07'
					WHEN 8 THEN   '08'
					WHEN 9 THEN   '09'
					ELSE CONVERT(varchar, DATEPART(HOUR, acct.ADM_DATE_TIME))
					 END  as 'admit_hour',

				  convert(date,acct.DISCH_DATE_TIME,100) as 'disch_date',

			 case datepart(HOUR, acct.DISCH_DATE_TIME)
				   WHEN 0 THEN  '12'
				   WHEN 1 THEN   '01'
				   WHEN 2 THEN   '02'
				   WHEN 3 THEN   '03'
				   WHEN 4 THEN   '04'
				   WHEN 5 THEN   '05'
				   WHEN 6 THEN   '06'
				   WHEN 7 THEN   '07'
				   WHEN 8 THEN   '08'
				   WHEN 9 THEN   '09'
				   ELSE CONVERT(varchar, DATEPART(HOUR, acct.DISCH_DATE_TIME))
					 END  as 'disch_hour',

			  case
				   when acct.ADMISSION_SOURCE_C = 18 then 'D'
				   when acct.ADMISSION_SOURCE_C = 23 then 'E'
				   when acct.ADMISSION_SOURCE_C = 24 then 'F'
				   when acct.ADMISSION_SOURCE_C = 25 then '5'
				   when acct.ADMISSION_SOURCE_C = 26 then '6'
					when acct.ADMISSION_SOURCE_C is null then '1'
				   else CONVERT(varchar(10), acct.ADMISSION_SOURCE_C)
					 end as 'point_origin',
			  CASE
			  when acct.ADMISSION_TYPE_C is null then 1
			   else acct.ADMISSION_TYPE_C
				 end  as 'admit_type',

			 case CONVERT(varchar,acct.PATIENT_STATUS_C)
				  when 42 then '20'
				  when 41 then '20'
				  when 40 then '20'
				  when 100 then '50'
				  when 10 then '04'
				  when 09 then '02'
				  when 30 then '02'
				  else CONVERT(varchar(10), acct.PATIENT_STATUS_C)
					end as 'pat_disch_status',

			 ( Select top (6)
				CONCAT(LTRIM((RTRIM(SUBSTRING(ecode.ref_bill_code, CHARINDEX('.',  ecode.ref_bill_code)-3, 3))))
						   ,LTRIM((RTRIM(SUBSTRING(ecode.ref_bill_code, CHARINDEX('.',ecode.ref_bill_code) +1, 4))))
						   )as 'ecode'
				from #TEMPEcode ecode
				where  acct.HSP_ACCOUNT_ID=ecode.HSP_ACCOUNT_ID
				for xml Path(''), TYPE
			 ),

			 case
				  when acct.AttendingNPI = '' then 'OTHOOO'
				  when acct.AttendingNPI IS NULL THEN 'OTHOOO'
				  else acct.AttendingNPI
					end as 'attending_phys_id',

			 case
				  when acct.BENEFIT_PLAN_NAME = 'MEDICARE PART A&B' then 'MEDICARE PART AB'
							  when  acct.BENEFIT_PLAN_NAME is null then 'Self-Pay'
							  when acct.BENEFIT_PLAN_NAME = 'BENEFIT MANAGEMENT, INC - PREFERRED COMMUNITY CHOICE' THEN 'BENEFIT MANAGEMENT INC PREFERRED COMMUNITY CHOICE'
				  else acct.BENEFIT_PLAN_NAME
					end  as 'prim_payer_name',

			 case
			 when acct.FINANCIAL_CLASS in (100,140,150,170,180,190,210,250,260,270,280,310)
				  then 1 /*Commercial*/
				  when acct.FINANCIAL_CLASS in (2,220,101)
				  OR acct.BENEFIT_PLAN_ID in(2201104, 2201105) /*UHC Dual Complete*/
				  then 2 /*Medicare*/
				  when acct.FINANCIAL_CLASS in (1,3,215,401)
				  OR acct.BENEFIT_PLAN_ID in(3000112, 3000304, 4000112, 4000201) /*Aetna*/
				  OR acct.BENEFIT_PLAN_ID in(3000113,4000113,4000203) /*Humana*/
				  then 3 /*Medicaid*/
				  when acct.FINANCIAL_CLASS in (6,230)
				  OR acct.BENEFIT_PLAN_ID in (10301,10302,1400115,1700801,1702101,1702701,2200801,2201501,2201502,2201503,2300201,2300401,3000113, 4000113)
				  then 4 /*VA or Military*/
				  when acct.FINANCIAL_CLASS = 240
				  OR acct.BENEFIT_PLAN_ID in
				  (1800103,1800106,1801701,2400427) /*Hobby Lobby mapped to work comp*/
				  then 5 /*Work Comp*/
				  When acct.FINANCIAL_CLASS = 311
				  or acct.BENEFIT_PLAN_ID in
				  (1601904) /*Self Pay*/
				  or acct.PAYOR_ID in
				  (10622) /*Self Pay*/
				  then 6 /*Uninsured or Self Pay*/
				  when acct.FINANCIAL_CLASS = 160 and acct.PAYOR_NAME like '%COVID19 HRSA UNINSURED TESTING AND TREATMENT FUND%' then 6 /*Uninsured or Self Pay*/
				  when (acct.FINANCIAL_CLASS  in (160, 155) OR acct.BENEFIT_PLAN_ID in(1601903, 1601904,1602101,1550109,1600109,1800112)
				  ) and acct.PAYOR_NAME not like '%COVID19 HRSA UNINSURED TESTING AND TREATMENT FUND%' then 7
				  else 7 end as 'prim_payer_class',

     		convert(numeric,acct.TOT_CHGS,100) as 'total_charges',
			'0131' as 'bill_type',
			'0' as 'icdv',

		(
			select

				CONCAT(LTRIM((RTRIM(SUBSTRING(diag.current_icd10_list, CHARINDEX('.', diag.current_icd10_list) -3, 3))))
							,LTRIM((RTRIM(SUBSTRING(diag.current_icd10_list, CHARINDEX('.', diag.current_icd10_list) +1, 4))))
							)as 'princ_diag',

				(
					select top (17)
							CONCAT(	LTRIM((RTRIM(SUBSTRING(diag2.current_icd10_list, CHARINDEX('.', diag2.current_icd10_list) -3, 3))))
							,LTRIM((RTRIM(SUBSTRING(diag2.current_icd10_list, CHARINDEX('.', diag2.current_icd10_list) +1, 4))))
							)as	 'oth_diag_code'

					from #TEMPDx diag2
					where acct.hsp_account_id=diag2.HSP_ACCOUNT_ID
							and diag2.LINE <>1
					for xml path(''), type, elements
				)

			from #TEMPDx diag
			where acct.hsp_account_id=diag.HSP_ACCOUNT_ID
					and diag.LINE = 1
					AND diag.current_icd10_list is not null
			for xml auto, type
			),
		----------------  PROCEDURE AREA ------------------

		(
			select top (1)
				case
				when procs.CPT_CODE is null
				then  '99999'
				else max(procs.cpt_code)
				end as 'princ_cpt_proc',
				case
				 when acct.AttendingNPI = '' then 'OTHOOO'
				 when acct.AttendingNPI is null then 'OTHOOO'
				 else acct.AttendingNPI
				end as 'princ_cpt_proc_phys_id',
				convert(date,procs.SERVICE_DATE,100) as 'princ_cpt_proc_date'

			from #TEMPTransactions procs

			where acct.hsp_account_id=procs.HSP_ACCOUNT_ID
					and procs.UB_REV_CODE_ID = 450
					and procs.CPT_CODE <> 'EDNOCHG'
			group by
			procs.CPT_CODE,procs.SERVICE_DATE

			  for xml auto, type
		),

 		----------------  CHARGE AREA ------------------

		(
			select

			RIGHT('0'+ CONVERT(VARCHAR,charge.UB_REV_CODE_ID),4)as 'rev_code' ,
			CAST(ROUND(ISNULL(SUM(charge.QUANTITY),0), 0) as int) as 'units_service' ,
			CAST(ROUND(ISNULL(SUM(charge.TX_AMOUNT),0), 0) as int) 'tot_charges_rev_cat'

			from #TEMPTransactions charge

			where acct.hsp_account_id=charge.HSP_ACCOUNT_ID
				and charge.UB_REV_CODE_ID is not null
			group by charge.UB_REV_CODE_ID

			for xml Path('charge'), Root('charges'),TYPE

		)

			for xml path(''), type
				)

			FROM #TEMPChargeFilter cf
				INNER JOIN #TEMPAccounts acct ON TRY_CAST(cf.HSP_ACCOUNT_ID as bigint) = acct.HSP_ACCOUNT_ID and cf.Charges > 0

	  order by '@id'

		for XML Path ('patientrecord'), TYPE
		)
	 for XML Path('patientrecords'), TYPE
	 );

/* ============================================================
   9. Trailer XML - unchanged from original
   ============================================================ */
DECLARE @Tr XML=
	(
	SELECT @Dt.value('count(/patientrecords/*)', 'int') as 'total_records'
	for XML Path('trailer'), TYPE
	);

/* ============================================================
   10. Output - unchanged from original
   ============================================================ */
SELECT
	@Hd
	,@Dt
	,@Tr
for XML Path('hci_data'), TYPE;

/* ============================================================
   11. Cleanup
   ============================================================ */
IF OBJECT_ID('tempdb..#TEMPChargeFilter')  IS NOT NULL DROP TABLE #TEMPChargeFilter;
IF OBJECT_ID('tempdb..#TEMPAccounts')      IS NOT NULL DROP TABLE #TEMPAccounts;
IF OBJECT_ID('tempdb..#TEMPDx')            IS NOT NULL DROP TABLE #TEMPDx;
IF OBJECT_ID('tempdb..#TEMPEcode')         IS NOT NULL DROP TABLE #TEMPEcode;
IF OBJECT_ID('tempdb..#TEMPTransactions')  IS NOT NULL DROP TABLE #TEMPTransactions;

end
GO
