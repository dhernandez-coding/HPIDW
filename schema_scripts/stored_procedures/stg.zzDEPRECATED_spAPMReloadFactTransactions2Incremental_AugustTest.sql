-- Table setup --

--Select top 100 * from fact.transactions2

--ALTER TABLE fact.Transactions2
--ADD 
--	PatientID int,
--	PatientNumber int,
--	VoucherNumber int

--ALTER TABLE fact.Transactions2
--ALTER COLUMN PatientNumber VARCHAR(50) NULL
--DROP COLUMN VoucherNumber

--Select top 1000 * from fact.transactions2
----where TransactionDateOfPosting BETWEEN '2023-08-01' AND '2023-08-31'
--WHERE TransactionCPTCode = 'S6062'

CREATE PROCEDURE [stg].[spAPMReloadFactTransactions2Incremental_AugustTest] as

--EXEC [stg].[spAPMReloadFactTransactions2Incremental_AugustTest]

BEGIN

-- 11-2 plan: reload a little further back and then focus on Dr. Jacobs using the visit count view, narrow in on discrepencies (thinking we're missing exclusions)

/*Step 1:  Delete and reload PB transactions*/
DELETE FROM fact.Transactions2 WHERE TransactionDataSourceID = 1 AND TransactionDateOfPosting BETWEEN '2023-08-01' AND '2023-09-05' --AND TransactionBillingType = 'PB'
INSERT INTO fact.Transactions2
	(--[TransactionID]
	  [TransactionDatasourceID] 
      ,[TransactionSourceID] 
	  ,TransactionParentSourceID 
      ,[TransactionVisitID]
	  ,TransactionAccountID
	  ,TransactionEncounterID 
      ,[TransactionDepartmentID] 
      ,[TransactionPayerID] 
      ,[TransactionBillingProviderID] 
      ,[TransactionBillingType] --
      ,[TransactionType] --
      ,[TransactionSubType] 
      ,[TransactionRevenueCode]
      ,[TransactionRevenueCodeDescription]
      ,[TransactionCode]
      ,[TransactionDescription]
      ,[TransactionCPTCode]
      ,[TransactionModifier1]
      ,[TransactionModifier2]
      ,[TransactionModifier3]
      ,[TransactionModifier4]
      ,[TransactionUnits]
      ,[TransactionAmount]
	  ,TransactionRVU
      ,[TransactionDateOfService]
      ,[TransactionDateOfPosting]
      ,[TransactionDateOfBilling]
	  ,[TransactionDateOfVoid]
      ,[TransactionReportingPeriodID]
      ,[TransactionStatus]
      ,[TransactionIsActive]
      ,[TransactionUpdatedDateTime]
	  ,[TransactionCPTDescription]
	  ,[TransactionPlaceOfServiceCode]
	  ,[TransactionPlaceOfServiceType]
	  ,[PatientID]
	  ,[PatientNumber]
	  )
 
 /*PB Transactions - Charges*/


SELECT   --v.Voucher_Number,tx.update_status,
	 '1' as TransactionDatasourceID
	,CONCAT('PB~',tx.Service_ID) as TransactionSourceID
	,CONCAT('PB~',tx.Service_ID) AS TransactionParentSourceID
	,CASE WHEN tx.Voucher_Number is not null THEN CONCAT('1~',tx.Voucher_Number) END as TransactionVisitID
	,CASE WHEN tx.Voucher_Number is not null THEN CONCAT('1~',tx.Voucher_Number) END as TransactionAccountID
	,CASE WHEN tx.Voucher_Number is not null THEN CONCAT('1~',tx.Voucher_Number) END as TransactionEncounterID
	,CASE WHEN v.Voucher_Number is not null THEN CONCAT('1~',v.Department_ID) END as TransactionDepartmentID
	,CASE WHEN COALESCE(tx.Billing_Carrier_ID, tx.Original_Carrier_ID) is not null THEN CONCAT('1~',COALESCE(tx.Billing_Carrier_ID, tx.Original_Carrier_ID)) 
		  WHEN v.Is_Self_Pay = 1 THEN '1~SELF' /*Hard-code selfpay when financial class is self pay*/
		  END as TransactionPayerID
	,CASE WHEN tx.Billing_Dr_ID is not null THEN CONCAT('1~',tx.Billing_Dr_ID ) END as TransactionBillingProviderID
	,'PB' as TransactionBillingType
	,'Charge' as TransactionType
	,'Charge - New' as TransactionSubType
	,NULL as TransactionRevenueCode
	,NULL as TransactionRevenueCodeDescription
	,tx.Procedure_Code as TransactionCode
	,tx.Procedure_Insurance_Descr as TransactionDescription
	,CASE WHEN LEN(tx.Procedure_Code) <> 5 THEN NULL ELSE tx.Procedure_Code END as TransactionCPTCode
	,LEFT(tx.Modifiers,2) as TransactionModifier1
	,SUBSTRING(tx.Modifiers,4,2) as TransactionModifier2
	,SUBSTRING(tx.Modifiers,7,2) as TransactionModifier3
	,SUBSTRING(tx.Modifiers,9,2) as TransactionModifier4
	,tx.Service_Units as TransactionUnits
	,tx.Service_Fee as TransactionAmount
	,NULL as TransactionRVU
	,v.Service_Date as TransactionDateOfService
	,tx.Posting_Date as TransactionDateOfPosting
	,tx.Billing_Date as TransactionDateOfBilling
	,v.Date_Voided as TransactionDateOfVoid
	,CONCAT(YEAR(tx.Posting_Date),' - ', RIGHT(concat('00',MONTH(tx.Posting_Date)),2)) as TransactionReportingPeriodID
	,CASE WHEN v.Date_Voided is null THEN 'Active' ELSE 'Voided' END as TransactionStatus 
	,1 as TransactionIsActive
	,GETDATE() as TransactionUpdatedDatetime
	,tx.Procedure_Insurance_Descr as TransactionCPTDescription
	,bc.Billing_Code AS TransactionPlaceOfServiceCode
	,NULL as TransactionPlaceOfServiceType
	,CONCAT('1~',v.Patient_ID) as PatientID
	,vch.Patient_Number as PatientNumber

FROM [TIEVMDB03].[Ntier_627200].[PM].vwGenSvcInfo tx
inner join [TIEVMDB03].[Ntier_627200].[PM].vwGenVouchInfo vch on tx.Tenant_ID = vch.Tenant_ID
	and tx.voucher_id = vch.voucher_id
LEFT JOIN [TIEVMDB03].[Ntier_627200].[PM].Vouchers v ON v.Voucher_ID = tx.Voucher_ID
LEFT JOIN [TIEVMDB03].[Ntier_627200].[PM].POS_BILLING_CODES bc ON bc.Place_Of_Service_ID = v.Place_Of_Service_ID AND bc.Profile_ID = 12 /*Standard POS Type*/ 
INNER JOIN [TIEVMDB03].[Ntier_627200].[PM].Procedure_Codes pr WITH (NOLOCK) ON tx.Procedure_Code = pr.Procedure_Code
	and tx.Tenant_ID = pr.Tenant_ID
left join [TIEVMDB03].[Ntier_627200].[PM].reporting_periods rp with (nolock) on tx.Tenant_ID = rp.Tenant_ID 
																			    and tx.posting_date >= rp.start_date 
																				and tx.posting_date <= isnull(rp.end_date,'2999-12-31')
--LEFT JOIN [TIEVMDB03].[Ntier_627200].[PM].Practice_Information PRACTINFO ON PRACTINFO.Tenant_ID = tx.Tenant_ID

 where 1=1
	AND tx.Update_Status in (1,2,3) -- all so that we pull charge and void
	--AND tx.Posting_Date BETWEEN rp.start_date AND isnull(rp.end_date,'2999-12-31')
	AND rp.abbreviation = 'Aug 2023'
	--AND v.voucher_id = '2201080'

UNION ALL 

 /*PB Transactions - Voids - reversing charge entry*/

SELECT   --v.Voucher_Number,tx.update_status,
	 '1' as TransactionDatasourceID
	,CONCAT('PB~',tx.Service_ID) as TransactionSourceID
	,CONCAT('PB~',tx.Service_ID) AS TransactionParentSourceID
	,CASE WHEN tx.Voucher_Number is not null THEN CONCAT('1~',tx.Voucher_Number) END as TransactionVisitID
	,CASE WHEN tx.Voucher_Number is not null THEN CONCAT('1~',tx.Voucher_Number) END as TransactionAccountID
	,CASE WHEN tx.Voucher_Number is not null THEN CONCAT('1~',tx.Voucher_Number) END as TransactionEncounterID
	,CASE WHEN v.Department_ID is not null THEN CONCAT('1~',v.Department_ID) END as TransactionDepartmentID
	,CASE WHEN COALESCE(tx.Billing_Carrier_ID, tx.Original_Carrier_ID) is not null THEN CONCAT('1~',COALESCE(tx.Billing_Carrier_ID, tx.Original_Carrier_ID)) 
		  WHEN v.Is_Self_Pay = 1 THEN '1~SELF' /*Hard-code selfpay when financial class is self pay*/
		  END as TransactionPayerID
	,CASE WHEN tx.Billing_Dr_ID is not null THEN CONCAT('1~',tx.Billing_Dr_ID ) END as TransactionBillingProviderID
	,'PB' as TransactionBillingType
	,'Charge' as TransactionType
	,'Charge - Void' as TransactionSubType
	,NULL as TransactionRevenueCode
	,NULL as TransactionRevenueCodeDescription
	,tx.Procedure_Code as TransactionCode
	,tx.Procedure_Insurance_Descr as TransactionDescription
	,CASE WHEN LEN(tx.Procedure_Code) <> 5 THEN NULL ELSE tx.Procedure_Code END as TransactionCPTCode
	,LEFT(tx.Modifiers,2) as TransactionModifier1
	,SUBSTRING(tx.Modifiers,4,2) as TransactionModifier2
	,SUBSTRING(tx.Modifiers,7,2) as TransactionModifier3
	,SUBSTRING(tx.Modifiers,9,2) as TransactionModifier4
	,-tx.Service_Units as TransactionUnits
	,-tx.Service_Fee as TransactionAmount
	,NULL as TransactionRVU
	,v.Service_Date as TransactionDateOfService
	,v.Date_Voided as TransactionDateOfPosting
	,tx.Billing_Date as TransactionDateOfBilling
	,v.Date_Voided as TransactionDateOfVoid
	,CONCAT(YEAR(v.Date_Voided),' - ', RIGHT(concat('00',MONTH(v.Date_Voided)),2)) as TransactionReportingPeriodID
	,CASE WHEN v.Date_Voided is null THEN 'Active' ELSE 'Voided' END as TransactionStatus 
	,1 as TransactionIsActive
	,GETDATE() as TransactionUpdatedDatetime
	,tx.Procedure_Insurance_Descr as TransactionCPTDescription
	,bc.Billing_Code AS TransactionPlaceOfServiceCode
	,NULL as TransactionPlaceOfServiceType
	,CONCAT('1~',v.Patient_ID) as PatientID
	,vch.Patient_Number as PatientNumber

FROM [TIEVMDB03].[Ntier_627200].[PM].vwGenSvcInfo tx
inner join [TIEVMDB03].[Ntier_627200].[PM].vwGenVouchInfo vch on tx.Tenant_ID = vch.Tenant_ID
	and tx.voucher_id = vch.voucher_id
LEFT JOIN [TIEVMDB03].[Ntier_627200].[PM].Vouchers v ON v.Voucher_ID = tx.Voucher_ID
LEFT JOIN [TIEVMDB03].[Ntier_627200].[PM].POS_BILLING_CODES bc ON bc.Place_Of_Service_ID = v.Place_Of_Service_ID AND bc.Profile_ID = 12 /*Standards POS Type*/ 
INNER JOIN [TIEVMDB03].[Ntier_627200].[PM].Procedure_Codes pr WITH (NOLOCK) ON tx.Procedure_Code = pr.Procedure_Code
	and tx.Tenant_ID = pr.Tenant_ID
left join [TIEVMDB03].[Ntier_627200].[PM].reporting_periods rp with (nolock) on tx.Tenant_ID = rp.Tenant_ID 
																				and tx.posting_date >= rp.start_date 
																				and tx.posting_date <= isnull(rp.end_date,'2999-12-31')
--LEFT JOIN [TIEVMDB03].[Ntier_627200].[PM].Practice_Information PRACTINFO ON PRACTINFO.Tenant_ID = tx.Tenant_ID

 where 1=1
	AND tx.Update_Status = 3 -- all so that we pull charge and void
	--AND v.date_voided BETWEEN rp.start_date AND isnull(rp.end_date,'2999-12-31')
	AND rp.abbreviation = 'Aug 2023'
	--AND v.voucher_id = '2201080'

UNION ALL


 /*PB Transactions - Payments, Refunds, and Adjustments*/

SELECT --v.Voucher_Number,tx.update_status,
	'1' as TransactionDatasourceID
	,CONCAT('PB~',tx.Service_Payment_ID, '~', tx.Service_ID) as TransactionSourceID
	,CONCAT('PB~',tx.Service_ID) AS TransactionParentSourceID
	,CASE WHEN svc.Voucher_Number is not null THEN CONCAT('1~',svc.Voucher_Number) END as TransactionVisitID
	,CASE WHEN svc.Voucher_Number is not null THEN CONCAT('1~',svc.Voucher_Number) END as TransactionAccountID
	,CASE WHEN svc.Voucher_Number is not null THEN CONCAT('1~',svc.Voucher_Number) END as TransactionEncounterID
	,CASE WHEN v.Department_ID is not null THEN CONCAT('1~',v.Department_ID) END as TransactionDepartmentID
	,CASE WHEN tx.Remitting_Carrier_ID IS NULL then '1~SELF'
		  WHEN tx.Remitting_Carrier_ID is not null then CONCAT('1~',tx.Remitting_Carrier_ID)
		  WHEN v.Is_Self_Pay = 1 THEN '1~SELF' /*Hard-code selfpay when financial class is self pay*/
		  END as TransactionPayerID
	,NULL as TransactionBillingProviderID
	,'PB' as TransactionBillingType
	,case
		when tx.Transaction_Type = 'P' then 'Payment'
		when tx.Transaction_type = 'R' then 'Payment'
		when tx.Transaction_Type = 'A' then 'Adjustment' end TransactionType
	,case
		when tx.Transaction_Type = 'P' then 'Payment - Regular'
		when tx.Transaction_type = 'R' then 'Refund'
		when tx.Transaction_Type = 'A' then 'Adjustment' 
		end TransactionSubType
	,NULL as TransactionRevenueCode
	,NULL as TransactionRevenueCodeDescription
	,tx.Transaction_Code_Abbr as TransactionCode
	,tx.Transaction_Code_Descr as TransactionDescription
	,NULL as TransactionCPTCode
	,null as TransactionModifier1
	,null as TransactionModifier2
	,null as TransactionModifier3
	,null as TransactionModifier4
	,1 as TransactionUnits
	,-tx.Amount as TransactionAmount
	,NULL as TransactionRVU
	,v.Service_Date as TransactionDateOfService
	,tx.Posting_Date as TransactionDateOfPosting
	,NULL as TransactionDateOfBilling
	,tx.Date_Voided as TransactionDateOfVoid
	,CONCAT(YEAR(tx.Posting_Date),' - ', RIGHT(concat('00',MONTH(tx.Posting_Date)),2)) as TransactionReportingPeriodID
	,CASE WHEN tx.Date_Voided is null THEN 'Active' ELSE 'Voided' END as TransactionStatus 
	,1 as TransactionIsActive
	,GETDATE() as TransactionUpdatedDatetime
	,NULL as TransactionCPTDescription
	,NULL AS TransactionPlaceOfServiceCode
	,NULL as TransactionPlaceOfServiceType
	,CONCAT('1~',v.Patient_ID) as PatientID
	,svc.Patient_Number as PatientNumber
 --select tx.*

 FROM [TIEVMDB03].[Ntier_627200].[PM].[vwGenSvcPmtInfo] tx
INNER JOIN  [TIEVMDB03].[Ntier_627200].[PM].vwGenSvcInfo AS svc ON tx.Tenant_ID = svc.Tenant_ID
	AND tx.Service_ID = svc.Service_ID
left join [TIEVMDB03].[Ntier_627200].[PM].Services ptx on ptx.Service_ID = tx.Service_ID -- Parent Transactions 
left join [TIEVMDB03].[Ntier_627200].[PM].Vouchers v ON ptx.Voucher_ID = v.Voucher_ID
left join [TIEVMDB03].[Ntier_627200].[PM].reporting_periods rp with (nolock) on tx.Tenant_ID = rp.Tenant_ID 
																				and tx.posting_date >= rp.start_date 
																				and tx.posting_date <= isnull(rp.end_date,'2999-12-31')
--LEFT JOIN [TIEVMDB03].[Ntier_627200].[PM].Practice_Information PRACTINFO ON PRACTINFO.Tenant_ID = tx.Tenant_ID
 where 1=1
	AND rp.abbreviation = 'Aug 2023'
	AND tx.Update_Status in (1,2,3)
	AND tx.Amount <> 0
	AND Transaction_Type in ('A','R','P', 'M')
	--AND tx.Posting_Date BETWEEN rp.start_date AND isnull(rp.end_date,'2999-12-31')
	--AND v.voucher_ID = '2175013'

UNION ALL 


/*PB Transactions - Reversing payment entry*/

SELECT --v.Voucher_Number,tx.update_status,
	'1' as TransactionDatasourceID
	,CONCAT('PB~',tx.Service_Payment_ID, '~', tx.Service_ID) as TransactionSourceID
	,CONCAT('PB~',tx.Service_ID) AS TransactionParentSourceID
	,CASE WHEN svc.Voucher_Number is not null THEN CONCAT('1~',svc.Voucher_Number) END as TransactionVisitID
	,CASE WHEN svc.Voucher_Number is not null THEN CONCAT('1~',svc.Voucher_Number) END as TransactionAccountID
	,CASE WHEN svc.Voucher_Number is not null THEN CONCAT('1~',svc.Voucher_Number) END as TransactionEncounterID
	,CASE WHEN v.Department_ID is not null THEN CONCAT('1~',v.Department_ID) END as TransactionDepartmentID
	,CASE WHEN tx.Remitting_Carrier_ID IS NULL then '1~SELF'
		  WHEN tx.Remitting_Carrier_ID is not null then CONCAT('1~',tx.Remitting_Carrier_ID)
		  WHEN v.Is_Self_Pay = 1 THEN '1~SELF' /*Hard-code selfpay when financial class is self pay*/
		  END as TransactionPayerID
	,NULL as TransactionBillingProviderID
	,'PB' as TransactionBillingType
	,case
		when tx.Transaction_Type = 'P' then 'Payment'
		when tx.Transaction_type = 'R' then 'Payment'
		when tx.Transaction_Type = 'A' then 'Adjustment' end TransactionType
	,case
		when tx.Transaction_Type = 'P' then 'Payment - Void'
		when tx.Transaction_type = 'R' then 'Refund - Void'
		when tx.Transaction_Type = 'A' then 'Adjustment - Void'
		end TransactionSubType
	,NULL as TransactionRevenueCode
	,NULL as TransactionRevenueCodeDescription
	,tx.Transaction_Code_Abbr as TransactionCode
	,tx.Transaction_Code_Descr as TransactionDescription
	,NULL as TransactionCPTCode
	,null as TransactionModifier1
	,null as TransactionModifier2
	,null as TransactionModifier3
	,null as TransactionModifier4
	,-1 as TransactionUnits
	,tx.Amount as TransactionAmount
	,NULL as TransactionRVU
	,v.Service_Date as TransactionDateOfService
	,tx.date_voided as TransactionDateOfPosting
	,NULL as TransactionDateOfBilling
	,tx.Date_Voided as TransactionDateOfVoid
	,CONCAT(YEAR(tx.date_voided),' - ', RIGHT(concat('00',MONTH(tx.date_voided)),2)) as TransactionReportingPeriodID
	,CASE WHEN tx.Date_Voided is null THEN 'Active' ELSE 'Voided' END as TransactionStatus 
	,1 as TransactionIsActive
	,GETDATE() as TransactionUpdatedDatetime
	,NULL as TransactionCPTDescription
	,NULL AS TransactionPlaceOfServiceCode
	,NULL as TransactionPlaceOfServiceType
	,CONCAT('1~',v.Patient_ID) as PatientID
	,svc.Patient_Number as PatientNumber
 --select tx.*
 FROM [TIEVMDB03].[Ntier_627200].[PM].[vwGenSvcPmtInfo] tx
INNER JOIN  [TIEVMDB03].[Ntier_627200].[PM].vwGenSvcInfo AS svc ON tx.Tenant_ID = svc.Tenant_ID
	AND tx.Service_ID = svc.Service_ID
left join [TIEVMDB03].[Ntier_627200].[PM].Services ptx on ptx.Service_ID = tx.Service_ID -- Parent Transactions 
left join [TIEVMDB03].[Ntier_627200].[PM].Vouchers v ON ptx.Voucher_ID = v.Voucher_ID
left join [TIEVMDB03].[Ntier_627200].[PM].reporting_periods rp with (nolock) on tx.Tenant_ID = rp.Tenant_ID 
																			    and tx.date_voided >= rp.start_date 
																				and tx.posting_date <= isnull(rp.end_date,'2999-12-31')
--LEFT JOIN [TIEVMDB03].[Ntier_627200].[PM].Practice_Information PRACTINFO ON PRACTINFO.Tenant_ID = tx.Tenant_ID
 where 1=1
	AND Transaction_Type in ('A','R','P', 'M')
	AND tx.Update_Status = 3
	AND tx.Amount <> 0
	--AND tx.date_voided BETWEEN rp.start_date AND isnull(rp.end_date,'2999-12-31')
	AND rp.abbreviation = 'Aug 2023'
	--AND v.voucher_ID = '2175013'
END
GO
