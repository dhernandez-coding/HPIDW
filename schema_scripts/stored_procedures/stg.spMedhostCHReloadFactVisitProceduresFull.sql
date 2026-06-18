CREATE procedure [stg].[spMedhostCHReloadFactVisitProceduresFull] AS 

	DELETE FROM fact.VisitProcedures WHERE VisitProcedureDataSourceID = 8

	INSERT INTO fact.VisitProcedures
	(
	 [VisitProcedureID]
      ,[VisitProcedureDataSourceID]
      ,[VisitProcedureSourceID]
      ,[VisitProcedureVisitID]
      ,[VisitProcedureAccountID]
      ,[VisitProcedureType]
      ,[VisitProcedureSequence]
      ,[VisitProcedureCodeType]
      ,[VisitProcedureCode]
      ,[VisitProcedureDescription]
      ,[VisitProcedureMod1]
      ,[VisitProcedureMod2]
      ,[VisitProcedureMod3]
      ,[VisitProcedureMod4]
      ,[VisitProcedureProviderID]
      ,[VisitProcedureDate]
      ,[VisitProcedureIsPrimary]
      ,[VisitProcedureIsActive]
      ,[VisitProcedureUpdatedDatetime]
	)
	SELECT 
	CONCAT('8~',v.PRNUMB,'~ICD10~',v.PRTYPE,'~',v.PRBSEQ#,'~',v.PRICD9) as  VisitProcedureID 
	,8 as VisitProcedureDataSourceID 
	,CONCAT(v.PRNUMB,'~',v.PRTYPE,'~',v.PRBSEQ#,'~',v.PRICD9) as VisitProcedureSourceID 
	,CONCAT('8~',v.PRNUMB) as VisitProcedureVisitID 
	,CONCAT('8~',v.PRNUMB) as VisitProcedureAccountID 
	,CASE WHEN v.PRTYPE = 'P' THEN 'Principal' 
		  WHEN v.PRTYPE = 'S' THEN 'Secondary'
		  ELSE v.PRTYPE END as VisitProcedureType 
	,v.PRBSEQ# as VisitProcedureSequence 
	,'ICD10' as VisitProcedureCodeType 
	,v.PRICD9 as VisitProcedureCode 
	,v.PRDESC_ VisitProcedureDescription 
	,null as VisitProcedureMod1 
	,null as VisitProcedureMod2
	,null as VisitProcedureMod3 
	,null as VisitProcedureMod4 
	,CONCAT('8~',v.PRDOCN) as VisitProcedureProviderID 
	,v.PRPSDT as VisitProcedureDate 
	,CASE WHEN v.PRTYPE = 'P' and v.PRBSEQ# = 1 THEN 1 ELSE 0 END as VisitProcedureIsPrimary
	,1 as VisitProcedureIsActive 
	,getdate() as VisitProcedureUpdatedDatetime
  --select * 
  FROM OPENQUERY([hmsls],'
	select
	prc.PRNUMB
	,prc.PRTYPE
	,prc.PRDOCN
	,prc.PRICD9
	,icd.PRDESC_
	,prc.PRPSDT
	,prc.PRBSEQ#
	--prc.*
	from MHD32.HOSPF110.MRABPROC prc 
			LEFT JOIN MHD32.HOSPF110.I10PROC icd ON icd.PRCODE_ = prc.PRICD9 AND prc.PRPSDT between icd.PREFFDATE_ and icd.PREXPDATE_
	where 1=1
		AND prc.PRCMED = 0
		AND prc.PRPSDT >= ''2016-01-01''
		--AND prc.PRTYPE = ''P''
		--AND prc.PRNUMB = 3042010
	--fetch first 100 rows only
	') v

	UNION ALL

	SELECT 
	CONCAT('8~',v.CPNUMB,'~CPT~',v.CPSEQ#,'~',v.CPSEQ#,'~',v.CPCPTC,'~',v.CPPSDT) as  VisitProcedureID 
	,8 as VisitProcedureDataSourceID 
	,CONCAT(v.CPNUMB,'~CPT~',v.CPSEQ#,'~',v.CPSEQ#,'~',v.CPCPTC,'~',v.CPPSDT) as VisitProcedureSourceID 
	,CONCAT('8~',v.CPNUMB) as VisitProcedureVisitID 
	,CONCAT('8~',v.CPNUMB) as VisitProcedureAccountID 
	,CASE WHEN v.CPSEQ# = 1 THEN 'Principal' 
		  ELSE 'Secondary'
		  END as VisitProcedureType 
	,v.CPSEQ# as VisitProcedureSequence 
	,'CPT' as VisitProcedureCodeType 
	,v.CPCPTC as VisitProcedureCode 
	,v.CDESC VisitProcedureDescription 
	,null as VisitProcedureMod1 
	,null as VisitProcedureMod2
	,null as VisitProcedureMod3 
	,null as VisitProcedureMod4 
	,null as VisitProcedureProviderID 
	,v.CPPSDT as VisitProcedureDate 
	,CASE WHEN v.CPSEQ# = 1 THEN 1 ELSE 0 END as VisitProcedureIsPrimary
	,1 as VisitProcedureIsActive 
	,getdate() as VisitProcedureUpdatedDatetime
  --select * 
  FROM OPENQUERY([hmsls],'
	select 
	cpt.CPNUMB
	,cpt.CPCPTC
	,cpt.CPPSDT
	,cpt.CPSEQ#
	,cpt.CPMOD1
	,cpt.CPMOD2
	,cpt.CPMOD3
	,cpt.CPMOD4
	,cptc.CDESC
	--cpt.*
	from MHD32.HOSPF110.MRABCPTC cpt
		LEFT JOIN MHD32.HOSPF110.CPTCODE cptc ON cptc.CPTCD = cpt.CPCPTC AND cpt.CPPSDT between cptc.CPEFFD and cptc.CPTRMD
	where 1=1
		AND cpt.CPCMED = ''0'' 
		AND cpt.CPPSDT >= ''2016-01-01''
		--AND cpt.CPNUMB = 3051067
	--fetch first 100 rows only
	') v
	GROUP BY 
	v.CPNUMB
	,v.CPCPTC
	,v.CPPSDT
	,v.CPSEQ#
	,v.CPMOD1
	,v.CPMOD2
	,v.CPMOD3
	,v.CPMOD4
	,v.CDESC
GO
