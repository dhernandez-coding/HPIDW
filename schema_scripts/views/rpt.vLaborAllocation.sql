--select top 1000 * from [rpt].[vLaborAllocation]

CREATE VIEW [rpt].[vLaborAllocation] as


SELECT --DISTINCT
	[Employee_Id]
      ,[First_Name]
      ,[Last_Name]
      ,[Employee_EIN]
      ,[Default_Department]  
      ,[Pay_Type]
      ,cast([date] as Date) AS [Date]
      ,[Jobs_HR]
      ,[Bereavement_Hours] as Bereavement_Hours
      ,[COVID_19_Hours] as COVID_19_Hours
      ,[Call_Back_Hours] as [Call_Back_Hours]
      ,[Cancelled_Shift_Hours] as  [Cancelled_Shift_Hours] 
      ,[Case_Completion_Hours] as [Case_Completion_Hours] 
      ,[Case_Completion_OT_Hours] as [Case_Completion_OT_Hours]
      ,[Charge_Nurse_Hours] as [Charge_Nurse_Hours]
      ,[Do_NOT_USE_Paramedic_Critical_Shift_Pay_Hours] as [Do_NOT_USE_Paramedic_Critical_Shift_Pay_Hours]
      ,[EML_Overage_Hours] as [EML_Overage_Hours]
      ,[Education_Meeting_Hours] as [Education_Meeting_Hours]
      ,[Epic_Training_Hours] as [Epic_Training_Hours]
      ,[Evening_Shift_Base_Hours] as [Evening_Shift_Base_Hours] 
      ,[Evening_Shift_Imaging_Hours] as [Evening_Shift_Imaging_Hours]
      ,[Evening_Shift_Pharmacy_Hours]as [Evening_Shift_Pharmacy_Hours]
      ,[Evening_Shift_RN_PT_Hours] as [Evening_Shift_RN_PT_Hours]
      ,[Evening_Shift_Respiratory_Hours] as [Evening_Shift_Respiratory_Hours]
      ,[Extended_Medical_Leave_Hours]as [Extended_Medical_Leave_Hours]
      ,[Family_Medical_Leave_Act_Hours] as [Family_Medical_Leave_Act_Hours]
      ,[Friday_Day_Prime_Shift_Hours] as [Friday_Day_Prime_Shift_Hours]
      ,[Friday_Evening_Prime_Shift_Hours]as [Friday_Evening_Prime_Shift_Hours]
      ,[Holiday_Hours] as [Holiday_Hours]  
      ,[Holiday_Worked_Hours] as [Holiday_Worked_Hours]
      ,[ICU_Day_Shift_Hours] as [ICU_Day_Shift_Hours]
      ,[Inclement_Weather_Hours] as [Inclement_Weather_Hours]
      ,[Jury_Duty_Hours] as [Jury_Duty_Hours]
      ,[LC_Not_Paid_Hours] as [LC_Not_Paid_Hours]
      ,[LC_Paid_Hours] as [LC_Paid_Hours]   
      ,[Lead_Pay_Hours] as [Lead_Pay_Hours]
      ,[Leave_without_Pay_Hours] as [Leave_without_Pay_Hours]
      ,[Leave_without_Pay_FMLA_Hours] as [Leave_without_Pay_FMLA_Hours]
      ,[Night_Shift_Base_Hours] as [Night_Shift_Base_Hours]
      ,[Night_Shift_Imaging_Scrub_Tech_Hours] as [Night_Shift_Imaging_Scrub_Tech_Hours]
      ,[Night_Shift_Pharmacy_Hours] as [Night_Shift_Pharmacy_Hours]
      ,[Night_Shift_RN_PT_Hours] as [Night_Shift_RN_PT_Hours]
      ,[Night_Shift_Respiratory_Hours] as [Night_Shift_Respiratory_Hours]
      ,[On_Call_Hours_Hours] as [On_Call_Hours_Hours]
      ,[Other_Hours] as [Other_Hours] 
      ,((LEFT(Overtime_Hours,LEN(REPLACE(Overtime_Hours,'-','0:00')) - 3) * 60) + RIGHT(REPLACE(Overtime_Hours,'-','0:00'),2))/60 as [Overtime_Hours]
      ,[PCT_HUC_Critical_Shift_Pay_Hours] as [PCT_HUC_Critical_Shift_Pay_Hours]
      ,[PTO_Hours] as [PTO_Hours]
      ,[PTO_PAYOUT_Hours] as [PTO_PAYOUT_Hours]
      ,[PTO_Premium_Pay_Hours] as [PTO_Premium_Pay_Hours]
      ,[PTO1_Hours] as [PTO1_Hours] 
      ,[Physician_or_Mid_Level_Provider_Hours] as [Physician_or_Mid_Level_Provider_Hours]
      ,[Preceptor_Hours_Hours] as [Preceptor_Hours_Hours]
      ,[RN_Critical_Shift_Pay_Hours] as [RN_Critical_Shift_Pay_Hours]
      ,[Regular_Hours] as [Regular_Hours]
      ,[Sick_Hours] as [Sick_Hours]
      ,[Total_Hours_Hours] as [Total_Hours_Hours] 
      ,[UNPDOT_Hours] as [UNPDOT_Hours]
      ,[WAOT_Hours] as [WAOT_Hours]
      ,[WC_Hours] as [WC_Hours]
      ,[WC_FMLA_Hours] as [WC_FMLA_Hours]
      ,[WC_FMLA_LWOP_Hours] as [WC_FMLA_LWOP_Hours]
      ,[WC_LWOP_Hours]as [WC_LWOP_Hours]
      ,[WD_Shift_Base_Hours] as [WD_Shift_Base_Hours] 
      ,[WD_Shift_Imaging_Surgical_Tech_Hours] as [WD_Shift_Imaging_Surgical_Tech_Hours]
      ,[WD_Shift_Pharmacy_Hours] as [WD_Shift_Pharmacy_Hours]
      ,[WD_Shift_Prime_Imaging_Surgical_T_Hours] as [WD_Shift_Prime_Imaging_Surgical_T_Hours]
      ,[WD_Shift_Prime_RN_PT_Hours] as [WD_Shift_Prime_RN_PT_Hours] 
      ,[WD_Shift_RN_PT_Hours] as [WD_Shift_RN_PT_Hours]
      ,[WD_Shift_Respiratory_Hours] as [WD_Shift_Respiratory_Hours]
      ,[WE_Shift_Base_Hours] as [WE_Shift_Base_Hours]
      ,[WE_Shift_Imaging_Surgical_Tech_Hours] as [WE_Shift_Imaging_Surgical_Tech_Hours]
      ,[WE_Shift_Pharmacy_Hours] as [WE_Shift_Pharmacy_Hours]
      ,[WE_Shift_Prime_Imaging_Surgical_T_Hours] as [WE_Shift_Prime_Imaging_Surgical_T_Hours]
      ,[WE_Shift_Prime_Pharmacy_Hours] as [WE_Shift_Prime_Pharmacy_Hours]
      ,[WE_Shift_Prime_RN_PT_Hours] as [WE_Shift_Prime_RN_PT_Hours] 
      ,[WE_Shift_RN_PT_Hours] as [WE_Shift_RN_PT_Hours]
      ,[WE_Shift_Respiratory_Hours] as [WE_Shift_Respiratory_Hours]
      ,[WN_Shift_Base_Hours] as [WN_Shift_Base_Hours]
      ,[WN_Shift_Imaging_Surgical_Tech_Hours] as [WN_Shift_Imaging_Surgical_Tech_Hours]
      ,[WN_Shift_Pharmacy_Hours] as [WN_Shift_Pharmacy_Hours]
      ,[WN_Shift_Prime_Imaging_Surgical_T_Hours] as[WN_Shift_Prime_Imaging_Surgical_T_Hours]
      ,[WN_Shift_Prime_Pharmacy_Hours] as [WN_Shift_Prime_Pharmacy_Hours]
      ,[WN_Shift_Prime_RN_PT_Hours] as [WN_Shift_Prime_RN_PT_Hours]
      ,[WN_Shift_RN_PT_Hours]as [WN_Shift_RN_PT_Hours]
      ,[WN_Shift_Respiratory_Hours] as [WN_Shift_Respiratory_Hours] 
      ,[Worked_Hours_Hours] as [Worked_Hours_Hours]
      ,lpp.PayDate as [Paydate]
	  ,(((LEFT(Call_Back_Hours,LEN(REPLACE(Call_Back_Hours,'-','0:00')) - 3) * 60) + RIGHT(REPLACE(Call_Back_Hours,'-','0:00'),2)) --Call_Back_Hours
		+ ((LEFT(Case_Completion_Hours,LEN(REPLACE(Case_Completion_Hours,'-','0:00')) - 3) * 60) + RIGHT(REPLACE(Case_Completion_Hours,'-','0:00'),2)) --Case_Completion_Hours
		+ ((LEFT(Charge_Nurse_Hours,LEN(REPLACE(Charge_Nurse_Hours,'-','0:00')) - 3) * 60) + RIGHT(REPLACE(Charge_Nurse_Hours,'-','0:00'),2)) -- Charge_Nurse_Hours
		+ ((LEFT(Holiday_Worked_Hours,LEN(REPLACE(Holiday_Worked_Hours,'-','0:00')) - 3) * 60) + RIGHT(REPLACE(Holiday_Worked_Hours,'-','0:00'),2)) -- Holiday_Worked_Hours
		+ ((LEFT(Regular_Hours,LEN(REPLACE(Regular_Hours,'-','0:00')) - 3) * 60) + RIGHT(REPLACE(Regular_Hours,'-','0:00'),2)) -- Regular_Hours
		+ ((LEFT(Education_Meeting_Hours,LEN(REPLACE(Education_Meeting_Hours,'-','0:00')) - 3) * 60) + RIGHT(REPLACE(Education_Meeting_Hours,'-','0:00'),2)) -- Education_Meeting_Hours
		+ ((LEFT(Epic_Training_Hours,LEN(REPLACE(Epic_Training_Hours,'-','0:00')) - 3) * 60) + RIGHT(REPLACE(Epic_Training_Hours,'-','0:00'),2)) -- Epic_Training_Hours
		) / 60.0 as TotalWorkedHours
	 -- ,(((LEFT(Regular_Hours,LEN(REPLACE(Regular_Hours,'-','0:00')) - 3) * 60) + RIGHT(REPLACE(Regular_Hours,'-','0:00'),2)) --Regular_Hours
		--+ ((LEFT(Other_Hours,LEN(REPLACE(Other_Hours,'-','0:00')) - 3) * 60) + RIGHT(REPLACE(Other_Hours,'-','0:00'),2)) --Other_Hours
		--+ ((LEFT(PTO_Hours,LEN(REPLACE(PTO_Hours,'-','0:00')) - 3) * 60) + RIGHT(REPLACE(PTO_Hours,'-','0:00'),2)) -- PTO_Hours
		--+ ((LEFT(PTO_Premium_Pay_Hours,LEN(REPLACE(PTO_Premium_Pay_Hours,'-','0:00')) - 3) * 60) + RIGHT(REPLACE(PTO_Premium_Pay_Hours,'-','0:00'),2)) -- PTO_Premium_Pay_Hours
		--+ ((LEFT(Holiday_Hours,LEN(REPLACE(Holiday_Hours,'-','0:00')) - 3) * 60) + RIGHT(REPLACE(Holiday_Hours,'-','0:00'),2)) -- Holiday_Hours
		--) / 60.0 
		,null as TotalPaidHours 
	  ,CONCAT(Default_Department,lpp.PayDate) as UniqueID
	

