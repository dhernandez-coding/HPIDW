-- =============================================
-- Author:		Ryan Tisserand
-- ALTER PROCEDURE24/2023
-- Description:	Extracts, Transforms and Loads Provider Data from EPIC Source System into a dim Table
-- Change Control
--	1. 02/24/2023 - Ryan Tisserand - Initial build of procedure
--	2. 06/24/2024 - Robert Beaird - Brought in Provider Title
--  3. 05/09/2025 - Diego Hernandez - Safe load
-- =============================================
CREATE   PROCEDURE [stg].[spEPICReloadDimProvidersFull] AS

BEGIN
SET NOCOUNT ON;



    DECLARE @StagingTable TABLE (
        ProviderID VARCHAR(50),
        ProviderDataSourceID INT,
        ProviderSourceID VARCHAR(50),
        ProviderAbbreviation VARCHAR(50),
        ProviderFirstName VARCHAR(100),
        ProviderMiddleInitial VARCHAR(50),
        ProviderLastName VARCHAR(100),
        ProviderGender VARCHAR(50),
        ProviderSuffix VARCHAR(50),
        ProviderStreetAddress1 VARCHAR(100),
        ProviderStreetAddress2 VARCHAR(100),
        ProviderCity VARCHAR(50),
        ProviderState VARCHAR(50),
        ProviderZipCode VARCHAR(50),
        ProviderPhone VARCHAR(50),
        ProviderFax VARCHAR(50),
        ProviderSpecialtyID VARCHAR(50),
        ProviderUPIN VARCHAR(50),
        ProviderNPI VARCHAR(50),
        ProviderIsActive BIT,
        ProviderUpdatedDateTime DATETIME
    );

    INSERT INTO @StagingTable (
        ProviderID,
        ProviderDataSourceID,
        ProviderSourceID,
        ProviderAbbreviation,
        ProviderFirstName,
        ProviderMiddleInitial,
        ProviderLastName,
        ProviderGender,
        ProviderSuffix,
        ProviderStreetAddress1,
        ProviderStreetAddress2,
        ProviderCity,
        ProviderState,
        ProviderZipCode,
        ProviderPhone,
        ProviderFax,
        ProviderSpecialtyID,
        ProviderUPIN,
        ProviderNPI,
        ProviderIsActive,
        ProviderUpdatedDateTime
    )

