CREATE PROCEDURE [rpt].[spLoadMetricORFixRoomDefinitions]	AS



-- ── MetricID 22: FIXED ROOM UTILIZATION DETAIL ──
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (22, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'% Fixed Room Utilization', N'KPI', N'Percentage of all OR room hours used out of total available hours across all 19 rooms on weekdays', N'DIVIDE([# Hours In OR],[# OR Rooms (All)] * 8 * [# Days Selected])', N'Hours in OR', N'19 rooms × 8 hrs × weekdays selected', N'—',
     NULL, NULL, 0.60, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (22, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'# Rooms At Or Above Target', N'KPI', N'Count of OR rooms whose utilization is at or above the 60% target in the current filter context', N'COUNTROWS(FILTER(ADDCOLUMNS(VALUES(dim Rooms[RoomName]), RoomUtil, CALCULATE(DIVIDE(SUM(MinutesInOR), 8*60*[# Days Selected]))), [RoomUtil] >= 0.60))', N'Rooms with util >= 60%', N'—', N'Iterates over each room individually; responds to location and room slicers',
     NULL, NULL, NULL, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (22, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'# Rooms Below Target', N'KPI', N'Count of OR rooms whose utilization is below the 60% target', N'[# OR Rooms (All)] - [# Rooms At Or Above Target]', N'Total OR rooms minus rooms at or above target', N'—', N'—',
     NULL, NULL, NULL, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (22, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'% Fixed Room Utilization (by room)', N'Chart measure', N'Room-level utilization used in bar chart and heatmap', N'CALCULATE(DIVIDE(SUM(MinutesInOR), 8*60*[# Days Selected]))', N'Hours in OR for specific room', N'8 hrs × days selected × 60', N'Evaluated in row context of each room in the visual',
     NULL, NULL, 0.60, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (22, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'Room x Day of Week Heatmap', N'Visual', N'Matrix showing utilization percentage for each room by day of week', N'% Fixed Room Utilization scoped to room + weekday', N'—', N'—', N'Conditional formatting: >=60% green, 45-59% amber, <45% red; WeekDayName sorted by Weekday numeric column',
     NULL, NULL, NULL, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (22, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'# Gap To Target (Fixed Room)', N'Table column', N'Difference between room utilization and the 60% target', N'[% Fixed Room Utilization] - 0.60', N'Room utilization %', N'0.60 target', N'Positive = above target; negative = below target; shown in summary table',
     NULL, NULL, NULL, '2026-07-07');
GO
