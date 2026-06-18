CREATE VIEW [fact].[vDenialsHB] AS


SELECT d.[DenialID]
      ,d.[DenialSourceID]
      ,d.[DenialDataSourceID]
      ,d.[DenialTransactionID]
      ,d.[DenialType]
      ,d.[DenialRemitID]
      ,d.[DenialRemitDescription]
      ,d.[DenialExternalRemitCode]
      ,d.[DenialRemarkStatus]
      ,d.[DenialCodeGroup]
      ,d.[DenailCodeCategory]
      ,d.[DenialResolution]
      ,d.[DenialSource]
      ,d.[DenialRootCause]
      ,d.[DenialCliniclCause]
      ,d.[DenialPreventable]
      ,d.[DenialDateRecieved]
      ,d.[DenialDateCreated]
      ,d.[DenialDaysOpen]
	  ,CASE WHEN d.[DenialDaysOpen]<= 30 THEN '0 to 30'
		WHEN d.[DenialDaysOpen] between 31 and 60 THEN '31 to 60'
		WHEN d.[DenialDaysOpen] between 61 and 90  THEN '61 to 90'
		WHEN d.[DenialDaysOpen] between 91 and 120  THEN '91 to 120'
		WHEN d.[DenialDaysOpen] between 121 and 150  THEN '121 to 150'
		ELSE '+150'
		END as DenialAgeBucket
	  ,CASE WHEN d.[DenialWriteOffAmount] IS NULL THEN 'No' ELSE 'Yes' END as DenialWriteOffFlag
      ,d.[DenialDateResolved]
      ,d.[DenialDateReopened]
      ,p.PayerCategoryName as DenialPayerCategory
      ,p.PayerName as DenialPayerName
      ,d.[DenialStatus]
      ,d.[DenialBalance]
      ,d.[DenialBucketStatus]
      ,d.[DenialBucketFinancialClass]
      ,d.[DenialBilledAmount]
      ,d.[DenialAllowedAmount]
      ,d.[DenialPaidAmount]
      ,d.[DenialDeniedAmount]
      ,d.[DenialAccountID]
      ,d.[DenialPatientName]
	  ,pp.ProviderFullName as DenialProviderName
      ,d.[DenialAccountStatus]
      ,d.[DenialAccountBalance]
      ,d.[DenialVisitClass]
      ,d.[DenialVisitType]
      ,l.LocationName as DenialLocationName
      ,dd.DepartmentName as DenialDepartmentName
      ,d.[DenialDateOfAdmission]
      ,d.[DenialDateOfDischarge]
      ,d.[DenialEndOfDayBucketBalance]
      ,d.[DenialRepoenDays]
      ,d.[DenialClass]
      ,d.[DenialServiceLine]
      ,d.[DenialWriteOffAmount]
      ,d.[DenialRecoveryAmount]
      ,d.[DenialPaymentTotal]
      ,d.[DenialUpdateDate]
  FROM [HPIDW].[fact].[DenialsHB] d
  LEFT JOIN [HPIDW].dim.vPayers p on p.PayerID = d.DenialPayerCategoryID
  LEFT JOIN [HPIDW].dim.vDepartments dd on dd.DepartmentID = d.DenialDepartmentID
  LEFT JOIN [HPIDW].dim.vLocations l on l.LocationID = d.DeniallocationID
  LEFT JOIN [HPIDW].dim.vProviders pp on pp.ProviderID = d.DenialBillingProviderID
  --where d.[DenialTransactionID] <> '5~'
GO
