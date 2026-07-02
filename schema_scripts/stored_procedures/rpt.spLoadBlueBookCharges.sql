CREATE PROCEDURE  [rpt].[spLoadBlueBookCharges] 

	--@CurrentYear int 
	--,@CurrentPeriod int 
	--,@Practice varchar(10)
	
as

/*
Change Control:
	1. 9/4/24 - Chris Cross - Replaced fact.Transactions2 with fact.TransactionsPB
	2. 4/30/25 - Chris Cross - Added "when t.TransactionDepartmentID = '5~42501006002' THEN 'Shadid Choctaw' --Checks if Choctaw department for Shadid" for ReportGroupLevel4
	3. 5/8/25 - Chris Cross - Added "when t.TransactionDepartmentID = '5~42501006001' THEN 'Shadid Edmond' --Checks if Edmond department for Shadid for ReportGroupLevel4
	4. 6/4/25 - Eric Silvestri - Added datasource 12 to the where clause to include HPI Customer data 
	5. 1/8/26 - Diego Hernandez - Added datasource 15 to the where clause to include Modmed 
*/


SET NOCOUNT ON

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
	DELETE FROM rpt.BlueBooks WHERE ReportSection in ('Charges') and FiscalYear >= @CurrentYear-1
	
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
		,'Charges' as ReportSection
		,ISNULL(vi.VisitType,'Other Visits') as ReportGroupLevel1
		,ISNULL(pg.PayerGroupName,'Other Commercial') as ReportGroupLevel2 
		,'1_Charge' as ReportGroupLevel3
		,case 
			when t.TransactionDepartmentID IN ('1~10','1~25') then 'PI' -- Checks if Personal Injury account for Kim
			WHEN t.TransactionBillingProviderID in ('1~18524','5~P1008411') THEN 'PI' --5.8.26 Mapped all Kevin Chessmore (EKK) activity to PI
			when t.TransactionDepartmentID = '5~42501006002' THEN 'SCS Choctaw' --Checks if Choctaw department for Shadid
			when t.TransactionDepartmentID = '5~42501006001' THEN 'SCS Edmond' --Checks if Choctaw department for Shadid
			WHEN (v.VisitLocationID = '1~135' OR t.TransactionDepartmentID = '5~42501041001') AND pt.PracticeID = '0~TDT' THEN 'Hinton' -- checks for location and provider for Thomason
			WHEN (v.VisitLocationID = '1~223' OR t.TransactionDepartmentID = '5~42501043001') AND pt.PracticeID = '0~TDT' THEN 'Binger'
			WHEN (v.VisitLocationID = '1~230' OR t.TransactionDepartmentID = '5~42501042001') AND pt.PracticeID = '0~TDT' THEN 'Hydro'
			WHEN v.VisitLocationID = '1~95' AND pt.PracticeID = '0~TDT' THEN 'Hinton'			
		end as ReportGroupLevel4
		,pt.PracticeID as PracticeID 
		,t.TransactionBillingProviderID as ReportingProviderID 
		,SUM(t.TransactionAmount) as FiscalPeriodValue 
		,GETDATE() AS UpdatedDatetime 

		--select pd.PracticeID,pp.PracticeID,pt.*,t.*
		FROM fact.TransactionsPB t
			left join dim.Departments d ON d.DepartmentID = t.TransactionDepartmentID
			/* --Replaced on 11.6.2024 due to duplicates caused by TMG Imaging and TMG Billing Office departments
				left join dim.vProviders p ON p.ProviderID = t.TransactionBillingProviderID
				left join map.PracticeDepartments pd ON pd.DepartmentID = t.TransactionDepartmentID
				left join map.vPracticeProviders pp ON pp.ProviderID = t.TransactionBillingProviderID 
												  AND pp.PracticeProviderEffectiveDate <= t.TransactionDateOfPosting 
												  AND pp.PracticeProviderEndDate >= t.TransactionDateOfPosting
			*/
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
												/*This is here to handle duplicates with Joseph Broome at multiple practices*/
												OR (pl.ParentProviderID in ('0~1306817887') 
													AND (pp.PracticeID = pd.PracticeID OR (pd.PracticeID is null AND pp.PracticeID = '0~JCB') ) )
												
												/*All other providers without specific mapping issues due to multiple practices as defined above*/
												OR pl.ParentProviderID not in ('0~1588209423','0~1679132823','0~1992746200','0~1891761136','0~1376509828','0~1245788231','0~1376507665','0~1063484251','0~1306817887'))
												
			left join dim.vPractices pt ON pt.PracticeID = COALESCE(pd.PracticeID,pp.PracticeID)
			left join dim.Payers py ON py.PayerID = t.TransactionPayerID
			--left join dim.PayerCategories pc ON pc.PayerCategoryID = py.PayerCategoryID
			left join dim.PayerGroups pg ON pg.PayerGroupID = py.PayerGroupID
			/*Change this to VisitID eventually*/
			left join rpt.BlueBookVisitInfo vi ON vi.VisitID = t.TransactionVisitID AND vi.VisitDateOfService = t.TransactionDateOfService
			left join fact.Visits2 v on t.TransactionVisitID = v.VisitID
												

		WHERE 1=1
			AND t.TransactionBillingType = 'PB'
			AND t.TransactionType = 'Charge'
			--AND (pd.DepartmentID is not null OR t.TransactionDatasourceID = 1)
			AND (pd.DepartmentID is not null OR t.TransactionDatasourceID IN (1, 12,15))
			AND LEFT(t.TransactionReportingPeriodID,4) >= @CurrentYear-1
			AND t.TransactionAmount <> 0
			AND pt.PracticeID NOT IN ('0~THP','0~CVFC')  --Added this to dedup THP
			--AND t.TransactionBillingProviderID = '1~13953'
			--AND (t.TransactionModifier1 IS NULL or t.TransactionModifier1 <> 'TC')
			--AND t.TransactionAccountID = '1~25691320'
			and (@Practice = '0' OR pt.PracticeSourceID = @Practice)
			--AND LEFT(t.TransactionReportingPeriodID, 4)
			--and d.DepartmentName like '%Diesselhorst%'
			and t.TransactionSourceID <> 'PB~4638492' /*exluding voided charge with large amount for Dr Joseph Hoskins*/
		GROUP BY
			t.TransactionReportingPeriodID
			,vi.VisitType
			,pg.PayerGroupName
			,case 
				when t.TransactionDepartmentID IN ('1~10','1~25') then 'PI'
				WHEN t.TransactionBillingProviderID in ('1~18524','5~P1008411') THEN 'PI' --5.8.26 Mapped all Kevin Chessmore (EKK) activity to PI
				when t.TransactionDepartmentID = '5~42501006002' THEN 'SCS Choctaw' --Checks if Choctaw department for Shadid
				when t.TransactionDepartmentID = '5~42501006001' THEN 'SCS Edmond' --Checks if Choctaw department for Shadid
				WHEN (v.VisitLocationID = '1~135' OR t.TransactionDepartmentID = '5~42501041001') AND pt.PracticeID = '0~TDT' THEN 'Hinton' -- checks for location and provider for Thomason
				WHEN (v.VisitLocationID = '1~223' OR t.TransactionDepartmentID = '5~42501043001') AND pt.PracticeID = '0~TDT' THEN 'Binger'
				WHEN (v.VisitLocationID = '1~230' OR t.TransactionDepartmentID = '5~42501042001') AND pt.PracticeID = '0~TDT' THEN 'Hydro'
				WHEN v.VisitLocationID = '1~95' AND pt.PracticeID = '0~TDT' THEN 'Hinton'			
			end
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
			,'1_Charge' as ReportGroupLevel3
			,NULL as ReportGroupLevel4
			,p.PracticeID
			,pp.ProviderID
			,0 as FiscalPeriodValue
			,GETDATE()
		from dim.vPractices p
			left join map.vPracticeProviders pp ON pp.PracticeID = p.PracticeID
			cross join (SELECT bb.ReportSection, bb.ReportGroupLevel1, max(ReportGroupLevel2) as ReportGroupLevel2
						FROM rpt.BlueBooks bb
						WHERE bb.ReportSection in ('Charges') and bb.ReportGroupLevel1 is not null
						GROUP BY bb.ReportSection, bb.ReportGroupLevel1) bbg
		where p.PracticeIsActive = 1

		
	UNION ALL
