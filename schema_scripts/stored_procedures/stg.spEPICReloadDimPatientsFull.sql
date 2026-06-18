-- =============================================
-- Author:		Ryan Tisserand
-- Create date: 02/17/2023
-- Description:	Extracts, Transforms and Loads Patient Data from EPIC Source System into a dim Table
-- Change Control
--	1. 02/10/2023 - Ryan Tisserand - Initial build of procedure
--  2. 08/10/2023 - Zeke Herrera   - Changed Linked server from 100.65.16.148 to [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM]
--  3. 09/03/2024 - Chris Cross - Added [PatientMaritalStatus], [PatientEthnicity], [PatientLanguage] and updated PatientGender column
--  4. 09/27/2024 - Eric Silvestri - Added join to OTHER_COMMUNIC to bring in the PatientMobilePhone 
--  5. 02/04/2025 - Diego Hernandez - Added Medicare number
--  6. 05/09/2025 - Diego Hernandez - Added safe load
--  7. 10/29/2025 - Diego Hernandez - Added openquery
--  8. 06/02/2026 - Chris Cross - Added subquery to pull 425000 service area records not included in ORGFILTER
-- =============================================
CREATE PROCEDURE [stg].[spEPICReloadDimPatientsFull] AS
BEGIN
SET NOCOUNT OFF;



    PRINT 'Creating @StagingTable...';
	
	DECLARE @StagingTable TABLE (
        PatientID VARCHAR(50),
        PatientDataSourceID INT,
        PatientSourceID VARCHAR(50),
        PatientMRN VARCHAR(50),
        PatientFirstName VARCHAR(100),
        PatientMiddleInitial VARCHAR(10),
        PatientLastName VARCHAR(100),
        PatientFullName VARCHAR(100),
        PatientGender VARCHAR(10),
        PatientDateOfBirth DATETIME,
        PatientSSN VARCHAR(50),
        PatientHomePhone NVARCHAR(30),
        PatientWorkPhone NVARCHAR(30),
        PatientWorkPhoneExtension VARCHAR(50),
        PatientMobilePhone VARCHAR(30),
        PatientEmailAddress VARCHAR(100),
        PatientStreetAddress1 VARCHAR(50),
        PatientStreetAddress2 VARCHAR(50),
        PatientCity VARCHAR(50),
        PatientState VARCHAR(50),
        PatientZipCode VARCHAR(50),
        PatientMaritalStatus VARCHAR(50),
        PatientEthnicity VARCHAR(50),
        PatientLanguage VARCHAR(50),
        PatientIsActive BIT,
        PatientUpdatedDateTime DATETIME,
        PatientMedicareNumber VARCHAR(150)
    );

	INSERT INTO @StagingTable (
        PatientID,
        PatientDataSourceID,
        PatientSourceID,
        PatientMRN,
        PatientFirstName,
        PatientMiddleInitial,
        PatientLastName,
        PatientFullName,
        PatientGender,
        PatientDateOfBirth,
        PatientSSN,
        PatientHomePhone,
        PatientWorkPhone,
        PatientWorkPhoneExtension,
        PatientMobilePhone,
        PatientEmailAddress,
        PatientStreetAddress1,
        PatientStreetAddress2,
        PatientCity,
        PatientState,
        PatientZipCode,
        PatientMaritalStatus,
        PatientEthnicity,
        PatientLanguage,
        PatientIsActive,
        PatientUpdatedDateTime,
        PatientMedicareNumber
    )


