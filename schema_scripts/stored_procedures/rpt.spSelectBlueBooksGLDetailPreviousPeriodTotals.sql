CREATE PROCEDURE rpt.spSelectBlueBooksGLDetailPreviousPeriodTotals
	@Year int
	,@Period int
	,@Practice varchar(10)
AS
	DECLARE @PriorPeriodYear INT = CASE WHEN @PERIOD = 1 THEN 12 ELSE @Period - 1 END ;
	DECLARE @PriorPeriod INT = CASE WHEN @PERIOD = 1 THEN @Year - 1 ELSE @Year END ;
	
	SELECT a.GLAccountNumber, a.GLAccountType,SUM(l.GLTrxAmountNetChange) AS BeginningBalance
	FROM stg.vGLAccounts a
	LEFT JOIN [HPIDW].[rpt].[vGLTransactionsAll] l on a.GLAccountNumber = l.GLAccountNumber
	WHERE a.PracticeID = @Practice
		AND l.GLTrxYear = 2026
		AND l.GLTrxPeriod <= @PriorPeriod
	GROUP BY a.GLAccountNumber, a.GLAccountType
	ORDER BY a.GLAccountNumber
GO
