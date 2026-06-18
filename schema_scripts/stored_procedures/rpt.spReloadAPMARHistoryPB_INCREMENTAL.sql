CREATE PROCEDURE [rpt].[spReloadAPMARHistoryPB_INCREMENTAL] as
		
/* 
-- =============================================
-- Author:		Robert Beaird
-- Create date: May 29 2024  1:30PM
-- Edit date:   
-- Description:	full reload for rpt.ARHistoryPB from APM, run AFTER MIDNIGHT 1ST DAY OF MONTH
-- ============================================= 
*/
BEGIN

IF DAY(GETDATE()) = 1
BEGIN

PRINT 'First day of month, executing job...'

/*-----INSERT INTO @StagingTable-----*/
	PRINT 'Creating @StagingTable....'
	DECLARE @StagingTable table						
	(ARHistoryID varchar(100)
	,ARHistoryDate date
	,TransactionDataSourceID int
	,TransactionSourceID varchar(50)
	,TransactionType varchar(50)
	,TransactionLocationID varchar(50)
	,TransactionDepartmentID varchar(50)
	,TransactionPlaceOfServiceID varchar(50)
	,TransactionPlaceOfServiceType varchar(50)
	,TransactionGuarantorID varchar(50)
	,TransactionGuarantorType varchar(50)
	,TransactionAccountID varchar(50)
	,TransactionAccountClass varchar(50)
	,TransactionVisitID varchar(50)
	,TransactionVisitType varchar(50)
	,CurrentFinancialClass varchar(50)
	,CurrentPayerID varchar(50)
	,CurrentPayerPlanID varchar(50)
	,OriginalFinancialClass varchar(50)
	,OriginalPayerID varchar(50)
	,OriginalPayerPlanID varchar(50)
	,TransactionServiceProviderID varchar(50)
	,TransactionBillingProviderID varchar(50)
	,TransactionCode varchar(50)
	,TransactionDescription varchar(300)
	,TransactionCPTCode varchar(30)
	,TransactionModifier1 varchar(30)
	,TransactionModifier2 varchar(30)
	,TransactionModifier3 varchar(30)
	,TransactionModifier4 varchar(30)
	,TransactionUnits decimal
	,TransactionLedgerType varchar(30)
	,TransactionOriginalAmount money
	,TransactionARAmountAll money
	,TransactionARAmountSelfPay money
	,TransactionARAmountInsurance money
	,TransactionARAmountActive money
	,TransactionARAmountBadDebt money
	,TransactionServiceDate date
	,TransactionServiceDateAge int
	,TransactionPostDate date
	,TransactionPostDateAge int
	,TransactionInsuranceAgeDate date
	,TransactionInsuranceAge int
	,TransactionFirstClaimDate date
	,TransactionLastClaimDate date
	,TransactionSelfPayAgeDate date
	,TransactionSelfPayAge int
	,ARHistoryUpdatedDatetime datetime
	)
	
	PRINT 'Inserting records from Datasource into @StagingTable....'
	INSERT INTO @StagingTable 
	(ARHistoryID
	,ARHistoryDate
	,TransactionDataSourceID
	,TransactionSourceID
	,TransactionType
	,TransactionLocationID
	,TransactionDepartmentID
	,TransactionPlaceOfServiceID
	,TransactionPlaceOfServiceType
	,TransactionGuarantorID
	,TransactionGuarantorType
	,TransactionAccountID
	,TransactionAccountClass
	,TransactionVisitID
	,TransactionVisitType
	,CurrentFinancialClass
	,CurrentPayerID
	,CurrentPayerPlanID
	,OriginalFinancialClass
	,OriginalPayerID
	,OriginalPayerPlanID
	,TransactionServiceProviderID
	,TransactionBillingProviderID
	,TransactionCode
	,TransactionDescription
	,TransactionCPTCode
	,TransactionModifier1
	,TransactionModifier2
	,TransactionModifier3
	,TransactionModifier4
	,TransactionUnits
	,TransactionLedgerType
	,TransactionOriginalAmount
	,TransactionARAmountAll
	,TransactionARAmountSelfPay
	,TransactionARAmountInsurance
	,TransactionARAmountActive
	,TransactionARAmountBadDebt
	,TransactionServiceDate
	,TransactionServiceDateAge
	,TransactionPostDate
	,TransactionPostDateAge
	,TransactionInsuranceAgeDate
	,TransactionInsuranceAge
	,TransactionFirstClaimDate
	,TransactionLastClaimDate
	,TransactionSelfPayAgeDate
	,TransactionSelfPayAge
	,ARHistoryUpdatedDatetime
	)

	SELECT
	CONCAT('1~',FORMAT(DATEADD(day, -DAY(GETDATE()), GETDATE()),'MM-dd-yyyy') ,'~',RIGHT(ac.TransactionAccountID,LEN(ac.TransactionAccountID)-2)) as ARHistoryID
	,FORMAT(DATEADD(day, -DAY(GETDATE()), GETDATE()),'MM-dd-yyyy') AS ARHistoryDate
	,TransactionDataSourceID
	,TransactionSourceID
	,TransactionType
	,TransactionLocationID
	,TransactionDepartmentID
	,TransactionPlaceOfServiceID
	,TransactionPlaceOfServiceType
	,TransactionGuarantorID
	,TransactionGuarantorType
	,TransactionAccountID
	,TransactionAccountClass
	,TransactionVisitID
	,TransactionVisitType
	,CurrentFinancialClass
	,CurrentPayerID
	,CurrentPayerPlanID
	,OriginalFinancialClass
	,OriginalPayerID
	,OriginalPayerPlanID
	,TransactionServiceProviderID
	,TransactionBillingProviderID
	,TransactionCode
	,TransactionDescription
	,TransactionCPTCode
	,TransactionModifier1
	,TransactionModifier2
	,TransactionModifier3
	,TransactionModifier4
	,TransactionUnits
	,TransactionLedgerType
	,TransactionOriginalAmount
	,TransactionARAmountAll
	,TransactionARAmountSelfPay
	,TransactionARAmountInsurance
	,TransactionARAmountActive
	,TransactionARAmountBadDebt
	,TransactionServiceDate
	,TransactionServiceDateAge
	,TransactionPostDate
	,TransactionPostDateAge
	,TransactionInsuranceAgeDate
	,TransactionInsuranceAge
	,TransactionFirstClaimDate
	,TransactionLastClaimDate
	,TransactionSelfPayAgeDate
	,TransactionSelfPayAge
	,ARHistoryUpdatedDatetime

	FROM rpt.ARCurrentPB ac
	WHERE 1=1
		AND ac.TransactionDataSourceID = 1

		

