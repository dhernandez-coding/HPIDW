CREATE VIEW fact.vVisits
AS
SELECT        v.VisitID, v.DataSourceID, v.VisitSourceID, l.LocationAbbreviation, l.LocationName, l.LocationDescription, d.DepartmentAbbreviation, d.DepartmentName, d.DepartmentDescription, 
                         bp.ProviderFirstName + ' ' + bp.ProviderLastName AS BillingProviderFullName, bp.ProviderAbbreviation AS BillingProviderAbbreviation, ap.ProviderFirstName + ' ' + ap.ProviderLastName AS ActualProviderFullName, 
                         ap.ProviderAbbreviation AS ActualProviderAbbreviation, rp.ProviderFirstName + ' ' + rp.ProviderLastName AS ReportProviderFullName, rp.ProviderAbbreviation AS ReportProviderAbbreviation, 
                         pp.ProviderFirstName + ' ' + pp.ProviderLastName AS PracticeProviderFullName, pp.ProviderAbbreviation AS PracticeProviderAbbreviation, ref.ProviderFirstName + ' ' + ref.ProviderLastName AS ReferringProviderFullName, 
                         ref.ProviderAbbreviation AS ReferringProviderAbbreviation, v.VisitNumber, v.VisitDateOfService, v.VisitDateOfPosting, v.VisitDateOfServiceAge, v.VisitDateOfServiceAgeGroup, v.VisitDateOfServiceAgeGroupGraph, 
                         v.VisitReportingPeriod, v.VisitReportPeriodMonth, v.VisitReportPeriodYear, v.VisitRolling13Month, v.VisitPayerCategoryOriginal, v.VisitPayerSubCategoryOriginal, po.PayerName AS VisitPayerOriginalName, 
                         v.VisitPayerCategoryCurrent, v.VisitPayerSubCategoryCurrent, pb.PayerName AS VisitPayerCurrentName, v.VisitBalance, v.VisitFees, v.VisitPostedPaymenets, v.VisitSelfPayBalance, v.VisitBalanceType, 
                         v.VisitProviderReimbursementPercent, v.VisitInfusionFlag, v.VisitHospitalConsultFlag, v.VisitBalanceOverFiveFlag, v.VisitRadTCChargeFlag, v.VisitInfusionQualifierFlag, p.PatientFullName, p.PatientNumber, v.VisitCategory, 
                         v.VisitProviderKey, v.VisitProviderTransition, v.VisitUpdateStatus, v.VisitUpdateStatusValue
FROM            fact.Visits AS v LEFT OUTER JOIN
                         dim.Locations AS l ON v.DataSourceID = l.DataSourceID AND v.VisitLocationID = l.LocationID LEFT OUTER JOIN
                         dim.Departments AS d ON v.DataSourceID = d.DataSourceID AND v.VisitDepartmentID = d.DepartmentID LEFT OUTER JOIN
                         dim.Providers AS bp ON v.DataSourceID = bp.DataSourceID AND v.VisitBillingProviderID = bp.ProviderID LEFT OUTER JOIN
                         dim.Providers AS ap ON v.DataSourceID = ap.DataSourceID AND v.VisitActualProviderID = ap.ProviderID LEFT OUTER JOIN
                         dim.Providers AS rp ON v.DataSourceID = rp.DataSourceID AND v.VisitReportProviderID = rp.ProviderID LEFT OUTER JOIN
                         dim.Providers AS pp ON v.DataSourceID = pp.DataSourceID AND v.VisitPracticeProviderID = pp.ProviderID LEFT OUTER JOIN
                         dim.Providers AS ref ON v.DataSourceID = ref.DataSourceID AND v.VisitReferringProviderID = ref.ProviderID LEFT OUTER JOIN
                         dim.Payers AS po ON v.DataSourceID = po.DataSourceID AND v.VisitOrginalPayerID = po.PayerID LEFT OUTER JOIN
                         dim.Payers AS pb ON v.DataSourceID = pb.DataSourceID AND v.VisitBillingPayerID = pb.PayerID LEFT OUTER JOIN
                         dim.Patients AS p ON v.DataSourceID = p.DataSourceID AND v.VisitPatientID = p.SourcePatientID
GO
