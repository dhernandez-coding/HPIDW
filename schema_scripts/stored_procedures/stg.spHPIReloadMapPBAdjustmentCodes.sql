CREATE PROCEDURE [stg].[spHPIReloadMapPBAdjustmentCodes] as

/*
CREATE TABLE map.PBAdjustmentCodes 
(PBAdjustmentCodeID varchar(100) primary key not null
, PBAdjustmentCodeDescription varchar(100)
, PBAdjustmentCodeCategory varchar(100)
, PBAdjustmentCodeUpdatedDatetime datetime)
*/

TRUNCATE TABLE map.PBAdjustmentCodes

INSERT INTO map.PBAdjustmentCodes SELECT '5~145740','MISCELLANEOUS DEBIT','3_Admin Write Off',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~3005','SMALL BALANCE WRITE-OFF','3_Admin Write Off',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~3014','PLB INTEREST DEBIT ADJUSTMENT','3_Admin Write Off',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~5015','SMALL BALANCE WRITE-OFF','3_Admin Write Off',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~6010','SMALL BALANCE DEBIT','3_Admin Write Off',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~995288','ADMINISTRATIVE ADJ','3_Admin Write Off',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~CBO002','CBO ADMINISTRATIVE ADJUSTMENT','3_Admin Write Off',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~CBO005','CBO BELOW MINIMUM PMT FOR APPEAL','3_Admin Write Off',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~CBO018','CBO INSURANCE OVERPAYMENT ADJUSTMENT','3_Admin Write Off',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~CBO035','CBO PATIENT OVERPAYMENT ADJUSTMENT','3_Admin Write Off',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~5002','BAD DEBT WRITE-OFF','8_Bad Debt',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~5003','BANKRUPTCY ADJUSTMENT','8_Bad Debt',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~5011','PATIENT DECEASED ADJUSTMENT','8_Bad Debt',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~5025','EXTERNAL A/R BAD DEBT ADJUSTMENT','8_Bad Debt',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~CBO004','CBO BANKRUPTCY WRITE-OFF','8_Bad Debt',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~CBO011','CBO DECEASED PAT DUE BALANCE ADJUSTMENT','8_Bad Debt',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~165034','CASH AGREEMENT ADJUSTMENT','2_Contractual Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~3000','CONTRACTUAL WRITE-OFF','2_Contractual Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~3006','WRITE-OFF','2_Contractual Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~3011','CAPITATED WRITE-OFF (INSURANCE)','2_Contractual Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~3012','SEQUESTRATION WRITE-OFF','2_Contractual Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~3132','PHYSICIAN CPC MEDICARE ADJUSTMENT','2_Contractual Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~5000','WRITE-OFF','2_Contractual Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~5023','SELF-PAY DISCOUNT','2_Contractual Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~5028','PROMPT PAY DISCOUNT','2_Contractual Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~CBO006','CBO BUNDLED INSURANCE AGREEMENT','2_Contractual Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~CBO021','CBO LIABILITY INSURANCE AGREEMENT/ADJUSTMENT','2_Contractual Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~CBO028','CBO NON-COVERED PATIENT LIABLE','2_Contractual Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~CBO031','CBO OUT OF NETWORK ADJUSTMENT','2_Contractual Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~CBO037','CBO SELF-PAY ADJUSTMENT','2_Contractual Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~CBO038','CBO SEQUESTRATION WRITE-OFF','2_Contractual Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~122387','ADJUSTMENT 5/50','99_No Category',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~148054','BONUS','99_No Category',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~153373','CREDIT CARD REFUND - VOIDED IN ERROR','99_No Category',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~187513','DEN - BILLING ERROR','99_No Category',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~3144','MIPS INCENTIVE ADJUSTMENT','99_No Category',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~4000','CAPITATION DEBIT ADJUSTMENT','99_No Category',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~4001','CREDIT ADJUSTMENT REVERSAL','99_No Category',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~4005','INTEREST DEBIT','99_No Category',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~4007','REFUND','99_No Category',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~6005','SELF-PAY CREDIT CARD REFUND','99_No Category',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~6007','NSF FEE','99_No Category',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~6008','PAYMENT REVERSAL','99_No Category',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~6017','NSF PAYMENT REVERSAL (ACCOUNT)','99_No Category',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~6024','HPI DEBIT ADJUSTMENT (MEDICAL RECORDS)','99_No Category',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~CBO003','CBO BALANCE ADJ FOR PHYSICIAN DEPOSITED/CASHED PAYMENT','99_No Category',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~CBO007','CBO CHARGE ERROR/CORRECTION','99_No Category',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~CBO029','CBO NSF ADJUSTMENT RETURNED CHECK FEE','99_No Category',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~3150','DEN - MEDICAL NECESSITY','4_Payer Determination Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~CBO013','CBO DOWNCODED BY CARRIER','4_Payer Determination Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~CBO014','CBO EXPERIMENTAL/UNPROVEN/INVESTIGATIONAL DENIAL','4_Payer Determination Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~CBO015','CBO INCLUSIVE/INCLUDED IN PMT OF OTHER SERVICE','4_Payer Determination Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~CBO019','CBO LACK OF DOCUMENTATION-SERV NOT SUPPORTED','4_Payer Determination Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~CBO020','CBO LACKS MEDICAL NECESSITY/DOES NOT MEET PLAN CRITERIA','4_Payer Determination Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~CBO024','CBO MUE DENIED MAX/FREQUENCY/LIMIT EXCEEDED','4_Payer Determination Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~CBO025','CBO NO AUTHORIZATION/AUTHORIZATION REQUIRED','4_Payer Determination Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~CBO026','CBO NO REFERRAL/PRECERT/REFERRAL REQUIRED','4_Payer Determination Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~CBO027','CBO NON-COVERED NON-BILLABLE TO PATIENT','4_Payer Determination Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~CBO032','CBO PA PHYSICIAN ASSISTS NON-COVERED CPT CODE','4_Payer Determination Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~CBO033','CBO PAST TIMELY FILING DEMO/OFFICE ERROR','4_Payer Determination Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~CBO034','CBO PAST TIMELY FILING OR APPEAL','4_Payer Determination Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~CBO036','CBO POST-OP/PRE-OP/GLOBAL SERV ADJUSTMENT','4_Payer Determination Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~4002','DEBIT ADJUSTMENT','7_Refund',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~6004','DEBIT ADJUSTMENT','7_Refund',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '5~6009','REFUND','7_Refund',getdate()

