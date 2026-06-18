-- =============================================
-- Author:		Ryan Tisserand
-- Create date: 08/31/2022
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [stg].[spAPMLoadVisitsFull]
AS
BEGIN
SET NOCOUNT ON;
--truncate table stg.Visits
--insert into stg.Visits
select top 1000
	1 DataSourceID,
	v.Voucher_ID VisitSourceID,
	v.Voucher_Number VisitNumber,
	v.Voucher_Service_Date VisitDateOfService,
	pg.PayerCategory VisitPayerCategory,
	v.Original_Carrier_Category_Descr VisitPayerSubCategory,
	pgc.PayerCategory VisitPayerCategoryCurrent,
	v.Billing_Carrier_Category_Descr VisitPayerSubCategoryCurrent,
	v.Voucher_Balance VisitBalance,
	v.Fees VisitFees,
	isnull(v.Posted_Payments,0) *-1 VisitPostedPaymenets,
	v.Billing_Dr_Abbr VisitBillingProvider, --Needs crosswalk to Report Dr
	pap.ProviderAssignmentPracticeProvider PracticProvider,
	v.Actual_Dr_Abbr VisitActualProvider, --Needs crosswalk to Report Dr
	'' VisitReportProiver,--Needs crosswalk to Report Dr
	'' VisitPracticeProvider, --Needs crosswalk to Billing and Actual Provider
	v.Refer_Dr_Abbr VisitReferringProvider,
	'' VisitCategory, --Needs crosswalk for Category
	month(v.Posting_Date) VisitReportPeriodMonth,
	year(v.Posting_Date) VisitReportPeriodYear,
	l.LocationID VisitLocationID,
	v.Posting_Date VisitDateOfPosting,
	spb.Self_Pay_Balance VisitSelfPayBalance,
	isnull(p.VisitRadTCCharge,'') VisitRadTCCharge,
	case when v.Voucher_Balance > 5 then 1 else 0 end VisitBalanceOverFiveFlag,
	case when p.VisitRadTCCharge is null then 0 else 1 end VisitRadTCChargeFlag,
	case when a.Voucher_Number is null then 0 else 1 end VisitHospitalConsultFlag,
	case when i.Voucher_Number is null then 0 else 1 end VisitInfusionFlag,
	g.Patient_ID
from tievmdb03.Ntier_627200.PM.vwGenVouchInfo v
left join map.PayerCategories pg on v.Original_Carrier_Category_Descr = pg.PayerSubCategory
left join map.PayerCategories pgc on v.Original_Carrier_Category_Descr = pgc.PayerSubCategory

	left join map.ProviderAssignments pap on v.Billing_Dr_Abbr = pap.ProviderAssignmentAbbreviation
	left join map.ProviderAssignments wfp on pap.ProviderAssignmentWorksFor = wfp.ProviderAssignmentAbbreviation

left join dim.Locations l on v.Department_Abbr = l.LocationDepartmentAbbreviation and l.DataSourceID = 1
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
		pa.Voucher_Number,
		'Rad TC Mod' VisitRadTCCharge
	from tievmdb03.Ntier_627200.PM.vwGenProdAnalysis pa
	where pa.TransType = 'c' and pa.PrCtgy_Abbr = 'xray' and pa.Update_status = 1 and pa.Modifiers like '%TC%'
	group by pa.Voucher_Number
) p on v.Voucher_Number = p.Voucher_Number
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
		a.Appt_Type_Abbr, 
		a.Appt_Type_Descr, 
		a.Appt_Visit_Type_Abbr, 
		a.Appt_Visit_Type_Descr, 
		a.Patient_ID, 
		a.Patient_Number, 
		cast(a.Appt_DateTime as int) Appt_DateTime,
		v.Voucher_Number
	from tievmdb03.Ntier_627200.PM.vwGenPatApptInfo a
	left join tievmdb03.Ntier_627200.PM.vwGenVouchInfo v on a.Patient_ID = v.Patient_ID
	where  
		(a.Appt_Status <> 'X') AND (v.Patient_ID IS NOT NULL) AND (a.Appt_Type_Abbr = 'HC10MEM') OR
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
		v.Voucher_Number
	having (cast(a.Appt_DateTime as int) > CONVERT(DATETIME, '2020-12-31 00:00:00', 102))
)a on v.Voucher_Number = a.Voucher_Number
left join
(
	select        
		p.Patient_ID,
		v.Voucher_Number
	from tievmdb03.Ntier_627200.PM.vwGenPatInfo p
	inner join tievmdb03.Ntier_627200.PM.vwGenVouchInfo v ON p.Patient_ID = v.Patient_ID
	group by
		v.Voucher_Number, 
		p.Patient_ID, 
		p.Prim_Policy_Carrier_Name
)g on v.Voucher_Number = g.Voucher_Number


END
GO
