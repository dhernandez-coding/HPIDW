CREATE PROCEDURE [rpt].[spLoadMetricORGrossUtilizationDefinitions]	AS





-- ── MetricID 24: GROSS BLOCK UTILIZATION DETAIL ──
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (24, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'% Utilized (Block) — Gross', N'KPI', N'Percentage of scheduled block time utilized by cases', N'DIVIDE([# Min Utilized (Block)],[# Min Available (Block)])', N'Min utilized in blocked slots (capped 30/slot)', N'Min available in blocked slots', N'—',
     NULL, NULL, 0.70, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (24, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'# Min Available (Block)', N'KPI', N'Total available minutes across all blocked schedule slots', N'SUMX(SUMMARIZE(vOpTimeUtilization, ScheduleID, ScheduleSlotAvailabilityType), IF(SlotType=Blocked, 30, 0))', N'30 min per blocked slot', N'—', N'SUMMARIZE pattern deduplicates multi-case slots; slot capacity sourced from slot type not availability column',
     NULL, NULL, NULL, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (24, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'# Min Utilized (Block)', N'KPI', N'Total minutes utilized within blocked schedule slots capped at 30 per slot', N'SUMX(SUMMARIZE(..., SlotUtilized, SUM(ScheduleUtilizedBlockMinutes)), MIN([SlotUtilized], 30))', N'Sum of ScheduleUtilizedBlockMinutes per slot', N'Capped at 30 per slot', N'Cap at 30 prevents slots with multiple overlapping cases from exceeding physical slot capacity',
     NULL, NULL, NULL, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (24, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'# Min Released (Block)', N'KPI', N'Total block minutes that were manually released by providers', N'SUMX(SUMMARIZE(vOpTimeUtilization, ScheduleID, ScheduleBlockModifiedReason), IF(BlockModifiedReason=Manual Block Release, 30, 0))', N'30 min per manually released slot', N'—', N'Only counts Manual Block Release — excludes Automatic Block Release - Service and Automatic Block Release - Performed',
     NULL, NULL, NULL, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (24, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'% Min Released (Block)', N'Supporting', N'Percentage of total block time that was manually released', N'DIVIDE([# Min Released (Block)],[# Min Available (Block)])', N'Min released', N'Min available (block)', N'—',
     NULL, NULL, NULL, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (24, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'# Min Unused Retained (Block)', N'KPI', N'Block minutes that were kept (not released) but not utilized', N'[# Min Available (Block)] - [# Min Released (Block)] - [# Min Utilized (Block)]', N'Available minus released minus utilized', N'—', N'Represents true wasted block capacity — time the provider kept but did not use',
     NULL, NULL, NULL, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (24, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'% Min Unused Retained (Block)', N'Supporting', N'Percentage of total block time that was retained but unused', N'DIVIDE([# Min Unused Retained (Block)],[# Min Available (Block)])', N'Min unused retained', N'Min available (block)', N'—',
     NULL, NULL, NULL, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (24, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'CaseBlockRelationshipFinal', N'Column', N'Dominant block relationship classification for each case based on highest priority slot classification', N'FIRST_VALUE(CaseBlockRelationship) OVER (PARTITION BY VisitCaseID ORDER BY CaseBlockRelationshipPriority ASC)', N'—', N'—', N'Computed in SQL view using window function; priority order: In Block=1, In Released Block=2, In Another Providers Block=3, Out of Block=4, Other=5',
     NULL, NULL, NULL, '2026-07-07');
GO