INSERT INTO map.PBAdjustmentCodes SELECT '1~ADMINADJ','Administrative Adjustment','3_Admin Write Off',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~BELOWMIN','BELOW MINIMUM REIMBURSEMENT FOR APPEAL','3_Admin Write Off',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~INSOVPMT','Insurance Overpayment Adjustment','3_Admin Write Off',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~INTERADJ','Interest Adjustment','3_Admin Write Off',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~LSMPURCH','FKV LSM PURCHASE ADJUSTMENT CODE','3_Admin Write Off',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~PTOVPMT','PT Overpayment Adjustment','3_Admin Write Off',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~SPSBADJ','Small Balance Adjustment','3_Admin Write Off',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~TRCR','Transfer/Apply Patient Credit Balance','3_Admin Write Off',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~UNDAPPL','Under Appeal Limit','3_Admin Write Off',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~BADDBT','Bad Debt Write Off','8_Bad Debt',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~BANKRUPT','Bankruptcy Write Off','8_Bad Debt',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~COLADJ','Collection Agency Adjustment','8_Bad Debt',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~DECEASED','DECEASED PATIENT DUE BALANCE ADJUSTMENT','8_Bad Debt',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~THOMASBD','T. THOMASON BAD DEBT WRITE OFF ADJ','8_Bad Debt',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~2XMAXWC','2X MAX W/C CONTRACTUAL ADJUSTMENT','2_Contractual Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~AETNAADJ','Aetna Adjustment','2_Contractual Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~AETNWTH','Aetna Withholding','2_Contractual Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~BCBSADJ','BCBS Adjustment','2_Contractual Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~BCBSWTH','BCBS Whthhold','2_Contractual Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~BUNDLED','Bundled Insurance Agreement','2_Contractual Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~CIGNAADJ','Cigna Adjustment','2_Contractual Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~CIGNWTH','Cigna Withholding','2_Contractual Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~COMADJ','Commercial Insurance Adjustment','2_Contractual Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~HCHADJ','Healthchoice Insurance Adjustment','2_Contractual Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~HCHBND','zz HEALTHCHOICE BUNDLED CONTRACT ADJ','2_Contractual Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~HEALWTH','Healthchoice Withholding','2_Contractual Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~IORTHADJ','zz I ORTHO IHS CONTRACTUAL ADJ CODE','2_Contractual Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~LIABADJ','Liability Insurance Adjustment','2_Contractual Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~MCAIDADJ','Medicaid Adjustment','2_Contractual Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~MCAIDWTH','Medicaid Withholding','2_Contractual Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~MCARADJ','Medicare Adjustment','2_Contractual Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~MCARWTH','Medicare Withholding','2_Contractual Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~NONCOVPT','NON COVERED PATIENT LIABLE','2_Contractual Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~ONLINEAD','Online Credit Card Fee Adjustment','2_Contractual Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~OON','Out Of Network Adjustment','2_Contractual Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~RESTADJ','RestAssured Adjustment','2_Contractual Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~SPADJ','Self Pay Adjustment','2_Contractual Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~TRICADJ','Tricare Adjustment','2_Contractual Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~UHCADJ','United HealthCare Adjustment','2_Contractual Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~UHCWTH','UHC Withholding','2_Contractual Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~VAXADJ','VAXCARE ADJUSTMENT','2_Contractual Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~WCADJ','Workers Comp Adjustment','2_Contractual Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~CAIDINCA','Medicaid/Soonercare Incentive Adjustment','99_No Category',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~CAREINCA','Medicare Incentive Adjustment','99_No Category',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~CHGCORR','Charge Correction/Charge Error','99_No Category',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~GMNHNOCO','GMNH NON COV DR DIRECT BILL','99_No Category',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~INFOVPMT','INFUSION INSURANCE PAYMENT ADJUSTMENT','99_No Category',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~INFPMTNR','INFUSION INSURANCE PYMT -NON RECONCILED','99_No Category',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~INOVINCA','INOVALON INCENTIVE ADJUSTMENT','99_No Category',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~MEDRECA','Medical Records Adjustment','99_No Category',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~NSFADJ','NSF Adjustment Returned Check Fee','99_No Category',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~PHYDEPO','Phy Direct Deposited Patient/Other Payme','99_No Category',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~UHCINCA','UHC Incentive Adjustment','99_No Category',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~DOWNCODE','Downcoded by carrier','4_Payer Determination Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~EXPERIM','Experimental/unproven/investig denial','4_Payer Determination Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~INCLUS','Inclusive/included in pymt of other serv','4_Payer Determination Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~LACKMEDN','Lacks Medical Necessity denial','4_Payer Determination Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~MUE','MUE Denied Max/Frequency limit exceeded','4_Payer Determination Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~NOAUTH','Not Authorized/No Referral -ins requires','4_Payer Determination Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~NODOCUM','Lack of Documentation/serv not supported','4_Payer Determination Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~NONCOV','Non Covered Non Billable to Patient','4_Payer Determination Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~PANONCO','PA Physician Assist Non Covered CPT Code','4_Payer Determination Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~PASTTIME','Past Timely Filing Demo/Office Error','4_Payer Determination Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~PASTTIML','Past Timely Filing or Appeal','4_Payer Determination Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~POSTOP','Post Op Services/Global to prev surgery','4_Payer Determination Adjustment',getdate()
INSERT INTO map.PBAdjustmentCodes SELECT '1~DMERETUR','DME Returned Item','7_Refund',getdate()


