-- =============================================
-- Author:		Ryan Tisserand
-- Create date: 11/23/2022
-- Description:	Extracts, Transforms and Loads Visit Data from APM Source System into a dim Table
-- Change Control
--	1. 11/23/2022 - Ryan Tisserand - Initial build of procedure
-- =============================================
CREATE PROCEDURE [stg].[spAPMReloadFactVisitsFull]
AS
BEGIN
SET NOCOUNT ON;

insert into fact.Visits
(
	VisitID,--1
	DataSourceID,--2
	VisitSourceID,--3
	VisitLocationID,--4
	VisitDepartmentID,--5
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
	v.VisitID,--1
	v.DataSourceID,--2
	v.VisitSourceID,--3
	l.LocationID VisitLocationID,--4
	d.DepartmentID VisitDepartmentID,--5
	v.VisitBillingProviderID,--6
	v.VisitActualProviderID,--7
	case when bp.ProviderAssignmentProviderType + '-' + ap.ProviderAssignmentProviderType = 'Aux-Primary' then bp.ProviderID else
		case when bp.ProviderAssignmentProviderType + '-' + ap.ProviderAssignmentProviderType = 'Primary-Aux' then ap.ProviderID else
			case when ap.ProviderID = '1~18564' then '1~18564' else
				bp.ProviderID
			end
		end
	end VisitReportProviderID,--8
	case when 
	(
		case when bp.ProviderAssignmentProviderType + '-' + ap.ProviderAssignmentProviderType = 'Aux-Primary' then bp.ProviderID else
			case when bp.ProviderAssignmentProviderType + '-' + ap.ProviderAssignmentProviderType = 'Primary-Aux' then ap.ProviderID else
				case when ap.ProviderID = '1~18564' then '1~18564' else
					bp.ProviderID
				end
			end
		end
	) = '1~13942' 
	then 
		case when v.VisitDateOfService >= '3/1/2021' then '1~18488'
	end
	else
		case when bp.ProviderAssignmentProviderType + '-' + ap.ProviderAssignmentProviderType = 'Aux-Primary' then bp.ProviderID else
			case when bp.ProviderAssignmentProviderType + '-' + ap.ProviderAssignmentProviderType = 'Primary-Aux' then ap.ProviderID else
				case when ap.ProviderID = '1~18564' then '1~18564' else
					bp.ProviderID
				end
			end
		end
	end VisitPracticeProviderID,--9
	v.VisitReferringProviderID,--10
	v.VisitNumber,--11
	v.VisitDateOfService,--12
	v.VisitDateOfPosting,--13
	v.VisitDateOfServiceAge,--14
	v.VisitDateOfServiceAgeGroup,--15
	v.VisitDateOfServiceAgeGroupGraph,--16
	v.VisitReportingPeriod,--17
	v.VisitReportPeriodMonth,--18
	v.VisitReportPeriodYear,--19
	v.VisitRolling13Month,--20
	v.VisitOrginalPayerID,--21
	v.VisitBillingPayerID,--22
	op.PayerCategory VisitPayerCategoryOriginal,--23
	op.PayerSubCategory VisitPayerSubCategoryOriginal,--24
	cp.PayerCategory VisitPayerCategoryCurrent,--25
	cp.PayerSubCategory VisitPayerSubCategoryCurrent,--26
	v.VisitBalance,--27
	v.VisitFees,--28
	v.VisitPostedPaymenets,--29
	v.VisitSelfPayBalance,--30
	v.VisitBalanceType,--31
	case when v.VisitPostedPaymenets = 0 then 0
		else case when v.VisitFees = 0 then 0
			else (v.VisitPostedPaymenets *-1) / v.VisitFees
			end
	end VisitProviderReimbursementPercent,--32
	v.VisitInfusionFlag,--33
	v.VisitHospitalConsultFlag,--34
	v.VisitBalanceOverFiveFlag,--35
	v.VisitRadTCChargeFlag,--36
	v.VisitInfusionQualifierFlag,--37-----Needs Logic, needs Category figured out first
	v.VisitPatientID,--38
	v.VisitCategory,--39-----Needs Logic, most likely will put Category in Transactions, TransactionCategory instead of VisitCategory
	v.VisitProviderKey,--40-----Needs Logic
	v.VisitProviderTransition,--41
	v.VisitUpdateStatus,--42
	v.VisitUpdateStatusValue--43
from stg.APMVisits v
left join dim.Locations l on v.DataSourceID = l.DataSourceID and v.VisitLocationAbbreviation = l.LocationAbbreviation
left join dim.Departments d on v.DataSourceID =  d.DataSourceID and v.VisitDepartmentAbbreviation = d.DepartmentAbbreviation
left join dim.Payers op on v.DataSourceID = op.DataSourceID and v.VisitOrginalPayerID = op.PayerID
left join dim.Payers cp on v.DataSourceID = cp.DataSourceID and v.VisitBillingPayerID = cp.PayerID
left join dim.Providers bp on v.DataSourceID = bp.DataSourceID and v.VisitBillingProviderID = bp.ProviderID
left join dim.Providers bpwf on v.DataSourceID = bpwf.DataSourceID and bp.ProviderAssignmentWorksForID = bpwf.ProviderID
left join dim.Providers ap on v.DataSourceID = ap.DataSourceID and  v.VisitActualProviderID = ap.ProviderID
left join dim.Providers apwf on v.DataSourceID = apwf.DataSourceID and ap.ProviderAssignmentWorksForID = apwf.ProviderID
left join dim.Providers rp on v.DataSourceID = rp.DataSourceID and v.VisitReferringProviderID = rp.ProviderID
END
GO
