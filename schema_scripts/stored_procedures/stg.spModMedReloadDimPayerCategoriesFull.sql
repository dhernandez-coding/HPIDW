-- =============================================
-- Author:        Diego Hernandez
-- Create date:   01/29/2026
-- Description:  Loads Payer Categories from ModMed into dim.PayerCategories
-- DataSourceID: 15 (ModMed)
-- =============================================
CREATE   PROCEDURE [stg].[spModMedReloadDimPayerCategoriesFull] AS
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

    PRINT 'Loading data from stg.ModMed_Financial_Category...';

    INSERT INTO @StagingTable (
        PayerCategoryID,
        PayerCategoryDataSourceID,
        PayerCategorySourceID,
        PayerCategoryName,
        PayerCategoryIsActive,
        PayerCategoryUpdatedDatetime
    )
    SELECT
        CONCAT('15~', financial_category_id) AS PayerCategoryID,
        15                                   AS PayerCategoryDataSourceID,
        financial_category_id               AS PayerCategorySourceID,
        category_name                       AS PayerCategoryName,
        ISNULL(active, 1)                   AS PayerCategoryIsActive,
        GETDATE()                           AS PayerCategoryUpdatedDatetime
	  FROM stg.ModMed_Financial_Category;

    PRINT 'Checking row count...';

    IF (SELECT COUNT(1) FROM @StagingTable) >= 5
    BEGIN
        BEGIN TRANSACTION;

            PRINT 'At least 10 records found. Proceeding to delete and reload.';

            DELETE
            FROM dim.PayerCategories
            WHERE PayerCategoryDataSourceID = 15;

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
GO
