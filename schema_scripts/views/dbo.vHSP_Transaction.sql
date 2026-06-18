Create View vHSP_Transaction as

select 
	t.HSP_ACCOUNT_ID
	,SUM(t.TX_AMOUNT) Charges
from [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].HSP_TRANSACTIONS t
where 1=1
	AND t.SERV_AREA_ID in (425,430)
	AND t.TX_TYPE_HA_C = 1 /*Charges*/
	AND LEFT(t.UB_REV_CODE_ID,2) IN (36,48,49,75,76)
group by t.HSP_ACCOUNT_ID
GO
