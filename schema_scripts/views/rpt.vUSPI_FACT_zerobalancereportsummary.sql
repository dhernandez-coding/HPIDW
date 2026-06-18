CREATE   VIEW [rpt].[vUSPI_FACT_zerobalancereportsummary] AS
/*
====================================================
 Author:      Diego Hernandez
 Create date: 02/06/2026
 Description: Zero Balance Report Summary - USPI AdvantX
 Source: rpt.vUSPI_FACT_zerobalancereport
 Grain: Unit / Department / Insurance Type
====================================================
*/

SELECT
    -- Identifiers
    a.id AS oracleid,
    a.unit,
    a.department,
    a.commonname,

    -- Insurance / classification
    a.instype,

    -- Aggregated financials
    SUM(a.charge) AS charge,
    SUM(a.paid) AS paid,
    SUM(a.charge) - SUM(a.paid) AS reserve,

    -- Metadata
    a.source_system_id,
    MAX(a.load_ts) AS load_ts
FROM rpt.vUSPI_FACT_zerobalancereport a
GROUP BY
    a.id,
    a.unit,
    a.department,
    a.commonname,
    a.instype,
    a.source_system_id;
GO
