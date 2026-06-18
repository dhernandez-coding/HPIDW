CREATE   PROCEDURE [etl].[spReloadModMedPatients]
AS
BEGIN
    SET NOCOUNT ON;

    PRINT 'Step 1: Create staging table';

    IF OBJECT_ID('tempdb..#StagingPatients') IS NOT NULL
        DROP TABLE #StagingPatients;

    CREATE TABLE #StagingPatients (
        PatientID                   VARCHAR(100),
        PatientDataSourceID         INT,
        PatientSourceID             VARCHAR(100),
        PatientMRN                  VARCHAR(100),
        PatientFirstName            VARCHAR(100),
        PatientMiddleInitial        VARCHAR(50),
        PatientLastName             VARCHAR(100),
        PatientFullName             VARCHAR(255),
        PatientGender               VARCHAR(50),
        PatientDateOfBirth          DATETIME2,
        PatientSSN                  VARCHAR(50),
        PatientHomePhone            VARCHAR(50),
        PatientWorkPhone            VARCHAR(50),
        PatientWorkPhoneExtension   VARCHAR(50),
        PatientMobilePhone          VARCHAR(50),
        PatientEmailAddress         VARCHAR(255),
        PatientStreetAddress1       VARCHAR(255),
        PatientStreetAddress2       VARCHAR(255),
        PatientCity                 VARCHAR(100),
        PatientState                VARCHAR(50),
        PatientZipCode              VARCHAR(20),
        PatientMaritalStatus        VARCHAR(50),
        PatientEthnicity            VARCHAR(100),
        PatientLanguage             VARCHAR(50),
        PatientIsActive             BIT,
        PatientUpdatedDateTime      DATETIME2,
        PatientRace                 VARCHAR(100),
        PatientMedicareNumber       VARCHAR(100)
    );

    PRINT 'Step 2: Load data into staging';

    INSERT INTO #StagingPatients
    SELECT
    '15~' + p.patient_id                          AS PatientID,
    15                                            AS PatientDataSourceID,
    p.patient_id                                  AS PatientSourceID,

    MAX(p.mrn)                                    AS PatientMRN,
    MAX(p.first_name)                             AS PatientFirstName,
    LEFT(MAX(p.middle_name), 1)                   AS PatientMiddleInitial,
    MAX(p.last_name)                              AS PatientLastName,

    MAX(
        CONCAT(
            p.first_name,
            ' ',
            COALESCE(p.middle_name + ' ', ''),
            p.last_name
        )
    )                                             AS PatientFullName,

    MAX(p.sex)                                    AS PatientGender,
    MAX(p.date_of_birth)                          AS PatientDateOfBirth,

    NULL                                          AS PatientSSN,

    MAX(p.home_phone_number)                      AS PatientHomePhone,
    MAX(p.work_phone_number)                      AS PatientWorkPhone,
    NULL                                          AS PatientWorkPhoneExtension,
    MAX(p.mobile_phone_number)                    AS PatientMobilePhone,
    MAX(p.email)                                  AS PatientEmailAddress,

    MAX(p.home_street1)                           AS PatientStreetAddress1,
    MAX(p.home_street2)                           AS PatientStreetAddress2,
    MAX(p.home_city)                              AS PatientCity,
    MAX(p.home_state)                             AS PatientState,
    MAX(p.home_zipcode)                           AS PatientZipCode,

    MAX(p.marital_status)                         AS PatientMaritalStatus,
    MAX(p.ethnic_group)                           AS PatientEthnicity,
    MAX(p.language)                               AS PatientLanguage,

    CASE 
        WHEN MAX(CAST(p.archived AS INT)) = 1 THEN 0 
        ELSE 1 
    END                                           AS PatientIsActive,

    GETDATE()                                     AS PatientUpdatedDateTime,

    MAX(p.race)                                   AS PatientRace,
    MAX(p.medicare_number)                        AS PatientMedicareNumber

FROM stg.ModMed_Patient p
GROUP BY
    p.patient_id;


    PRINT 'Step 3: Insert into dim.Patients';

    IF (SELECT COUNT(1) FROM #StagingPatients) > 0
    BEGIN
        DELETE FROM dim.Patients
        WHERE PatientDataSourceID = 15;

        INSERT INTO dim.Patients
        SELECT * FROM #StagingPatients;
    END
    ELSE
    BEGIN
        PRINT 'No records found. Skipping insert.';
    END
END;
GO
