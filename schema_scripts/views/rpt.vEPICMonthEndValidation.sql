CREATE VIEW [rpt].[vEPICMonthEndValidation] as

select 
	t.DEPT_ID
	,dep.DEPARTMENT_NAME
	,sum(t.AMOUNT) as Payments
	,sum(t.ACTIVE_AR_AMOUNT) as ActiveARAmount
	,sum(t.BAD_DEBT_AR_AMOUNT) AS BadDebtAmount
	,CONCAT(YEAR(t.post_date),' - ', RIGHT(concat('00',MONTH(t.post_date)),2)) as ReportingPeriod
	--select dep.DEPARTMENT_NAME,t.DETAIL_TYPE, dt.NAME, t.AMOUNT, t.ACTIVE_AR_AMOUNT,t.*
from [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].CLARITY_TDL_TRAN t 
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].CLARITY_DEP dep ON dep.DEPARTMENT_ID = t.DEPT_ID
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].ZC_DETAIL_TYPE dt ON dt.DETAIL_TYPE = t.DETAIL_TYPE
where 1=1 --and t.DEPT_ID = 43004001017 --43005005003
	and t.DEPT_ID NOT IN ('43002001001','43001006001','43001007001', '43001008001')
	and t.SERV_AREA_ID IN (425,430)
	and dep.DEPARTMENT_NAME like ('HPIP%') or dep.DEPARTMENT_NAME like ('TPG%')
	--and t.post_date >= '5/1/2024' and t.post_date < '6/1/2024'
	and t.DETAIL_TYPE IN (2,5,11,20,22,32,33) --order by t.amount
group by 
	t.DEPT_ID
	,t.post_date
	,dep.DEPARTMENT_NAME
	,t.DETAIL_TYPE
GO
