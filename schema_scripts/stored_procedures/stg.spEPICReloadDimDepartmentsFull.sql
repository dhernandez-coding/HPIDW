-- =============================================
-- Author:      Ryan Tisserand
-- Create date: 02/10/2023
-- Description: Extracts, Transforms, and Loads Department data from EPIC
-- Change Control:
--   1. 02/10/2023 - Ryan Tisserand - Initial build
--   2. 05/09/2025 - Diego Hernandez - Safe reload logic using staging + transaction
--   3. 10/29/2025 - Diego Hernandez - Modify this to OPENQUERY
--   4. 03/31/2026 - Chris Cross - Added Service Area 452000
-- =============================================

CREATE PROCEDURE [stg].[spEPICReloadDimDepartmentsFull] AS

BEGIN
    SET NOCOUNT ON;

    PRINT 'Creating @StagingTable...';
    DECLARE @StagingTable TABLE (
        DepartmentID VARCHAR(50),
        DepartmentDataSourceID INT,
        DepartmentSourceID VARCHAR(50),
        DepartmentName VARCHAR(200),
        DepartmentLocationID VARCHAR(50),
        DepartmentParentLocationID VARCHAR(50),
        DepartmentServiceAreaLocationID VARCHAR(50),
        DepartmentAbbreviation VARCHAR(50),
        DepartmentDescription VARCHAR(200),
        DepartmentStreetAddress1 VARCHAR(200),
        DepartmentStreetAddress2 VARCHAR(200),
        DepartmentCity VARCHAR(200),
        DepartmentState VARCHAR(200),
        DepartmentZipCode VARCHAR(200),
        DepartmentPhone VARCHAR(50),
        DepartmentFederalTaxID VARCHAR(20),
        DepartmentIsActive BIT,
        DepartmentUpdatedDateTime DATETIME
    );

    INSERT INTO @StagingTable (
        DepartmentID,
        DepartmentDataSourceID,
        DepartmentSourceID,
        DepartmentName,
        DepartmentLocationID,
        DepartmentParentLocationID,
        DepartmentServiceAreaLocationID,
        DepartmentAbbreviation,
        DepartmentDescription,
        DepartmentStreetAddress1,
        DepartmentStreetAddress2,
        DepartmentCity,
        DepartmentState,
        DepartmentZipCode,
        DepartmentPhone,
        DepartmentFederalTaxID,
        DepartmentIsActive,
        DepartmentUpdatedDateTime
    )
