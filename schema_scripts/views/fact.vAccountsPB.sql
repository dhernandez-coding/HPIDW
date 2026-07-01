CREATE VIEW  [fact].[vAccountsPB]
AS
SELECT  a.AccountID, 
		a.AccountDataSourceID,
		ds.DataSourceName AS AccountDataSource, 
		a.AccountSourceID, 
		a.AccountReferenceNumber, 
		a.AccountPatientID, 
		a.AccountLocationID, 
		a.AccountDepartmentID, 
        pt.PracticeID AS AccountPracticeID, 
		a.AccountFinancialClassID, 
		a.AccountPrimaryPayerID,
		a.AccountPrimaryPayerPlanID, 
		pp.PayerPlanName AS AccountPrimaryPayerPlan, 
		a.AccountPrimaryProviderID, 
        a.AccountAdmittingProviderID, 
		a.AccountAttendingProviderID, 
		a.AccountReferringProviderID, 
		a.AccountDateOfService, 
		a.AccountDateOfBilling, 
		a.AccountDateOfClosing AS AccountDateOfPosting, DATEADD(DAY, 1, 
        EOMONTH(a.AccountDateOfClosing, - 1)) AS AccountReportingPeriod, 
		a.AccountDateOfZeroBalance, 
		a.AccountDateOfBadDebtWriteOff, 
		a.AccountTotalCharges, 
		a.AccountTotalAdjustments, 
		a.AccountTotalPayments, 
        a.AccountTotalRefunds, 
		a.AccountTotalBalance, 
		SPB.SelfPayBalance as AccountSelfPayBalance,
		a.AccountStatus, 
		a.AccountIsRecurring, 
		CASE WHEN a.AccountTotalCharges > 0 AND a.AccountTotalBalance <= 10 THEN 'Yes' ELSE 'No' END AS AccountIsMostlyAdjudicated, 
        CASE WHEN a.AccountTotalBalance = 0 THEN 'Yes' ELSE 'No' END AS AccountIsZeroBalance,
		CASE WHEN a.AccountDataSourceID IN (2, 8) THEN 'No' WHEN a.AccountDataSourceID = 5 AND 
        a.AccountSourceID LIKE '6%' THEN 'No' ELSE 'Yes' END AS AccountIsClinical, 
		a.AccountIsActive, 
		a.AccountUpdatedDatetime, 
		a.AccountEmployerName 

FROM  fact.Accounts AS a 
		LEFT OUTER JOIN dim.PayerPlans AS pp ON pp.PayerPlanID = a.AccountPrimaryPayerPlanID 
		LEFT OUTER JOIN dim.DataSources AS ds ON ds.DataSourceID = a.AccountDataSourceID 
		LEFT OUTER JOIN map.PracticeDepartments AS pd ON pd.DepartmentID = a.AccountDepartmentID 
		LEFT OUTER JOIN map.vPracticeProviders AS pp2 ON pp2.ProviderID = a.AccountPrimaryProviderID AND pp2.PracticeProviderEffectiveDate <= a.AccountDateOfClosing AND 
                         pp2.PracticeProviderEndDate >= a.AccountDateOfClosing 
		LEFT OUTER JOIN dim.vPractices AS pt ON pt.PracticeID = COALESCE (pd.PracticeID, pp2.PracticeID)
		LEFT OUTER JOIN (SELECT
							CONCAT('1~',ca.Voucher_Number) as VoucherNumber,
							sum(ca.Self_Pay_Balance) SelfPayBalance
						FROM [TIEVMDB03].[Ntier_627200].[PM].vwCollAcctVchrInfo ca
						GROUP BY 
							ca.Voucher_Number,
							ca.Self_Pay_Balance) SPB on SPB.VoucherNumber = a.AccountID

WHERE        (1 = 1) AND (YEAR(a.AccountDateOfService) >= YEAR(GETDATE()) - 3) AND (a.AccountDataSourceID IN (1, 5)) AND (a.AccountSourceID NOT LIKE '6%')
GO
