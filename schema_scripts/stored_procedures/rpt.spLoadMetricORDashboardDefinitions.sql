CREATE PROCEDURE [rpt].[spLoadMetricORDashboardDefinitions]	AS

--BEGIN	



-- ── MetricID 21: DASHBOARD ──
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (21, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'% Fixed Room Utilization', N'KPI', N'Percentage of all OR room hours used out of total available hours across all 19 rooms on weekdays', N'DIVIDE([# Hours In OR],[# OR Rooms (All)] * 8 * [# Days Selected])', N'Hours in OR', N'19 rooms × 8 hrs × weekdays selected', N'8-hour room day is a business assumption; all 19 rooms included regardless of staffing',
     NULL, NULL, 0.60, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (21, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'% Open Room Utilization', N'KPI', N'Percentage of OR hours used out of hours available in rooms that had at least one case', N'DIVIDE([# Hours In OR],[# OR Room Days (Open)] * 8)', N'Hours in OR', N'Open room days × 8 hrs', N'Open room defined as any room with at least one case on a given day — interim definition',
     NULL, NULL, 0.80, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (21, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'% Utilized (Block) — Gross', N'KPI', N'Percentage of scheduled block time that was utilized by cases', N'DIVIDE([# Min Utilized (Block)],[# Min Available (Block)])', N'Min utilized in blocked slots (capped at 30/slot)', N'Min available in blocked slots (30/slot)', N'Uses SUMMARIZE pattern to handle multi-case slots; cap at 30 min per slot prevents over-counting',
     NULL, NULL, 0.70, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (21, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'% Utilized (Net Block)', N'KPI', N'Gross block utilization excluding the impact of manually released blocks', N'DIVIDE([# Min Utilized (Net Block)],[# Min Available (Block)])', N'Min utilized (block) minus min utilized in manually released slots', N'Min available (block)', N'Net shows what utilization would be if no blocks were voluntarily released',
     NULL, NULL, 0.70, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (21, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'% First Case On Time Start', N'KPI', N'Percentage of first cases of the day that started on time (within 5 minutes of scheduled start)', N'CALCULATE(COUNT(VisitCaseID), FirstCaseofDay=Y, LateStart=N) / CALCULATE(COUNT(VisitCaseID), FirstCaseofDay=Y)', N'First cases with LateStart=N', N'All first cases', N'On time = 0-5 min after scheduled start; early starts also counted as on time',
     NULL, NULL, 0.70, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (21, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'% All Cases On Time Start', N'KPI', N'Percentage of all completed cases that started on time', N'CALCULATE(COUNT(VisitCaseID), LateStart=N) / CALCULATE(COUNT(VisitCaseID), MinutesInOR>0)', N'Cases with LateStart=N', N'All cases with MinutesInOR > 0', N'Excludes cancelled cases from denominator',
     NULL, NULL, 0.70, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (21, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'Avg Turnover Time (min)', N'KPI', N'Average minutes between one case ending and the next case beginning in the same room on the same day', N'DIVIDE([# Total Turnover Minutes],[# Total Room Turnovers])', N'Total turnover minutes', N'Count of turnovers > 0', N'Replaces misleadingly named % Turnover Time measure; 30 min is organizational target',
     NULL, NULL, 30.00, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (21, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'% Cases Cancelled', N'KPI', N'Percentage of all scheduled cases that were cancelled', N'CALCULATE(# All Cases, ScheduleStatus=Canceled) / # All Cases', N'Cancelled cases', N'All cases', N'10% target set by organization',
     NULL, NULL, 0.10, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (21, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'% DOS Cancellations', N'KPI', N'Percentage of all cases cancelled on the day of surgery', N'# DOS Cancellations / # All Cases', N'Cases where SameDayCancellation=Y', N'All cases', N'DOS = cancellation date equals service date',
     NULL, NULL, 0.01, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (21, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'# Days Selected', N'Supporting', N'Count of distinct weekdays in the selected date range', N'COUNTROWS(FILTER(VALUES(dim Dates[Date]), dim Dates[IsWeekend] = FALSE()))', N'Distinct weekday dates in filter context', N'—', N'Anchored to fact vVisitCases date range; excludes weekends only — holidays not excluded',
     NULL, NULL, NULL, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (21, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'# OR Rooms (All)', N'Supporting', N'Count of distinct OR rooms responding to location/room slicer', N'CALCULATE(DISTINCTCOUNT(dim Rooms[RoomName]), dim Rooms[RoomIsOR] = TRUE())', N'Distinct OR room names', N'—', N'Responds to location and room slicers; used in fixed room utilization denominator',
     NULL, NULL, NULL, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (21, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'# Hours In OR', N'Supporting', N'Total hours cases were in the OR', N'SUM(VisitCaseMinutesInOR) / 60', N'Sum of VisitCaseMinutesInOR', N'60 (conversion)', N'—',
     NULL, NULL, NULL, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (21, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'# OR Room Days (Open)', N'Supporting', N'Count of distinct room/day combinations that had at least one case', N'COUNTROWS(SUMMARIZE(FILTER(vVisitCases, MinutesInOR>0), VisitCaseORID, VisitCaseServiceDate))', N'Distinct room + date combinations with cases', N'—', N'Used in open room utilization denominator',
     NULL, NULL, NULL, '2026-07-07');
GO
