CREATE VIEW [rpt].[vGLTransactionsCurrentYear] as 

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
	--and (g.YEAR1 < @CurrentYear --(select min(YEAR1) from GL11110)
	--	OR g.YEAR1 = @CurrentYear AND g.PERIODID <= @CurrentPeriod) /*Include all unclosed years up to current period*/
	--and g.PSTNGTYP = 1 /* 1 - Profit and Loss, 0 - Balance Sheet */ 
	and g.ACTNUMBR_4 NOT IN ('046') /*Exclude Robert Glade activity..Robert Spender is now RSG*/
	--and (@Practice = '0' /*0 - All*/ OR s4.DSCRIPTN = @Practice)

/* ---Run this for actual GL Detail 

SELECT 
    GL.TrxDate,          -- Transaction date
    a.GLAccountNumber,     -- Account identifier
	a.GLAccountName,
	 GL.DebitAmt,
	  GL.CRDTAMNT,-- Transaction amount
	   GL.TrxDate,
	   gl.ORPSTDDT,

	gl.*
FROM 
    CORVMAP22.TPG.dbo.GL20000 AS GL        -- General Ledger transaction table
	left join stg.vGLAccounts a ON a.GLAccountSourceID = gl.ACTINDX
	left join dim.vProviders prv ON prv.ProviderDataSourceID = 10 AND prv.ProviderSourceID = a.GLAccountReportingProvider
WHERE 
    GL.TrxDate BETWEEN '2024-09-01' AND '2024-09-30'  -- Adjust the date range as needed
	and prv.ProviderID = '10~Default'
	and left(a.GLAccountNumber,1) = 4 
ORDER BY 
    GL.TrxDate;         -- Optionally, order by transaction date
	*/
GO
