CREATE PROCEDURE [rpt].[spSelectPBClosedClaims] as
BEGIN

/* ##### STORED PROCEDURE ##### 
   #<Chris Cross - Author>#
   #<Modified by Diego Hernandez - 10/30/2024># 
   1. 7/22/2026 - Logan Richardson	- Replaced hero db PBProcdureCategories with dim.vPBProcedureCategories
   
   */


 -- Clear existing records in the rpt.PBClosedClaims table to avoid duplicates
    TRUNCATE TABLE rpt.PBClosedClaims;

    DECLARE @EndDate date = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1);
    DECLARE @StartDate date = DATEADD(MONTH, -10, @EndDate);

    -- Insert the detailed transaction data directly into rpt.PBClosedClaims
    INSERT INTO rpt.PBClosedClaims (
        Datasource,
        VisitID,
        Account,
        ServiceDate,
        BillingProvider,
        Payer,
        PayerCategory,
        Charges,
        Adjustments,
        TotalPayments,
        InsurancePayments,
        PatientPayments,
        PercentAdjusted,
        Balance
    )

	SELECT																		
	t.DataSourceName as Datasource																	
	,t.VisitID																	
	,t.Account																	
	,t.ServiceDate																	
	,t.BillingProvider																	
	,t.Payer																	
	,t.PayerCategory																	
	,sum(t.Charges) as Charges																	
	,sum(t.Adjustments) as Adjustments																	
	,sum(t.TotalPayments) as TotalPayments																	
	,sum(t.InsurancePayments) as InsurancePayments																	
	,sum(t.PatientPayments) as PatientPayments																	
	,sum(t.Adjustments) / sum(t.Charges) as PercentAdjusted																	
	,sum(t.Balance) as Balance																	
FROM
    (SELECT
       																		
	ds.DataSourceName																	
	,t2.TransactionVisitID as VisitID																	
	,t2.TransactionAccountID as Account																	
	,t2.TransactionSourceID as TransactionID																	
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
	,ISNULL(t2.TransactionAmount,0)+ ISNULL(pa.Adjustments,0) + ISNULL(pa.TotalPayments,0) as Balance

    FROM fact.TransactionsPB t2
    left join dim.Datasources ds ON ds.DataSourceID = t2.TransactionDatasourceID																	
	left join dim.Payers p ON p.PayerID = t2.TransactionPayerID																	
	left join dim.PayerCategories pc ON pc.PayerCategoryID = p.PayerCategoryID																	
	left join dim.PayerGroups pg ON pg.PayerGroupID = p.PayerGroupID																	
	left join dim.vProviders pr ON pr.ProviderID = t2.TransactionBillingProviderID																	
	left join dim.vPBProcedureCodeCategories c ON c.ProcedureCode = COALESCE(t2.TransactionCPTCode,t2.TransactionCode)
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
	AND t2.TransactionDateOfService >= @StartDate
		AND t2.TransactionDateOfService < @EndDate --between '11/1/2023' and '8/31/2024'																	
	AND ISNULL(t2.TransactionAmount,0) > 0																	
	AND ISNULL(t2.TransactionAmount,0) 																	
		+ ISNULL(pa.Adjustments,0)																
		+ ISNULL(pa.TotalPayments,0) <= 0) t

	GROUP BY 																		
	t.DataSourceName																	
	,t.VisitID																	
	,t.Account																	
	,t.ServiceDate																	
	,t.BillingProvider																	
	,t.Payer																	
	,t.PayerCategory
	

/* ################ OLD CODE #######################

DECLARE @EndDate date = DATEFROMPARTS(YEAR(GETDATE()),MONTH(GETDATE()),1)
DECLARE @StartDate date = DATEADD(MONTH,-10,@EndDate)

--select @EndDate, @StartDate

select																		
	ds.DataSourceName																	
	,t2.TransactionVisitID as VisitID																	
	,t2.TransactionAccountID as Account																	
	,t2.TransactionSourceID as TransactionID																	
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
	,ISNULL(t2.TransactionAmount,0)+ ISNULL(pa.Adjustments,0) + ISNULL(pa.TotalPayments,0) as Balance																
	--,t2.TransactionPlaceOfServiceCode																	
INTO #TEMP_Charges																		
from fact.TransactionsPB t2 																		
	left join dim.Datasources ds ON ds.DataSourceID = t2.TransactionDatasourceID																	
	left join dim.Payers p ON p.PayerID = t2.TransactionPayerID																	
	left join dim.PayerCategories pc ON pc.PayerCategoryID = p.PayerCategoryID																	
	left join dim.PayerGroups pg ON pg.PayerGroupID = p.PayerGroupID																	
	left join dim.vProviders pr ON pr.ProviderID = t2.TransactionBillingProviderID																	
	left join stg.PBProcedureCodeCategories c ON c.ProcedureCode = t2.TransactionCode																	
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
	AND t2.TransactionDateOfService >= @StartDate
		AND t2.TransactionDateOfService < @EndDate --between '11/1/2023' and '8/31/2024'																	
	AND ISNULL(t2.TransactionAmount,0) > 0																	
	AND ISNULL(t2.TransactionAmount,0) 																	
		+ ISNULL(pa.Adjustments,0)																
		+ ISNULL(pa.TotalPayments,0) <= 0																
																		
																		
																		
SELECT																		
	t.DataSourceName as Datasource																	
	,t.VisitID																	
	,t.Account																	
	,t.ServiceDate																	
	,t.BillingProvider																	
	,t.Payer																	
	,t.PayerCategory																	
	,sum(t.Charges) as Charges																	
	,sum(t.Adjustments) as Adjustments																	
	,sum(t.TotalPayments) as TotalPayments																	
	,sum(t.InsurancePayments) as InsurancePayments																	
	,sum(t.PatientPayments) as PatientPayments																	
	,sum(t.Adjustments) / sum(t.Charges) as PercentAdjusted																	
	,sum(t.Balance) as Balance																	
FROM #TEMP_Charges t																		
GROUP BY 																		
	t.DataSourceName																	
	,t.VisitID																	
	,t.Account																	
	,t.ServiceDate																	
	,t.BillingProvider																	
	,t.Payer																	
	,t.PayerCategory																	

*/

END;
GO
