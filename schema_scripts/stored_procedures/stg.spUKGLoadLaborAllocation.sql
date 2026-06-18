-- =============================================
-- Author:		Zeke Herrera
-- Create date:   12/11/2023
-- Description:	Calls UKG API to populate PowerBI Report (LaborAllocation)
-- =============================================
CREATE PROCEDURE [stg].[spUKGLoadLaborAllocation] 

AS
BEGIN

--IF EXISTS (SELECT 1 FROM rpt.LaborAllocation)
--BEGIN
--    -- Truncate the table if it contains data
--    TRUNCATE TABLE rpt.LaborAllocation;
--    PRINT 'Table rpt.LaborAllocation has been truncated.';
--END
--ELSE
--BEGIN
--    PRINT 'Table rpt.LaborAllocation is already empty.';
--END


exec [stg].[spUKGGetAccessToken]

	/*Documentation for endpoint https://secure.saashr.com/ta/docs/rest/public/#  */

	Declare @URL nvarchar(max) = 'https://secure.saashr.com/ta/rest/v1/report/saved/106641954' --Labor Allocation Report Specifically 
	Declare @AccessToken nvarchar(max) = (SELECT TOP 1 PlatformAccessToken FROM Platforms WHERE PlatformID = 1)
	Declare @Authentication nvarchar(max) = CONCAT('Bearer ',@AccessToken)




		Declare @Object as Int;
		Declare @ResponseTable as table(Json_Table nvarchar(max))
		--Code Snippet
		Exec sp_OACreate 'MSXML2.XMLHTTP', @Object OUT;
		Exec sp_OAMethod @Object, 'open', NULL, 'get',
						 @URL, --Your Web Service Url (invoked)
						 'false'
		EXEC sp_OAMethod @Object, 'setRequestHeader', null, 'Authentication', @Authentication
		EXEC sp_OAMethod @Object, 'setRequestHeader', null, 'Content-Type', 'application/json'
		Exec sp_OAMethod @Object, 'send'
	--	Exec sp_OAMethod @Object, 'responseText', @ResponseText OUTPUT

		INSERT INTO @ResponseTable(Json_Table) EXEC sp_OAGetProperty @Object, 'responseText'
		select * from @ResponseTable

	DECLARE @json nvarchar(max)
	set @json = (select top 1 Json_Table from @ResponseTable)
	--select @json


--Replace double quotes
SET @json = REPLACE(@json, '"', ''); 
SET @json = REPLACE(@json, CHAR(13) + CHAR(10), CHAR(10));


DECLARE @Data NVARCHAR(MAX);

SELECT @Data = string_agg(TRIM(value), ']')
FROM (
    SELECT DISTINCT TRIM(S.Value) AS Value
    FROM STRING_SPLIT(@json, CHAR(10)) AS S
    WHERE S.Value <> 'Employee id' AND TRIM(S.Value) <> ''
) AS Attributes;




DECLARE @Delimiter CHAR(1) = ']';
DECLARE @xml XML;

-- Replace the delimiter with XML tags
SET @Data = '<Record><Attribute>' + 
                    REPLACE(REPLACE(@Data, ',', '</Attribute><Attribute>'), @Delimiter, '</Attribute></Record><Record><Attribute>') + 
                    '</Attribute></Record>';

-- Cast AS XML
SET @xml = CAST(@Data AS XML);

/* insert this into a stagining temp table local to this sp before rpt.LaborAllocation, and then insert into actual table */

