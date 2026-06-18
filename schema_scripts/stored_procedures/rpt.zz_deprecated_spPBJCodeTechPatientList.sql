-- =============================================
-- Author:		Eric Silvestri
-- Create date: 09/12/2023
-- Description:	Exports data for PBJ Code Technology
-- Change Control
--	
-- =============================================

CREATE PROCEDURE [rpt].[spPBJCodeTechPatientList]

AS
BEGIN
SET NOCOUNT ON;
SET FMTONLY OFF;

--DECLARE @STARTDATE AS DATE 
--DECLARE @ENDDATE AS DATE

--SET @STARTDATE =  DATEADD(day,-30,DATEFROMPARTS(YEAR(GETDATE()),MONTH(GETDATE()),1)); 
--SET @ENDDATE = DATEADD(DAY,+30,DATEFROMPARTS(YEAR(GETDATE()),MONTH(GETDATE()),1)); 

--SELECT  replace(rtrim(ltrim([gpi.Patient_Name]))varchar(100), ',', '') as "Patient_Name"
--		,replace(rtrim(ltrim(gpa.Patient_ID)), ',', '') as "Patient_ID"
--		,replace(rtrim(ltrim(gsi.Actual_Dr_Name)), ',', '') as "Physician"
--		,replace(rtrim(ltrim(gsi.Billing_Dr_ID)), ',', '') as "Physician ID"
--		,replace(rtrim(ltrim(CONVERT(DATE,gpa.Appt_DateTime, 101))), ',', '') as "Apt Date" 
--		,replace(rtrim(ltrim(CONVERT(TIME,gpa.Appt_DateTime,8))), ',', '') as "Apt Time" 
--		,replace(rtrim(ltrim(CONVERT(DATE,gpa.Appt_Cancelled_Date,101))), ',', '') as "Appt_Cancelled_Date"
--		,replace(rtrim(ltrim(gpi.Patient_SSN)), ',', '') as "SSN"
--		,replace(rtrim(ltrim(CONVERT(DATE,gpi.Patient_DOB,101))), ',', '') as "DOB"
--		,replace(rtrim(ltrim(gpi.Patient_Age)), ',', '') as "Age"
--		,replace(rtrim(ltrim(gpi.Patient_Sex)), ',', '') as "Gender"
--		,replace(rtrim(ltrim(gpi.Patient_Marital_Status)), ',', '') as "Marital Status"
--		,replace(rtrim(ltrim(ai.Addit_Field2)), ',', '') as "Ethnicity"
--		,replace(rtrim(ltrim(ai.Addit_Field4)), ',', '') as "Language"
--		,replace(rtrim(ltrim(gpi.Patient_Street1)), ',', '') as "Street Adress"
--		,replace(rtrim(ltrim(gpi.Patient_Street2)), ',', '') as "Patient_Street2"
--		,replace(rtrim(ltrim(gpi.Patient_City)), ',', '') as "City"
--		,replace(rtrim(ltrim(gpi.Patient_State)), ',', '') as "State"
--		,replace(rtrim(ltrim(gpi.Patient_Zip_Code)), ',', '') as "Zip"
--		,replace(rtrim(ltrim(gpi.Patient_Home_Phone)), ',', '') as "Home_Phone"
--		,replace(rtrim(ltrim(gpi.Patient_Work_Phone)), ',', '') as "Work_Phone"
--		,replace(rtrim(ltrim(gpi.Patient_Cell_Phone)), ',', '') as "Cell_Phone"
--		,replace(rtrim(ltrim(gpi.Patient_Email)), ',', '') as "Patient_Email"
--		,replace(rtrim(ltrim(gpi.Prim_Policy_Carrier_Name)), ',', '') as "Primary Policy"
--		,replace(rtrim(ltrim(gpi.Prim_Policy_Carrier_ID)), ',', '') as "Prim_Policy_ID"
--		,replace(rtrim(ltrim(gpi.Prim_Policy_Group_No)), ',', '') as "Prim_Policy_Group_No"
--		,replace(rtrim(ltrim(gpi.Sec_Policy_Carrier_Name)), ',', '') as "Secondary Policy"
--		,replace(rtrim(ltrim(gpi.Sec_Policy_Carrier_ID)), ',', '') as "Sec_Policy_Carrier_ID"
--		,replace(rtrim(ltrim(gpi.Sec_Policy_Group_No)), ',', '') as "Sec_Policy_Group_No"
--		,replace(rtrim(ltrim(gpa.Appt_Comments)), ',', '') as "Appt_Comments"
--FROM         tievmdb03.Ntier_627200.pm.vwGenPatApptInfo gpa 
--	LEFT OUTER JOIN tievmdb03.Ntier_627200.pm.vwGenPatInfo gpi 
--		ON gpa.Patient_ID = gpi.Patient_ID 
--	LEFT OUTER JOIN tievmdb03.Ntier_627200.pm.vwGenPatAdditInfo ai
--		ON gpa.Patient_ID = ai.Patient_ID 
--	LEFT OUTER JOIN  tievmdb03.Ntier_627200.pm.vwGenSvcInfo gsi
--		ON gpa.Patient_ID = gsi.Patient_ID
--WHERE gpa.[Appt_Type_Descr] = 'SU60PBJ' and gpa.Appt_DateTime between @STARTDATE and @ENDDATE
--GROUP BY gpi.Patient_Name,
--		 gpa.Patient_ID,
--		 gsi.Actual_Dr_Name,
--		 gsi.Billing_Dr_ID,
--		 gpa.Appt_DateTime,
--		 gpa.Appt_DateTime,
--		 gpa.Appt_Cancelled_Date,
--		 gpi.Patient_SSN,
--		 gpi.Patient_DOB,
--		 gpi.Patient_Age,
--		 gpi.Patient_Sex,
--		 gpi.Patient_Marital_Status,
--		 gpi.Patient_Marital_Status,
--		 ai.Addit_Field2,ai.Addit_Field4,
--		 gpi.Patient_Street1,
--		 gpi.Patient_Street2,
--		 gpi.Patient_City,
--		 gpi.Patient_State,
--		 gpi.Patient_Zip_Code,
--		 gpi.Patient_Home_Phone,
--		 gpi.Patient_Work_Phone,
--		 gpi.Patient_Cell_Phone,
--		 gpi.Patient_Email,
--		 gpi.Prim_Policy_Carrier_Name,
--		 gpi.Prim_Policy_Carrier_ID,
--		 gpi.Prim_Policy_Group_No,
--		 gpi.Sec_Policy_Carrier_Name,
--		 gpi.Sec_Policy_Carrier_ID,
--		 gpi.Sec_Policy_Group_No,
--		 gpa.Appt_Comments
																																																									 
																																																									 
																																																									 
