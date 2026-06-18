/****** Script for SelectTopNRows command from SSMS  ******/
CREATE PROCEDURE [stg].[spMedhostNSReloadFactVisits2Full]
as

	DELETE FROM fact.Visits2 WHERE VisitDatasourceID = 2

	INSERT INTO fact.Visits2 
	  ([VisitID]
      ,[VisitDatasourceID]
      ,[VisitSourceID]
      ,[VisitPatientID]
      ,[VisitAccountID]
      ,[VisitLocationID]
      ,[VisitDepartmentID]
      ,[VisitRoomID]
      ,[VisitPrimaryProviderID]
      ,[VisitAppointmentProviderID]
      ,[VisitAdmittingProviderID]
      ,[VisitAttendingProviderID]
      ,[VisitDischargeProviderID]
      ,[VisitType]
      ,[VisitService]
      ,[VisitStatus]
      ,[VisitDateOfService]
      ,[VisitDatetimeOfService]
      ,[VisitDateOfScheduling]
      ,[VisitDateOfAppointment]
      ,[VisitDateOfAdmission]
      ,[VisitDateOfDischarge]
      ,[VisitDateofClosing]
      ,[VisitDateOfCancellation]
      ,[VisitCancellationReason]
      ,[VisitIsPrimary]
      ,[VisitIsActive]
      ,[VisitUpdatedDatetime]
	)

SELECT 
	  CONCAT('2~',v.PATNO) AS VisitID
      ,2 as VisitDataSourceID
      ,v.PATNO as VisitSourceID
	  ,CONCAT('2~',v.HSTNUM) as VisitPatientID
      ,CONCAT('2~',v.PATNO) as VisitAccountID
      ,CONCAT('2~',v.LOCATION) as VisitLocationID
      ,CONCAT('2~',v.HSV_DESC) as VisitDepartmentID
      ,v.ABRMBD as VisitRoomID
      ,CASE WHEN coalesce(v.NWPROCDR,v.PRDOCN, v.NWDOCNUM) IS NOT NULL THEN CONCAT('2~', coalesce(v.NWPROCDR,v.PRDOCN, v.NWDOCNUM)) END as VisitPrimaryProviderID
	  ,CASE WHEN coalesce(v.NWPROCDR,v.PRDOCN, v.NWDOCNUM) IS NOT NULL THEN CONCAT('2~', coalesce(v.NWPROCDR,v.PRDOCN, v.NWDOCNUM)) END as VisitAppointmentProviderID
      ,CASE WHEN coalesce(v.NWATTPHY, NWPROCDR, v.NWDOCNUM) IS NOT NULL THEN CONCAT('2~', coalesce(v.NWATTPHY, NWPROCDR, v.NWDOCNUM)) END as VisitAdmittingProviderID
      ,CASE WHEN v.NWATTPHY IS NOT NULL THEN CONCAT('2~',v.NWATTPHY) END as VisitAttendingProviderID
	  ,CASE WHEN v.NWATTPHY IS NOT NULL THEN CONCAT('2~',v.NWATTPHY) END as VisitDischargeProviderID
	  ,CASE WHEN v.ABIO = 'I' THEN 'Inpatient'
	        WHEN v.ABIO = 'O' THEN 'Outpatient'
			WHEN v.RECTYP = 'I' THEN 'Inpatient'
			WHEN v.RECTYP = 'O' THEN 'Outpatient'
			ELSE v.RECTYP END
			as VisitType
	  ,isnull(v.SVDESC, v.HSV_DESC) as VisitService
      ,CASE WHEN v.ISADATE = '0001-01-01' THEN 'Scheduled'
			--WHEN v.ISADATE <> '0001-01-01' AND v.ISDDATE = '0001-01-01' THEN 'Admitted' 
			ELSE 'Completed' END as VisitStatus

      ,CASE WHEN v.ISADATE = '0001-01-01' THEN NULL ELSE v.ISADATE END as VisitDateOfService
	  ,CASE WHEN v.ISADATE = '0001-01-01' THEN NULL ELSE v.ISADATE END as VisitDatetimeOfService
      ,null as VisitDateOfScheduling
      ,null as VisitDateOfAppointment
      ,CASE WHEN v.ISADATE = '0001-01-01' THEN NULL ELSE v.ISADATE END as VisitDateOfAdmission
      ,CASE WHEN v.ISDDATE = '0001-01-01' THEN NULL ELSE v.ISDDATE END as VisitDateOfDischarge
      ,null as VisitDateOfClosing
      ,null as VisitDateOfCancellation
      ,null as VisitCancellationReason

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
	  ,1 as VisitIsPrimary
      ,1 as VisitIsActive
      ,getdate() AS VisitUpdatedDatetime
