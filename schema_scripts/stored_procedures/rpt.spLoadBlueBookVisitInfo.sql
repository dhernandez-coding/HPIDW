CREATE PROCEDURE [rpt].[spLoadBlueBookVisitInfo] as

/*
Change Control:
	1. 9/4/24 - Chris Cross - Replaced fact.Transactions2 with fact.TransactionsPB
	2. 6/4/25 - Eric Silvestri - Added datasource 12 to the where clause to include HPI Customer data 
	3. 7/24/25 - Chris Cross - Added VisitDateOfService to primary key due to generic visits spanning multiple days (ex. Shadid and Neese 5~30198848168)
	4. 1/8/26 - Diego Hernandez - Added datasource 15 to the where clause to include Modmed and included an exclusion for visit id null that i need to revisit
	5. 6/2/2026 - Chris Cross - Replaced HPIApp.dbo.PBProcedureCategories with [HERO-DB].hpi.dbo.PBProcedureCategoriess to look at new HERO app
*/

TRUNCATE TABLE rpt.BlueBookVisitInfo

INSERT INTO rpt.BlueBookVisitInfo
	([VisitID]
	  ,[VisitDateOfService]
      ,[VisitType]
      ,[VisitSubtype]
      ,[UpdatedDatetime]
	)

SELECT

	sub.TransactionVisitID as VisitID
	,sub.TransactionDateOfService as VisitDateOfService
	,pc.ProcedureCategoryVisitType
	,pc.ProcedureCategory
	,GETDATE() as UpdatedDatetime
FROM (
	SELECT
	--t.TransactionAccountID
	--t.TransactionVisitID
	t.TransactionVisitID
	,t.TransactionDateOfService
	,min(cat.ProcedureCategoryPriority) as ProcedureCategoryPriority

	FROM fact.TransactionsPB t
		left join map.PracticeDepartments pd ON pd.DepartmentID = t.TransactionDepartmentID
		left join dim.vPBProcedureCodeCategories c ON c.ProcedureCode = COALESCE(t.TransactionCPTCode,t.TransactionCode)
		left join [HERO-DB].hpi.dbo.PBProcedureCategoriess cat ON cat.ProcedureCategory = CASE WHEN c.ProcedureCodeIsLocationDependent = 1 and t.TransactionPlaceOfServiceCode in ('21','22') THEN 'Outpatient Procedures' 
																				WHEN c.ProcedureCodeIsLocationDependent = 1 and t.TransactionPlaceOfServiceCode not in ('21','22') THEN 'In Office Procedures'
																				ELSE c.ProcedureCodeCategory END
	WHERE 1=1
		AND t.TransactionBillingType = 'PB'
		AND t.TransactionType = 'Charge'
		AND t.TransactionDateOfVoid is null /*Not voided*/
		--AND (pd.DepartmentID is not null OR t.TransactionDatasourceID = 1)
		AND (pd.DepartmentID is not null OR t.TransactionDatasourceID IN (1, 12,15))
		AND t.TransactionDateOfPosting >= '1/1/2021'
		--AND t.TransactionAmount <> 0
		AND (t.TransactionModifier1 IS NULL or t.TransactionModifier1 <> 'TC')
		AND t.TransactionVisitID is not null -- I added this here because modmed is sending some bills without visitID and we need to investigate further on this  
		--and t.TransactionEncounterID = '5~30167308725'
	GROUP BY
		t.TransactionVisitID
		,TransactionDateOfService


	) sub
	left join [HERO-DB].hpi.dbo.PBProcedureCategoriess pc ON pc.ProcedureCategoryPriority = sub.ProcedureCategoryPriority

	--select * from fact.Transactions2 t2 where  t2.TransactionVisitID = '5~30173022350'

	--select * from rpt.BlueBookVisitInfo bb where bb.AccountID = '5~116632760' and bb.EncounterID = '5~30173022350' and bb.DateOfService = '2023-02-02'
GO
