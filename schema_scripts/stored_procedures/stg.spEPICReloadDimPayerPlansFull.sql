-- =============================================
-- Author:		Chris Cross
-- Create date: 03/14/2023
-- Description:	Extracts, Transforms and Loads Payer Plan Data from EPIC Source System into a dim Table
-- Change Control
--	1. 03/14/2023 - Chris Cross - Initial build of procedure
--  2. 05/09/2025 - Diego Hernandez - Safe load
--  3. 10/29/2025 - Diego Hernandez - Open query
-- =============================================
CREATE PROCEDURE [stg].[spEPICReloadDimPayerPlansFull] AS
BEGIN
    SET NOCOUNT ON;

    PRINT 'Creating @StagingTable...';

    DECLARE @StagingTable TABLE (
        PayerPlanID VARCHAR(50),
        PayerPlanDataSourceID INT,
        PayerPlanSourceID VARCHAR(50),
        PayerID VARCHAR(50),
        PayerPlanName VARCHAR(100),
        PayerPlanContractNumber VARCHAR(50),
        PayerPlanIsActive BIT,
        PayerPlanUpdatedDatetime DATETIME
    );

    -- Add Self-Pay record
    INSERT INTO @StagingTable (
        PayerPlanID,
        PayerPlanDataSourceID,
        PayerPlanSourceID,
        PayerID,
        PayerPlanName,
        PayerPlanContractNumber,
        PayerPlanIsActive,
        PayerPlanUpdatedDatetime
    )
    VALUES (
        '5~0' -- PayerPlanID
		,5 -- PayerPlanDataSourceID
		,'0' --  PayerPlanSourceID
		,'5~0' -- PayerID
		,'Self-Pay' -- PayerPlanName
		,NULL -- PayerPlanContractNumber
		,1 -- PayerPlanIsActive
		,GETDATE() -- PayerPlanUpdatedDatetime
    );

    -- Load from EPIC
    INSERT INTO @StagingTable (
        PayerPlanID,
        PayerPlanDataSourceID,
        PayerPlanSourceID,
        PayerID,
        PayerPlanName,
        PayerPlanContractNumber,
        PayerPlanIsActive,
        PayerPlanUpdatedDatetime
    )
