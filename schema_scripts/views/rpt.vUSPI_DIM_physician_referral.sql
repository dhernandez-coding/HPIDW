CREATE VIEW rpt.vUSPI_DIM_physician_referral AS
SELECT DISTINCT
    '5' AS company_code,                                   -- Static company code
    NULL AS facility_code,                                 -- Placeholder for facility code
    CONCAT('5~', c.ProviderID) AS physician_code,             -- Physician code
    c.ProviderFirstName AS first_name,                                     -- First name extracted from full name
    c.ProviderLastName AS last_name,                                      -- Last name extracted from full name
    s.NAME AS specialty,                                   -- Specialty of the physician
    c.ProviderSpecialtyID AS specialty_code,                                -- Placeholder for specialty code
    c.[ProviderIsActive],
    c.ProviderUPIN AS upin,                                        -- Unique Physician Identifier (UPIN)
    c.ProviderNPI AS npi,                                         -- National Provider Identifier (NPI)
    NULL AS date_of_birth,                         -- Date of birth of the physician
    'EPIC' AS source_system,                               -- Static source system
    GETDATE() AS create_date,                              -- Record creation date
    GETDATE() AS update_date                                    -- Placeholder for update date
FROM 
    rpt.vEpicReferrals r
LEFT JOIN 
    HPIDW.dim.vProviders c
    ON r.ReferredByProviderID = c.ProviderID
LEFT JOIN 
  [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[CLARITY_SER_2] pa 
   ON c.ProviderID = CONCAT('5~',pa.PROV_ID)
LEFT JOIN 
   [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[ZC_SPECIALTY] s 
    ON c.[ProviderSpecialtyID] = CONCAT('5~',s.SPECIALTY_C)
GO
