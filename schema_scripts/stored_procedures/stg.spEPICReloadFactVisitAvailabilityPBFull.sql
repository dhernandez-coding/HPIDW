CREATE PROCEDURE [stg].[spEPICReloadFactVisitAvailabilityPBFull]	AS
BEGIN		
	-- ========================================================================
	-- Author:		Eric Silvestri
	-- Create date: 11-14-2024
	-- Description:	Loads PB VisitAvailability records from EPIC into fact.VisitAvailabilityPB.
	-- ========================================================================

-- Step 1: Delete existing records for the data source
	DELETE FROM fact.VisitAvailabilityPB 
	WHERE VisitAvailabilityDataSourceID = 5;

-- Step 2: Insert into fact.VisitSchedulePB
INSERT INTO fact.VisitAvailabilityPB(
	[VisitAvailabilityID],
	[VisitAvailabilityVisitID],
	[VisitAvailabilityDataSourceID],
	[VisitAvailabilityDate],
	[VisitAvailabilityPatientID],
	[VisitAvailabilityDepartmentID],
	[VisitAvailabilitySpecialty],
	[VisitAvailabilityLocationID],
	[VisitAvailabilityProviderID],
	[VisitAvailabilityAppointmentFlag],
	[VisitAvailabilityType],
	[VisitAvailabilityUnavailable],
	[VisitAvailabilityUnavailableReason],
	[VisitAvailabilityOutsideTemplate],
	[VisitAvailabilityOverbook],
	[VisitAvailabilityRegularOpening],
	[VisitAvailabilityOverbookOpening],
	[VisitAvailabilitySlotLength],
	[VisitAvailabilityBeginTime],
	[VisitAvailabilityEndTime],
	[VisitAvailabilityUpdateDate]
)


SELECT
    CONCAT('5~',a.PAT_ENC_CSN_ID,'~', a.PROV_ID, '~', a.DEPARTMENT_ID, '~', FORMAT(a.SLOT_BEGIN_TIME, 'yyyy-MM-dd HH:mm:ss')) as VisitAvailabilityID,
    CONCAT('5~', a.PAT_ENC_CSN_ID) as VisitAvailabilityVisitID,
	--a.PAT_ENC_CSN_ID as VisitAvailabilityVisitID,
    5 as VisitAvailabilityDataSourceID,
    a.SLOT_DATE as VisitAvailabilityDate,
    CONCAT('5~', a.PAT_ID) as VisitAvailabilityPatientID,
	--a.PAT_ID as VisitAvailabilityPatientID,
    CONCAT('5~', a.DEPARTMENT_ID) as VisitAvailabilityDepartmentID,
    a.DEPT_SPECIALTY_NAME as VisitAvailabilitySpecialty,
    CONCAT('5~', a.LOC_ID) as VisitAvailabilityLocationID,
    CONCAT('5~', a.PROV_ID) as VisitAvailabilityProviderID,
    a.NUM_APTS_SCHEDULED as VisitAvailabilityAppointmentFlag,
    a.APPT_PRC_NAME as VisitAvailabilityType,
    a.TIME_UNAVAIL_YN as VisitAvailabilityUnavailable,
    a.TIME_UNAVAIL_RSN_NAME as VisitAvailabilityUnavailableReason,
    a.OUTSIDE_TEMPLATE_YN as VisitAvailabilityOutsideTemplate,
    a.APPT_OVERBOOK_YN as VisitAvailabilityOverbook,
    a.ORG_REG_OPENINGS as VisitAvailabilityRegularOpening,
    a.ORG_OVBK_OPENINGS as VisitAvailabilityOverbookOpening,
    a.SLOT_LENGTH as VisitAvailabilitySlotLength,
    a.SLOT_BEGIN_TIME as VisitAvailabilityBeginTime,
    a.SLOT_END_TIME as VisitAvailabilityEndTime,
    GETDATE() as VisitAvailabilityUpdateDate
FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].V_AVAILABILITY a
WHERE  
	 (a.PAT_ENC_CSN_ID IS NOT NULL
        OR (a.PAT_ENC_CSN_ID IS NULL AND a.NUM_APTS_SCHEDULED = 0))
	AND a.DEPARTMENT_NAME like 'TPG%' or a.DEPARTMENT_NAME like 'HPIP%'
GROUP BY 
    a.PROV_ID,
	a.PAT_ENC_CSN_ID,
    a.DEPARTMENT_ID,
    a.SLOT_BEGIN_TIME,
    a.SLOT_DATE,
    a.PAT_ID,
    a.DEPARTMENT_ID,
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
    a.SLOT_BEGIN_TIME,
    a.SLOT_END_TIME

END;
GO
