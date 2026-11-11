CREATE VIEW rpt.vEpicAnesthesiaConcurrency as
/*Anesthesia Charges with multiple providers for concurrency*/

SELECT 
       tdl.TX_ID as TransactionID
	  ,pt.PatientMRN as MRN
	  ,pt.PatientFullName as Patient
	  ,tdl.ORIG_SERVICE_DATE as DOS
	  ,tdl.POST_DATE as PostDate
	  ,tdl.CPT_CODE as CPT
	  ,tdl.BASE_UNITS as BaseUnits
	  ,tdl.TIMED_UNITS as TimedUnits
	  ,tdl.CRNA_CHARGE_ID as CRNATransactionID
	  ,bp.ProviderFullName as BillingProvider
	  ,bp.ProviderSuffix as BillingProviderType
	  ,tm1.ANES_DEFAULT_MOD as AnesMod1
	  ,tm2.ANES_DEFAULT_MOD as AnesMod2
	  ,tm3.ANES_DEFAULT_MOD as AnesMod3
	  ,tai.LOCKIN_PRECONC_VAL as SystemConcurrencyValue
	  ,ats.START_DATE as AnesDate
	  ,ats.START_TIME as AnesBegin
	  ,ats.END_TIME as AnesEnd
	  --,doc.LINE as AnesProviderLine
	  --,ap.ProviderFullName as AnesProvider
	  --,ap.ProviderSuffix as AnesProviderType
      --,doc_start_time as ProviderStartTime
      --,doc_end_time as ProviderEndTime
	  --,df.NAME as AnesProviderFunction

	  --,doc.*
FROM  [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].CLARITY_TDL_TRAN tdl
	  left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].TX_ANES_TIMES ats on tdl.tx_id = ats.tx_id
      --left JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].DOC_PROVIDER doc on tdl.tx_id = doc.tx_id
      --left JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_DOC_PROV_FUNC df on df.DOC_PROV_FUNC_C = doc.DOC_PROV_FUNC_C
	  LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].TX_ANES_INFO tai on tdl.TX_ID = tai.TX_ID
	  LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].dbo.ARPB_TX_DEF_ANES_MODS tm1 ON tm1.TX_ID = tdl.TX_ID AND tm1.LINE = 1
	  LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].dbo.ARPB_TX_DEF_ANES_MODS tm2 ON tm2.TX_ID = tdl.TX_ID AND tm2.LINE = 2
	  LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].dbo.ARPB_TX_DEF_ANES_MODS tm3 ON tm3.TX_ID = tdl.TX_ID AND tm3.LINE = 3
					
	 -- left join dim.vproviders ap ON ap.PROVIDERID = concat('5~',doc.DOC_PROV_ID)
	  left join dim.vproviders bp ON bp.PROVIDERID = concat('5~',tdl.BILLING_PROVIDER_ID)
	  left join dim.Patients pt ON pt.PatientID = CONCAT('5~',tdl.INT_PAT_ID)
WHERE 1=1
      and TYPE_OF_SERVICE = '7' --ANESTHESIA 
      and DETAIL_TYPE in ('1','10')
	  and tdl.ORIG_SERVICE_DATE = '2/24/2026'
      and tdl.POST_DATE between '1/1/2026' and '10/31/2026'
	  and tm1.ANES_DEFAULT_MOD IN ('QK','AD')
      --and (DOC_START_TIME is not null OR DOC_END_TIME is not null)
	  --and tdl.TX_ID in (104889631,104889693,104889633,104889694) --(106517925,106517926)-- ('104985090','104985091')
--ORDER BY
--	MRN
--	,DOS
--	,BillingProvider
--	,ats.START_TIME
--	--,TransactionID

/*

SELECT 
       tdl.TX_ID as TransactionID
	  ,pt.PatientMRN as MRN
	  ,pt.PatientFullName as Patient
	  ,tdl.ORIG_SERVICE_DATE as DOS
	  ,tdl.POST_DATE as PostDate
	  ,tdl.CPT_CODE as CPT
	  ,tdl.BASE_UNITS as BaseUnits
	  ,tdl.TIMED_UNITS as TimedUnits
	  ,tdl.CRNA_CHARGE_ID as CRNATransactionID
	  ,bp.ProviderFullName as BillingProvider
	  ,bp.ProviderSuffix as BillingProviderType
	  ,tm1.ANES_DEFAULT_MOD as AnesMod1
	  ,tm2.ANES_DEFAULT_MOD as AnesMod2
	  ,tm3.ANES_DEFAULT_MOD as AnesMod3
	  ,tai.LOCKIN_PRECONC_VAL as SystemConcurrencyValue
	  ,doc.LINE as AnesProviderLine
	  ,ap.ProviderFullName as AnesProvider
	  ,ap.ProviderSuffix as AnesProviderType
      ,doc_start_time as ProviderStartTime
      ,doc_end_time as ProviderEndTime
	  ,df.NAME as AnesProviderFunction

	  --,doc.*
FROM  [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].CLARITY_TDL_TRAN tdl
      left JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].DOC_PROVIDER doc on tdl.tx_id = doc.tx_id
      left JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_DOC_PROV_FUNC df on df.DOC_PROV_FUNC_C = doc.DOC_PROV_FUNC_C
	  LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].TX_ANES_INFO tai on tdl.TX_ID = tai.TX_ID
	  LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].dbo.ARPB_TX_DEF_ANES_MODS tm1 ON tm1.TX_ID = tdl.TX_ID AND tm1.LINE = 1
	  LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].dbo.ARPB_TX_DEF_ANES_MODS tm2 ON tm2.TX_ID = tdl.TX_ID AND tm2.LINE = 2
	  LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].dbo.ARPB_TX_DEF_ANES_MODS tm3 ON tm3.TX_ID = tdl.TX_ID AND tm3.LINE = 3
					
	  left join dim.vproviders ap ON ap.PROVIDERID = concat('5~',doc.DOC_PROV_ID)
	  left join dim.vproviders bp ON bp.PROVIDERID = concat('5~',tdl.BILLING_PROVIDER_ID)
	  left join dim.Patients pt ON pt.PatientID = CONCAT('5~',tdl.INT_PAT_ID)
WHERE 1=1
      and TYPE_OF_SERVICE = '7' --ANESTHESIA 
      and DETAIL_TYPE in ('1','10')
	  and tdl.ORIG_SERVICE_DATE = '5/8/2026'
      and tdl.POST_DATE between '1/1/2026' and '10/31/2026'
      --and (DOC_START_TIME is not null OR DOC_END_TIME is not null)
	  --and tdl.TX_ID in (104889631,104889693,104889633,104889694) --(106517925,106517926)-- ('104985090','104985091')
ORDER BY
	MRN
	,DOS
	,TransactionID
	,AnesProviderLine
*/
GO