SELECT *
FROM OPENQUERY([CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM],
'
    SELECT
        ''5~'' + p.PAT_ID AS PatientID,
        5 AS PatientDataSourceID,
        p.PAT_ID AS PatientSourceID,
        p.PAT_MRN_ID AS PatientMRN,
        p.PAT_FIRST_NAME AS PatientFirstName,
        LEFT(p.PAT_MIDDLE_NAME, 1) AS PatientMiddleInitial,
        p.PAT_LAST_NAME AS PatientLastName,
        p.PAT_NAME AS PatientFullName,
        sx.NAME AS PatientGender,
        p.BIRTH_DATE AS PatientDateOfBirth,
        p.SSN AS PatientSSN,
        p.HOME_PHONE AS PatientHomePhone,
        p.WORK_PHONE AS PatientWorkPhone,
        '''' AS PatientWorkPhoneExtension,
        c.OTHER_COMMUNIC_NUM AS PatientMobilePhone,
        p.EMAIL_ADDRESS AS PatientEmailAddress,
        p.ADD_LINE_1 AS PatientStreetAddress1,
        p.ADD_LINE_2 AS PatientStreetAddress2,
        p.CITY AS PatientCity,
        s.ABBR AS PatientState,
        p.ZIP AS PatientZipCode,
        ms.NAME AS PatientMaritalStatus,
        eg.NAME AS PatientEthnicity,
        l.NAME AS PatientLanguage,
        p.PAT_STATUS_C AS PatientIsActive, /* Lookup in ZC_PATIENT_STATUS: Alive or Deceased */
        GETDATE() AS PatientUpdatedDateTime,
        COALESCE(p.MEDICARE_NUM, p.MEDICAID_NUM) AS PatientMedicareNumber
    FROM (SELECT
			sub.PAT_ID
		  FROM (
			select 
				pe.PAT_ID
			from [Clarity].[dbo].[PAT_ENC] pe 
				left join [Clarity].[dbo].CLARITY_DEP d ON d.DEPARTMENT_ID = pe.DEPARTMENT_ID
			where 1=1 
				AND d.SERV_AREA_ID IN (452000)
			group by 
				pe.PAT_ID
																	
			UNION ALL 
			
			select 
				p.PAT_ID
			from [Clarity].[orgfilter].[PATIENT] P
			) sub
		  GROUP BY 
			sub.PAT_ID
		) patlist	
	INNER JOIN [Clarity].[dbo].[PATIENT] p ON p.PAT_ID = patlist.PAT_ID
    LEFT JOIN [Clarity].[dbo].[ZC_STATE] s ON p.STATE_C = s.STATE_C
    LEFT JOIN [Clarity].[dbo].[ZC_SEX] sx ON sx.RCPT_MEM_SEX_C = p.SEX_C
    LEFT JOIN [Clarity].[dbo].[ZC_MARITAL_STATUS] ms ON ms.MARITAL_STATUS_C = p.MARITAL_STATUS_C
    LEFT JOIN [Clarity].[dbo].[ZC_ETHNIC_GROUP] eg ON eg.ETHNIC_GROUP_C = p.ETHNIC_GROUP_C
    LEFT JOIN [Clarity].[dbo].[ZC_LANGUAGE] l ON l.LANGUAGE_C = p.LANGUAGE_C
    LEFT JOIN (
        SELECT 
            zc.NAME,
            ROW_NUMBER() OVER (PARTITION BY c.PAT_ID ORDER BY c.CONTACT_PRIORITY ASC) AS RowNumber,
            c.*
        FROM [Clarity].[dbo].[OTHER_COMMUNCTN] c
			LEFT JOIN [Clarity].[DBO].[ZC_OTHER_COMMUNIC] zc ON zc.OTHER_COMMUNIC_C = c.OTHER_COMMUNIC_C
        WHERE c.OTHER_COMMUNIC_C = 1 /* Mobile */
    ) c 
        ON c.PAT_ID = p.PAT_ID 
       AND c.RowNumber = 1
	WHERE 1=1
		--AND p.PAT_ID = ''Z2620860''
') AS pat

	    IF (SELECT COUNT(1) FROM @StagingTable) >= 10
    BEGIN
        BEGIN TRANSACTION;
            PRINT 'At least 10 patient records found. Proceeding to delete and reload.';
            DELETE FROM dim.Patients WHERE PatientDataSourceID = 5;

			insert into dim.Patients(
			PatientID,
			PatientDataSourceID,
			PatientSourceID,
			PatientMRN,
			PatientFirstName,
			PatientMiddleInitial,
			PatientLastName,
			PatientFullName,
			PatientGender,
			PatientDateOfBirth,
			PatientSSN,
			PatientHomePhone,
			PatientWorkPhone,
			PatientWorkPhoneExtension,
			PatientMobilePhone,
			PatientEmailAddress,
			PatientStreetAddress1,
			PatientStreetAddress2,
			PatientCity,
			PatientState,
			PatientZipCode,
			[PatientMaritalStatus],
			[PatientEthnicity],
			[PatientLanguage],
			PatientIsActive,
			PatientUpdatedDateTime,
			PatientMedicareNumber)
			SELECT 
                PatientID,
                PatientDataSourceID,
                PatientSourceID,
                PatientMRN,
                PatientFirstName,
                PatientMiddleInitial,
                PatientLastName,
                PatientFullName,
                PatientGender,
                PatientDateOfBirth,
                PatientSSN,
                PatientHomePhone,
                PatientWorkPhone,
                PatientWorkPhoneExtension,
                PatientMobilePhone,
                PatientEmailAddress,
                PatientStreetAddress1,
                PatientStreetAddress2,
                PatientCity,
                PatientState,
                PatientZipCode,
                PatientMaritalStatus,
                PatientEthnicity,
                PatientLanguage,
                PatientIsActive,
                PatientUpdatedDateTime,
                PatientMedicareNumber
            FROM @StagingTable;
			COMMIT TRANSACTION;

		   END
		    ELSE
		    BEGIN
		        PRINT 'Less than 10 patient records found. Skipping delete and reload.';
		    END
		END;


-- #################################### OLD QUERY #########################################################
--    PRINT 'Creating @StagingTable...';
	
--	DECLARE @StagingTable TABLE (
--        PatientID VARCHAR(50),
--        PatientDataSourceID INT,
--        PatientSourceID VARCHAR(50),
--        PatientMRN VARCHAR(50),
--        PatientFirstName VARCHAR(100),
--        PatientMiddleInitial VARCHAR(10),
--        PatientLastName VARCHAR(100),
--        PatientFullName VARCHAR(100),
--        PatientGender VARCHAR(10),
--        PatientDateOfBirth DATETIME,
--        PatientSSN VARCHAR(50),
--        PatientHomePhone NVARCHAR(30),
--        PatientWorkPhone NVARCHAR(30),
--        PatientWorkPhoneExtension VARCHAR(50),
--        PatientMobilePhone VARCHAR(30),
--        PatientEmailAddress VARCHAR(100),
--        PatientStreetAddress1 VARCHAR(50),
--        PatientStreetAddress2 VARCHAR(50),
--        PatientCity VARCHAR(50),
--        PatientState VARCHAR(50),
--        PatientZipCode VARCHAR(50),
--        PatientMaritalStatus VARCHAR(50),
--        PatientEthnicity VARCHAR(50),
--        PatientLanguage VARCHAR(50),
--        PatientIsActive BIT,
--        PatientUpdatedDateTime DATETIME,
--        PatientMedicareNumber VARCHAR(150)
--    );

--	INSERT INTO @StagingTable (
--        PatientID,
--        PatientDataSourceID,
--        PatientSourceID,
--        PatientMRN,
--        PatientFirstName,
--        PatientMiddleInitial,
--        PatientLastName,
--        PatientFullName,
--        PatientGender,
--        PatientDateOfBirth,
--        PatientSSN,
--        PatientHomePhone,
--        PatientWorkPhone,
--        PatientWorkPhoneExtension,
--        PatientMobilePhone,
--        PatientEmailAddress,
--        PatientStreetAddress1,
--        PatientStreetAddress2,
--        PatientCity,
--        PatientState,
--        PatientZipCode,
--        PatientMaritalStatus,
--        PatientEthnicity,
--        PatientLanguage,
--        PatientIsActive,
--        PatientUpdatedDateTime,
--        PatientMedicareNumber
--    )


--select
--	'5~' + p.PAT_ID PatientID,
--	5 AS PatientDataSourceID,
--	p.PAT_ID PatientSourceID,
--	p.PAT_MRN_ID PatientMRN,
--	p.PAT_FIRST_NAME PatientFirstName,
--	left(p.PAT_MIDDLE_NAME,1) PatientMiddleInitial,
--	p.PAT_LAST_NAME PatientLastName,
--	p.PAT_NAME PatientFullName,
--	sx.NAME as PatientGender,
--	p.BIRTH_DATE PatientDateOfBirth,
--	p.SSN PatientSSN,
--	p.HOME_PHONE PatientHomePhone,
--	p.WORK_PHONE PatientWorkPhone,
--	'' PatientWorkPhoneExtension,
--	c.OTHER_COMMUNIC_NUM as PatientMobilePhone,
--	p.EMAIL_ADDRESS PatientEmailAddress,
--	p.ADD_LINE_1 PatientStreetAddress1,
--	p.ADD_LINE_2 PatientStreetAddress2,
--	p.CITY PatientCity,
--	s.ABBR PatientState,
--	p.ZIP PatientZipCode,
--	ms.NAME AS PatientMaritalStatus,
--	eg.NAME as PatientEthnicity,
--	l.NAME as PatientLanguage,
--	p.PAT_STATUS_C PatientIsActive, /*Lookup Value in [100.65.16.148].[CLARITY].[ORGFILTER].[ZC_PATIENT_STATUS]:  Alive or Deceased*/
--	getdate() PatientUpdatedDateTime,
--	COALESCE(p.MEDICARE_NUM, p.MEDICAID_NUM) AS PatientMedicareNumber
--	from [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[PATIENT] p
--	left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[ZC_STATE] s on p.STATE_C = s.STATE_C
--	left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[ZC_SEX] sx ON sx.RCPT_MEM_SEX_C = p.SEX_C
--	left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[ZC_MARITAL_STATUS] ms ON ms.MARITAL_STATUS_C = p.MARITAL_STATUS_C
--	left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[ZC_ETHNIC_GROUP] eg ON eg.ETHNIC_GROUP_C = p.ETHNIC_GROUP_C
--	left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[ZC_LANGUAGE] l ON l.LANGUAGE_C = p.LANGUAGE_C
--	left join (
--		select 
--			zc.NAME
--			,ROW_NUMBER() OVER(PARTITION BY c.PAT_ID ORDER BY CONTACT_PRIORITY ASC) as RowNumber 
--			,c.*
--		from [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].[OTHER_COMMUNCTN] c
--			left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].[ZC_OTHER_COMMUNIC] zc on zc.OTHER_COMMUNIC_C = c.OTHER_COMMUNIC_C
--		where 1=1
--			AND c.OTHER_COMMUNIC_C = 1 /*Mobile*/
--		) c on c.PAT_ID = p.PAT_ID and c.RowNumber = 1 --and c.OTHER_COMMUNIC_NUM not like ('+1%')

--	    IF (SELECT COUNT(1) FROM @StagingTable) >= 10
--    BEGIN
--        BEGIN TRANSACTION;
--            PRINT 'At least 10 patient records found. Proceeding to delete and reload.';
--            DELETE FROM dim.Patients WHERE PatientDataSourceID = 5;

--			insert into dim.Patients(
--			PatientID,
--			PatientDataSourceID,
--			PatientSourceID,
--			PatientMRN,
--			PatientFirstName,
--			PatientMiddleInitial,
--			PatientLastName,
--			PatientFullName,
--			PatientGender,
--			PatientDateOfBirth,
--			PatientSSN,
--			PatientHomePhone,
--			PatientWorkPhone,
--			PatientWorkPhoneExtension,
--			PatientMobilePhone,
--			PatientEmailAddress,
--			PatientStreetAddress1,
--			PatientStreetAddress2,
--			PatientCity,
--			PatientState,
--			PatientZipCode,
--			[PatientMaritalStatus],
--			[PatientEthnicity],
--			[PatientLanguage],
--			PatientIsActive,
--			PatientUpdatedDateTime,
--			PatientMedicareNumber)
--			SELECT 
--                PatientID,
--                PatientDataSourceID,
--                PatientSourceID,
--                PatientMRN,
--                PatientFirstName,
--                PatientMiddleInitial,
--                PatientLastName,
--                PatientFullName,
--                PatientGender,
--                PatientDateOfBirth,
--                PatientSSN,
--                PatientHomePhone,
--                PatientWorkPhone,
--                PatientWorkPhoneExtension,
--                PatientMobilePhone,
--                PatientEmailAddress,
--                PatientStreetAddress1,
--                PatientStreetAddress2,
--                PatientCity,
--                PatientState,
--                PatientZipCode,
--                PatientMaritalStatus,
--                PatientEthnicity,
--                PatientLanguage,
--                PatientIsActive,
--                PatientUpdatedDateTime,
--                PatientMedicareNumber
--            FROM @StagingTable;
--			COMMIT TRANSACTION;

--		   END
--		    ELSE
--		    BEGIN
--		        PRINT 'Less than 10 patient records found. Skipping delete and reload.';
--		    END
--		END;


----select * from [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[PATIENT] p where PAT_ID = 'Z1006343'
----select * from [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[PATIENT_4] p where PAT_ID = 'Z1006343'

----SELECT 
----	mp.PAT_ID, mp.OTHER_COMMUNIC_NUM as PatientMobilePhone
----FROM (
----	select 
----		zc.NAME
----		,ROW_NUMBER() OVER(PARTITION BY c.PAT_ID ORDER BY CONTACT_PRIORITY ASC) as RowNumber 
----		,c.*
----	from [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].[OTHER_COMMUNCTN] c
----		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].[ZC_OTHER_COMMUNIC] zc on zc.OTHER_COMMUNIC_C = c.OTHER_COMMUNIC_C
----	where 1=1
----		AND c.OTHER_COMMUNIC_C = 1 /*Mobile*/
----		AND PAT_ID IN ('Z1006343','Z1130935')
----	) mp 
----WHERE mp.RowNumber = 1
----select * from [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].[ZC_OTHER_COMMUNIC]
GO
