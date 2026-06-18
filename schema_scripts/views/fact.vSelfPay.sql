CREATE view [fact].[vSelfPay] as

WITH Ranked AS (
    SELECT
         s.SelfPayTransactionID
        ,s.SelfPayDataSourceID
        ,s.SelfPayTransactionSourceID
        ,t.TransactionPracticeID   AS SelfPayPracticeID
        ,t.TransactionDepartmentID AS SelfPayDepartmentID
        ,t.TransactionBillingProviderID AS SelfPayProviderID
        ,s.SelfPayVisitID
        ,s.SelfPayPatientID
        ,s.SelfPayType
        ,s.SelfPayDateOfService
        ,s.SelfPayPostDate
        ,s.SelfPayPostDateAge
        ,s.SelfPayPostDateAgeBucket
        ,s.SelfPayAgeDate
        ,s.SelfPayAge
        ,s.SelfPayAgeBucket
        ,s.SelfPayFinancialClass
        ,s.SelfPayBalance
		,s.SelfPayPatientResponsibility
		,s.SelfPayOutstandingBalance
        ,s.SelfPayUpdateDate
        ,ROW_NUMBER() OVER (
              PARTITION BY s.SelfPayVisitID
              ORDER BY s.SelfPayAge DESC, s.SelfPayAgeDate DESC
          ) AS rn
    FROM HPIDW.fact.SelfPay s
    LEFT JOIN fact.vTransactionsPB t ON t.TransactionID = s.SelfPayTransactionID
	--where s.SelfPayVisitID = '5~30141802885'
)
SELECT *
FROM Ranked
WHERE rn = 1;
GO
