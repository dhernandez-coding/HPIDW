CREATE   VIEW  [rpt].[vUSPI_FACT_PhysicianGrowth_Details] AS
/*
====================================================
 Author:      Diego Hernandez
 Create date: 02/06/2026
 Description: Physician Monthly Growth – Completed Visit Cases
 Source:       fact.VisitCases (+ dim.Providers, fact.VisitProcedures)
 Filter:       VisitCaseDatesourceID = 5
               VisitCaseScheduleStatus = 'Completed'
 Grain:        Physician / Unit / ServiceLine / EncounterType / Procedure / Month
====================================================
*/

WITH Base AS
(
    SELECT
        -- Dimensions
		
        CAST(vc.VisitCaseLocationID AS varchar(100)) AS unitid,
        CAST(vc.VisitCasePhysician  AS varchar(100)) AS primary_phys_num,
        CAST(p.ProviderNPI          AS varchar(50))  AS national_prov_id,
        CAST(p.ProviderID           AS varchar(100)) AS pers_org_num,
        CAST(p.ProviderLastName     AS varchar(200)) AS last_name,
        CAST(p.ProviderFirstName    AS varchar(200)) AS first_name,

        CAST(vc.VisitCaseServiceID        AS varchar(100)) AS proc_num,
        CAST(vp.VisitProcedureCode        AS varchar(300)) AS quick_code,
        YEAR(vc.VisitCaseServiceDate)  AS rptyear,
        MONTH(vc.VisitCaseServiceDate) AS rptmonth,

        CAST(vc.VisitCaseService      AS varchar(200)) AS serviceline,
        CAST(NULL                     AS numeric(18,4)) AS casefactor,
        CAST(vc.VisitCasePatientClass AS varchar(100)) AS encountertype,

        CAST(vc.VisitCaseDatesourceID AS varchar(50)) AS source_system_id
    FROM fact.VisitCases vc
    LEFT JOIN dim.vProviders p
        ON p.ProviderID = CONCAT('5~', vc.VisitCasePhysician)
    LEFT JOIN fact.VisitProcedures vp
        ON vp.VisitProcedureVisitID = vc.VisitCaseVisitID
    WHERE vc.VisitCaseDatesourceID = 5
      AND vc.VisitCaseScheduleStatus = 'Completed'
      AND vc.VisitCaseServiceDate IS NOT NULL
),
Monthly AS
(
    SELECT
        unitid,
        primary_phys_num,
        national_prov_id,
        pers_org_num,
        last_name,
        first_name,
        proc_num,
        quick_code,
        rptyear,
        rptmonth,
        COUNT(*) AS rptmocnt,
        serviceline,
        casefactor,
        encountertype,
        source_system_id
    FROM Base
    GROUP BY
        unitid,
        primary_phys_num,
        national_prov_id,
        pers_org_num,
        last_name,
        first_name,
        proc_num,
        quick_code,
        rptyear,
        rptmonth,
        serviceline,
        casefactor,
        encountertype,
        source_system_id
),
WithWindows AS
(
    SELECT
        m.*,

        ISNULL(LAG(m.rptmocnt, 1) OVER (PARTITION BY unitid, primary_phys_num, proc_num, quick_code, serviceline, encountertype ORDER BY rptyear, rptmonth), 0) AS prvmo01cnt,
        ISNULL(LAG(m.rptmocnt, 2) OVER (PARTITION BY unitid, primary_phys_num, proc_num, quick_code, serviceline, encountertype ORDER BY rptyear, rptmonth), 0) AS prvmo02cnt,
        ISNULL(LAG(m.rptmocnt, 3) OVER (PARTITION BY unitid, primary_phys_num, proc_num, quick_code, serviceline, encountertype ORDER BY rptyear, rptmonth), 0) AS prvmo03cnt,

        ISNULL(SUM(m.rptmocnt) OVER (
            PARTITION BY unitid, primary_phys_num, proc_num, quick_code, serviceline, encountertype
            ORDER BY rptyear, rptmonth
            ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING
        ), 0) AS prv03mocnt,

        ISNULL(SUM(m.rptmocnt) OVER (
            PARTITION BY unitid, primary_phys_num, proc_num, quick_code, serviceline, encountertype
            ORDER BY rptyear, rptmonth
            ROWS BETWEEN 12 PRECEDING AND 1 PRECEDING
        ), 0) AS prior12mocnt,

        ISNULL(SUM(m.rptmocnt) OVER (
            PARTITION BY unitid, primary_phys_num, proc_num, quick_code, serviceline, encountertype, rptyear
            ORDER BY rptmonth
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ), 0) AS cytdcnt
    FROM Monthly m
),
Final AS
(
    SELECT
        w.*,
        ISNULL(py.cytdcnt, 0) AS pytdcnt,
        ISNULL(py3.py03mocnt, 0) AS py03mocnt
    FROM WithWindows w
    LEFT JOIN WithWindows py
        ON py.primary_phys_num = w.primary_phys_num
       AND py.proc_num = w.proc_num
       AND py.quick_code = w.quick_code
       AND py.serviceline = w.serviceline
       AND py.encountertype = w.encountertype
       AND py.rptyear = w.rptyear - 1
       AND py.rptmonth = w.rptmonth
    LEFT JOIN
    (
        SELECT
            primary_phys_num, proc_num, quick_code, serviceline, encountertype,
            rptyear, rptmonth,
            SUM(rptmocnt) OVER (
                PARTITION BY primary_phys_num, proc_num, quick_code, serviceline, encountertype, rptyear
                ORDER BY rptmonth
                ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
            ) AS py03mocnt
        FROM Monthly
    ) py3
        ON py3.primary_phys_num = w.primary_phys_num
       AND py3.proc_num = w.proc_num
       AND py3.quick_code = w.quick_code
       AND py3.serviceline = w.serviceline
       AND py3.encountertype = w.encountertype
       AND py3.rptyear = w.rptyear - 1
       AND py3.rptmonth = w.rptmonth
)

SELECT
    -- ✅ oracleid defined LAST and at correct grain
    CONCAT(primary_phys_num, '~', rptyear, '~', RIGHT('00' + CAST(rptmonth AS varchar(2)), 2)) AS oracleid,

    unitid,
    primary_phys_num,
    national_prov_id,
    pers_org_num,
    last_name,
    first_name,
    proc_num,
    quick_code,
    rptyear,
    rptmonth,

    CAST(rptmocnt AS bigint)    AS rptmocnt,
    CAST(prvmo01cnt AS bigint)  AS prvmo01cnt,
    CAST(prvmo02cnt AS bigint)  AS prvmo02cnt,
    CAST(prvmo03cnt AS bigint)  AS prvmo03cnt,
    CAST(prv03mocnt AS bigint)  AS prv03mocnt,
    CAST(prior12mocnt AS bigint) AS prior12mocnt,
    CAST(py03mocnt AS bigint)   AS py03mocnt,
    CAST(cytdcnt AS bigint)     AS cytdcnt,
    CAST(pytdcnt AS bigint)     AS pytdcnt,

    serviceline,
    casefactor,
    encountertype,
    source_system_id,
    GETDATE() AS load_ts
FROM Final;
GO
