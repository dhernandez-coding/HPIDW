CREATE VIEW [rpt].[vPBChargeDetail] as

/*
	Change Control:
		1. 9/4/24 - Chris Cross - Replaced fact.Transactions2 with fact.TransactionsPB
		2. 9/30/24 - Eric Silvestri - added TransactionPatientID to join dim.Patients in PBI
		3. 6/2/2026 - Chris Cross - Replaced HPIApp.dbo.PBProcedureCategories with [HERO-DB].hpi.dbo.PBProcedureCategoriess to look at new HERO app
		3. 7/22/2026 - Logan Richardson - Replaced [HERO-DB].hpi.dbo.PBProcedureCategoriess with dim.vPBProcedureCategories
*/

select																		
	REPLACE(t2.TransactionVisitID, '1~','') as Voucher																	
	,t2.TransactionSourceID as TransactionID	
	,t2.TransactionPatientID as PatientID
	,t2.TransactionDateOfService as ServiceDate																	
	,t2.TransactionDateOfPosting as PostingDate																	
	,t2.TransactionReportingPeriodID as ReportingPeriod																	
	,t2.TransactionSubType as TransactionType																	
	,pr.ProviderFullName as BillingProvider																	
	,p.PayerName as Payer																	
	,pc.PayerCategoryName as PayerCategory																	
	,pg.PayerGroupName as PayerGroup																	
	,t2.TransactionCode as ProcedureCode																	
	,t2.TransactionDescription as ProcedureCodeDescription																	
	,cat.ProcedureCategory as ProcedureCategory																	
	,cat.ProcedureCategoryVisitType as ProcedureVisitType																	
	,t2.TransactionUnits as ChargeUnits																	
	,ISNULL(t2.TransactionAmount,0) as Charges																	
	,ISNULL(pa.Adjustments,0) as Adjustments																	
	,ISNULL(pa.TotalPayments,0) as TotalPayments																	
	,ISNULL(pa.InsurancePayments,0) as InsurancePayments																	
	,ISNULL(pa.PatientPayments,0) as PatientPayments																	
	,ISNULL(t2.TransactionAmount,0) 
		+ ISNULL(pa.Adjustments,0)
		+ ISNULL(pa.TotalPayments,0) as Balance
	,t2.TransactionPlaceOfServiceCode																	
from fact.TransactionsPB t2 																		
	left join dim.Payers p ON p.PayerID = t2.TransactionPayerID																	
	left join dim.PayerCategories pc ON pc.PayerCategoryID = p.PayerCategoryID																	
	left join dim.PayerGroups pg ON pg.PayerGroupID = p.PayerGroupID																	
	left join dim.vProviders pr ON pr.ProviderID = t2.TransactionBillingProviderID																	
	left join dim.vPBProcedureCodeCategories c ON c.ProcedureCode = t2.TransactionCode																	
	left join dim.vPBProcedureCategories cat ON cat.ProcedureCategory = CASE WHEN c.ProcedureCodeIsLocationDependent = 1 and t2.TransactionPlaceOfServiceCode in ('21','22') THEN 'Outpatient Procedures' 																	
																		  WHEN c.ProcedureCodeIsLocationDependent = 1 and t2.TransactionPlaceOfServiceCode not in ('21','22') THEN 'In Office Procedures'
																		  ELSE c.ProcedureCodeCategory END
	left join (select 																	
				t2.TransactionDatasourceID
				,t2.TransactionParentSourceID														
				,SUM(CASE WHEN t2.TransactionType = 'Adjustment' THEN t2.TransactionAmount ELSE 0 END) as Adjustments														
				,SUM(CASE WHEN t2.TransactionType = 'Payment' AND pg.PayerGroupName <> 'Self-Pay' THEN t2.TransactionAmount ELSE 0 END) as InsurancePayments														
				,SUM(CASE WHEN t2.TransactionType = 'Payment' AND pg.PayerGroupName = 'Self-Pay' THEN t2.TransactionAmount ELSE 0 END) as PatientPayments														
				,SUM(CASE WHEN t2.TransactionType = 'Payment' THEN t2.TransactionAmount ELSE 0 END) as TotalPayments														
				from fact.TransactionsPB t2 														
					left join dim.Payers p on p.PayerID = t2.TransactionPayerID													
					left join dim.PayerGroups pg ON pg.PayerGroupID = p.PayerGroupID													
				where 1=1														
				and t2.TransactionBillingType = 'PB'														
				and t2.TransactionType <> 'Charge'														
				and t2.TransactionDatasourceID in (1,5) 														
				--and t2.TransactionParentSourceID in ('PB~3423368','PB~3424327')														
				group by 														
					t2.TransactionDatasourceID,t2.TransactionParentSourceID ) pa ON pa.TransactionDatasourceID = t2.TransactionDatasourceID AND pa.TransactionParentSourceID = t2.TransactionSourceID													
where 1=1																		
	AND t2.TransactionBillingType = 'PB'																	
	AND t2.TransactionType = 'Charge'																	
	AND DATEFROMPARTS(left(t2.TransactionReportingPeriodID,4),right(t2.TransactionReportingPeriodID,2),1) >= '1/1/2022' --between '1/1/2022' and '9/30/2023'																	
	--AND t2.TransactionBillingProviderID = '1~13962' --'1~13946'  --'1~17927'
GO