INSERT INTO HPIDW.rpt.LaborAllocation
(
Employee_Id 
,First_Name
,Last_Name
,Employee_EIN
,Default_Department
,Pay_Type 
,[Date] 
,Jobs_HR 
,Bereavement_Hours 
,COVID_19_Hours 
,Call_Back_Hours 
,Cancelled_Shift_Hours
,Case_Completion_Hours
,Case_Completion_OT_Hours
,Charge_Nurse_Hours 
,Do_NOT_USE_Paramedic_Critical_Shift_Pay_Hours 
,EML_Overage_Hours 
,Education_Meeting_Hours 
,Epic_Training_Hours 
,Evening_Shift_Base_Hours 
,Evening_Shift_Imaging_Hours 
,Evening_Shift_Pharmacy_Hours 
,Evening_Shift_RN_PT_Hours 
,Evening_Shift_Respiratory_Hours 
,Extended_Medical_Leave_Hours 
,Family_Medical_Leave_Act_Hours 
,Friday_Day_Prime_Shift_Hours
,Friday_Evening_Prime_Shift_Hours 
,Holiday_Hours 
,Holiday_Worked_Hours 
,ICU_Day_Shift_Hours 
,Inclement_Weather_Hours 
,Jury_Duty_Hours 
,LC_Not_Paid_Hours 
,LC_Paid_Hours 
,Lead_Pay_Hours 
,Leave_without_Pay_Hours 
,Leave_without_Pay_FMLA_Hours 
,Night_Shift_Base_Hours 
,Night_Shift_Imaging_Scrub_Tech_Hours 
,Night_Shift_Pharmacy_Hours 
,Night_Shift_RN_PT_Hours 
,Night_Shift_Respiratory_Hours 
,On_Call_Hours_Hours 
,Other_Hours 
,Overtime_Hours 
,PCT_HUC_Critical_Shift_Pay_Hours 
,PTO_Hours 
,PTO_PAYOUT_Hours 
,PTO_Premium_Pay_Hours 
,PTO1_Hours 
,Physician_or_Mid_Level_Provider_Hours 
,Preceptor_Hours_Hours 
,RN_Critical_Shift_Pay_Hours 
,Regular_Hours 
,Sick_Hours 
,Total_Hours_Hours
,UNPDOT_Hours
,WAOT_Hours 
,WC_Hours 
,WC_FMLA_Hours 
,WC_FMLA_LWOP_Hours 
,WC_LWOP_Hours 
,WD_Shift_Base_Hours
,WD_Shift_Imaging_Surgical_Tech_Hours 
,WD_Shift_Pharmacy_Hours 
,WD_Shift_Prime_Imaging_Surgical_T_Hours 
,WD_Shift_Prime_RN_PT_Hours
,WD_Shift_RN_PT_Hours 
,WD_Shift_Respiratory_Hours 
,WE_Shift_Base_Hours 
,WE_Shift_Imaging_Surgical_Tech_Hours 
,WE_Shift_Pharmacy_Hours
,WE_Shift_Prime_Imaging_Surgical_T_Hours 
,WE_Shift_Prime_Pharmacy_Hours 
,WE_Shift_Prime_RN_PT_Hours
,WE_Shift_RN_PT_Hours 
,WE_Shift_Respiratory_Hours
,WN_Shift_Base_Hours 
,WN_Shift_Imaging_Surgical_Tech_Hours 
,WN_Shift_Pharmacy_Hours
,WN_Shift_Prime_Imaging_Surgical_T_Hours 
,WN_Shift_Prime_Pharmacy_Hours 
,WN_Shift_Prime_RN_PT_Hours 
,WN_Shift_RN_PT_Hours 
,WN_Shift_Respiratory_Hours 
,Worked_Hours_Hours
)
SELECT 
		T.C.value('Attribute[1]', 'NVARCHAR(MAX)') AS Employee_Id,
		T.C.value('Attribute[2]', 'NVARCHAR(MAX)') AS First_Name,
		T.C.value('Attribute[3]', 'NVARCHAR(MAX)') AS Last_Name,
		T.C.value('Attribute[4]', 'NVARCHAR(MAX)') AS Employee_EIN,
		T.C.value('Attribute[5]', 'NVARCHAR(MAX)') AS Default_Department,
		T.C.value('Attribute[6]', 'NVARCHAR(MAX)') AS Pay_Type,
		T.C.value('Attribute[7]', 'NVARCHAR(MAX)') AS [Date],
		T.C.value('Attribute[8]', 'NVARCHAR(MAX)') AS Jobs_HR,
		T.C.value('Attribute[9]', 'NVARCHAR(MAX)') AS Bereavement_Hours,
		T.C.value('Attribute[10]', 'NVARCHAR(MAX)') AS COVID_19_Hours,
		T.C.value('Attribute[11]', 'NVARCHAR(MAX)') AS Call_Back_Hours,
		T.C.value('Attribute[12]', 'NVARCHAR(MAX)') AS Cancelled_Shift_Hours,
		T.C.value('Attribute[13]', 'NVARCHAR(MAX)') AS Case_Completion_Hours,
		T.C.value('Attribute[14]', 'NVARCHAR(MAX)') AS Case_Completion_OT_Hours,
		T.C.value('Attribute[15]', 'NVARCHAR(MAX)') AS Charge_Nurse_Hours,
		T.C.value('Attribute[16]', 'NVARCHAR(MAX)') AS Do_NOT_USE_Paramedic_Critical_Shift_Pay_Hours,
		T.C.value('Attribute[17]', 'NVARCHAR(MAX)') AS EML_Overage_Hours,
		T.C.value('Attribute[18]', 'NVARCHAR(MAX)') AS Education_Meeting_Hours,
		T.C.value('Attribute[19]', 'NVARCHAR(MAX)') AS Epic_Training_Hours,
		T.C.value('Attribute[20]', 'NVARCHAR(MAX)') AS Evening_Shift_Base_Hours,
		T.C.value('Attribute[21]', 'NVARCHAR(MAX)') AS Evening_Shift_Imaging_Hours,
		T.C.value('Attribute[22]', 'NVARCHAR(MAX)') AS Evening_Shift_Pharmacy_Hours,
		T.C.value('Attribute[23]', 'NVARCHAR(MAX)') AS Evening_Shift_RN_PT_Hours,
		T.C.value('Attribute[24]', 'NVARCHAR(MAX)') AS Evening_Shift_Respiratory_Hours,
		T.C.value('Attribute[25]', 'NVARCHAR(MAX)') AS Extended_Medical_Leave_Hours,
		T.C.value('Attribute[26]', 'NVARCHAR(MAX)') AS Family_Medical_Leave_Act_Hours,
		T.C.value('Attribute[27]', 'NVARCHAR(MAX)') AS Friday_Day_Prime_Shift_Hours,
		T.C.value('Attribute[28]', 'NVARCHAR(MAX)') AS Friday_Evening_Prime_Shift_Hours,
		T.C.value('Attribute[29]', 'NVARCHAR(MAX)') AS Holiday_Hours,
		T.C.value('Attribute[30]', 'NVARCHAR(MAX)') AS Holiday_Worked_Hours,
		T.C.value('Attribute[31]', 'NVARCHAR(MAX)') AS ICU_Day_Shift_Hours,
		T.C.value('Attribute[32]', 'NVARCHAR(MAX)') AS Inclement_Weather_Hours,
		T.C.value('Attribute[33]', 'NVARCHAR(MAX)') AS Jury_Duty_Hours,
		T.C.value('Attribute[34]', 'NVARCHAR(MAX)') AS LC_Not_Paid_Hours,
		T.C.value('Attribute[35]', 'NVARCHAR(MAX)') AS LC_Paid_Hours,
		T.C.value('Attribute[36]', 'NVARCHAR(MAX)') AS Lead_Pay_Hours,
		T.C.value('Attribute[37]', 'NVARCHAR(MAX)') AS Leave_without_Pay_Hours,
		T.C.value('Attribute[38]', 'NVARCHAR(MAX)') AS Leave_without_Pay_FMLA_Hours,
		T.C.value('Attribute[39]', 'NVARCHAR(MAX)') AS Night_Shift_Base_Hours,
		T.C.value('Attribute[40]', 'NVARCHAR(MAX)') AS Night_Shift_Imaging_Scrub_Tech_Hours,
		T.C.value('Attribute[41]', 'NVARCHAR(MAX)') AS Night_Shift_Pharmacy_Hours,
		T.C.value('Attribute[42]', 'NVARCHAR(MAX)') AS Night_Shift_RN_PT_Hours,
		T.C.value('Attribute[43]', 'NVARCHAR(MAX)') AS Night_Shift_Respiratory_Hours,
		T.C.value('Attribute[44]', 'NVARCHAR(MAX)') AS On_Call_Hours_Hours,
		T.C.value('Attribute[45]', 'NVARCHAR(MAX)') AS Other_Hours,
		T.C.value('Attribute[46]', 'NVARCHAR(MAX)') AS Overtime_Hours,
		T.C.value('Attribute[47]', 'NVARCHAR(MAX)') AS PCT_HUC_Critical_Shift_Pay_Hours,
		T.C.value('Attribute[48]', 'NVARCHAR(MAX)') AS PTO_Hours,
		T.C.value('Attribute[49]', 'NVARCHAR(MAX)') AS PTO_PAYOUT_Hours,
		T.C.value('Attribute[50]', 'NVARCHAR(MAX)') AS PTO_Premium_Pay_Hours,
		T.C.value('Attribute[51]', 'NVARCHAR(MAX)') AS PTO1_Hours,
		T.C.value('Attribute[52]', 'NVARCHAR(MAX)') AS Physician_or_Mid_Level_Provider_Hours,
		T.C.value('Attribute[53]', 'NVARCHAR(MAX)') AS Preceptor_Hours_Hours,
		T.C.value('Attribute[54]', 'NVARCHAR(MAX)') AS RN_Critical_Shift_Pay_Hours,
		T.C.value('Attribute[55]', 'NVARCHAR(MAX)') AS Regular_Hours,
		T.C.value('Attribute[56]', 'NVARCHAR(MAX)') AS Sick_Hours,
		T.C.value('Attribute[57]', 'NVARCHAR(MAX)') AS Total_Hours_Hours,
		T.C.value('Attribute[58]', 'NVARCHAR(MAX)') AS UNPDOT_Hours,
		T.C.value('Attribute[59]', 'NVARCHAR(MAX)') AS WAOT_Hours,
		T.C.value('Attribute[60]', 'NVARCHAR(MAX)') AS WC_Hours,
		T.C.value('Attribute[61]', 'NVARCHAR(MAX)') AS WC_FMLA_Hours,
		T.C.value('Attribute[62]', 'NVARCHAR(MAX)') AS WC_FMLA_LWOP_Hours,
		T.C.value('Attribute[63]', 'NVARCHAR(MAX)') AS WC_LWOP_Hours,
		T.C.value('Attribute[64]', 'NVARCHAR(MAX)') AS WD_Shift_Base_Hours,
		T.C.value('Attribute[65]', 'NVARCHAR(MAX)') AS WD_Shift_Imaging_Surgical_Tech_Hours,
		T.C.value('Attribute[66]', 'NVARCHAR(MAX)') AS WD_Shift_Pharmacy_Hours,
		T.C.value('Attribute[67]', 'NVARCHAR(MAX)') AS WD_Shift_Prime_Imaging_Surgical_T_Hours,
		T.C.value('Attribute[68]', 'NVARCHAR(MAX)') AS WD_Shift_Prime_RN_PT_Hours,
		T.C.value('Attribute[69]', 'NVARCHAR(MAX)') AS WD_Shift_RN_PT_Hours,
		T.C.value('Attribute[70]', 'NVARCHAR(MAX)') AS WD_Shift_Respiratory_Hours,
		T.C.value('Attribute[71]', 'NVARCHAR(MAX)') AS WE_Shift_Base_Hours,
		T.C.value('Attribute[72]', 'NVARCHAR(MAX)') AS WE_Shift_Imaging_Surgical_Tech_Hours,
		T.C.value('Attribute[73]', 'NVARCHAR(MAX)') AS WE_Shift_Pharmacy_Hours,
		T.C.value('Attribute[74]', 'NVARCHAR(MAX)') AS WE_Shift_Prime_Imaging_Surgical_T_Hours,
		T.C.value('Attribute[75]', 'NVARCHAR(MAX)') AS WE_Shift_Prime_Pharmacy_Hours,
		T.C.value('Attribute[76]', 'NVARCHAR(MAX)') AS WE_Shift_Prime_RN_PT_Hours,
		T.C.value('Attribute[77]', 'NVARCHAR(MAX)') AS WE_Shift_RN_PT_Hours,
		T.C.value('Attribute[78]', 'NVARCHAR(MAX)') AS WE_Shift_Respiratory_Hours,
		T.C.value('Attribute[79]', 'NVARCHAR(MAX)') AS WN_Shift_Base_Hours,
		T.C.value('Attribute[80]', 'NVARCHAR(MAX)') AS WN_Shift_Imaging_Surgical_Tech_Hours,
		T.C.value('Attribute[81]', 'NVARCHAR(MAX)') AS WN_Shift_Pharmacy_Hours,
		T.C.value('Attribute[82]', 'NVARCHAR(MAX)') AS WN_Shift_Prime_Imaging_Surgical_T_Hours,
		T.C.value('Attribute[83]', 'NVARCHAR(MAX)') AS WN_Shift_Prime_Pharmacy_Hours,
		T.C.value('Attribute[84]', 'NVARCHAR(MAX)') AS WN_Shift_Prime_RN_PT_Hours,
		T.C.value('Attribute[85]', 'NVARCHAR(MAX)') AS WN_Shift_RN_PT_Hours,
		T.C.value('Attribute[86]', 'NVARCHAR(MAX)') AS WN_Shift_Respiratory_Hours,
		T.C.value('Attribute[87]', 'NVARCHAR(MAX)') AS Worked_Hours_Hours
FROM @xml.nodes('/Record') T(C)
   -- Added 3-27 to extend load pipeline to 7 days. No WHERE in previous writing
   WHERE 1=1
  -- AND T.C.value('Attribute[7]', 'NVARCHAR(MAX)') >= DATEADD(DAY, -7, GETDATE())  -- Retrieve data for the last 7 days
	--AND CAST(T.C.value('Attribute[7]', 'NVARCHAR(MAX)') AS DATE) >= '2024-05-01'
    AND NOT EXISTS (
        -- Avoid inserting duplicate rows
        SELECT 1
        FROM HPIDW.rpt.LaborAllocation AS LA
        WHERE CONCAT(LA.Employee_Id,LA.Date) = CONCAT(T.C.value('Attribute[1]', 'NVARCHAR(MAX)'),T.C.value('Attribute[7]', 'NVARCHAR(MAX)')) 
   )

--Delete unneeded entry into table 
--DELETE FROM HPIDW.rpt.LaborAllocation
--WHERE date  = 'date'



END
GO
