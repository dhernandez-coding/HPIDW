-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [rpt].[spSelectStateDischargeReportED_export]
	-- Add the parameters for the stored procedure here
	@Location int,
	@startdate datetime,
	@enddate datetime,
	@reportingyear int,
	@reportingperiod int
AS
BEGIN
	

--DECLARE @startdate datetime = '7/1/2024'
--DECLARE @enddate datetime = '8/1/2024'
--DECLARE @reportingyear int = YEAR(@startdate)
--DECLARE @reportingperiod int = MONTH(@startdate)
--DECLARE @Location int = 43004001 --HPI CHN
--						--43005005 --HPI CHS
--						--43006001 --HPI NWSH
DECLARE @LocationName varchar(100) = (SELECT case when @location = 43004001 then 'Community Hospital North'
												  when @location = 43005005 then 'Community Hospital South'
												  when @location = 43006001 then 'Northwest Surgical Hospital' end)
DECLARE @LocationAddress varchar(100) = (SELECT case when @location = 43004001 then '3100 SW 89th Street'
												  when @location = 43005005 then '3100 SW 89th Street'
												  when @location = 43006001 then '9204 North May' end)
DECLARE @LocationCity varchar(100) = (SELECT case when @location = 43004001 then 'OKC'
												  when @location = 43005005 then 'OKC'
												  when @location = 43006001 then 'OKC' end)
DECLARE @LocationZip varchar(100) = (SELECT case when @location = 43004001 then '73159'
												  when @location = 43005005 then '73159'
												  when @location = 43006001 then '73120' end)
DECLARE @LocationMedicareNumber varchar(100) = (SELECT case when @location = 43004001 then '370203'
												  when @location = 43005005 then '370203'
												  when @location = 43006001 then '370192' end)



/*Header XML*/
DECLARE @Hd XML=
	(
	SELECT
		@reportingyear AS 'reporting_year',
		3 AS 'reporting_type', /*2 - quarterly; 3 - monthly*/
		@reportingperiod AS 'reporting_period',
		@LocationMedicareNumber AS 'medicare_provider_no',
		'E' as 'submission_type', /*O - Hospital Outpatient Surgery Data; I - Hospital Inpatient Data; E - Hospital Emergency Department Data*/
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
		) --as 'contact_person'
	for XML Path('header'), TYPE
	)

