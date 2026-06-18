/****** Script for SelectTopNRows command from SSMS  ******/
CREATE PROCEDURE [stg].[spMedhostCHReloadFactAccountsFull]
as

DELETE FROM fact.Accounts WHERE AccountDataSourceID = 8

INSERT INTO fact.Accounts
(
[AccountID]
      ,[AccountDataSourceID]
      ,[AccountSourceID]
      ,[AccountReferenceNumber]
      ,[AccountPatientID]
      ,[AccountLocationID]
      ,[AccountDepartmentID]
	  ,[AccountFinancialClassID]
      ,[AccountPrimaryPayerID]
      ,[AccountPrimaryPayerPlanID]
      ,[AccountPrimaryProviderID]
      ,[AccountAdmittingProviderID]
      ,[AccountAttendingProviderID]
      ,[AccountReferringProviderID]
      ,[AccountDateOfService]
      ,[AccountDateOfAdmission]
      ,[AccountDateOfDischarge]
      ,[AccountDateOfBilling]
      ,[AccountDateOfClosing]
      ,[AccountDateOfZeroBalance]
      ,[AccountDateOfBadDebtWriteOff]
      ,[AccountTotalCharges]
      ,[AccountTotalAdjustments]
      ,[AccountTotalPayments]
      ,[AccountTotalRefunds]
      ,[AccountTotalBalance]
      ,[AccountStatus]
      ,[AccountClass]
      ,[AccountType]
	  ,[AccountService]
      ,[AccountBillingStatus]
	  ,AccountCodingStatus
	  ,AccountCodingStatusDatetime
      ,[AccountDRG]
      ,[AccountDRGDescription]
      ,[AccountDRGType]
      ,[AccountDRGMDC]
	  ,[AccountDRGCMI]
	  ,[AccountDRGGMLOS]
	  ,AccountIsRecurring
      ,[AccountIsActive]
      ,[AccountUpdatedDatetime]
)
SELECT 
	  CONCAT('8~',v.PATNO) AS AccountID
      ,8 as AccountDataSourceID
      ,v.PATNO as AccountSourceID
      ,v.PATNO as AccountReferenceNumber
      ,CONCAT('8~',v.HSTNUM) as AccountPatientID
      ,CONCAT('8~',v.LOCATION) as AccountLocationID
      ,v.HSV_DESC as AccountDepartmentID
      /*,CASE WHEN v.DXICD9 is not null THEN CONCAT(v.DXICD9,' - ', v.DxDesc,' (ICD)') END as VisitPrimaryDiagnosis  */
      /*,CASE WHEN v.CPTCode is not null THEN CONCAT(v.CPTCode,' - ',v.CPTDesc, ' (CPT)') 
			WHEN v.ICDCode is not null THEN CONCAT(v.ICDCode,' - ',v.ICDDesc, ' (ICD)')
			END as VisitPrimaryProcedure*/
	  ,CONCAT('8~',CASE WHEN v.NWARFC1 = '0' THEN '999' ELSE v.NWARFC1 END) as AccountFinancialClassID
      ,CONCAT('8~',CASE WHEN v.AINS1 = '0' THEN '999' ELSE v.AINS1 END) as AccountPrimaryPayerID /*999 is self-pay*/
	  ,CONCAT('8~',CASE WHEN v.AINS1 = '0' THEN '999' ELSE v.AINS1 END,'~',CASE WHEN v.AINS1 = '0' THEN '1' ELSE v.APLN1 END) as AccountPrimaryPayerPlanID /*999 is self-pay*/
      ,CASE WHEN coalesce(v.NWPROCDR,v.PRDOCN, v.NWDOCNUM) IS NOT NULL THEN CONCAT('8~', coalesce(v.NWPROCDR,v.PRDOCN, v.NWDOCNUM)) END as AccountPrimaryProviderID
      ,CASE WHEN coalesce(v.NWATTPHY, NWPROCDR, v.NWDOCNUM) IS NOT NULL THEN CONCAT('8~', coalesce(v.NWATTPHY, NWPROCDR, v.NWDOCNUM)) END as AccountAdmittingProviderID
      ,CASE WHEN v.NWATTPHY IS NOT NULL THEN CONCAT('8~',v.NWATTPHY) END as AccountAttendingProviderID
      ,CASE WHEN v.NWREFDOC IS NOT NULL THEN CONCAT('8~',v.NWREFDOC) END as AccountReferringProviderID
      ,CASE WHEN v.ISADATE = '0001-01-01' THEN NULL ELSE v.ISADATE END as AccountDateOfService
      ,CASE WHEN v.ISADATE = '0001-01-01' THEN NULL ELSE v.ISADATE END as AccountDateOfAdmission
      ,CASE WHEN v.ISDDATE = '0001-01-01' THEN NULL ELSE v.ISDDATE END as AccountDateOfDischarge
      ,CASE WHEN v.ISDTFBL = '0001-01-01' THEN NULL ELSE v.ISDTFBL END as AccountDateOfBilling
      ,null as AccountDateOfClosing
      ,null as AccountDateOfZeroBalance
	  ,CASE WHEN v.ISBDWDT = '0001-01-01' THEN NULL ELSE v.ISBDWDT END as AccountDateOfBadDebtWriteOff
      ,v.ORGBL as AccountTotalCharges
      ,null as AccounttTotalAdjustments
      ,null as AccountTotalPayments
      ,null as AccountTotalRefunds
      ,V.CURBL - v.RCAMT as AccountTotalBalance /*AR Balance - Bad Debt recovery balance*/
      ,CASE WHEN v.ISADATE = '0001-01-01' THEN 'Scheduled'
			--WHEN v.ISADATE <> '0001-01-01' AND v.ISDDATE = '0001-01-01' THEN 'Admitted' 
			ELSE 'Completed' END as AccountStatus
      ,/*CASE WHEN v.SVCLAS = 'M' THEN 'Inpatient'
			WHEN v.SVCLAS = 'O' THEN 'Outpatient'
			WHEN v.SVCLAS = 'X' THEN 'Observation'
			WHEN v.SVCLAS = 'P' THEN 'Pain Management'
			WHEN v.SVCLAS = 'E' THEN 'Emergency'
			WHEN v.SVCLAS = 'S' THEN 'Sleep Study'
			WHEN v.SVCLAS = 'R' THEN 'Rehab'

			ELSE v.SVCLAS END */
	   CASE WHEN v.ABIO = 'I' THEN 'Inpatient'
	        WHEN v.ABIO = 'O' THEN 'Outpatient'
			WHEN v.RECTYP = 'I' THEN 'Inpatient'
			WHEN v.RECTYP = 'O' THEN 'Outpatient'
			ELSE v.RECTYP END
			as AccountClass
      ,isnull(v.SVDESC, v.HSV_DESC) as AccountType
	  ,isnull(v.SVDESC, v.HSV_DESC) as AccountService
      ,CASE WHEN v.CURBL = 0 THEN 'Zero'
		    WHEN v.CURBD > 0 THEN 'Bad Debt'
			WHEN v.ISDTFBL is not null THEN 'Final Billed'
			ELSE 'Not Final Billed' END as AccountBillingStatus
	  --,v.CFFLG as VisitBillingFlag
      ,'Completed' AS  AccountCodingStatus
	  ,CASE WHEN v.ISDTFBL = '0001-01-01' THEN NULL ELSE v.ISDTFBL END as AccountCodingStatusDatetime
      ,v.ABDRG as AccountDRG
	  ,v.DRGDesc as AccountDRGDescription
	  ,v.DRGType as AccountDRGType
	  ,v.DRGMDC as AccountDRGMDC
	  ,v.DRGCMI as AccountDRGCMI
	  ,v.DRGGMLOS as AccountDRGGMLOS
	  ,0 AccountIsRecurring
	  /*
	  ,CASE WHEN isnull(v.SVDESC, v.HSV_DESC) in ('OUTPATIENT'
								  ,'INPATIENT'
								  ,'GI PATIENTS'
								  ,'SURGICAL'
								  ,'OBSERVATION'
								  ,'EYES'
								  ,'MEDICAL'
								  ,'PAIN MANAGEMENT'
								  ,'ICU'
								  ,'Surgery Admit'
								  ,'Outpatient Surgery'
								  ,'Pain') THEN 1 ELSE 0 END as VisitIsSurgical
	  */
      ,1 as AccountIsActive
      ,getdate() AS AccountUpdatedDatetime