INSERT INTO map.PBAdjustmentCodes SELECT '5~3128','DEN - TIMELY PAST APPEAL DEADLINE','4_Payer Determination Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~3196','DEN - NON-COVERED SERVICE','4_Payer Determination Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~3197','DEN - PYMT INCLUDES PYMT FOR OTHER SVC/PROC NOT PD SEPARATELY','4_Payer Determination Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~5027','EXTERNAL A/R BAD DEBT ADJUSTMENT REVERSAL','8_Bad Debt',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~6002','BAD DEBT REVERSAL','8_Bad Debt',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '1~PAYMYDOC','PAY MY DOCTOR MISSING PYMT TRACKING','6_Patient Receipts',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~4006','PAYMENT REVERSAL','5_Payer Receipts',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~3119','DEN - NO AUTH - AUTH NOT APPROVED (NAANA)','4_Payer Determination Adjustment',GETDATE()

UPDATE map.PBAdjustmentCodes SET PBAdjustmentCodeCategory = '5_Payer Receipts', PBAdjustmentCodeUpdatedDatetime = GETDATE() WHERE PBAdjustmentCodeID = '5~4000'
UPDATE map.PBAdjustmentCodes SET PBAdjustmentCodeCategory = '7_Refund', PBAdjustmentCodeUpdatedDatetime = GETDATE() WHERE PBAdjustmentCodeID = '5~4007'
UPDATE map.PBAdjustmentCodes SET PBAdjustmentCodeCategory = '7_Refund', PBAdjustmentCodeUpdatedDatetime = GETDATE() WHERE PBAdjustmentCodeID = '5~6005'
UPDATE map.PBAdjustmentCodes SET PBAdjustmentCodeCategory = '6_Patient Receipts', PBAdjustmentCodeUpdatedDatetime = GETDATE() WHERE PBAdjustmentCodeID = '5~6008'
UPDATE map.PBAdjustmentCodes SET PBAdjustmentCodeCategory = '6_Patient Receipts', PBAdjustmentCodeUpdatedDatetime = GETDATE() WHERE PBAdjustmentCodeID = '5~6017'
UPDATE map.PBAdjustmentCodes SET PBAdjustmentCodeCategory = '6_Patient Receipts', PBAdjustmentCodeUpdatedDatetime = GETDATE() WHERE PBAdjustmentCodeID = '1~CAIDINCA'
UPDATE map.PBAdjustmentCodes SET PBAdjustmentCodeCategory = '6_Patient Receipts', PBAdjustmentCodeUpdatedDatetime = GETDATE() WHERE PBAdjustmentCodeID = '1~CAREINCA'
UPDATE map.PBAdjustmentCodes SET PBAdjustmentCodeCategory = '1_Charge', PBAdjustmentCodeUpdatedDatetime = GETDATE() WHERE PBAdjustmentCodeID = '5~CBO007'
UPDATE map.PBAdjustmentCodes SET PBAdjustmentCodeCategory = '1_Charge', PBAdjustmentCodeUpdatedDatetime = GETDATE() WHERE PBAdjustmentCodeID = '1~CHGCORR'
UPDATE map.PBAdjustmentCodes SET PBAdjustmentCodeCategory = '2_Contractual Adjustment', PBAdjustmentCodeUpdatedDatetime = GETDATE() WHERE PBAdjustmentCodeID = '1~INFOVPMT'
UPDATE map.PBAdjustmentCodes SET PBAdjustmentCodeCategory = '5_Payer Receipts', PBAdjustmentCodeUpdatedDatetime = GETDATE() WHERE PBAdjustmentCodeID = '1~PHYDEPO'
UPDATE map.PBAdjustmentCodes SET PBAdjustmentCodeCategory = '6_Patient Receipts', PBAdjustmentCodeUpdatedDatetime = GETDATE() WHERE PBAdjustmentCodeID = '1~UHCINCA'

