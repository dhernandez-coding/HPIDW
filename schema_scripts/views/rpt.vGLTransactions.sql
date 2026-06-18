CREATE VIEW [rpt].[vGLTransactions] as 

select 
g.Year1 as GLYear
,g.PeriodID as GLPeriod
,g.CREATDDT as GLCreatedDate
,g.DEBITAMT as GLDebits
,g.CRDTAMNT as GLCredits
,convert(decimal(18,2),(g.DEBITAMT-g.CRDTAMNT)) as GLNetChange
,CASE WHEN left(a.GLAccountNumber,1) = 4 THEN 'Revenue'
	   WHEN left(a.GLAccountNumber,1) = 5 THEN 'Expenses'
 END as GLAccountGroup
,a.*
,GETDATE() as AsOfDatetime
from CORVMAP22.TPG.dbo.GL11110 g  --GL
	left join CORVMAP22.TPG.dbo.GL40200 s4 ON s4.SGMNTID = g.ACTNUMBR_4 AND s4.SGMTNUMB = 4
	left join stg.vGLAccounts a ON a.GLAccountSourceID = g.ACTINDX
where 1=1
	and g.ACCTTYPE = 1
	and g.PSTNGTYP = 1
	--and (g.YEAR1 < @CurrentYear --(select min(YEAR1) from GL11110)
	--	OR g.YEAR1 = @CurrentYear AND g.PERIODID <= @CurrentPeriod) /*Include all unclosed years up to current period*/
	--and g.PSTNGTYP = 1 /* 1 - Profit and Loss, 0 - Balance Sheet */ 
	and g.ACTNUMBR_4 NOT IN ('046') /*Exclude Robert Glade activity..Robert Spender is now RSG*/
	--and (@Practice = '0' /*0 - All*/ OR s4.DSCRIPTN = @Practice)

UNION ALL 

select 
g.Year1 as GLYear
,g.PeriodID as GLPeriod
,g.CREATDDT as GLCreatedDate
,g.DEBITAMT as GLDebits
,g.CRDTAMNT as GLCredits
,convert(decimal(18,2),(g.DEBITAMT-g.CRDTAMNT)) as GLNetChange
,CASE WHEN left(a.GLAccountNumber,1) = 4 THEN 'Revenue'
	   WHEN left(a.GLAccountNumber,1) = 5 THEN 'Expenses'
 END as GLAccountGroup
,a.*
,GETDATE() as AsOfDatetime
from CORVMAP22.TPG.dbo.GL11111 g  --GL
	left join CORVMAP22.TPG.dbo.GL40200 s4 ON s4.SGMNTID = g.ACTNUMBR_4 AND s4.SGMTNUMB = 4
	left join stg.vGLAccounts a ON a.GLAccountSourceID = g.ACTINDX
where 1=1
	and g.ACCTTYPE = 1
	and g.YEAR1 >= 2024
	and g.PSTNGTYP = 1
	--	OR g.YEAR1 = @CurrentYear AND g.PERIODID <= @CurrentPeriod) /*Include all unclosed years up to current period*/
	--and g.PSTNGTYP = 1 /* 1 - Profit and Loss, 0 - Balance Sheet */ 
	and g.ACTNUMBR_4 NOT IN ('046') /*Exclude Robert Glade activity..Robert Spender is now RSG*/
	--and (@Practice = '0' /*0 - All*/ OR s4.DSCRIPTN = @Practice)
GO
