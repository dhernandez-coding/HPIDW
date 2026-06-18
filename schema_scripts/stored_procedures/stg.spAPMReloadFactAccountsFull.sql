CREATE procedure [stg].[spAPMReloadFactAccountsFull] as

DELETE FROM fact.Accounts WHERE AccountDatasourceID = 1

	INSERT INTO fact.Accounts
	  ([AccountID]
      ,[AccountDataSourceID]
      ,[AccountSourceID]
      ,[AccountReferenceNumber]
      ,[AccountPatientID]
      ,[AccountLocationID]
      ,[AccountDepartmentID]
      ,[AccountFinancialClassID]
      ,[AccountPrimaryPayerID]
      ,[AccountPrimaryPayerPlanID]
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
      ,[AccountService]
      ,[AccountBillingStatus]
      ,[AccountCodingStatus]
      ,[AccountCodingStatusDatetime]
      ,[AccountDRG]
      ,[AccountDRGDescription]
      ,[AccountDRGType]
      ,[AccountDRGMDC]
      ,[AccountDRGCMI]
      ,[AccountDRGGMLOS]
      ,[AccountIsRecurring]
      ,[AccountIsActive]
      ,[AccountUpdatedDatetime]
	  ,[AccountEmployerName]
	)
	
SELECT
	concat('1~', v.voucher_number) AS [AccountID]
      ,1 AS [AccountDataSourceID]
      ,v.voucher_number AS [AccountSourceID]
      ,v.voucher_number AS [AccountReferenceNumber]
      ,concat('1~', v.patient_id) AS [AccountPatientID]
      ,concat('1~', v.location_id) AS	[AccountLocationID]
	  ,concat('1~', v.department_id)AS [AccountDepartmentID]
      ,'1~' + cast(p.Insurance_Category_ID as varchar(50)) AS [AccountFinancialClassID]
      ,'1' + '~' + cast(p.Carrier_ID as varchar(50)) AS [AccountPrimaryPayerID]
      ,null AS [AccountPrimaryPayerPlanID]
      ,concat('1~', v.[Actual_Prov_Practitioner_ID]) AS  [AccountPrimaryProviderID]
      ,concat('1~', v.[Actual_Prov_Practitioner_ID]) AS [AccountAdmittingProviderID]
      ,concat('1~', v.[Actual_Prov_Practitioner_ID]) AS [AccountAttendingProviderID]
      ,null AS [AccountReferringProviderID]
      ,v.service_date AS [AccountDateOfService]
      ,cast(v.service_date as date) AS [AccountDateOfAdmission]
      ,cast(v.service_date as date) AS[AccountDateOfDischarge]
      ,cast (v.billing_date as date) AS [AccountDateOfBilling]
      ,CONVERT(DATETIME,v.Date_Updated,101) AS [AccountDateOfClosing]
      ,null AS [AccountDateOfZeroBalance]
      ,null AS [AccountDateOfBadDebtWriteOff]
      ,v.Fees AS [AccountTotalCharges]
      ,v.Posted_Adjustments AS [AccountTotalAdjustments]
      ,v.Posted_Payments AS [AccountTotalPayments]
      ,v.Posted_Refunds AS [AccountTotalRefunds]
      ,Fees - COALESCE (v.Posted_Payments, 0)
			- COALESCE (v.Posted_Adjustments, 0)
			+ COALESCE (v.Posted_Refunds, 0)
			+ COALESCE (v.Posted_Misc_Debits, 0) AS [AccountTotalBalance]
      ,CASE WHEN v.update_status in (0,1) THEN 'Completed'
		  WHEN v.update_status in (3,5) THEN 'Voided' 
		  END AS [AccountStatus]
      ,'Outpatient' AS [AccountClass]
      ,'Outpatient' AS [AccountType]
      ,null AS [AccountService]
      ,CASE WHEN (v.Fees - COALESCE (v.Posted_Payments, 0)
			- COALESCE (v.Posted_Adjustments, 0)
			+ COALESCE (v.Posted_Refunds, 0)
			+ COALESCE (v.Posted_Misc_Debits, 0)) = 0 THEN 'Zero Balance'
		WHEN (v.Fees - COALESCE (v.Posted_Payments, 0)
			- COALESCE (v.Posted_Adjustments, 0)
			+ COALESCE (v.Posted_Refunds, 0)
			+ COALESCE (v.Posted_Misc_Debits, 0))  < 0 THEN 'Credit Balance'
		ELSE 'Open Balance' END AS [AccountBillingStatus]
      ,null AS [AccountCodingStatus]
      ,null AS [AccountCodingStatusDatetime]
      ,null AS [AccountDRG]
      ,null AS [AccountDRGDescription]
      ,null AS [AccountDRGType]
      ,null AS [AccountDRGMDC]
      ,null AS [AccountDRGCMI]
      ,null AS [AccountDRGGMLOS]
      ,0 AS [AccountIsRecurring]
      ,CASE WHEN v.update_status in (3,5) THEN 0 ELSE 1 END [AccountIsActive]
      ,getdate() [AccountUpdatedDatetime]
	  ,null as AccountEmployerName


FROM [TIEVMDB03].[Ntier_627200].[PM].[Vouchers] v
	LEFT JOIN [TIEVMDB03].[Ntier_627200].[PM].Carriers p WITH (NOLOCK) ON p.Tenant_ID = v.Tenant_ID AND p.Carrier_ID = v.Carrier_ID

WHERE 1=1
	AND v.update_status in (0,1) /*Not Voided*/
GO