/*9.30.2026 - Chris Cross added new codes from SOS*/
INSERT INTO map.PBAdjustmentCodes SELECT '5~187512',' DEN -  REGISTRATION ERROR - ','4_Payer Determination Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~3015',' FB/WO PLB DEBIT ADJUSTMENT  ','',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~301604',' ALLSET SECONDARY PAYER FORMAT ADJUSTMENT  ','',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~3018',' DEN  -  TIMELY CHARGING ERROR - DEPT','4_Payer Determination Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~3020',' TOO OLD TO BILL PATIENT','4_Payer Determination Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~3099',' EXPECTED PAYER CONTRACTUAL WRITE-OFF (INSURANCE) - ','2_Contractual Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~3102',' DEN - NO AUTHORIZATION NOT ATTEMPTED','4_Payer Determination Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~3104',' DEN - PROC IS INCONSISTENT WITH MOD','4_Payer Determination Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~3111',' DEN - DIAGNOSIS INCONSISTENT WITH PROCEDURE','4_Payer Determination Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~3115',' DEN - AUTH/PRECERT RELATED','4_Payer Determination Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~3118',' DEN - NO AUTH - ADDON PROCEDURE (NAAP)','4_Payer Determination Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~3120',' DEN - NUMBER OF VISITS/OTHER PROVIDER SAME DATE OF SERVICE','4_Payer Determination Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~3123',' DEN - NO AUTH - DOS OUTSIDE ORIGINAL AUTH (NADE)','4_Payer Determination Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~3127',' DEN - TIMELY ELIGIBILITY/INCORRECT INSURANCE - ','4_Payer Determination Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~3129',' DEN - TIMELY CLAIM NOT FILED - ','4_Payer Determination Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~3131',' DEN - NO AUTH - PHYSICIAN NOTIFY / CLINICAL NOT DONE (NAPNC)','4_Payer Determination Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~3135',' DEN - BENEFITS EXHAUSTED','4_Payer Determination Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~3137',' DEN - SECONDARY INSURANCE NOT BILLED/APPEALED TIMELY - ','4_Payer Determination Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~3139',' DEN - MODIFIER INCONSISTENT WITH AUTHORIZATION','4_Payer Determination Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~3151',' DEN - SERVICES EXCEED PAYER GUIDELINES','4_Payer Determination Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~3155',' DEN - MED POL/PROC DEEMED EXPERIMENTAL/NOT APRVD BY FDA','4_Payer Determination Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~3165',' DEN - NO REFERRAL/EXCEEDED/REF PRVDR NOT ELIG TO REFER','4_Payer Determination Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~3185',' DEN - PROVIDER NOT ELIG/CERTIFIED','4_Payer Determination Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~5021',' WRITE-OFF (UNCOLLECTIBLE DENIAL)','4_Payer Determination Adjustment',GETDATE()


DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '5~137378'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '5~163642'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '5~165411'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '5~187512'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '5~242457'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '5~3015'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '5~301604'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '5~3018'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '5~3020'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '5~3099'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '5~3102'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '5~3104'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '5~3111'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '5~3115'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '5~3118'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '5~3120'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '5~3122'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '5~3123'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '5~3127'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '5~3129'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '5~3131'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '5~3135'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '5~3137'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '5~3139'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '5~3151'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '5~3155'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '5~3165'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '5~3185'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '5~4009'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '5~5014'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '5~5021'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '5~6020'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '5~8020'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '5~995226'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '5~995338'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '5~995353'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '5~995508'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '5~999206'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '12~ADMINADJ'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '12~BADDBT'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '12~BCBSADJ'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '5~CARE CREDIT BALANCE ADJUSTMENT'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '5~CARE CREDIT SERVICE FEE'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '5~CBO008'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '5~CBO016'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '5~CBO039'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '5~CCC001'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '5~CCC002'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '12~CHGCORR'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '12~COLADJ'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '12~COMADJ'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '5~DNU'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '12~INCLUS'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '12~INSOVPMT'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '12~MCAIDADJ'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '12~MCARADJ'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '12~MCARWTH'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '12~MUE'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '12~NOAUTH'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '12~NONCOV'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '12~OON'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '12~PASTTIME'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '12~PASTTIML'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '12~PHYDEPO'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '12~PTOVPMT'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '12~SPADJ'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '12~SPSBADJ'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '12~TRICADJ'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '12~UHCADJ'
DELETE FROM map.PBAdjustmentCodes WHERE PBAdjustmentCodeID = '12~WCADJ'

