Create Procedure ETLUnmappedProcedureCodes
as


insert into HPIApp.dbo.[UnmappedPBProcedureCodes]
  select 
  (0-ROW_NUMBER() OVER (ORDER BY ttt.TransactionCPTCode)) AS Id, --negatify the id, this will be used by the app to differentiate between the mapped and unmapped
ttt.TransactionCPTCode as ProcedureCode
,0 as RVU-- there arent any cpt code records for these so default to 0
,'' as CPTDescription-- there arent any cpt code records for these so default to ''
,GETDATE() as EffectiveStartDate-- Not tracking, but added value
, DATEADD(YEAR, 2099 - YEAR(GETDATE()), GETDATE()) as EffectiveEndDate --Not tracking, but added value
,0 as ProcedureCodePriority -- default to 0 priority
,CasT(0 as bit) as IsDeleted
,ttt.TransactionCPTCode as UnmappedProcedureCode	
	,count(1) as ChargeCount
	,sum(t.TransactionAmount) as TotalCharges
	,max(t.TransactionDateOfPosting) as LastPostDate	
,CasT(0 as bit) as ProcedureCodeIsLocationDependent -- default to 0
 ,CasT(0 as bit) as ProcedureCodeInPlay -- default to 0
,CasT(0 as bit) as ProcedureCodeTHPLab -- default to 0
	,null as ProcedureCodeCategoryId
	,null as ProcedureCodeServiceLineId
	,null as ProcedureCodeDHSCategoryId
 
  from
  (Select Distinct TransactionCPTCode as TransactionCPTCode from HPIDW.fact.TransactionsPB where TransactionCPTCode not in (select ProcedureCode from HPIApp.dbo.PBProcedureCodes)) as ttt
  left join HPIDW.fact.TransactionsPB t on ttt.TransactionCPTCode =  t.TransactionCPTCode
   where
  1=1
    GROUP BY
	ttt.TransactionCPTCode
GO
