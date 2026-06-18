CREATE   PROCEDURE [stg].[spReloadModMedPayers]
AS
BEGIN
    SET NOCOUNT ON;

    PRINT 'Step 1: Creating staging table...';

    IF OBJECT_ID('tempdb..#StagingPayers') IS NOT NULL
        DROP TABLE #StagingPayers;

    CREATE TABLE #StagingPayers
    (
        PayerID                VARCHAR(100),
        PayerDataSourceID      INT,
        PayerSourceID          VARCHAR(100),
        PayerGroupID           VARCHAR(100),
        PayerCategoryID        VARCHAR(100),
        PayerName              VARCHAR(255),
        PayerAbbreviation      VARCHAR(100),
        PayerStreetAddress1    VARCHAR(255),
        PayerStreetAddress2    VARCHAR(255),
        PayerCity              VARCHAR(100),
        PayerState             VARCHAR(50),
        PayerZipCode           VARCHAR(25),
        PayerIsActive          BIT,
        PayerUpdatedDatetime   DATETIME
    );

    PRINT 'Step 2: Loading data from stg.ModMed_Payers...';

    INSERT INTO #StagingPayers
(
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
    PayerUpdatedDatetime
)
SELECT
    '15~' + CAST(p.payer_id AS VARCHAR(100))      AS PayerID,
    15                                            AS PayerDataSourceID,
    CAST(p.payer_id AS VARCHAR(100))              AS PayerSourceID,
    CAST(p.payer_group AS VARCHAR(100)) AS PayerGroupID,
    CAST(p.financial_category_id AS VARCHAR(100)) AS PayerCategoryID,
    p.payer_name                                  AS PayerName,
    p.payer_id_number                             AS PayerAbbreviation,
    NULL                                          AS PayerStreetAddress1,
    NULL                                          AS PayerStreetAddress2,
    NULL                                          AS PayerCity,
    NULL                                          AS PayerState,
    NULL                                          AS PayerZipCode,
    CASE WHEN p.active = 1 THEN 1 ELSE 0 END       AS PayerIsActive,
    GETDATE()                                     AS PayerUpdatedDatetime
FROM (
    SELECT
        payer_id,
        ISNULL(MAX(financial_category_id),'1513-pod37') AS financial_category_id,
		CASE 
			WHEN financial_category_id = '1507-pod37' THEN '0~7'
			ELSE ISNULL(pg.PayerGroupID,'0~3') END AS payer_group,
        MAX(payer_name) AS payer_name,
        MAX(payer_id_number) AS payer_id_number,
        1 AS active
     FROM [stg].[ModMed_Payers] p 
	 LEFT JOIN  map.PayerGroupPayerCategories pg 
		ON pg.PayerCategoryID = CONCAT('15~',p.financial_category_id)

    GROUP BY payer_id,PayerGroupID,financial_category_id
) p;

    PRINT 'Step 3: Validation row count...';

    IF (SELECT COUNT(1) FROM #StagingPayers) > 0
    BEGIN
        PRINT 'Step 4: Deleting existing Payers for datasource 16...';

        DELETE FROM [dim].[Payers]
        WHERE PayerDataSourceID = 15;

        PRINT 'Step 5: Inserting refreshed payer records...';

        INSERT INTO [dim].[Payers]
        (
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
            PayerUpdatedDatetime
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
            PayerUpdatedDatetime
        FROM #StagingPayers;
    END
    ELSE
    BEGIN
        PRINT 'No rows found in staging — aborting insert.';
    END
END;
GO