SELECT *
FROM OPENQUERY([CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM],
'
    SELECT 
        CONCAT(''5~'', p.BENEFIT_PLAN_ID) AS BenefitPlanID,
        5 AS BenefitPlanDataSourceID,
        p.BENEFIT_PLAN_ID AS BenefitPlanSourceID,
        CONCAT(''5~'', p.PAYOR_ID) AS BenefitPlanPayorID,
        p.BENEFIT_PLAN_NAME AS BenefitPlanName,
        NULL AS BenefitPlanDescription,
        1 AS BenefitPlanIsActive,
        GETDATE() AS BenefitPlanUpdatedDateTime
    FROM [Clarity].[ORGFILTER].[CLARITY_EPP] p
    WHERE p.PAYOR_ID IS NOT NULL
    -- AND p.BENEFIT_PLAN_NAME LIKE ''%WEB TPA%''
') AS epp;

    -- Safe check before delete + reload
    IF (SELECT COUNT(1) FROM @StagingTable) >= 10
    BEGIN
        BEGIN TRANSACTION;
            PRINT 'At least 10 records found. Proceeding to delete and reload.';

            DELETE FROM dim.PayerPlans WHERE PayerPlanDataSourceID = 5;

            INSERT INTO dim.PayerPlans (
                PayerPlanID,
                PayerPlanDataSourceID,
                PayerPlanSourceID,
                PayerID,
                PayerPlanName,
                PayerPlanContractNumber,
                PayerPlanIsActive,
                PayerPlanUpdatedDatetime
            )
            SELECT 
                PayerPlanID,
                PayerPlanDataSourceID,
                PayerPlanSourceID,
                PayerID,
                PayerPlanName,
                PayerPlanContractNumber,
                PayerPlanIsActive,
                PayerPlanUpdatedDatetime
            FROM @StagingTable;
        COMMIT TRANSACTION;
    END
    ELSE
    BEGIN
        PRINT 'Less than 10 records in the staging table. Ending job without delete and reload...';
    END
END;

-- ################################# OPEN QUERY ##################################################
--PRINT 'Creating @StagingTable...';

--    DECLARE @StagingTable TABLE (
--        PayerPlanID VARCHAR(50),
--        PayerPlanDataSourceID INT,
--        PayerPlanSourceID VARCHAR(50),
--        PayerID VARCHAR(50),
--        PayerPlanName VARCHAR(100),
--        PayerPlanContractNumber VARCHAR(50),
--        PayerPlanIsActive BIT,
--        PayerPlanUpdatedDatetime DATETIME
--    );

--    -- Add Self-Pay record
--    INSERT INTO @StagingTable (
--        PayerPlanID,
--        PayerPlanDataSourceID,
--        PayerPlanSourceID,
--        PayerID,
--        PayerPlanName,
--        PayerPlanContractNumber,
--        PayerPlanIsActive,
--        PayerPlanUpdatedDatetime
--    )
--    VALUES (
--        '5~0' -- PayerPlanID
--		,5 -- PayerPlanDataSourceID
--		,'0' --  PayerPlanSourceID
--		,'5~0' -- PayerID
--		,'Self-Pay' -- PayerPlanName
--		,NULL -- PayerPlanContractNumber
--		,1 -- PayerPlanIsActive
--		,GETDATE() -- PayerPlanUpdatedDatetime
--    );

--    -- Load from EPIC
--    INSERT INTO @StagingTable (
--        PayerPlanID,
--        PayerPlanDataSourceID,
--        PayerPlanSourceID,
--        PayerID,
--        PayerPlanName,
--        PayerPlanContractNumber,
--        PayerPlanIsActive,
--        PayerPlanUpdatedDatetime
--    )
--    SELECT 
--        CONCAT('5~', p.BENEFIT_PLAN_ID),
--        5,
--        p.BENEFIT_PLAN_ID,
--        CONCAT('5~', p.PAYOR_ID),
--        p.BENEFIT_PLAN_NAME,
--        NULL,
--        1,
--        GETDATE()
--    FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[CLARITY_EPP] p
--	--LEFT JOIN [100.65.16.149].[CLARITY].[ORGFILTER].[CLARITY_EPM] py on py.PAYOR_ID = p.PAYOR_ID
--    WHERE p.PAYOR_ID IS NOT NULL;
--	 --and p.BENEFIT_PLAN_NAME like '%WEB TPA%'

--    -- Safe check before delete + reload
--    IF (SELECT COUNT(1) FROM @StagingTable) >= 10
--    BEGIN
--        BEGIN TRANSACTION;
--            PRINT 'At least 10 records found. Proceeding to delete and reload.';

--            DELETE FROM dim.PayerPlans WHERE PayerPlanDataSourceID = 5;

--            INSERT INTO dim.PayerPlans (
--                PayerPlanID,
--                PayerPlanDataSourceID,
--                PayerPlanSourceID,
--                PayerID,
--                PayerPlanName,
--                PayerPlanContractNumber,
--                PayerPlanIsActive,
--                PayerPlanUpdatedDatetime
--            )
--            SELECT 
--                PayerPlanID,
--                PayerPlanDataSourceID,
--                PayerPlanSourceID,
--                PayerID,
--                PayerPlanName,
--                PayerPlanContractNumber,
--                PayerPlanIsActive,
--                PayerPlanUpdatedDatetime
--            FROM @StagingTable;
--        COMMIT TRANSACTION;
--    END
--    ELSE
--    BEGIN
--        PRINT 'Less than 10 records in the staging table. Ending job without delete and reload...';
--    END
--END;
GO
