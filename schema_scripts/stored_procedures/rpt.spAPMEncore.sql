-- =============================================
-- Author:		Eric Silvestri
-- Create date: 08/13/2023
-- Description:	
-- Change Control
--	
-- =============================================

CREATE PROCEDURE [rpt].[spAPMEncore]
AS
BEGIN
SET NOCOUNT ON;

DECLARE @startdate AS DATE
DECLARE @enddate AS DATE

SET @startdate = GETDATE();
SET @enddate = DATEADD(DAY,3,@startdate);

SELECT DISTINCT  
		replace(rtrim(ltrim(ad.Patient_Number)), ',', '') as "PatNo"
		,replace(rtrim(ltrim(ad.Patient_Last_Name)), ',', '') as "LName"
		,replace(rtrim(ltrim(ad.Patient_First_Name)), ',', '') as "FName"
		,replace(rtrim(ltrim(ad.Patient_MI)), ',', '') as "Mi"
		,replace(rtrim(ltrim(ad.Patient_DOB)), ',', '') as "DOB"
		,replace(rtrim(ltrim(ad.Patient_Home_Phone)), ',', '') as "Home Phone"
		,replace(rtrim(ltrim(convert(date,ad.Appointment_DateTime,101))), ',', '') as "Appt Date"
		,replace(rtrim(ltrim(REPLACE(REPLACE(CONVERT(VARCHAR, ad.Appointment_DateTime, 108), 'AM', ' AM'), 'PM', ' PM'))), ',', '') as "Appt Time"
		,replace(rtrim(ltrim(ad.Appt_Type_Abbr)), ',', '') as "Appt Type"
		,replace(rtrim(ltrim(ad.Resource_Abbr)), ',', '') as "Resource"
		,replace(rtrim(ltrim(ad.Resource_Desc)), ',', '') as "Resource Desc"
		,replace(rtrim(ltrim(ad.Sched_Loc_Abbr)), ',', '') as "Loc"
		,replace(rtrim(ltrim(ad.Sched_Loc_Desc)), ',', '') as "Loc Desc"
		,replace(rtrim(ltrim(ad.Encounter_Number)), ',', '') as "Enc No"
		,replace(rtrim(ltrim(gpi.Patient_SSN)), ',', '') as "Patient SSN"
 FROM   tievmdb03.Ntier_627200.PM.vwApptDetail ad 
	INNER JOIN tievmdb03.Ntier_627200.PM.vwGenPatInfo gpi 
		ON ad.Patient_Number=gpi.Patient_Number AND ad.Patient_ID=gpi.Patient_ID
 WHERE  (ad.Resource_Abbr='AJG' OR ad.Resource_Abbr='DEA' OR ad.Resource_Abbr='LDP' OR ad.Resource_Abbr='MEM' OR ad.Resource_Abbr='RFH' OR ad.Resource_Abbr='RMH' OR ad.Resource_Abbr='SDC') AND (ad.Patient_Last_Name<>' ') and (ad.Appointment_DateTime between @startdate and @enddate)


 END
GO
