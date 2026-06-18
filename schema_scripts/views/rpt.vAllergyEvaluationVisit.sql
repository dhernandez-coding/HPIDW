CREATE VIEW [rpt].[vAllergyEvaluationVisit] AS
WITH PaymentAggregation AS (
    SELECT 
        t2.TransactionDatasourceID, 
        t2.TransactionParentSourceID, 
        t2.TransactionDateOfPosting AS PaymentPosting, 
		t2.TransactionReportPeriodDate,
        SUM(CASE WHEN t2.TransactionType = 'Adjustment' THEN t2.TransactionAmount ELSE 0 END) AS Adjustments, 
        SUM(CASE WHEN t2.TransactionType = 'Payment' AND pg.PayerGroupName <> 'Self-Pay' THEN t2.TransactionAmount ELSE 0 END) AS InsurancePayments, 
        SUM(CASE WHEN t2.TransactionType = 'Payment' AND pg.PayerGroupName = 'Self-Pay' THEN t2.TransactionAmount ELSE 0 END) AS PatientPayments, 
        SUM(CASE WHEN t2.TransactionType = 'Payment' THEN t2.TransactionAmount ELSE 0 END) AS TotalPayments
    FROM fact.vTransactionsPB t2  
    LEFT JOIN dim.Payers p ON p.PayerID = t2.TransactionPayerID  
    LEFT JOIN dim.PayerGroups pg ON pg.PayerGroupID = p.PayerGroupID  
    WHERE t2.TransactionBillingType = 'PB'  
        AND t2.TransactionType <> 'Charge'  
        AND t2.TransactionDatasourceID IN (1,5) 
    GROUP BY t2.TransactionDatasourceID, t2.TransactionParentSourceID, t2.TransactionDateOfPosting, t2.TransactionReportPeriodDate
)
SELECT 
    pr.ProviderFullName AS AllergyProviderName, 
    t2.ProcedureCategory AS AllergyProcedureCategory, 
    pp.PatientMRN AS AllergyPatientMRN, 
    pp.PatientFullName AS AllergyPatientName, 
    t2.TransactionVisitID AS AllergyVisitID, 
    p.PayerName AS AllergyPayer, 
    t2.TransactionCode AS AllergyCPTCode, 
    pa.PaymentPosting AS AllergyPaymentPostingDate, 
    t2.TransactionDateOfPosting AS AllergyDateOfPosting, 
    t2.TransactionDateOfService AS AllergyDateOfService, 
	pa.TransactionReportPeriodDate AS AllergyReportPeriod,
    ISNULL(pa.TotalPayments, 0) AS AllergyPayments
FROM fact.vTransactionsPB t2  
LEFT JOIN dim.Payers p ON p.PayerID = t2.TransactionPayerID  
LEFT JOIN dim.PayerCategories pc ON pc.PayerCategoryID = p.PayerCategoryID  
LEFT JOIN dim.PayerGroups pg ON pg.PayerGroupID = p.PayerGroupID  
LEFT JOIN dim.vProviders pr ON pr.ProviderID = t2.TransactionBillingProviderID  
LEFT JOIN dim.Patients pp ON pp.PatientID = t2.PatientID  
LEFT JOIN dim.vPBProcedureCodeCategories c ON c.ProcedureCode = t2.TransactionCode  
LEFT JOIN [HERO-DB].hpi.dbo.PBProcedureCategoriess cat ON cat.ProcedureCategory = 
    CASE 
        WHEN c.ProcedureCodeIsLocationDependent = 1 AND t2.TransactionPlaceOfServiceCode IN ('21','22') THEN 'Outpatient Procedures'  
        WHEN c.ProcedureCodeIsLocationDependent = 1 AND t2.TransactionPlaceOfServiceCode NOT IN ('21','22') THEN 'In Office Procedures' 
        ELSE c.ProcedureCodeCategory 
    END
LEFT JOIN PaymentAggregation pa ON pa.TransactionDatasourceID = t2.TransactionDatasourceID 
    AND pa.TransactionParentSourceID = t2.TransactionSourceID  
WHERE t2.TransactionBillingType = 'PB'  
    AND t2.TransactionType = 'Charge' 
	AND pa.PaymentPosting >= '2024-01-01'
    AND t2.ProcedureCategory = 'Allergy Evaluation Visit';
GO
