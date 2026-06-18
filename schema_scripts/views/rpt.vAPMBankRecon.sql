CREATE view [rpt].[vAPMBankRecon] as
SELECT
      br.[Batch_Number] BankReconBatchNumber
      ,br.[Batch_Cat_Abbr] BankReconBatchCategoryAbbr
      ,br.[Batch_Cat_Desc] BankReconBatchCategoryDesc
      ,br.[Tran_Cat_Abbr] BankReconTransactionCatAbbr
      ,br.[Tran_Cat_Desc] BankRecondTransactionCatDesc
      ,br.[Tran_Code_Abbr] BankReconTransactionCodeAbbr
      ,br.[Tran_Code_Desc] BankReconTransactionCodeDesc
      ,br.[Transaction_Type] BankReconTransactionType
	  ,CONCAT(YEAR(br.[Date_Paid]),' - ', RIGHT(concat('00',MONTH(br.[Date_Paid])),2)) BankReconPaidPeriod
	  ,CONCAT(YEAR(br.[Date_Updated]),' - ', RIGHT(concat('00',MONTH(br.[Date_Updated])),2)) BankReconUpdatePeriod
	  ,CONCAT(YEAR(br.[Date_Entered]),' - ', RIGHT(concat('00',MONTH(br.[Date_Entered])),2)) BankReconEnteredPeriod
      ,br.[Date_Paid] BankReconDatePaid
      ,br.[Date_Updated] BankReconDateUpdated
      ,br.[Date_Entered] BankReconDateEntered
      ,br.[Reference] BankReconReference
      ,br.[Patient_Number] BankReconPatientNumber
      ,br.[Voucher_Number] BankRecondVoucherNumber
	  ,t.TransactionStatus BankReconVoucherStatus
      ,br.[Amount] BankReconAmount
      ,br.[Service_Payment_ID] BankReconServicePaymentID
      ,br.[Location_Abbreviation] BankReconLocationAbbr
      ,br.[Location_Description] BankReconLocationName
      ,br.[Department_Abbreviation] BankReconDepartmentAbbr
      ,br.[Department_Description] BankReconDepartmentName
	  ,pp.ProviderFullName BankReconActualProvider
	  ,p.ProviderFullName BankReconBillingProvider
      ,br.[Operator_Name] BankReconOperatorName	
  FROM tievmdb03.Ntier_627200.PM.[vwBankReconcilPmts] br
	LEFT JOIN [HPIDW].fact.vTransactionsPB t on t.TransactionVisitID = CONCAT('1~', br.Voucher_Number)
	LEFT JOIN [HPIDW].dim.vProviders p on p.ProviderID = CONCAT('1~', br.Billing_Prov_Practitioner_ID)
	LEFT JOIN [HPIDW].dim.vProviders pp on pp.ProviderID = CONCAT('1~', br.Actual_Prov_Practitioner_ID)
  WHERE br.Service_Payment_ID <> 0 
		AND br.Date_Entered >= CAST('2023-01-01 00:00:00' AS DATETIME) 
		AND br.Department_Abbreviation = 'HPIP'
		--and br.[Batch_Number] = 'CBOTJM062724LBX03'
 GROUP BY
	br.[Batch_Number]
	,br.[Batch_Cat_Abbr]
	,br.[Batch_Cat_Desc]
	,br.[Tran_Cat_Abbr]
	,br.[Tran_Cat_Desc]
	,br.[Tran_Code_Abbr]
	,br.[Tran_Code_Desc]
	,br.[Transaction_Type]
	,br.[Date_Paid]
	,br.[Date_Paid]
	,br.[Date_Updated]
	,br.[Date_Entered]
	,br.[Reference]
	,br.[Patient_Number]
	,br.[Voucher_Number]
	,t.TransactionStatus
	,br.[Amount]
	,br.[Service_Payment_ID]
	,br.[Location_Abbreviation]
	,br.[Location_Description]
	,br.[Department_Abbreviation]
	,br.[Department_Description]
	,pp.ProviderFullName
	,p.ProviderFullName
	,br.[Operator_Name]
GO
