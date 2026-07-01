-- 2/16/2026 - Diego Hernandez - I remove some columns that are redundant if we include this on the dataset and we reference the dim tables. 

CREATE VIEW [fact].[vDenialsPB] AS


SELECT
	d.[DenialID]
	,d.DenialDataSourceID
	,d.[DenialTransactionID] 
	,d.[DenialTransactionChargeID]
	,t.TransactionAccountID				AS DenialAccountID
	,d.[ChargePostingDate] 
	,d.[ChargeServiceDate] 
	,d.[DenialReceiveDate]
	,d.[DenialProcedureID] 
	,pc.ProcedureCodeCategoryDescription AS DenialProcedureDescription
	,d.[DenialPatientID]
	,pt.PatientFullName					AS DenialPatientName
	,l.LocationName				 AS DenialLocationName  --	
	,d.DenialLocationID
	,d.[DenialDepartmentID]				 
	,dt.DepartmentName					 AS DenialDepartmentName
	,d.[DenialBillingProviderID]		 
	,bp.ProviderFullName				 AS DenialBillingProviderName
	,ptb.PracticeID						 AS DenialBillingPracticeID
	,ptb.PracticeName					 AS DenialBillingPracticeName
	,ptb.PracticeAbbreviation			 AS DenialBillingPracticeAbbreviation
	,d.[DenialServiceProviderID]		 
	,sp.ProviderFullName				 AS DenialServiceProviderName
	,pts.PracticeID						 AS DenialServicePracticeID
	,pts.PracticeName					 AS DenialServicePracticeName
	,pts.PracticeAbbreviation			 AS DenialServicePracticeAbbreviation
	,d.[DenialPayerID]					 
	,py.PayerName						 AS DenialPayerName
	,py.PayerGroupName					 AS DenialPayerGroup
	,py.PayerCategoryName				 AS DenialPayerCategory
	,d.[DenialPayerPlanID]				 
	,pyp.PayerPlanName					 AS DenialPayerPlanName
	,d.[DenialProcedureCode] 
	,d.[DenialDiagnosisID] 
	,d.[DenialInvoiceNumber] 
	,d.[DenialReasonCode]
	,d.[DenialReasonDescription]
	,d.[DenialCategory]
	,d.[DenialCause]
	,d.[DenialRootCause] 
	,d.[DenialReasonGroup]
	,d.[DenialResolutionCategory]
	,d.[DenialStatus]
	,d.[DenialIsPrimary]
	,d.[DenialIsFirst] 
	,d.[DenialPostingDate] 
	,d.[DenialCompletionDate]
	,d.[DenialDaysToClose] 
	,d.[DenialAmount]
	,d.[DenialRecoveryAmount]
	,d.[DenialAdjustmentAmount] 
	,d.[DenialBillingAmount]
	,CASE WHEN d.[DenialAdjustmentAmount] IS NULL THEN 'No' ELSE 'Yes' END as DenialWriteOffFlag
	,d.[DenialUpdateDate]
FROM fact.DenialsPB d
	LEFT JOIN fact.vTransactionsPB t on t.TransactionSourceID = d.DenialTransactionID
	LEFT JOIN dim.ProcedureCodes pc ON d.DenialProcedureCode = pc.ProcedureCode
	LEFT JOIN dim.locations l ON d.DenialLocationID = l.LocationID
	LEFT JOIN dim.Departments dt ON d.DenialDepartmentID = dt.DepartmentID
	LEFT JOIN dim.vPayers py ON d.DenialPayerID = py.PayerID
	LEFT JOIN dim.PayerPlans pyp ON d.DenialPayerPlanID = pyp.PayerPlanID
