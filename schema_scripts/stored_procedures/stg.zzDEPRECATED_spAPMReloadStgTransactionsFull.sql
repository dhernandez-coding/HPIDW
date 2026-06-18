-- =============================================
-- Author:		Ryan Tisserand
-- Create date: 01/04/2023
-- Description:	Extracts, Transforms and Loads Transaction Data from APM Source System into a stg Table
-- Change Control
--	1. 01/04/2023 - Ryan Tisserand - Initial build of procedure
-- =============================================
CREATE PROCEDURE [stg].[spAPMReloadStgTransactionsFull]
AS
BEGIN
SET NOCOUNT ON;
--insert into stg.Transactions
--(
--	TransactionID, --1
--	DataSourceID,--2
--	SourceTransactionID,--3
--	TransactionPatientID,--4
--	TransactionVisitID,--5
--	TransactionLocationAbbreviation,--6
--	TransactionDepartmentAbbreviation,--7
--  TransactionBillingProviderID,--8
--  TransactionActualProviderID,--9
--	TransactionReportProviderID,--10
--	TransactionPracticeProviderID,--11
--  TransactionReferringProviderAbbreviation,--12
--	TransactionDateOfService,--13
--  TransactionDateOfServiceYearMonth,--14
--  TransactionDateOfServiceYear,--15
--  TransactionDateOfServiceMonth,--16
--	TransactionDateOfPosting,--17
--  TransactionDateOfPostingYearMonth,--18
--  TransactionDateOfPostingYear,--19
--  TransactionDateOfPostingMonth,--20



--	TransactionType,--6
--	TransactionUpdateStatus,--7


--	TransactionReportingPeriodMonth,--10
--	TransactionReportingPeriodYear,--11
--  TransactionRolling13Month,--12
--  TransactionReportPeriodYearMonth,--13
--  TransactionPostingDateLagMonths,--14
--	TransactionProcedureCode,--19
--	TransactionProcedureCodeCategory,--20
--	TransactionUnits,--21
--	TransactionAmount,--22
--  TransactionPracticeProviderWorksFor,--23
--	TransactionCodeDescription,--25
--  TransactionCode,--26
--  TransactionType,--27
--  TransactionPostingDateLagDays,--28
--  TransactionInfusionQualifier,--29
--  TransactionSmartBeatDays,--30
--  TransactionSmartBeat,--31
--  TransactionANS,--32
--  TransactionPatientNameAtVoucher,--33
--  TransactionPatientIDAtVoucher,--34
--  TransactionPatientDateOfServiceAtVoucher,--35
--  TransactionPayerNameAtVoucher,--36
--  TransactionPatientNumberAtVoucher,--37

--  TransactionCalculatePayerType,--39
--  TransactionWhoPaid,--40
--  TransactionNRWLabAllocation,--41
--  TransactionUrodynAllocation,--42
--  TransactionRadTCMod,--43
--  TransactionGLKey,--44
--  TransactionGLCode,--45
--  TransactionSBTCGLCode,--46
--  TransactionLocationDescription,--47
--  TransactionExclusion,--48
--  TransactionCorrection,--49
--  TransactionMaxPulse,--50
--  TransactionADBAMWTransition,--51
--  TransactionProcedureCat

--	TransactionPayerSubCategory,--
--	TransactionBillingProviderType,--
--	TransactionActualProviderType,--
--	TransactionWorksForProviderID,--
--	TransactionPostingYear,--
--	TransactionPostingMonth,--
--	TransactionPointOfServiceType,--
--	TransactionPointOfServiceSurgical,--
--	TransactionVisitCategory,--
--	TransactionVoidKey,--
--	TransactionVoided,--
--	TransactionServicePaymentID,--
--	TransactionProcedureCategoryAbbreviation--
--)
select top 10000
	'1~' + cast(t.service_id as varchar(50)) TransactionID,--1
	1 DataSourceID,--2
	t.service_id SourceTransactionID,--3
	'1~' + cast(t.Patient_ID as varchar(50)) TransactionPatientID,--4
	'1~' + cast(t.Voucher_ID as varchar(50)) TransactionVisitID,--5
	t.Location_Abbr TransactionLocationAbbreviation,--6
	t.Department_Abbr TransactionDepartmentAbbreviation,--7
	'' TransactionBillingProviderID,--8 - TPG2 relationship  
	'' TransactionActualProviderID,--9 - TPG relationship  
	'' TransactionReportProviderID, --10
	'' TransactionPracticeProviderID, --11
	t.refer_dr_abbr TransactionReferringProviderAbbreviation, --12
	t.Service_Date_From TransactionDateOfService,--13
	cast(year(t.Service_Date_From) as varchar(4)) + ' ' + right('0' + cast(month(t.Service_Date_From) as varchar(2)),2) TransactionDateOfServiceYearMonth,--14
	cast(year(t.Service_Date_From) as varchar(4)) TransactionDateOfServiceYear,--15
	right('0' + cast(month(t.Service_Date_From) as varchar(2)),2) TransactionDateOfServiceMonth,--16
	t.Posting_Date TransactionDateOfPosting,--17
	cast(year(t.Posting_Date) as varchar(4)) + ' ' + right('0' + cast(month(t.Posting_Date) as varchar(2)),2) TransactionDateOfPostingYearMonth,--18
	cast(year(t.Posting_Date) as varchar(4)) TransactionDateOfPostingYear,--19
	right('0' + cast(month(t.Posting_Date) as varchar(2)),2) TransactionDateOfPostingMonth,--20

	t.TransType TransactionType,--6
	t.Update_status TransactionUpdateStatus,--7


	'' TransactionReportPeriodMonth,--10
	'' TransactionReportPeriodYear,--11
	case when datediff(MM,t.Posting_Date,getdate()) <=13 then 1 else 0 end TransactionRolling13Month,--12
	'' TransactionReportPeriodYearMonth,--13
	datediff(MM,t.Service_Date_From,t.Posting_Date) TransactionPostingDateLagMonths,--14



	t.Procedure_Code TransactionProcedureCode,--19
	case when t.Procedure_Code in('767600','76705','76536') then
		case when t.Department_Abbr = 'FTMC' then 'US'
		else t.PrCtgy_Abbr
		end
	else t.PrCtgy_Abbr
	end	TransactionProcedureCodeCategory,--20
	t.Units TransactionUnits,--21
	t.Amount	,--22
	'' TransactionPracticeProviderWorksFor,--23

	t.TransCodeDescr TransactionCodeDescription,--25
	case when t.TransType = 'C' then t.Procedure_Code
		else case when t.TransCodeDescr = '' then t.Procedure_Code
		else t.TransCodeDescr
		end 
	end TransactionCode,--26
	'' TransactionType,--27  Join to map.TransactionTypes
	datediff(DD,t.Service_Date_From,t.Posting_Date) TransactionPostingDateLagDays,--28
	'' TransactionInfusionQualifier,--29 Join to dim.ProcedureCodes
	datediff(DD,t.Service_Date_From,'2018/02/19') TransactionSmartBeatDays,--30
	case when t.Voucher_Number = '15204240' then 'N'
		else case when sb.[Status] is null then 'N' else 'Y' 
		end
	end TransactionSmartBeat,--31
	case when ans.[Status] is null then 'N' else 'Y' end TransactionANS,--32
	ptnv.Expr1 TransactionPatientNameAtVoucher,--33
	ptnv.Patient_ID TransactionPatientIDAtVoucher,--34
	ptnv.Expr2 TransactionPatientDateOfServiceAtVoucher,--35
	ptnv.Prim_Policy_Carrier_Name TransactionPayerNameAtVoucher,--36
	ptid.Patient_Number TransactionPatientNumberAtVoucher,--37

	'' TransactionCalculatePayerType,--39 May need another dim table, this column uses specific TransactionProcedureTypes to show an R
	case when t.TransType <> 'P' then '' else
		case when t.TransCodeDescr in 
			(

				'CBO Self Pay Care Credit Credit Card',
				'CBO Self Pay Cash Payment',
				'CBO Self Pay Check Payment',
				'CBO Self Pay Credit Card Payment',
				'Co-pay Cash',
				'Co-pay Check',
				'Co-pay Credit Card',
				'Infusion Services Cash Payment',
				'Infusion Services Credit Card Payment',
				'Infusion Services Personal Check Payment',
				'NSF Payment',
				'ONLINE CC FEE',
				'Online Credit Card Fee',
				'POS Selfpay Care Credit Credit Card',
				'POS Selfpay Cash Payment',
				'POS Selfpay Check Payment',
				'POS Selfpay Credit Card Payment',
				'SELF PAY REMITS',
				'SELFPAY CREDIT FROM VISION'
			) then 'R' else 'I' 
		end
	end TransactionWhoPaid,--40
	case when t.Service_Date_From < '12/01/2018' then 'NRW30' else 'NRW20' end TransactionNRWLabAllocation,--41
	case when t.Service_Date_From < '11/09/2018' then 'Allocate' else 'Do Not Allocate' end TransactionUrodynAllocation,--42
	case when xray.Procedure_Code is null then '' else 'Rad TC Mod' end TransactionRadTCMod,--43
	'' TransactionGLKey,--44
	'' TransactionGLCode,--45
	'' TransactionSBTCGLCode,--46 Logic, uses these SB Procedure Codes 92250,93000,93308,93882,93922,93979,94010
	'' TransactionLocationDescription,--47
	case when t.Amount in('214100','-214100','141200.10','-141200.10') then 'Y' else 'N' end TransactionExclusion,--48
	case when t.Voucher_Number = '15001210' then
		case when t.Procedure_Code = '22558' then 'Correction'
		end
	else 'Include' 
	end TransactionCorrection,--49
	case when t.Procedure_Code = 'MPDC' then 'Max Pulse' else 'N' end TransactionMaxPulse,--50
	case when t.Service_Date_From > '02/28/2021' then 'HPIP' else 'TPG' end TransactionADBAMWTransition,--51


	'' TransactionPayerSubCategory,--52

	'' TransactionWorksForProviderID,--55 - Logic  
	year(t.Posting_Date) TransactionPostingYear,--56
	month(t.Posting_Date) TransactionPostingMonth,--57
	'' TransactionPointOfServiceType,--58 - Logic  
	'' TransactionPointOfServiceSurgical,--59 - Logic  
	'' TransactionVisitCategory,--60 - Logic  
	'' TransactionVoidKey,--61 - Logic  
	'' TransactionVoided,--62 - Logic   Not sure if needed  
	t.Service_PMT_ID TransactionServicePaymentID,--63
	t.PrCtgy_Desc TransactionProcedureCategoryAbbreviation,--64
	p.Self_Pay_Balance TransactionSelfPayBalance,--65
	case when sb.Patient_ID is null then 'N' else 'Y' end TransactionSmartBeatFlag,--66
	case when r.Voucher_Number is null then '' else 'Rad TC Mod' end TransactionRadTCModifier
