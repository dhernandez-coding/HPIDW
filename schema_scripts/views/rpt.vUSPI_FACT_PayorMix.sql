CREATE   VIEW rpt.vUSPI_PayorMix As 


SELECT
    -- Identifiers / dimensions
    l.LocationName AS facility_id,
    NULL AS unit_type,
    p.ProviderNPI AS npi,
    p.ProviderFullName AS physician_name,
    p.ParentSpecialtyName AS specialty,
    py.PayerCategoryName AS payor_class,
    NULL AS standard_payor_class,

    -- Fiscal period
    CONCAT(YEAR(a.AccountDateOfBilling), '-', FORMAT(a.AccountDateOfBilling, 'MMM')) AS period_name,
    YEAR(a.AccountDateOfBilling) AS fiscal_year,
    DATEPART(QUARTER, a.AccountDateOfBilling) AS fiscal_quarter,
    MONTH(a.AccountDateOfBilling) AS fiscal_month,

    -- Metrics
    COUNT(DISTINCT a.AccountID) AS case_count,
    SUM(a.AccountTotalCharges - a.AccountTotalAdjustments) AS expected_collections,

    -- ✅ Should now return non-zero Bad Debt totals
    SUM(CASE 
            WHEN a.AccountBillingStatus = 'Bad Debt' 
                 AND a.AccountTotalBalance IS NOT NULL 
            THEN a.AccountTotalBalance 
            ELSE 0 
        END) AS case_bad_debt_amount,

    'EPIC' AS source_system_id,
    GETDATE() AS load_ts

 FROM fact.vAccounts a
LEFT JOIN dim.FinancialClasses fc
    ON a.AccountFinancialClassID = fc.FinancialClassID
LEFT JOIN dim.vLocations l 
    ON l.LocationID = a.AccountLocationID
LEFT JOIN dim.vPayers py 
    ON py.PayerID = a.AccountPrimaryPayerID
LEFT JOIN dim.vProviders p 
    ON p.ParentProviderID = a.AccountPrimaryProviderID

WHERE 
    a.AccountFinancialClassID IS NOT NULL
    AND a.AccountDataSourceID = 5
	AND AccountDateOfBilling is not null
	AND a.AccountTotalCharges  is not null
GROUP BY
    l.LocationName,
    p.ProviderNPI,
    p.ProviderFullName,
    p.ParentSpecialtyName,
    py.PayerCategoryName,
    YEAR(a.AccountDateOfBilling),
    DATEPART(QUARTER, a.AccountDateOfBilling),
    MONTH(a.AccountDateOfBilling),
    CONCAT(YEAR(a.AccountDateOfBilling), '-', FORMAT(a.AccountDateOfBilling, 'MMM'))
GO
