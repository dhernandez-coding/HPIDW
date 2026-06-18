CREATE VIEW [fact].[vClaims] as
SELECT 
	   c.ClaimID
      ,c.ClaimDataSourceID
      ,c.ClaimSourceID
      ,c.ClaimAcceptanceDate
      ,c.ClaimDateOfService
      ,c.ClaimFromDate
      ,c.ClaimThroughDate
      ,pp.PayerCategoryName AS ClaimPayerCategory
	  ,pp.PayerName as ClaimPayerName
      ,pa.PayerPlanName
      ,c.ClaimCoverageID
      ,c.ClaimDefinitionID
      ,c.ClaimInvoiceNumber
	  ,pt.PatientMRN as ClaimPatientMRN
      ,pt.PatientFullName as ClaimPatientName
      ,p.ProviderFullName as ClaimProviderName
      ,c.ClaimAccountID
      ,c.ClaimLiabilityBucketID
      ,l.LocationName
      ,d.DepartmentName
	  ,c.ClaimConditionCode
	  ,c.ClaimConditionCodeDescription
      ,c.ClaimFormType
      ,c.ClaimType
      ,c.ClaimAccountType
      ,c.ClaimClassType
      ,c.ClaimTotalCharges
      ,c.ClaimTotalDue
      ,c.ClaimNonCoveredAmount
      ,c.ClaimTotalPayments
      ,c.ClaimTotalAdjustments
      ,c.ClaimBillType
      ,c.ClaimUpdateDateTime
  FROM [HPIDW].[fact].[Claims] c
	LEFT JOIN dim.vProviders p on p.ProviderID = c.ClaimProviderID
	LEFT JOIN dim.vPayers pp on pp.PayerID = c.ClaimPayorID
	LEFT JOIN dim.vPayerPlans pa on pa.PayerPlanID = c.ClaimPlanID
	LEFT JOIN dim.vPatients pt on pt.PatientID = c.ClaimPatientID
	LEFT JOIN dim.vLocations l on l.LocationID = c.ClaimLocationID
	LEFT JOIN dim.vDepartments d on d.DepartmentID = c.ClaimDepartmentID
GO
