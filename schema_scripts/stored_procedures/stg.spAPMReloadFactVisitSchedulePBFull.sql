CREATE PROCEDURE [stg].[spAPMReloadFactVisitSchedulePBFull]	AS
BEGIN		
	-- ========================================================================
	-- Author:		Eric Silvestri
	-- Create date: 11-12-2024
	-- Description:	Loads PB VisitSchedule records from EPIC into fact.VisitSchedulePB.
	-- ========================================================================

-- Step 1: Delete existing records for the data source
	DELETE FROM fact.VisitSchedulePB 
	WHERE VisitScheduleDataSourceID = 1;

-- Step 2: Insert into fact.VisitSchedulePB
INSERT INTO fact.VisitSchedulePB(
	[VisitScheduleVisitID],
	[VisitScheduleDataSourceID],
	[VisitScheduleSourceID],
	[VisitScheduleAccountID],
	[VisitScheduleDate],
	[VisitSchedulePatientID],
	[VisitScheduleStatus],
	[VisitScheduleDepartmentID],
	[VisitScheduleSpecialty],
	[VisitScheduleLocationID],
	[VisitScheduleProviderID],
	[VisitSchedulePayerID],
	[VisitScheduleType],
	[VisitScheduleScheduleDate],
	[VisitScheduleAppointmentDate],
	[VisitScheduleCheckinTime],
	[VisitScheduleInRoomTime],
	[VisitScheduleProviderInTime],
	[VisitScheduleEndTime],
	[VisitScheduleCheckoutTime],
	[VisitScheduleTimeToRoom],
	[VisitScheduleTimeInRoom],
	[VisitScheduleVisitDuration],
	[VisitScheduleSameDayCancellation],
	[VisitScheduleConfirmationStatus],
	[VisitScheduleConfirmationDate],
	[VisitScheduleOverbook],
	[VisitScheduleCancellationDate],
	[VisitScheduleLateCancellation],
	[VisitScheduleCopayDue],
	[VisitScheduleCopayCollected],
	[VisitScheduleUpdateDate]
)


SELECT 
	CONCAT('1~', a.Appt_Encounter_Number) AS VisitScheduleVisitID
	,1 AS VisitScheduleDataSourceID
	,a.Appt_Encounter_Number AS VisitScheduleSourceID
	,ad.Account_ID AS VisitScheduleAccountID
	,a.Appt_DateTime AS VisitScheduleDate
	,CONCAT('1~', a.Patient_Number) AS VisitSchedulePatientID
	,CASE WHEN a.Appt_Status = 'A' THEN 'Acknowledged' 
		 WHEN a.Appt_Status = 'X' THEN 'Cancelled' 
		 WHEN a.Appt_Status = 'C' THEN 'Confirmed' 
		 WHEN a.Appt_Status = 'N' THEN 'No Show' 
		 WHEN a.Appt_Status = 'S' THEN 'Scheduled' 
		 WHEN a.Appt_Status = 'W' THEN 'Wait List' 
		 WHEN a.Appt_Status = 'B' THEN 'Bumped' 
			END AS VisitScheduleStatus 
	,CONCAT('1~', a.Appt_Sched_Department_ID) AS VisitScheduleDepartmentID
	,NULL AS VisitScheduleSpecialty
	,CONCAT('1~', a.Appt_Sched_Location_ID) AS VisitScheduleLocationID
	,CONCAT('1~', a.Appt_Resource_ID) AS VisitScheduleProviderID
	,CASE WHEN gv.Billing_Carrier_ID IS NULL THEN CONCAT('1~',gv.Original_Carrier_ID)
		ELSE CONCAT('1~', gv.Billing_Carrier_ID) END AS VisitSchedulePayerID
	,a.Appt_Visit_Type_Abbr AS VisitScheduleType
	,a.Appt_Booked_Date AS VisitScheduleScheduleDate
	,a.Appt_DateTime AS VisitScheduleAppointmentDate
	,NULL AS VisitScheduleCheckinTime
	,NULL AS VisitScheduleInRoomTime
	,NULL AS VisitScheduleProviderInTime
	,NULL AS VisitScheduleEndTime
	,NULL AS VisitScheduleCheckoutTime
	,NULL AS VisitScheduleTimeToRoom
	,NULL AS VisitScheduleTimeInRoom
	,NULL AS VisitScheduleVisitDuration
	,CASE WHEN CONVERT(date, a.Appt_Cancelled_Date) = CONVERT(date, a.Appt_DateTime) THEN 'Y' ELSE 'N' END AS VisitScheduleSameDayCancellation
	,CASE WHEN a.Appt_Confirmed_Date IS NULL THEN 'Not Confirmed' 
		ELSE 'Confirmed' END AS VisitScheduleConfirmationStatus
	,a.Appt_Confirmed_Date AS VisitScheduleConfirmationDate
	,NULL AS VisitScheduleOverbook
	,a.Appt_Cancelled_Date AS VisitScheduleCancellationDate
	,CASE WHEN a.Appt_Cancelled_Date IS NOT NULL 
         AND DATEDIFF(HOUR, a.Appt_Cancelled_Date, a.Appt_DateTime) < 24 
		THEN 'Y'
		ELSE 'N'
		END  AS VisitScheduleLateCancellation -- create logic for this
	,CASE WHEN a.Appt_Status = 'X' THEN NULL ELSE gv.Copay_Amount_Due END AS VisitScheduleCopayDue
	,CASE WHEN a.Appt_Status = 'X' THEN NULL ELSE gv.Copay_Credits END AS VisitScheduleCopayCollected
	,GETDATE() AS VisitScheduleUpdateDate
