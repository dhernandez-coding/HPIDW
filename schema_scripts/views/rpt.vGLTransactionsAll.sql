CREATE VIEW rpt.vGLTransactionsAll AS
-- ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
-- view_Posted_GL_Trx
-- Returns all lines for posted GL transactions
-- Excludes year-end closing entries
-- Returns Functional amounts only
--   GL20000 - Open Year Trx
--   GL30000 - Historical Trx
--   GL00100 - Account Master
--   GL00102 - Account Categories
--   GL00105 - Account Index Master
-- ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

/*
Change Control:
	1. 09/22/2026 - Chris Cross - Created View
	2.
*/
 
SELECT
	gl.YEAR1 AS GLTrxYear --Trx_Year,
	, gl.PERIODID as GLTrxPeriod
	, CONCAT(gl.YEAR1,'-',RIGHT(CONCAT('00',gl.PERIODID),2)) as GLTrxYearPeriod
	, gl.TRXDATE AS GLTrxDate --Trx_Date,
	, gl.JRNENTRY AS GLTrxJournalEntry -- Journal_Entry,
	, gl.ORTRXSRC AS GLTrxOriginSource -- Originating_TRX_Source,
	, gl.REFRENCE AS GLTrxReference -- Reference,
	, gl.ORMSTRID AS GLTrxOriginMasterID -- Originating_Master_ID,
	, gl.ORMSTRNM AS GLTrxOriginMasterName -- Originating_Master_Name,
	, gl.ORDOCNUM AS GLTrxOriginDocNumber -- Originating_Doc_Number,
	, gl.DEBITAMT AS GLTrxAmountDebit -- Debit_Amount,
	, gl.CRDTAMNT AS GLTrxAmountCredit -- Credit_Amount,
	, convert(decimal(18,2),(gl.DEBITAMT-gl.CRDTAMNT)) as GLTrxAmountNetChange
	, gl.USWHPSTD AS GLTrxPostingUser -- User_Who_Posted
	, a.GLAccountSourceID 
	, a.GLAccountNumber
	, a.GLAccountName 
	, a.GLAccountDescriptionID 
	, a.GLAccountDescription 
	, a.GLAccountTypeID
	, a.GLAccountType
	, a.GLAccountLocationID
	, a.GLAccountLocation
	, a.GLAccountPracticeID 
	, a.GLAccountPractice 
	, a.GLAccountProviderID 
	, a.GLAccountProvider
	, a.PracticeID
	, a.GLAccountReportType
	, a.GLAccountBalanceType
	, a.GLAccountPostingType
	,CASE WHEN left(a.GLAccountNumber,1) = 4 THEN 'Revenue'
	      WHEN left(a.GLAccountNumber,1) = 5 THEN 'Expenses'
	  END as GLAccountGroup
	, a.GLAccountCategory
	, a.GLAccountReportGroupLevel1
	, a.GLAccountReportGroupLevel2
	, a.GLAccountReportGroupLevel3
	, GETDATE() as AsOfDate

FROM
	(select 
		ot.ACTINDX
		, ot.OPENYEAR YEAR1
		, ot.PERIODID
		, ot.TRXDATE
		, ot.JRNENTRY
		, ot.ORTRXSRC
		, ot.REFRENCE
		, ot.ORDOCNUM
		, ot.ORMSTRID
		, ot.ORMSTRNM
		, ot.DEBITAMT
		, ot.CRDTAMNT
		, ot.CURNCYID
		, ot.USWHPSTD
	 from CORVMAP22.TPG.dbo.GL20000 ot
	 where 1=1
		AND ot.SOURCDOC not in ('BBF','P/L') 
		AND ot.VOIDED = 0
 
	 union all
 
	 select 
		ht.ACTINDX
		, ht.HSTYEAR YEAR1
		, ht.PERIODID 
		, ht.TRXDATE
		, ht.JRNENTRY
		, ht.ORTRXSRC
		, ht.REFRENCE
		, ht.ORDOCNUM
		, ht.ORMSTRID
		, ht.ORMSTRNM
		, ht.DEBITAMT
		, ht.CRDTAMNT
		, ht.CURNCYID
		, ht.USWHPSTD
	 from CORVMAP22.TPG.dbo.GL30000 ht
	 where 1=1
		AND ht.SOURCDOC not in ('BBF','P/L') 
		AND ht.VOIDED = 0
		--AND ht.HSTYEAR >= YEAR(getdate()) - 2
	) gl
	LEFT JOIN stg.vGLAccounts a ON a.GLAccountSourceID = CAST(gl.ACTINDX as VARCHAR(100))
	LEFT JOIN dim.Practices p ON p.PracticeID = a.PracticeID
	--inner join CORVMAP22.TPG.dbo.GL00105 GM ON GL.ACTINDX = GM.ACTINDX
	--inner join CORVMAP22.TPG.dbo.GL00100 GA ON GL.ACTINDX = GA.ACTINDX
	--inner join CORVMAP22.TPG.dbo.GL00102 C  ON GA.ACCATNUM = C.ACCATNUM
WHERE 1=1
GO
