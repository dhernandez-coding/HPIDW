-- =============================================
-- Author:		Ryan Tisserand
-- Create date: 11/23/2022
-- Description:	Extracts, Transforms and Loads Visit Data from APM Source System into a stg Table
-- Change Control
--	1. 12/28/2022 - Ryan Tisserand - Initial build of procedure
-- =============================================
CREATE PROCEDURE [stg].[spAPMReloadStgVisitsFull]
AS
BEGIN
SET NOCOUNT ON;

insert into stg.APMVisits
(
	VisitID,--1
	DataSourceID,--2
	VisitSourceID,--3
	VisitLocationAbbreviation,--4
	VisitDepartmentAbbreviation,--5
	VisitBillingProviderID,--6
	VisitActualProviderID,--7
	VisitReportProviderID,--8
	VisitPracticeProviderID,--9
	VisitReferringProviderID,--10
	VisitNumber,--11
	VisitDateOfService,--12
	VisitDateOfPosting,--13
	VisitDateOfServiceAge,--14
	VisitDateOfServiceAgeGroup,--15
	VisitDateOfServiceAgeGroupGraph,--16
	VisitReportingPeriod,--17
	VisitReportPeriodMonth,--18
	VisitReportPeriodYear,--19
	VisitRolling13Month,--20
	VisitOrginalPayerID,--21
	VisitBillingPayerID,--22
	VisitPayerCategoryOriginal,--23
	VisitPayerSubCategoryOriginal,--24
	VisitPayerCategoryCurrent,--25
	VisitPayerSubCategoryCurrent,--26
	VisitBalance,--27
	VisitFees,--28
	VisitPostedPaymenets,--29
	VisitSelfPayBalance,--30
	VisitBalanceType,--31
	VisitProviderReimbursementPercent,--32
	VisitInfusionFlag,--33
	VisitHospitalConsultFlag,--34
	VisitBalanceOverFiveFlag,--35
	VisitRadTCChargeFlag,--36
	VisitInfusionQualifierFlag,--37
	VisitPatientID,--38
	VisitCategory,--39
	VisitProviderKey,--40
	VisitProviderTransition,--41
	VisitUpdateStatus,--42
	VisitUpdateStatusValue--43
)
select
	'1' + '~' + cast(v.Voucher_ID as varchar(50)) VisitID,--1
	1 DataSourceID,--2
	v.Voucher_ID VisitSourceID,--3
	v.Location_Abbr VisitLocationAbbreviation,--4
	v.Department_Abbr VisitDepartmentAbbreviation,--5
	'1~' + cast(v.Billing_Dr_ID as varchar(50)) VisitBillingProviderID, --6
	'1~' + cast(v.Actual_Dr_ID as varchar(50)) VisitActualProviderID, --7
	'' VisitReportProviderID,--8  Needs logic
	'' VisitPracticeProvider, --9  Needs logic
	'1~' + cast(v.Refer_Dr_ID as varchar(50)) VisitReferringProviderID,--10
	v.Voucher_Number VisitNumber,--11
	v.Voucher_Service_Date VisitDateOfService,--12
	v.Posting_Date VisitDateOfPosting,--13
	datediff(DD,v.Voucher_Service_Date,getdate()) VisitDateOfServiceAge,--14
	case when (datediff(DD,v.Voucher_Service_Date,getdate())) < 31 then '1. 0-30' else 
		case when (datediff(DD,v.Voucher_Service_Date,getdate())) < 61 then '2. 31-60' else 
		case when (datediff(DD,v.Voucher_Service_Date,getdate())) < 90 then '3. 61-90' else 
		case when (datediff(DD,v.Voucher_Service_Date,getdate())) < 121 then '4. 90-120' else 
		case when (datediff(DD,v.Voucher_Service_Date,getdate())) < 151 then '5. 121-150' else 
		case when (datediff(DD,v.Voucher_Service_Date,getdate())) < 181 then '6. 151-180' else 
		'181+'
		end end end end end 
	end VisitDateOfServiceAgeGroup,--15
	case when (datediff(DD,v.Voucher_Service_Date,getdate())) >= 366 then '5. 366+' else 
		case when (datediff(DD,v.Voucher_Service_Date,getdate())) >= 91 then '4. 91-365' else
		(
			case when (datediff(DD,v.Voucher_Service_Date,getdate())) < 31 then '1. 0-30' else 
				case when (datediff(DD,v.Voucher_Service_Date,getdate())) < 61 then '2. 31-60' else 
				case when (datediff(DD,v.Voucher_Service_Date,getdate())) < 90 then '3. 61-90' 
				end end
			end 
		)
		end
	end VisitDateOfServiceAgeGroupGraph,--16
	cast(month(v.Posting_Date) as varchar(2)) + '-' + cast(year(v.Posting_Date) as varchar(4)) VisitReportingPeriod,--17
	month(v.Posting_Date) VisitReportPeriodMonth,--18
	year(v.Posting_Date) VisitReportPeriodYear,--19
	case when datediff(MM,v.Posting_Date,getdate()) <=13 then 1 else 0 end VisitRolling13Month,--20
	case when cast(v.Original_Carrier_ID as varchar(50)) is null then '1~SELF' else '1~' + cast(v.Original_Carrier_ID as varchar(50)) end VisitOriginalPayerID,--21
	case when cast(v.Billing_Carrier_ID as varchar(50)) is null then '1~SELF' else '1~' + cast(v.Billing_Carrier_ID as varchar(50)) end VisitBillingPayerID,--22
	'' VisitPayerCategoryOriginal,--23
	'' VisitPayerSubCategoryOriginal,--24
	'' VisitPayerCategoryCurrent,--25
	'' VisitPayerSubCategoryCurrent,--26
	v.Voucher_Balance VisitBalance,--27
	v.Fees VisitFees,--28
	isnull(v.Posted_Payments,0) *-1 VisitPostedPaymenets,--29
	isnull(spb.Self_Pay_Balance,0) VisitSelfPayBalance,--30
	case when v.Voucher_Balance = 0 then 'Zero Balance' else
		case when v.Voucher_Balance < 0 then 'Credit Balance' else
		'Open Balance'
		end
	end VisitBalanceType,--31
	'' VisitProviderReimbursementPercent,--32
	case when i.Voucher_Number is null then 0 else 1 end VisitInfusionFlag,--33
	case when a.Voucher_Number is null then 0 else 1 end VisitHospitalConsultFlag,--34
	case when v.Voucher_Balance > 5 then 1 else 0 end VisitBalanceOverFiveFlag,--35
	case when rad.VisitRadTCCharge is null then 0 else 1 end VisitRadTCChargeFlag,--36
	'' VisitInfusionQualifierFlag,--37
	g.Patient_ID VisitPatientID,--38
	'' VisitCategory, --39  Needs logic and crosswalk for Category
	'' VisitProviderKey,--40  Needs Logic
	case when v.Voucher_Service_Date > '2/28/2021' then 'HPIP' else 'TPG' end VisitProviderTransition,--41
	v.Update_Status VisitUpdateStatus,--42
	case v.Update_Status
		when '0' then 'Not Updated'
		when '1' then 'Updated'
		when '2' then 'Marked Void'
		when '3' then 'Voided'
		when '4' then 'Memo Void'
		when '5' then 'Memo Voided'
	end VisitUpdateStatusValue--43
