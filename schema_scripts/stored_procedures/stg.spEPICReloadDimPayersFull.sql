-- =============================================
-- Author:		Ryan Tisserand
-- Create date: 02/10/2023
-- Description:	Extracts, Transforms and Loads Payer Data from EPIC Source System into a dim Table
-- Change Control
--	1. 02/10/2023 - Ryan Tisserand - Initial build of procedure
--  2. 03/14/2023 - Chris Cross - Added PayerCategoryID
--  3. 05/09/2025 - Diego Hernandez - Adding safe load
-- =============================================
CREATE PROCEDURE [stg].[spEPICReloadDimPayersFull] AS
BEGIN
    SET NOCOUNT ON;

    PRINT 'Creating @StagingTable...';

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

    -- Insert manual Self-Pay record
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
    VALUES (
        '5~0', 5, '0', '0~7', '5~4',
        'Self-Pay', 'Self-Pay',
        NULL, NULL, NULL, NULL, NULL,
        1, GETDATE()
    );

    -- Load payer data from CLARITY
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
    ep.PayerID,
    ep.PayerDataSourceID,
    ep.PayerSourceID,
    pg.PayerGroupID,
    ep.PayerCategoryID,
    ep.PAYOR_NAME,
    ep.SHORT_NAME,
    ep.ADDR_LINE_1,
    ep.ADDR_LINE_2,
    ep.CITY,
    ep.ABBR,
    ep.ZIP_CODE,
    ep.PayerIsActive,
    ep.PayerUpdatedDateTime
