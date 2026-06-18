-- =============================================
-- Author:		Chris Cross
-- Create date: 03/14/2023
-- Description:	Extracts, Transforms and Loads Specialty Data from MEDHOST Source System into a dim Table
-- Change Control
--	1. 04/19/2023 - Chris Cross - Initial build of procedure
-- =============================================
CREATE PROCEDURE [stg].[spEPICReloadDimSpecialtiesFull]  AS
BEGIN
SET NOCOUNT ON;

-- HOSP: NS, SERVER: HOSPF100, SOURCEID: 2

 DELETE FROM dim.Specialties WHERE SpecialtyDataSourceID = 5

insert into dim.Specialties

--select * from [NXDC1DBSQ016.CORP.INTEGRIS-HEALTH.COM].[Revenue].dbo.DimSpecialties

SELECT 
    CONCAT('5~', s.SPECIALTY_C) AS SpecialtyID,
    5 AS SpecialtyDataSourceID,
    s.SPECIALTY_C AS SpecialtySourceID,
    s.NAME AS SpecialtyName,
    s.ABBR AS SpecialtyAbbreviation,
    NULL AS SpecialtyDescription,
    1 AS SpecialtyIsActive,
    NULL AS SpecialtyCoPayApplies,
    GETDATE() AS SpecialtyUpdatedDateTime
FROM OPENQUERY([CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM],
'
    SELECT 
        SPECIALTY_C,
        NAME,
        ABBR
    FROM [Clarity].[ORGFILTER].[ZC_SPECIALTY]
') AS s;


END
GO
