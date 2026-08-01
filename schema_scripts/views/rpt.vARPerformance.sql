CREATE VIEW [rpt].[vARPerformance]
AS

WITH BlueBooksBase AS
(
    SELECT
          bb.BlueBooksID
        , bb.FiscalYear
        , bb.FiscalPeriod
        , bb.FiscalYearPeriod
        , DATEFROMPARTS(bb.FiscalYear, CASE WHEN bb.FiscalPeriod = 0 THEN 1 ELSE bb.FiscalPeriod END,1) AS FiscalPeriodDate
        , bb.ReportSection
        , bb.ReportGroupLevel1
        , CASE WHEN bb.ReportSection IN ('Revenue', 'Expenses')
              THEN RIGHT(bb.ReportGroupLevel1,LEN(bb.ReportGroupLevel1) - 3) ELSE bb.ReportGroupLevel1 END AS ReportGroupLevel1Clean
        , bb.ReportGroupLevel2
        , CASE WHEN bb.ReportSection IN ('Revenue', 'Expenses')
                  THEN RIGHT(bb.ReportGroupLevel2,LEN(bb.ReportGroupLevel2) - 3) ELSE bb.ReportGroupLevel2 END AS ReportGroupLevel2Clean
        , bb.ReportGroupLevel3
        , CASE WHEN bb.ReportSection IN ('Revenue', 'Expenses') THEN RIGHT(bb.ReportGroupLevel3,LEN(bb.ReportGroupLevel3) - 3)
                WHEN bb.ReportGroupLevel3 IN
                                            (
                                                '1_Charge'
                                              , '2_Contractual Adjustment'
                                              , '3_Admin Write Off'
                                              , '4_Payer Determination Adjustment'
                                              , '5_Payer Receipts'
                                              , '6_Patient Receipts'
                                              , '7_Refund'
                                              , '8_Bad Debt'
                                              , '99_No Category'
                                            )
                  THEN RIGHT(bb.ReportGroupLevel3,LEN(bb.ReportGroupLevel3) - 2) ELSE bb.ReportGroupLevel3 END AS ReportGroupLevel3Clean

        , bb.ReportGroupLevel4
        , bb.PracticeID
        , bb.ReportingProviderID
        , bb.FiscalPeriodValue
        , bb.FiscalPeriodNumerator
        , bb.FiscalPeriodDenominator
        , CASE WHEN bb.ReportSection LIKE '%Charge Lag%' OR bb.ReportSection LIKE '%Payment Lag%' THEN 'Fraction' ELSE 'Sum' END AS FiscalPeriodValueType
        , 'Actual' AS ReportSectionType
        , bb.UpdatedDatetime

    FROM [HPIDW].[rpt].[BlueBooks] bb

    WHERE bb.ReportSection IN ('Charges', 'Payments', 'Adjustments')
      -- Exclude adjustments mapped as '1_Charge' completely so they don't show up in any category
      AND NOT (bb.ReportSection = 'Adjustments' AND bb.ReportGroupLevel3 = '1_Charge')
),

