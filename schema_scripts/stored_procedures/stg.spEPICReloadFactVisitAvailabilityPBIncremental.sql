CREATE PROCEDURE [stg].[spEPICReloadFactVisitAvailabilityPBIncremental]	AS
		
	-- ========================================================================
	-- Author:		Eric Silvestri
	-- Create date: 11-14-2024
	-- Description:	Loads PB VisitAvailability records from EPIC into fact.VisitAvailabilityPB.
    -- Charge Control: 	
        --1. 3/6/26 - Diego Hernandez - Added datasource 15 to the where clause to include Modmed 
	-- ========================================================================

BEGIN
 
/*Step 1: Load Staging Table with PB VisitAvailabilityPB...*/
PRINT 'Step 1: Create Staging Table...'

DECLARE @DaysToReload INT = 5

PRINT 'Setting Days To Reload: ' + CONVERT(VARCHAR(10), @DaysToReload) + '...'


DECLARE @Staging TABLE
(
    [VisitAvailabilityID] VARCHAR(100) NOT NULL,
    [VisitAvailabilityVisitID] VARCHAR(50),
    [VisitAvailabilityDataSourceID] INT,
    [VisitAvailabilityDate] DATETIME,
    [VisitAvailabilityPatientID] VARCHAR(50),
    [VisitAvailabilityDepartmentID] VARCHAR(50),
    [VisitAvailabilitySpecialty] VARCHAR(50),
    [VisitAvailabilityLocationID] VARCHAR(50),
    [VisitAvailabilityProviderID] VARCHAR(50),
    [VisitAvailabilityAppointmentFlag] INT,
    [VisitAvailabilityType] VARCHAR(50),
    [VisitAvailabilityUnavailable] VARCHAR(10),
    [VisitAvailabilityUnavailableReason] VARCHAR(50),
    [VisitAvailabilityOutsideTemplate] VARCHAR(10),
    [VisitAvailabilityOverbook] VARCHAR(10),
    [VisitAvailabilityRegularOpening] INT,
    [VisitAvailabilityOverbookOpening] INT,
    [VisitAvailabilitySlotLength] INT,
    [VisitAvailabilityBeginTime] DATETIME,
    [VisitAvailabilityEndTime] DATETIME,
    [VisitAvailabilityUpdateDate] DATETIME
)


/* Step 1.1: Load staging table */
PRINT 'Step 1.1: Loading fact.VisitAvailabilityPB into @Staging...'

INSERT INTO @Staging
(
    VisitAvailabilityID,
    VisitAvailabilityVisitID,
    VisitAvailabilityDataSourceID,
    VisitAvailabilityDate,
    VisitAvailabilityPatientID,
    VisitAvailabilityDepartmentID,
    VisitAvailabilitySpecialty,
    VisitAvailabilityLocationID,
    VisitAvailabilityProviderID,
    VisitAvailabilityAppointmentFlag,
    VisitAvailabilityType,
    VisitAvailabilityUnavailable,
    VisitAvailabilityUnavailableReason,
    VisitAvailabilityOutsideTemplate,
    VisitAvailabilityOverbook,
    VisitAvailabilityRegularOpening,
    VisitAvailabilityOverbookOpening,
    VisitAvailabilitySlotLength,
    VisitAvailabilityBeginTime,
    VisitAvailabilityEndTime,
    VisitAvailabilityUpdateDate
)

SELECT
    CONCAT('5~',src.PAT_ENC_CSN_ID,'~',src.PROV_ID,'~',src.DEPARTMENT_ID,'~',FORMAT(src.SLOT_BEGIN_TIME,'yyyy-MM-dd HH:mm:ss')),
    CONCAT('5~',src.PAT_ENC_CSN_ID),
    5,
    src.SLOT_DATE,
    CONCAT('5~',src.PAT_ID),
    CONCAT('5~',src.DEPARTMENT_ID),
    src.DEPT_SPECIALTY_NAME,
    CONCAT('5~',src.LOC_ID),
    CONCAT('5~',src.PROV_ID),
    src.NUM_APTS_SCHEDULED,
    src.APPT_PRC_NAME,
    src.TIME_UNAVAIL_YN,
    src.TIME_UNAVAIL_RSN_NAME,
    src.OUTSIDE_TEMPLATE_YN,
    src.APPT_OVERBOOK_YN,
    src.ORG_REG_OPENINGS,
    src.ORG_OVBK_OPENINGS,
    src.SLOT_LENGTH,
    src.SLOT_BEGIN_TIME,
    src.SLOT_END_TIME,
    GETDATE()