--select *
  FROM OPENQUERY([hmsls],'
	select
	p.RECTYP
	,p.PATNO
	,p.HSTNUM
	,a.NWARFC1
	,p.AINS1
	,p.APLN1
	,p.ISADATE
	,p.ISDDATE
	,p.NWPROCDR
	,p.NWDOCNUM
	,prc.PRDOCN
	,p.NWATTPHY
	,p.NWREFDOC
	,p.HSSVC
	,p.DIAGN
	,a.ISDTFBL
	,a.ORGBL
	,a.CURBL
	,a.CURBD
	,a.RCAMT
	,ab.ABDRG
	,drg.DRGDES AS DRGDesc
	,drg.MDC as DRGMDC
	,drg.TYPE as DRGType
	,drg.CGELOS as DRGGMLOS
	,drg.CSTWST as DRGCMI
	,ab.ABDRGW
	,ab.ABRMBD
	,ab.ABIO
	,ab.ABMDC
	,svc.SVCLAS
	,svc.SVDESC
	,dx.DXICD9
	,cpt.CPCPTC as CPTCode
	,cptc.CDESC as CPTDesc
	,prc.PRICD9 as ICDCode
	,icd.PRDESC_  as ICDDesc
	,icdx.DGDESC_ as DxDesc
	,hsvc.HSV_DESC
	,hsvc.LOCATION
	,a.ISBDWDT
	,p.CFFLG
	from MHD32.HOSPF110.PATIENTS p 
		LEFT JOIN MHD32.HOSPF110.ARMAST a ON a.PATNO = p.PATNO
		LEFT JOIN MHD32.HOSPF110.MRABMSTR ab ON ab.ABNUMB = a.PATNO
		LEFT JOIN MHD32.HOSPF110.MRABDIAG dx ON dx.DXNUMB = ab.ABNUMB AND dx.DXTYPE = ''P'' and dx.DXCMED = 0
			LEFT JOIN MHD32.HOSPF110.I10DIAG icdx ON icdx.DGCODE_ = dx.DXICD9 AND dx.DXCDDT between icdx.DGEFFDATE_ AND icdx.DGEXPDATE_
		LEFT JOIN (select cpt.CPNUMB, MIN(cpt.CPCPTC) AS CPCPTC, MIN(cpt.CPPSDT) AS CPPSDT
				   from MHD32.HOSPF110.MRABCPTC cpt
				   where cpt.CPSEQ# = 1 and cpt.CPCMED = ''0'' and cpt.CPCDDT >= ''2017-01-01''
				   group by cpt.CPNUMB
				  ) cpt ON cpt.CPNUMB = ab.ABNUMB 
			LEFT JOIN MHD32.HOSPF110.CPTCODE cptc ON cptc.CPTCD = cpt.CPCPTC AND cpt.CPPSDT between cptc.CPEFFD and cptc.CPTRMD
		LEFT JOIN MHD32.HOSPF110.MRABPROC prc ON prc.PRNUMB = a.PATNO AND prc.PRTYPE = ''P'' and prc.PRBSEQ# = 1 and prc.PRCMED = ''0''
			LEFT JOIN MHD32.HOSPF110.I10PROC icd ON icd.PRCODE_ = prc.PRICD9 AND prc.PRPSDT between icd.PREFFDATE_ and icd.PREXPDATE_
		LEFT JOIN MHD32.HOSPF110.STATHDV1 hsvc ON hsvc.HOSVCD = COALESCE(a.HSSVC, p.HSSVC)
		LEFT JOIN MHD32.HOSPF110.MRSERV svc ON svc.SVCODE = COALESCE(ab.ABSVCD, hsvc.MRSRV_CDE)
		LEFT JOIN ACMSHRLIBA.DRGMSDESCC drg ON drg.DRICO = 1 AND drg.DRG = ab.ABDRG
	where 1=1
	AND (CAST(a.ISADATE1 as Date) >= ''2016-01-01'' OR a.PATNO IS NULL) /*a.PATNO is null for future scheduled patients*/
	--and a.PATNO = 3450991
	--AND a.ISBDWDT is not null
	--fetch first 10000 rows only
	') v

/*
      SELECT  
  *
  FROM OPENQUERY([hmsls],'
	select
	drg.CGELOS 
	,drg.CSTWST 
	
	from ACMSHRLIBA.DRGMSDESCC drg
	where 1=1
	fetch first 10000 rows only
	') v
	Where v.DRG = 1
*/

/*
select
*
from openquery(HMSLS,
'select 
	t.TABLE_SCHEMA as TableSchema
	,t.TABLE_NAME as TableName
	,t.TABLE_TEXT as TableDescription
	,c.ORDINAL_POSITION as ColumnOrder
	,c.COLUMN_NAME as ColumnName
	,c.COLUMN_HEADING as ColumnHeading
	,c.COLUMN_TEXT as ColumnDescription
from QSYS2.SYSCOLUMNS c
	left join QSYS2.SYSTABLES t on t.TABLE_NAME = c.TABLE_NAME and t.TABLE_SCHEMA = c.TABLE_SCHEMA
where 1=1
AND t.TABLE_SCHEMA = ''ACMSHRLIBA''
AND t.TABLE_NAME = ''DRGMSDESCC'' 
--and t.TABLE_TEXT like ''%Financial%''
--AND C.column_text like ''%CHECK%'' 
')
order by TableSchema, TableName, ColumnOrder
*/

	/*
	      SELECT 
  *
  FROM OPENQUERY([hmsls],'
	select
	p.*
	,icd.PRDESC_
	from MHD32.HOSPF110.MRABPROC p 
		left join MHD32.HOSPF110.I10PROC icd ON icd.PRCODE_ = p.PRICD9 AND p.PRPSDT between icd.PREFFDATE_ and icd.PREXPDATE_
	where 1=1
	--and PRNUMB = 3030311
	--fetch first 100 rows only
	') v

		      SELECT 
  *
  FROM OPENQUERY([hmsls],'
	select
	cpt.*
	,cptc.*
	from MHD32.HOSPF110.MRABCPTC cpt
		LEFT JOIN MHD32.HOSPF110.CPTCODE cptc ON cptc.CPTCD = cpt.CPCPTC
	where 1=1
	  and CPPSDT >= ''2017-01-01''
	--and CPNUMB = 3031992
	--fetch first 100 rows only
	') v


	
  SELECT 
  *
  FROM OPENQUERY([hmsls],'
	select
	*
	from MHD32.HOSPF110.DRGDESC 

	where 1=1

	') v
	*/
GO
