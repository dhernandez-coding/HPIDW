CREATE   VIEW  [rpt].[vUSPI_FACT_zerobalancereport] AS
/*
====================================================
 Author:      Diego Hernandez
 Create date: 10/17/2025
 Description: Zero Balance Report - USPI AdvantX
 Source: fact.vAccounts
 Filter: AccountBillingStatus = 'Zero Balance'
====================================================
*/

SELECT
    -- Identifiers
    a.AccountSourceID AS id,                                -- maps to the unique source account identifier
    a.AccountLocationID AS unit,                                  -- maps to facility/unit reference
    d.DepartmentName AS department,                               -- mapped from department dimension
    l.LocationName AS commonname,                                 -- readable facility name

    -- Period fields
    FORMAT(a.AccountDateOfBilling, 'yyyy-MM') AS period,          -- “2025-10”
    FORMAT(a.AccountDateOfBilling, 'yyyyMM') AS periodconverted,  -- “202510”
    YEAR(a.AccountDateOfBilling) AS periodyear,                   -- 2025
    MONTH(a.AccountDateOfBilling) AS periodmonth,                 -- 10

    -- Insurance / classification
    fc.FinancialClassName AS instype,                             -- insurance/financial class

    -- Case and financials
    CAST(a.AccountReferenceNumber AS NUMERIC) AS case_num,
    a.AccountTotalCharges AS charge,
    a.AccountTotalPayments AS paid,
    a.AccountTotalAdjustments AS writeoff,

    -- Metadata
    a.AccountDataSource AS source_system_id,
    GETDATE() AS load_ts
 FROM fact.vAccounts a
LEFT JOIN dim.vLocations l
    ON l.LocationID = a.AccountLocationID
LEFT JOIN dim.vDepartments d
    ON d.DepartmentID = a.AccountDepartmentID
LEFT JOIN dim.FinancialClasses fc
    ON fc.FinancialClassID = a.AccountFinancialClassID

WHERE 1=1
    and a.AccountDataSourceID = 5
	and a.AccountTotalCharges + a.AccountTotalPayments + a.AccountTotalAdjustments = 0
GO
