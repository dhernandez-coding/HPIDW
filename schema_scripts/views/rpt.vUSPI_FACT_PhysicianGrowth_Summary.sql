CREATE   VIEW  [rpt].[vUSPI_FACT_PhysicianGrowth_Summary] AS
/*
====================================================
 Author:      Diego Hernandez
 Create date: 02/06/2026
 Description: Physician Growth Summary (Monthly Classification)
 Source:       rpt.vUSPI_FACT_PhysicianGrowth_Details
 Grain:        Physician / Unit / Month
====================================================
*/

WITH Base AS
(
    SELECT
        d.*,

        -- First case month per physician & unit
        MIN(DATEFROMPARTS(d.rptyear, d.rptmonth, 1))
            OVER (PARTITION BY d.unitid, d.primary_phys_num) AS facilityfirstcasedate
    FROM rpt.vUSPI_FACT_PhysicianGrowth_Details d
),
BaseFlags AS
(
    SELECT
        b.*,

        -- NEW physician
        CASE
            WHEN b.rptmocnt > 0
             AND b.facilityfirstcasedate = DATEFROMPARTS(b.rptyear, b.rptmonth, 1)
            THEN 1 ELSE 0
        END AS is_new,

        -- LOST physician
        CASE
            WHEN b.rptmocnt = 0 AND b.prior12mocnt > 0
            THEN 1 ELSE 0
        END AS is_lost,

        -- DECLINING physician
        CASE
            WHEN b.prv03mocnt > 0
             AND b.rptmocnt < (b.prv03mocnt / 3.0)
            THEN 1 ELSE 0
        END AS is_declining
    FROM Base b
)

SELECT
    /* ============================================
       Stable Oracle ID (Physician ~ Year ~ Month)
       ============================================ */
    CONCAT(
        primary_phys_num,
        '~',
        rptyear,
        '~',
        RIGHT('00' + CAST(rptmonth AS varchar(2)), 2)
    ) AS oracleid,

    /* =====================
       Physician Identifiers
       ===================== */
    unitid                                  AS unit,
    TRY_CAST(primary_phys_num AS numeric)  AS physnum,
    pers_org_num                           AS physiciancode,
    national_prov_id                       AS physiciannpi,
    last_name                              AS physicianlastname,
    first_name                             AS physicianfirstname,

    /* =====================
       Specialty
       ===================== */
    serviceline                            AS specialtycode,
    serviceline                            AS specialty,

    /* =====================
       Reporting Period
       ===================== */
    rptyear                                AS reportyear,
    rptmonth                               AS reportmonth,

    /* =====================
       Classification Flags
       ===================== */
    is_lost                                AS lost,
    is_new                                 AS [new],

    CASE
        WHEN rptmocnt > 0 AND prior12mocnt > 0
         AND rptmocnt < (prior12mocnt / 12.0)
        THEN 1 ELSE 0
    END                                    AS low,

    CASE WHEN rptmocnt > 0 AND prior12mocnt > 0 THEN 1 ELSE 0 END AS established,
    CASE WHEN rptmocnt > 0 AND prior12mocnt = 0 THEN 1 ELSE 0 END AS notestablished,

    CASE
        WHEN rptmocnt >= (pytdcnt / NULLIF(rptmonth, 0))
        THEN 1 ELSE 0
    END                                    AS currproductive,

    CASE WHEN pytdcnt > 0 THEN 1 ELSE 0 END AS priorproductive,

    is_declining                           AS declining,

    /* =====================
       Lost / New Timing
       ===================== */
    CASE WHEN is_lost = 1 THEN rptyear  END AS lostyear,
    CASE WHEN is_lost = 1 THEN rptmonth END AS lostmonth,
    CASE WHEN is_lost = 1 THEN rptyear  END AS lostidentifiedyear,
    CASE WHEN is_lost = 1 THEN rptmonth END AS lostidentifiedmonth,

    CASE WHEN is_new = 1 THEN rptyear  END  AS newyear,
    CASE WHEN is_new = 1 THEN rptmonth END  AS newmonth,

    facilityfirstcasedate,
    CASE WHEN is_new = 1 THEN 1 ELSE 0 END  AS facilityfirstcaseflag,

    /* =====================
       Optional Commentary
       ===================== */
    CAST(NULL AS varchar(200))              AS lostreason,
    CAST(NULL AS varchar(500))              AS lostreasoncomments,

    /* =====================
       Metrics (from Details)
       ===================== */
    rptmocnt,
    prvmo01cnt,
    prvmo02cnt,
    prvmo03cnt,
    prv03mocnt,
    prior12mocnt,
    py03mocnt,
    cytdcnt,
    pytdcnt,

    /* =====================
       Expected / Exceptions
       ===================== */
    CAST(NULL AS numeric(18,4))             AS currytdexpected,
    CAST(NULL AS numeric(18,4))             AS priorytdexpected,

    CASE
        WHEN is_lost = 1 OR is_declining = 1 THEN 1
        ELSE 0
    END                                    AS exceptionflag,

    source_system_id,
    GETDATE()                               AS load_ts

FROM BaseFlags
where pers_org_num is not null ;
GO
