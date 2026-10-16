CREATE PROCEDURE rpt.spSelectBlueBooksGLDetailPreviousPeriodTotals
	@Year int
	,@Period int
	,@Practice varchar(10)
AS
	DECLARE @PriorPeriod INT = CASE WHEN @PERIOD = 1 THEN 12 ELSE @Period - 1 END ;
	DECLARE @PriorPeriodYear INT = CASE WHEN @PERIOD = 1 THEN @Year - 1 ELSE @Year END ;
	WITH PriorPeriod AS (
		SELECT a.GLAccountNumber, a.GLAccountType, SUM(l.GLTrxAmountNetChange) AS BeginningBalance
		FROM stg.vGLAccounts a
		LEFT JOIN [HPIDW].[rpt].[vGLTransactionsAll] l on a.GLAccountNumber = l.GLAccountNumber AND l.GLTrxYear = @PriorPeriodYear AND l.GLTrxPeriod <= @PriorPeriod
		WHERE a.PracticeID = @Practice
		GROUP BY a.GLAccountNumber, a.GLAccountType
	),
	CurrentPeriod AS (
		SELECT a.GLAccountNumber, a.GLAccountType, SUM(l.GLTrxAmountNetChange) AS EndingBalance
		FROM stg.vGLAccounts a
		LEFT JOIN [HPIDW].[rpt].[vGLTransactionsAll] l on a.GLAccountNumber = l.GLAccountNumber AND l.GLTrxYear = @Year AND l.GLTrxPeriod <= @Period
		WHERE a.PracticeID = @Practice
		GROUP BY a.GLAccountNumber, a.GLAccountType
	)
	,PeriodOnlyTotals AS (
		SELECT a.GLAccountNumber, a.GLAccountType, SUM(l.GLTrxAmountDebit) AS TotalDebit, SUM(l.GLTrxAmountCredit) AS TotalCredit
		FROM stg.vGLAccounts a
		LEFT JOIN [HPIDW].[rpt].[vGLTransactionsAll] l on a.GLAccountNumber = l.GLAccountNumber AND l.GLTrxYear = @Year AND l.GLTrxPeriod = @Period
		WHERE a.PracticeID = @Practice
		GROUP BY a.GLAccountNumber, a.GLAccountType
	)
	Select a.GLAccountNumber, a.GLAccountName, a.GLAccountType, p.BeginningBalance, c.EndingBalance, (c.EndingBalance-p.BeginningBalance) as NetChange, po.TotalDebit, po.TotalCredit
	FROM stg.vGLAccounts a 
	LEFT JOIN PriorPeriod p on a.GLAccountNumber = p.GLAccountNumber
	LEFT JOIN CurrentPeriod c on a.GLAccountNumber = c.GLAccountNumber
	LEFT JOIN PeriodOnlyTotals po on a.GLAccountNumber = po.GLAccountNumber
	WHERE a.PracticeID = @Practice
GO