MonthlyAR AS
(
    SELECT
          FiscalYear
        , FiscalPeriod
        , FiscalYearPeriod
        , FiscalPeriodDate
        , PracticeID

        , SUM
          (
              CASE
                  -- Limit Charges to only pull from Charges section (excludes adjustments)
                  WHEN ReportSection = 'Charges'
                   AND ReportGroupLevel3Clean = 'Charge'
                      THEN COALESCE(FiscalPeriodValue, 0)
                  ELSE 0
              END
          ) AS Charges

        , SUM
          (
              CASE
                  -- Standard adjustments (mapped adjustment charges excluded via WHERE clause)
                  WHEN ReportSection = 'Adjustments'
                   AND ReportGroupLevel3Clean IN
                       (
                           'Contractual Adjustment',
                           'Admin Write Off',
                           'Payer Determination Adjustment'
                       )
                      THEN COALESCE(FiscalPeriodValue, 0)
                  ELSE 0
              END
          ) AS Adjustments

        , SUM
          (
              CASE
                  -- Treat Bad Debt as its own separate category
                  WHEN ReportSection = 'Adjustments'
                   AND ReportGroupLevel3Clean = 'Bad Debt'
                      THEN COALESCE(FiscalPeriodValue, 0)
                  ELSE 0
              END
          ) AS BadDebt

        , SUM
          (
              CASE
                  WHEN ReportSection = 'Payments'
                   AND ReportGroupLevel3Clean IN
                       (
                           'Payer Receipts',
                           'Patient Receipts',
                           'Refund'
                       )
                      THEN COALESCE(FiscalPeriodValue, 0)
                  ELSE 0
              END
          ) AS NetPayments

        , SUM
          (
              CASE
                  WHEN ReportSection = 'Payments'
                   AND ReportGroupLevel3Clean IN
                       (
                           'Payer Receipts',
                           'Patient Receipts'
                       )
                      THEN COALESCE(FiscalPeriodValue, 0)
                  ELSE 0
              END
          ) AS GrossPayments
        , ReportingProviderID
        , MAX(UpdatedDatetime) AS UpdatedDatetime

    FROM BlueBooksBase

    GROUP BY
          FiscalYear
        , FiscalPeriod
        , FiscalYearPeriod
        , FiscalPeriodDate
        , PracticeID
        , ReportingProviderID
),

MonthlyCalculations AS
(
    SELECT
          FiscalYear
        , FiscalPeriod
        , FiscalYearPeriod
        , FiscalPeriodDate
        , PracticeID
        , ReportingProviderID
        , Charges
        , Adjustments
        , BadDebt
        , NetPayments
        , GrossPayments
        , Charges - Adjustments - NetPayments - BadDebt AS ResidualAR
        , GrossPayments / NULLIF(Charges, 0.0) AS GrossCollectionRate
        , NetPayments / NULLIF(Charges - Adjustments, 0.0) AS NetCollectionRate
        , 1.0 - ((Charges - Adjustments - NetPayments - BadDebt) / NULLIF(Charges, 0.0)) AS ARResolution
        , UpdatedDatetime

    FROM MonthlyAR
),

