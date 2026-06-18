CREATE   PROCEDURE [etl].[spModMedReloadProviders]
AS
BEGIN
    SET NOCOUNT ON;

    PRINT 'Step 1: Create staging table';

    IF OBJECT_ID('tempdb..#StagingProviders') IS NOT NULL
        DROP TABLE #StagingProviders;

    CREATE TABLE #StagingProviders (
        ProviderID                 VARCHAR(100),
        ProviderDataSourceID       INT,
        ProviderSourceID           VARCHAR(100),
        ProviderAbbreviation       VARCHAR(100),
        ProviderFirstName          VARCHAR(100),
        ProviderMiddleInitial      VARCHAR(50),
        ProviderLastName           VARCHAR(100),
        ProviderGender             VARCHAR(50),
        ProviderSuffix             VARCHAR(50),
        ProviderStreetAddress1     VARCHAR(255),
        ProviderStreetAddress2     VARCHAR(255),
        ProviderCity               VARCHAR(100),
        ProviderState              VARCHAR(50),
        ProviderZipCode            VARCHAR(20),
        ProviderPhone              VARCHAR(50),
        ProviderFax                VARCHAR(50),
        ProviderSpecialtyID        VARCHAR(100),
        ProviderUPIN               VARCHAR(100),
        ProviderNPI                VARCHAR(50),
        ProviderIsActive           BIT,
        ProviderUpdatedDateTime    DATETIME2
    );

    PRINT 'Step 2: Load staging data';

    INSERT INTO #StagingProviders
    SELECT
        '15~' + p.staff_id                          AS ProviderID,
        15                                          AS ProviderDataSourceID,
        p.staff_id                                  AS ProviderSourceID,

        p.universal_identifier                     AS ProviderAbbreviation,
        p.first_name                               AS ProviderFirstName,
        LEFT(p.middle_name, 1)                     AS ProviderMiddleInitial,
        p.last_name                                AS ProviderLastName,
        NULL                                       AS ProviderGender,
        p.suffix                                   AS ProviderSuffix,

        NULL                                       AS ProviderStreetAddress1,
        NULL                                       AS ProviderStreetAddress2,
        NULL                                       AS ProviderCity,
        NULL                                       AS ProviderState,
        NULL                                       AS ProviderZipCode,

        NULL                                       AS ProviderPhone,
        NULL                                       AS ProviderFax,

        p.professional_designation                 AS ProviderSpecialtyID,
        p.billing_provider_id                      AS ProviderUPIN,
        p.npi                                      AS ProviderNPI,

        CASE 
            WHEN p.role IS NULL THEN 1
            ELSE 1
        END                                        AS ProviderIsActive,

        GETDATE()                                  AS ProviderUpdatedDateTime
    FROM (
        SELECT
            p.*,
            ROW_NUMBER() OVER (
                PARTITION BY p.staff_id
                ORDER BY p.staff_id
            ) AS rn
        FROM HPIDW.stg.ModMed_Provider p
        WHERE p.npi IS NOT NULL
    ) p
    WHERE p.rn = 1;

    PRINT 'Step 3: Load into dim.Providers';

    IF (SELECT COUNT(*) FROM #StagingProviders) > 0
    BEGIN
        DELETE FROM dim.Providers
        WHERE ProviderDataSourceID = 15;

        INSERT INTO dim.Providers
        SELECT * FROM #StagingProviders;
    END
    ELSE
    BEGIN
        PRINT 'No provider records found.';
    END
END;
GO
