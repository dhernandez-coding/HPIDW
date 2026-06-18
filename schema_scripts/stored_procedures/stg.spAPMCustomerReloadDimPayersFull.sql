-- =============================================
-- Author:		Eric Silvestri
-- Create date: 09/15/2025
-- Description:	Extracts, Transforms and Loads Payer Data from APM Source System into a dim Table
-- Change Control

-- =============================================
CREATE PROCEDURE [stg].[spAPMCustomerReloadDimPayersFull]
AS
BEGIN
SET NOCOUNT OFF;

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

	--Insert one row for NULL values from source system
	INSERT INTO @StagingTable 
		(PayerID
		,PayerDataSourceID
		,PayerSourceID
		,PayerGroupID
		,PayerCategoryID
		,PayerName
		,PayerAbbreviation)
		
		select '12~SELF',12,'SELF','0~7','12~-1','Self-Pay','Self-Pay'

    -- Load payer data from APM
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
 select 
		CONCAT('12~',cast(p.Carrier_ID as varchar(50))) AS PayerID,
		12 as PayerDataSourceID,
		p.Carrier_ID PayerSourceID,
		pg.PayerGroupID PayerGroupID,
		'12~' + cast(p.Insurance_Category_ID as varchar(50)) PayerCategoryID,
		p.[Name] PayerName,
		p.Abbreviation PayerAbbreviation,
		p.Street1 PayerStreetAddress1,
		p.Street2 PayerStreetAddres2,
		p.[City] PayerCity,
		p.[State] PayerState,
		p.Zip_Code PayerZipCode,
		1 PayerIsActive,
		getdate() PayerUpdatedDateTime
	from  [TIEVMDB03].Ntier_HPI_Customers.[PM].Carriers p
		left join dim.PayerCategories pc ON pc.PayerCategoryID = ('12~' + cast(p.Insurance_Category_ID as varchar(50)))
		left join map.PayerGroupPayerCategories pg ON pg.PayerCategoryID = pc.PayerCategoryID

    -- Proceed only if enough data was returned
    IF (SELECT COUNT(1) FROM @StagingTable) >= 10
    BEGIN
        BEGIN TRANSACTION;
            PRINT 'At least 10 records found. Proceeding to delete and reload.';

            DELETE FROM dim.Payers WHERE PayerDataSourceID = 12;

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

END

--select * from fact.TransactionsPB t where t.TransactionID = '12~1060904'
--select * from dim.Payers p where p.PayerID = '12~8485'
GO
