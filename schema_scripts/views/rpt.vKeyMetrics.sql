CREATE   VIEW [rpt].[vKeyMetrics] AS
WITH BaseData AS (
    SELECT 
        bb.FiscalYear,
        bb.FiscalPeriod,
        bb.FiscalYearPeriod,
        bb.PracticeID,
        p.PracticeName,
        bb.ReportingProviderID,
        bb.ReportSection,
        bb.ReportGroupLevel1,
        SUM(bb.FiscalPeriodValue) AS Value
    FROM rpt.vBlueBooks bb
    LEFT JOIN dim.Practices p ON p.PracticeID = bb.PracticeID
    WHERE 1=1 -- p.PracticeCompany = 'TPG' 
      AND bb.ReportSection IN ('Non-Assist Visits', 'Payments', 'Expenses', 'Revenue')
    GROUP BY 
        bb.FiscalYear,
        bb.FiscalPeriod,
        bb.FiscalYearPeriod,
        bb.PracticeID,
        p.PracticeName,
        bb.ReportingProviderID,
        bb.ReportSection,
        bb.ReportGroupLevel1

),
CategoryMetrics AS (
    SELECT
        FiscalYear,
        FiscalPeriod,
        FiscalYearPeriod,
        PracticeID,
        PracticeName,
        ReportingProviderID,
        
        -- Base Totals
        ISNULL(SUM(CASE WHEN ReportSection = 'Non-Assist Visits' AND ReportGroupLevel1 = 'Surgical Visits' THEN Value END), 0) AS SurgicalEncounters,
        ISNULL(SUM(CASE WHEN ReportSection = 'Non-Assist Visits' AND ReportGroupLevel1 = 'Office Visits'   THEN Value END), 0) AS OfficeEncounters,
        ISNULL(SUM(CASE WHEN ReportSection = 'Non-Assist Visits' AND ReportGroupLevel1 = 'Hospital Visits' THEN Value END), 0) AS HospitalVisits,
        
        ISNULL(SUM(CASE WHEN ReportSection = 'Payments' AND ReportGroupLevel1 = 'Surgical Visits' THEN Value END), 0) AS SurgicalRevenue,
        ISNULL(SUM(CASE WHEN ReportSection = 'Revenue' AND ReportGroupLevel1 in ('01_Total Professional Services','04_Total Professional Services')  THEN Value END), 0) - (ISNULL(SUM(CASE WHEN ReportSection = 'Payments' AND ReportGroupLevel1 = 'Surgical Visits' THEN Value END), 0) + ISNULL(SUM(CASE WHEN ReportSection = 'Payments' AND ReportGroupLevel1 = 'Hospital Visits' THEN Value END), 0))   AS OfficeRevenue, --ISNULL(SUM(CASE WHEN ReportSection = 'Payments' AND ReportGroupLevel1 = 'Office Visits'   THEN Value END), 0)
        ISNULL(SUM(CASE WHEN ReportSection = 'Payments' AND ReportGroupLevel1 = 'Hospital Visits' THEN Value END), 0) AS HospitalRevenue,
        
        ISNULL(SUM(CASE WHEN ReportSection = 'Revenue' THEN Value END), 0) AS TotalRevenue, --ISNULL(SUM(CASE WHEN ReportSection = 'Payments' THEN Value END), 0),
        ISNULL(SUM(CASE WHEN ReportSection = 'Expenses' THEN Value END), 0) AS TotalExpense
    FROM BaseData
    GROUP BY 
        FiscalYear,
        FiscalPeriod,
        FiscalYearPeriod,
        PracticeID,
        PracticeName,
        ReportingProviderID
),
CalculatedRatios AS (
    SELECT 
        *,
        (SurgicalEncounters + OfficeEncounters + HospitalVisits) AS TotalEncounters
    FROM CategoryMetrics
),
StackedResults AS (
    -- Volumes (ValueType = 'Sum')
    SELECT FiscalYear, FiscalPeriod, FiscalYearPeriod, PracticeID, PracticeName, ReportingProviderID, 'Surgical Encounters' AS MetricName, SurgicalEncounters AS Numerator, 1.0 AS Denominator, 'Sum' AS ValueType, 1 AS SortOrder FROM CalculatedRatios
    UNION ALL
    SELECT FiscalYear, FiscalPeriod, FiscalYearPeriod, PracticeID, PracticeName, ReportingProviderID, 'Office Encounters' AS MetricName, OfficeEncounters AS Numerator, 1.0 AS Denominator, 'Sum' AS ValueType, 2 AS SortOrder FROM CalculatedRatios
    UNION ALL
    SELECT FiscalYear, FiscalPeriod, FiscalYearPeriod, PracticeID, PracticeName, ReportingProviderID, 'Hospital Visits' AS MetricName, HospitalVisits AS Numerator, 1.0 AS Denominator, 'Sum' AS ValueType, 3 AS SortOrder FROM CalculatedRatios

    -- Revenue (ValueType = 'Sum')
    UNION ALL
    SELECT FiscalYear, FiscalPeriod, FiscalYearPeriod, PracticeID, PracticeName, ReportingProviderID, 'Revenue from Surgical Encounters' AS MetricName, SurgicalRevenue AS Numerator, 1.0 AS Denominator, 'Sum' AS ValueType, 4 AS SortOrder FROM CalculatedRatios
    UNION ALL
    SELECT FiscalYear, FiscalPeriod, FiscalYearPeriod, PracticeID, PracticeName, ReportingProviderID, 'Revenue from Office Encounters' AS MetricName, OfficeRevenue AS Numerator, 1.0 AS Denominator, 'Sum' AS ValueType, 5 AS SortOrder FROM CalculatedRatios
    UNION ALL
    SELECT FiscalYear, FiscalPeriod, FiscalYearPeriod, PracticeID, PracticeName, ReportingProviderID, 'Revenue from Hospital Encounters' AS MetricName, HospitalRevenue AS Numerator, 1.0 AS Denominator, 'Sum' AS ValueType, 6 AS SortOrder FROM CalculatedRatios

    -- Fractions (ValueType = 'Fraction')
    UNION ALL
    SELECT FiscalYear, FiscalPeriod, FiscalYearPeriod, PracticeID, PracticeName, ReportingProviderID, 'Revenue per Surgical Encounter' AS MetricName, SurgicalRevenue AS Numerator, SurgicalEncounters AS Denominator, 'Fraction' AS ValueType, 7 AS SortOrder FROM CalculatedRatios
    UNION ALL
    SELECT FiscalYear, FiscalPeriod, FiscalYearPeriod, PracticeID, PracticeName, ReportingProviderID, 'Revenue per Office Encounter' AS MetricName, OfficeRevenue AS Numerator, OfficeEncounters AS Denominator, 'Fraction' AS ValueType, 8 AS SortOrder FROM CalculatedRatios
    UNION ALL
    SELECT FiscalYear, FiscalPeriod, FiscalYearPeriod, PracticeID, PracticeName, ReportingProviderID, 'Revenue per Hospital Visit' AS MetricName, HospitalRevenue AS Numerator, HospitalVisits AS Denominator, 'Fraction' AS ValueType, 9 AS SortOrder FROM CalculatedRatios
    UNION ALL
    SELECT FiscalYear, FiscalPeriod, FiscalYearPeriod, PracticeID, PracticeName, ReportingProviderID, 'Total Revenue per Encounter' AS MetricName, TotalRevenue AS Numerator, TotalEncounters AS Denominator, 'Fraction' AS ValueType, 10 AS SortOrder FROM CalculatedRatios
    UNION ALL
    SELECT FiscalYear, FiscalPeriod, FiscalYearPeriod, PracticeID, PracticeName, ReportingProviderID, 'Total Expense per Encounter' AS MetricName, TotalExpense AS Numerator, TotalEncounters AS Denominator, 'Fraction' AS ValueType, 11 AS SortOrder FROM CalculatedRatios
    UNION ALL
    SELECT FiscalYear, FiscalPeriod, FiscalYearPeriod, PracticeID, PracticeName, ReportingProviderID, 'Net income per Encounter' AS MetricName, (TotalRevenue - TotalExpense) AS Numerator, TotalEncounters AS Denominator, 'Fraction' AS ValueType, 12 AS SortOrder FROM CalculatedRatios

)
SELECT 
    DATEFROMPARTS(FiscalYear, FiscalPeriod, 1) AS MetricDate,
    FiscalYear,
    FiscalPeriod,
    FiscalYearPeriod, 
    PracticeID,
    PracticeName, 
    ReportingProviderID,
    'Actual' AS ReportSectionType,
    MetricName,
    Numerator,
    Denominator,
    ValueType, -- Renamed back as requested
    CASE 
        WHEN ValueType IN ('Fraction', 'Percent') THEN CASE WHEN Denominator = 0 THEN 0 ELSE Numerator / Denominator END
        ELSE Numerator 
    END AS MetricValue,
    SortOrder
FROM StackedResults
GO