FROM OPENQUERY
(
    [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM],
'
SELECT
    a.PAT_ENC_CSN_ID,
    a.PROV_ID,
    a.DEPARTMENT_ID,
    a.SLOT_BEGIN_TIME,
    a.SLOT_DATE,
    a.PAT_ID,
    a.DEPT_SPECIALTY_NAME,
    a.LOC_ID,
    a.NUM_APTS_SCHEDULED,
    a.APPT_PRC_NAME,
    a.TIME_UNAVAIL_YN,
    a.TIME_UNAVAIL_RSN_NAME,
    a.OUTSIDE_TEMPLATE_YN,
    a.APPT_OVERBOOK_YN,
    a.ORG_REG_OPENINGS,
    a.ORG_OVBK_OPENINGS,
    a.SLOT_LENGTH,
    a.SLOT_END_TIME
FROM CLARITY.ORGFILTER.V_AVAILABILITY a
WHERE
    (a.PAT_ENC_CSN_ID IS NOT NULL OR (a.PAT_ENC_CSN_ID IS NULL AND a.NUM_APTS_SCHEDULED = 0))
    AND (a.DEPARTMENT_NAME LIKE ''TPG%'' OR a.DEPARTMENT_NAME LIKE ''HPIP%'')
'
) src
WHERE src.SLOT_DATE >= DATEADD(DAY,-@DaysToReload,CONVERT(DATE,GETDATE()))

GROUP BY
    src.PAT_ENC_CSN_ID,
    src.PROV_ID,
    src.DEPARTMENT_ID,
    src.SLOT_BEGIN_TIME,
    src.SLOT_DATE,
    src.PAT_ID,
    src.DEPT_SPECIALTY_NAME,
    src.LOC_ID,
    src.NUM_APTS_SCHEDULED,
    src.APPT_PRC_NAME,
    src.TIME_UNAVAIL_YN,
    src.TIME_UNAVAIL_RSN_NAME,
    src.OUTSIDE_TEMPLATE_YN,
    src.APPT_OVERBOOK_YN,
    src.ORG_REG_OPENINGS,
    src.ORG_OVBK_OPENINGS,
    src.SLOT_LENGTH,
    src.SLOT_END_TIME


/* Step 2: Validate staging count before load */

PRINT 'Step 2: Checking number of records in @Staging...'

IF (SELECT COUNT(1) FROM @Staging) > 100
BEGIN

    PRINT 'Step 2.1: More than 100 records exist in @Staging. Proceeding with DELETE...'

    DELETE FROM fact.VisitAvailabilityPB
    WHERE VisitAvailabilityDataSourceID = 5
    AND VisitAvailabilityDate >= DATEADD(DAY,-@DaysToReload,CONVERT(DATE,GETDATE()))


    PRINT 'Step 2.2: Proceeding with INSERT...'

    INSERT INTO fact.VisitAvailabilityPB
    (
        VisitAvailabilityID,
        VisitAvailabilityVisitID,
        VisitAvailabilityDataSourceID,
        VisitAvailabilityDate,
        VisitAvailabilityPatientID,
        VisitAvailabilityDepartmentID,
        VisitAvailabilitySpecialty,
        VisitAvailabilityLocationID,
        VisitAvailabilityProviderID,
        VisitAvailabilityAppointmentFlag,
        VisitAvailabilityType,
        VisitAvailabilityUnavailable,
        VisitAvailabilityUnavailableReason,
        VisitAvailabilityOutsideTemplate,
        VisitAvailabilityOverbook,
        VisitAvailabilityRegularOpening,
        VisitAvailabilityOverbookOpening,
        VisitAvailabilitySlotLength,
        VisitAvailabilityBeginTime,
        VisitAvailabilityEndTime,
        VisitAvailabilityUpdateDate
    )

    SELECT *
    FROM @Staging

END
ELSE
    PRINT 'Less than 100 records in @Staging. Ending Job...'

END


--/*Step 1:  Load Staging Table with PB VisitAvailabilityPB...*/
--Print 'Step 1:  Create Staging Table...'
--DECLARE @DaysToReload int = 5
--Print 'Setting Days To Reload:' + convert(varchar(10),@DaysToReload) + '...'


