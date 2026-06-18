CREATE view [rpt].[vAllergyReportsPB] as

select																		
	REPLACE(t2.TransactionVisitID, '1~','') as Voucher																	
	,REPLACE(t2.TransactionSourceID, 'PB~','') as TransactionID																	
	,t2.TransactionDateOfService as ServiceDate																																
	,t2.TransactionReportingPeriodID as ReportingPeriod	
	,t2.TransactionBillingProviderID																																
	--,pr.ProviderFullName as BillingProvider
	,t2.PatientID
	--,pat.PatientMRN
	--,pat.PatientFullName																	
	,p.PayerName as Payer																																	
	,t2.TransactionCode as ProcedureCode																	
	--,t2.TransactionDescription as ProcedureCodeDescription																	
	,cat.ProcedureCategory as ProcedureCategory																																	
	--,t2.TransactionUnits as ChargeUnits																	
	,ISNULL(t2.TransactionAmount,0) as Charges																	
	,ISNULL(pa.Adjustments,0) as Adjustments																	
	,ISNULL(pa.TotalPayments,0) as TotalPayments																	
	--,ISNULL(pa.InsurancePayments,0) as InsurancePayments																	
	--,ISNULL(pa.PatientPayments,0) as PatientPayments																	
	--,ISNULL(t2.TransactionAmount,0) 
	--	+ ISNULL(pa.Adjustments,0)
	--	+ ISNULL(pa.TotalPayments,0) as Balance															
from fact.Transactions2 t2 																		
	left join dim.Payers p ON p.PayerID = t2.TransactionPayerID																	
	left join dim.PayerCategories pc ON pc.PayerCategoryID = p.PayerCategoryID																	
	left join dim.PayerGroups pg ON pg.PayerGroupID = p.PayerGroupID																	
	left join dim.vProviders pr ON pr.ProviderID = t2.TransactionBillingProviderID																	
	left join dim.vPBProcedureCodeCategories c ON c.ProcedureCode = t2.TransactionCode	
	--left join dim.vPatients pat on pat.PatientID = t2.PatientID																
	left join [HERO-DB].hpi.dbo.PBProcedureCategoriess cat ON cat.ProcedureCategory = CASE WHEN c.ProcedureCodeIsLocationDependent = 1 and t2.TransactionPlaceOfServiceCode in ('21','22') THEN 'Outpatient Procedures' 																	
																		  WHEN c.ProcedureCodeIsLocationDependent = 1 and t2.TransactionPlaceOfServiceCode not in ('21','22') THEN 'In Office Procedures'
																		  ELSE c.ProcedureCodeCategory END
	left join (select 																	
				t2.TransactionDatasourceID
				,t2.TransactionParentSourceID														
				,SUM(CASE WHEN t2.TransactionType = 'Adjustment' THEN t2.TransactionAmount ELSE 0 END) as Adjustments														
				--,SUM(CASE WHEN t2.TransactionType = 'Payment' AND pg.PayerGroupName <> 'Self-Pay' THEN t2.TransactionAmount ELSE 0 END) as InsurancePayments														
				--,SUM(CASE WHEN t2.TransactionType = 'Payment' AND pg.PayerGroupName = 'Self-Pay' THEN t2.TransactionAmount ELSE 0 END) as PatientPayments														
				,SUM(CASE WHEN t2.TransactionType = 'Payment' THEN t2.TransactionAmount ELSE 0 END) as TotalPayments														
				from fact.Transactions2 t2 														
					left join dim.Payers p on p.PayerID = t2.TransactionPayerID													
					left join dim.PayerGroups pg ON pg.PayerGroupID = p.PayerGroupID													
				where 1=1														
				and t2.TransactionBillingType = 'PB'														
				and t2.TransactionType <> 'Charge'														
				and t2.TransactionDatasourceID in (1,5) 																											
				group by 														
					t2.TransactionDatasourceID,t2.TransactionParentSourceID ) pa ON pa.TransactionDatasourceID = t2.TransactionDatasourceID AND pa.TransactionParentSourceID = t2.TransactionSourceID													
where 1=1																		
	AND t2.TransactionBillingType = 'PB'																	
	--AND t2.TransactionType = 'Charge'
	AND pr.ProviderAbbreviation IN ('WSB','GPK','LLK','JML')
	AND cat.ProcedureCategory = 'Allergy Evaluation Visit'																	
	AND DATEFROMPARTS(left(t2.TransactionReportingPeriodID,4),right(t2.TransactionReportingPeriodID,2),1) >= '1/1/2022'	
	--and pa.TransactionParentSourceID = '1~26539510'



--select
	
--	--t.TransactionDatasourceID
--	--,t.TransactionParentSourceID
--	--,t.TransactionSourceID
--	--,tc.TransactionCode as ChargeCode
--	--,tc.TransactionDescription as ChargeDescription
--	tc.TransactionDateOfPosting as ChargePostDate
--	,tc.TransactionAmount as ChargeAmount	
--	--,t.TransactionType
--	--,t.TransactionSubType
--	,t.TransactionDateOfService
--	,t.TransactionDateOfPosting
--	,t.TransactionReportingPeriodID
--	,t.TransactionAmount
--	,CASE WHEN t.TransactionType = 'Charge' THEN ISNULL(t.TransactionAmount,0) END as Charges														
--	,CASE WHEN t.TransactionType = 'Adjustment' THEN ISNULL(t.TransactionAmount,0) END as Adjustments																
--	,CASE WHEN t.TransactionType = 'Payment' THEN ISNULL(t.TransactionAmount,0) END as Payments	
--	--,t.TransactionCode
--	--,t.TransactionDescription
--	--,t.*
--from fact.transactions2	t
--	left join fact.Transactions2 tc ON tc.TransactionBillingType = 'PB'
--									AND tc.TransactionDatasourceID = t.TransactionDatasourceID
--									AND tc.TransactionSourceID = t.TransactionParentSourceID
--									AND tc.TransactionType = 'Charge'
--where 1=1
--	AND t.TransactionBillingType ='PB'
--	AND DATEFROMPARTS(left(t.TransactionReportingPeriodID,4),right(t.TransactionReportingPeriodID,2),1) >= '1/1/2021'	
--	AND t.TransactionAccountID = '1~27332380'
GO
