-- =============================================
-- Author:		Eric Silvestri
-- Create date: 12/07/2024
-- Description:	Stored proceedure for paginated month end HB report
-- =============================================
CREATE PROCEDURE [rpt].[spSelectHBFacilityCharges]

AS
BEGIN

	SET NOCOUNT ON;

SELECT 
    l.LocationName,
    CASE WHEN p.PayerCategoryName IS NULL THEN 'Self-Pay' ELSE p.PayerCategoryName END AS PayerCategoryName,
    CONCAT(YEAR(t.TransactionDateOfBilling), ' - ', RIGHT(CONCAT('00', MONTH(t.TransactionDateOfBilling)), 2)) AS TransactionReportingPeriodID,
    SUM(t.TransactionAmount) AS Charges
FROM HPIDW.fact.Transactions2 t
    LEFT JOIN HPIDW.fact.vAccounts a ON a.AccountID = t.TransactionAccountID
    LEFT JOIN HPIDW.dim.vLocations l ON l.LocationID = a.AccountLocationID
    LEFT JOIN HPIDW.dim.vPayers p ON p.PayerID = t.TransactionPayerID
WHERE t.TransactionType = 'Charge' 
    AND t.TransactionBillingType = 'HB' 
    AND t.TransactionDateOfBilling >= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 1, 0)
    AND t.TransactionDateOfBilling < DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)
GROUP BY
    l.LocationName,
    CASE WHEN p.PayerCategoryName IS NULL THEN 'Self-Pay' ELSE p.PayerCategoryName END,
    CONCAT(YEAR(t.TransactionDateOfBilling), ' - ', RIGHT(CONCAT('00', MONTH(t.TransactionDateOfBilling)), 2));

END
GO
