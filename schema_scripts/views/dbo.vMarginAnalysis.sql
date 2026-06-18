CREATE view [dbo].[vMarginAnalysis] as

with cteTotalPayments 
as 
(
    select 
        patno
        ,sum(tamt) * -1 TotalPayment
    from fact.MedhostTransactions
    where recid = 'P'
    group by patno
)

-- case header
select 
	ors.ORCase
	,ors.MedicalRecord
	,ors.ADTCaseNumber PatientNumber
	,ors.SurgeryDate
	,ors.PhysFirst +' '+ ors.PhysLast Physician
	,ss.Specialty as PhysicianSpeciality
	,ors.FirstName +' '+ ors.MI +' '+ ors.LastName Patient
	,ors.Procedure_ [Procedure]
	,ors.InsuranceProvider HPIPayerRollup
	--,Payments
	--,PharmaCost
	--,CellSaverCost
	--,MonitoringCost
	--,DirectMargin
	,ors.ScheduledService
	,cs.PrimaryCPT
	,cs.CaseProcedure
	,ar.orgbl as OriginalBill
	,ar.curbl as CurrentBill
	,ar.icname as InsuranceProvider
	,ar.insnme as InsurancePlan
	,p.TotalPayment
	,110 as Facility
from [CORHPIVMAP14].[DATA_PIMS_OK_OklahomaCity_CommunityHospital].[dbo].[ORSched] ors -- visits
left join CORHPIVMAP14.DATA_PIMS_OK_OklahomaCity_CommunityHospital.dbo.DG_SurgeonSpecialties ss on ors.PhysLast = ss.Last and ors.PhysFirst = ss.First
left join CORHPIVMAP14.DATA_PIMS_OK_OklahomaCity_CommunityHospital.dbo.PIMS_Sch_CaseSchedule cs on ors.AnesCaseNumber = cs.CaseId
left join stg.MedhostArMastInsurance ar on ors.ADTCaseNumber = ar.patno
left join cteTotalPayments p on ors.ADTCaseNumber = p.patno
where isnumeric(ors.ADTCaseNumber) = 1
	and ors.Cancelled = 0
	and  year(ors.SurgeryDate) >= YEAR(GETDATE()) - 2

union all

select 
	ors.ORCase
	,ors.MedicalRecord
	,ors.ADTCaseNumber PatientNumber
	,ors.SurgeryDate
	,ors.PhysFirst +' '+ ors.PhysLast Physician
	,ss.Specialty as PhysicianSpeciality
	,ors.FirstName +' '+ ors.MI +' '+ ors.LastName Patient
	,ors.Procedure_ [Procedure]
	,ors.InsuranceProvider HPIPayerRollup
	--,Payments
	--,PharmaCost
	--,CellSaverCost
	--,MonitoringCost
	--,DirectMargin
	,ors.ScheduledService
	,cs.PrimaryCPT
	,cs.CaseProcedure
	,ar.orgbl as OriginalBill
	,ar.curbl as CurrentBill
	,ar.icname as InsuranceProvider
	,ar.insnme as InsurancePlan
	,p.TotalPayment
	,100 as Facility
from [CORHPIVMAP14].[DATA_PIMS_OK_OklahomaCity_NorthwestSurgicalHospital].[dbo].[ORSched] ors -- visits
left join CORHPIVMAP14.DATA_PIMS_OK_OklahomaCity_CommunityHospital.dbo.DG_SurgeonSpecialties ss on ors.PhysLast = ss.Last and ors.PhysFirst = ss.First
left join CORHPIVMAP14.DATA_PIMS_OK_OklahomaCity_NorthwestSurgicalHospital.dbo.PIMS_Sch_CaseSchedule cs on ors.AnesCaseNumber = cs.CaseId
left join stg.MedhostArMastInsurance ar on ors.ADTCaseNumber = ar.patno
left join cteTotalPayments p on ors.ADTCaseNumber = p.patno
where isnumeric(ors.ADTCaseNumber) = 1
	and ors.Cancelled = 0
	and  year(ors.SurgeryDate) >= YEAR(GETDATE()) - 2
GO
