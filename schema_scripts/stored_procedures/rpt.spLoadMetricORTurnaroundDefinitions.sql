CREATE PROCEDURE [rpt].[spLoadMetricORTurnaroundDefinitions]	AS





-- ── MetricID 28: CASE TURNAROUND TIME DETAIL ──
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (28, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'Avg Turnover Time (min)', N'KPI', N'Average minutes between one case ending and the next case beginning in the same room on the same day', N'DIVIDE([# Total Turnover Minutes],[# Total Room Turnovers])', N'Total turnover minutes', N'Count of turnovers > 0', N'Replaces misleadingly named % Turnover Time from dashboard; 30 min is organizational benchmark target',
     NULL, NULL, 30.00, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (28, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'Avg Scheduled Turnover (min)', N'KPI', N'Average scheduled turnover duration sourced directly from the EHR system', N'CALCULATE(AVERAGE(VisitCaseScheduledTurnoverDuration), VisitCaseTurnoverMinutes > 0)', N'Sum of VisitCaseScheduledTurnoverDuration', N'Count of cases with turnover > 0', N'VisitCaseScheduledTurnoverDuration = SCHED_ROOM_OUT_TO_IN from Epic V_CASE_ROOM_TURNOVER linked server view',
     NULL, NULL, NULL, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (28, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'Avg Procedure Turnover (min)', N'KPI', N'Average time from procedure completion to next case start from the EHR system', N'CALCULATE(AVERAGE(VisitCaseProcedureTurnoverDuration), VisitCaseTurnoverMinutes > 0)', N'Sum of VisitCaseProcedureTurnoverDuration', N'Count of cases with turnover > 0', N'VisitCaseProcedureTurnoverDuration = PROC_COMP_TO_START_ADJ from Epic V_CASE_ROOM_TURNOVER linked server view',
     NULL, NULL, NULL, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (28, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'# Total Room Turnovers', N'KPI', N'Count of room turnover events where a positive turnover time was recorded', N'CALCULATE(COUNT(VisitCaseTurnoverMinutes), VisitCaseTurnoverMinutes > 0)', N'Cases with TurnoverMinutes > 0', N'—', N'Turnover nulled when next case is on a different calendar date to prevent cross-day inflation',
     NULL, NULL, NULL, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (28, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'# Total Turnover Minutes', N'KPI', N'Sum of all turnover minutes across all turnover events in the selected period', N'SUM(VisitCaseTurnoverMinutes)', N'VisitCaseTurnoverMinutes', N'—', N'—',
     NULL, NULL, NULL, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (28, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'# Total Turnover Hours', N'Supporting', N'Total turnover time expressed in hours to two decimal places', N'DIVIDE([# Total Turnover Minutes], 60)', N'Total turnover minutes', N'60', N'—',
     NULL, NULL, NULL, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (28, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'VisitCaseTurnoverMinutes', N'Column', N'Minutes between current case OR end and next case OR begin in same room on same calendar day', N'CASE WHEN Next_ORBegin IS NULL THEN NULL WHEN Next_ORBeginDate != CaseDate THEN NULL ELSE DATEDIFF(minute, VisitCaseOREndDatetime, Next_ORBegin) END', N'—', N'—', N'Computed using LEAD() window function in Turnover CTE partitioned by VisitCaseRoomID ordered by VisitCaseORBeginDatetime',
     NULL, NULL, NULL, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (28, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'Avg Turnover - [Day of Week]', N'Supporting', N'Average turnover time for cases whose OR end falls on a specific day of week', N'CALCULATE([Avg Turnover Time (min)], dim Dates[WeekDayName] = [Day])', N'Turnover minutes on specific day', N'Turnovers on specific day', N'Five measures covering Monday through Friday',
     NULL, NULL, 30.00, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (28, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'Avg Turnover - [HH to HH]', N'Supporting', N'Average turnover time grouped by the two-hour block in which the preceding case ended — shows intraday fatigue trend', N'CALCULATE([Avg Turnover Time (min)], FILTER(vVisitCases, HOUR(VisitCaseOREndDatetime) >= X && HOUR < Y))', N'Turnover minutes in time window', N'Turnovers in time window', N'Six measures covering 06-08 through 16-18 in two-hour blocks; later blocks typically show longer turnovers',
     NULL, NULL, 30.00, '2026-07-07');
GO