--select *
  FROM OPENQUERY([hmsls],'
	select
	p.RECTYP
	,p.PATNO
	,p.HSTNUM
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
	from MHD32.HOSPF100.PATIENTS p 
		LEFT JOIN MHD32.HOSPF100.ARMAST a ON a.PATNO = p.PATNO
		LEFT JOIN MHD32.HOSPF100.MRABMSTR ab ON ab.ABNUMB = a.PATNO
		LEFT JOIN MHD32.HOSPF100.MRABDIAG dx ON dx.DXNUMB = ab.ABNUMB AND dx.DXTYPE = ''P'' and dx.DXCMED = 0
			LEFT JOIN MHD32.HOSPF100.I10DIAG icdx ON icdx.DGCODE_ = dx.DXICD9 AND dx.DXCDDT between icdx.DGEFFDATE_ AND icdx.DGEXPDATE_
		LEFT JOIN (select cpt.CPNUMB, MIN(cpt.CPCPTC) AS CPCPTC, MIN(cpt.CPPSDT) AS CPPSDT
				   from MHD32.HOSPF100.MRABCPTC cpt
				   where cpt.CPSEQ# = 1 and cpt.CPCMED = ''0'' and cpt.CPCDDT >= ''2017-01-01''
				   group by cpt.CPNUMB
				  ) cpt ON cpt.CPNUMB = ab.ABNUMB 
			LEFT JOIN MHD32.HOSPF100.CPTCODE cptc ON cptc.CPTCD = cpt.CPCPTC AND cpt.CPPSDT between cptc.CPEFFD and cptc.CPTRMD
		LEFT JOIN MHD32.HOSPF100.MRABPROC prc ON prc.PRNUMB = a.PATNO AND prc.PRTYPE = ''P'' and prc.PRBSEQ# = 1 and prc.PRCMED = ''0''
			LEFT JOIN MHD32.HOSPF100.I10PROC icd ON icd.PRCODE_ = prc.PRICD9 AND prc.PRPSDT between icd.PREFFDATE_ and icd.PREXPDATE_
		LEFT JOIN MHD32.HOSPF100.STATHDV1 hsvc ON hsvc.HOSVCD = COALESCE(a.HSSVC, p.HSSVC)
		LEFT JOIN MHD32.HOSPF100.MRSERV svc ON svc.SVCODE = COALESCE(ab.ABSVCD, hsvc.MRSRV_CDE)
		LEFT JOIN ACMSHRLIBA.DRGMSDESCC drg ON drg.DRICO = 1 AND drg.DRG = ab.ABDRG
	where 1=1
	AND (CAST(a.ISADATE1 as Date) >= ''2016-01-01'' OR a.PATNO IS NULL) /*a.PATNO is null for future scheduled patients*/
	--and a.PATNO = 3044006
	--fetch first 100 rows only
	') v

/*
      SELECT  
  *
  FROM OPENQUERY([hmsls],'
	select
	*
	from MHD32.HOSPF110.MRABDIAG
	where 1=1
	and DXNUMB = 3044006
	AND DXCMED = 0
	--AND DXCDDT >= ''2017-01-01''
	--fetch first 100 rows only
	') v

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
