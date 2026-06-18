CREATE PROCEDURE [stg].[spEPICReloadFactVisitCaseStaffFull] AS
BEGIN

-- =============================================
-- Author:		Zeke Herrera
-- Create date: 09/11/2023
-- Description:	Extracts, Transforms and Loads visitcasestaff Data from EPIC Source System into a fact table
-- Change Control: Diego Hernandez - Modify the script to OpenQUERY (3/6/2026)
-- =============================================

-- Step 1: Delete existing records for the data source
DELETE FROM [fact].[VisitCaseStaff]
WHERE [VisitCaseStaffDatasourceID] = 5;


-- Step 2: Insert records into fact.VisitCaseStaff
INSERT INTO [fact].[VisitCaseStaff]
(
      [VisitCaseStaffID],
      [VisitCaseStaffDatasourceID],
      [VisitCaseStaffSourceID],
      [VisitCaseID],
      [VisitCaseStaffLine],
      [VisitCaseStaffName],
      [VisitCaseStaffCred],
      [VisitCaseStaffType],
      [VisitCaseStaffSubtype],
      [VisitCaseStaffAccountableStaff],
      [VisitCaseStaffDurationMinutes],
      [VisitCaseStaffIsActive],
      [VisitCaseStaffUpdatedDatetime]
)

SELECT
    CONCAT('5~',src.LOG_ID,'~',src.LINE) AS VisitCaseStaffID,
    5 AS VisitCaseStaffDatasourceID,
    CONCAT(src.LOG_ID,'~',src.LINE) AS VisitCaseStaffSourceID,
    CONCAT('5~',src.LOG_ID) AS VisitCaseID,
    src.LINE AS VisitCaseStaffLine,
    src.STAFF_NM AS VisitCaseStaffName,
    src.STAFF_CRED AS VisitCaseStaffCred,
    src.STAFF_TYPE_MAP_NM AS VisitCaseStaffType,
    src.TYPE_NM AS VisitCaseStaffSubtype,
    src.ACCOUNTABLE_STAFF_YN AS VisitCaseStaffAccountableStaff,
    src.TIME_DURATION_MINUTES AS VisitCaseStaffDurationMinutes,
    1 AS VisitCaseStaffIsActive,
    GETDATE() AS VisitCaseStaffUpdatedDatetime

FROM OPENQUERY
(
    [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM],
    '
    SELECT
        LOG_ID,
        LINE,
        STAFF_NM,
        STAFF_CRED,
        STAFF_TYPE_MAP_NM,
        TYPE_NM,
        ACCOUNTABLE_STAFF_YN,
        TIME_DURATION_MINUTES
    FROM CLARITY.ORGFILTER.V_LOG_STAFF
    '
) src;

END;




--	ALTER PROCEDURE [stg].[spEPICReloadFactVisitCaseStaffFull] as

--	DELETE FROM [fact].[VisitCaseStaff] where [VisitCaseStaffDatasourceID] = 5

--INSERT INTO  [fact].[VisitCaseStaff]
--(
--[VisitCaseStaffID]
--      ,[VisitCaseStaffDatasourceID]
--      ,[VisitCaseStaffSourceID]
--      ,[VisitCaseID]
--      ,[VisitCaseStaffLine]
--      ,[VisitCaseStaffName]
--      ,[VisitCaseStaffCred]
--      ,[VisitCaseStaffType]
--      ,[VisitCaseStaffSubtype]
--      ,[VisitCaseStaffAccountableStaff]
--      ,[VisitCaseStaffDurationMinutes]
--      ,[VisitCaseStaffIsActive]
--      ,[VisitCaseStaffUpdatedDatetime]
--)
--SELECT 
--CONCAT('5~',v.LOG_ID,'~',v.LINE) as VisitCaseStaffID
--,5 as VisitCaseStaffDatasourceID
--,CONCAT(v.LOG_ID,'~',v.LINE) as VisitCaseStaffSourceID
--,concat('5~',log_id) as VisitCaseID
--,v.line  as VisitCaseStaffLine
--,STAFF_NM as VisitCaseStaffName
--,STAFF_CRED as VisitCaseStaffCred
--,staff_type_map_nm as VisitCaseStaffType 
--,TYPE_NM as VisitCaseStaffSubtype
--,Accountable_staff_yn as VisitCaseStaffAccountableStaff
--,Time_duration_minutes as VisitCaseStaffDurationMinutes
--,1 as [VisitCaseStaffIsActive] 
--,getdate() as [VisitCaseStaffUpdatedDatetime]
--FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].v_log_staff v
GO