--END		

DECLARE @STARTDATE AS DATE 
DECLARE @ENDDATE AS DATE

SET @STARTDATE =  DATEADD(day,-30,DATEFROMPARTS(YEAR(GETDATE()),MONTH(GETDATE()),DAY(GETDATE()))); 
SET @ENDDATE = DATEADD(DAY,+30,DATEFROMPARTS(YEAR(GETDATE()),MONTH(GETDATE()),DAY(GETDATE()))); 

DROP TABLE IF EXISTS ##tempPBJCodeExport;

    CREATE TABLE ##tempPBJCodeExport (
        [Patient_Name] varchar(100)
        ,[Patient_ID] varchar(100)
        ,[Physician] varchar(100)
        ,[Physician ID] varchar(100)
		,[Apt Date] varchar(100)
		,[Apt Time] varchar(100)
		,[Appt_Cancelled_Date] varchar(100)
		,[SSN] varchar(100)
		,[DOB] varchar(100)
		,[Age] varchar(100)
		,[Gender] varchar(100)
		,[Marital Status] varchar(100)
		,[Ethnicity] varchar(100)
		,[Language] varchar(100)
		,[Street Address] varchar(100)
        ,[Patient_Street2] varchar(100)
        ,[City] varchar(100)
        ,[State] varchar(100)
		,[Zip] varchar(100)
		,[Home_Phone] varchar(100)
		,[Work_Phone] varchar(100)
		,[Cell_Phone] varchar(100)
		,[Patient_Email] varchar(100)
		,[Primary Policy] varchar(100)
		,[Prim_Policy_ID] varchar(100)
		,[Prim_Policy_Group_No] varchar(100)
		,[Secondary Policy] varchar(100)
		,[Sec_Policy_Carrier_ID] varchar(100)
		,[Sec_Policy_Group_No] varchar(100)
		,[Appt_Comments] varchar(100)
        )

		
    INSERT INTO ##tempPBJCodeExport


		SELECT  gpi.Patient_Name as "Patient_Name"
				,gpa.Patient_ID as "Patient_ID"
				,gsi.Actual_Dr_Name as "Physician"
				,gsi.Billing_Dr_ID as "Physician ID"
				,CONVERT(DATE,gpa.Appt_DateTime, 101) as "Apt Date" 
				--,CONVERT(TIME,gpa.Appt_DateTime,8) as "Apt Time" 
				,FORMAT(gpa.Appt_DateTime, 'HH:mm') as "Apt Time"
				,CONVERT(DATE,gpa.Appt_Cancelled_Date,101) as "Appt_Cancelled_Date"
				,gpi.Patient_SSN as "SSN"
				,CONVERT(DATE,gpi.Patient_DOB,101) as "DOB"
				,gpi.Patient_Age as "Age"
				,gpi.Patient_Sex as "Gender"
				,gpi.Patient_Marital_Status as "Marital Status"
				,ai.Addit_Field2 as "Ethnicity"
				,ai.Addit_Field4 as "Language"
				,gpi.Patient_Street1 as "Street Adress"
				,gpi.Patient_Street2 as "Patient_Street2"
				,gpi.Patient_City as "City"
				,gpi.Patient_State as "State"
				,gpi.Patient_Zip_Code as "Zip"
				,gpi.Patient_Home_Phone as "Home_Phone"
				,gpi.Patient_Work_Phone as "Work_Phone"
				,gpi.Patient_Cell_Phone as "Cell_Phone"
				,gpi.Patient_Email as "Patient_Email"
				,gpi.Prim_Policy_Carrier_Name as "Primary Policy"
				,gpi.Prim_Policy_Carrier_ID as "Prim_Policy_ID"
				,gpi.Prim_Policy_Group_No as "Prim_Policy_Group_No"
				,gpi.Sec_Policy_Carrier_Name as "Secondary Policy"
				,gpi.Sec_Policy_Carrier_ID as "Sec_Policy_Carrier_ID"
				,gpi.Sec_Policy_Group_No as "Sec_Policy_Group_No"
				,gpa.Appt_Comments as "Appt_Comments"
		FROM         tievmdb03.Ntier_627200.pm.vwGenPatApptInfo gpa 
			LEFT OUTER JOIN tievmdb03.Ntier_627200.pm.vwGenPatInfo gpi 
				ON gpa.Patient_ID = gpi.Patient_ID 
			LEFT OUTER JOIN tievmdb03.Ntier_627200.pm.vwGenPatAdditInfo ai
				ON gpa.Patient_ID = ai.Patient_ID 
			LEFT OUTER JOIN  tievmdb03.Ntier_627200.pm.vwGenSvcInfo gsi
				ON gpa.Patient_ID = gsi.Patient_ID
		WHERE gpa.[Appt_Type_Descr] = 'SU60PBJ' and gpa.Appt_DateTime between @STARTDATE and @ENDDATE
		GROUP BY gpi.Patient_Name,
				 gpa.Patient_ID,
				 gsi.Actual_Dr_Name,
				 gsi.Billing_Dr_ID,
				 gpa.Appt_DateTime,
				 gpa.Appt_DateTime,
				 gpa.Appt_Cancelled_Date,
				 gpi.Patient_SSN,
				 gpi.Patient_DOB,
				 gpi.Patient_Age,
				 gpi.Patient_Sex,
				 gpi.Patient_Marital_Status,
				 gpi.Patient_Marital_Status,
				 ai.Addit_Field2,ai.Addit_Field4,
				 gpi.Patient_Street1,
				 gpi.Patient_Street2,
				 gpi.Patient_City,
				 gpi.Patient_State,
				 gpi.Patient_Zip_Code,
				 gpi.Patient_Home_Phone,
				 gpi.Patient_Work_Phone,
				 gpi.Patient_Cell_Phone,
				 gpi.Patient_Email,
				 gpi.Prim_Policy_Carrier_Name,
				 gpi.Prim_Policy_Carrier_ID,
				 gpi.Prim_Policy_Group_No,
				 gpi.Sec_Policy_Carrier_Name,
				 gpi.Sec_Policy_Carrier_ID,
				 gpi.Sec_Policy_Group_No,
				 gpa.Appt_Comments

		Select
			* 
		FROM ##tempPBJCodeExport

END
GO