----------- JOIN in service providers' practices
	LEFT JOIN dim.vProviders sp ON d.DenialServiceProviderID = sp.ProviderID
	LEFT JOIN map.ProviderLinking pls ON pls.ChildProviderID = d.DenialServiceProviderID
	LEFT JOIN map.PracticeDepartments pds ON pds.DepartmentID = d.DenialDepartmentID
	LEFT JOIN map.vPracticeProviders pps ON pps.ParentProviderID = pls.ParentProviderID
											AND pps.PracticeProviderEffectiveDate <= d.ChargePostingDate 
											AND pps.PracticeProviderEndDate >= d.ChargePostingDate
												--/*This is here to handle duplicates with Amy James and Murphi Scarborough at multiple practices*/
												--AND ((t.TransactionBillingProviderID in ('1~19898','5~126867','1~19711','5~125582') AND (pp.PracticeID = pd.PracticeID OR (pd.PracticeID is null AND t.TransactionBillingProviderID = pp.ProviderID)))
												--	  OR t.TransactionBillingProviderID not in ('1~19898','5~126867','1~19711','5~125582'))
												----AND pp.ProviderID = t.TransactionBillingProviderID
	LEFT JOIN dim.vPractices pts ON pts.PracticeID = COALESCE(pds.PracticeID,pps.PracticeID)
----------- JOIN in biling providers' practices
	LEFT JOIN dim.vProviders bp ON d.DenialBillingProviderID = bp.ProviderID
	LEFT JOIN map.ProviderLinking plb ON plb.ChildProviderID = d.DenialBillingProviderID
	LEFT JOIN map.PracticeDepartments pdb ON pdb.DepartmentID = d.DenialDepartmentID
	LEFT JOIN map.vPracticeProviders ppb ON ppb.ParentProviderID = plb.ParentProviderID
											AND ppb.PracticeProviderEffectiveDate <= d.ChargePostingDate 
											AND ppb.PracticeProviderEndDate >= d.ChargePostingDate
												--/*This is here to handle duplicates with Amy James and Murphi Scarborough at multiple practices*/
												--AND ((t.TransactionBillingProviderID in ('1~19898','5~126867','1~19711','5~125582') AND (pp.PracticeID = pd.PracticeID OR (pd.PracticeID is null AND t.TransactionBillingProviderID = pp.ProviderID)))
												--	  OR t.TransactionBillingProviderID not in ('1~19898','5~126867','1~19711','5~125582'))
												----AND pp.ProviderID = t.TransactionBillingProviderID
	LEFT JOIN dim.vPractices ptb ON ptb.PracticeID = COALESCE(pdb.PracticeID,ppb.PracticeID)
	LEFT JOIN dim.vPatients pt on pt.PatientID = d.DenialPatientID

GROUP BY
	d.[DenialID]
	,d.DenialDataSourceID
	,d.[DenialTransactionID] 
	,d.[DenialTransactionChargeID]
	,t.TransactionAccountID
	,d.[ChargePostingDate] 
	,d.[ChargeServiceDate] 
	,d.[DenialReceiveDate]
	,d.[DenialProcedureID] 
	,pc.ProcedureCodeCategoryDescription
	,l.LocationID 
	,d.[DenialPatientID]
	,pt.PatientFullName	
	,d.[DenialLocationID]
	,l.LocationName						
	,d.[DenialDepartmentID]				
	,dt.DepartmentName					
	,d.[DenialBillingProviderID]		
	,bp.ProviderFullName				
	,ptb.PracticeID						
	,ptb.PracticeName					
	,ptb.PracticeAbbreviation			
	,d.[DenialServiceProviderID]		
	,sp.ProviderFullName				
	,pts.PracticeID						
	,pts.PracticeName					
	,pts.PracticeAbbreviation			
	,d.[DenialPayerID]					
	,py.PayerName						
	,py.PayerGroupName					
	,py.PayerCategoryName				
	,d.[DenialPayerPlanID]				
	,pyp.PayerPlanName					
	,d.[DenialProcedureCode] 
	,d.[DenialDiagnosisID] 
	,d.[DenialInvoiceNumber] 
	,d.[DenialReasonCode]
	,d.[DenialReasonDescription]
	,d.[DenialCategory]
	,d.[DenialCause]
	,d.[DenialRootCause] 
	,d.[DenialReasonGroup]
	,d.[DenialResolutionCategory]
	,d.[DenialStatus]
	,d.[DenialIsPrimary]
	,d.[DenialIsFirst] 
	,d.[DenialPostingDate] 
	,d.[DenialCompletionDate]
	,d.[DenialDaysToClose] 
	,d.[DenialAmount]
	,d.[DenialRecoveryAmount]
	,d.[DenialAdjustmentAmount] 
	,d.[DenialBillingAmount]
	,d.[DenialUpdateDate]
GO
