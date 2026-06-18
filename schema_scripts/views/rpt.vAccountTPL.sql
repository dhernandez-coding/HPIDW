CREATE VIEW [rpt].[vAccountTPL] as (

SELECT

d.DataSourceName,
sub.[AccountID]
,sub.GuarantorType
,sub.[AccountReferenceNumber]
,sub.AccountGuarantorID
,sub.AccountGuarantorName
,sub.AccountDateOfService
,sub.AccountDateOfAdmission
,sub.AccountDateOfDischarge
,sub.AccountStatus
,sub.AccountBillingStatus
,sub.AccountClass
,sub.AccountType
,l.LocationName
,vd.DepartmentName
,p.ProviderFullName
,fc.FinancialClassName
,pay.PayerCategoryName
,pay.PayerName
,sub.AccountPrimaryPayerPlanID
,vds.VisitDiagnosisCodeWithDescription
,sub.AccountDRGDescription
,sub.AccountDRG
,sub.AccountDRGCMI
,COUNT(DISTINCT sub.AccountID) as '# Accounts'
,SUM(sub.AccountTotalCharges) as 'Total Charges'
,SUM(sub.AccountTotalAdjustments) as 'Total Adjustments'
,SUM(sub.AccountTotalPayments) as 'Total Payments'
,SUM(sub.AccountTotalBalance) as 'Total Balance'
FROM
(SELECT

CONCAT('5~',a.HSP_ACCOUNT_ID) as [AccountID]
,5 as [AccountDataSourceID]
,a.HSP_ACCOUNT_ID as [AccountSourceID]
,a.HSP_ACCOUNT_ID as [AccountReferenceNumber]
,CONCAT('5~',a.PAT_ID) as [AccountPatientID]
,CONCAT('5~',COALESCE(a.DISCH_LOC_ID, a.ADM_LOC_ID, a.LOC_ID)) as [AccountLocationID]
,CASE WHEN COALESCE(a.DISCH_DEPT_ID, a.ADM_DEPARMENT_ID) is not null
	  THEN CONCAT('5~',COALESCE(a.DISCH_DEPT_ID, a.ADM_DEPARMENT_ID)) END as[AccountDepartmentID]
,CASE WHEN a.ACCT_FIN_CLASS_C is null THEN NULL ELSE CONCAT('5~',a.ACCT_FIN_CLASS_C) END as [AccountFinancialClassID]
,CASE WHEN a.PRIMARY_PAYOR_ID is null THEN NULL ELSE CONCAT('5~',a.PRIMARY_PAYOR_ID) END as [AccountPrimaryPayerID]
,CASE WHEN a.PRIMARY_PLAN_ID is null THEN NULL ELSE CONCAT('5~',a.PRIMARY_PLAN_ID) END AS AccountPrimaryPayerPlanID
,CASE WHEN a.ATTENDING_PROV_ID is null THEN NULL ELSE CONCAT('5~',a.ATTENDING_PROV_ID) END as [AccountPrimaryProviderID]
,CASE WHEN a.ATTENDING_PROV_ID is null THEN NULL ELSE CONCAT('5~',a.ATTENDING_PROV_ID) END as [AccountAdmittingProviderID]
,CASE WHEN a.ATTENDING_PROV_ID is null THEN NULL ELSE CONCAT('5~',a.ATTENDING_PROV_ID) END as [AccountAttendingProviderID]
,CASE WHEN a.REFERRING_PROV_ID is null THEN NULL ELSE CONCAT('5~',a.REFERRING_PROV_ID) END as [AccountReferringProviderID]
,CONVERT(date,coalesce(a.ADM_DATE_TIME,e2.EXP_ADMISSION_TIME)) as [AccountDateOfService]
,coalesce(a.ADM_DATE_TIME,e2.EXP_ADMISSION_TIME) as [AccountDateOfAdmission]
,a.DISCH_DATE_TIME as [AccountDateOfDischarge]
,a.ACCT_BILLED_DATE as AccountDateOfBilling
,a.ACCT_CLOSE_DATE as AccountDateOfClosing
,a.ACCT_ZERO_BAL_DT as AccountDateOfZeroBalance
,NULL AS AccountDateOfBadDebtWriteOff
,a.TOT_CHGS as AccountTotalCharges
,a.TOT_ADJ as AccountTotalAdjustments
,a.TOT_PMTS as AccountTotalPayments
,NULL as AccountTotalRefunds
,A.TOT_ACCT_BAL as AccountTotalBalance
,COALESCE(ps.Name,st.NAME) as [AccountStatus] 
,bc.NAME as [AccountClass]
,ac.NAME as [AccountType]
,svc.NAME as [AccountService]
,bs.NAME as [AccountBillingStatus]
,cs.NAME as AccountCodingStatus
,a.CODING_DATETIME as AccountCodingStatusDatetime
,drg.DRG_NUMBER as [AccountDRG]
,drg.DRG_NAME as AccountDRGDescription
,drgt.NAME as AccountDRGType
,drg.DRG_MDC_C as AccountDRGMDC
,a.BILL_DRG_WEIGHT as AccountDRGCMI
,a.BILL_DRG_GMLOS as AccountDRGGMLOS
,CASE WHEN a.RECUR_PARENT_ID is not null THEN 1 ELSE 0 END as AccountIsRecurring
--,CASE WHEN a.IS_ACTIVE_YN = 'Y' THEN 1 ELSE 0 END as [AccountIsActive] /*Closed Hospital Accounts are considered inactive by this logic*/
,1 as [AccountIsActive]
,GETDATE() AS [AccountUpdatedDatetime]
,CASE
	WHEN aa.empr_id_cmt is not null -- check if employer comment has employer name
		THEN aa.empr_id_cmt
	WHEN cov.subscr_empr_id_cmt is not null and aa.empr_id_cmt is null -- check if payment plan comment has employer name (payor ID of 24004 = workers comp)
		THEN cov.subscr_empr_id_cmt
	WHEN cov.payor_id = 24004 and (cov.SUBSCR_SEX_C is null OR cov.SUBSCR_SEX_C =3) and cov.subscr_empr_id_cmt is null and aa.empr_id_cmt is null -- check if payment plan subscriber name is an employer name 
		THEN cov.SUBSCR_NAME
	WHEN a.PRIMARY_PAYOR_ID = 24004 and epp.benefit_plan_name is not null and cov.subscr_empr_id_cmt is null and aa.empr_id_cmt is null  --  check if payment plan name is an employer name
		THEN epp.benefit_plan_name
	--WHEN eep.employer_name is not null and aa.empr_id_cmt is null and cov.subscr_empr_id_cmt is null and a.PRIMARY_PAYOR_ID <> 24004 -- check if employer name is given directly (does not catch "workers comp" consistently)
	--	THEN eep.employer_name
	ELSE null
END AS [AccountEmployerName],
cov.SUBSCR_NUM as AccountBeneficiaryNumber,
a.GUAR_NAME as [AccountGuarantorName],
a.GUARANTOR_ID as [AccountGuarantorID],
cg.GUARANTOR_ACCOUNT_TYPE as GuarantorType


FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].HSP_ACCOUNT a
left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].V_CUBE_D_GUARANTOR cg on cg.GUARANTOR_ID = a.GUARANTOR_ID
left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].HSP_ACCOUNT_3 a3 ON a3.HSP_ACCOUNT_ID = a.HSP_ACCOUNT_ID
left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_ACCT_BILLSTS_HA bs ON bs.ACCT_BILLSTS_HA_C = a.ACCT_BILLSTS_HA_C
left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_ACCT_CLASS_HA ac ON ac.ACCT_CLASS_HA_C = a.ACCT_CLASS_HA_C
left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_ACCT_BASECLS_HA bc ON bc.ACCT_BASECLS_HA_C = a.ACCT_BASECLS_HA_C
left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_ADM_SOURCE src ON src.ADMIT_SOURCE_C = a.ADMISSION_SOURCE_C
left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_CODING_STS_HA cs ON cs.CODING_STATUS_C = a.CODING_STATUS_C
left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].HSP_ACCT_PAT_CSN csn ON csn.HSP_ACCOUNT_ID = a.HSP_ACCOUNT_ID and csn.LINE = 1 /*First CSN only*/
left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].PAT_ENC e1 ON e1.PAT_ENC_CSN_ID = COALESCE(a.PRIM_ENC_CSN_ID,csn.PAT_ENC_CSN_ID)
left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_APPT_STATUS st ON st.APPT_STATUS_C = e1.APPT_STATUS_C
left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].PAT_ENC_HSP e2 ON e2.PAT_ENC_CSN_ID = a.PRIM_ENC_CSN_ID
left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[ZC_PAT_STATUS] ps ON ps.ADT_PATIENT_STAT_C = e2.ADT_PATIENT_STAT_C
left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_DISCH_DESTIN_HA dd ON dd.DISCH_DESTIN_HA_C = a.DISCH_DESTIN_HA_C
left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].CLARITY_DRG drg ON a.FINAL_DRG_ID = drg.DRG_ID
left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[ZC_DRG_CASE_TYPE] drgt ON drgt.DRG_CASE_TYPE_C = drg.DRG_CASE_TYPE_C
left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].HSP_ACCT_SBO sbo ON sbo.HSP_ACCOUNT_ID = a.HSP_ACCOUNT_ID
left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[ZC_PAT_SERVICE] svc on svc.HOSP_SERV_C = a.PRIM_SVC_HA_C
left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].account aa on a.HSP_ACCOUNT_ID = aa.sbo_hsp_account_id
left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].COVERAGE cov on a.COVERAGE_ID = cov.COVERAGE_ID
left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].CLARITY_EPP epp on a.PRIMARY_PLAN_ID = epp.benefit_plan_id
where 1=1 
AND a.SERV_AREA_ID <> 425
AND cg.GUARANTOR_ACCOUNT_TYPE = 'Third Party Liability')sub
left join dim.vDataSources d on sub.[AccountDataSourceID] = d.DataSourceID
left join dim.vLocations l on l.LocationID = sub.AccountLocationID
left join dim.vDepartments vd on vd.DepartmentID = sub.AccountDepartmentID
left join dim.vProviders p on p.ProviderID = sub.AccountPrimaryProviderID
left join dim.FinancialClasses fc on fc.FinancialClassID = sub.AccountFinancialClassID
left join dim.vPayers pay on pay.PayerID = sub.AccountPrimaryPayerID
left join fact.vVisitDiagnoses vds on vds.VisitDiagnosisAccountID = sub.AccountID

GROUP BY 
d.DataSourceName,
sub.[AccountID]
,sub.[AccountReferenceNumber]
,sub.AccountGuarantorID
,sub.AccountGuarantorName
,sub.AccountDateOfService
,sub.AccountDateOfAdmission
,sub.AccountDateOfDischarge
,sub.AccountStatus
,sub.AccountBillingStatus
,sub.AccountClass
,sub.AccountType
,l.LocationName
,vd.DepartmentName
,p.ProviderFullName
,fc.FinancialClassName
,pay.PayerCategoryName
,pay.PayerName
,sub.AccountPrimaryPayerPlanID
,vds.VisitDiagnosisCodeWithDescription
,sub.AccountDRGDescription
,sub.AccountDRG
,sub.AccountDRGCMI
,sub.GuarantorType
)
GO
