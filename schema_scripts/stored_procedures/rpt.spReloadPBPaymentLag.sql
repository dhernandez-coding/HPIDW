-- =============================================
-- Author:		<Cross, Chris>
-- ALTER PROCEDURE11/2024>
-- Description:	<Reload of PaymentLag table (Payment lag for Practice)>
-- =============================================
CREATE   PROCEDURE [rpt].[spReloadPBPaymentLag] 
AS
BEGIN
    IF OBJECT_ID('tempdb..#TEMP_DaysToPay') IS NOT NULL 
        DROP TABLE #TEMP_DaysToPay;

    SELECT
        sub.PracticeID,
        sub.PracticeName,
        AVG(sub.FirstPaymentLagPost) AS PaymentLagPost,
        AVG(sub.FirstPaymentLagDOS) AS PaymentLagDOS
    INTO #TEMP_DaysToPay
    FROM (
        SELECT
            pt.PracticeID,
            pt.PracticeName,
            c.TransactionID AS ChargeTransactionID,
            c.TransactionDateOfService AS ChargeServiceDate,
            c.TransactionDateOfPosting AS ChargePostDate,
            c.TransactionCPTCode AS ChargeCPT,
            c.TransactionAmount AS ChargeAmount,
            c.TransactionPayerID AS ChargePayerID,
            c.TransactionPayerPlanID AS ChargePlanID,
            MIN(p.TransactionDateOfPosting) AS FirstPaymentDate,
            DATEDIFF(DAY, c.TransactionDateOfPosting, MIN(p.TransactionDateOfPosting)) AS FirstPaymentLagPost,
            DATEDIFF(DAY, c.TransactionDateOfService, MIN(p.TransactionDateOfPosting)) AS FirstPaymentLagDOS
        FROM fact.TransactionsPB p
        INNER JOIN fact.TransactionsPB c ON c.TransactionType = 'Charge'
            AND p.TransactionType <> 'Charge'
            AND CONCAT(p.TransactionDatasourceID, '~', p.TransactionParentSourceID) = c.TransactionID
        LEFT JOIN map.ProviderLinking pl ON pl.ChildProviderID = c.TransactionBillingProviderID
        LEFT JOIN map.PracticeDepartments pd ON pd.DepartmentID = c.TransactionDepartmentID
        LEFT JOIN map.vPracticeProviders pp ON pp.ParentProviderID = pl.ParentProviderID
            AND pp.PracticeProviderEffectiveDate <= c.TransactionDateOfPosting
            AND pp.PracticeProviderEndDate >= c.TransactionDateOfPosting
            AND ((c.TransactionBillingProviderID IN ('1~19898', '5~126867', '1~19711', '5~125582', '5~122305', '5~104092', '5~120997', '1~14003', '1~18356', '1~13986')
                  AND (pp.PracticeID = pd.PracticeID OR (pd.PracticeID IS NULL AND c.TransactionBillingProviderID = pp.ProviderID)))
                 OR c.TransactionBillingProviderID NOT IN ('1~19898', '5~126867', '1~19711', '5~125582', '5~122305', '5~104092', '5~120997', '1~14003', '1~18356', '1~13986'))
        LEFT JOIN dim.vPractices pt ON pt.PracticeID = COALESCE(pd.PracticeID, pp.PracticeID)
        LEFT JOIN dim.Payers py ON py.PayerID = p.TransactionPayerID
        LEFT JOIN dim.PayerGroups pyg ON pyg.PayerGroupID = py.PayerGroupID
        WHERE p.TransactionType = 'Payment'
            AND c.TransactionDateOfPosting >= '2023-01-01'
            AND p.TransactionDateOfPosting >= DATEADD(DAY, 2, c.TransactionDateOfService)
            AND pt.PracticeCompany = 'TPG'
            AND pt.PracticeIsActive = 1
        GROUP BY
            pt.PracticeID,
            pt.PracticeName,
            c.TransactionID,
            c.TransactionDateOfService,
            c.TransactionDateOfPosting,
            c.TransactionCPTCode,
            c.TransactionAmount,
            c.TransactionPayerID,
            c.TransactionPayerPlanID
    ) sub
    GROUP BY
        sub.PracticeID,
        sub.PracticeName;

	DELETE FROM rpt.PBPaymentLag
    INSERT INTO rpt.PBPaymentLag (PracticeID, PracticeName, PaymentLagPost, PaymentLagDOS)
    SELECT PracticeID, PracticeName, PaymentLagPost, PaymentLagDOS
    FROM #TEMP_DaysToPay;

    DROP TABLE #TEMP_DaysToPay;
END
GO
