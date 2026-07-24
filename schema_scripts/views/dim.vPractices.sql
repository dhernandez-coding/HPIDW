CREATE VIEW [dim].[vPractices]
 with schemabinding as
 
 WITH SameStoreMap AS (

     -- 🔵 2024-01-01 group
    SELECT '0~MEC' AS PracticeID, CAST('2024-01-01' AS DATE) AS StartDate, NULL AS EndDate
    UNION ALL SELECT '0~NBN', '2024-01-01', NULL
    UNION ALL SELECT '0~MSO', '2024-01-01', NULL
    UNION ALL SELECT '0~JLM', '2024-01-01', NULL
    UNION ALL SELECT '0~MBJ', '2024-01-01', NULL
    UNION ALL SELECT '0~PAK', '2024-01-01', NULL
    UNION ALL SELECT '0~BET', '2024-01-01', NULL
    UNION ALL SELECT '0~EKK', '2024-01-01', NULL
    UNION ALL SELECT '0~LAK', '2024-01-01', NULL
    UNION ALL SELECT '0~TAK', '2024-01-01', NULL
    UNION ALL SELECT '0~ACC', '2024-01-01', NULL
    UNION ALL SELECT '0~SMS', '2024-01-01', NULL
    UNION ALL SELECT '0~WSB', '2024-01-01', NULL

    -- 👇 Special case (LCS)
    UNION ALL SELECT '0~LCS', '2024-01-01', '2025-12-31'

    UNION ALL SELECT '0~SCS', '2024-01-01', NULL
    UNION ALL SELECT '0~NMO', '2024-01-01', NULL
    UNION ALL SELECT '0~DDR', '2024-01-01', NULL
    UNION ALL SELECT '0~PBJ', '2024-01-01', NULL
    UNION ALL SELECT '0~BAB', '2024-01-01', NULL
    UNION ALL SELECT '0~AKM', '2024-01-01', NULL
    UNION ALL SELECT '0~RGS', '2024-01-01', NULL
    UNION ALL SELECT '0~RMH', '2024-01-01', NULL
    UNION ALL SELECT '0~RLN', '2024-01-01', NULL
    UNION ALL SELECT '0~RSG', '2024-01-01', NULL
    UNION ALL SELECT '0~BLN', '2024-01-01', NULL
    UNION ALL SELECT '0~MEM', '2024-01-01', NULL
    UNION ALL SELECT '0~THP', '2024-01-01', NULL
    UNION ALL SELECT '0~TDT', '2024-01-01', NULL

    -- 🟢 2025-01-01 group
    UNION ALL SELECT '0~EBJ', '2025-01-01', NULL
    UNION ALL SELECT '0~NRJ', '2025-01-01', NULL
    UNION ALL SELECT '0~WAS', '2025-01-01', NULL
    UNION ALL SELECT '0~SJA', '2025-01-01', NULL
)

 /*THIS IS THE NEW LOGIC*/

 

  select 
  [PracticePracticeID] as PracticeID
      ,[PracticeDataSourceID]
      ,[PracticeSourceID]
      ,[PracticeName]
      ,[PracticeAbbreviation]
      ,[PracticeDataSource]
      ,c.CompanyName as PracticeCompany
      ,[PracticeIsActive]
      ,
	  
	  
        CASE 
            WHEN SameStoreStartDate <= GETDATE() 
                 AND (SameStoreEndDate IS NULL OR SameStoreEndDate >= GETDATE())
            THEN 1
            ELSE 0
        END as PracticeIsSameStore
      ,[PracticeUpdatedDatetime]
      ,[PracticeGLLocationID]
      ,[PracticeGLLocation]
      ,[PracticeGLPracticeID]
      ,s.SpecialtyName AS PracticeSpecialty
      ,null as [PracticeSameStoreDate]

	        ,ss.StartDate as PracticeFirstDateActivity
      ,ss.StartDate as zPracticeSameStoreDate
 ,SameStoreEndDate 
	  from hero.practicess p
	  left join  hero.companiess c on p.CompanyID = c.CompanyID
	  
	  left join  hero.specialtiess s on p.SpecialtyID = s.SpecialtyID
	  LEFT JOIN SameStoreMap ss 
    ON ss.PracticeID = p.PracticePracticeID
	  WHERE EXISTS (
    SELECT 1 FROM dbo.DWConfig WHERE Name = 'UseAppTables' AND [Value] = 1
)