IF (SELECT COUNT(1) FROM @StagingTable) >= 10
	BEGIN 
	PRINT 'At least 10 records exist in the staging table.  Proceed with delete and reload...'


/*-----INSERT new records-----*/
	PRINT 'Inserting new records in Datasource from @StagingTable....'
	INSERT INTO rpt.ARHistoryPB
	(ARHistoryID
	,ARHistoryDate
	,TransactionDataSourceID
	,TransactionSourceID
	,TransactionType
	,TransactionLocationID
	,TransactionDepartmentID
	,TransactionPlaceOfServiceID
	,TransactionPlaceOfServiceType
	,TransactionGuarantorID
	,TransactionGuarantorType
	,TransactionAccountID
	,TransactionAccountClass
	,TransactionVisitID
	,TransactionVisitType
	,CurrentFinancialClass
	,CurrentPayerID
	,CurrentPayerPlanID
	,OriginalFinancialClass
	,OriginalPayerID
	,OriginalPayerPlanID
	,TransactionServiceProviderID
	,TransactionBillingProviderID
	,TransactionCode
	,TransactionDescription
	,TransactionCPTCode
	,TransactionModifier1
	,TransactionModifier2
	,TransactionModifier3
	,TransactionModifier4
	,TransactionUnits
	,TransactionLedgerType
	,TransactionOriginalAmount
	,TransactionARAmountAll
	,TransactionARAmountSelfPay
	,TransactionARAmountInsurance
	,TransactionARAmountActive
	,TransactionARAmountBadDebt
	,TransactionServiceDate
	,TransactionServiceDateAge
	,TransactionPostDate
	,TransactionPostDateAge
	,TransactionInsuranceAgeDate
	,TransactionInsuranceAge
	,TransactionFirstClaimDate
	,TransactionLastClaimDate
	,TransactionSelfPayAgeDate
	,TransactionSelfPayAge
	,ARHistoryUpdatedDatetime
	)

	SELECT
	source.ARHistoryID
	,source.ARHistoryDate
	,source.TransactionDataSourceID
	,source.TransactionSourceID
	,source.TransactionType
	,source.TransactionLocationID
	,source.TransactionDepartmentID
	,source.TransactionPlaceOfServiceID
	,source.TransactionPlaceOfServiceType
	,source.TransactionGuarantorID
	,source.TransactionGuarantorType
	,source.TransactionAccountID
	,source.TransactionAccountClass
	,source.TransactionVisitID
	,source.TransactionVisitType
	,source.CurrentFinancialClass
	,source.CurrentPayerID
	,source.CurrentPayerPlanID
	,source.OriginalFinancialClass
	,source.OriginalPayerID
	,source.OriginalPayerPlanID
	,source.TransactionServiceProviderID
	,source.TransactionBillingProviderID
	,source.TransactionCode
	,source.TransactionDescription
	,source.TransactionCPTCode
	,source.TransactionModifier1
	,source.TransactionModifier2
	,source.TransactionModifier3
	,source.TransactionModifier4
	,source.TransactionUnits
	,source.TransactionLedgerType
	,source.TransactionOriginalAmount
	,source.TransactionARAmountAll
	,source.TransactionARAmountSelfPay
	,source.TransactionARAmountInsurance
	,source.TransactionARAmountActive
	,source.TransactionARAmountBadDebt
	,source.TransactionServiceDate
	,source.TransactionServiceDateAge
	,source.TransactionPostDate
	,source.TransactionPostDateAge
	,source.TransactionInsuranceAgeDate
	,source.TransactionInsuranceAge
	,source.TransactionFirstClaimDate
	,source.TransactionLastClaimDate
	,source.TransactionSelfPayAgeDate
	,source.TransactionSelfPayAge
	,source.ARHistoryUpdatedDatetime
	
	FROM @StagingTable source
	--	LEFT JOIN rpt.ARCurrentPB target ON target.ARHistoryID = source.ARHistoryID
	WHERE 1=1
	--	AND target.ARHistoryID IS NULL 

	/*-----DELETE/DEACTIVATE old records----*/
	PRINT 'Deleting records in Datasource....'
	--DELETE FROM rpt.ARCurrentPB WHERE TransactionDataSourceID = 1

	END

ELSE
	BEGIN
	PRINT 'Less than 10 records in the staging table. Ending job without delete and reload...'
	END

END
ELSE
	PRINT 'Not first day of month, terminating job...'

END
GO
