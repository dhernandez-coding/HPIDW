CREATE PROCEDURE [stg].[spAPMCustomersReloadFactTransactionsPBFull] as
-- =============================================
-- Author:		Eric Silvestri
-- Create date: 5/28/2025
-- Description:	Deletes and reloads all APM PB Transactions
-- =============================================

BEGIN
 
/*Step 1:  Load Staging Table with PB transactions...*/
Print 'Step 1:  Create Staging Table...'
--DECLARE @DaysToReload int = 5
--Print 'Setting Days To Reload:' + convert(varchar(10),@DaysToReload) + '...'

DECLARE @Staging TABLE
	([TransactionID] varchar(100) primary key NOT NULL,
	[TransactionDatasourceID] [int] NULL,
	[TransactionSourceID] [varchar](100) NULL,
	[TransactionParentSourceID] [varchar](100) NULL,
	[TransactionVisitID] [varchar](100) NULL,
	[TransactionAccountID] [varchar](100) NULL,
	[TransactionDepartmentID] [varchar](100) NULL,
	[TransactionPayerID] [varchar](100) NULL,
	[TransactionBillingProviderID] [varchar](100) NULL,
	[TransactionBillingType] [varchar](100) NULL,
	[TransactionType] [varchar](100) NULL,
	[TransactionSubType] [varchar](100) NULL,
	[TransactionRevenueCode] [varchar](100) NULL,
	[TransactionRevenueCodeDescription] [varchar](1000) NULL,
	[TransactionCode] [varchar](100) NULL,
	[TransactionDescription] [varchar](1000) NULL,
	[TransactionCPTCode] [varchar](100) NULL,
	[TransactionCPTDescription] [varchar](1000) NULL,
	[TransactionModifier1] [varchar](50) NULL,
	[TransactionModifier2] [varchar](50) NULL,
	[TransactionModifier3] [varchar](50) NULL,
	[TransactionModifier4] [varchar](50) NULL,
	[TransactionUnits] [decimal](10, 2) NULL,
	[TransactionAmount] [money] NULL,
	[TransactionRVU] [decimal](18, 2) NULL,
	[TransactionDateOfService] [datetime] NULL,
	[TransactionDateOfPosting] [datetime] NULL,
	[TransactionDateOfBilling] [datetime] NULL,
	[TransactionDateOfVoid] [datetime] NULL,
	[TransactionReportingPeriodID] [varchar](100) NULL,
	[TransactionPlaceOfServiceCode] [varchar](50) NULL,
	[TransactionPlaceOfServiceType] [varchar](100) NULL,
	[TransactionPatientID] [varchar](50) NULL,
	[TransactionGLType] [varchar](10) NULL,
	[TransactionStatus] [varchar](100) NULL,
	[TransactionIsActive] [bit] NULL,
	[TransactionUpdatedDateTime] [date] NULL,
	[TransactionPayerPlanID] varchar(50)
	)

