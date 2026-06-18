CREATE VIEW rpt.vTransactions2forMaterializedView 
	with schemabinding
	AS 
	
	SELECT
	t.[TransactionID]
      ,t.[TransactionDatasourceID]
      ,t.[TransactionSourceID]
      ,t.[TransactionParentSourceID]
      ,t.[TransactionVisitID]
      ,t.[TransactionAccountID]
      ,t.[TransactionEncounterID]
      ,t.[TransactionDepartmentID]
      ,t.[TransactionPayerID]
      ,t.[TransactionBillingProviderID]
      ,t.[TransactionBillingType]
      ,t.[TransactionType]
      ,t.[TransactionSubType]
      ,t.[TransactionRevenueCode]
      ,t.[TransactionRevenueCodeDescription]
      ,t.[TransactionCode]
      ,t.[TransactionDescription]
      ,t.[TransactionCPTCode]
      ,t.[TransactionModifier1]
      ,t.[TransactionModifier2]
      ,t.[TransactionModifier3]
      ,t.[TransactionModifier4]
      ,t.[TransactionUnits]
      ,t.[TransactionAmount]
      ,t.[TransactionRVU]
      ,t.[TransactionDateOfService]
      ,t.[TransactionDateOfPosting]
      ,t.[TransactionDateOfBilling]
      ,t.[TransactionDateOfVoid]
      ,t.[TransactionReportingPeriodID]
      ,t.[TransactionStatus]
      ,t.[TransactionIsActive]
      ,t.[TransactionUpdatedDateTime]
      ,t.[TransactionCPTDescription]
      ,t.[TransactionPlaceOfServiceCode]
      ,t.[TransactionPlaceOfServiceType]
      ,t.[PatientID]
      ,t.[PatientNumber]
      ,t.[TransactionGLType]
	  FROM 
	fact.Transactions2 t 
	LEFT JOIN fact.Transactions2 tc ON

	tc.TransactionType = 'Charge' 
	AND tc.TransactionBillingType = 'PB'
	AND t.TransactionType <> 'Charge'
	AND tc.TransactionDatasourceID = t.TransactionDatasourceID
	AND tc.TransactionSourceID = t.TransactionParentSourceID
GO
