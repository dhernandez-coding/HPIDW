CREATE PROCEDURE [rpt].[spSelectBlueBookCarryForward] AS
SELECT
	sub.FiscalYear
	,sub.FiscalPeriod
	,FORMAT(DATEFROMPARTS(sub.FiscalYear,sub.FiscalPeriod,1),'MMM-yy') as FiscalYearPeriod
	,sub.PracticeID
	,NULL as ReportingProviderID
	,'Cash' as ReportSection
	,'Physician Draws' as ReportGroupLevel1
	,CASE WHEN sub.GLAccountDescriptionID = '3003' THEN '401K Contributions'
		  WHEN sub.GLAccountDescriptionID = '3004' THEN 'Payroll Set Asides'
		  WHEN sub.GLAccountDescriptionID = '3010' THEN 'General Set Asides'
		  WHEN sub.GLAccountDescriptionID = '3001' THEN 'Physician Draws'
		  END as ReportGroupLevel2
 	--,sub.GLAccountDescription
	,SUM(CASE WHEN SUB.GLAccountDescriptionID = '3003' THEN sub.FiscalPeriodValue * -1 ELSE sub.FiscalPeriodValue END) as FiscalPeriodValue
	
FROM 
	(
	  select 
	  t.ACTINDX
	  ,a.GLAccountDescriptionID
	  ,a.GLAccountDescription
	  ,a.GLAccountNumber
	  ,a.GLAccountName
	  ,a.GLAccountPracticeID
	  ,p.PracticeID
	  ,p.PracticeName
	  ,t.OPENYEAR as FiscalYear
	  ,t.PERIODID as FiscalPeriod
	  ,t.REFRENCE as TransactionReference
	  ,t.DSCRIPTN as TransactionDescription
	  ,t.DEBITAMT as FiscalPeriodDebits
	  ,t.CRDTAMNT as FiscalPeriodCredits
	  ,t.DEBITAMT - T.CRDTAMNT as FiscalPeriodValue
	  --,* 
	  from CORVMAP22.TPG.dbo.GL20000 t 
		left join stg.vGLAccounts a ON a.GLAccountSourceID = t.ACTINDX
		left join dim.Practices p ON p.PracticeSourceID = a.GLAccountPractice
	  where 1=1
	  --AND a.GLAccountDescriptionID like '3%'
	  --AND t.REFRENCE like '%EOM ALLOC%'
	  AND a.GLAccountDescriptionID in ('3001','3003','3004','3010')
	  AND t.PERIODID <> 0
	  AND t.PERIODID = 8
	  AND t.VOIDED = 0
	  --AND p.PracticeSourceID = 'PBJ'
	) sub
GROUP BY 
	sub.FiscalYear
	,sub.FiscalPeriod
	,sub.PracticeID
	,sub.GLAccountDescriptionID
	,sub.GLAccountDescription
GO