INSERT INTO map.PBAdjustmentCodes SELECT '5~137378','137378 - MISCELLANEOUS DEBIT INSURANCE','2_Contractual Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~163642','163642 - RECOUPMENT DEBIT ADJUSTMENT','3_Admin Write Off',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~165411','165411 - INCIDENTAL - PRE-BILLING','6_Patient Receipts',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~187512','187512 - DEN - REGISTRATION ERROR','4_Payer Determination Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~242457','242457 - OHCA OK MEDICAID ADJUSTMENT','2_Contractual Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~3015','3015 - FB/WO PLB DEBIT ADJUSTMENT','3_Admin Write Off',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~301604','301604 - ALLSET SECONDARY PAYER FORMAT ADJUSTMENT','3_Admin Write Off',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~3018','3018 - DEN - TIMELY CHARGING ERROR-DEPT','4_Payer Determination Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~3020','3020 - TOO OLD TO BILL PATIENT','3_Admin Write Off',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~3099','3099 - EXPECTED PAYER CONTRACTUAL WRITE-OFF (INSURANCE)','2_Contractual Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~3102','3102 - DEN - NO AUTHORIZATION NOT ATTEMPTED','4_Payer Determination Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~3104','3104 - DEN - PROC IS INCONSISTENT WITH MOD','4_Payer Determination Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~3111','3111 - DEN - DIAGNOSIS INCONSISTENT WITH PROCEDURE','4_Payer Determination Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~3115','3115 - DEN - AUTH/PRECERT RELATED','4_Payer Determination Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~3118','3118 - DEN - NO AUTH - ADD-ON PROCEDURE (NAAP)','4_Payer Determination Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~3120','3120 - DEN - NUMBER OF VISITS/OTHER PROVIDER SAME DATE OF SERVICE','4_Payer Determination Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~3122','3122 - DEN - NO AUTH - BILLED DIFF CPT (NABDC)','4_Payer Determination Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~3123','3123 - DEN - NO AUTH - DOS OUTSIDE ORIGINAL AUTH (NADE)','4_Payer Determination Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~3127','3127 - DEN - TIMELY ELIGIBILITY/INCORRECT INSURANCE','4_Payer Determination Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~3129','3129 - DEN - TIMELY CLAIM NOT FILED','4_Payer Determination Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~3131','3131 - DEN - NO AUTH - PHYSICIAN NOTIFY / CLINICAL NOT DONE (NAPNC)','4_Payer Determination Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~3135','3135 - DEN - BENEFITS EXHAUSTED','4_Payer Determination Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~3137','3137 - DEN - SECONDARY INSURANCE NOT BILLED/APPEALED TIMELY','4_Payer Determination Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~3139','3139 - DEN - MODIFIER INCONSISTENT WITH AUTHORIZATION','4_Payer Determination Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~3151','3151 - DEN - SERVICES EXCEED PAYER GUIDELINES','4_Payer Determination Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~3155','3155 - DEN - MED POL/PROC DEEMED EXPERIMENTAL/NOT APRVD BY FDA','4_Payer Determination Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~3165','3165 - DEN - NO REFERRAL/EXCEEDED/REF PRVDR NOT ELIG TO REFER','4_Payer Determination Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~3185','3185 - DEN - PROVIDER NOT ELIG/CERTIFIED','4_Payer Determination Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~4009','4009 - EXPECTED PAYER ALLOWANCE REVERSAL','2_Contractual Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~5014','5014 - REFUND REVERSAL','7_Refund',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~5021','5021 - WRITE-OFF (UNCOLLECTIBLE DENIAL)','4_Payer Determination Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~6020','6020 - DEBIT ADJUSTMENT (HIGH DEF LENSE)','3_Admin Write Off',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~8020','8020 - DEN - EFFORTS EXHAUSTED','4_Payer Determination Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~995226','995226 - RISK MANAGEMENT','3_Admin Write Off',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~995338','995338 - NEVER EVENT','3_Admin Write Off',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~995353','995353 - FPL 90%','3_Admin Write Off',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~995508','995508 - NON-REIMBURSEMENT CCI','3_Admin Write Off',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~999206','999206 - MANAGED CARE REVIEW ALLOWANCE','3_Admin Write Off',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '12~ADMINADJ','ADMINADJ - Administrative Adjustment','3_Admin Write Off',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '12~BADDBT','BADDBT - Bad Debt Write Off','8_Bad Debt',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '12~BCBSADJ','BCBSADJ - BCBS Adjustment','2_Contractual Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~CARE CREDIT BALANCE ADJUSTMENT','CARE CREDIT BALANCE ADJUSTMENT - CARE CREDIT BALANCE ADJUSTMENT','3_Admin Write Off',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~CARE CREDIT SERVICE FEE','CARE CREDIT SERVICE FEE - CARE CREDIT SERVICE FEE','6_Patient Receipts',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~CBO008','CBO008 - CBO CHARITY ADJUSTMENT','3_Admin Write Off',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~CBO016','CBO016 - CBO INS INCENTIVE ADJUSTMENT','3_Admin Write Off',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~CBO039','CBO039 - CBO VIP PROVIDER ADJUSTMENT','3_Admin Write Off',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~CCC001','CCC001 - CCC SW ORTHO WORKS AND LETZ WRITE-OFF','3_Admin Write Off',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~CCC002','CCC002 - AMR COLLECTION AGENCY WRITE OFF','8_Bad Debt',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '12~CHGCORR','CHGCORR - Charge Correction/Charge Error','1_Charge',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '12~COLADJ','COLADJ - Collection Agency Adjustment','8_Bad Debt',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '12~COMADJ','COMADJ - Commercial Insurance Adjustment','2_Contractual Adjustment',GETDATE()