FROM [TIEVMDB03].[Ntier_627200].[PM].[vwGenPatApptInfo] a
	LEFT JOIN [TIEVMDB03].[Ntier_627200].[PM].[vwGenVouchInfo] gv on gv.Voucher_Number = a.Appt_Encounter_Number AND gv.Update_Status = 1
	LEFT JOIN [TIEVMDB03].[Ntier_627200].[PM].[vwApptDetail] ad on ad.Encounter_Number = a.Appt_Encounter_Number
	LEFT JOIN [TIEVMDB03].[Ntier_627200].[PM].[vwApptSchedAppts] sa on sa.Patient_Number = a.Patient_Number						
WHERE 1=1 AND a.Appt_Time_in is not null 
	AND CONVERT(Date, gv.Voucher_Service_Date) = CONVERT(date, a.Appt_DateTime)		
	AND a.Appt_Encounter_Number is not null  --and Appt_Encounter_Number = '19673110' 
	--AND a.Appt_DateTime between '2025-03-01' and '2025-03-31'
GROUP BY		  
	a.Appt_Encounter_Number
	,ad.Account_ID 
	,a.Appt_DateTime
	,a.Patient_Number
	,a.Appt_Status
	,a.Appt_Sched_Department_ID
	,a.Appt_Sched_Location_ID
	,gv.Billing_Carrier_ID
	,gv.Original_Carrier_ID
	,a.Appt_Resource_ID
	,a.Appt_Visit_Type_Abbr
	,a.Appt_Booked_Date
	,a.Appt_DateTime
	,a.Appt_Confirmed_Date
	,a.Appt_Cancelled_Date
	,gv.Copay_Amount_Due
	,gv.Copay_Credits 

END;





--SELECT top 1000 * FROM [TIEVMDB03].[Ntier_627200].[PM].[vwGenSvcPmtInfo] 
--SELECT top 1000 * FROM [TIEVMDB03].[Ntier_627200].[PM].[vwGenSvcPmtInfo] 

--SELECT top 1000 * FROM [TIEVMDB03].[Ntier_627200].[PM].[vwGenPatApptInfo]  WHERE patient_number = '2593360'

--SELECT *
--  FROM [TIEVMDB03].[Ntier_627200].[PM].[vwGenVouchInfo] --where patient_Number = '0103387'1~30670680

--SELECT top 1000 *
--  FROM fact.vVisitSchedulePB

--SELECT *
--  FROM [TIEVMDB03].[Ntier_627200].[PM].[vwGenVouchInfo] where Voucher_Number = '30760220'

--    SELECT top 1000 *
--  FROM [TIEVMDB03].[Ntier_627200].[PM].[vwGenPatApptInfo] where Appt_Encounter_Number = '30760220'

--      SELECT top 1000 *
--  FROM [TIEVMDB03].[Ntier_627200].[PM].[vwApptDetail] where Encounter_Number = '19673110'

--  SELECT top 1000 *
--  FROM [TIEVMDB03].[Ntier_627200].[PM].[vwApptSchedAppts]  where patient_Number = '0349429'
  
--  SELECT top 1000 *
--  FROM [TIEVMDB03].[Ntier_627200].[PM].[vwGenPatApptInfo]  where patient_Number = '0103387'

--  SELECT top 1000 *
--  FROM [TIEVMDB03].[Ntier_627200].[PM].[vwGenSvcInfo] where patient_Number = '0103387'
GO