/*Load Charges into @Staging*/
	Print 'Step 1.1:  Loading Charges and Credit Adjustments into @Staging...'
	INSERT INTO @Staging
	([TransactionID]
      ,[TransactionDatasourceID]
      ,[TransactionSourceID]
      ,[TransactionParentSourceID]
      ,[TransactionVisitID]
      ,[TransactionAccountID]
      ,[TransactionDepartmentID]
      ,[TransactionPayerID]
      ,[TransactionBillingProviderID]
      ,[TransactionBillingType]
      ,[TransactionType]
      ,[TransactionSubType]
      ,[TransactionRevenueCode]
      ,[TransactionRevenueCodeDescription]
      ,[TransactionCode]
      ,[TransactionDescription]
      ,[TransactionCPTCode]
      ,[TransactionCPTDescription]
      ,[TransactionModifier1]
      ,[TransactionModifier2]
      ,[TransactionModifier3]
      ,[TransactionModifier4]
      ,[TransactionUnits]
      ,[TransactionAmount]
      ,[TransactionRVU]
      ,[TransactionDateOfService]
      ,[TransactionDateOfPosting]
      ,[TransactionDateOfBilling]
      ,[TransactionDateOfVoid]
      ,[TransactionReportingPeriodID]
      ,[TransactionPlaceOfServiceCode]
      ,[TransactionPlaceOfServiceType]
      ,[TransactionPatientID]
      ,[TransactionGLType]
      ,[TransactionStatus]
      ,[TransactionIsActive]
      ,[TransactionUpdatedDateTime]
	  ,[TransactionPayerPlanID]
	)


	SELECT   --v.Voucher_Number,tx.update_status,
		CONCAT('12~',tx.Service_ID) as TransactionID
		,'12' as TransactionDatasourceID
		,convert(varchar(50),tx.Service_ID) as TransactionSourceID
		,convert(varchar(50),tx.Service_ID) AS TransactionParentSourceID
		,CASE WHEN tx.Voucher_Number is not null THEN CONCAT('12~',tx.Voucher_Number,'~',v.Department_ID) END as TransactionVisitID
		,CASE WHEN tx.Voucher_Number is not null THEN CONCAT('12~',tx.Voucher_Number,'~',v.Department_ID) END as TransactionAccountID
		,CASE WHEN v.Voucher_Number is not null THEN CONCAT('12~',v.Department_ID) END as TransactionDepartmentID
		,CASE WHEN COALESCE(tx.Original_Carrier_ID,tx.Billing_Carrier_ID) is not null THEN CONCAT('12~',COALESCE(tx.Original_Carrier_ID,tx.Billing_Carrier_ID)) 
			  WHEN v.Is_Self_Pay = 1 THEN '12~SELF' /*Hard-code selfpay when financial class is self pay*/
			  END as TransactionPayerID
		,CASE WHEN tx.Billing_Dr_ID = '18438' and tx.Refer_Dr_ID is not null THEN CONCAT('12~',tx.Refer_Dr_ID) /*Special exception for Nancy Turner*/
			  WHEN tx.Billing_Dr_ID is not null THEN CONCAT('12~',tx.Billing_Dr_ID ) END as TransactionBillingProviderID
		,'PB' as TransactionBillingType
		,'Charge' as TransactionType
		,'Charge - New' as TransactionSubType
		,NULL as TransactionRevenueCode
		,NULL as TransactionRevenueCodeDescription
		,tx.Procedure_Code as TransactionCode
		,tx.Procedure_Insurance_Descr as TransactionDescription
		,CASE WHEN LEN(tx.Procedure_Code) <> 5 THEN NULL ELSE tx.Procedure_Code END as TransactionCPTCode
		,tx.Procedure_Insurance_Descr as TransactionCPTDescription
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
		,CONCAT(YEAR(rp.start_date),' - ', RIGHT(concat('00',MONTH(rp.start_date)),2)) as TransactionReportingPeriodID
		,bc.Billing_Code AS TransactionPlaceOfServiceCode
		,NULL as TransactionPlaceOfServiceType
		,CONCAT('12~',v.Patient_ID) as PatientID
		--,vch.Patient_Number as PatientNumber
		,CASE WHEN a.[Appt_Type_Abbr] in ('SB','SB GWILL') or a.[Appt_Resource_Descr] like '%smartbeat%' and tx.Procedure_Code in ('92250','93000','93308','93321','93325','93882','93922','93979','94010') THEN 'Smartbeat'
			WHEN tx.Procedure_Code in ('MPDC', '93922') THEN 'MaxPulse'
			WHEN v.Date_Voided is null and tx.Procedure_Code like '7%' and (LEFT(tx.Modifiers,2) = 'TC' OR SUBSTRING(tx.Modifiers,4,2) = 'TC') THEN 'RadTC'
			WHEN pc.[ProcedureCodeCategory] = 'XRAY Only Visits' THEN 'Xray'
			WHEN pc.[ProcedureCodeServiceLine] = 'DME' THEN 'DME'
			WHEN pc.[ProcedureCodeCategory] = 'Ultrasound Only Visit' THEN 'Ultrasound' 
			WHEN pc.[ProcedureCodeCategory] = 'Lab Only Visit' THEN 'Lab' 
			WHEN (a.[Appt_Type_Abbr] = 'ANS GWIL' or a.[Appt_Resource_Descr] = 'AUTONOMIC NERVE TESTING-GWIL') and (a.[Patient_ID] is not null) and (a.[Appt_Status] <> 'X' and a.[Appt_Status] <> 'N')  THEN 'ANS'
			WHEN tx.Procedure_Code in ('51729', '51797', '51784', '51741') THEN 'URO'  
			WHEN tx.Procedure_Code in ('99453', '99454', '99457', '99458', '95249', '95250', '95251') THEN 'Heartcloud'
			WHEN tx.Procedure_Code in ('95250', '95251', '95249') THEN 'CGM' END as TransactionGLType
		,CASE WHEN v.Date_Voided is null THEN 'Active' ELSE 'Voided' END as TransactionStatus 
		,1 as TransactionIsActive
		,GETDATE() as TransactionUpdatedDatetime
		,CASE WHEN COALESCE(tx.Original_Carrier_ID,tx.Billing_Carrier_ID) is not null THEN CONCAT('12~',COALESCE(tx.Original_Carrier_ID,tx.Billing_Carrier_ID)) 
			  WHEN v.Is_Self_Pay = 1 THEN '12~SELF' /*Hard-code selfpay when financial class is self pay*/
			  END as [TransactionPayerPlanID]

	FROM [TIEVMDB03].Ntier_HPI_Customers.[PM].vwGenSvcInfo tx
	inner join [TIEVMDB03].Ntier_HPI_Customers.[PM].vwGenVouchInfo vch on tx.Tenant_ID = vch.Tenant_ID
		and tx.voucher_id = vch.voucher_id
	LEFT JOIN [TIEVMDB03].Ntier_HPI_Customers.[PM].Vouchers v ON v.Voucher_ID = tx.Voucher_ID
	LEFT JOIN [TIEVMDB03].Ntier_HPI_Customers.[PM].POS_BILLING_CODES bc ON bc.Place_Of_Service_ID = v.Place_Of_Service_ID AND bc.Profile_ID = 12 /*Standard POS Type*/ 
	INNER JOIN [TIEVMDB03].Ntier_HPI_Customers.[PM].Procedure_Codes pr WITH (NOLOCK) ON tx.Procedure_Code = pr.Procedure_Code
		and tx.Tenant_ID = pr.Tenant_ID
	left join [TIEVMDB03].Ntier_HPI_Customers.[PM].reporting_periods rp with (nolock) on tx.Tenant_ID = rp.Tenant_ID 
																					and tx.posting_date >= rp.start_date 
																					and tx.posting_date <= isnull(rp.end_date,'2999-12-31')
	left join [TIEVMDB03].Ntier_HPI_Customers.[dbo].[vwGenPatApptInfo] a ON a.Appt_ID = v.Appointment_ID
	LEFT JOIN [HPIDW].[stg].[PBProcedureCodeCategories] pc on tx.Procedure_Code = pc.[ProcedureCode]
	--LEFT JOIN [TIEVMDB03].[Ntier_627200].[PM].Practice_Information PRACTINFO ON PRACTINFO.Tenant_ID = tx.Tenant_ID

	 where 1=1
		AND tx.Update_Status in (1,2,3) -- all so that we pull charge and void
		AND tx.Posting_Date >= '1/1/2019' --DATEADD(DAY,-@DaysToReload, convert(date,GETDATE())) /*Only load transactions from the last 10 days*/

	UNION ALL
	/*PB Transactions - Voids - reversing charge entry*/

	SELECT   --v.Voucher_Number,tx.update_status,
		CONCAT('12~',tx.Service_ID,'~VOID') AS TransactionID
		,'12' as TransactionDatasourceID
		,CONCAT(tx.Service_ID,'~VOID') as TransactionSourceID
		,convert(varchar(50),tx.Service_ID) AS TransactionParentSourceID
		,CASE WHEN tx.Voucher_Number is not null THEN CONCAT('12~',tx.Voucher_Number,'~',v.Department_ID) END as TransactionVisitID
		,CASE WHEN tx.Voucher_Number is not null THEN CONCAT('12~',tx.Voucher_Number,'~',v.Department_ID) END as TransactionAccountID
		,CASE WHEN v.Department_ID is not null THEN CONCAT('12~',v.Department_ID) END as TransactionDepartmentID
		,CASE WHEN COALESCE(tx.Original_Carrier_ID,tx.Billing_Carrier_ID) is not null THEN CONCAT('12~',COALESCE(tx.Original_Carrier_ID,tx.Billing_Carrier_ID)) 
			  WHEN v.Is_Self_Pay = 1 THEN '12~SELF' /*Hard-code selfpay when financial class is self pay*/
			  END as TransactionPayerID
		,CASE WHEN tx.Billing_Dr_ID = '18438' and tx.Refer_Dr_ID is not null THEN CONCAT('12~',tx.Refer_Dr_ID) /*Special exception for Nancy Turner*/
			  WHEN tx.Billing_Dr_ID is not null THEN CONCAT('12~',tx.Billing_Dr_ID ) END as TransactionBillingProviderID
		,'PB' as TransactionBillingType
		,'Charge' as TransactionType
		,'Charge - Void' as TransactionSubType
		,NULL as TransactionRevenueCode
		,NULL as TransactionRevenueCodeDescription
		,tx.Procedure_Code as TransactionCode
		,tx.Procedure_Insurance_Descr as TransactionDescription
		,CASE WHEN LEN(tx.Procedure_Code) <> 5 THEN NULL ELSE tx.Procedure_Code END as TransactionCPTCode
		,tx.Procedure_Insurance_Descr as TransactionCPTDescription
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
		,CONCAT(YEAR(rp.start_date),' - ', RIGHT(concat('00',MONTH(rp.start_date)),2)) as TransactionReportingPeriodID
		,bc.Billing_Code AS TransactionPlaceOfServiceCode
		,NULL as TransactionPlaceOfServiceType
		,CONCAT('12~',v.Patient_ID) as PatientID
		--,vch.Patient_Number as PatientNumber
		,CASE WHEN a.[Appt_Type_Abbr] in ('SB','SB GWILL') or a.[Appt_Resource_Descr] like '%smartbeat%' and tx.Procedure_Code in ('92250','93000','93308','93321','93325','93882','93922','93979','94010') THEN 'Smartbeat'
			WHEN tx.Procedure_Code in ('MPDC', '93922') THEN 'MaxPulse'
			WHEN v.Date_Voided is null and tx.Procedure_Code like '7%' and (LEFT(tx.Modifiers,2) = 'TC' OR SUBSTRING(tx.Modifiers,4,2) = 'TC') THEN 'RadTC'
			WHEN pc.[ProcedureCodeCategory] = 'XRAY Only Visits' THEN 'Xray'
			WHEN pc.[ProcedureCodeServiceLine] = 'DME' THEN 'DME'
			WHEN pc.[ProcedureCodeCategory] = 'Ultrasound Only Visit' THEN 'Ultrasound' 
			WHEN pc.[ProcedureCodeCategory] = 'Lab Only Visit' THEN 'Lab' 
			WHEN (a.[Appt_Type_Abbr] = 'ANS GWIL' or a.[Appt_Resource_Descr] = 'AUTONOMIC NERVE TESTING-GWIL') and (a.[Patient_ID] is not null) and (a.[Appt_Status] <> 'X' and a.[Appt_Status] <> 'N')  THEN 'ANS'  
			WHEN tx.Procedure_Code in ('51729', '51797', '51784', '51741') THEN 'URO'  
			WHEN tx.Procedure_Code in ('99453', '99454', '99457', '99458', '95249', '95250', '95251') THEN 'Heartcloud'
			WHEN tx.Procedure_Code in ('95250', '95251', '95249') THEN 'CGM' END as TransactionGLType
		,CASE WHEN v.Date_Voided is null THEN 'Active' ELSE 'Voided' END as TransactionStatus 
		,1 as TransactionIsActive
		,GETDATE() as TransactionUpdatedDatetime
		,CASE WHEN COALESCE(tx.Original_Carrier_ID,tx.Billing_Carrier_ID) is not null THEN CONCAT('12~',COALESCE(tx.Original_Carrier_ID,tx.Billing_Carrier_ID)) 
			  WHEN v.Is_Self_Pay = 1 THEN '12~SELF' /*Hard-code selfpay when financial class is self pay*/
			  END as TransactionPayerPlanID

	FROM [TIEVMDB03].Ntier_HPI_Customers.[PM].vwGenSvcInfo tx
	inner join [TIEVMDB03].Ntier_HPI_Customers.[PM].vwGenVouchInfo vch on tx.Tenant_ID = vch.Tenant_ID
		and tx.voucher_id = vch.voucher_id
	LEFT JOIN [TIEVMDB03].Ntier_HPI_Customers.[PM].Vouchers v ON v.Voucher_ID = tx.Voucher_ID
	LEFT JOIN [TIEVMDB03].Ntier_HPI_Customers.[PM].POS_BILLING_CODES bc ON bc.Place_Of_Service_ID = v.Place_Of_Service_ID AND bc.Profile_ID = 12 /*Standards POS Type*/ 
	INNER JOIN [TIEVMDB03].Ntier_HPI_Customers.[PM].Procedure_Codes pr WITH (NOLOCK) ON tx.Procedure_Code = pr.Procedure_Code and tx.Tenant_ID = pr.Tenant_ID
	left join [TIEVMDB03].Ntier_HPI_Customers.[PM].reporting_periods rp with (nolock) on tx.Tenant_ID = rp.Tenant_ID 
																					and v.Date_Voided >= rp.start_date 
																					and v.Date_Voided <= isnull(rp.end_date,'2999-12-31')
	left join [TIEVMDB03].Ntier_HPI_Customers.[dbo].[vwGenPatApptInfo] a ON a.Appt_ID = v.Appointment_ID
	LEFT JOIN [HPIDW].[stg].[PBProcedureCodeCategories] pc on tx.Procedure_Code = pc.[ProcedureCode]
	--LEFT JOIN [TIEVMDB03].[Ntier_627200].[PM].Practice_Information PRACTINFO ON PRACTINFO.Tenant_ID = tx.Tenant_ID

	 where 1=1
		AND tx.Update_Status = 3 -- all so that we pull charge and void
		AND v.date_voided >= '1/1/2019' --DATEADD(DAY,-@DaysToReload, convert(date,GETDATE())) /*Only load transactions from the last 10 days*/ 

