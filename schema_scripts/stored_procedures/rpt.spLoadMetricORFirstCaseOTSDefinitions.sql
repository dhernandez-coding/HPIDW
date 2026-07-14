CREATE PROCEDURE [rpt].[spLoadMetricORFirstCaseOTSDefinitions]	AS






-- ── MetricID 27: FIRST CASE ON TIME STARTS DETAIL ──
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (27, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'% First Case On Time Start', N'KPI', N'Percentage of first cases that started on time or early', N'CALCULATE(COUNT(VisitCaseID), FirstCaseofDay=Y, LateStart=N) / CALCULATE(COUNT(VisitCaseID), FirstCaseofDay=Y)', N'First cases with LateStart=N', N'All first cases', N'First case = VisitCaseFirstCaseofDay=Y; on time = within 5 min of scheduled start',
     NULL, NULL, 0.70, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (27, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'% First Case Late Start', N'KPI', N'Percentage of first cases that started more than 5 minutes after scheduled start', N'CALCULATE(COUNT(VisitCaseID), FirstCaseofDay=Y, OnTimeStartStatus=Late Start) / CALCULATE(COUNT(VisitCaseID), FirstCaseofDay=Y)', N'First cases with OnTimeStartStatus=Late Start', N'All first cases', N'—',
     NULL, NULL, NULL, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (27, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'% First Case Early Start', N'KPI', N'Percentage of first cases that started before the scheduled start time', N'CALCULATE(COUNT(VisitCaseID), FirstCaseofDay=Y, OnTimeStartStatus=Early Start) / CALCULATE(COUNT(VisitCaseID), FirstCaseofDay=Y)', N'First cases with OnTimeStartStatus=Early Start', N'All first cases', N'—',
     NULL, NULL, NULL, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (27, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'# First Cases (Total)', N'KPI', N'Total count of first cases in the selected period', N'CALCULATE(COUNT(VisitCaseID), VisitCaseFirstCaseofDay=Y)', N'Cases where VisitCaseFirstCaseofDay=Y', N'—', N'—',
     NULL, NULL, NULL, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (27, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'# Avg Minutes Late (First Case)', N'KPI', N'Average minutes late for first cases that started late', N'AVERAGEX(FILTER(vVisitCases, FirstCaseofDay=Y && OnTimeStartStatus=Late Start), DATEDIFF(ScheduleStartDatetime, ORBeginDatetime, MINUTE))', N'Sum of late minutes for late first cases', N'Count of late first cases', N'Only includes cases classified as Late Start — excludes on time and early starts',
     NULL, NULL, NULL, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (27, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'VisitCaseFirstCaseofDay', N'Column', N'Flag indicating whether a case was the first case of the day in that room', N'Y or N flag sourced directly from fact.VisitCases', N'—', N'—', N'Determined by the source system; first case = earliest scheduled case in the room on that date',
     NULL, NULL, NULL, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (27, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'% First Case OTS - [Day of Week]', N'Supporting', N'On time start percentage for first cases on a specific day of week', N'CALCULATE([% First Case On Time Start], dim Dates[WeekDayName] = [Day])', N'First cases on time on specific day', N'All first cases on specific day', N'Five measures — one per weekday Monday through Friday',
     NULL, NULL, 0.70, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (27, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'# Cases With Delay', N'Supporting', N'Count of cases that had a recorded delay reason from the EHR', N'CALCULATE(COUNT(VisitCaseID), CaseDelay=Y)', N'Cases where CaseDelay=Y', N'—', N'CaseDelay=Y when DELAY_REASON_NM is not null in V_CASE_ROOM_TURNOVER linked server view',
     NULL, NULL, NULL, '2026-07-07');
GO
