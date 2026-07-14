CREATE PROCEDURE [rpt].[spLoadMetricORNetUtilizationDefinitions]	AS





-- ── MetricID 25: NET BLOCK UTILIZATION DETAIL ──
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (25, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'% Utilized (Net Block)', N'KPI', N'Block utilization excluding time utilized in manually released blocks', N'DIVIDE([# Min Utilized (Net Block)],[# Min Available (Block)])', N'Min utilized (block) minus min utilized in released slots', N'Min available (block)', N'Net removes the contribution of released block time from numerator only — denominator stays same as gross',
     NULL, NULL, 0.70, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (25, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'# Min Utilized (Net Block)', N'KPI', N'Block minutes utilized excluding cases in manually released slots', N'[# Min Utilized (Block)] - [# Min Utilized (Released Block)]', N'Min utilized (block)', N'Minus min utilized in released slots', N'—',
     NULL, NULL, NULL, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (25, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'# Min Utilized (Released Block)', N'KPI', N'Minutes utilized within manually released block slots by other providers', N'SUMX(SUMMARIZE(..., SlotUtilized, SUM(ScheduleUtilizedUnblockedMinutes)), IF(BlockModifiedReason=Manual Block Release, MIN(SlotUtilized,30), 0))', N'Sum of ScheduleUtilizedUnblockedMinutes in released slots', N'Capped at 30/slot', N'Released slots utilize unblocked minutes not blocked minutes since slot type changes to Unblocked after release',
     NULL, NULL, NULL, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (25, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'# Released Impact (pp)', N'KPI', N'Percentage point difference between gross and net block utilization — impact of voluntary releases', N'[% Utilized (Block)] - [% Utilized (Net Block)]', N'Gross block util %', N'Minus net block util %', N'Positive value means gross is higher than net; represents pp contribution of released blocks to gross utilization',
     NULL, NULL, NULL, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (25, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'% Utilized (Released Block)', N'Supporting', N'Percentage of manually released block time that was utilized by others', N'DIVIDE([# Min Utilized (Released Block)],[# Min Released (Block)])', N'Min utilized in released slots', N'Min released (block)', N'Shows how effectively released time was reused by other providers after manual release',
     NULL, NULL, NULL, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (25, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'OriginalBlockOwnerFinal', N'Column', N'Name of the provider who originally owned a block before it was manually released', N'FIRST_VALUE(OriginalBlockOwner) OVER (PARTITION BY VisitCaseID ORDER BY CaseBlockRelationshipPriority ASC)', N'—', N'—', N'NULL for slots that were never manually released; populated only when ScheduleBlockModifiedReason = Manual Block Release',
     NULL, NULL, NULL, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (25, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'# Cases (In Block)', N'Supporting', N'Count of distinct cases performed within the provider''''s own retained block time', N'CALCULATE(DISTINCTCOUNT(VisitCaseID), CaseBlockRelationshipFinal=In Block, NOT ISBLANK(VisitCaseID))', N'Cases with CaseBlockRelationshipFinal=In Block', N'—', N'—',
     NULL, NULL, NULL, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (25, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'# Cases (In Released Block)', N'Supporting', N'Count of distinct cases performed in time that was manually released by the original block owner', N'CALCULATE(DISTINCTCOUNT(VisitCaseID), CaseBlockRelationshipFinal=In Released Block, NOT ISBLANK(VisitCaseID))', N'Cases with CaseBlockRelationshipFinal=In Released Block', N'—', N'—',
     NULL, NULL, NULL, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (25, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'# Cases (Out of Block)', N'Supporting', N'Count of distinct cases performed in open unblocked time', N'CALCULATE(DISTINCTCOUNT(VisitCaseID), CaseBlockRelationshipFinal=Out of Block, NOT ISBLANK(VisitCaseID))', N'Cases with CaseBlockRelationshipFinal=Out of Block', N'—', N'—',
     NULL, NULL, NULL, '2026-07-07');
INSERT INTO [HPIDW].[rpt].[MetricValues]
    ([MetricID],[MetricValueDate],[DataSourceID],
     [LocationID],[DepartmentID],[ProviderID],[PracticeID],[PayerID],[ServiceLine],
     [ReportGroup1],[ReportGroup2],[ReportGroup3],[ReportGroup4],[ReportGroup5],[ReportGroup6],[ReportGroup7],
     [MetricValueNumerator],[MetricValueDenominator],[MetricValue],[UpdateDatetime])
VALUES
    (25, '2026-07-07', 5,
     NULL, NULL, NULL, NULL, NULL, NULL,
     N'# Cases (In Another Providers Block)', N'Supporting', N'Count of distinct cases performed within a block owned by a different provider', N'CALCULATE(DISTINCTCOUNT(VisitCaseID), CaseBlockRelationshipFinal=In Another Providers Block, NOT ISBLANK(VisitCaseID))', N'Cases with CaseBlockRelationshipFinal=In Another Providers Block', N'—', N'—',
     NULL, NULL, NULL, '2026-07-07');
GO
