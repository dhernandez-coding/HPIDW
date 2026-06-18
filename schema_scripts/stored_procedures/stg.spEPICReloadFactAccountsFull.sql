-- =============================================
-- Author:		Zeke Herrera
-- Create date: 08/09/2023
-- Description:	Extracts Accounts data from HSP_Account and loads into Fact.Accounts
-- Change control: 
-- 1. 05/09/2025 - Diego Hernandez - Adding safe load
-- 2. 10/29/2025 - Diego Hernandez - Change temptable and openquery 
-- =============================================
CREATE PROCEDURE [stg].[spEPICReloadFactAccountsFull] AS
BEGIN
    SET NOCOUNT ON;

    PRINT 'Creating #StagingTable...';

    -- Drop temp table if it already exists
    IF OBJECT_ID('tempdb..#StagingTable') IS NOT NULL
        DROP TABLE #StagingTable;


    CREATE TABLE #StagingTable (
        AccountID VARCHAR(100),
        AccountDataSourceID INT,
        AccountSourceID VARCHAR(100),
        AccountReferenceNumber VARCHAR(100),
        AccountPatientID VARCHAR(100),
        AccountLocationID VARCHAR(100),
        AccountDepartmentID VARCHAR(100),
        AccountFinancialClassID VARCHAR(100),
        AccountPrimaryPayerID VARCHAR(100),
        AccountPrimaryPayerPlanID VARCHAR(100),
        AccountPrimaryProviderID VARCHAR(100),
        AccountAdmittingProviderID VARCHAR(100),
        AccountAttendingProviderID VARCHAR(100),
        AccountReferringProviderID VARCHAR(100),
        AccountDateOfService DATE,
        AccountDateOfAdmission DATETIME,
        AccountDateOfDischarge DATETIME,
        AccountDateOfBilling DATETIME,
        AccountDateOfClosing DATETIME,
        AccountDateOfZeroBalance DATETIME,
        AccountDateOfBadDebtWriteOff DATETIME,
        AccountTotalCharges MONEY,
        AccountTotalAdjustments MONEY,
        AccountTotalPayments MONEY,
        AccountTotalRefunds MONEY,
        AccountTotalBalance MONEY,
        AccountStatus VARCHAR(100),
        AccountClass VARCHAR(100),
        AccountType VARCHAR(100),
        AccountService VARCHAR(100),
        AccountBillingStatus VARCHAR(100),
        AccountCodingStatus VARCHAR(100),
        AccountCodingStatusDatetime DATETIME,
        AccountDRG VARCHAR(100),
        AccountDRGDescription VARCHAR(1000),
        AccountDRGType VARCHAR(100),
        AccountDRGMDC VARCHAR(100),
        AccountDRGCMI DECIMAL(18,4),
        AccountDRGGMLOS DECIMAL(18,2),
        AccountIsRecurring BIT,
        AccountIsActive BIT,
        AccountUpdatedDatetime DATETIME,
        AccountEmployerName VARCHAR(100),
        AccountBeneficiaryNumber VARCHAR(100),
        AccountGuarantorName NVARCHAR(155),
        AccountGuarantorID NVARCHAR(150)
    );

    -- Insert source query into staging table