FROM OPENQUERY([CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM],
'
    SELECT 
        ''5~'' + CAST(p.PAYOR_ID AS VARCHAR(50)) AS PayerID,
        5 AS PayerDataSourceID,
        p.PAYOR_ID AS PayerSourceID,
        ''5~'' + CAST(p.FINANCIAL_CLASS AS VARCHAR(50)) AS PayerCategoryID,
        p.PAYOR_NAME,
        p.SHORT_NAME,
        p.ADDR_LINE_1,
        p.ADDR_LINE_2,
        p.CITY,
        s.ABBR,
        p.ZIP_CODE,
        1 AS PayerIsActive,
        GETDATE() AS PayerUpdatedDateTime
    FROM [Clarity].[ORGFILTER].[CLARITY_EPM] p
    LEFT JOIN [Clarity].[ORGFILTER].[CLARITY_FC] f 
        ON p.FINANCIAL_CLASS = f.FINANCIAL_CLASS
    LEFT JOIN [Clarity].[ORGFILTER].[ZC_STATE] s 
        ON p.STATE_C = s.STATE_C
') AS ep
LEFT JOIN dim.PayerCategories pc 
    ON pc.PayerCategoryID = ep.PayerCategoryID
LEFT JOIN map.PayerGroupPayerCategories pg 
    ON pg.PayerCategoryID = pc.PayerCategoryID;

    -- Proceed only if enough data was returned
    IF (SELECT COUNT(1) FROM @StagingTable) >= 10
    BEGIN
        BEGIN TRANSACTION;
            PRINT 'At least 10 records found. Proceeding to delete and reload.';

            DELETE FROM dim.Payers WHERE PayerDataSourceID = 5;

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
        PRINT 'Less than 10 records in the staging table. Ending job without delete and reload...';
    END
END;

-- ################################################ OPEN QUERY ##############################################


--    PRINT 'Creating @StagingTable...';

--    DECLARE @StagingTable TABLE (
--        PayerID VARCHAR(50),
--        PayerDataSourceID INT,
--        PayerSourceID VARCHAR(50),
--        PayerGroupID VARCHAR(50),
--        PayerCategoryID VARCHAR(50),
--        PayerName VARCHAR(100),
--        PayerAbbreviation VARCHAR(50),
--        PayerStreetAddress1 VARCHAR(50),
--        PayerStreetAddress2 VARCHAR(50),
--        PayerCity VARCHAR(50),
--        PayerState VARCHAR(50),
--        PayerZipCode VARCHAR(50),
--        PayerIsActive BIT,
--        PayerUpdatedDateTime DATETIME
--    );

--    -- Insert manual Self-Pay record
--    INSERT INTO @StagingTable (
--        PayerID,
--        PayerDataSourceID,
--        PayerSourceID,
--        PayerGroupID,
--        PayerCategoryID,
--        PayerName,
--        PayerAbbreviation,
--        PayerStreetAddress1,
--        PayerStreetAddress2,
--        PayerCity,
--        PayerState,
--        PayerZipCode,
--        PayerIsActive,
--        PayerUpdatedDateTime
--    )
--    VALUES (
--        '5~0', 5, '0', '0~7', '5~4',
--        'Self-Pay', 'Self-Pay',
--        NULL, NULL, NULL, NULL, NULL,
--        1, GETDATE()
--    );

--    -- Load payer data from CLARITY
--    INSERT INTO @StagingTable (
--        PayerID,
--        PayerDataSourceID,
--        PayerSourceID,
--        PayerGroupID,
--        PayerCategoryID,
--        PayerName,
--        PayerAbbreviation,
--        PayerStreetAddress1,
--        PayerStreetAddress2,
--        PayerCity,
--        PayerState,
--        PayerZipCode,
--        PayerIsActive,
--        PayerUpdatedDateTime
--    )
--    SELECT 
--        '5~' + CAST(p.payor_id AS VARCHAR(50)) AS PayerID,
--        5 AS PayerDataSourceID,
--        p.payor_id AS PayerSourceID,
--        pg.PayerGroupID,
--        '5~' + CAST(p.FINANCIAL_CLASS AS VARCHAR(50)) AS PayerCategoryID,
--        p.PAYOR_NAME,
--        p.SHORT_NAME,
--        p.ADDR_LINE_1,
--        p.ADDR_LINE_2,
--        p.CITY,
--        s.ABBR,
--        p.ZIP_CODE,
--        1 AS PayerIsActive,
--        GETDATE() AS PayerUpdatedDateTime
--    FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[CLARITY_EPM] p
--    LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[CLARITY_FC] f 
--        ON p.FINANCIAL_CLASS = f.FINANCIAL_CLASS
--    LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[ZC_STATE] s 
--        ON p.STATE_C = s.STATE_C
--    LEFT JOIN dim.PayerCategories pc 
--        ON pc.PayerCategoryID = CONCAT('5~', p.FINANCIAL_CLASS)
--    LEFT JOIN map.PayerGroupPayerCategories pg 
--        ON pg.PayerCategoryID = pc.PayerCategoryID;

--    -- Proceed only if enough data was returned
--    IF (SELECT COUNT(1) FROM @StagingTable) >= 10
--    BEGIN
--        BEGIN TRANSACTION;
--            PRINT 'At least 10 records found. Proceeding to delete and reload.';

--            DELETE FROM dim.Payers WHERE PayerDataSourceID = 5;

--            INSERT INTO dim.Payers (
--                PayerID,
--                PayerDataSourceID,
--                PayerSourceID,
--                PayerGroupID,
--                PayerCategoryID,
--                PayerName,
--                PayerAbbreviation,
--                PayerStreetAddress1,
--                PayerStreetAddress2,
--                PayerCity,
--                PayerState,
--                PayerZipCode,
--                PayerIsActive,
--                PayerUpdatedDateTime
--            )
--            SELECT 
--                PayerID,
--                PayerDataSourceID,
--                PayerSourceID,
--                PayerGroupID,
--                PayerCategoryID,
--                PayerName,
--                PayerAbbreviation,
--                PayerStreetAddress1,
--                PayerStreetAddress2,
--                PayerCity,
--                PayerState,
--                PayerZipCode,
--                PayerIsActive,
--                PayerUpdatedDateTime
--            FROM @StagingTable;

--        COMMIT TRANSACTION;
--    END
--    ELSE
--    BEGIN
--        PRINT 'Less than 10 records in the staging table. Ending job without delete and reload...';
--    END
--END;
GO
