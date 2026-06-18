-- =============================================
-- Author:		Chris Cross
-- Create date: 03/14/2023
-- Description:	Extracts, Transforms and Loads Provider Data from EPIC Source System into a dim Table
-- Change Control
--	1. 03/14/2023 - Chris Cross - Initial build of procedure
--  2. 05/09/2025 - Diego Hernandez - Safe reload
-- =============================================
CREATE PROCEDURE [stg].[spEPICReloadDimPayerCategoriesFull] AS
BEGIN
    SET NOCOUNT ON;

    PRINT 'Creating @StagingTable...';

    DECLARE @StagingTable TABLE (
        PayerCategoryID VARCHAR(50),
        PayerCategoryDataSourceID INT,
        PayerCategorySourceID VARCHAR(50),
        PayerCategoryName VARCHAR(100),
        PayerCategoryIsActive BIT,
        PayerCategoryUpdatedDatetime DATETIME
    );

    INSERT INTO @StagingTable (
        PayerCategoryID,
        PayerCategoryDataSourceID,
        PayerCategorySourceID,
        PayerCategoryName,
        PayerCategoryIsActive,
        PayerCategoryUpdatedDatetime
    )
    SELECT *
FROM OPENQUERY([CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM],
'
    SELECT 
        CONCAT(''5~'', f.FINANCIAL_CLASS) AS PayerCategoryID,
        5 AS PayerCategoryDataSourceID,
        f.FINANCIAL_CLASS AS PayerCategorySourceID,
        f.FINANCIAL_CLASS_NAME AS PayerCategoryName,
        1 AS PayerCategoryIsActive,
        GETDATE() AS PayerCategoryUpdatedDatetime
    FROM [Clarity].[ORGFILTER].[CLARITY_FC] f
') AS fc;

    IF (SELECT COUNT(1) FROM @StagingTable) >= 10
    BEGIN
        BEGIN TRANSACTION;
            PRINT 'At least 10 records found. Proceeding to delete and reload.';

            DELETE FROM dim.PayerCategories WHERE PayerCategoryDataSourceID = 5;

            INSERT INTO dim.PayerCategories (
                PayerCategoryID,
                PayerCategoryDataSourceID,
                PayerCategorySourceID,
                PayerCategoryName,
                PayerCategoryIsActive,
                PayerCategoryUpdatedDatetime
            )
            SELECT 
                PayerCategoryID,
                PayerCategoryDataSourceID,
                PayerCategorySourceID,
                PayerCategoryName,
                PayerCategoryIsActive,
                PayerCategoryUpdatedDatetime
            FROM @StagingTable;

        COMMIT TRANSACTION;
    END
    ELSE
    BEGIN
        PRINT 'Less than 10 records in the staging table. Ending job without delete and reload...';
    END
END;

-- ############################ OPEN QUERY ##################################################
--PRINT 'Creating @StagingTable...';

--    DECLARE @StagingTable TABLE (
--        PayerCategoryID VARCHAR(50),
--        PayerCategoryDataSourceID INT,
--        PayerCategorySourceID VARCHAR(50),
--        PayerCategoryName VARCHAR(100),
--        PayerCategoryIsActive BIT,
--        PayerCategoryUpdatedDatetime DATETIME
--    );

--    INSERT INTO @StagingTable (
--        PayerCategoryID,
--        PayerCategoryDataSourceID,
--        PayerCategorySourceID,
--        PayerCategoryName,
--        PayerCategoryIsActive,
--        PayerCategoryUpdatedDatetime
--    )
--    SELECT 
--        CONCAT('5~', f.FINANCIAL_CLASS) AS PayerCategoryID,
--        5 AS PayerCategoryDataSourceID,
--        f.FINANCIAL_CLASS AS PayerCategorySourceID,
--        f.FINANCIAL_CLASS_NAME AS PayerCategoryName,
--        1 AS PayerCategoryIsActive,
--        GETDATE() AS PayerCategoryUpdatedDatetime
--    FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[CLARITY_FC] f;

--    IF (SELECT COUNT(1) FROM @StagingTable) >= 10
--    BEGIN
--        BEGIN TRANSACTION;
--            PRINT 'At least 10 records found. Proceeding to delete and reload.';

--            DELETE FROM dim.PayerCategories WHERE PayerCategoryDataSourceID = 5;

--            INSERT INTO dim.PayerCategories (
--                PayerCategoryID,
--                PayerCategoryDataSourceID,
--                PayerCategorySourceID,
--                PayerCategoryName,
--                PayerCategoryIsActive,
--                PayerCategoryUpdatedDatetime
--            )
--            SELECT 
--                PayerCategoryID,
--                PayerCategoryDataSourceID,
--                PayerCategorySourceID,
--                PayerCategoryName,
--                PayerCategoryIsActive,
--                PayerCategoryUpdatedDatetime
--            FROM @StagingTable;

--        COMMIT TRANSACTION;
--    END
--    ELSE
--    BEGIN
--        PRINT 'Less than 10 records in the staging table. Ending job without delete and reload...';
--    END
--END;
GO
