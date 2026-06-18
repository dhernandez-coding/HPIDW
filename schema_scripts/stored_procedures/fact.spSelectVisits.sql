-- =============================================
-- Author:		Eric Silvestri
-- Create date: 01/27/2023
-- Description:	Selects all Visits
-- Change Control
--	1. 01/27/2023 - Eric Silvestri - Initial build of procedure
--  2. 02/01/2023 - Ryan Tisserand - Rebuilt procedure from View since it didn't have updates.  Updated view with procedure code
-- =============================================
CREATE PROCEDURE [fact].[spSelectVisits]
AS
BEGIN
SET NOCOUNT ON;
select
	v.VisitID, v.DataSourceID, v.VisitSourceID, 
	l.LocationAbbreviation, 
	l.LocationName, 
	l.LocationDescription, 
	d.DepartmentAbbreviation, 
	d.DepartmentName, 
	d.DepartmentDescription, 
	bp.ProviderFirstName + ' ' + bp.ProviderLastName BillingProviderFullName, 
	bp.ProviderAbbreviation BillingProviderAbbreviation, 
	ap.ProviderFirstName + ' ' + ap.ProviderLastName ActualProviderFullName, 
	ap.ProviderAbbreviation ActualProviderAbbreviation, 
	rp.ProviderFirstName + ' ' + rp.ProviderLastName ReportProviderFullName, 
	rp.ProviderAbbreviation ReportProviderAbbreviation, 
	pp.ProviderFirstName + ' ' + pp.ProviderLastName PracticeProviderFullName, 
	pp.ProviderAbbreviation PracticeProviderAbbreviation, 
	ref.ProviderFirstName + ' ' + ref.ProviderLastName ReferringProviderFullName, 
	ref.ProviderAbbreviation ReferringProviderAbbreviation, 
	v.VisitNumber, 
	v.VisitDateOfService, 
	v.VisitDateOfPosting, 
	v.VisitDateOfServiceAge, 
	v.VisitDateOfServiceAgeGroup, 
	v.VisitDateOfServiceAgeGroupGraph, 
	v.VisitReportingPeriod, 
	v.VisitReportPeriodMonth, 
	v.VisitReportPeriodYear, 
	v.VisitRolling13Month, 
	v.VisitPayerCategoryOriginal, 
	v.VisitPayerSubCategoryOriginal, 
	po.PayerName VisitPayerOriginalName, 
	v.VisitPayerCategoryCurrent, 
	v.VisitPayerSubCategoryCurrent, 
	pb.PayerName VisitPayerCurrentName, 
	v.VisitBalance, v.VisitFees, 
	v.VisitPostedPaymenets, 
	v.VisitSelfPayBalance, 
	v.VisitBalanceType, 
	v.VisitProviderReimbursementPercent, 
	v.VisitInfusionFlag, 
	v.VisitHospitalConsultFlag, 
	v.VisitBalanceOverFiveFlag, 
	v.VisitRadTCChargeFlag, 
	v.VisitInfusionQualifierFlag, 
	p.PatientFullName, 
	p.PatientNumber, 
	v.VisitCategory, 
	v.VisitProviderKey, 
	v.VisitProviderTransition, 
	v.VisitUpdateStatus, 
	v.VisitUpdateStatusValue
from fact.Visits v 
left join dim.Locations l on v.DataSourceID = l.DataSourceID and v.VisitLocationID = l.LocationID 
left join dim.Departments d on v.DataSourceID = d.DataSourceID and v.VisitDepartmentID = d.DepartmentID 
left join dim.Providers  bp on v.DataSourceID = bp.DataSourceID and v.VisitBillingProviderID = bp.ProviderID 
left join dim.Providers  ap on v.DataSourceID = ap.DataSourceID and v.VisitActualProviderID = ap.ProviderID 
left join dim.Providers  rp on v.DataSourceID = rp.DataSourceID and v.VisitReportProviderID = rp.ProviderID 
left join dim.Providers  pp on v.DataSourceID = pp.DataSourceID and v.VisitPracticeProviderID = pp.ProviderID 
left join dim.Providers  ref on v.DataSourceID = ref.DataSourceID and v.VisitReferringProviderID = ref.ProviderID 
left join dim.Payers  po on v.DataSourceID = po.DataSourceID and v.VisitOrginalPayerID = po.PayerID 
left join dim.Payers  pb on v.DataSourceID = pb.DataSourceID and v.VisitBillingPayerID = pb.PayerID 
left join dim.Patients  p on v.DataSourceID = p.DataSourceID and v.VisitPatientID = p.SourcePatientID
END
GO
