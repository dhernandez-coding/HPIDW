CREATE PROCEDURE [rpt].[spLoadBlueBookPayments] 

	--@CurrentYear int 
	--,@CurrentPeriod int 
	--,@Practice varchar(10)
	
as

/*
Change Control:
	1. 9/4/24 - Chris Cross - Replaced fact.Transactions2 with fact.TransactionsPB
	2. 1/10/25 - Chris Cross - Excluded Payments - New and Payments - Distributed from visit detail due to undist payments being assigned to visits without a Billing Provider
	3. 4/30/25 - Chris Cross - Added "when t.TransactionDepartmentID = '5~42501006002' THEN 'Shadid Choctaw' --Checks if Choctaw department for Shadid" for ReportGroupLevel4
	4. 5/8/25 - Chris Cross - Added "when t.TransactionDepartmentID = '5~42501006001' THEN 'Shadid Edmond' --Checks if Edmond department for Shadid for ReportGroupLevel4
	5. 6/4/25 - Eric Silvestri - Added datasource 12 to the where clause to include HPI Customer data 
	6. 1/8/26 - Diego Hernandez - Added datasource 15 to the where clause to include Modmed 
*/

SET NOCOUNT OFF

DECLARE @Practice varchar(10) = '0' /*0 - All*/  --'DRW'
DECLARE @AsOfDate date = DATEADD(DAY,-1,DATEFROMPARTS(YEAR(GETDATE()),MONTH(GETDATE()),1))  
DECLARE @CurrentYear int = YEAR(@AsOfDate) --2023
DECLARE @CurrentPeriod int = MONTH(@AsOfDate)
DECLARE @EndDate date = DATEFROMPARTS(@CurrentYear,@CurrentPeriod,1)
DECLARE @StartDate date = DATEFROMPARTS(@CurrentYear-1,1,1)
DECLARE @12MonthStartDate date = DATEADD(MONTH,-12,@EndDate)
DECLARE @6MonthStartDate date = DATEADD(MONTH,-6,@EndDate)


