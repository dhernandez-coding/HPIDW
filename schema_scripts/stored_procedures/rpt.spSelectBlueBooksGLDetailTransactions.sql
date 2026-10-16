CREATE PROCEDURE rpt.spSelectBlueBooksGLDetailTransactions
	@Year int
	,@Period int
	,@Practice varchar(10)
AS

SELECT 
	a.GLAccountNumber, 
	a.GLAccountType, 
	l.GLTrxDate,
	l.GLTrxJournalEntry,
	l.GLTrxOriginSource,
	l.GLTrxReference, 
	l.GLTrxOriginMasterID, 
	l.GLTrxOriginMasterName, 
	l.GLTrxAmountNetChange,
	l.GLTrxAmountDebit, 
	l.GLTrxAmountCredit
FROM stg.vGLAccounts a
JOIN [HPIDW].[rpt].[vGLTransactionsAll] l on a.GLAccountNumber = l.GLAccountNumber AND l.GLTrxYear = @Year AND l.GLTrxPeriod = @Period
WHERE a.PracticeID = @Practice
Order By a.GLAccountNumber, l.GLTrxDate
GO
