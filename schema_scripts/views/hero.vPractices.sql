CREATE view [hero].[vPractices] as


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
	  left join  hero.companiess c on p.PracticeCompanyID = c.CompanyID
	  
	  left join  hero.specialtiess s on p.PracticeSpecialtyID = s.SpecialtyID
	  LEFT JOIN SameStoreMap ss 
    ON ss.PracticeID = p.PracticePracticeID
GO
