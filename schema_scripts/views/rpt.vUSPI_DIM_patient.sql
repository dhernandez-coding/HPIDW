CREATE VIEW [rpt].[vUSPI_DIM_patient] AS
SELECT 
    '5' AS company_code,     -- Company code derived from source ID
    '5~430' AS facility_code,                                             -- Facility code (set NULL or join if applicable)
    p.PatientFirstName AS first_name,                                  -- Patient first name
    p.PatientLastName AS last_name,                                    -- Patient last name
    p.PatientDateOfBirth AS dob,                                       -- Patient date of birth
    SUBSTRING(p.PatientGender, 1, 1) AS sex,                           -- Gender, limited to 1 character
    p.PatientRace AS race,                                             -- Race
    CONCAT(p.PatientStreetAddress1, ' ', p.PatientStreetAddress2) AS address, -- Full address
    p.PatientCity AS city,                                             -- City
    p.PatientState AS state,                                           -- State
    p.PatientZipCode AS zip_code,-- ZIP code
	pp.MEDICARE_NUM as MedicareNumber,
    zc.NAME AS county,                                                    -- County (add logic if needed)
    e.EMPLOYER_NAME  AS employer_name,                                             -- Employer name (set NULL or add logic if available)
    NULL AS account_code,                                              -- Account code (set NULL or add logic if available)
    p.PatientID AS patient_code,                                       -- Patient code
    'EPIC' AS source_system,                                           -- Static source system identifier
    GETDATE() AS create_date,                                          -- Current timestamp for record creation
    NULL AS update_date,                                               -- Initially NULL for updates
    NULL AS account_group_10,                          -- Account group (logic derived from PatientID)
    NULL AS account_group_100,
    NULL AS account_group_1000,
    NULL AS account_group_10000,
    NULL AS account_group_100000,
    NULL AS account_group_1000000,
    NULL AS account_group_10000000,
    NULL AS account_group_100000000,
    NULL AS account_group_1000000000,
    CAST(p.PatientSourceID AS VARCHAR(6)) AS source_patient_code,       -- Source patient code
    p.PatientMRN AS patient_mrn,                                       -- Medical record number
    NULL AS nationality,                                               -- Nationality (add logic if applicable)
    p.PatientEthnicity AS ethnicity                                    -- Ethnicity
FROM 
    [HPIDW].[dim].[Patients] p
LEFT JOIN
	[CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[dbo].PATIENT pp
	ON pp.PAT_ID=p.PatientID
LEFT JOIN 
   [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[ZC_COUNTY] zc 
    ON pp.COUNTY_C = zc.COUNTY_C
LEFT JOIN 
    [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[dbo].CLARITY_EEP e 
    ON pp.EMPLOYER_ID = e.EMPLOYER_ID

WHERE 
    p.PatientDataSourceID = 5;                                         -- Filter for DataSourceID 5
GO
