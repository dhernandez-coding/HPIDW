CREATE VIEW [rpt].[vAPMSelfPayBalance] as


--WITH CTE_Account AS (
SELECT
	sub.Account_ID
	,sub.Department_Abbr
	,sub.Voucher_Reporting_Period
	,pp.PracticeName
FROM 
	(
		SELECT 
			v.Account_ID
			,v.Voucher_Number
			,v.Department_Abbr
			,v.Voucher_Reporting_Period
			,p.PracticeID
		FROM [TIEVMDB03].[Ntier_627200].[PM].[vwGenVouchInfo]  v
			LEFT JOIN map.Providers p ON p.ProviderID = CONCAT('1~', v.Billing_Dr_ID)  
		WHERE Voucher_Balance > 5 AND v.Voucher_Reporting_Period IS NOT NULL AND p.PracticeID IS NOT NULL  --AND Department_Abbr <> 'HPIP' --and Account_ID = 662141
		GROUP BY
			v.Account_ID
			,v.Voucher_Number
			,v.Department_Abbr
			,v.Voucher_Reporting_Period
			,p.PracticeID
			) sub
	LEFT JOIN dim.vPractices pp on pp.PracticeID = sub.PracticeID
GROUP BY
	sub.Account_ID
	,sub.Department_Abbr
	,sub.Voucher_Reporting_Period
	,pp.PracticeName
--	)

--SELECT
--	s.Account_ID AS SelfPayAccountID
--	,CONCAT(YEAR(s.Statement_Date),' - ', RIGHT(CONCAT('00',MONTH(s.Statement_Date)),2)) SelfPayReportingPeriod
--	,COUNT(s.Account_ID) AS SelfPayStatementCount
--	,a.PracticeID AS SelfPayPracticeID
--FROM [TIEVMDB03].[Ntier_627200].[PM].[vwStmtAuditInfo] s
--	LEFT JOIN CTE_Account a on a.Account_ID = s.Account_ID AND s.Department_Abbreviation = a.Department_Abbr
--WHERE s.Statement_Date >= '2024-01-01' and s.Amount > 5 and a.PracticeID is not null and s.Department_Abbreviation <> 'HPIP'
--GROUP BY
--	s.Account_ID
--	,s.Statement_Date
--	,a.PracticeID


--GO



--SELECT
--	s.Department_Abbreviation
--	,s.Account_ID
--	,s.Bypassed_Due_To
--	,s.Statement_Date
--	,Count(s.Account_ID) as Count
--FROM [TIEVMDB03].[Ntier_627200].[PM].[vwStmtAuditInfo] s
--where  amount >= 5 and division_abbreviation <> 'HPI' and s.Statement_Date between '2025-03-01' and '2025-03-31' --and Department_Abbreviation <> 'HPIP'
--GROUP BY
--	s.Department_Abbreviation
--	,s.Bypassed_Due_To
--	,s.Statement_Date
--	,s.Account_ID


--SELECT
--	*
--FROM [TIEVMDB03].[Ntier_627200].[PM].[vwGenVouchInfo] 
----where Statement_Date between '2025-03-01' and '2025-03-31' 
----and Department_Abbreviation = 'FBL' and Amount > 0


--SELECT
--	Count(Account_ID) as Count
--FROM [TIEVMDB03].[Ntier_627200].[PM].[vwStmtAuditInfo]
--where Statement_Date between '2025-03-01' and '2025-03-31'

--SELECT
--	*
--FROM [TIEVMDB03].[Ntier_627200].[PM].Statement_History
--where Statement_Date between '2025-03-01' and '2025-03-31'


--vw_LastStatementActivity
--vw_LastStatementInformation

--Statement_History
--vw_LastStatementInformation

--select 
--*
--from [TIEVMDB03].[Ntier_627200].[PM].[vwStmtAuditInfo]
--where Statement_Date between '2025-03-01' and '2025-03-31'
--and
--division_abbreviation = 'HPI'
GO