/*Load Payments and other adjustments into @Staging*/
	Print 'Step 1.2:  Loading Payments into @Staging...'
	INSERT INTO @Staging
	([TransactionID]
      ,[TransactionDatasourceID]
      ,[TransactionSourceID]
      ,[TransactionParentSourceID]
      ,[TransactionVisitID]
      ,[TransactionAccountID]
      ,[TransactionDepartmentID]
      ,[TransactionPayerID]
      ,[TransactionBillingProviderID]
      ,[TransactionBillingType]
      ,[TransactionType]
      ,[TransactionSubType]
      ,[TransactionRevenueCode]
      ,[TransactionRevenueCodeDescription]
      ,[TransactionCode]
      ,[TransactionDescription]
      ,[TransactionCPTCode]
      ,[TransactionCPTDescription]
      ,[TransactionModifier1]
      ,[TransactionModifier2]
      ,[TransactionModifier3]
      ,[TransactionModifier4]
      ,[TransactionUnits]
      ,[TransactionAmount]
      ,[TransactionRVU]
      ,[TransactionDateOfService]
      ,[TransactionDateOfPosting]
      ,[TransactionDateOfBilling]
      ,[TransactionDateOfVoid]
      ,[TransactionReportingPeriodID]
      ,[TransactionPlaceOfServiceCode]
      ,[TransactionPlaceOfServiceType]
      ,[TransactionPatientID]
      ,[TransactionGLType]
      ,[TransactionStatus]
      ,[TransactionIsActive]
      ,[TransactionUpdatedDateTime]
	  ,[TransactionPayerPlanID]
	)

	SELECT --v.Voucher_Number,tx.update_status,
		CONCAT('12~',tx.Service_Payment_ID, '~', tx.Service_ID) 
		,'12' as TransactionDatasourceID
		,CONCAT(tx.Service_Payment_ID, '~', tx.Service_ID) as TransactionSourceID
		,convert(varchar(50),tx.Service_ID) AS TransactionParentSourceID
		,CASE WHEN svc.Voucher_Number is not null THEN CONCAT('12~',svc.Voucher_Number,'~',v.Department_ID) END as TransactionVisitID
		,CASE WHEN svc.Voucher_Number is not null THEN CONCAT('12~',svc.Voucher_Number,'~',v.Department_ID) END as TransactionAccountID
		,CASE WHEN v.Department_ID is not null THEN CONCAT('12~',v.Department_ID) END as TransactionDepartmentID
		,CASE WHEN tx.Remitting_Carrier_ID IS NULL then '12~SELF'
			  WHEN tx.Remitting_Carrier_ID is not null then CONCAT('12~',tx.Remitting_Carrier_ID)
			  WHEN v.Is_Self_Pay = 1 THEN '12~SELF' /*Hard-code selfpay when financial class is self pay*/
			  END as TransactionPayerID
		,CASE WHEN svc.Billing_Dr_ID = '18438' and svc.Refer_Dr_ID is not null THEN CONCAT('12~',svc.Refer_Dr_ID) /*Special exception for Nancy Turner*/
			  WHEN svc.Billing_Dr_ID is not null THEN CONCAT('12~',svc.Billing_Dr_ID ) END as TransactionBillingProviderID
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
		,NULL as TransactionCPTDescription
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
		,CONCAT(YEAR(rp.start_date),' - ', RIGHT(concat('00',MONTH(rp.start_date)),2)) as TransactionReportingPeriodID
		,NULL AS TransactionPlaceOfServiceCode
		,NULL as TransactionPlaceOfServiceType
		,CONCAT('12~',v.Patient_ID) as PatientID
		--,svc.Patient_Number as PatientNumber
		,NULL as TransactionGLType
		,CASE WHEN tx.Date_Voided is null THEN 'Active' ELSE 'Voided' END as TransactionStatus 
		,1 as TransactionIsActive
		,GETDATE() as TransactionUpdatedDatetime
		,CASE WHEN tx.Remitting_Carrier_ID IS NULL then '12~SELF'
			  WHEN tx.Remitting_Carrier_ID is not null then CONCAT('12~',tx.Remitting_Carrier_ID)
			  WHEN v.Is_Self_Pay = 1 THEN '12~SELF' /*Hard-code selfpay when financial class is self pay*/
			  END as TransactionPayerPlanID
	 --select tx.*
	FROM [TIEVMDB03].Ntier_HPI_Customers.[PM].[vwGenSvcPmtInfo] tx
	INNER JOIN  [TIEVMDB03].Ntier_HPI_Customers.[PM].vwGenSvcInfo AS svc ON tx.Tenant_ID = svc.Tenant_ID
		AND tx.Service_ID = svc.Service_ID
	left join [TIEVMDB03].Ntier_HPI_Customers.[PM].Services ptx on ptx.Service_ID = tx.Service_ID -- Parent Transactions 
	left join [TIEVMDB03].Ntier_HPI_Customers.[PM].Vouchers v ON ptx.Voucher_ID = v.Voucher_ID
	left join [TIEVMDB03].Ntier_HPI_Customers.[PM].reporting_periods rp with (nolock) on tx.Tenant_ID = rp.Tenant_ID 
																					and tx.posting_date >= rp.start_date 
																					and tx.posting_date <= isnull(rp.end_date,'2999-12-31')
	--LEFT JOIN [TIEVMDB03].[Ntier_627200].[PM].Practice_Information PRACTINFO ON PRACTINFO.Tenant_ID = tx.Tenant_ID
	 where 1=1
		--AND rp.abbreviation = 'Aug 2023'
		AND tx.Update_Status in (1,2,3)
		AND tx.Amount <> 0
		AND Transaction_Type in ('A','R','P', 'M')
		AND tx.Posting_Date >= '1/1/2019' --DATEADD(DAY,-@DaysToReload, convert(date,GETDATE())) /*Only load transactions from the last 10 days*/
	
	UNION ALL 
	/*PB Transactions - Reversing payment entry*/

	SELECT --v.Voucher_Number,tx.update_status,
		CONCAT('12~',tx.Service_Payment_ID, '~', tx.Service_ID,'~VOID') as TransactionID
		,'12' as TransactionDatasourceID
		,CONCAT(tx.Service_Payment_ID, '~', tx.Service_ID,'~VOID') as TransactionSourceID
		,convert(varchar(50),tx.Service_ID) AS TransactionParentSourceID
		,CASE WHEN svc.Voucher_Number is not null THEN CONCAT('12~',svc.Voucher_Number,'~',v.Department_ID) END as TransactionVisitID
		,CASE WHEN svc.Voucher_Number is not null THEN CONCAT('12~',svc.Voucher_Number,'~',v.Department_ID) END as TransactionAccountID
		,CASE WHEN v.Department_ID is not null THEN CONCAT('12~',v.Department_ID) END as TransactionDepartmentID
		,CASE WHEN tx.Remitting_Carrier_ID IS NULL then '12~SELF'
			  WHEN tx.Remitting_Carrier_ID is not null then CONCAT('12~',tx.Remitting_Carrier_ID)
			  WHEN v.Is_Self_Pay = 1 THEN '12~SELF' /*Hard-code selfpay when financial class is self pay*/
			  END as TransactionPayerID
		,CASE WHEN svc.Billing_Dr_ID = '18438' and svc.Refer_Dr_ID is not null THEN CONCAT('12~',svc.Refer_Dr_ID) /*Special exception for Nancy Turner*/
			  WHEN svc.Billing_Dr_ID is not null THEN CONCAT('12~',svc.Billing_Dr_ID ) END as TransactionBillingProviderID
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
		,NULL as TransactionCPTDescription
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
		,CONCAT(YEAR(rp.start_date),' - ', RIGHT(concat('00',MONTH(rp.start_date)),2)) as TransactionReportingPeriodID
		
		,NULL AS TransactionPlaceOfServiceCode
		,NULL as TransactionPlaceOfServiceType
		,CONCAT('12~',v.Patient_ID) as PatientID
		--,svc.Patient_Number as PatientNumber
		,NULL as TransactionGLType
		,CASE WHEN tx.Date_Voided is null THEN 'Active' ELSE 'Voided' END as TransactionStatus 
		,1 as TransactionIsActive
		,GETDATE() as TransactionUpdatedDatetime
		,CASE WHEN tx.Remitting_Carrier_ID IS NULL then '12~SELF'
			  WHEN tx.Remitting_Carrier_ID is not null then CONCAT('12~',tx.Remitting_Carrier_ID)
			  WHEN v.Is_Self_Pay = 1 THEN '12~SELF' /*Hard-code selfpay when financial class is self pay*/
			  END as TransactionPayerPlanID
	 --select tx.*
	 FROM [TIEVMDB03].Ntier_HPI_Customers.[PM].[vwGenSvcPmtInfo] tx
	INNER JOIN  [TIEVMDB03].Ntier_HPI_Customers.[PM].vwGenSvcInfo AS svc ON tx.Tenant_ID = svc.Tenant_ID
		AND tx.Service_ID = svc.Service_ID
	left join [TIEVMDB03].Ntier_HPI_Customers.[PM].Services ptx on ptx.Service_ID = tx.Service_ID -- Parent Transactions 
	left join [TIEVMDB03].Ntier_HPI_Customers.[PM].Vouchers v ON ptx.Voucher_ID = v.Voucher_ID
	left join [TIEVMDB03].Ntier_HPI_Customers.[PM].reporting_periods rp with (nolock) on tx.Tenant_ID = rp.Tenant_ID 
																					and tx.date_voided >= rp.start_date 
																					and tx.date_voided <= isnull(rp.end_date,'2999-12-31')
	--LEFT JOIN [TIEVMDB03].[Ntier_627200].[PM].Practice_Information PRACTINFO ON PRACTINFO.Tenant_ID = tx.Tenant_ID
	 where 1=1
		AND Transaction_Type in ('A','R','P', 'M')
		AND tx.Update_Status = 3
		AND tx.Amount <> 0
		AND tx.date_voided >= '1/1/2019' --DATEADD(DAY,-@DaysToReload, convert(date,GETDATE()))


