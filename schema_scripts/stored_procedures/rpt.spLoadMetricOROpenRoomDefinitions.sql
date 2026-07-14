CREATE PROCEDURE [rpt].[spLoadMetricOROpenRoomDefinitions]	AS



-- ── MetricID 23: OPEN ROOM UTILIZATION DETAIL ──
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (23, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'% Open Room Utilization', N'KPI', N'Percentage of hours used in rooms that were actually open (had at least one case)', N'DIVIDE([# Hours In OR],[# Available Hours (Open)])', N'Hours in OR', N'Open room days × 8 hrs', N'Open room = any room with MinutesInOR > 0 on a given day — interim definition pending formal org definition',
     NULL, NULL, 0.80, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (23, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'# OR Room Days (Open)', N'KPI', N'Count of distinct room/day combinations that had at least one case', N'COUNTROWS(SUMMARIZE(FILTER(vVisitCases, MinutesInOR>0), VisitCaseORID, VisitCaseServiceDate))', N'Distinct room + date combinations', N'—', N'—',
     NULL, NULL, NULL, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (23, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'# Available Hours (Open)', N'Supporting', N'Total available hours across all open room days', N'[# OR Room Days (Open)] * 8', N'Open room days', N'8 hrs per day', N'—',
     NULL, NULL, NULL, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (23, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'# Rooms At Or Above Target (Open)', N'KPI', N'Count of open rooms at or above 80% utilization using per-room open days as denominator', N'COUNTROWS(FILTER(ADDCOLUMNS(VALUES(RoomName), RoomUtil, CALCULATE(DIVIDE(SUM(MinutesInOR), COUNTROWS(SUMMARIZE(FILTER(...),ServiceDate))*8*60))), RoomUtil >= 0.80))', N'Rooms with open util >= 80%', N'—', N'Denominator uses per-room open day count not total open days',
     NULL, NULL, NULL, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (23, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'# Rooms Below Target (Open)', N'KPI', N'Count of open rooms below 80% utilization', N'CALCULATE(DISTINCTCOUNT(VisitCaseORID), MinutesInOR>0) - [# Rooms At Or Above Target (Open)]', N'Open rooms minus rooms at or above target', N'—', N'—',
     NULL, NULL, NULL, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (23, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'# Gap To Target (Open Room)', N'Table column', N'Difference between open room utilization and the 80% target', N'[% Open Room Utilization] - 0.80', N'Open room util %', N'0.80 target', N'—',
     NULL, NULL, NULL, '2026-07-07');
GO