UNION ALL



 --WITH SameStore as (

 --SELECT
 --pt.PracticeID as TransactionPracticeID,
 --MIN(t.TransactionDateOfPosting) as TransactionDateOfPosting
 --FROM fact.TransactionsPB t
 --left join map.ProviderLinking pl ON pl.ChildProviderID = t.TransactionBillingProviderID
 --left join map.PracticeDepartments pd ON pd.DepartmentID = t.TransactionDepartmentID
	--	left join map.vPracticeProviders pp ON pp.ParentProviderID = pl.ParentProviderID
	--								AND pp.PracticeProviderEffectiveDate <= t.TransactionDateOfPosting 
	--								AND pp.PracticeProviderEndDate >= t.TransactionDateOfPosting
	--								--AND pp.ProviderdatasourceID = t.TransactionDatasourceID
	--								AND (/*This is here to handle duplicates with Murphi Scarborough at multiple practices*/
	--											(pl.ParentProviderID in ('0~1588209423') 
	--												AND (pp.PracticeID = pd.PracticeID OR (pd.PracticeID is null AND (t.TransactionDatasourceID = 5 AND pp.PracticeID = '0~RGS')
	--																												  OR (t.TransactionDatasourceID = 1 AND pp.PracticeID = '0~RLN'))) )
												
												
	--											/*This is here to handle duplicates with Amy James at multiple practices*/
	--											OR (pl.ParentProviderID in ('0~1679132823') 
	--												AND (pp.PracticeID = pd.PracticeID OR (pd.PracticeID is null AND (t.TransactionDatasourceID = 5 AND pp.PracticeID = '0~MDW')
	--																												  OR (t.TransactionDatasourceID = 1 AND pp.PracticeID = '0~CGW'))) )
	--											/*Chris Cross - 10.7.24 - Added Olivo, Pape, and Dunkleberger due to practicing at PBJ, NMO, and NRJ; Defaults to PBJ if no mapped department defined in Epic*/
	--											OR (pl.ParentProviderID in ('0~1992746200','0~1891761136','0~1376509828') 
	--												AND (pp.PracticeID = pd.PracticeID OR (pd.PracticeID is null AND  pp.PracticeID = '0~PBJ') ) )


	--											/*Chris Cross - 02.18.25 - Added Jill Yingling due to practicing at MBJ and RLN; Defaults to RLN if no mapped department defined in Epic*/
	--											OR (pl.ParentProviderID in ('0~1245788231') 
	--												AND (pp.PracticeID = pd.PracticeID OR (pd.PracticeID is null AND pp.PracticeID = '0~RLN') ) )
	--											/*This is here to handle duplicates with Paul Maitino at multiple practices*/
	--											OR (pl.ParentProviderID in ('0~1376507665') 
	--												AND (pp.PracticeID = pd.PracticeID OR (pd.PracticeID is null AND (t.TransactionDepartmentID = '12~45' AND pp.PracticeID = '0~JRS')
	--																												  OR (t.TransactionDepartmentID = '12~46' AND pp.PracticeID = '0~OPCL'))) )
	--											  /*This is here to handle duplicates with Calvin Johnson at multiple practices*/
	--											OR (pl.ParentProviderID in ('0~1063484251') 
	--												AND (pp.PracticeID = pd.PracticeID OR (pd.PracticeID is null AND (t.TransactionDepartmentID = '12~48' AND pp.PracticeID = '0~JCJ')
	--																												  OR (t.TransactionDepartmentID = '12~36' AND pp.PracticeID = '0~JCJ')
	--																												  OR (t.TransactionDepartmentID = '1~19' AND pp.PracticeID = '0~JCJ2')
	--																												  OR (t.TransactionDepartmentID = '1~5' AND pp.PracticeID = '0~JCJ2'))) )
												
												
	--											/*All other providers without specific mapping issues due to multiple practices as defined above*/
	--											OR pl.ParentProviderID not in ('0~1588209423','0~1679132823','0~1992746200','0~1891761136','0~1376509828','0~1245788231','0~1376507665','0~1063484251'))
													
 --left join dim.vPractices pt ON pt.PracticeID = COALESCE(pd.PracticeID,pp.PracticeID)
 --WHERE t.TransactionType = 'Charge'
 --and pt.PracticeCompany = 'TPG'
 --GROUP BY 
 --pt.PracticeID

 --UNION ALL
 ----THP
 --SELECT 
 --'0~' + t.Practice,
 --MIN(t.Date) as TransactionDateOfPosting
 --FROM stg.THPTransactions t
 --GROUP BY t.Practice 

 --)



 SELECT 
      p.[PracticeID]
      ,[PracticeDataSourceID]
      ,[PracticeSourceID]
      ,[PracticeName]
      ,[PracticeAbbreviation]
      ,[PracticeDataSource]
      ,[PracticeCompany]
      ,[PracticeIsActive]
      ,[PracticeIsSameStore]
      ,[PracticeUpdatedDatetime]
      ,[PracticeGLLocationID]
      ,[PracticeGLLocation]
      ,[PracticeGLPracticeID]
      ,[PracticeSpecialty]
      ,[PracticeSameStoreDate]
      ,ss.StartDate as PracticeFirstDateActivity
      ,ss.StartDate as zPracticeSameStoreDate
      ,ss.EndDate as SameStoreEndDate


FROM [dim].[Practices] p
LEFT JOIN SameStoreMap ss 
    ON ss.PracticeID = p.PracticeID
WHERE 1=1 and
EXISTS (
    SELECT 1 FROM dbo.DWConfig WHERE Name = 'UseAppTables' AND [Value] = 0
)
GO
