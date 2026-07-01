-- =============================================
-- Author:		Eric Silvestri
-- ALTER PROCEDURE10/2024
-- Description:	Stored Procedure to load the PB Month End reports


-- =============================================
CREATE   PROCEDURE [rpt].[spPBMonthEndReporting]

	 @CurrentYear int 
	,@CurrentPeriod int 
	,@Practice varchar(10)
	--,@SpecialFilter varchar(50)

AS

	--DECLARE @CurrentYear int = 2024
	--DECLARE @CurrentPeriod int = 04
	DECLARE @EndDate date = DATEFROMPARTS(@CurrentYear,@CurrentPeriod,1)
	DECLARE @StartDate date = DATEFROMPARTS(@CurrentYear-2,1,1)
	DECLARE @13MonthStartDate date = DATEADD(MONTH,-13,@EndDate)


BEGIN

SET NOCOUNT ON;

SELECT
	t.TransactionVisitID as PBMonthEndVisitID
	,pt.PatientMRN as PBMonthEndPatientMRN
	,pt.PatientFullName as PBMonthEndPatientName
	,t.TransactionPracticeID as PBMonthEndPracticeID
	,p.PracticeName as PBMonthEndPracticeName
	,pr.ProviderFullName as PBMonthEndReportingProvider
	,l.LocationName as PBMonthEndLocationName
	,d.DepartmentName as PBMonthEndDepartmentName
	,t.TransactionDateOfService as PBMonthEndDateOfService
	,t.TransactionDateOfPosting as PBMonthEndDateOfPosting
	,t.TransactionReportPeriod as  PBMonthEndReportingPeriod
	,t.TransactionReportPeriodDate as PBMonthEndReportPeriodDate
	,LEFT(t.TransactionReportPeriodDate, 4) as PBMonthEndReportYear
	,RIGHT(t.TransactionReportPeriodDate, 2) as PBMonthEndReportMonth
	,t.TransactionCPTCode as PBMonthEndCPTCode
	,t.TransactionUnits as PBMonthEndTransactionUnits
	,t.ProcedureCategory as PBMonthEndProcedureCategory
	,pa.PayerCategoryName as PBMonthEndPayerCategoryName
	,pa.PayerName as PBMonthEndPayerName
	,t.TransactionGLType as PBMonthEndGLType
	,t.TransactionIsActive as PBMonthEndTransactionIsActive
	,t.TransactionStatus as PBMonthEndTransactionStatus
	,CASE WHEN t.TransactionType = 'Charge' THEN SUM(t.TransactionAmount) END as PBMonthEndCharges
	,CASE WHEN t.TransactionType = 'Payment' THEN SUM(t.TransactionAmount) END as PBMonthEndPayments
	,CASE WHEN t.TransactionType = 'Adjustment' THEN SUM(t.TransactionAmount) END as PBMonthEndAdjustments
	,CASE WHEN t.TransactionSubType = 'Refund' THEN SUM(t.TransactionAmount) END as PBMonthEndRefunds
	,CASE WHEN DATEFROMPARTS(LEFT(t.TransactionReportPeriodDate, 4), RIGHT(t.TransactionReportPeriodDate, 2),1) between @13MonthStartDate AND DATEADD(DAY,-1,@EndDate) THEN 'Y' ELSE 'N' END as PBMonthEndTrailing13Months
	
FROM [HPIDW].[fact].[vTransactionsPB] t
	LEFT JOIN dim.vPractices p on p.PracticeID = t.TransactionPracticeID
	LEFT JOIN dim.vProviders pr on pr.ProviderID = t.TransactionBillingProviderID
	LEFT JOIN dim.vPayers pa on pa.PayerID = t.TransactionPayerID
	LEFT JOIN dim.vPatients pt on pt.PatientID = t.PatientID
	LEFT JOIN dim.vLocations l on l.LocationID = t.TransactionVisitLocationID
	LEFT JOIN dim.vDepartments d on d.DepartmentID = t.TransactionDepartmentID
WHERE 1=1
GROUP BY
	t.TransactionVisitID
	,pt.PatientMRN
	,pt.PatientFullName
	,t.TransactionPracticeID
	,p.PracticeName
	,pr.ProviderFullName 
	,l.LocationName
	,d.DepartmentName
	,t.TransactionDateOfService
	,t.TransactionDateOfPosting
	,t.TransactionReportPeriod
	,t.TransactionReportPeriodDate
	,t.TransactionCPTCode
	,t.TransactionUnits
	,t.ProcedureCategory
	,pa.PayerCategoryName
	,pa.PayerName
	,t.TransactionGLType
	,t.TransactionIsActive
	,t.TransactionStatus
	,t.TransactionType
	,t.TransactionSubType

END
GO
