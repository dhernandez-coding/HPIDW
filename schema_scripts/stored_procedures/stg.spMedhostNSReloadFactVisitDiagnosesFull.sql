CREATE PROCEDURE [stg].[spMedhostNSReloadFactVisitDiagnosesFull] as
  
  DELETE FROM fact.VisitDiagnoses WHERE VisitDiagnosisDataSourceID = 2

  INSERT INTO fact.VisitDiagnoses
  SELECT 
	CONCAT('2~',v.DXNUMB,'~',v.DXTYPE,'~',v.DXSEQ#,'~',v.DXCMED,'~',v.DXICD9) AS VisitDiagnosisID
	,2 as VisitDiagnosisDataSourceID
	,CONCAT(v.DXNUMB,'~',v.DXTYPE,'~',v.DXSEQ#,'~',v.DXCMED,'~',v.DXICD9) as VisitDiagnosisSourceID
	,CONCAT('2~',v.DXNUMB) as VisitDiagnosisVisitID
	,CONCAT('2~',v.DXNUMB) as VisitDiagnosisAccountID
	,CASE WHEN v.DXTYPE = 'P' THEN 'Principal'
		  WHEN v.DXTYPE = 'A' THEN 'Admitting'
		  WHEN v.DXTYPE = 'S' THEN 'Secondary'
		  ELSE v.DXTYPE END as VisitDiagnosisType
	,v.DXSEQ# as VisitDiagnosisSequence
	,'ICD10' AS VisitDiagnosisCodeType
	,v.DXICD9 as VisitDiagnosisCode
	,v.DGDESC_ as VisitDiagnosisCodeDescription
	,v.DXCDDT as VisitDiagnosisDate
	,CASE WHEN v.DXTYPE = 'P' and v.DXSEQ# = 1 THEN 1 ELSE 0 END as VisitDiagnosisIsPrimary
	,1 as VisitDiagnosisIsActive
	,getdate() as VisitDiagnosisUpdatedDatetime
  FROM OPENQUERY([hmsls],'
	select
	dx.DXNUMB
	,dx.DXTYPE
	,dx.DXSEQ#
	,dx.DXICD9
	,icd.DGDESC_
	,dx.DXADMT
	,dx.DXCMED
	,dx.DXCDDT
	--dx.*
	from MHD32.HOSPF100.MRABDIAG dx
		LEFT JOIN MHD32.HOSPF100.I10DIAG icd ON icd.DGCODE_ = dx.DXICD9 
											AND dx.DXCDDT between icd.DGEFFDATE_ AND icd.DGEXPDATE_
	where 1=1
		AND dx.DXCMED = ''0''
		AND dx.DXCDDT >= ''2016-01-01'' 
		--AND dx.DXNUMB = 3092211
	--fetch first 100 rows only
	') v
GO
