-- =============================================
-- Author:		<Eric Silvestri>
-- Create date: <2024-06-25>
-- Description:	<Stored procedure for TPG Allergy Month End reports>
-- =============================================
CREATE PROCEDURE [rpt].[spAPMAllergyProcedures] 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
select																		
	REPLACE(t2.TransactionVisitID, '1~','') as Voucher																	
	,REPLACE(t2.TransactionSourceID, 'PB~','') as TransactionID																	
	,t2.TransactionDateOfService as ServiceDate																																
	,t2.TransactionReportingPeriodID as ReportingPeriod																																	
	,pr.ProviderFullName as BillingProvider
	,pat.PatientMRN
	,pat.PatientFullName																	
	,p.PayerName as Payer																																	
	,t2.TransactionCode as ProcedureCode																	
	,t2.TransactionDescription as ProcedureCodeDescription																	
	,cat.ProcedureCategory as ProcedureCategory																																	
	,t2.TransactionUnits as ChargeUnits																	
	,ISNULL(t2.TransactionAmount,0) as Charges																	
	,ISNULL(pa.Adjustments,0) as Adjustments																	
	,ISNULL(pa.TotalPayments,0) as TotalPayments																	
	,ISNULL(pa.InsurancePayments,0) as InsurancePayments																	
	,ISNULL(pa.PatientPayments,0) as PatientPayments																	
	,ISNULL(t2.TransactionAmount,0) 
		+ ISNULL(pa.Adjustments,0)
		+ ISNULL(pa.TotalPayments,0) as Balance															
from fact.Transactions2 t2 																		
	left join dim.Payers p ON p.PayerID = t2.TransactionPayerID																	
	left join dim.PayerCategories pc ON pc.PayerCategoryID = p.PayerCategoryID																	
	left join dim.PayerGroups pg ON pg.PayerGroupID = p.PayerGroupID																	
	left join dim.vProviders pr ON pr.ProviderID = t2.TransactionBillingProviderID																	
	left join  dim.vPBProcedureCodeCategories c ON c.ProcedureCode = t2.TransactionCode	
	left join dim.vPatients pat on pat.PatientID = t2.PatientID																
	left join stg.PBProcedureCategories cat ON cat.ProcedureCategory = CASE WHEN c.ProcedureCodeIsLocationDependent = 1 and t2.TransactionPlaceOfServiceCode in ('21','22') THEN 'Outpatient Procedures' 																	
																		  WHEN c.ProcedureCodeIsLocationDependent = 1 and t2.TransactionPlaceOfServiceCode not in ('21','22') THEN 'In Office Procedures'
																		  ELSE c.ProcedureCodeCategory END
	left join (select 																	
				t2.TransactionDatasourceID
				,t2.TransactionParentSourceID														
				,SUM(CASE WHEN t2.TransactionType = 'Adjustment' THEN t2.TransactionAmount ELSE 0 END) as Adjustments														
				,SUM(CASE WHEN t2.TransactionType = 'Payment' AND pg.PayerGroupName <> 'Self-Pay' THEN t2.TransactionAmount ELSE 0 END) as InsurancePayments														
				,SUM(CASE WHEN t2.TransactionType = 'Payment' AND pg.PayerGroupName = 'Self-Pay' THEN t2.TransactionAmount ELSE 0 END) as PatientPayments														
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
	AND t2.TransactionType = 'Charge'
	AND pr.ProviderAbbreviation IN ('WSB','GPK','LLK','JML')
	AND cat.ProcedureCategory = 'Allergy Evaluation Visit'																	
	AND DATEFROMPARTS(left(t2.TransactionReportingPeriodID,4),right(t2.TransactionReportingPeriodID,2),1) >= '1/1/2022'	
END
GO
