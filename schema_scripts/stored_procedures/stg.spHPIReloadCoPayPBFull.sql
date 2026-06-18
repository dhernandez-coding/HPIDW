CREATE PROCEDURE [stg].[spHPIReloadCoPayPBFull]	AS
BEGIN		
	-- ========================================================================
	-- Author:		Eric Silvestri
	-- Create date: 1-13-2025
	-- Description:	Loads PB CoPay records from EPIC and APM into rpt.CoPayPB.
	-- ========================================================================

-- Step 1: Delete existing records for the data source
DELETE FROM rpt.CoPayPB 


-- Step 2: Insert into rpt.CoPayPB
INSERT INTO rpt.CoPayPB (
	[CopayDataSourceID],
	[CopayVisitID],
	[CopayPatientID],
	[CopayProviderID],
	[CopayDepartmentID],
	[CopayPayerID],
	[CopayPracticeID],
	[CopayUserEntryName],
	[CopayDateOfService],
	[CopayDateOfPayment],
	[CopayDOSFlag],
	[CopayDue],
	[CopayCollected],
	[CopayUpdateDate]
)



SELECT
	5 as CopayDataSourceID
	,CONCAT('5~', sa.PAT_ENC_CSN_ID) as CopayVisitID
	,CONCAT('5~', sa.PAT_ID) as CopayPatientID
	,CONCAT('5~', sa.PROV_ID) as CopayProviderID
	,CONCAT('5~', sa.DEPARTMENT_ID) as CopayDepartmentID
	,t.TransactionPayerID as CopayPayerID
	,p.PracticeID as CopayPracticeID
	,sa.COPAY_USER_NAME_WID as CopayUserEntryName
	,CONVERT(VARCHAR(10), sa.CONTACT_DATE, 101) as CopayDateOfService
	,CONVERT(VARCHAR(10), cp.COPAY_COLL_DTTM, 101) as CopayDateOfPayment
	,CASE WHEN CONVERT(VARCHAR(10), sa.CONTACT_DATE, 101) = CONVERT(VARCHAR(10), cp.COPAY_COLL_DTTM, 101) THEN 'Y' ELSE 'N' END AS CopayDOSFlag
	,sa.COPAY_DUE as CopayDue
	,sa.COPAY_COLLECTED as CopayCollected
	,GETDATE() as CopayUpdateDate
FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].V_SCHED_APPT sa
 LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].PAT_ENC_ARPB_COPAY cp on cp.PAT_ENC_CSN_ID = sa.PAT_ENC_CSN_ID
 LEFT JOIN [HPIDW].[map].[PracticeDepartments] p on p.DepartmentID = CONCAT('5~', sa.DEPARTMENT_ID)
 LEFT JOIN  [HPIDW].[fact].[vTransactionsPB] t on t.TransactionVisitID = CONCAT('5~',sa.PAT_ENC_CSN_ID)
where sa.DEPARTMENT_NAME like ('HPIP%') or sa.DEPARTMENT_NAME like ('TPG%') 
	and sa.APPT_STATUS_NAME = 'Completed' 
	and sa.APPT_DTTM >= '2023-01-01 00:00:00.000'
GROUP BY 
	sa.PAT_ENC_CSN_ID
	,sa.PAT_ID
	,sa.PROV_ID
	,sa.DEPARTMENT_ID
	,t.TransactionPayerID
	,sa.PAT_ENC_CSN_ID
	,p.PracticeID
	,sa.COPAY_USER_NAME_WID
	,sa.CONTACT_DATE
	,cp.COPAY_COLL_DTTM
	,sa.COPAY_DUE
	,sa.COPAY_COLLECTED



UNION ALL

SELECT
	sub.[CopayDataSourceID],
	sub.[CopayVisitID],
	sub.[CopayPatientID],
	sub.[CopayProviderID],
	sub.[CopayDepartmentID],
	sub.CopayPayerID,
	p.PracticeID as CopayPracticeID,
	sub.[CopayUserEntryName],
	sub.[CopayDateOfService],
	sub.[CopayDateOfPayment],
	sub.CopayDOSFlag,
	sub.[CopayDue],
	sub.[CopayCollected],
	sub.[CopayUpdateDate]
FROM(

		SELECT 
			1 as CopayDataSourceID
			,CONCAT('1~', si.Voucher_Number) as CopayVisitID
			,CONCAT('1~', si.Patient_Number) as CopayPatientID
			,CONCAT('1~', si.Actual_Dr_ID) as CopayProviderID
			,CONCAT('1~', d.Department_ID) as CopayDepartmentID
			,CASE WHEN gv.Billing_Carrier_ID is null THEN CONCAT('1~', gv.Original_Carrier_ID)  --spi.Current_Carrier_ID
				ELSE CONCAT('1~', gv.Billing_Carrier_ID) END as CopayPayerID
			,ol.Name as CopayUserEntryName
			,si.Service_Date_From  as CopayDateOfService
			,spi.Date_Paid as CopayDateOfPayment
			,CASE WHEN CONVERT(VARCHAR(10), si.Service_Date_From, 101) = CONVERT(VARCHAR(10), spi.Date_Paid, 101) THEN 'Y' ELSE 'N' END AS CopayDOSFlag
			,gv.CoPay_Amount_Due as CopayDue
			,spi.CoPayment as CopayCollected
			,GETDATE() as CopayUpdateDate
		FROM [TIEVMDB03].[Ntier_627200].[PM].[vwGenSvcInfo] si
			LEFT JOIN [TIEVMDB03].[Ntier_627200].[PM].[vwGenSvcPmtInfo] spi ON spi.Service_ID = si.Service_ID
			LEFT JOIN [TIEVMDB03].[Ntier_627200].[PM].[vwGenVouchInfo] gv ON gv.Voucher_Number = si.Voucher_Number
			LEFT JOIN [TIEVMDB03].[Ntier_627200].[PM].[vwOperList] ol ON ol.Abbreviation = spi.Operator_abbr
			LEFT JOIN [TIEVMDB03].[Ntier_627200].[PM].Departments d ON d.Abbreviation = si.Department_Abbr
		WHERE spi.Transaction_Code_Descr LIKE ('Co-pay%') AND si.Service_Date_From >= '2023-01-01 00:00:00.000' --and si.Service_ID = 54
		GROUP BY
			si.Voucher_Number
			,si.Patient_Number
			,si.Actual_Dr_ID
			,d.Department_ID
			,gv.Original_Carrier_ID
			,gv.Billing_Carrier_ID
			,ol.Name
			,si.Service_Date_From
			,spi.Date_Paid
			,gv.CoPay_Amount_Due
			,spi.CoPayment
			) sub
		LEFT JOIN [HPIDW].[map].[PracticeProviders] p on p.ProviderID = sub.CopayProviderID
END;
GO
