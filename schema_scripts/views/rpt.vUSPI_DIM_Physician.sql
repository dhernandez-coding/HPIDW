CREATE VIEW rpt.vUSPI_DIM_Physician AS
--WITH ReferredList AS (
--    SELECT DISTINCT 
--        r.ReferredByProviderID
--		FROM
--        rpt.vEpicReferrals r

--) rl

SELECT 
    5 AS company_code,        -- Company code derived from provider ID
    NULL AS facility_code,                                        -- Facility code (placeholder for now)
    case when len(p.PROV_NAME) - len(replace(p.PROV_NAME,' ','')) = 2
		then substring(p.PROV_NAME,charindex(' ',p.PROV_NAME)+1,(charindex(' ',p.PROV_NAME, (charindex(' ',p.PROV_NAME,1))+1)) - charindex(' ',p.PROV_NAME)-1)
		else right(p.PROV_NAME,CASE WHEN len(p.PROV_NAME) - charindex(' ',p.PROV_NAME) >= 1 THEN len(p.PROV_NAME) - charindex(' ',p.PROV_NAME) ELSE 0 END)
	end ProviderFirstName,
	case when len(p.PROV_NAME) - len(replace(p.PROV_NAME,' ','')) = 2
		then right(p.PROV_NAME,1)
		else ''
	end ProviderMiddleInitial,
	replace(replace(substring(p.PROV_NAME,1,charindex(' ',p.PROV_NAME)),',',''),' ','') ProviderLastName,
    s.NAME AS specialty,                                   -- Specialty description
    CASE 
        WHEN si.SPECIALTY_C IS NOT NULL THEN CONCAT('5~', si.SPECIALTY_C) 
        ELSE NULL 
    END AS specialty_code,                                        -- Specialty code
    p.RPT_GRP_ONE AS group_name,                                           -- Placeholder for group name
    p.RPT_GRP_TWO AS group_code,                                           -- Placeholder for group code
    NULL AS investor_flag,                                        -- Placeholder for investor flag
    NULL AS referring_physician_flag,                              -- Referring physician flag
    CASE 
        WHEN p.ACTIVE_STATUS = 'Active' THEN 'Active'
        ELSE 'Inactive'
    END AS status_code,                                           -- Status code
    'EPIC' AS source_system,                                      -- Static source system
    CAST(p.PROV_ID AS VARCHAR(250)) AS physician_code,            -- Physician code
    GETDATE() AS create_date,                                     -- Current timestamp
    GETDATE() AS update_date,                                     -- Current timestamp for updates
    pa.NPI AS physician_npi,                                      -- Physician NPI
    p.BIRTH_DATE AS physician_dob                                 -- Physician date of birth
FROM 
    [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[CLARITY_SER] p
LEFT JOIN 
    [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[CLARITY_SER_2] pa 
    ON p.PROV_ID = pa.PROV_ID
LEFT JOIN 
    [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[CLARITY_SER_ADDR] a 
    ON p.PROV_ID = a.PROV_ID AND a.PRIMARY_ADDR_YN = 'Y'
LEFT JOIN 
   [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[CLARITY_SER_SPEC] si 
    ON p.PROV_ID = si.PROV_ID AND si.LINE = 1
LEFT JOIN 
    [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[ZC_SPECIALTY] s 
    ON si.SPECIALTY_C = s.SPECIALTY_C
LEFT JOIN 
    [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[ZC_SEX] x 
    ON p.SEX_C = x.RCPT_MEM_SEX_C
LEFT JOIN 
    [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[ZC_STATE] t 
    ON a.STATE_C = t.STATE_C

WHERE p.PROV_TYPE = 'Physician'
GO
