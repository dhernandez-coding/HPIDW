CREATE PROCEDURE [rpt].[spLoadMetricORCancellationsDefinitions]	AS





-- ── MetricID 29: CANCELLATIONS DETAIL ──
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (29, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'% Cases (Cancelled)', N'KPI', N'Percentage of all cases that were cancelled', N'CALCULATE(# All Cases, ScheduleStatus=Canceled) / # All Cases', N'Cancelled cases', N'All cases', N'10% target set by organization; includes both DOS and advance cancellations',
     NULL, NULL, 0.10, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (29, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'% DOS Cancellations', N'KPI', N'Percentage of all cases cancelled on the day of surgery', N'# DOS Cancellations / # All Cases', N'Cases where SameDayCancellation=Y', N'All cases', N'DOS = VisitCaseCancelledDate equals VisitCaseServiceDate',
     NULL, NULL, 0.01, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (29, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'# Total Cancellations', N'KPI', N'Total count of cancelled cases in the selected period', N'CALCULATE(COUNT(VisitCaseID), VisitCaseScheduleStatus=Canceled)', N'Cancelled cases', N'—', N'—',
     NULL, NULL, NULL, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (29, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'# DOS Cancellations', N'KPI', N'Count of cases cancelled on the day of surgery', N'CALCULATE(COUNT(VisitCaseID), VisitCaseSameDayCancellation=Y)', N'Cases with SameDayCancellation=Y', N'—', N'—',
     NULL, NULL, NULL, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (29, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'# Advance Cancellations', N'KPI', N'Count of cases cancelled before the day of surgery', N'CALCULATE(COUNT(VisitCaseID), ScheduleStatus=Canceled, SameDayCancellation=N)', N'Cancelled cases with SameDayCancellation=N', N'—', N'—',
     NULL, NULL, NULL, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (29, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'# Cancellations DOS', N'Timing bucket', N'Count of cancellations recorded on the same day as the service date', N'CALCULATE(COUNT(VisitCaseID), CancellationTiming=DOS)', N'Cases with CancellationTiming=DOS', N'—', N'DaysBeforeDOS = 0',
     NULL, NULL, NULL, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (29, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'# Cancellations Short Notice', N'Timing bucket', N'Count of cancellations recorded 1 to 7 days before the service date', N'CALCULATE(COUNT(VisitCaseID), CancellationTiming=Short Notice)', N'Cases with CancellationTiming=Short Notice', N'—', N'DaysBeforeDOS between 1 and 7',
     NULL, NULL, NULL, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (29, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'# Cancellations Moderate', N'Timing bucket', N'Count of cancellations recorded 8 to 30 days before the service date', N'CALCULATE(COUNT(VisitCaseID), CancellationTiming=Moderate)', N'Cases with CancellationTiming=Moderate', N'—', N'DaysBeforeDOS between 8 and 30',
     NULL, NULL, NULL, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (29, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'# Cancellations Advance', N'Timing bucket', N'Count of cancellations recorded more than 30 days before the service date', N'CALCULATE(COUNT(VisitCaseID), CancellationTiming=Advance)', N'Cases with CancellationTiming=Advance', N'—', N'DaysBeforeDOS > 30; advance cancellations allow block time to be reassigned',
     NULL, NULL, NULL, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (29, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'# Cancellations Late Entry', N'Timing bucket', N'Count of cancellations recorded after the service date — data quality flag', N'CALCULATE(COUNT(VisitCaseID), CancellationTiming=Late Entry)', N'Cases with CancellationTiming=Late Entry', N'—', N'Negative DaysBeforeDOS; indicates administrative entry after DOS — flagged as data quality issue in EHR workflow',
     NULL, NULL, NULL, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (29, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'% Cancellation Rate (Provider)', N'Supporting', N'Provider-level cancellation rate — cancelled cases divided by total cases for that provider', N'DIVIDE(CALCULATE(COUNT(VisitCaseID), ScheduleStatus=Canceled), CALCULATE(COUNT(VisitCaseID), MinutesInOR>0 || ScheduleStatus=Canceled))', N'Cancelled cases per provider', N'Completed + cancelled cases per provider', N'—',
     NULL, NULL, NULL, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (29, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'CancellationTiming', N'Column', N'Classification of how far in advance a cancellation was recorded relative to the service date', N'IF(ISBLANK(CancelledDate), BLANK(), SWITCH(TRUE(), DaysBefore<0, Late Entry, DaysBefore=0, DOS, DaysBefore<=7, Short Notice, DaysBefore<=30, Moderate, Advance)) — DaysBefore = DATEDIFF(CancelledDate, ServiceDate, DAY)', N'—', N'—', N'VAR syntax not supported in this PBI version for calculated columns — uses nested DATEDIFF without VAR',
     NULL, NULL, NULL, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (29, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'DaysBeforeDOS', N'Column', N'Number of days between the cancellation date and the service date', N'DATEDIFF(VisitCaseCancelledDate, VisitCaseServiceDate, DAY)', N'—', N'—', N'Negative values = late entry; zero = DOS; positive = advance; NULL when no cancellation date exists',
     NULL, NULL, NULL, '2026-07-07');
GO
