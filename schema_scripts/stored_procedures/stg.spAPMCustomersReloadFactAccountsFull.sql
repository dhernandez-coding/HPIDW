CREATE procedure [stg].[spAPMCustomersReloadFactAccountsFull] as

DELETE FROM fact.Accounts WHERE AccountDatasourceID = 12

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
	concat('12~', v.voucher_number,'~',v.department_id) AS [AccountID]
      ,12 AS [AccountDataSourceID]
      ,v.voucher_number AS [AccountSourceID]
      ,v.voucher_number AS [AccountReferenceNumber]
      ,concat('12~', v.patient_id) AS [AccountPatientID]
      ,concat('12~', v.location_id) AS	[AccountLocationID]
	  ,concat('12~', v.department_id)AS [AccountDepartmentID]
      ,'12~' + cast(p.Insurance_Category_ID as varchar(50)) AS [AccountFinancialClassID]
      ,'12' + '~' + cast(p.Carrier_ID as varchar(50)) AS [AccountPrimaryPayerID]
      ,null AS [AccountPrimaryPayerPlanID]
      ,concat('12~', v.[Actual_Prov_Practitioner_ID]) AS  [AccountPrimaryProviderID]
      ,concat('12~', v.[Actual_Prov_Practitioner_ID]) AS [AccountAdmittingProviderID]
      ,concat('12~', v.[Actual_Prov_Practitioner_ID]) AS [AccountAttendingProviderID]
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


FROM [TIEVMDB03].Ntier_HPI_Customers.[PM].[Vouchers] v
	LEFT JOIN [TIEVMDB03].Ntier_HPI_Customers.[PM].Carriers p WITH (NOLOCK) ON p.Tenant_ID = v.Tenant_ID AND p.Carrier_ID = v.Carrier_ID

WHERE 1=1
	AND v.update_status in (0,1) /*Not Voided*/
	AND v.department_id in ('36','45','46','48', '47') --Add this to include Bryant Street
	AND v.service_date >= '2023-01-01'
GO