/*Check @Staging records and delete/reload into fact.TransactionsPB*/
	Print 'Step 2:  Checking number of records in @Staging...'
	IF (SELECT COUNT(1) FROM @Staging) > 100 
		BEGIN
		Print 'Step 2.1:  More than 100 records exist in @Staging.  Proceeding with DELETE...'
		DELETE FROM fact.TransactionsPB WHERE TransactionDatasourceID = 12 --AND TransactionDateOfPosting >= DATEADD(DAY,-@DaysToReload, convert(date,GETDATE())) 

		Print 'Step 2.2:  Proceeding with INSERT...'
		INSERT INTO fact.TransactionsPB
		([TransactionID]
		  ,[TransactionDatasourceID]
		  ,[TransactionSourceID]
		  ,[TransactionParentSourceID]
		  ,[TransactionVisitID]
		  ,[TransactionAccountID]
		  ,[TransactionDepartmentID]
		  ,[TransactionPayerID]
		  ,[TransactionBillingProviderID]
		  ,[TransactionBillingType]
		  ,[TransactionType]
		  ,[TransactionSubType]
		  ,[TransactionRevenueCode]
		  ,[TransactionRevenueCodeDescription]
		  ,[TransactionCode]
		  ,[TransactionDescription]
		  ,[TransactionCPTCode]
		  ,[TransactionCPTDescription]
		  ,[TransactionModifier1]
		  ,[TransactionModifier2]
		  ,[TransactionModifier3]
		  ,[TransactionModifier4]
		  ,[TransactionUnits]
		  ,[TransactionAmount]
		  ,[TransactionRVU]
		  ,[TransactionDateOfService]
		  ,[TransactionDateOfPosting]
		  ,[TransactionDateOfBilling]
		  ,[TransactionDateOfVoid]
		  ,[TransactionReportingPeriodID]
		  ,[TransactionPlaceOfServiceCode]
		  ,[TransactionPlaceOfServiceType]
		  ,[TransactionPatientID]
		  ,[TransactionGLType]
		  ,[TransactionStatus]
		  ,[TransactionIsActive]
		  ,[TransactionUpdatedDateTime]
		  ,TransactionPayerPlanID
		)

	SELECT [TransactionID]
		  ,[TransactionDatasourceID]
		  ,[TransactionSourceID]
		  ,[TransactionParentSourceID]
		  ,[TransactionVisitID]
		  ,[TransactionAccountID]
		  ,[TransactionDepartmentID]
		  ,[TransactionPayerID]
		  ,[TransactionBillingProviderID]
		  ,[TransactionBillingType]
		  ,[TransactionType]
		  ,[TransactionSubType]
		  ,[TransactionRevenueCode]
		  ,[TransactionRevenueCodeDescription]
		  ,[TransactionCode]
		  ,[TransactionDescription]
		  ,[TransactionCPTCode]
		  ,[TransactionCPTDescription]
		  ,[TransactionModifier1]
		  ,[TransactionModifier2]
		  ,[TransactionModifier3]
		  ,[TransactionModifier4]
		  ,[TransactionUnits]
		  ,[TransactionAmount]
		  ,[TransactionRVU]
		  ,[TransactionDateOfService]
		  ,[TransactionDateOfPosting]
		  ,[TransactionDateOfBilling]
		  ,[TransactionDateOfVoid]
		  ,[TransactionReportingPeriodID]
		  ,[TransactionPlaceOfServiceCode]
		  ,[TransactionPlaceOfServiceType]
		  ,[TransactionPatientID]
		  ,[TransactionGLType]
		  ,[TransactionStatus]
		  ,[TransactionIsActive]
		  ,[TransactionUpdatedDateTime]
		  ,TransactionPayerPlanID
	FROM @Staging
	--WHERE TransactionID = '5~42294501~82061025~42294501200441'

	END
	ELSE
	Print 'Less than 100 records in @Staging. Ending Job...'
END
GO