--DECLARE @Staging TABLE
--	(
--	[VisitAvailabilityID] [varchar](100) NOT NULL,
--	[VisitAvailabilityVisitID] [varchar](50) NULL,
--	[VisitAvailabilityDataSourceID] [int] NULL,
--	[VisitAvailabilityDate] [datetime] NULL,
--	[VisitAvailabilityPatientID] [varchar](50) NULL,
--	[VisitAvailabilityDepartmentID] [varchar](50) NULL,
--	[VisitAvailabilitySpecialty] [varchar](50) NULL,
--	[VisitAvailabilityLocationID] [varchar](50) NULL,
--	[VisitAvailabilityProviderID] [varchar](50) NULL,
--	[VisitAvailabilityAppointmentFlag] [int] NULL,
--	[VisitAvailabilityType] [varchar](50) NULL,
--	[VisitAvailabilityUnavailable] [varchar](10) NULL,
--	[VisitAvailabilityUnavailableReason] [varchar](50) NULL,
--	[VisitAvailabilityOutsideTemplate] [varchar](10) NULL,
--	[VisitAvailabilityOverbook] [varchar](10) NULL,
--	[VisitAvailabilityRegularOpening] [int] NULL,
--	[VisitAvailabilityOverbookOpening] [int] NULL,
--	[VisitAvailabilitySlotLength] [int] NULL,
--	[VisitAvailabilityBeginTime] [datetime] NULL,
--	[VisitAvailabilityEndTime] [datetime] NULL,
--	[VisitAvailabilityUpdateDate] [datetime] NULL
--	)

---- Step 2: Insert into fact.VisitAvailabilityPB
--	Print 'Step 1.1:  Loading fact.VisitAvailabilityPB into @Staging...'
--	INSERT INTO @Staging (
--	[VisitAvailabilityID],
--	[VisitAvailabilityVisitID],
--	[VisitAvailabilityDataSourceID],
--	[VisitAvailabilityDate],
--	[VisitAvailabilityPatientID],
--	[VisitAvailabilityDepartmentID],
--	[VisitAvailabilitySpecialty],
--	[VisitAvailabilityLocationID],
--	[VisitAvailabilityProviderID],
--	[VisitAvailabilityAppointmentFlag],
--	[VisitAvailabilityType],
--	[VisitAvailabilityUnavailable],
--	[VisitAvailabilityUnavailableReason],
--	[VisitAvailabilityOutsideTemplate],
--	[VisitAvailabilityOverbook],
--	[VisitAvailabilityRegularOpening],
--	[VisitAvailabilityOverbookOpening],
--	[VisitAvailabilitySlotLength],
--	[VisitAvailabilityBeginTime],
--	[VisitAvailabilityEndTime],
--	[VisitAvailabilityUpdateDate]
--)


--SELECT
--    CONCAT('5~',a.PAT_ENC_CSN_ID,'~', a.PROV_ID, '~', a.DEPARTMENT_ID, '~', FORMAT(a.SLOT_BEGIN_TIME, 'yyyy-MM-dd HH:mm:ss')) as VisitAvailabilityID,
--    CONCAT('5~', a.PAT_ENC_CSN_ID) as VisitAvailabilityVisitID,
--	--a.PAT_ENC_CSN_ID as VisitAvailabilityVisitID,
--    5 as VisitAvailabilityDataSourceID,
--    a.SLOT_DATE as VisitAvailabilityDate,
--    CONCAT('5~', a.PAT_ID) as VisitAvailabilityPatientID,
--	--a.PAT_ID as VisitAvailabilityPatientID,
--    CONCAT('5~', a.DEPARTMENT_ID) as VisitAvailabilityDepartmentID,
--    a.DEPT_SPECIALTY_NAME as VisitAvailabilitySpecialty,
--    CONCAT('5~', a.LOC_ID) as VisitAvailabilityLocationID,
--    CONCAT('5~', a.PROV_ID) as VisitAvailabilityProviderID,
--    a.NUM_APTS_SCHEDULED as VisitAvailabilityAppointmentFlag,
--    a.APPT_PRC_NAME as VisitAvailabilityType,
--    a.TIME_UNAVAIL_YN as VisitAvailabilityUnavailable,
--    a.TIME_UNAVAIL_RSN_NAME as VisitAvailabilityUnavailableReason,
--    a.OUTSIDE_TEMPLATE_YN as VisitAvailabilityOutsideTemplate,
--    a.APPT_OVERBOOK_YN as VisitAvailabilityOverbook,
--    a.ORG_REG_OPENINGS as VisitAvailabilityRegularOpening,
--    a.ORG_OVBK_OPENINGS as VisitAvailabilityOverbookOpening,
--    a.SLOT_LENGTH as VisitAvailabilitySlotLength,
--    a.SLOT_BEGIN_TIME as VisitAvailabilityBeginTime,
--    a.SLOT_END_TIME as VisitAvailabilityEndTime,
--    GETDATE() as VisitAvailabilityUpdateDate
--FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].V_AVAILABILITY a
--WHERE  
--    (a.PAT_ENC_CSN_ID IS NOT NULL OR (a.PAT_ENC_CSN_ID IS NULL AND a.NUM_APTS_SCHEDULED = 0))
--    AND (a.DEPARTMENT_NAME LIKE 'TPG%' OR a.DEPARTMENT_NAME LIKE 'HPIP%')
--    AND a.SLOT_DATE >= DATEADD(DAY, -@DaysToReload, CONVERT(date, GETDATE()))
--GROUP BY 
--    a.PAT_ENC_CSN_ID,
--    a.PROV_ID,
--    a.DEPARTMENT_ID,
--    a.SLOT_BEGIN_TIME,
--    a.SLOT_DATE,
--    a.PAT_ID,
--    a.DEPT_SPECIALTY_NAME,
--    a.LOC_ID,
--    a.NUM_APTS_SCHEDULED,
--    a.APPT_PRC_NAME,
--    a.TIME_UNAVAIL_YN,
--    a.TIME_UNAVAIL_RSN_NAME,
--    a.OUTSIDE_TEMPLATE_YN,
--    a.APPT_OVERBOOK_YN,
--    a.ORG_REG_OPENINGS,
--    a.ORG_OVBK_OPENINGS,
--    a.SLOT_LENGTH,
--    a.SLOT_END_TIME