SELECT *
FROM OPENQUERY([CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM],
'
    SELECT 
        ''5~'' + CAST(p.PROV_ID AS VARCHAR(50)) AS ProviderID,
        5 AS ProviderDataSourceID,
        p.PROV_ID AS ProviderSourceID,
        CONVERT(VARCHAR(50), p.PROV_ABBR) AS ProviderAbbreviation,
        CASE 
            WHEN LEN(p.PROV_NAME) - LEN(REPLACE(p.PROV_NAME, '' '', '''')) = 2 
                THEN SUBSTRING(p.PROV_NAME, CHARINDEX('' '', p.PROV_NAME) + 1, 
                    (CHARINDEX('' '', p.PROV_NAME, (CHARINDEX('' '', p.PROV_NAME, 1)) + 1)) 
                    - CHARINDEX('' '', p.PROV_NAME) - 1)
            ELSE RIGHT(p.PROV_NAME, 
                CASE WHEN LEN(p.PROV_NAME) - CHARINDEX('' '', p.PROV_NAME) >= 1 
                    THEN LEN(p.PROV_NAME) - CHARINDEX('' '', p.PROV_NAME) 
                    ELSE 0 END)
        END AS ProviderFirstName,
        CASE 
            WHEN LEN(p.PROV_NAME) - LEN(REPLACE(p.PROV_NAME, '' '', '''')) = 2 
                THEN RIGHT(p.PROV_NAME, 1)
            ELSE ''''
        END AS ProviderMiddleInitial,
        REPLACE(REPLACE(SUBSTRING(p.PROV_NAME, 1, CHARINDEX('' '', p.PROV_NAME)), '','', ''''), '' '', '''') AS ProviderLastName,
        x.ABBR AS ProviderGender,
        p.CLINICIAN_TITLE AS ProviderSuffix,
        a.ADDR_LINE_1 AS ProviderStreetAddress1,
        a.ADDR_LINE_2 AS ProviderStreetAddress2,
        a.CITY AS ProviderCity,
        t.ABBR AS ProviderState,
        a.ZIP AS ProviderZipCode,
        p.OFFICE_PHONE_NUM AS ProviderPhone,
        p.OFFICE_FAX_NUM AS ProviderFax,
        CASE WHEN si.SPECIALTY_C IS NOT NULL THEN CONCAT(''5~'', si.SPECIALTY_C) END AS ProviderSpecialtyID,
        p.UPIN AS ProviderUPIN,
        pa.NPI AS ProviderNPI,
        CASE WHEN p.ACTIVE_STATUS = ''Active'' THEN 1 ELSE 0 END AS ProviderIsActive,
        GETDATE() AS ProviderUpdatedDateTime
    FROM [Clarity].[ORGFILTER].[CLARITY_SER] p
    LEFT JOIN [Clarity].[ORGFILTER].[CLARITY_SER_2] pa 
        ON p.PROV_ID = pa.PROV_ID
    LEFT JOIN [Clarity].[ORGFILTER].[CLARITY_SER_ADDR] a 
        ON p.PROV_ID = a.PROV_ID 
        AND a.PRIMARY_ADDR_YN = ''Y''
    LEFT JOIN [Clarity].[ORGFILTER].[CLARITY_SER_SPEC] si 
        ON p.PROV_ID = si.PROV_ID 
        AND si.LINE = 1
    LEFT JOIN [Clarity].[ORGFILTER].[ZC_SEX] x 
        ON p.SEX_C = x.RCPT_MEM_SEX_C
    LEFT JOIN [Clarity].[ORGFILTER].[ZC_STATE] t 
        ON a.STATE_C = t.STATE_C
    LEFT JOIN [Clarity].[ORGFILTER].[ZC_STAFF_RESOURCE] r 
        ON p.STAFF_RESOURCE_C = r.STAFF_RESOURCE_C
') AS providers;
 IF (SELECT COUNT(1) FROM @StagingTable) >= 10
    BEGIN
        BEGIN TRANSACTION;
            PRINT 'At least 10 records found. Proceeding to delete and reload.';
            
            DELETE FROM dim.Providers WHERE ProviderDataSourceID = 5;

            INSERT INTO dim.Providers (
                ProviderID,
                ProviderDataSourceID,
                ProviderSourceID,
                ProviderAbbreviation,
                ProviderFirstName,
                ProviderMiddleInitial,
                ProviderLastName,
                ProviderGender,
                ProviderSuffix,
                ProviderStreetAddress1,
                ProviderStreetAddress2,
                ProviderCity,
                ProviderState,
                ProviderZipCode,
                ProviderPhone,
                ProviderFax,
                ProviderSpecialtyID,
                ProviderUPIN,
                ProviderNPI,
                ProviderIsActive,
                ProviderUpdatedDateTime
            )
            SELECT 
                ProviderID,
                ProviderDataSourceID,
                ProviderSourceID,
                ProviderAbbreviation,
                ProviderFirstName,
                ProviderMiddleInitial,
                ProviderLastName,
                ProviderGender,
                ProviderSuffix,
                ProviderStreetAddress1,
                ProviderStreetAddress2,
                ProviderCity,
                ProviderState,
                ProviderZipCode,
                ProviderPhone,
                ProviderFax,
                ProviderSpecialtyID,
                ProviderUPIN,
                ProviderNPI,
                ProviderIsActive,
                ProviderUpdatedDateTime
            FROM @StagingTable;
        COMMIT TRANSACTION;
    END
    ELSE
    BEGIN
        PRINT 'Less than 10 provider records found. Skipping delete and reload.';
    END
END;


-- ################################## OPEN QUERY ############################################
-- DECLARE @StagingTable TABLE (
--        ProviderID VARCHAR(50),
--        ProviderDataSourceID INT,
--        ProviderSourceID VARCHAR(50),
--        ProviderAbbreviation VARCHAR(50),
--        ProviderFirstName VARCHAR(100),
--        ProviderMiddleInitial VARCHAR(50),
--        ProviderLastName VARCHAR(100),
--        ProviderGender VARCHAR(50),
--        ProviderSuffix VARCHAR(50),
--        ProviderStreetAddress1 VARCHAR(100),
--        ProviderStreetAddress2 VARCHAR(100),
--        ProviderCity VARCHAR(50),
--        ProviderState VARCHAR(50),
--        ProviderZipCode VARCHAR(50),
--        ProviderPhone VARCHAR(50),
--        ProviderFax VARCHAR(50),
--        ProviderSpecialtyID VARCHAR(50),
--        ProviderUPIN VARCHAR(50),
--        ProviderNPI VARCHAR(50),
--        ProviderIsActive BIT,
--        ProviderUpdatedDateTime DATETIME
--    );

--    INSERT INTO @StagingTable (
--        ProviderID,
--        ProviderDataSourceID,
--        ProviderSourceID,
--        ProviderAbbreviation,
--        ProviderFirstName,
--        ProviderMiddleInitial,
--        ProviderLastName,
--        ProviderGender,
--        ProviderSuffix,
--        ProviderStreetAddress1,
--        ProviderStreetAddress2,
--        ProviderCity,
--        ProviderState,
--        ProviderZipCode,
--        ProviderPhone,
--        ProviderFax,
--        ProviderSpecialtyID,
--        ProviderUPIN,
--        ProviderNPI,
--        ProviderIsActive,
--        ProviderUpdatedDateTime
--    )

--select 
--	'5~' + cast(p.PROV_ID as varchar(50)) ProviderID,
--	5 ProviderDataSourceID,
--	p.PROV_ID ProviderSourceID, 
--	convert(varchar(50),p.PROV_ABBR) ProviderAbbreviation,
--	case when len(p.PROV_NAME) - len(replace(p.PROV_NAME,' ','')) = 2
--		then substring(p.PROV_NAME,charindex(' ',p.PROV_NAME)+1,(charindex(' ',p.PROV_NAME, (charindex(' ',p.PROV_NAME,1))+1)) - charindex(' ',p.PROV_NAME)-1)
--		else right(p.PROV_NAME,CASE WHEN len(p.PROV_NAME) - charindex(' ',p.PROV_NAME) >= 1 THEN len(p.PROV_NAME) - charindex(' ',p.PROV_NAME) ELSE 0 END)
--	end ProviderFirstName,
--	case when len(p.PROV_NAME) - len(replace(p.PROV_NAME,' ','')) = 2
--		then right(p.PROV_NAME,1)
--		else ''
--	end ProviderMiddleInitial,
--	replace(replace(substring(p.PROV_NAME,1,charindex(' ',p.PROV_NAME)),',',''),' ','') ProviderLastName,
--	x.ABBR ProviderGender, 
--	p.CLINICIAN_TITLE ProviderSuffix, 
--	a.addr_line_1 ProvderStreetAddress1, 
--	a.addr_line_2 ProviderStreetAddress2, 
--	a.CITY ProviderCity, 
--	t.ABBR ProviderState, 
--	a.ZIP ProviderZipCode,
--	p.OFFICE_PHONE_NUM ProviderPhone, 
--	p.OFFICE_FAX_NUM ProviderFax, 
--	CASE WHEN si.SPECIALTY_C is not null THEN CONCAT('5~',si.SPECIALTY_C) END ProviderSpecialtyID,
--	p.UPIN ProviderUPIN, 
--	pa.NPI ProviderNPI,
--	case when p.ACTIVE_STATUS = 'Active' then 1 else 0 end ProviderIsActive,
--	getdate() ProviderUpdatedDateTime
--	from [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[CLARITY_SER] p
--	left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[CLARITY_SER_2] pa on p.PROV_ID = pa.PROV_ID
--	left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[CLARITY_SER_ADDR] a on p.PROV_ID = a.PROV_ID and a.PRIMARY_ADDR_YN = 'Y'
--	left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[CLARITY_SER_SPEC] si on p.PROV_ID = si.PROV_ID and si.line = 1
--	--left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[ZC_SPECIALTY] s on si.SPECIALTY_C = s.SPECIALTY_C
--	left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[ZC_SEX] x on p.SEX_C = x.RCPT_MEM_SEX_C 
--	left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[ZC_STATE] t on a.STATE_C = t.STATE_C
--	left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[ZC_STAFF_RESOURCE] r on p.STAFF_RESOURCE_C = r.STAFF_RESOURCE_C
-- IF (SELECT COUNT(1) FROM @StagingTable) >= 10
--    BEGIN
--        BEGIN TRANSACTION;
--            PRINT 'At least 10 records found. Proceeding to delete and reload.';
            
--            DELETE FROM dim.Providers WHERE ProviderDataSourceID = 5;

--            INSERT INTO dim.Providers (
--                ProviderID,
--                ProviderDataSourceID,
--                ProviderSourceID,
--                ProviderAbbreviation,
--                ProviderFirstName,
--                ProviderMiddleInitial,
--                ProviderLastName,
--                ProviderGender,
--                ProviderSuffix,
--                ProviderStreetAddress1,
--                ProviderStreetAddress2,
--                ProviderCity,
--                ProviderState,
--                ProviderZipCode,
--                ProviderPhone,
--                ProviderFax,
--                ProviderSpecialtyID,
--                ProviderUPIN,
--                ProviderNPI,
--                ProviderIsActive,
--                ProviderUpdatedDateTime
--            )
--            SELECT 
--                ProviderID,
--                ProviderDataSourceID,
--                ProviderSourceID,
--                ProviderAbbreviation,
--                ProviderFirstName,
--                ProviderMiddleInitial,
--                ProviderLastName,
--                ProviderGender,
--                ProviderSuffix,
--                ProviderStreetAddress1,
--                ProviderStreetAddress2,
--                ProviderCity,
--                ProviderState,
--                ProviderZipCode,
--                ProviderPhone,
--                ProviderFax,
--                ProviderSpecialtyID,
--                ProviderUPIN,
--                ProviderNPI,
--                ProviderIsActive,
--                ProviderUpdatedDateTime
--            FROM @StagingTable;
--        COMMIT TRANSACTION;
--    END
--    ELSE
--    BEGIN
--        PRINT 'Less than 10 provider records found. Skipping delete and reload.';
--    END
--END;
GO
