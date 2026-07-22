CREATE VIEW [fact].[vAccounts] as
SELECT
	 [AccountID]
      ,[AccountDataSourceID]
	  ,ds.DataSourceName as AccountDataSource
      ,[AccountSourceID]
      ,[AccountReferenceNumber]
      ,[AccountPatientID]
      ,[AccountLocationID]
      ,[AccountDepartmentID]
	  ,[AccountFinancialClassID]
      ,[AccountPrimaryPayerID]
      ,[AccountPrimaryPayerPlanID]
	  ,pp.PayerPlanName AS AccountPrimaryPayerPlan
      ,[AccountPrimaryProviderID]
      ,[AccountAdmittingProviderID]
      ,[AccountAttendingProviderID]
      ,[AccountReferringProviderID]
      ,[AccountDateOfService]
      ,[AccountDateOfAdmission]
      ,[AccountDateOfDischarge]
      ,[AccountDateOfBilling]
      ,[AccountDateOfClosing]
      ,[AccountDateOfZeroBalance]
      ,[AccountDateOfBadDebtWriteOff]
      ,[AccountTotalCharges]
      ,[AccountTotalAdjustments]
      ,[AccountTotalPayments]
      ,[AccountTotalRefunds]
      ,[AccountTotalBalance]
      ,[AccountStatus]
      ,[AccountClass]
      ,[AccountType]
	  ,AccountService
      ,[AccountBillingStatus]
      ,[AccountCodingStatus]
      ,[AccountCodingStatusDatetime]
	  ,px.PrimaryProcedureCode as AccountPrimaryProcedureCode
	  ,px.PrimaryProcedureCodeDescription as AccountPrimaryProcedure
	  ,dx.PrimaryDiagnosisCode as AccountPrimaryDiagnosisCode
	  ,dx.PrimaryDiagnosisDescription as AccountPrimaryDiagnosis
      ,[AccountDRG]
      ,[AccountDRGDescription]
	  ,CASE WHEN ISNULL(a.AccountDRG,'') = '' THEN null ELSE CONCAT(a.AccountDRG,' - ',a.AccountDRGDescription,' (', a.AccountDRGMDC,')') END as AccountDRGWithDescription
      ,[AccountDRGType]
      ,[AccountDRGMDC]
	  ,AccountDRGCMI
	  ,AccountDRGGMLOS
      ,[AccountIsRecurring]
  	  ,CASE WHEN a.AccountTotalCharges > 0 AND a.AccountTotalBalance <= 10 THEN 'Yes' ELSE 'No' END as AccountIsMostlyAdjudicated
	  --CASE WHEN tx.VisitTotalCharges > 0 AND tx.VisitTotalBalance < (tx.VisitTotalCharges - tx.VisitTotalAdjustments) * .10 THEN 'Yes' ELSE 'No' END as VisitIsMostlyAdjudicated 
	  ,CASE WHEN a.AccountTotalBalance = 0 THEN 'Yes' ELSE 'No' END as AccountIsZeroBalance 
	  --CASE WHEN tx.VisitTotalBalance = 0 THEN 'Yes' ELSE 'No' END as VisitIsZeroBalance 
	  ,CASE WHEN a.AccountDataSourceID in (2,8) THEN 'Yes'
			  WHEN a.AccountDataSourceID = 5 and a.AccountSourceID like '6%' THEN 'Yes' 
			  --WHEN a.AccountSourceID like 'NoAccount%' THEN 'Yes' /*Scheduled surgeries without a hospital account*/
			  ELSE 'No' END as AccountIsHospital
	,CASE WHEN a.AccountTotalBalance = 0 THEN '99_ZeroBalance'
		  WHEN DATEDIFF(DAY,a.AccountDateOfDischarge,GETDATE()) between 0 and 30 THEN '1) 0-30'
		  WHEN DATEDIFF(DAY,a.AccountDateOfDischarge,GETDATE()) between 31 and 60 THEN '2) 31-60'
		  WHEN DATEDIFF(DAY,a.AccountDateOfDischarge,GETDATE()) between 61 and 90 THEN '3) 61-90'
		  WHEN DATEDIFF(DAY,a.AccountDateOfDischarge,GETDATE()) between 91 and 120 THEN '4) 91-120'
		  WHEN DATEDIFF(DAY,a.AccountDateOfDischarge,GETDATE()) > 120 THEN '5) 121+'
		  END as AccountARAgingBucket
	, CASE WHEN a.AccountTotalBalance = 0 THEN DATEDIFF(DAY,a.AccountDateOfDischarge,a.AccountDateOfZeroBalance) 
	       WHEN a.AccountTotalCharges > 0 THEN DATEDIFF(DAY,a.AccountDateOfDischarge,GETDATE())
		   END as AccountARAgingDays
	,AccountBeneficiaryNumber
	,[AccountIsActive]
	,[AccountUpdatedDatetime]
	,[AccountGuarantorName]
	,[AccountGuarantorID]
FROM [HPIDW].[fact].[Accounts] a
	left join dim.PayerPlans pp ON pp.PayerPlanID = a.AccountPrimaryPayerPlanID
	left join dim.DataSources ds ON ds.DataSourceID = a.AccountDatasourceID
	left join (SELECT	
				 p.VisitProcedureAccountID
				 ,MIN(p.VisitProcedureCode) as PrimaryProcedureCode
				 ,MIN(CONCAT(p.VisitProcedureCode, ' - ', p.VisitProcedureDescription)) as PrimaryProcedureCodeDescription
			   FROM fact.VisitProcedures p 
			   WHERE 1=1
				AND p.VisitProcedureIsPrimary = 1
			   GROUP BY 
				p.VisitProcedureAccountID) px ON px.VisitProcedureAccountID = a.AccountID
	left join (SELECT	
				 d.VisitDiagnosisAccountID
				 ,MIN(d.VisitDiagnosisCode) as PrimaryDiagnosisCode
				 ,MIN(CONCAT(d.VisitDiagnosisCode, ' - ', d.VisitDiagnosisDescription)) as PrimaryDiagnosisDescription
			   FROM fact.VisitDiagnoses d 
			   WHERE 1=1
				AND d.VisitDiagnosisIsPrimary = 1
			   GROUP BY 
				d.VisitDiagnosisAccountID) dx ON dx.VisitDiagnosisAccountID = a.AccountID

WHERE 1=1
	AND a.AccountDateOfService >= DATEFROMPARTS(YEAR(GETDATE()) - 3, 1, 1)
	--AND a.AccountDataSourceID = 5
	--AND a.AccountSourceID like '6%'
GO