FROM [HPIDW].[rpt].[LaborAllocation] la
  left join [HPIDW].map.LaborPayPeriods lpp ON (la.Date =lpp.PayPeriodDate)

  WHERE 1=1
  AND Date <> 'Date'
  AND Pay_Type <> 'Salaried'

--UNION ALL -- add hours for combined imaging departments


--SELECT --DISTINCT
--	[Employee_Id]
--      ,[First_Name]
--      ,[Last_Name]
--      ,[Employee_EIN]
--      ,CASE
--		WHEN Default_Department like 'Imaging%South' THEN 'Imaging South'
--		WHEN Default_Department like 'Imaging%North' THEN 'Imaging North'
--		WHEN Default_Department like 'Imaging%NWSH' THEN 'Imaging NWSH'

--	  END AS [Default_Department]  
--      ,[Pay_Type]
--      ,cast([date] as Date) AS [Date]
--      ,[Jobs_HR]
--      ,[Bereavement_Hours] as Bereavement_Hours
--      ,[COVID_19_Hours] as COVID_19_Hours
--      ,[Call_Back_Hours] as [Call_Back_Hours]
--      ,[Cancelled_Shift_Hours] as  [Cancelled_Shift_Hours] 
--      ,[Case_Completion_Hours] as [Case_Completion_Hours] 
--      ,[Case_Completion_OT_Hours] as [Case_Completion_OT_Hours]
--      ,[Charge_Nurse_Hours] as [Charge_Nurse_Hours]
--      ,[Do_NOT_USE_Paramedic_Critical_Shift_Pay_Hours] as [Do_NOT_USE_Paramedic_Critical_Shift_Pay_Hours]
--      ,[EML_Overage_Hours] as [EML_Overage_Hours]
--      ,[Education_Meeting_Hours] as [Education_Meeting_Hours]
--      ,[Epic_Training_Hours] as [Epic_Training_Hours]
--      ,[Evening_Shift_Base_Hours] as [Evening_Shift_Base_Hours] 
--      ,[Evening_Shift_Imaging_Hours] as [Evening_Shift_Imaging_Hours]
--      ,[Evening_Shift_Pharmacy_Hours]as [Evening_Shift_Pharmacy_Hours]
--      ,[Evening_Shift_RN_PT_Hours] as [Evening_Shift_RN_PT_Hours]
--      ,[Evening_Shift_Respiratory_Hours] as [Evening_Shift_Respiratory_Hours]
--      ,[Extended_Medical_Leave_Hours]as [Extended_Medical_Leave_Hours]
--      ,[Family_Medical_Leave_Act_Hours] as [Family_Medical_Leave_Act_Hours]
--      ,[Friday_Day_Prime_Shift_Hours] as [Friday_Day_Prime_Shift_Hours]
--      ,[Friday_Evening_Prime_Shift_Hours]as [Friday_Evening_Prime_Shift_Hours]
--      ,[Holiday_Hours] as [Holiday_Hours]  
--      ,[Holiday_Worked_Hours] as [Holiday_Worked_Hours]
--      ,[ICU_Day_Shift_Hours] as [ICU_Day_Shift_Hours]
--      ,[Inclement_Weather_Hours] as [Inclement_Weather_Hours]
--      ,[Jury_Duty_Hours] as [Jury_Duty_Hours]
--      ,[LC_Not_Paid_Hours] as [LC_Not_Paid_Hours]
--      ,[LC_Paid_Hours] as [LC_Paid_Hours]   
--      ,[Lead_Pay_Hours] as [Lead_Pay_Hours]
--      ,[Leave_without_Pay_Hours] as [Leave_without_Pay_Hours]
--      ,[Leave_without_Pay_FMLA_Hours] as [Leave_without_Pay_FMLA_Hours]
--      ,[Night_Shift_Base_Hours] as [Night_Shift_Base_Hours]
--      ,[Night_Shift_Imaging_Scrub_Tech_Hours] as [Night_Shift_Imaging_Scrub_Tech_Hours]
--      ,[Night_Shift_Pharmacy_Hours] as [Night_Shift_Pharmacy_Hours]
--      ,[Night_Shift_RN_PT_Hours] as [Night_Shift_RN_PT_Hours]
--      ,[Night_Shift_Respiratory_Hours] as [Night_Shift_Respiratory_Hours]
--      ,[On_Call_Hours_Hours] as [On_Call_Hours_Hours]
--      ,[Other_Hours] as [Other_Hours] 
--      ,((LEFT(Overtime_Hours,LEN(REPLACE(Overtime_Hours,'-','0:00')) - 3) * 60) + RIGHT(REPLACE(Overtime_Hours,'-','0:00'),2))/60 as [Overtime_Hours]
--      ,[PCT_HUC_Critical_Shift_Pay_Hours] as [PCT_HUC_Critical_Shift_Pay_Hours]
--      ,[PTO_Hours] as [PTO_Hours]
--      ,[PTO_PAYOUT_Hours] as [PTO_PAYOUT_Hours]
--      ,[PTO_Premium_Pay_Hours] as [PTO_Premium_Pay_Hours]
--      ,[PTO1_Hours] as [PTO1_Hours] 
--      ,[Physician_or_Mid_Level_Provider_Hours] as [Physician_or_Mid_Level_Provider_Hours]
--      ,[Preceptor_Hours_Hours] as [Preceptor_Hours_Hours]
--      ,[RN_Critical_Shift_Pay_Hours] as [RN_Critical_Shift_Pay_Hours]
--      ,[Regular_Hours] as [Regular_Hours]
--      ,[Sick_Hours] as [Sick_Hours]
--      ,[Total_Hours_Hours] as [Total_Hours_Hours] 
--      ,[UNPDOT_Hours] as [UNPDOT_Hours]
--      ,[WAOT_Hours] as [WAOT_Hours]
--      ,[WC_Hours] as [WC_Hours]
--      ,[WC_FMLA_Hours] as [WC_FMLA_Hours]
--      ,[WC_FMLA_LWOP_Hours] as [WC_FMLA_LWOP_Hours]
--      ,[WC_LWOP_Hours]as [WC_LWOP_Hours]
--      ,[WD_Shift_Base_Hours] as [WD_Shift_Base_Hours] 
--      ,[WD_Shift_Imaging_Surgical_Tech_Hours] as [WD_Shift_Imaging_Surgical_Tech_Hours]
--      ,[WD_Shift_Pharmacy_Hours] as [WD_Shift_Pharmacy_Hours]
--      ,[WD_Shift_Prime_Imaging_Surgical_T_Hours] as [WD_Shift_Prime_Imaging_Surgical_T_Hours]
--      ,[WD_Shift_Prime_RN_PT_Hours] as [WD_Shift_Prime_RN_PT_Hours] 
--      ,[WD_Shift_RN_PT_Hours] as [WD_Shift_RN_PT_Hours]
--      ,[WD_Shift_Respiratory_Hours] as [WD_Shift_Respiratory_Hours]
--      ,[WE_Shift_Base_Hours] as [WE_Shift_Base_Hours]
--      ,[WE_Shift_Imaging_Surgical_Tech_Hours] as [WE_Shift_Imaging_Surgical_Tech_Hours]
--      ,[WE_Shift_Pharmacy_Hours] as [WE_Shift_Pharmacy_Hours]
--      ,[WE_Shift_Prime_Imaging_Surgical_T_Hours] as [WE_Shift_Prime_Imaging_Surgical_T_Hours]
--      ,[WE_Shift_Prime_Pharmacy_Hours] as [WE_Shift_Prime_Pharmacy_Hours]
--      ,[WE_Shift_Prime_RN_PT_Hours] as [WE_Shift_Prime_RN_PT_Hours] 
--      ,[WE_Shift_RN_PT_Hours] as [WE_Shift_RN_PT_Hours]
--      ,[WE_Shift_Respiratory_Hours] as [WE_Shift_Respiratory_Hours]
--      ,[WN_Shift_Base_Hours] as [WN_Shift_Base_Hours]
--      ,[WN_Shift_Imaging_Surgical_Tech_Hours] as [WN_Shift_Imaging_Surgical_Tech_Hours]
--      ,[WN_Shift_Pharmacy_Hours] as [WN_Shift_Pharmacy_Hours]
--      ,[WN_Shift_Prime_Imaging_Surgical_T_Hours] as[WN_Shift_Prime_Imaging_Surgical_T_Hours]
--      ,[WN_Shift_Prime_Pharmacy_Hours] as [WN_Shift_Prime_Pharmacy_Hours]
--      ,[WN_Shift_Prime_RN_PT_Hours] as [WN_Shift_Prime_RN_PT_Hours]
--      ,[WN_Shift_RN_PT_Hours]as [WN_Shift_RN_PT_Hours]
--      ,[WN_Shift_Respiratory_Hours] as [WN_Shift_Respiratory_Hours] 
--      ,[Worked_Hours_Hours] as [Worked_Hours_Hours]
--      ,lpp.PayDate as [Paydate]
--	  ,(((LEFT(Call_Back_Hours,LEN(REPLACE(Call_Back_Hours,'-','0:00')) - 3) * 60) + RIGHT(REPLACE(Call_Back_Hours,'-','0:00'),2)) --Call_Back_Hours
--		+ ((LEFT(Case_Completion_Hours,LEN(REPLACE(Case_Completion_Hours,'-','0:00')) - 3) * 60) + RIGHT(REPLACE(Case_Completion_Hours,'-','0:00'),2)) --Case_Completion_Hours
--		+ ((LEFT(Charge_Nurse_Hours,LEN(REPLACE(Charge_Nurse_Hours,'-','0:00')) - 3) * 60) + RIGHT(REPLACE(Charge_Nurse_Hours,'-','0:00'),2)) -- Charge_Nurse_Hours
--		+ ((LEFT(Holiday_Worked_Hours,LEN(REPLACE(Holiday_Worked_Hours,'-','0:00')) - 3) * 60) + RIGHT(REPLACE(Holiday_Worked_Hours,'-','0:00'),2)) -- Holiday_Worked_Hours
--		+ ((LEFT(Regular_Hours,LEN(REPLACE(Regular_Hours,'-','0:00')) - 3) * 60) + RIGHT(REPLACE(Regular_Hours,'-','0:00'),2)) -- Regular_Hours
--		+ ((LEFT(Education_Meeting_Hours,LEN(REPLACE(Education_Meeting_Hours,'-','0:00')) - 3) * 60) + RIGHT(REPLACE(Education_Meeting_Hours,'-','0:00'),2)) -- Education_Meeting_Hours
--		+ ((LEFT(Epic_Training_Hours,LEN(REPLACE(Epic_Training_Hours,'-','0:00')) - 3) * 60) + RIGHT(REPLACE(Epic_Training_Hours,'-','0:00'),2)) -- Epic_Training_Hours
--		) / 60.0 as TotalWorkedHours
--	 -- ,(((LEFT(Regular_Hours,LEN(REPLACE(Regular_Hours,'-','0:00')) - 3) * 60) + RIGHT(REPLACE(Regular_Hours,'-','0:00'),2)) --Regular_Hours
--		--+ ((LEFT(Other_Hours,LEN(REPLACE(Other_Hours,'-','0:00')) - 3) * 60) + RIGHT(REPLACE(Other_Hours,'-','0:00'),2)) --Other_Hours
--		--+ ((LEFT(PTO_Hours,LEN(REPLACE(PTO_Hours,'-','0:00')) - 3) * 60) + RIGHT(REPLACE(PTO_Hours,'-','0:00'),2)) -- PTO_Hours
--		--+ ((LEFT(PTO_Premium_Pay_Hours,LEN(REPLACE(PTO_Premium_Pay_Hours,'-','0:00')) - 3) * 60) + RIGHT(REPLACE(PTO_Premium_Pay_Hours,'-','0:00'),2)) -- PTO_Premium_Pay_Hours
--		--+ ((LEFT(Holiday_Hours,LEN(REPLACE(Holiday_Hours,'-','0:00')) - 3) * 60) + RIGHT(REPLACE(Holiday_Hours,'-','0:00'),2)) -- Holiday_Hours
--		--) / 60.0 
--		,null as TotalPaidHours 
--	  ,CONCAT(Default_Department,lpp.PayDate) as UniqueID
	

--FROM [HPIDW].[rpt].[LaborAllocation] la
--  left join [HPIDW].map.LaborPayPeriods lpp ON (la.Date =lpp.PayPeriodDate)

--  WHERE 1=1
--  AND Date <> 'Date'
--  AND Pay_Type <> 'Salaried'
--  AND Default_Department like 'imaging%'
GO