from tievmdb03.Ntier_627200.PM.vwGenVouchInfo v
left join 
(
	select 
		Self_Pay_Balance, 
		Voucher_Number
	from tievmdb03.Ntier_627200.PM.vwCollAcctVchrInfo
) spb on v.Voucher_Number = spb.Voucher_Number
left join 
(
	select        
		Voucher_Number
	from tievmdb03.Ntier_627200.PM.vwGenProdAnalysis
	where (Department_Abbr = 'TPGR' and Procedure_Code = '96365') or Procedure_Code in
	(
		'96366','96367','96372','96374','96375','96401','96409','96413','96415','J3262','Q5121',
		'J0490','J1740','J0717','J2786','J3380','J3111','J0517','J0638','J3245','Q5103','J2507','J0202',
		'J2182','J2350','J0222','J0129','J2430','J0897','J1301','J1745','Q5104','J9312','Q5119','J1602',
		'J3358','J3357','J1300','J3241','Q5115','J2323','J1823','J3032','J2357','J0565','J3489','J1459',
		'J1556','J1557','J1561','J1566','J1568','J1569','J1200','J2405','J2920','J2930','J2550','J1100',
		'J1720','J1642','J1940','J1885'
	)                
	group by Voucher_Number
) i on v.Voucher_Number = i.Voucher_Number
left join
(
	select 
		h.Voucher_Number Voucher_Number
	from
	(
		select 
			a.Appt_Type_Abbr, 
			a.Appt_Type_Descr, 
			a.Appt_Visit_Type_Abbr, 
			a.Appt_Visit_Type_Descr, 
			a.Patient_ID, 
			a.Patient_Number, 
			cast(a.Appt_DateTime as int) Appt_DateTime,
			v.Voucher_ID,
			v.Voucher_Number
		from tievmdb03.Ntier_627200.PM.vwGenPatApptInfo a
		left join tievmdb03.Ntier_627200.PM.vwGenVouchInfo v on a.Patient_ID = v.Patient_ID  
		where (a.Appt_Status <> 'X') AND (v.Patient_ID IS NOT NULL) AND (a.Appt_Type_Abbr = 'HC10MEM') OR
			(a.Appt_Type_Abbr = 'HC15BRB') OR
			(a.Appt_Type_Abbr = 'HC15DNR') OR
			(a.Appt_Type_Abbr = 'HC15 JCG') OR
			(a.Appt_Type_Abbr = 'HC15 LDH') OR
			(a.Appt_Type_Abbr = 'HC15 LRL') OR
			(a.Appt_Type_Abbr = 'HC15MSO') OR
			(a.Appt_Type_Abbr = 'HC15PBJ') OR
			(a.Appt_Type_Abbr = 'HC15RCD') OR
			(a.Appt_Type_Abbr = 'HC15 RGS') OR
			(a.Appt_Type_Abbr = 'HC15RLN') OR
			(a.Appt_Type_Abbr = 'HC15SKH') OR
			(a.Appt_Type_Abbr = 'HC15SWM') OR
			(a.Appt_Type_Abbr = 'HC15HCR') OR
			(a.Appt_Type_Abbr = 'HC15JHC') OR
			(a.Appt_Type_Abbr = 'HC20ADB') OR
			(a.Appt_Type_Abbr = 'HC30 ADB') OR
			(a.Appt_Type_Abbr = 'HC30 GMM') OR
			(a.Appt_Type_Abbr = 'HC30CAH') OR
			(a.Appt_Type_Abbr = 'HC30JPN')
		group by
			a.Appt_Type_Abbr, 
			a.Appt_Type_Descr, 
			a.Appt_Visit_Type_Abbr, 
			a.Appt_Visit_Type_Descr, 
			a.Patient_ID, 
			a.Patient_Number, 
			cast(a.Appt_DateTime as int), 
			v.Voucher_Number,
			v.Voucher_ID
		having (cast(a.Appt_DateTime as int) > CONVERT(DATETIME, '2020-12-31 00:00:00', 102))
	)h
	group by h.Voucher_Number
)a on v.Voucher_Number = a.Voucher_Number
left join
(
	select
		pa.Voucher_Number,
		'Rad TC Mod' VisitRadTCCharge
	from tievmdb03.Ntier_627200.PM.vwGenProdAnalysis pa
	where pa.TransType = 'c' and pa.PrCtgy_Abbr = 'xray' and pa.Update_status = 1 and pa.Modifiers like '%TC%'
	group by pa.Voucher_Number
) rad on v.Voucher_Number = rad.Voucher_Number
left join
(
	select        
		p.Patient_ID,
		v.Voucher_Number
	from tievmdb03.Ntier_627200.PM.vwGenPatInfo p
	inner join tievmdb03.Ntier_627200.PM.vwGenVouchInfo v ON p.Patient_ID = v.Patient_ID
	group by
		v.Voucher_Number,
		p.Patient_ID
		--p.Prim_Policy_Carrier_Name
)g on v.Voucher_Number = g.Voucher_Number
END
GO