--/*Check @Staging records and delete/reload into fact.TransactionsPB*/
--	Print 'Step 2:  Checking number of records in @Staging...'
--	IF (SELECT COUNT(1) FROM @Staging) > 100 
--		BEGIN
--		Print 'Step 2.1:  More than 100 records exist in @Staging.  Proceeding with DELETE...'
--		DELETE FROM fact.VisitAvailabilityPB WHERE VisitAvailabilityDataSourceID = 5 AND VisitAvailabilityDate >= DATEADD(DAY,-@DaysToReload, convert(date,GETDATE())) 

--		Print 'Step 2.2:  Proceeding with INSERT...'

--		INSERT INTO fact.VisitAvailabilityPB
--		(
--			[VisitAvailabilityID],
--			[VisitAvailabilityVisitID],
--			[VisitAvailabilityDataSourceID],
--			[VisitAvailabilityDate],
--			[VisitAvailabilityPatientID],
--			[VisitAvailabilityDepartmentID],
--			[VisitAvailabilitySpecialty],
--			[VisitAvailabilityLocationID],
--			[VisitAvailabilityProviderID],
--			[VisitAvailabilityAppointmentFlag],
--			[VisitAvailabilityType],
--			[VisitAvailabilityUnavailable],
--			[VisitAvailabilityUnavailableReason],
--			[VisitAvailabilityOutsideTemplate],
--			[VisitAvailabilityOverbook],
--			[VisitAvailabilityRegularOpening],
--			[VisitAvailabilityOverbookOpening],
--			[VisitAvailabilitySlotLength],
--			[VisitAvailabilityBeginTime],
--			[VisitAvailabilityEndTime],
--			[VisitAvailabilityUpdateDate]
--		)

		
--	SELECT 
--			[VisitAvailabilityID],
--			[VisitAvailabilityVisitID],
--			[VisitAvailabilityDataSourceID],
--			[VisitAvailabilityDate],
--			[VisitAvailabilityPatientID],
--			[VisitAvailabilityDepartmentID],
--			[VisitAvailabilitySpecialty],
--			[VisitAvailabilityLocationID],
--			[VisitAvailabilityProviderID],
--			[VisitAvailabilityAppointmentFlag],
--			[VisitAvailabilityType],
--			[VisitAvailabilityUnavailable],
--			[VisitAvailabilityUnavailableReason],
--			[VisitAvailabilityOutsideTemplate],
--			[VisitAvailabilityOverbook],
--			[VisitAvailabilityRegularOpening],
--			[VisitAvailabilityOverbookOpening],
--			[VisitAvailabilitySlotLength],
--			[VisitAvailabilityBeginTime],
--			[VisitAvailabilityEndTime],
--			[VisitAvailabilityUpdateDate]
--	FROM @Staging
	
--	END
--	ELSE
--	Print 'Less than 100 records in @Staging. Ending Job...'
--END
GO