from tievmdb03.Ntier_627200.dbo.DG_vw_GenProdAnalysis t
left join tievmdb03.Ntier_627200.dbo.[vw_DG_Voided Transactions] v on t.Voucher_ID = v.Voucher_ID
left join tievmdb03.Ntier_627200.PM.vwCollAcctVchrInfo p on t.Voucher_Number = p.Voucher_Number
left join 
(
select 
	Patient_Number, 
	Appointment_DateTime, 
	Patient_ID, 
	[Status]
from tievmdb03.Ntier_627200.PM.vwApptDetail
where ((Appt_Type_Abbr = 'SB GWIL') OR ([Resource_Desc] = 'SMARTBEAT GWIL')) AND (Patient_ID IS NOT NULL) AND ([Status] <> 'X' and [Status] <> 'N')
group by 
	Patient_Number, 
	Appointment_DateTime, 
	Patient_ID, 
	[Status]
) sb on t.Patient_ID = sb.Patient_ID and t.Service_Date_From = sb.Appointment_DateTime
left join
(
	select 
		Voucher_Number
	from tievmdb03.Ntier_627200.PM.vwGenProdAnalysis
	where (TransType = 'c') and (PrCtgy_Abbr = 'xray') and (Modifiers like '%TC%') and (Update_status = 1)
	group by 
		Voucher_Number, 
		Procedure_Code
) r on t.Voucher_Number = r.Voucher_Number
left join
(
	select        
		Patient_Number, 
		Appointment_DateTime, 
		Patient_ID, 
		[Status]
	from tievmdb03.Ntier_627200.PM.vwApptDetail
	where ((Appt_Type_Abbr = 'ANS GWIL') OR ([Resource_Desc] = 'AUTONOMIC NERVE TESTING-GWIL')) AND (Patient_ID IS NOT NULL) AND (Status <> 'X' and Status <> 'N')
	group by	
		Patient_Number, 
		Appointment_DateTime, 
		Patient_ID, 
		[Status]
) ans on t.Patient_ID = ans.Patient_ID and t.Service_Date_From = ans.Appointment_DateTime
left join
(
	select        
		MAX(p.Patient_LFI) AS Expr1, 
		v.Voucher_Number, 
		p.Patient_ID, 
		MIN(v.Voucher_Service_Date) AS Expr2, 
		p.Prim_Policy_Carrier_Name
	from tievmdb03.Ntier_627200.PM.vwGenPatInfo p
	INNER JOIN tievmdb03.Ntier_627200.PM.vwGenVouchInfo v ON p.Patient_ID = v.Patient_ID
	group by 
	v.Voucher_Number, 
	p.Patient_ID, 
	p.Prim_Policy_Carrier_Name
)ptnv on t.Voucher_Number = ptnv.Voucher_Number
left join
(
	select
		Patient_Number, 
		Patient_ID
	from tievmdb03.Ntier_627200.PM.vwApptDetail AS vwApptDetail_1
	where (Patient_ID IS NOT NULL)
	group by 
		Patient_Number, 
		Patient_ID
)ptid on ptnv.Patient_ID = ptid.Patient_ID
left join
(
	select
		Voucher_Number, 
		Procedure_Code
	from tievmdb03.Ntier_627200.PM.vwGenProdAnalysis
	where (TransType = 'c') and (PrCtgy_Abbr = 'xray') and (Modifiers like '%TC%') and (Update_status = 1)
	group by Voucher_Number, Procedure_Code
)xray on t.Voucher_Number = xray.Voucher_Number and t.Procedure_Code = xray.Procedure_Code

--select top 10 * from tievmdb03.Ntier_627200.dbo.DG_vw_GenProdAnalysis t
--select top 10 * from tievmdb03.Ntier_627200.dbo.[vw_DG_Voided Transactions] v
--select top 10 * from tievmdb03.Ntier_627200.PM.vwCollAcctVchrInfo
--select top 10 * from tievmdb03.Ntier_627200.PM.vwGenPatInfo

END
GO
