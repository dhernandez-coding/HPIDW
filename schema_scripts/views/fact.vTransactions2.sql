CREATE view [fact].[vTransactions2] as

SELECT
	[TransactionID]
	,[TransactionDatasourceID]
	,[TransactionSourceID]
	,[TransactionParentSourceID]
	,[TransactionVisitID]
	,[TransactionAccountID]
	,[TransactionEncounterID]
	,[TransactionDepartmentID]
	,[TransactionPayerID]
	,[TransactionBillingProviderID]
	,[TransactionBillingType]
	,[TransactionType]
	,[TransactionSubType]
	,[TransactionRevenueCode]
	,[TransactionRevenueCodeDescription]
	,[TransactionCode]
	,[TransactionDescription]
	,[TransactionCPTCode]
	,[TransactionModifier1]
	,[TransactionModifier2]
	,[TransactionModifier3]
	,[TransactionModifier4]
	,[TransactionUnits]
	,[TransactionAmount]
	,[TransactionRVU]
	,[TransactionDateOfService]
	,[TransactionDateOfPosting]
	,[TransactionDateOfBilling]
	,[TransactionDateOfVoid]
	,[TransactionReportingPeriodID]
	,[TransactionStatus]
	,CASE WHEN t.TransactionType = 'Charge' and (ISNUMERIC(t.TransactionCPTCode) = 1 or t.TransactionCPTCode is null)
			   AND (t.TransactionRevenueCode  in ('610','611','612','614','615','0610','0611','0612','0614','0615')
					OR t.TransactionCode in ('4192471','4192472','4192473','4192474','4192476','4192477','4192478','4192480','4192482','4192483'
											,'4192484','4192485','4192486','4192487','4192488','4192489','4192490','4192491'
											,'4192492','4192493','4192494','4192495','4192496','4192497','4192498','4192502'
											,'4192503','4192505','4193000','4193002','4193003','4193004','4193005','4193006'
											,'4193007','4193008','4193009','4192512','4192521','4193010','4193011','4192488'
											,'4192490','4192493','4192495','4193002','4193007')) THEN 'Yes' ELSE 'No' END as TransactionIsMRICharge
	,CASE WHEN t.TransactionType = 'Charge' AND t.TransactionRevenueCode in ('350','351','352','0350','0351','0352') THEN 'Yes' ELSE 'No' END as TransactionIsCTCharge
	,CASE WHEN t.TransactionType = 'Charge' AND t.TransactionRevenueCode in ('401','403','0401','0403') THEN 'Yes' ELSE 'No' END as TransactionIsMammoCharge
	,CASE WHEN t.TransactionType = 'Charge' AND t.TransactionRevenueCode in ('402','483','921','0402','0483','0921') THEN 'Yes' ELSE 'No' END as TransactionIsUltrasoundCharge
	,case
		when t.TransactionType = 'Charge' and (ISNUMERIC(t.TransactionCPTCode) = 1 or t.TransactionCPTCode is null)
		then
			case
				when
			   (t.TransactionRevenueCode  in ('610','611','612','614','615','0610','0611','0612','0614','0615')
				OR t.TransactionCode in ('4192471','4192472','4192473','4192474','4192476','4192477','4192478','4192480','4192482','4192483'
											,'4192484','4192485','4192486','4192487','4192488','4192489','4192490','4192491'
											,'4192492','4192493','4192494','4192495','4192496','4192497','4192498','4192502'
											,'4192503','4192505','4193000','4193002','4193003','4193004','4193005','4193006'
											,'4193007','4193008','4193009','4192512','4192521','4193010','4193011','4192488'
											,'4192490','4192493','4192495','4193002','4193007'))
				then '0~11' -- mri
		else
			CASE
				when t.TransactionRevenueCode in ('350','351','352','0350','0351','0352') 
				then '0~10' -- ct
		else
			CASE
				when t.TransactionRevenueCode in ('401','403','0401','0403')
				then '0~15' -- mammo
		else
			CASE
				when t.TransactionRevenueCode in ('402','483','921','0402','0483','0921')
				then '0~14' -- ultrasound
		end end end end end as TransactionImagingType
	,CASE WHEN t.TransactionType = 'Adjustment' THEN
			CASE WHEN t.TransactionDescription like 'DEN -%' THEN 'Yes'
			     WHEN t.TransactionDescription like 'DEN-%' THEN 'Yes'
				 WHEN t.TransactionDescription in ('CBO INCLUSIVE/INCLUDED IN PMT OF OTHER SERVICE'													
													,'CBO MUE DENIED MAX/FREQUENCY/LIMIT EXCEEDED'
													,'CBO NO AUTHORIZATION/AUTHORIZATION REQUIRED'
													,'CBO PAST TIMELY FILING DEMO/OFFICE ERROR'
													,'WRITE-OFF (UNCOLLECTIBLE DENIAL)') THEN 'Yes'
				
				 ELSE 'No' END
		  ELSE 'No'	END as TransactionIsDenial
	,CASE WHEN t.TransactionType = 'Adjustment' THEN
				/* ----EPIC - Denial Adjustments----- */
		  CASE WHEN t.TransactionDescription = 'DEN - BENEFITS EXHAUSTED' THEN 'Benefits Exhausted'
				WHEN t.TransactionDescription = 'DEN - BILLING ERROR' THEN 'Billing Error'
				WHEN t.TransactionDescription = 'DEN - FREQUENCY, LENGTH, DOSAGE, DAY''S SUPPLY' THEN 'Not Covered/Limit Exceeded'
				WHEN t.TransactionDescription = 'DEN - LATE OR NO NOTIFICATION' THEN 'Past Timely Filing'
				WHEN t.TransactionDescription = 'DEN - LEVEL OF SERVICE/CARE - HOSPITAL ACQUITY' THEN 'Level of Care'
				WHEN t.TransactionDescription = 'DEN - MED POL/PROC DEEMED EXPERIMENTAL/NOT APRVD BY FDA' THEN 'Not Medically Necessary'
				WHEN t.TransactionDescription = 'DEN - MEDICAL NECESSITY' THEN 'Not Medically Necessary'
				WHEN t.TransactionDescription = 'DEN - NO AUTH - AUTH NOT APPROVED (NAANA)' THEN 'No Authorization'
				WHEN t.TransactionDescription = 'DEN - NO AUTH - DOS OUTSIDE ORIGINAL AUTH (NADE)' THEN 'No Authorization'
				WHEN t.TransactionDescription = 'DEN - NO AUTH - PT REGISTERED WRONG (NAR)' THEN 'No Authorization'
				WHEN t.TransactionDescription = 'DEN - NO AUTHORIZATION NOT ATTEMPTED' THEN 'No Authorization'
				WHEN t.TransactionDescription = 'DEN - NO AUTO - AUTH ON FILE (NAAF)' THEN 'No Authorization'
				WHEN t.TransactionDescription = 'DEN - NO PRECERT/AUTH/NOTIFICATION' THEN 'No Authorization'
				WHEN t.TransactionDescription = 'DEN - NON-COVERED SERVICE' THEN 'No Authorization'
				WHEN t.TransactionDescription = 'DEN - PYMT INCLUDES PYMT FOR OTHER SVC/PROC NOT PD SEPARATELY' THEN 'Inclusive'
				WHEN t.TransactionDescription = 'DEN - TIMELY CLAIM NOT FILED' THEN 'Past Timely Filing'
				WHEN t.TransactionDescription = 'DEN - TIMELY ELIGIBILITY/INCORRECT INSURANCE' THEN 'Past Timely Filing'
				WHEN t.TransactionDescription = 'DEN - TIMELY PAST APPEAL DEADLINE' THEN 'Past Timely Filing'
				WHEN t.TransactionDescription = 'DEN-NO AUTHORIZATION-CLINICAL SUBMITTED BUT NOT RECEIVED' THEN 'No Authorization'
				WHEN t.TransactionDescription = 'CBO INCLUSIVE/INCLUDED IN PMT OF OTHER SERVICE' THEN 'Inclusive'
				WHEN t.TransactionDescription = 'CBO MUE DENIED MAX/FREQUENCY/LIMIT EXCEEDED' THEN 'Not Covered/Limit Exceeded'
				WHEN t.TransactionDescription = 'CBO NO AUTHORIZATION/AUTHORIZATION REQUIRED' THEN 'No Authorization'
				WHEN t.TransactionDescription = 'CBO PAST TIMELY FILING DEMO/OFFICE ERROR' THEN 'Past Timely Filing'
				WHEN t.TransactionDescription = 'WRITE-OFF (UNCOLLECTIBLE DENIAL)' THEN 'Unspecified'
				WHEN t.TransactionDescription like 'DEN -%' OR t.TransactionDescription like 'DEN-%' THEN 'Unspecified'
			 END
		 END as TransactionDenialType
	,TransactionAdjustmentCategory
	,[TransactionIsActive]
	,[TransactionUpdatedDateTime]
FROM [HPIDW].[fact].[Transactions2] t
	
where 1=1 
	AND YEAR(t.TransactionDateOfPosting) >= (year(getdate()) - 3)
GO
