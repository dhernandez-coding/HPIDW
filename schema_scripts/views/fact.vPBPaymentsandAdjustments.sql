CREATE VIEW [fact].[vPBPaymentsandAdjustments] AS
SELECT 
	t.[TransactionID]
      ,t.[TransactionDatasourceID]
      ,t.[TransactionSourceID]
      ,CONCAT(t.[TransactionDatasourceID],'~',t.[TransactionParentSourceID]) as TransactionParentSourceID
      ,t.[TransactionVisitID]
      ,t.[TransactionAccountID]
      ,t.[TransactionDepartmentID]
      ,t.[TransactionPayerID]
      ,t.[TransactionBillingProviderID]
      ,t.[TransactionBillingType]
      ,t.[TransactionType]
      ,t.[TransactionSubType]
      ,t.[TransactionRevenueCode]
      ,t.[TransactionRevenueCodeDescription]
      ,t.[TransactionCode]
      ,t.[TransactionDescription]
      ,t.[TransactionCPTCode]
      ,t.[TransactionCPTDescription]
      ,t.[TransactionModifier1]
      ,t.[TransactionModifier2]
      ,t.[TransactionModifier3]
      ,t.[TransactionModifier4]
      ,t.[TransactionUnits]
	  ,t.[TransactionActiveARAmount]
      ,t.[TransactionAmount]
      ,t.[TransactionRVU]
      ,t.[TransactionDateOfService]
      ,t.[TransactionDateOfPosting]
      ,t.[TransactionDateOfBilling]
      ,t.[TransactionDateOfVoid]
      ,t.[TransactionReportingPeriodID]
      ,t.[TransactionPlaceOfServiceCode]
      ,t.[TransactionPlaceOfServiceType]
      ,t.[TransactionPatientID]
      ,t.[TransactionGLType]
      ,t.[TransactionStatus]
      ,t.[TransactionIsActive]
      ,t.[TransactionUpdatedDateTime]
      ,t.[TransactionPayerPlanID]
	  ,CASE WHEN t.TransactionType = 'Adjustment' THEN
	  		CASE WHEN t.TransactionDescription like 'DEN -%' THEN 'Yes'
			     WHEN t.TransactionDescription like 'DEN-%' THEN 'Yes'
				 WHEN t.TransactionDescription in ('CBO INCLUSIVE/INCLUDED IN PMT OF OTHER SERVICE'													
													,'CBO MUE DENIED MAX/FREQUENCY/LIMIT EXCEEDED'
													,'CBO NO AUTHORIZATION/AUTHORIZATION REQUIRED'
													,'CBO PAST TIMELY FILING DEMO/OFFICE ERROR'
													,'WRITE-OFF (UNCOLLECTIBLE DENIAL)') THEN 'Yes'
				WHEN t.TransactionCode in ('EXPERIM','INCLUS','LACKMEDN','MUE','NOAUTH','NODOCUM','NONCOV','NONCOVPT',
											'PANONCO','PASTTIME','PASTTIML','BELOWMIN','UNDAPPL','POSTOP') THEN 'Yes'
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
				/* ----APM - Denial Adjustments----- */
				WHEN t.TransactionDescription = 'Experimental/unproven/investig denial' THEN 'Not Medically Necessary'
				WHEN t.TransactionDescription = 'Lacks Medical Necessity denial' THEN 'Not Medically Necessary'
				WHEN t.TransactionDescription = 'MUE Denied Max/Frequency limit exceeded' THEN 'Not Covered/Limit Exceeded'
				WHEN t.TransactionDescription = 'Not Authorized/No Referral -ins requires' THEN 'No Authorization'
				WHEN t.TransactionDescription = 'Lack of Documentation/serv not supported' THEN 'Not Covered/Limit Exceeded'
				WHEN t.TransactionDescription = 'Non Covered Non Billable to Patient' THEN 'No Authorization'
				WHEN t.TransactionDescription = 'NON COVERED PATIENT LIABLE' THEN 'No Authorization'
				WHEN t.TransactionDescription = 'PA Physician Assist Non Covered CPT Code' THEN 'Not Covered/Limit Exceeded'
				WHEN t.TransactionDescription = 'Past Timely Filing Demo/Office Error' THEN 'Past Timely Filing'
				WHEN t.TransactionDescription = 'Past Timely Filing or Appeal' THEN 'Past Timely Filing'
				WHEN t.TransactionDescription = 'BELOW MINIMUM REIMBURSEMENT FOR APPEAL' THEN 'Unspecified'
				WHEN t.TransactionDescription = 'Under Appeal Limit' THEN 'Unspecified'
				WHEN t.TransactionDescription = 'Inclusive/included in pymt of other serv' THEN 'Inclusive'
				WHEN t.TransactionDescription = 'Post Op Services/Global to prev surgery' THEN 'Not Covered/Limit Exceeded'
			 END
		 END as TransactionDenialType
FROM fact.TransactionsPB t
WHERE 1=1 
	AND t.TransactionType IN ('Payment', 'Adjustment')
	AND t.TransactionDateOfPosting >= DATEFROMPARTS(YEAR(GETDATE()) - 5, 1, 1)
GO