CalculatedRows AS
(
    SELECT
          CAST(NULL AS BIGINT) AS BlueBooksID
        , FiscalYear
        , FiscalPeriod
        , FiscalYearPeriod
        , FiscalPeriodDate
        , 'AR Performance' AS ReportSection
        , 'AR Performance' AS ReportGroupLevel1
        , 'AR Performance' AS ReportGroupLevel1Clean
        , 'AR Performance' AS ReportGroupLevel2
        , 'AR Performance' AS ReportGroupLevel2Clean
        , '9_Net Receipts' AS ReportGroupLevel3
        , 'Net Receipts' AS ReportGroupLevel3Clean
        , CAST(NULL AS VARCHAR(255)) AS ReportGroupLevel4
        , PracticeID
        , CAST(ReportingProviderID AS VARCHAR(250)) AS ReportingProviderID
        , CAST(NetPayments AS DECIMAL(19, 4)) AS FiscalPeriodValue
        , CAST(NULL AS DECIMAL(19, 4)) AS FiscalPeriodNumerator
        , CAST(NULL AS DECIMAL(19, 4)) AS FiscalPeriodDenominator
        , 'Sum' AS FiscalPeriodValueType
        , 'Actual' AS ReportSectionType
        , UpdatedDatetime

    FROM MonthlyCalculations

    UNION ALL

    SELECT
          NULL
        , FiscalYear
        , FiscalPeriod
        , FiscalYearPeriod
        , FiscalPeriodDate
        , 'AR Performance'
        , 'AR Performance'
        , 'AR Performance'
        , 'AR Performance'
        , 'AR Performance'
        , '10_Gross Collection Rate'
        , 'Gross Collection Rate'
        , NULL
        , PracticeID
        , ReportingProviderID
        , CAST(GrossCollectionRate AS DECIMAL(19, 6))
        , CAST(GrossPayments AS DECIMAL(19, 4)) AS FiscalPeriodNumerator
        , CAST(Charges AS DECIMAL(19, 4)) AS FiscalPeriodDenominator
        , 'Percent'
        , 'Actual'
        , UpdatedDatetime

    FROM MonthlyCalculations

    UNION ALL

    SELECT
          NULL
        , FiscalYear
        , FiscalPeriod
        , FiscalYearPeriod
        , FiscalPeriodDate
        , 'AR Performance'
        , 'AR Performance'
        , 'AR Performance'
        , 'AR Performance'
        , 'AR Performance'
        , '11_Net Collection Rate'
        , 'Net Collection Rate'
        , NULL
        , PracticeID
        , ReportingProviderID
        , CAST(NetCollectionRate AS DECIMAL(19, 6))
        , CAST(NetPayments AS DECIMAL(19, 4)) AS FiscalPeriodNumerator
        , CAST(Charges - Adjustments AS DECIMAL(19, 4)) AS FiscalPeriodDenominator
        , 'Percent'
        , 'Actual'
        , UpdatedDatetime

    FROM MonthlyCalculations

    UNION ALL

    SELECT
          NULL
        , FiscalYear
        , FiscalPeriod
        , FiscalYearPeriod
        , FiscalPeriodDate
        , 'AR Performance'
        , 'AR Performance'
        , 'AR Performance'
        , 'AR Performance'
        , 'AR Performance'
        , '12_Residual AR'
        , 'Residual AR'
        , NULL
        , PracticeID
        , ReportingProviderID
        , CAST(ResidualAR AS DECIMAL(19, 4))
        , CAST(NULL AS DECIMAL(19, 4)) AS FiscalPeriodNumerator
        , CAST(NULL AS DECIMAL(19, 4)) AS FiscalPeriodDenominator
        , 'Sum'
        , 'Actual'
        , UpdatedDatetime

    FROM MonthlyCalculations

    UNION ALL

    SELECT
          NULL
        , FiscalYear
        , FiscalPeriod
        , FiscalYearPeriod
        , FiscalPeriodDate
        , 'AR Performance'
        , 'AR Performance'
        , 'AR Performance'
        , 'AR Performance'
        , 'AR Performance'
        , '13_AR Resolution'
        , 'AR Resolution'
        , NULL
        , PracticeID
        , ReportingProviderID
        , CAST(ARResolution AS DECIMAL(19, 6))
        , CAST(Adjustments + NetPayments + BadDebt AS DECIMAL(19, 4)) AS FiscalPeriodNumerator
        , CAST(Charges AS DECIMAL(19, 4)) AS FiscalPeriodDenominator
        , 'Percent'
        , 'Actual'
        , UpdatedDatetime

    FROM MonthlyCalculations
)

SELECT
      BlueBooksID
    , FiscalYear
    , FiscalPeriod
    , FiscalYearPeriod
    , FiscalPeriodDate
    , ReportSection
    , ReportGroupLevel1
    , ReportGroupLevel1Clean
    , ReportGroupLevel2
    , ReportGroupLevel2Clean
    , ReportGroupLevel3
    , ReportGroupLevel3Clean
    , ReportGroupLevel4
    , PracticeID
    , ReportingProviderID
    , FiscalPeriodValue
    , FiscalPeriodNumerator
    , FiscalPeriodDenominator
    , FiscalPeriodValueType
    , ReportSectionType
    , UpdatedDatetime

FROM BlueBooksBase

UNION ALL

SELECT
      BlueBooksID
    , FiscalYear
    , FiscalPeriod
    , FiscalYearPeriod
    , FiscalPeriodDate
    , ReportSection
    , ReportGroupLevel1
    , ReportGroupLevel1Clean
    , ReportGroupLevel2
    , ReportGroupLevel2Clean
    , ReportGroupLevel3
    , ReportGroupLevel3Clean
    , ReportGroupLevel4
    , PracticeID
    , ReportingProviderID
    , FiscalPeriodValue
    , FiscalPeriodNumerator
    , FiscalPeriodDenominator
    , FiscalPeriodValueType
    , ReportSectionType
    , UpdatedDatetime

FROM CalculatedRows;
GO