/* THP DATA */ 

	SELECT
     YEAR(v.Month) as FiscalYear
    ,MONTH(v.Month) as FiscalPeriod
    ,FORMAT(DATEFROMPARTS(YEAR(v.Month), MONTH(v.Month), 1), 'MMM-yy') AS FiscalYearPeriod
    ,'Charges' AS ReportSection
    ,'Other Visits' AS ReportGroupLevel1
    ,'Other Commercial' AS ReportGroupLevel2
    ,'1_Charge' AS ReportGroupLevel3
    ,NULL AS ReportGroupLevel4
    ,p.PracticeID
    ,ISNULL(pl.ParentProviderID, 'UNKNOWN') AS ReportingProviderID
    ,SUM(v.Charges) AS FiscalPeriodValue
    ,GETDATE() AS UpdatedDateTime
FROM [HPIDW].[stg].[THPVolumes] v
LEFT JOIN dim.Providers pp
    ON UPPER(LTRIM(RTRIM(pp.ProviderSourceID))) = UPPER(LTRIM(RTRIM(v.Provider)))
    AND pp.ProviderDataSourceID = 17
LEFT JOIN map.ProviderLinking pl 
    ON pl.ChildProviderID = pp.ProviderID
LEFT JOIN map.PracticeProviders mpp
    ON mpp.ProviderID = pp.ProviderID
