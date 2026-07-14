CREATE PROCEDURE [rpt].[spLoadMetricORAllCaseOTSDefinitions]	AS






-- ── MetricID 26: ALL CASES ON TIME STARTS DETAIL ──
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (26, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'% All Cases On Time Start', N'KPI', N'Percentage of all completed cases that started on time or early', N'CALCULATE(COUNT(VisitCaseID), LateStart=N) / CALCULATE(COUNT(VisitCaseID), MinutesInOR>0)', N'Cases with LateStart=N', N'Cases with MinutesInOR > 0', N'On time = within 5 min of scheduled start; early starts counted as on time',
     NULL, NULL, 0.70, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (26, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'% All Cases Late Start', N'KPI', N'Percentage of all completed cases that started more than 5 minutes after scheduled start', N'CALCULATE(COUNT(VisitCaseID), OnTimeStartStatus=Late Start) / CALCULATE(COUNT(VisitCaseID), MinutesInOR>0)', N'Cases with OnTimeStartStatus=Late Start', N'Cases with MinutesInOR > 0', N'—',
     NULL, NULL, NULL, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (26, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'% All Cases Early Start', N'KPI', N'Percentage of all completed cases that started before the scheduled start time', N'CALCULATE(COUNT(VisitCaseID), OnTimeStartStatus=Early Start, MinutesInOR>0) / CALCULATE(COUNT(VisitCaseID), MinutesInOR>0)', N'Cases with OnTimeStartStatus=Early Start', N'Cases with MinutesInOR > 0', N'—',
     NULL, NULL, NULL, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (26, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'# Avg Minutes Late (All Cases)', N'KPI', N'Average minutes late across all cases that started late', N'AVERAGEX(FILTER(vVisitCases, OnTimeStartStatus=Late Start && MinutesInOR>0), DATEDIFF(ScheduleStartDatetime, ORBeginDatetime, MINUTE))', N'Sum of late minutes for late cases', N'Count of late cases', N'Only includes cases classified as Late Start',
     NULL, NULL, NULL, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (26, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'% Case Length Accuracy', N'KPI', N'Percentage of cases where actual duration was within tolerance of scheduled duration', N'CALCULATE(COUNT(VisitCaseID), VisitCaseAccuracyStatus=Accurate) / CALCULATE(COUNT(VisitCaseID), MinutesInOR>0)', N'Accurate cases', N'Cases with MinutesInOR > 0', N'Accurate = within +/-15 minutes of scheduled duration based on corrected threshold logic',
     NULL, NULL, NULL, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (26, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'% Case Length Overscheduled', N'KPI', N'Percentage of cases where scheduled duration was more than 15 minutes longer than actual', N'DIVIDE(DISTINCTCOUNT where AccuracyStatus contains Overscheduled, DISTINCTCOUNT where MinutesInOR>0)', N'Overscheduled cases', N'Cases with MinutesInOR > 0', N'Two tiers: 15-30 mins overscheduled and 30+ mins overscheduled',
     NULL, NULL, NULL, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (26, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'% Case Length Underscheduled', N'KPI', N'Percentage of cases where actual duration exceeded scheduled duration by more than 15 minutes', N'DIVIDE(DISTINCTCOUNT where AccuracyStatus contains Underscheduled, DISTINCTCOUNT where MinutesInOR>0)', N'Underscheduled cases', N'Cases with MinutesInOR > 0', N'Two tiers: 15-30 mins underscheduled and 30+ mins underscheduled; underscheduled cases often cause downstream late starts',
     NULL, NULL, NULL, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (26, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'VisitCaseAccuracyStatus', N'Column', N'Classification of case scheduling accuracy based on difference between scheduled and actual OR duration', N'CASE WHEN diff < -50 THEN 30+ Mins Underscheduled WHEN diff < -30 THEN 15-30 Mins Underscheduled WHEN diff > 30 THEN 30+ Mins Overscheduled WHEN diff > 15 THEN 15-30 Mins Overscheduled WHEN MinutesInOR > 0 THEN Accurate END — diff = VisitCaseMinutesScheduledInOR - VisitCaseMinutesInOR', N'—', N'—', N'Negative diff means case ran longer than scheduled (underscheduled); thresholds ordered most extreme first to prevent misclassification',
     NULL, NULL, NULL, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (26, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'VisitCaseOnTimeStartStatus', N'Column', N'Classification of case start timing relative to scheduled start time', N'CASE WHEN DATEDIFF(ScheduleStart,ORBegin,MINUTE) < 0 THEN Early Start WHEN DATEDIFF <= 5 THEN On Time WHEN DATEDIFF > 5 THEN Late Start END', N'—', N'—', N'5-minute grace period for on-time classification; computed from VisitCaseScheduleStartDatetime vs VisitCaseORBeginDatetime',
     NULL, NULL, NULL, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (26, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'# Cases Accurate / Overscheduled / Underscheduled', N'Supporting', N'Count of cases in each accuracy category for stacked bar chart by provider', N'CALCULATE(COUNT(VisitCaseID), VisitCaseAccuracyStatus = [category], MinutesInOR > 0)', N'Cases matching accuracy category', N'—', N'Three separate measures — one per accuracy category',
     NULL, NULL, NULL, '2026-07-07');
GO