INSERT INTO #StagingTable
SELECT *
FROM OPENQUERY([CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM],
'
    SELECT 
        CONCAT(''5~'', a.HSP_ACCOUNT_ID) AS AccountID,
        5 AS AccountDataSourceID,
        a.HSP_ACCOUNT_ID AS AccountSourceID,
        a.HSP_ACCOUNT_ID AS AccountReferenceNumber,
        CONCAT(''5~'', a.PAT_ID) AS AccountPatientID,
        CONCAT(''5~'', COALESCE(a.DISCH_LOC_ID, a.ADM_LOC_ID, a.LOC_ID)) AS AccountLocationID,
        CASE WHEN COALESCE(a.DISCH_DEPT_ID, a.ADM_DEPARMENT_ID) IS NOT NULL
            THEN CONCAT(''5~'', COALESCE(a.DISCH_DEPT_ID, a.ADM_DEPARMENT_ID)) END AS AccountDepartmentID,
        CASE WHEN a.ACCT_FIN_CLASS_C IS NULL THEN NULL ELSE CONCAT(''5~'', a.ACCT_FIN_CLASS_C) END AS AccountFinancialClassID,
        CASE WHEN a.PRIMARY_PAYOR_ID IS NULL THEN NULL ELSE CONCAT(''5~'', a.PRIMARY_PAYOR_ID) END AS AccountPrimaryPayerID,
        CASE WHEN a.PRIMARY_PLAN_ID IS NULL THEN NULL ELSE CONCAT(''5~'', a.PRIMARY_PLAN_ID) END AS AccountPrimaryPayerPlanID,
        CASE WHEN a.ATTENDING_PROV_ID IS NULL THEN NULL ELSE CONCAT(''5~'', a.ATTENDING_PROV_ID) END AS AccountPrimaryProviderID,
        CASE WHEN a.ATTENDING_PROV_ID IS NULL THEN NULL ELSE CONCAT(''5~'', a.ATTENDING_PROV_ID) END AS AccountAdmittingProviderID,
        CASE WHEN a.ATTENDING_PROV_ID IS NULL THEN NULL ELSE CONCAT(''5~'', a.ATTENDING_PROV_ID) END AS AccountAttendingProviderID,
        CASE WHEN a.REFERRING_PROV_ID IS NULL THEN NULL ELSE CONCAT(''5~'', a.REFERRING_PROV_ID) END AS AccountReferringProviderID,
        CONVERT(date, COALESCE(a.ADM_DATE_TIME, e2.EXP_ADMISSION_TIME)) AS AccountDateOfService,
        COALESCE(a.ADM_DATE_TIME, e2.EXP_ADMISSION_TIME) AS AccountDateOfAdmission,
        a.DISCH_DATE_TIME AS AccountDateOfDischarge,
        a.ACCT_BILLED_DATE AS AccountDateOfBilling,
        a.ACCT_CLOSE_DATE AS AccountDateOfClosing,
        a.ACCT_ZERO_BAL_DT AS AccountDateOfZeroBalance,
        NULL AS AccountDateOfBadDebtWriteOff,
        a.TOT_CHGS AS AccountTotalCharges,
        a.TOT_ADJ AS AccountTotalAdjustments,
        a.TOT_PMTS AS AccountTotalPayments,
        NULL AS AccountTotalRefunds,
        a.TOT_ACCT_BAL AS AccountTotalBalance,
        COALESCE(ps.NAME, st.NAME) AS AccountStatus,
        bc.NAME AS AccountClass,
        ac.NAME AS AccountType,
        svc.NAME AS AccountService,
        bs.NAME AS AccountBillingStatus,
        cs.NAME AS AccountCodingStatus,
        a.CODING_DATETIME AS AccountCodingStatusDatetime,
        drg.DRG_NUMBER AS AccountDRG,
        drg.DRG_NAME AS AccountDRGDescription,
        drgt.NAME AS AccountDRGType,
        drg.DRG_MDC_C AS AccountDRGMDC,
        a.BILL_DRG_WEIGHT AS AccountDRGCMI,
        a.BILL_DRG_GMLOS AS AccountDRGGMLOS,
        CASE WHEN a.RECUR_PARENT_ID IS NOT NULL THEN 1 ELSE 0 END AS AccountIsRecurring,
        1 AS AccountIsActive,
        GETDATE() AS AccountUpdatedDatetime,
        CASE
            WHEN aa.empr_id_cmt IS NOT NULL THEN aa.empr_id_cmt
            WHEN cov.subscr_empr_id_cmt IS NOT NULL AND aa.empr_id_cmt IS NULL THEN cov.subscr_empr_id_cmt
            WHEN cov.payor_id = 24004 AND (cov.SUBSCR_SEX_C IS NULL OR cov.SUBSCR_SEX_C = 3)
                 AND cov.subscr_empr_id_cmt IS NULL AND aa.empr_id_cmt IS NULL THEN cov.SUBSCR_NAME
            WHEN a.PRIMARY_PAYOR_ID = 24004 AND epp.benefit_plan_name IS NOT NULL
                 AND cov.subscr_empr_id_cmt IS NULL AND aa.empr_id_cmt IS NULL THEN epp.benefit_plan_name
            ELSE NULL
        END AS AccountEmployerName,
        cov.SUBSCR_NUM AS AccountBeneficiaryNumber,
        a.GUAR_NAME AS AccountGuarantorName,
        a.GUARANTOR_ID AS AccountGuarantorID
    FROM        [CLARITY].[ORGFILTER].HSP_ACCOUNT a
	left join   [CLARITY].[ORGFILTER].HSP_ACCOUNT_3 a3 ON a3.HSP_ACCOUNT_ID = a.HSP_ACCOUNT_ID
	left join   [CLARITY].[ORGFILTER].ZC_ACCT_BILLSTS_HA bs ON bs.ACCT_BILLSTS_HA_C = a.ACCT_BILLSTS_HA_C
	left join   [CLARITY].[ORGFILTER].ZC_ACCT_CLASS_HA ac ON ac.ACCT_CLASS_HA_C = a.ACCT_CLASS_HA_C
	left join   [CLARITY].[ORGFILTER].ZC_ACCT_BASECLS_HA bc ON bc.ACCT_BASECLS_HA_C = a.ACCT_BASECLS_HA_C
	left join   [CLARITY].[ORGFILTER].ZC_ADM_SOURCE src ON src.ADMIT_SOURCE_C = a.ADMISSION_SOURCE_C
	left join   [CLARITY].[ORGFILTER].ZC_CODING_STS_HA cs ON cs.CODING_STATUS_C = a.CODING_STATUS_C
	left join   [CLARITY].[ORGFILTER].HSP_ACCT_PAT_CSN csn ON csn.HSP_ACCOUNT_ID = a.HSP_ACCOUNT_ID and csn.LINE = 1 /*First CSN only*/
	left join   [CLARITY].[ORGFILTER].PAT_ENC e1 ON e1.PAT_ENC_CSN_ID = COALESCE(a.PRIM_ENC_CSN_ID,csn.PAT_ENC_CSN_ID)
	left join   [CLARITY].[ORGFILTER].ZC_APPT_STATUS st ON st.APPT_STATUS_C = e1.APPT_STATUS_C
	--left join [CLARITY].[ORGFILTER].ZC_CANCEL_REASON cr ON cr.CANCEL_REASON_C = e1.CANCEL_REASON_C
	--left join  et ON et.DISP_ENC_TYPE_C = e1.ENC_TYPE_C
	left join   [CLARITY].[ORGFILTER].PAT_ENC_HSP e2 ON e2.PAT_ENC_CSN_ID = a.PRIM_ENC_CSN_ID
	left join   [CLARITY].[ORGFILTER].[ZC_PAT_STATUS] ps ON ps.ADT_PATIENT_STAT_C = e2.ADT_PATIENT_STAT_C
	left join   [CLARITY].[ORGFILTER].ZC_DISCH_DESTIN_HA dd ON dd.DISCH_DESTIN_HA_C = a.DISCH_DESTIN_HA_C
	left join   [CLARITY].[ORGFILTER].CLARITY_DRG drg ON a.FINAL_DRG_ID = drg.DRG_ID
	left join   [CLARITY].[ORGFILTER].[ZC_DRG_CASE_TYPE] drgt ON drgt.DRG_CASE_TYPE_C = drg.DRG_CASE_TYPE_C
	left join   [CLARITY].[ORGFILTER].HSP_ACCT_SBO sbo ON sbo.HSP_ACCOUNT_ID = a.HSP_ACCOUNT_ID
	left join   [CLARITY].[ORGFILTER].[ZC_PAT_SERVICE] svc on svc.HOSP_SERV_C = a.PRIM_SVC_HA_C
	--left join [CLARITY].[ORGFILTER].HSP_ACCT_CPT_CODES cpt ON cpt.HSP_ACCOUNT_ID = a.HSP_ACCOUNT_ID and cpt.LINE = 1
	--left join [CLARITY].[ORGFILTER].HSP_ACCT_PX_LIST px ON px.HSP_ACCOUNT_ID = a.HSP_ACCOUNT_ID and px.LINE = 1
	--left join [CLARITY].[ORGFILTER].CL_ICD_PX icd ON icd.ICD_PX_ID = px.FINAL_ICD_PX_ID
	--left join [CLARITY].[ORGFILTER].HSP_ACCT_DX_LIST dx ON dx.HSP_ACCOUNT_ID = a.HSP_ACCOUNT_ID and dx.LINE = 1
	--left join [CLARITY].[ORGFILTER].[CLARITY_EDG] edg ON edg.DX_ID = dx.DX_ID
	left join   [CLARITY].[ORGFILTER].account aa on a.HSP_ACCOUNT_ID = aa.sbo_hsp_account_id
	--left join [CLARITY].[ORGFILTER].CLARITY_EEP eep on aa.employer_id = emp.employer_id
	left join   [CLARITY].[ORGFILTER].COVERAGE cov on a.COVERAGE_ID = cov.COVERAGE_ID
	left join   [CLARITY].[ORGFILTER].CLARITY_EPP epp on a.PRIMARY_PLAN_ID = epp.benefit_plan_id
') AS epic_accounts;

-- Safety check and transaction
    IF (SELECT COUNT(1) FROM #StagingTable) >= 10
    BEGIN
        BEGIN TRANSACTION;
            PRINT 'At least 10 accounts found. Deleting and reloading fact.Accounts...';

            DELETE FROM fact.Accounts WHERE AccountDataSourceID = 5;

            INSERT INTO fact.Accounts (
                AccountID,
                AccountDataSourceID,
                AccountSourceID,
                AccountReferenceNumber,
                AccountPatientID,
                AccountLocationID,
                AccountDepartmentID,
                AccountFinancialClassID,
                AccountPrimaryPayerID,
                AccountPrimaryPayerPlanID,
                AccountPrimaryProviderID,
                AccountAdmittingProviderID,
                AccountAttendingProviderID,
                AccountReferringProviderID,
                AccountDateOfService,
                AccountDateOfAdmission,
                AccountDateOfDischarge,
                AccountDateOfBilling,
                AccountDateOfClosing,
                AccountDateOfZeroBalance,
                AccountDateOfBadDebtWriteOff,
                AccountTotalCharges,
                AccountTotalAdjustments,
                AccountTotalPayments,
                AccountTotalRefunds,
                AccountTotalBalance,
                AccountStatus,
                AccountClass,
                AccountType,
                AccountService,
                AccountBillingStatus,
                AccountCodingStatus,
                AccountCodingStatusDatetime,
                AccountDRG,
                AccountDRGDescription,
                AccountDRGType,
                AccountDRGMDC,
                AccountDRGCMI,
                AccountDRGGMLOS,
                AccountIsRecurring,
                AccountIsActive,
                AccountUpdatedDatetime,
                AccountEmployerName,
                AccountBeneficiaryNumber,
                AccountGuarantorName,
                AccountGuarantorID
            )
            SELECT * FROM #StagingTable;

        COMMIT TRANSACTION;
    END
    ELSE
    BEGIN
        PRINT 'Less than 10 accounts found. Skipping delete and reload.';
    END
END;


--select a.PRIM_SVC_HA_C,a.BILL_DRG_WEIGHT,a.BILL_DRG_GMLOS,* from [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].HSP_ACCOUNT a where a.HSP_ACCOUNT_ID like '6%' and a.ACCT_BASECLS_HA_C = 1 
--select * from [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].CLARITY_DRG drg  WHERE drg.DRG_ID = 4818

-- ########################### OLD QUERY ###########################################################

--    SET NOCOUNT ON;

--    PRINT 'Creating @StagingTable...';

--    DECLARE @StagingTable TABLE (
--        AccountID VARCHAR(100),
--        AccountDataSourceID INT,
--        AccountSourceID VARCHAR(100),
--        AccountReferenceNumber VARCHAR(100),
--        AccountPatientID VARCHAR(100),
--        AccountLocationID VARCHAR(100),
--        AccountDepartmentID VARCHAR(100),
--        AccountFinancialClassID VARCHAR(100),
--        AccountPrimaryPayerID VARCHAR(100),
--        AccountPrimaryPayerPlanID VARCHAR(100),
--        AccountPrimaryProviderID VARCHAR(100),
--        AccountAdmittingProviderID VARCHAR(100),
--        AccountAttendingProviderID VARCHAR(100),
--        AccountReferringProviderID VARCHAR(100),
--        AccountDateOfService DATE,
--        AccountDateOfAdmission DATETIME,
--        AccountDateOfDischarge DATETIME,
--        AccountDateOfBilling DATETIME,
--        AccountDateOfClosing DATETIME,
--        AccountDateOfZeroBalance DATETIME,
--        AccountDateOfBadDebtWriteOff DATETIME,
--        AccountTotalCharges MONEY,
--        AccountTotalAdjustments MONEY,
--        AccountTotalPayments MONEY,
--        AccountTotalRefunds MONEY,
--        AccountTotalBalance MONEY,
--        AccountStatus VARCHAR(100),
--        AccountClass VARCHAR(100),
--        AccountType VARCHAR(100),
--        AccountService VARCHAR(100),
--        AccountBillingStatus VARCHAR(100),
--        AccountCodingStatus VARCHAR(100),
--        AccountCodingStatusDatetime DATETIME,
--        AccountDRG VARCHAR(100),
--        AccountDRGDescription VARCHAR(1000),
--        AccountDRGType VARCHAR(100),
--        AccountDRGMDC VARCHAR(100),
--        AccountDRGCMI DECIMAL(18,4),
--        AccountDRGGMLOS DECIMAL(18,2),
--        AccountIsRecurring BIT,
--        AccountIsActive BIT,
--        AccountUpdatedDatetime DATETIME,
--        AccountEmployerName VARCHAR(100),
--        AccountBeneficiaryNumber VARCHAR(100),
--        AccountGuarantorName NVARCHAR(155),
--        AccountGuarantorID NVARCHAR(150)
--    );

--    -- Insert source query into staging table
--INSERT INTO @StagingTable
--SELECT

--CONCAT('5~',a.HSP_ACCOUNT_ID) as [AccountID]
--,5 as [AccountDataSourceID]
--,a.HSP_ACCOUNT_ID as [AccountSourceID]
--,a.HSP_ACCOUNT_ID as [AccountReferenceNumber]
--,CONCAT('5~',a.PAT_ID) as [AccountPatientID]
--,CONCAT('5~',COALESCE(a.DISCH_LOC_ID, a.ADM_LOC_ID, a.LOC_ID)) as [AccountLocationID]
--,CASE WHEN COALESCE(a.DISCH_DEPT_ID, a.ADM_DEPARMENT_ID) is not null
--	  THEN CONCAT('5~',COALESCE(a.DISCH_DEPT_ID, a.ADM_DEPARMENT_ID)) END as[AccountDepartmentID]
--,CASE WHEN a.ACCT_FIN_CLASS_C is null THEN NULL ELSE CONCAT('5~',a.ACCT_FIN_CLASS_C) END as [AccountFinancialClassID]
--,CASE WHEN a.PRIMARY_PAYOR_ID is null THEN NULL ELSE CONCAT('5~',a.PRIMARY_PAYOR_ID) END as [AccountPrimaryPayerID]
--,CASE WHEN a.PRIMARY_PLAN_ID is null THEN NULL ELSE CONCAT('5~',a.PRIMARY_PLAN_ID) END AS AccountPrimaryPayerPlanID
--,CASE WHEN a.ATTENDING_PROV_ID is null THEN NULL ELSE CONCAT('5~',a.ATTENDING_PROV_ID) END as [AccountPrimaryProviderID]
--,CASE WHEN a.ATTENDING_PROV_ID is null THEN NULL ELSE CONCAT('5~',a.ATTENDING_PROV_ID) END as [AccountAdmittingProviderID]
--,CASE WHEN a.ATTENDING_PROV_ID is null THEN NULL ELSE CONCAT('5~',a.ATTENDING_PROV_ID) END as [AccountAttendingProviderID]
--,CASE WHEN a.REFERRING_PROV_ID is null THEN NULL ELSE CONCAT('5~',a.REFERRING_PROV_ID) END as [AccountReferringProviderID]
--,CONVERT(date,coalesce(a.ADM_DATE_TIME,e2.EXP_ADMISSION_TIME)) as [AccountDateOfService]
--,coalesce(a.ADM_DATE_TIME,e2.EXP_ADMISSION_TIME) as [AccountDateOfAdmission]
--,a.DISCH_DATE_TIME as [AccountDateOfDischarge]
--,a.ACCT_BILLED_DATE as AccountDateOfBilling
--,a.ACCT_CLOSE_DATE as AccountDateOfClosing
--,a.ACCT_ZERO_BAL_DT as AccountDateOfZeroBalance
--,NULL AS AccountDateOfBadDebtWriteOff
--,a.TOT_CHGS as AccountTotalCharges
--,a.TOT_ADJ as AccountTotalAdjustments
--,a.TOT_PMTS as AccountTotalPayments
--,NULL as AccountTotalRefunds
--,A.TOT_ACCT_BAL as AccountTotalBalance
--,COALESCE(ps.Name,st.NAME) as [AccountStatus] 
--,bc.NAME as [AccountClass]
--,ac.NAME as [AccountType]
--,svc.NAME as [AccountService]
--,bs.NAME as [AccountBillingStatus]
--,cs.NAME as AccountCodingStatus
--,a.CODING_DATETIME as AccountCodingStatusDatetime
--,drg.DRG_NUMBER as [AccountDRG]
--,drg.DRG_NAME as AccountDRGDescription
--,drgt.NAME as AccountDRGType
--,drg.DRG_MDC_C as AccountDRGMDC
--,a.BILL_DRG_WEIGHT as AccountDRGCMI
--,a.BILL_DRG_GMLOS as AccountDRGGMLOS
--,CASE WHEN a.RECUR_PARENT_ID is not null THEN 1 ELSE 0 END as AccountIsRecurring
----,CASE WHEN a.IS_ACTIVE_YN = 'Y' THEN 1 ELSE 0 END as [AccountIsActive] /*Closed Hospital Accounts are considered inactive by this logic*/
--,1 as [AccountIsActive]
--,GETDATE() AS [AccountUpdatedDatetime]
--,CASE
--	WHEN aa.empr_id_cmt is not null -- check if employer comment has employer name
--		THEN aa.empr_id_cmt
--	WHEN cov.subscr_empr_id_cmt is not null and aa.empr_id_cmt is null -- check if payment plan comment has employer name (payor ID of 24004 = workers comp)
--		THEN cov.subscr_empr_id_cmt
--	WHEN cov.payor_id = 24004 and (cov.SUBSCR_SEX_C is null OR cov.SUBSCR_SEX_C =3) and cov.subscr_empr_id_cmt is null and aa.empr_id_cmt is null -- check if payment plan subscriber name is an employer name 
--		THEN cov.SUBSCR_NAME
--	WHEN a.PRIMARY_PAYOR_ID = 24004 and epp.benefit_plan_name is not null and cov.subscr_empr_id_cmt is null and aa.empr_id_cmt is null  --  check if payment plan name is an employer name
--		THEN epp.benefit_plan_name
--	--WHEN eep.employer_name is not null and aa.empr_id_cmt is null and cov.subscr_empr_id_cmt is null and a.PRIMARY_PAYOR_ID <> 24004 -- check if employer name is given directly (does not catch "workers comp" consistently)
--	--	THEN eep.employer_name
--	ELSE null
--END AS [AccountEmployerName],
--cov.SUBSCR_NUM as AccountBeneficiaryNumber,
--a.GUAR_NAME as [AccountGuarantorName],
--a.GUARANTOR_ID as [AccountGuarantorID]


--FROM        [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].HSP_ACCOUNT a
--left join   [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].HSP_ACCOUNT_3 a3 ON a3.HSP_ACCOUNT_ID = a.HSP_ACCOUNT_ID
--left join   [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_ACCT_BILLSTS_HA bs ON bs.ACCT_BILLSTS_HA_C = a.ACCT_BILLSTS_HA_C
--left join   [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_ACCT_CLASS_HA ac ON ac.ACCT_CLASS_HA_C = a.ACCT_CLASS_HA_C
--left join   [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_ACCT_BASECLS_HA bc ON bc.ACCT_BASECLS_HA_C = a.ACCT_BASECLS_HA_C
--left join   [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_ADM_SOURCE src ON src.ADMIT_SOURCE_C = a.ADMISSION_SOURCE_C
--left join   [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_CODING_STS_HA cs ON cs.CODING_STATUS_C = a.CODING_STATUS_C
--left join   [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].HSP_ACCT_PAT_CSN csn ON csn.HSP_ACCOUNT_ID = a.HSP_ACCOUNT_ID and csn.LINE = 1 /*First CSN only*/
--left join   [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].PAT_ENC e1 ON e1.PAT_ENC_CSN_ID = COALESCE(a.PRIM_ENC_CSN_ID,csn.PAT_ENC_CSN_ID)
--left join   [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_APPT_STATUS st ON st.APPT_STATUS_C = e1.APPT_STATUS_C
----left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_CANCEL_REASON cr ON cr.CANCEL_REASON_C = e1.CANCEL_REASON_C
----left join [CLARITY].[ORGFILTER].[ZC_DISP_ENC_TYPE] et ON et.DISP_ENC_TYPE_C = e1.ENC_TYPE_C
--left join   [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].PAT_ENC_HSP e2 ON e2.PAT_ENC_CSN_ID = a.PRIM_ENC_CSN_ID
--left join   [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[ZC_PAT_STATUS] ps ON ps.ADT_PATIENT_STAT_C = e2.ADT_PATIENT_STAT_C
--left join   [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_DISCH_DESTIN_HA dd ON dd.DISCH_DESTIN_HA_C = a.DISCH_DESTIN_HA_C
--left join   [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].CLARITY_DRG drg ON a.FINAL_DRG_ID = drg.DRG_ID
--left join   [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[ZC_DRG_CASE_TYPE] drgt ON drgt.DRG_CASE_TYPE_C = drg.DRG_CASE_TYPE_C
--left join   [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].HSP_ACCT_SBO sbo ON sbo.HSP_ACCOUNT_ID = a.HSP_ACCOUNT_ID
--left join   [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[ZC_PAT_SERVICE] svc on svc.HOSP_SERV_C = a.PRIM_SVC_HA_C
----left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].HSP_ACCT_CPT_CODES cpt ON cpt.HSP_ACCOUNT_ID = a.HSP_ACCOUNT_ID and cpt.LINE = 1
----left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].HSP_ACCT_PX_LIST px ON px.HSP_ACCOUNT_ID = a.HSP_ACCOUNT_ID and px.LINE = 1
----left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].CL_ICD_PX icd ON icd.ICD_PX_ID = px.FINAL_ICD_PX_ID
----left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].HSP_ACCT_DX_LIST dx ON dx.HSP_ACCOUNT_ID = a.HSP_ACCOUNT_ID and dx.LINE = 1
----left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[CLARITY_EDG] edg ON edg.DX_ID = dx.DX_ID
--left join   [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].account aa on a.HSP_ACCOUNT_ID = aa.sbo_hsp_account_id
----left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].CLARITY_EEP eep on aa.employer_id = emp.employer_id
--left join   [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].COVERAGE cov on a.COVERAGE_ID = cov.COVERAGE_ID
--left join   [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].CLARITY_EPP epp on a.PRIMARY_PLAN_ID = epp.benefit_plan_id
--where 1=1

---- Safety check and transaction
--    IF (SELECT COUNT(1) FROM @StagingTable) >= 10
--    BEGIN
--        BEGIN TRANSACTION;
--            PRINT 'At least 10 accounts found. Deleting and reloading fact.Accounts...';

--            DELETE FROM fact.Accounts WHERE AccountDataSourceID = 5;

--            INSERT INTO fact.Accounts (
--                AccountID,
--                AccountDataSourceID,
--                AccountSourceID,
--                AccountReferenceNumber,
--                AccountPatientID,
--                AccountLocationID,
--                AccountDepartmentID,
--                AccountFinancialClassID,
--                AccountPrimaryPayerID,
--                AccountPrimaryPayerPlanID,
--                AccountPrimaryProviderID,
--                AccountAdmittingProviderID,
--                AccountAttendingProviderID,
--                AccountReferringProviderID,
--                AccountDateOfService,
--                AccountDateOfAdmission,
--                AccountDateOfDischarge,
--                AccountDateOfBilling,
--                AccountDateOfClosing,
--                AccountDateOfZeroBalance,
--                AccountDateOfBadDebtWriteOff,
--                AccountTotalCharges,
--                AccountTotalAdjustments,
--                AccountTotalPayments,
--                AccountTotalRefunds,
--                AccountTotalBalance,
--                AccountStatus,
--                AccountClass,
--                AccountType,
--                AccountService,
--                AccountBillingStatus,
--                AccountCodingStatus,
--                AccountCodingStatusDatetime,
--                AccountDRG,
--                AccountDRGDescription,
--                AccountDRGType,
--                AccountDRGMDC,
--                AccountDRGCMI,
--                AccountDRGGMLOS,
--                AccountIsRecurring,
--                AccountIsActive,
--                AccountUpdatedDatetime,
--                AccountEmployerName,
--                AccountBeneficiaryNumber,
--                AccountGuarantorName,
--                AccountGuarantorID
--            )
--            SELECT * FROM @StagingTable;

--        COMMIT TRANSACTION;
--    END
--    ELSE
--    BEGIN
--        PRINT 'Less than 10 accounts found. Skipping delete and reload.';
--    END
--END;


----select a.PRIM_SVC_HA_C,a.BILL_DRG_WEIGHT,a.BILL_DRG_GMLOS,* from [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].HSP_ACCOUNT a where a.HSP_ACCOUNT_ID like '6%' and a.ACCT_BASECLS_HA_C = 1 
----select * from [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].CLARITY_DRG drg  WHERE drg.DRG_ID = 4818
GO