LEFT JOIN dim.Practices p
    ON p.PracticeID = ISNULL(mpp.PracticeID, v.Practice)
WHERE v.Charges IS NOT NULL 
    AND v.Month >= @StartDate
    AND v.Month < DATEADD(MONTH, 1, @EndDate)
    AND (p.PracticeID LIKE '0~THP%' OR p.PracticeID = '0~CVFC')
GROUP BY
    YEAR(v.Month),
    MONTH(v.Month),
    FORMAT(DATEFROMPARTS(YEAR(v.Month), MONTH(v.Month), 1), 'MMM-yy'),
    p.PracticeID,
    ISNULL(pl.ParentProviderID, 'UNKNOWN')


--	SELECT
--     YEAR(v.Month) as FiscalYear
--    ,MONTH(v.Month) as FiscalPeriod
--    ,FORMAT(DATEFROMPARTS(YEAR(v.Month), MONTH(v.Month), 1), 'MMM-yy') AS FiscalYearPeriod
--    ,'Charges' AS ReportSection
--    ,'Other Visits' AS ReportGroupLevel1
--    ,'Other Commercial' AS ReportGroupLevel2
--    ,'1_Charge' AS ReportGroupLevel3
--    ,NULL AS ReportGroupLevel4
--    ,p.PracticeID
--    ,ISNULL(pr.ProviderID, 'UNKNOWN') AS ReportingProviderID
--    ,SUM(v.Charges) AS FiscalPeriodValue
--    ,GETDATE() AS UpdatedDateTime
--FROM [HPIDW].[stg].[THPVolumes] v
--LEFT JOIN dim.vPractices p
--    ON p.PracticeID = '0~' + LTRIM(RTRIM(v.Practice))
--OUTER APPLY (
--    SELECT TOP 1 pl.ParentProviderID AS ProviderID
--    FROM dim.vProviders pp
--    LEFT JOIN map.ProviderLinking pl ON pl.ChildProviderID = pp.ProviderID
--    WHERE UPPER(LTRIM(RTRIM(pp.ProviderSourceID))) = UPPER(LTRIM(RTRIM(v.Provider)))
--      AND pp.ProviderDataSourceID IN (17)
--    ORDER BY pp.ProviderDataSourceID DESC, pp.ProviderID
--) pr
--WHERE v.Charges IS NOT NULL 
--    AND v.Month >= @StartDate
--    AND v.Month < DATEADD(MONTH, 1, @EndDate)
--    AND p.PracticeID IN ('0~THP','0~CVFC')
--GROUP BY
--    YEAR(v.Month),
--    MONTH(v.Month),
--    FORMAT(DATEFROMPARTS(YEAR(v.Month), MONTH(v.Month), 1), 'MMM-yy'),
--    p.PracticeID,
--    ISNULL(pr.ProviderID, 'UNKNOWN')


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