INSERT INTO map.PBAdjustmentCodes SELECT '12~INCLUS','INCLUS - Inclusive to other service denial','4_Payer Determination Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '12~INSOVPMT','INSOVPMT - Insurance Overpayment Adjustment','5_Payer Receipts',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '12~MCAIDADJ','MCAIDADJ - Medicaid Adjustment','2_Contractual Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '12~MCARADJ','MCARADJ - Medicare Adjustment','2_Contractual Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '12~MCARWTH','MCARWTH - Medicare Withholding','2_Contractual Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '12~MUE','MUE - MUE Denied Max/Frequency limit exceeded','4_Payer Determination Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '12~NOAUTH','NOAUTH - NOT AUTHORIZED authorization required','2_Contractual Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '12~NONCOV','NONCOV - Non Covered Non Billable to Patient','2_Contractual Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '12~OON','OON - Out Of Network Adjustment','2_Contractual Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '12~PASTTIME','PASTTIME - Past Timely Filing Demo/Office Error','2_Contractual Adjustment',GETDATE()

INSERT INTO map.PBAdjustmentCodes SELECT '12~PASTTIML','PASTTIML - PAST TIMELY FILING CLM OR APPEAL','2_Contractual Adjustment',GETDATE()

INSERT INTO map.PBAdjustmentCodes SELECT '12~PHYDEPO','PHYDEPO - Phy Direct Deposited Pt/ins/other paymen','6_Patient Receipts',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '12~PTOVPMT','PTOVPMT - PT Overpayment Adjustment','7_Refund',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '12~SPADJ','SPADJ - Self Pay Adjustment','3_Admin Write Off',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '12~SPSBADJ','SPSBADJ - Small Balance Adjustment','3_Admin Write Off',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '12~TRICADJ','TRICADJ - Tricare Adjustment','2_Contractual Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '12~UHCADJ','UHCADJ - United HealthCare Adjustment','2_Contractual Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '12~WCADJ','WCADJ - Workers Comp Adjustment','2_Contractual Adjustment',GETDATE()

INSERT INTO map.PBAdjustmentCodes SELECT '5~3117',' DEN - INFO REQ, NOT RCVD (MUST NOTE ACCT WITH SPECIFICS)','4_Payer Determination Adjustment',GETDATE()
INSERT INTO map.PBAdjustmentCodes SELECT '5~DNU','DNU - VOIDED - DNU - voided','99_No_Category',GETDATE()
--select PBAdjustmentCodeID, count(1) ct from map.PBAdjustmentCodes group by PBAdjustmentCodeID order by ct desc
GO