--select @Practice, @AsOfDate, @CurrentYear,@CurrentPeriod


		
/*Delete and Reload*/
	DELETE FROM rpt.BlueBooks WHERE ReportSection in ('Payments') and FiscalYear >= @CurrentYear-1
	
	INSERT INTO rpt.BlueBooks 

	([FiscalYear] 
      ,[FiscalPeriod]
      ,[FiscalYearPeriod]
      ,[ReportSection]
      ,[ReportGroupLevel1]
      ,[ReportGroupLevel2]
	  ,[ReportGroupLevel3]
	  ,[ReportGroupLevel4]
      ,[PracticeID]
      ,[ReportingProviderID]
      ,[FiscalPeriodValue]
      ,[UpdatedDatetime])

	SELECT
	sub.FiscalYear
		,sub.FiscalPeriod
		,sub.FiscalYearPeriod
		,sub.ReportSection
		,sub.ReportGroupLevel1
		,sub.ReportGroupLevel2
		,sub.ReportGroupLevel3
		,sub.ReportGroupLevel4
		,sub.PracticeID
		,sub.ReportingProviderID
		,sum(sub.FiscalPeriodValue) as FiscalPeriodValue
		,GETDATE() as UpdateDatetime
	FROM (
		SELECT
		LEFT(t.TransactionReportingPeriodID,4) AS FiscalYear 
		,RIGHT(t.TransactionReportingPeriodID,2) AS FiscalPeriod 
		,FORMAT(DATEFROMPARTS(LEFT(t.TransactionReportingPeriodID,4),RIGHT(t.TransactionReportingPeriodID,2),1),'MMM-yy') AS FiscalYearPeriod 
		,'Payments' as ReportSection
		,ISNULL(vi.VisitType,'Other Visits') as ReportGroupLevel1
		,ISNULL(vi.VisitSubtype,'Misc') as ReportGroupLevel2 
		,CASE WHEN t.TransactionSubType like '%Refund%' THEN '7_Refund'
			  WHEN t.TransactionType = 'Payment' AND ISNULL(pg.PayerGroupName,'') <> 'Self-Pay' THEN '5_Payer Receipts'
			  WHEN t.TransactionType = 'Payment' AND ISNULL(pg.PayerGroupName,'') = 'Self-Pay' THEN '6_Patient Receipts' 
			  ELSE '5_Payer Receipts' END as ReportGroupLevel3
		,CASE
			WHEN t.TransactionDepartmentID IN ('1~10','1~25')THEN 'PI' -- Checks if Personal Injury account for Kim
			WHEN t.TransactionBillingProviderID in ('1~18524','5~P1008411') THEN 'PI' --5.8.26 Mapped all Kevin Chessmore (EKK) activity to PI
			when t.TransactionDepartmentID = '5~42501006002' THEN 'SCS Choctaw' --Checks if Choctaw department for Shadid
			when t.TransactionDepartmentID = '5~42501006001' THEN 'SCS Edmond' --Checks if Choctaw department for Shadid
			WHEN (v.VisitLocationID = '1~135' OR t.TransactionDepartmentID = '5~42501041001') AND pt.PracticeID = '0~TDT' THEN 'Hinton' -- checks for location and provider for Thomason
			WHEN (v.VisitLocationID = '1~223' OR t.TransactionDepartmentID = '5~42501043001') AND pt.PracticeID = '0~TDT' THEN 'Binger'
			WHEN (v.VisitLocationID = '1~230' OR t.TransactionDepartmentID = '5~42501042001') AND pt.PracticeID = '0~TDT' THEN 'Hydro'
			WHEN v.VisitLocationID = '1~95' AND pt.PracticeID = '0~TDT' THEN 'Hinton'			
		END AS ReportGroupLevel4
		,pt.PracticeID as PracticeID 
		,t.TransactionBillingProviderID as ReportingProviderID 
		,SUM(t.TransactionAmount * -1) as FiscalPeriodValue 
		,GETDATE() AS UpdatedDatetime 

		--select pd.PracticeID,pp.PracticeID,pt.*,t.*
		FROM fact.TransactionsPB t
			LEFT JOIN dim.Payers py ON py.PayerID = t.TransactionPayerID
			LEFT JOIN dim.PayerCategories pc ON pc.PayerCategoryID = py.PayerCategoryID
			LEFT JOIN dim.PayerGroups pg ON pg.PayerGroupID = py.PayerGroupID
			left join dim.Departments d ON d.DepartmentID = t.TransactionDepartmentID
			left join map.ProviderLinking pl ON pl.ChildProviderID = t.TransactionBillingProviderID
			left join map.PracticeDepartments pd ON pd.DepartmentID = t.TransactionDepartmentID
			left join map.vPracticeProviders pp ON pp.ParentProviderID = pl.ParentProviderID
									AND pp.PracticeProviderEffectiveDate <= t.TransactionDateOfPosting 
									AND pp.PracticeProviderEndDate >= t.TransactionDateOfPosting
									AND (/*This is here to handle duplicates with Murphi Scarborough at multiple practices*/
												(pl.ParentProviderID in ('0~1588209423') 
													AND (pp.PracticeID = pd.PracticeID OR (pd.PracticeID is null AND (t.TransactionDatasourceID = 5 AND pp.PracticeID = '0~RGS')
																													  OR (t.TransactionDatasourceID = 1 AND pp.PracticeID = '0~RLN'))) )
												/*This is here to handle duplicates with Amy James at multiple practices*/
												OR (pl.ParentProviderID in ('0~1679132823') 
													AND (pp.PracticeID = pd.PracticeID OR (pd.PracticeID is null AND (t.TransactionDatasourceID = 5 AND pp.PracticeID = '0~MDW')
																													  OR (t.TransactionDatasourceID = 1 AND pp.PracticeID = '0~CGW'))) )
												/*Chris Cross - 10.7.24 - Added Olivo, Pape, and Dunkleberger due to practicing at PBJ, NMO, and NRJ; Defaults to PBJ if no mapped department defined in Epic*/
												OR (pl.ParentProviderID in ('0~1992746200','0~1891761136','0~1376509828') 
													AND (pp.PracticeID = pd.PracticeID OR (pd.PracticeID is null AND  pp.PracticeID = '0~PBJ') ) )
												/*Chris Cross - 02.18.25 - Added Jill Yingling due to practicing at MBJ and RLN; Defaults to RLN if no mapped department defined in Epic*/
												OR (pl.ParentProviderID in ('0~1245788231') 
													AND (pp.PracticeID = pd.PracticeID OR (pd.PracticeID is null AND pp.PracticeID = '0~RLN') ) )
												/*This is here to handle duplicates with Paul Maitino at multiple practices*/
												OR (pl.ParentProviderID in ('0~1376507665') 
													AND (pp.PracticeID = pd.PracticeID OR (pd.PracticeID is null AND (t.TransactionDepartmentID = '12~45' AND pp.PracticeID = '0~JRS')
																													  OR (t.TransactionDepartmentID = '12~46' AND pp.PracticeID = '0~OPCL'))) )
												 /*This is here to handle duplicates with Calvin Johnson at multiple practices*/
												OR (pl.ParentProviderID in ('0~1063484251') 
													AND (pp.PracticeID = pd.PracticeID OR (pd.PracticeID is null AND (t.TransactionDepartmentID = '12~48' AND pp.PracticeID = '0~JCJ')
																													  OR (t.TransactionDepartmentID = '12~36' AND pp.PracticeID = '0~JCJ')
																													  OR (t.TransactionDepartmentID = '1~19' AND pp.PracticeID = '0~JCJ2')
																													  OR (t.TransactionDepartmentID = '1~5' AND pp.PracticeID = '0~JCJ2'))) )
												/*All other providers without specific mapping issues due to multiple practices as defined above*/
												OR pl.ParentProviderID not in ('0~1588209423','0~1679132823','0~1992746200','0~1891761136','0~1376509828','0~1245788231','0~1376507665','0~1063484251'))
			left join dim.Practices pt ON pt.PracticeID = COALESCE(pd.PracticeID,pp.PracticeID)
			/*Change this to VisitID eventually*/
			left join rpt.BlueBookVisitInfo vi ON vi.VisitID = t.TransactionVisitID 
												 
												  AND vi.VisitDateOfService = t.TransactionDateOfService
												  AND (
                                            t.TransactionDatasourceID = 15 OR t.TransactionSubType not in ('Payment - Distributed to Charge'
																					,'Payment - Distributed to Debit Adjustment'
																					,'Payment - Void'
																					,'Payment - New'
																					,'Payment - Refund')) /*Chris Cross - excluded these on 1/10/25 due to undist payments being assigned to visits without a Billing Provider*/
																										  /*Diego Hernandez - Add ModMed 6/24/26 due to modmed logic was failing based on this join*/		
			left join fact.Visits2 v on t.TransactionVisitID = v.VisitID
		WHERE 1=1
			AND t.TransactionBillingType = 'PB'
			AND t.TransactionType in ('Payment','Refund')
			--AND (pd.DepartmentID is not null OR t.TransactionDatasourceID = 1)
			AND (pd.DepartmentID is not null OR t.TransactionDatasourceID IN (1, 12,15))
			AND LEFT(t.TransactionReportingPeriodID,4) >= @CurrentYear-1
			AND t.TransactionAmount <> 0
			--AND t.TransactionBillingProviderID = '1~13953'
			--AND (t.TransactionModifier1 IS NULL or t.TransactionModifier1 <> 'TC')
			--AND t.TransactionAccountID = '1~25691320'
			and (@Practice = '0' OR pt.PracticeSourceID = @Practice)
			--AND LEFT(t.TransactionReportingPeriodID, 4)
			--and d.DepartmentName like '%Diesselhorst%'
		GROUP BY
			t.TransactionReportingPeriodID
			,vi.VisitType
			,vi.VisitSubtype
			,CASE WHEN t.TransactionSubType like '%Refund%' THEN '7_Refund'
			  WHEN t.TransactionType = 'Payment' AND ISNULL(pg.PayerGroupName,'') <> 'Self-Pay' THEN '5_Payer Receipts'
			  WHEN t.TransactionType = 'Payment' AND ISNULL(pg.PayerGroupName,'') = 'Self-Pay' THEN '6_Patient Receipts' 
			  ELSE '5_Payer Receipts' END
			,CASE
				WHEN t.TransactionDepartmentID IN ('1~10','1~25') THEN 'PI'
				WHEN t.TransactionBillingProviderID in ('1~18524','5~P1008411') THEN 'PI' --5.8.26 Mapped all Kevin Chessmore (EKK) activity to PI
				when t.TransactionDepartmentID = '5~42501006002' THEN 'SCS Choctaw' --Checks if Choctaw department for Shadid
				when t.TransactionDepartmentID = '5~42501006001' THEN 'SCS Edmond' --Checks if Choctaw department for Shadid
				WHEN (v.VisitLocationID = '1~135' OR t.TransactionDepartmentID = '5~42501041001') AND pt.PracticeID = '0~TDT' THEN 'Hinton' -- checks for location and provider for Thomason
				WHEN (v.VisitLocationID = '1~223' OR t.TransactionDepartmentID = '5~42501043001') AND pt.PracticeID = '0~TDT' THEN 'Binger'
				WHEN (v.VisitLocationID = '1~230' OR t.TransactionDepartmentID = '5~42501042001') AND pt.PracticeID = '0~TDT' THEN 'Hydro'
				WHEN v.VisitLocationID = '1~95' AND pt.PracticeID = '0~TDT' THEN 'Hinton'			
			END
			,pt.PracticeID
			,t.TransactionBillingProviderID
		--,p.ProviderID

	/*Add in Zero Values as placeholder*/
		UNION ALL

		select
			@CurrentYear as FiscalYear
			,@CurrentPeriod as FiscalPeriod
			,FORMAT(DATEFROMPARTS(@CurrentYear,@CurrentPeriod,1),'MMM-yy') AS FiscalYearPeriod 
			,bbg.ReportSection
			,bbg.ReportGroupLevel1
			,bbg.ReportGroupLevel2 as ReportGroupLevel2
			,'5_Payer Receipts' as ReportGroupLevel3
			,NULL as ReportGroupLevel4
			,p.PracticeID
			,pp.ProviderID
			,0 as FiscalPeriodValue
			,GETDATE()
		from dim.Practices p
			left join map.PracticeProviders pp ON pp.PracticeID = p.PracticeID
			cross join (SELECT bb.ReportSection, bb.ReportGroupLevel1, max(ReportGroupLevel2) as ReportGroupLevel2 
						FROM rpt.BlueBooks bb
						WHERE bb.ReportSection in ('Payments') and bb.ReportGroupLevel1 is not null
						GROUP BY bb.ReportSection, bb.ReportGroupLevel1) bbg
		where p.PracticeIsActive = 1

		UNION ALL

		SELECT --New logic dividing thp in different practices 
			    YEAR(thp.[Date]) AS FiscalYear,
			    MONTH(thp.[Date]) AS FiscalPeriod,
			    FORMAT(DATEFROMPARTS(YEAR(thp.[Date]), MONTH(thp.[Date]), 1), 'MMM-yy') AS FiscalYearPeriod,
			    'Payments' AS ReportSection,
			    'Office Visits' AS ReportGroupLevel1,
			    'Misc' AS ReportGroupLevel2,
			    '5_Payer Receipts' AS ReportGroupLevel3,
			    NULL AS ReportGroupLevel4,
			    COALESCE(pp.PracticeID, p.PracticeID) AS PracticeID,
			    pl.ParentProviderID AS ReportingProviderID,
			    SUM(thp.Original_Amount * -1) AS FiscalPeriodValue,
			    GETDATE() AS UpdatedDatetime
			FROM [HPIDW].[stg].[THPTransactions] thp
			LEFT JOIN dim.Practices p
			    ON p.PracticeID = '0~' + LTRIM(RTRIM(thp.Practice))
			LEFT JOIN dim.Providers pr
			    ON UPPER(LTRIM(RTRIM(pr.ProviderSourceID))) = UPPER(LTRIM(RTRIM(thp.Provider)))
			    AND pr.ProviderDataSourceID = 18
			LEFT JOIN map.PracticeProviders pp
			    ON pp.ProviderID = pr.ProviderID
			    AND pp.PracticeID = p.PracticeID -- ✅ Prevents duplication for multi-practice mid-levels
			LEFT JOIN map.ProviderLinking pl
			    ON pl.ChildProviderID = pp.ProviderID
			WHERE thp.Account_Type = 'Income'
			    AND thp.Account NOT IN ('RENTAL INCOME','OTHER INCOME')
			    AND thp.[Date] >= @StartDate 
			    AND thp.[Date] < DATEADD(MONTH, 1, @EndDate)
			    AND (COALESCE(pp.PracticeID, p.PracticeID) IN ('0~THP','0~CVFC') OR p.PracticeCompany = 'THP' OR pp.PracticeID LIKE '%THP%')
			    AND (@Practice = '0' OR p.PracticeSourceID = @Practice)
			GROUP BY
			    YEAR(thp.[Date]),
			    MONTH(thp.[Date]),
			    FORMAT(DATEFROMPARTS(YEAR(thp.[Date]), MONTH(thp.[Date]), 1), 'MMM-yy'),
			    COALESCE(pp.PracticeID, p.PracticeID),
			    pl.ParentProviderID



		) sub

		GROUP BY  
		sub.FiscalYear
		,sub.FiscalPeriod
		,sub.FiscalYearPeriod
		,sub.ReportSection
		,sub.ReportGroupLevel1
		,sub.ReportGroupLevel2
		,sub.ReportGroupLevel3
		,sub.ReportGroupLevel4
		,sub.PracticeID
		,sub.ReportingProviderID
GO
