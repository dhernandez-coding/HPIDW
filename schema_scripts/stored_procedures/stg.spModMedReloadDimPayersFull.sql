CREATE PROCEDURE [stg].[spModMedReloadDimPayersFull]
AS
BEGIN
    SET NOCOUNT ON;

    PRINT 'Creating staging table for ModMed Payers (basic)...';

    DECLARE @StagingTable TABLE (
        PayerID VARCHAR(50),
        PayerDataSourceID INT,
        PayerSourceID VARCHAR(50),
        PayerGroupID VARCHAR(50),
        PayerCategoryID VARCHAR(50),
        PayerName VARCHAR(100),
        PayerAbbreviation VARCHAR(50),
        PayerStreetAddress1 VARCHAR(50),
        PayerStreetAddress2 VARCHAR(50),
        PayerCity VARCHAR(50),
        PayerState VARCHAR(50),
        PayerZipCode VARCHAR(50),
        PayerIsActive BIT,
        PayerUpdatedDateTime DATETIME
    );

    ------------------------------------------------------------
    -- Load ModMed Payers (DEDUPLICATED)
    ------------------------------------------------------------
    INSERT INTO @StagingTable (
        PayerID,
        PayerDataSourceID,
        PayerSourceID,
        PayerGroupID,
        PayerCategoryID,
        PayerName,
        PayerAbbreviation,
        PayerStreetAddress1,
        PayerStreetAddress2,
        PayerCity,
        PayerState,
        PayerZipCode,
        PayerIsActive,
        PayerUpdatedDateTime
    )
    SELECT
        '16~' + CAST(p.payer_id AS VARCHAR(50))              AS PayerID,
        16                                                   AS PayerDataSourceID,
        CAST(p.payer_id AS VARCHAR(50))                     AS PayerSourceID,
        NULL                                                 AS PayerGroupID,
        NULL												 AS PayerCategoryID,
        MAX(p.payer_name)                                   AS PayerName,
        NULL                                                 AS PayerAbbreviation,
        NULL                                                 AS PayerStreetAddress1,
        NULL                                                 AS PayerStreetAddress2,
        NULL                                                 AS PayerCity,
        NULL                                                 AS PayerState,
        NULL                                                 AS PayerZipCode,
        MAX(CAST(p.active AS INT))                           AS PayerIsActive,
        GETDATE()                                            AS PayerUpdatedDateTime
    FROM [HPIDW].[stg].[ModMed_Payers] p
    GROUP BY
        p.payer_id,
        p.financial_category_id;

    ------------------------------------------------------------
    -- Safety check
    ------------------------------------------------------------
    IF (SELECT COUNT(1) FROM @StagingTable) >= 10
    BEGIN
        BEGIN TRANSACTION;

            PRINT 'At least 10 records found. Reloading ModMed Payers...';

            DELETE FROM dim.Payers
            WHERE PayerDataSourceID = 16;

            INSERT INTO dim.Payers (
                PayerID,
                PayerDataSourceID,
                PayerSourceID,
                PayerGroupID,
                PayerCategoryID,
                PayerName,
                PayerAbbreviation,
                PayerStreetAddress1,
                PayerStreetAddress2,
                PayerCity,
                PayerState,
                PayerZipCode,
                PayerIsActive,
                PayerUpdatedDateTime
            )
            SELECT
                PayerID,
                PayerDataSourceID,
                PayerSourceID,
                PayerGroupID,
                PayerCategoryID,
                PayerName,
                PayerAbbreviation,
                PayerStreetAddress1,
                PayerStreetAddress2,
                PayerCity,
                PayerState,
                PayerZipCode,
                PayerIsActive,
                PayerUpdatedDateTime
            FROM @StagingTable;

        COMMIT TRANSACTION;
    END
    ELSE
    BEGIN
        PRINT 'Less than 10 records found. Skipping delete and reload.';
    END
END;
GO
