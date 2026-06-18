-- =============================================
-- Author:      []
-- Create date: []
-- Description: Safe reload of Financial Class data from EPIC into dim.FinancialClasses
-- Change Control:
--   1. 05/09/2025 - Diego Hernandez - Safe load logic using staging and transaction
--   2. 10/29/2025 - Diego Hernandez - Open query load
-- =============================================

CREATE PROCEDURE [stg].[spEPICReloadDimFinancialClassesFull] AS
BEGIN
    SET NOCOUNT ON;

    PRINT 'Creating @StagingTable...';

    DECLARE @StagingTable TABLE (
        FinancialClassID VARCHAR(100),
        FinancialClassDataSourceID INT,
        FinancialClassSourceID VARCHAR(100),
        FinancialClassName VARCHAR(100),
        FinancialClassIsActive BIT,
        FinancialClassUpdatedDatetime DATETIME
    );

    INSERT INTO @StagingTable (
        FinancialClassID,
        FinancialClassDataSourceID,
        FinancialClassSourceID,
        FinancialClassName,
        FinancialClassIsActive,
        FinancialClassUpdatedDatetime
    )
    SELECT *
	FROM OPENQUERY([CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM],
	'
	    SELECT 
	        CONCAT(''5~'', f.FINANCIAL_CLASS) AS FinancialClassID,
	        5 AS FinancialClassDataSourceID,
	        f.FINANCIAL_CLASS AS FinancialClassSourceID,
	        f.FINANCIAL_CLASS_NAME AS FinancialClassName,
	        1 AS FinancialClassIsActive,
	        GETDATE() AS FinancialClassUpdatedDatetime
	    FROM [Clarity].[ORGFILTER].[CLARITY_FC] f
	') AS fc;

    IF (SELECT COUNT(1) FROM @StagingTable) >= 10
    BEGIN
        BEGIN TRANSACTION;
            PRINT 'At least 10 records found. Proceeding to delete and reload.';

            DELETE FROM dim.FinancialClasses WHERE FinancialClassDataSourceID = 5;

            INSERT INTO dim.FinancialClasses (
                FinancialClassID,
                FinancialClassDataSourceID,
                FinancialClassSourceID,
                FinancialClassName,
                FinancialClassIsActive,
                FinancialClassUpdatedDatetime
            )
            SELECT 
                FinancialClassID,
                FinancialClassDataSourceID,
                FinancialClassSourceID,
                FinancialClassName,
                FinancialClassIsActive,
                FinancialClassUpdatedDatetime
            FROM @StagingTable;

        COMMIT TRANSACTION;
    END
    ELSE
    BEGIN
        PRINT 'Less than 10 records in the staging table. Ending job without delete and reload...';
    END
END;


-- ########################################### OLD QUERY #############################################
--PRINT 'Creating @StagingTable...';

--    DECLARE @StagingTable TABLE (
--        FinancialClassID VARCHAR(100),
--        FinancialClassDataSourceID INT,
--        FinancialClassSourceID VARCHAR(100),
--        FinancialClassName VARCHAR(100),
--        FinancialClassIsActive BIT,
--        FinancialClassUpdatedDatetime DATETIME
--    );

--    INSERT INTO @StagingTable (
--        FinancialClassID,
--        FinancialClassDataSourceID,
--        FinancialClassSourceID,
--        FinancialClassName,
--        FinancialClassIsActive,
--        FinancialClassUpdatedDatetime
--    )
--    SELECT 
--        CONCAT('5~', f.FINANCIAL_CLASS) AS FinancialClassID,
--        5 AS FinancialClassDataSourceID,
--        f.FINANCIAL_CLASS AS FinancialClassSourceID,
--        f.FINANCIAL_CLASS_NAME AS FinancialClassName,
--        1 AS FinancialClassIsActive,
--        GETDATE() AS FinancialClassUpdatedDatetime
--    FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[CLARITY_FC] f;

--    IF (SELECT COUNT(1) FROM @StagingTable) >= 10
--    BEGIN
--        BEGIN TRANSACTION;
--            PRINT 'At least 10 records found. Proceeding to delete and reload.';

--            DELETE FROM dim.FinancialClasses WHERE FinancialClassDataSourceID = 5;

--            INSERT INTO dim.FinancialClasses (
--                FinancialClassID,
--                FinancialClassDataSourceID,
--                FinancialClassSourceID,
--                FinancialClassName,
--                FinancialClassIsActive,
--                FinancialClassUpdatedDatetime
--            )
--            SELECT 
--                FinancialClassID,
--                FinancialClassDataSourceID,
--                FinancialClassSourceID,
--                FinancialClassName,
--                FinancialClassIsActive,
--                FinancialClassUpdatedDatetime
--            FROM @StagingTable;

--        COMMIT TRANSACTION;
--    END
--    ELSE
--    BEGIN
--        PRINT 'Less than 10 records in the staging table. Ending job without delete and reload...';
--    END
--END;
GO