/*Detail XML*/
DECLARE @Dt XML=
	(

	SELECT
		(
			SELECT

			ROW_NUMBER() OVER(ORDER BY hsp.pat_id ASC) AS '@id',
		
	   			(
					 SELECT
					left(case 
						 when p.PAT_MIDDLE_NAME is null 
						 then p.pat_last_name +', '+ p.pat_first_name
						 else p.pat_last_name +', '+ p.pat_first_name +' '+substring(p.PAT_MIDDLE_NAME,1,1) 
						   end, 30) as 'pat_name',
						case 
							when p.add_line_1  = 'none' then 'Unknown'
							when p.add_line_1 is null then 'Unknown'
							when len(p.add_line_1) < 5 then 'Unknown'
							else left(p.add_line_1,70)
							end  as 'pat_address',
						  Case when p.city is not null
						 then p.city 
						 else 'Oklahoma City'
						end as 'pat_city',
						 CASE WHEN st.abbr is null THEN 'ZZ' 
							  WHEN LEN(st.abbr) > 2 THEN 'XX' 
							  ELSE st.abbr END  as 'pat_state',
					case when isnumeric(substring(p.zip,1,5)) = 1 then substring(p.zip,1,5) else 99990 end as 'pat_zip',
					case 
						 when p.SEX_C = 1 then 'F'
						 when p.SEX_C = 2 then 'M'
						 when p.SEX_C = 3 then 'U'
						 when p.SEX_C = 950 then 'U'
						 when p.SEX_C = 951 then 'U'
						 when p.SEX_C = 999 then 'U'
						 ELSE 'U'
						  end as 'pat_gender',
				   case 
						 when r.PATIENT_RACE_C = 1 then 4
						 when r.PATIENT_RACE_C = 2 then 3
						 when r.PATIENT_RACE_C = 3 then 1
						 when r.PATIENT_RACE_C = 4 then 2
						 when r.PATIENT_RACE_C = 5 then 2
						 when r.PATIENT_RACE_C = 6 then 5
						 when r.PATIENT_RACE_C = 7 then 6
						 when r.PATIENT_RACE_C = 8 then 6
						 ELSE 6
						  end as 'pat_race',

				  case
					   when p.ETHNIC_GROUP_C = 1 then 2
					   when p.ETHNIC_GROUP_C = 2 then 1
					   when p.ETHNIC_GROUP_C = 3 then 6
					   when p.ETHNIC_GROUP_C = 4 then 6
				   when p.ETHNIC_GROUP_C is null then 6
				   else 6
						end as 'pat_ethnicity',

				 case
					  when p.MARITAL_STATUS_C = 1 then 'S'
					  when p.MARITAL_STATUS_C = 2 then 'M'
					  when p.MARITAL_STATUS_C = 3 then 'X'
					  when p.MARITAL_STATUS_C = 4 then 'D'
					  when p.MARITAL_STATUS_C = 5 then 'W'
					  when p.MARITAL_STATUS_C = 6 then 'U'
					  when p.MARITAL_STATUS_C = 7 then 'P'
					  when p.MARITAL_STATUS_C = 100 then 'U'
					  Else 'U'
					   end as 'pat_marital_stat',

				convert(date,p.BIRTH_DATE,100) as 'pat_birth_date',

				case 
	       			when substring(p.ssn,8,4) < 4 then '300'
	           		when  substring(p.ssn,8,4) in('0000','9999') then '300'
					WHEN substring(p.ssn,8,4) IS NULL then '300'
					else substring(p.SSN,8,4) 
					   end as 'pat_ssn',

				hsp.HSP_ACCOUNT_ID as 'pat_control_no',
				p.PAT_MRN_ID as 'pat_medical_rec_no',
				CASE WHEN HSP.DISCH_LOC_ID = 43004001 THEN '1275593337' --HPI CHN
					WHEN HSP.DISCH_LOC_ID = 43005005 THEN '1275593337' --HPI CHS
					WHEN HSP.DISCH_LOC_ID = 43006001 THEN '1942260971' --HPI NWSH
					END as 'national_provider_no',
				convert(date,hsp.ADM_DATE_TIME,100) as 'admit_date',
           		 case datepart(HOUR, hsp.ADM_DATE_TIME)
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
					ELSE CONVERT(varchar, DATEPART(HOUR, hsp.ADM_DATE_TIME))
					 END  as 'admit_hour',
	       
				  convert(date,hsp.DISCH_DATE_TIME,100) as 'disch_date',
	  
			 case datepart(HOUR, hsp.DISCH_DATE_TIME)
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
				   ELSE CONVERT(varchar, DATEPART(HOUR, hsp.DISCH_DATE_TIME))
					 END  as 'disch_hour',

			  case
				   when hsp.ADMISSION_SOURCE_C = 18 then 'D'
				   when hsp.ADMISSION_SOURCE_C = 23 then 'E'
				   when hsp.ADMISSION_SOURCE_C = 24 then 'F'
				   when hsp.ADMISSION_SOURCE_C = 25 then '5'
				   when hsp.ADMISSION_SOURCE_C = 26 then '6'
					when hsp.ADMISSION_SOURCE_C is null then '1'
				   else hsp.ADMISSION_SOURCE_C
					 end as 'point_origin',
			  CASE
			  when hsp.ADMISSION_TYPE_C is null then 1
			   else hsp.ADMISSION_TYPE_C
				 end  as 'admit_type',

			 case CONVERT(varchar,hsp.PATIENT_STATUS_C)
				  when 42 then '20'
				  when 41 then '20'
				  when 40 then '20'
				  when 100 then '50'
				  when 10 then '04'
				  when 09 then '02'
				  when 30 then '02'
				  else hsp.PATIENT_STATUS_C
					end as 'pat_disch_status',

			  -- convert(numeric,hsp.BIRTH_WEIGHT, 100) as 'birth_weight',
			 ( Select top (6)
				CONCAT(LTRIM((RTRIM(SUBSTRING(ecode.ref_bill_code, CHARINDEX('.',  ecode.ref_bill_code)-3, 3))))
						   ,LTRIM((RTRIM(SUBSTRING(ecode.ref_bill_code, CHARINDEX('.',ecode.ref_bill_code) +1, 4))))
						   )as 'ecode'
				from [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].V_CODING_ALL_DX_PX_LIST ecode with(nolock)
					left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_DX_POA pos on ecode.DX_POA_C = pos.DX_POA_C
				where  hsp.HSP_ACCOUNT_ID=ecode.HSP_ACCOUNT_ID 
					and ecode.SOURCE_name = 'External Cause of Injury Primary Code Set'
				for xml Path(''), TYPE		
			 ),
	
			 case 
				  when ser2.NPI = '' then 'OTHOOO' 
				  when ser2.NPI IS NULL THEN 'OTHOOO'
				  else ser2.NPI
					end as 'attending_phys_id',

			 case 
				  when epp.BENEFIT_PLAN_NAME = 'MEDICARE PART A&B' then 'MEDICARE PART AB'
							  when  epp.BENEFIT_PLAN_NAME is null then 'Self-Pay'
							  when epp.BENEFIT_PLAN_NAME = 'BENEFIT MANAGEMENT, INC - PREFERRED COMMUNITY CHOICE' THEN 'BENEFIT MANAGEMENT INC PREFERRED COMMUNITY CHOICE'
				  else epp.BENEFIT_PLAN_NAME
					end  as 'prim_payer_name',

			 case
				  when epm.FINANCIAL_CLASS = 100 then 1
				  when epm.FINANCIAL_CLASS = 101 then 2
				  when epm.FINANCIAL_CLASS = 6 then 4
				  when epm.FINANCIAL_CLASS = 140 then 1
				  when epm.FINANCIAL_CLASS = 150 then 1
				  when epm.FINANCIAL_CLASS = 160 and payor_name like '%COVID19 HRSA UNINSURED TESTING AND TREATMENT FUND%' then 6
						  when epm.FINANCIAL_CLASS = 160 and payor_name not like '%COVID19 HRSA UNINSURED TESTING AND TREATMENT FUND%' then 7
				  when epm.FINANCIAL_CLASS = 170 then 1
				  when epm.FINANCIAL_CLASS = 180 then 1
				  when epm.FINANCIAL_CLASS = 190 then 1
				  when epm.FINANCIAL_CLASS = 210 then 1
				  when epm.FINANCIAL_CLASS = 220 then 2
				  when epm.FINANCIAL_CLASS = 230 then 4
				  when epm.FINANCIAL_CLASS = 240 then 5
				  when epm.FINANCIAL_CLASS = 250 then 1
				  when epm.FINANCIAL_CLASS = 260 then 1
				  when epm.FINANCIAL_CLASS = 270 then 1
				  when epm.FINANCIAL_CLASS = 280 then 1
				  when epm.FINANCIAL_CLASS = 310 then 1
				  When epm.FINANCIAL_CLASS is null then 1
						  When epm.FINANCIAL_CLASS = 311 then 6
				  else 7
					 end as 'prim_payer_class',

     		convert(numeric,hsp.TOT_CHGS,100) as 'total_charges',
			'0131' as 'bill_type',
	
		--case
		--				when drg.DRG_NUMBER = '' then '9999'
		--				else left(drg.drg_number, 1)+''+right(drg.DRG_NUMBER, 3)
		--			end as 'drg',
	
			'0' as 'icdv',


		(
			select
			
			
				CONCAT(LTRIM((RTRIM(SUBSTRING(dx.current_icd10_list, CHARINDEX('.', dx.current_icd10_list) -3, 3)))) 
							,LTRIM((RTRIM(SUBSTRING(dx.current_icd10_list, CHARINDEX('.', dx.current_icd10_list) +1, 4))))
						
							)as 'princ_diag',
								
			(
					select top (17)
							CONCAT(	LTRIM((RTRIM(SUBSTRING(dx.current_icd10_list, CHARINDEX('.', dx.current_icd10_list) -3, 3))))
							,LTRIM((RTRIM(SUBSTRING(dx.current_icd10_list, CHARINDEX('.', dx.current_icd10_list) +1, 4))))
						
							)as	 'oth_diag_code'
				
					from [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[HSP_ACCT_DX_LIST] diag with(nolock)
						join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].clarity_edg dx with(nolock) on dx.dx_id=diag.dx_id
					
					where hsp.hsp_account_id=diag.HSP_ACCOUNT_ID
							and diag.LINE <>1
						

					for xml path(''), type, elements

				)
		
		
		from [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[HSP_ACCT_DX_LIST] diag with(nolock)
				join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].clarity_edg dx with(nolock) on dx.dx_id=diag.dx_id
            

			where hsp.hsp_account_id=diag.HSP_ACCOUNT_ID
					and diag.LINE = 1
					AND dx.current_icd10_list is not null
			
			
			
			
			for xml auto, type
		),
		----------------  PROCEDURE AREA ------------------

		(
			select top (1)
				case
				when procs.CPT_CODE is null --= 99999
				then  '99999'
				else max(procs.cpt_code) --+''+procs.CPT_MODIFIERS
				end as 'princ_cpt_proc',
				case 
				 when ser2.NPI = '' then 'OTHOOO' 
				 else ser2.NPI
				end as 'princ_cpt_proc_phys_id',
				convert(date,procs.SERVICE_DATE,100) as 'princ_cpt_proc_date'

					--(

					-- Select top (17)
					
					--	convert(date,ap.proc_date,100) as 'oth_proc_date'

					--from HSP_ACCT_cpt_codes cp 
					--	join HSP_ACCOUNT hsp  on hsp.hsp_account_id = cp.HSP_ACCOUNT_ID

					--where ap.LINE <> 1
			
					--for xml Path(''), TYPE

					--)
		
			from [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[HSP_TRANSACTIONS] procs with(nolock)
		
			where hsp.hsp_account_id=procs.HSP_ACCOUNT_ID
					and procs.UB_REV_CODE_ID = 450
		and procs.CPT_CODE <> 'EDNOCHG'
		group by 
		procs.CPT_CODE,procs.SERVICE_DATE
			
			  --for xml Path('procs'), TYPE
			  --for xml Path('procs'), Root('auto'),TYPE
			  --for xml path(''), type, elements
			  for xml auto, type  
		),



 		----------------  CHARGE AREA ------------------
 
		(
			select
			
			RIGHT('0'+ CONVERT(VARCHAR,charge.UB_REV_CODE_ID),4)as 'rev_code' ,
			CAST(ROUND(ISNULL(SUM(charge.QUANTITY),0), 0) as int) as 'units_service' ,
			CAST(ROUND(ISNULL(SUM(charge.TX_AMOUNT),0), 0) as int) 'tot_charges_rev_cat'	
		
			from [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[HSP_TRANSACTIONS] charge with(nolock)

			where hsp.hsp_account_id=charge.HSP_ACCOUNT_ID
				and charge.UB_REV_CODE_ID is not null
			group by charge.UB_REV_CODE_ID
			
			for xml Path('charge'), Root('charges'),TYPE

		)
			FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].PATIENT p

						LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_STATE st	ON st.STATE_C = p.STATE_C
						LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].PATIENT_RACE r	ON r.pat_id = p.PAT_ID
						LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].CLARITY_EPM epm	ON epm.PAYOR_ID = hsp.PRIMARY_PAYOR_ID
						LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].clarity_epp epp	ON epp.BENEFIT_PLAN_ID = hsp.PRIMARY_PLAN_ID
						LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].clarity_drg drg	ON drg.DRG_ID = hsp.FINAL_DRG_ID
						LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].clarity_ser_2 ser2 ON ser2.PROV_ID = hsp.ATTENDING_PROV_ID
						LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_MC_ADM_SOURCE zcadmin ON zcadmin.ADMISSION_SOURCE_C = hsp.ADMISSION_SOURCE_C
			WHERE hsp.PAT_ID = p.PAT_ID
					AND r.line = 1 
			  		AND convert(numeric,hsp.TOT_CHGS,100) > 0
					AND hsp.TOT_CHGS > 0
			   				
			for xml path(''), type
	)

	FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].HSP_ACCOUNT hsp
		LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].PATIENT p	ON hsp.PAT_ID = p.PAT_ID
		LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].PAT_ENC_HSP enc on hsp.PRIM_ENC_CSN_ID = ENC.PAT_ENC_CSN_ID
		LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].CLARITY_DEP dep on dep.DEPARTMENT_ID = enc.DEPARTMENT_ID
		--LEFT JOIN ZC_STATE st ON st.STATE_C = p.STATE_C
		-- JOIN PATIENT_RACE r ON r.pat_id = p.PAT_ID
		--LEFT JOIN clarity.dbo.CLARITY_EPM epm	ON epm.PAYOR_ID = hsp.PRIMARY_PAYOR_ID
		--LEFT JOIN clarity.dbo.clarity_epp epp	ON epp.BENEFIT_PLAN_ID = hsp.PRIMARY_PLAN_ID
		--LEFT JOIN clarity.dbo.clarity_drg drg	ON drg.DRG_ID = hsp.FINAL_DRG_ID
		--LEFT JOIN clarity.dbo.clarity_ser_2 ser2 ON ser2.PROV_ID = hsp.ATTENDING_PROV_ID
		--LEFT JOIN clarity.dbo.ZC_MC_ADM_SOURCE zcadmin ON zcadmin.ADMISSION_SOURCE_C = hsp.ADMISSION_SOURCE_C

	WHERE 1=1
		--AND hsp.HSP_ACCOUNT_ID in (606203035,606203105,606201776) 
		AND hsp.DISCH_DATE_TIME >= @startdate
		AND hsp.DISCH_DATE_TIME <= @enddate
		and hsp.CODING_STATUS_C = 4 -- Completed coding
		AND hsp.ACCT_BASECLS_HA_C = 3
		AND hsp.HSP_ACCOUNT_ID >= 600000000
		AND convert(numeric,hsp.TOT_CHGS,100) > 0
		AND (hsp.ACCT_FIN_CLASS_C = 4 /*Self Pay*/
			 OR exists( select * 
						from [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].clarity_epp epp1
						where epp1.BENEFIT_PLAN_NAME not in  ('OKLAHOMA CITY POLICE DEPARTMENT','TURN KEY HEALTH CLINIC','SHARED SERVICE','SANE/YWCA','VALIR HOSPICE','WILLOW CREST HOSPITAL')
							  AND hsp.PRIMARY_PLAN_ID = epp1.BENEFIT_PLAN_ID)
			)
		AND hsp.pat_id is not null
		AND HSP.DISCH_LOC_ID IN (@Location
								--43004001 --HPI CHN
								--,43005005 --HPI CHS
								--,43006001 --HPI NWSH
								)  
		  order by '@id'
			
			for XML Path ('patientrecord'), TYPE
			)
		 for XML Path('patientrecords'), TYPE
		 )

/*Detail XML*/
DECLARE @Tr XML=
	(
	SELECT @Dt.value('count(/patientrecords/*)', 'int') as 'total_records'
	for XML Path('trailer'), TYPE
	)

/*Output XML*/	
SELECT 
	@Hd
	,@Dt
	,@Tr
for XML Path('hci_data'), TYPE;
END
GO