SELECT *
FROM OPENQUERY([CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM],
'
    SELECT
        ''5~'' + CAST(d.DEPARTMENT_ID AS VARCHAR(50)) AS DepartmentID,
        5 AS DepartmentDataSourceID,
        d.DEPARTMENT_ID AS DepartmentSourceID,
        d.DEPARTMENT_NAME AS DepartmentName,
        ''5~'' + CAST(l.LOC_ID AS VARCHAR(50)) AS DepartmentLocationID,
        ''5~'' + CAST(l1.LOC_ID AS VARCHAR(50)) AS DepartmentParentLocationID,
        ''5~'' + CAST(l1.SERV_AREA_ID AS VARCHAR(50)) AS DepartmentServiceAreaLocationID,
        d.DEPT_ABBREVIATION AS DepartmentAbbreviation,
        d.SPECIALTY AS DepartmentDescription,
        p.ADDRESS_LINE_1 AS DepartmentStreetAddress1,
        p.ADDRESS_LINE_2 AS DepartmentStreetAddress2,
        p.CITY AS DepartmentCity,
        s.ABBR AS DepartmentState,
        p.ZIP AS DepartmentZipCode,
        p.PHONE AS DepartmentPhone,
        '''' AS DepartmentFederalTaxID,
        1 AS DepartmentIsActive,
        GETDATE() AS DepartmentUpdatedDateTime
    FROM [Clarity].[ORGFILTER].[CLARITY_DEP] d
    LEFT JOIN [Clarity].[ORGFILTER].[CLARITY_LOC] l 
        ON d.REV_LOC_ID = l.LOC_ID
    LEFT JOIN [Clarity].[ORGFILTER].[CLARITY_LOC] l1 
        ON l1.LOC_ID = l.ADT_PARENT_ID
    LEFT JOIN [Clarity].[ORGFILTER].[CLARITY_POS] p 
        ON l.LOC_ID = p.POS_ID
    LEFT JOIN [Clarity].[ORGFILTER].[ZC_STATE] s 
        ON p.STATE_C = s.STATE_C
    WHERE d.SERV_AREA_ID IN (425, 430, 452000)
') AS dep;

    IF (SELECT COUNT(1) FROM @StagingTable) >= 10
    BEGIN
        BEGIN TRANSACTION;
            PRINT 'At least 10 records found. Proceeding to delete and reload.';
            
            DELETE FROM dim.Departments WHERE DepartmentDataSourceID = 5;

            INSERT INTO dim.Departments (
                DepartmentID,
                DepartmentDataSourceID,
                DepartmentSourceID,
                DepartmentName,
                DepartmentLocationID,
                DepartmentParentLocationID,
                DepartmentServiceAreaLocationID,
                DepartmentAbbreviation,
                DepartmentDescription,
                DepartmentStreetAddress1,
                DepartmentStreetAddress2,
                DepartmentCity,
                DepartmentState,
                DepartmentZipCode,
                DepartmentPhone,
                DepartmentFederalTaxID,
                DepartmentIsActive,
                DepartmentUpdatedDateTime
            )
            SELECT
                DepartmentID,
                DepartmentDataSourceID,
                DepartmentSourceID,
                DepartmentName,
                DepartmentLocationID,
                DepartmentParentLocationID,
                DepartmentServiceAreaLocationID,
                DepartmentAbbreviation,
                DepartmentDescription,
                DepartmentStreetAddress1,
                DepartmentStreetAddress2,
                DepartmentCity,
                DepartmentState,
                DepartmentZipCode,
                DepartmentPhone,
                DepartmentFederalTaxID,
                DepartmentIsActive,
                DepartmentUpdatedDateTime
            FROM @StagingTable;
        COMMIT TRANSACTION;
    END
    ELSE
    BEGIN
        PRINT 'Less than 10 records in the staging table. Ending job without delete and reload...';
    END
END;


-- ############################################ OLD QUERY #########################################

--    PRINT 'Creating @StagingTable...';
--    DECLARE @StagingTable TABLE (
--        DepartmentID VARCHAR(50),
--        DepartmentDataSourceID INT,
--        DepartmentSourceID VARCHAR(50),
--        DepartmentName VARCHAR(200),
--        DepartmentLocationID VARCHAR(50),
--        DepartmentParentLocationID VARCHAR(50),
--        DepartmentServiceAreaLocationID VARCHAR(50),
--        DepartmentAbbreviation VARCHAR(50),
--        DepartmentDescription VARCHAR(200),
--        DepartmentStreetAddress1 VARCHAR(200),
--        DepartmentStreetAddress2 VARCHAR(200),
--        DepartmentCity VARCHAR(200),
--        DepartmentState VARCHAR(200),
--        DepartmentZipCode VARCHAR(200),
--        DepartmentPhone VARCHAR(50),
--        DepartmentFederalTaxID VARCHAR(20),
--        DepartmentIsActive BIT,
--        DepartmentUpdatedDateTime DATETIME
--    );

--    INSERT INTO @StagingTable (
--        DepartmentID,
--        DepartmentDataSourceID,
--        DepartmentSourceID,
--        DepartmentName,
--        DepartmentLocationID,
--        DepartmentParentLocationID,
--        DepartmentServiceAreaLocationID,
--        DepartmentAbbreviation,
--        DepartmentDescription,
--        DepartmentStreetAddress1,
--        DepartmentStreetAddress2,
--        DepartmentCity,
--        DepartmentState,
--        DepartmentZipCode,
--        DepartmentPhone,
--        DepartmentFederalTaxID,
--        DepartmentIsActive,
--        DepartmentUpdatedDateTime
--    )
--    SELECT
--        '5~' + CAST(d.DEPARTMENT_ID AS VARCHAR(50)) AS DepartmentID,
--        5 AS DepartmentDataSourceID,
--        d.DEPARTMENT_ID AS DepartmentSourceID,
--        d.DEPARTMENT_NAME AS DepartmentName,
--        '5~' + CAST(l.LOC_ID AS VARCHAR(50)) AS DepartmentLocationID,
--        '5~' + CAST(l1.LOC_ID AS VARCHAR(50)) AS DepartmentParentLocationID,
--        '5~' + CAST(l1.SERV_AREA_ID AS VARCHAR(50)) AS DepartmentServiceAreaLocationID,
--        d.DEPT_ABBREVIATION AS DepartmentAbbreviation,
--        d.SPECIALTY AS DepartmentDescription,
--        p.ADDRESS_LINE_1 AS DepartmentStreetAddress1,
--        p.ADDRESS_LINE_2 AS DepartmentStreetAddress2,
--        p.CITY AS DepartmentCity,
--        s.ABBR AS DepartmentState,
--        p.ZIP AS DepartmentZipCode,
--        p.PHONE AS DepartmentPhone,
--        '' AS DepartmentFederalTaxID,
--        1 AS DepartmentIsActive,
--        GETDATE() AS DepartmentUpdatedDateTime
--    FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[CLARITY_DEP] d
--    LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[CLARITY_LOC] l ON d.REV_LOC_ID = l.LOC_ID
--    LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[CLARITY_LOC] l1 ON l1.LOC_ID = l.ADT_PARENT_ID
--    LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[CLARITY_POS] p ON l.LOC_ID = p.POS_ID
--    LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[ZC_STATE] s ON p.STATE_C = s.STATE_C
--    WHERE d.SERV_AREA_ID IN (425, 430);

--    IF (SELECT COUNT(1) FROM @StagingTable) >= 10
--    BEGIN
--        BEGIN TRANSACTION;
--            PRINT 'At least 10 records found. Proceeding to delete and reload.';
            
--            DELETE FROM dim.Departments WHERE DepartmentDataSourceID = 5;

--            INSERT INTO dim.Departments (
--                DepartmentID,
--                DepartmentDataSourceID,
--                DepartmentSourceID,
--                DepartmentName,
--                DepartmentLocationID,
--                DepartmentParentLocationID,
--                DepartmentServiceAreaLocationID,
--                DepartmentAbbreviation,
--                DepartmentDescription,
--                DepartmentStreetAddress1,
--                DepartmentStreetAddress2,
--                DepartmentCity,
--                DepartmentState,
--                DepartmentZipCode,
--                DepartmentPhone,
--                DepartmentFederalTaxID,
--                DepartmentIsActive,
--                DepartmentUpdatedDateTime
--            )
--            SELECT
--                DepartmentID,
--                DepartmentDataSourceID,
--                DepartmentSourceID,
--                DepartmentName,
--                DepartmentLocationID,
--                DepartmentParentLocationID,
--                DepartmentServiceAreaLocationID,
--                DepartmentAbbreviation,
--                DepartmentDescription,
--                DepartmentStreetAddress1,
--                DepartmentStreetAddress2,
--                DepartmentCity,
--                DepartmentState,
--                DepartmentZipCode,
--                DepartmentPhone,
--                DepartmentFederalTaxID,
--                DepartmentIsActive,
--                DepartmentUpdatedDateTime
--            FROM @StagingTable;
--        COMMIT TRANSACTION;
--    END
--    ELSE
--    BEGIN
--        PRINT 'Less than 10 records in the staging table. Ending job without delete and reload...';
--    END
--END;
GO
