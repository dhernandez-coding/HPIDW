CREATE PROCEDURE [rpt].[spLoadBlueBookCash] as

	--@CurrentYear int 
	--,@CurrentPeriod int 
	--,@Practice varchar(10)
	

SET NOCOUNT Off

DECLARE @Practice varchar(10) = '0' /*0 - All*/  --'DRW'
DECLARE @AsOfDate date = DATEADD(DAY,-1,DATEFROMPARTS(YEAR(GETDATE()),MONTH(GETDATE()),1))  
DECLARE @CurrentYear int = YEAR(@AsOfDate) --2023
DECLARE @CurrentPeriod int = MONTH(@AsOfDate)
DECLARE @PreviousPeriodYear INT = CASE WHEN @CurrentPeriod > 1 THEN @CurrentYear ELSE @CurrentYear - 1 END
DECLARE @PreviousPeriod int = CASE WHEN @CurrentPeriod = 1 THEN 12 ELSE @CurrentPeriod - 1 END
DECLARE @EndDate date = DATEFROMPARTS(@CurrentYear,@CurrentPeriod,1)
DECLARE @StartDate date = DATEFROMPARTS(@CurrentYear-1,1,1)
DECLARE @12MonthStartDate date = DATEADD(MONTH,-12,@EndDate)
DECLARE @6MonthStartDate date = DATEADD(MONTH,-6,@EndDate)

--select @Practice, @AsOfDate, @CurrentYear,@CurrentPeriod

DELETE FROM rpt.BlueBooks WHERE ReportSection in ('Cash') and FiscalYear = @CurrentYear and FiscalPeriod in (@CurrentPeriod,0) --FiscalYear >= @CurrentYear-1

INSERT INTO rpt.BlueBooks

([FiscalYear] 
      ,[FiscalPeriod]
      ,[FiscalYearPeriod]
      ,[ReportSection]
      ,[ReportGroupLevel1]
      ,[ReportGroupLevel2]
	  ,[ReportGroupLevel3]
	  --,[ReportGroupLevel4]
      ,[PracticeID]
      ,[ReportingProviderID]
      ,[FiscalPeriodValue]
      ,[UpdatedDatetime])
	  
SELECT
	sub.FiscalYear
	,sub.FiscalPeriod
	,FORMAT(DATEFROMPARTS(sub.FiscalYear,CASE WHEN sub.FiscalPeriod = 0 THEN 1 ELSE sub.FiscalPeriod END,1),'MMM-yy') as FiscalYearPeriod
	,'Cash' as ReportSection
	,CASE WHEN sub.GLAccountDescriptionID = '3003' THEN '401K Contributions'
		  WHEN sub.GLAccountDescriptionID = '3004' THEN 'Payroll Set Asides'
		  WHEN sub.GLAccountDescriptionID = '3010' THEN 'General Set Asides'
		  WHEN sub.GLAccountDescriptionID = '3001' THEN 'Physician Draws'
		  WHEN sub.GLAccountDescriptionID like '13%' THEN 'Asset Purchases'
		  END as ReportGroupLevel1
	,CASE WHEN sub.GLAccountDescriptionID = '3003' THEN '401K Contributions'
		  WHEN sub.GLAccountDescriptionID = '3004' THEN 'Payroll Set Asides'
		  WHEN sub.GLAccountDescriptionID = '3010' THEN 'General Set Asides'
		  WHEN sub.GLAccountDescriptionID = '3001' THEN 'Physician Draws'
		  WHEN sub.GLAccountDescriptionID like '13%' THEN 'Asset Purchases'
		  END as ReportGroupLevel2
	,NULL as ReportGroupLevel3
	,sub.PracticeID
	,NULL as ReportingProviderID
	,SUM(CASE WHEN SUB.GLAccountDescriptionID = '3003' THEN sub.FiscalPeriodValue * -1 
			  WHEN SUB.GLAccountDescriptionID = '3001' 
					AND (((TransactionReference like '%Set Aside%' 
							OR TransactionDescription like '%Set Aside%'
							OR TransactionReference like 'MEM HC Credit Sep25%' /*Chris Cross - Added on 10/9/25 for a single tranaction in MEM*/
							OR TransactionReference like 'MEM HC Credit Oct25%' /*Chris Cross - Added on 10/9/25 for a single tranaction in MEM*/
							) 
								AND TransactionDescription <> 'WSB SET ASIDE 05/17/24 LD' /*Chris Cross - Put in place to handle a mid-month draw transaction for WSB*/
								AND TransactionDescription <> 'MBJ DRAW 5/15 LD' /*Chris Cross - 6/8/26 - Put in place to handle a mid-month draw transaction for MBJ*/)
							OR TransactionReference = 'Back Out Journal Entry 641011' /*Chris Cross - Put in place to handle a backed out entry for LRL*/)
					THEN 0       
			  WHEN SUB.GLAccountDescriptionID = '3001' THEN sub.FiscalPeriodValue * -1 
			  WHEN SUB.GLAccountDescriptionID like '13%' THEN sub.FiscalPeriodValue * -1 
			  ELSE sub.FiscalPeriodValue END) as FiscalPeriodValue
	,getdate() AS UpdatedDatetime
	
FROM 
	(
	  select 
	  t.ACTINDX
	  ,a.GLAccountDescriptionID
	  ,a.GLAccountDescription
	  ,a.GLAccountNumber
	  ,a.GLAccountName
	  ,a.GLAccountPracticeID
	  ,p.PracticeID
	  ,p.PracticeName
	  ,t.OPENYEAR as FiscalYear
	  ,t.PERIODID as FiscalPeriod
	  ,t.REFRENCE as TransactionReference
	  ,t.DSCRIPTN as TransactionDescription
	  ,t.DEBITAMT as FiscalPeriodDebits
	  ,t.CRDTAMNT as FiscalPeriodCredits
	  ,t.DEBITAMT - T.CRDTAMNT as FiscalPeriodValue
	  --,* 
	  from CORVMAP22.TPG.dbo.GL20000 t 
		left join stg.vGLAccounts a ON a.GLAccountSourceID = CAST(t.ACTINDX AS VARCHAR(100))
		left join dim.Practices p ON p.PracticeSourceID = a.GLAccountPractice
	  where 1=1
	  --AND a.GLAccountDescriptionID like '3%'
	  --AND t.REFRENCE like '%EOM ALLOC%'
	  AND a.GLAccountDescriptionID in ('3001','3003','3004','3010'
									,'1305'
									,'1306'
									,'1307'
									,'1308'
									,'1309'
									,'1310'
									,'1311'
									,'1312'
									,'1313'
									,'1314'
									,'1315'
									,'1316'
									,'1317'
									,'1318'
									,'1319'
									,'1320'
									,'1321'
									,'1322'
									,'1323'
									,'1324'
									,'1325'
									,'1390' --Asset Purchases
									)
	  AND t.PERIODID <> 0
	  AND t.OPENYEAR = @CurrentYear
	  AND t.PERIODID = @CurrentPeriod
	  AND t.VOIDED = 0
	  AND p.PracticeID is not null
		--AND p.PracticeSourceID = 'MBJ'
		
	  
	  /*Chris Cross - 2/13/25 - Added in starting balances for the year for general set asides per convo with Nick; 4/16/25 - added payroll set asides (3004) */
	  UNION ALL
	  select 
			t.ACTINDX
			  ,a.GLAccountDescriptionID
			  ,a.GLAccountDescription
			  ,a.GLAccountNumber
			  ,a.GLAccountName
			  ,a.GLAccountPracticeID
			  ,p.PracticeID
			  ,p.PracticeName
			  ,t.YEAR1 as FiscalYear
			  ,t.PERIODID as FiscalPeriod
			  ,CONCAT('Annual Starting Balance: ',t.ACTDESCR) as TransactionReference
			  ,CONCAT('Annual Starting Balance: ',t.ACTDESCR) as TransactionDescription
			  ,t.DEBITAMT as FiscalPeriodDebits
			  ,t.CRDTAMNT as FiscalPeriodCredits
			  ,t.DEBITAMT - T.CRDTAMNT as FiscalPeriodValue
			  --,t.PERDBLNC
		from CORVMAP22.TPG.dbo.GL11110 t
			left join stg.vGLAccounts a ON a.GLAccountSourceID = CAST(t.ACTINDX AS VARCHAR(100))
			left join dim.Practices p ON p.PracticeSourceID = a.GLAccountPractice
		where 1=1
		AND p.PracticeID is not null
		AND t.MNACSGMT in ('3004','3010') 
		AND t.PERIODID = '0'
		AND t.YEAR1 = @CurrentYear
		--AND @CurrentPeriod = 1 /*Only load this at the beginning of the year*/


	) sub
GROUP BY 
	sub.FiscalYear
	,sub.FiscalPeriod
	,sub.PracticeID
	,sub.GLAccountDescriptionID
	,sub.GLAccountDescription

UNION ALL

/*Starting Balance*/

--/*Hard code in negative balance entries for October*/
--INSERT INTO rpt.BlueBooks

--SELECT '2023','1','Jan-23','Cash','Carry Forward Balance', NULL, '0~DRW',NULL,-38651.49,GETDATE()
--UNION ALLSELECT '2023','1','Jan-23','Cash','Carry Forward Balance', NULL, '0~NRW',NULL,-34323.96,GETDATE()
--UNION ALL SELECT '2023','10','Oct-23','Cash','Carry Forward Balance', NULL, '0~BEB',NULL,-5678.08,GETDATE()
--UNION ALL  SELECT '2023','10','Oct-23','Cash','Carry Forward Balance', NULL, '0~BET',NULL,-19621.25,GETDATE()
--UNION ALL  SELECT '2023','10','Oct-23','Cash','Carry Forward Balance', NULL, '0~BLN',NULL,-12685.9,GETDATE()
--UNION ALL  SELECT '2023','10','Oct-23','Cash','Carry Forward Balance', NULL, '0~CAH',NULL,-19154.28,GETDATE()
--UNION ALL  SELECT '2023','10','Oct-23','Cash','Carry Forward Balance', NULL, '0~CMS',NULL,-13668.42,GETDATE()
--UNION ALL  SELECT '2023','10','Oct-23','Cash','Carry Forward Balance', NULL, '0~DDR',NULL,-96457.54,GETDATE()
--UNION ALL  SELECT '2023','10','Oct-23','Cash','Carry Forward Balance', NULL, '0~DRW',NULL,-30950.68,GETDATE()
--UNION ALL  SELECT '2023','10','Oct-23','Cash','Carry Forward Balance', NULL, '0~LLK',NULL,-2206.22,GETDATE()
--UNION ALL  SELECT '2023','10','Oct-23','Cash','Carry Forward Balance', NULL, '0~MSO',NULL,-196317.57,GETDATE()
--UNION ALL  SELECT '2023','10','Oct-23','Cash','Carry Forward Balance', NULL, '0~NMO',NULL,-14752.81,GETDATE()
--UNION ALL  SELECT '2023','10','Oct-23','Cash','Carry Forward Balance', NULL, '0~SCS',NULL,-3237.23,GETDATE()
--UNION ALL  SELECT '2023','10','Oct-23','Cash','Carry Forward Balance', NULL, '0~TDT',NULL,-8022.32,GETDATE()

--UNION ALL

/* Carry Forward Balances */

SELECT
	@CurrentYear as FiscalYear
	,@CurrentPeriod as FiscalPeriod
	,FORMAT(DATEFROMPARTS(@CurrentYear,@CurrentPeriod,1),'MMM-yy') as FiscalYearPeriod
	,'Cash' as ReportSection
	,'Carry Forward Balance' as ReportGroupLevel1
	,'Carry Forward Balance' as ReportGroupLevel2
	,'Carry Forward Balance' as ReportGroupLevel3
	,sub.PracticeID
	,NULL as ReportingProviderID
	,sub.[Ending Balance] as FiscalPeriodValue
	--,bb.FiscalPeriodValue
	,GETDATE() as UpdatedDatetime

FROM (

	select
	bb.PracticeID
	,p.PracticeName
	,bb.FiscalYear
	,bb.FiscalPeriod
	,bb.FiscalYearPeriod
	,sum(case when bb.ReportGroupLevel1 = 'Carry Forward Balance' THEN bb.FiscalPeriodValue ELSE 0 END) as 'Carry Forward Balance'
	,sum(case when bb.ReportSection = 'Revenue' THEN bb.FiscalPeriodValue ELSE 0 END) as 'Revenue'
	,sum(case when bb.ReportSection = 'Expenses' THEN bb.FiscalPeriodValue ELSE 0 END) as 'Expenses'
	,sum(case when bb.ReportGroupLevel1 = 'Physician Draws' THEN bb.FiscalPeriodValue ELSE 0 END) as 'Physician Draws'
	,sum(case when bb.ReportGroupLevel1 = '401K Contributions' THEN bb.FiscalPeriodValue ELSE 0 END) as '401K Contributions'
	,sum(case when bb.ReportGroupLevel1 = 'Payroll Set Asides' THEN bb.FiscalPeriodValue ELSE 0 END) as 'Payroll Set Asides'
	,sum(case when bb.ReportGroupLevel1 = 'General Set Asides' THEN bb.FiscalPeriodValue ELSE 0 END) as 'General Set Asides'
	,sum(case when bb.ReportGroupLevel1 = 'Asset Purchases' THEN bb.FiscalPeriodValue ELSE 0 END) as 'Asset Purchases'
	,sum(case when bb.ReportGroupLevel1 = 'Carry Forward Balance' THEN bb.FiscalPeriodValue ELSE 0 END)
		+ sum(case when bb.ReportSection = 'Revenue' THEN bb.FiscalPeriodValue ELSE 0 END)
		- sum(case when bb.ReportSection = 'Expenses' THEN bb.FiscalPeriodValue ELSE 0 END)
		+ sum(case when bb.ReportGroupLevel1 = 'Physician Draws' THEN bb.FiscalPeriodValue ELSE 0 END) 
		+ sum(case when bb.ReportGroupLevel1 = '401K Contributions' THEN bb.FiscalPeriodValue ELSE 0 END)
		+ sum(case when bb.ReportGroupLevel1 = 'Payroll Set Asides' THEN bb.FiscalPeriodValue ELSE 0 END)
		+ sum(case when bb.ReportGroupLevel1 = 'General Set Asides' THEN bb.FiscalPeriodValue ELSE 0 END)
		+ sum(case when bb.ReportGroupLevel1 = 'Asset Purchases' THEN bb.FiscalPeriodValue ELSE 0 END) as 'Ending Balance'
	from rpt.BlueBooks bb
		left join dim.Practices p ON p.PracticeID = bb.PracticeID
	where 1=1
		AND bb.ReportSection IN ('Cash','Revenue','Expenses')
		AND bb.FiscalYear = @PreviousPeriodYear
		AND bb.FiscalPeriod = @PreviousPeriod
		--AND bb.PracticeID in ('0~CAH')
		AND (@Practice = '0' OR bb.PracticeID = @Practice)
	group by 
		bb.FiscalYear
		,bb.FiscalPeriod
		,bb.FiscalYearPeriod
		,bb.PracticeID
		,p.PracticeName
) sub
	left join rpt.BlueBooks bb ON bb.ReportGroupLevel1 = 'Carry Forward Balance' 
							  AND bb.FiscalPeriod = @CurrentPeriod 
							  AND bb.FiscalYear = @CurrentYear
							  AND bb.PracticeID = sub.PracticeID
WHERE 1=1 
	AND sub.PracticeID is not null

	UNION ALL

/*Add In Ending Balances*/

SELECT
	sub.FiscalYear
	,sub.FiscalPeriod
	,FORMAT(DATEFROMPARTS(sub.FiscalYear,sub.FiscalPeriod,1),'MMM-yy') as FiscalYearPeriod
	,'Cash' as ReportSection
	,'Ending Balance' as ReportGroupLevel1
	,NULL as ReportGroupLevel2
	,NULL as ReportGroupLevel3
 	,sub.PracticeID
	,NULL as ReportingProviderID
	,SUM(sub.FiscalPeriodValue ) as FiscalPeriodValue
	,GETDATE() as UpdatedDatetime
	
FROM 
	(
	  select 
	  t.ACTINDX
	  ,a.GLAccountDescriptionID
	  ,a.GLAccountDescription
	  ,a.GLAccountNumber
	  ,a.GLAccountName
	  ,a.GLAccountPracticeID
	  ,p.PracticeID
	  ,p.PracticeName
	  ,CASE WHEN t.PERIODID = 1 THEN t.OPENYEAR - 1 ELSE t.OPENYEAR END as FiscalYear
	  ,CASE WHEN t.PERIODID = 1 THEN 12 ELSE t.PERIODID - 1 END as FiscalPeriod
	  ,t.REFRENCE as TransactionReference
	  ,t.DSCRIPTN as TransactionDescription
	  ,t.DEBITAMT as FiscalPeriodDebits
	  ,t.CRDTAMNT as FiscalPeriodCredits
	  ,t.DEBITAMT - T.CRDTAMNT as FiscalPeriodValue
	  --,* 
	  from CORVMAP22.TPG.dbo.GL20000 t 
		left join stg.vGLAccounts a ON a.GLAccountSourceID = CAST(t.ACTINDX AS VARCHAR(100))
		left join dim.Practices p ON p.PracticeSourceID = a.GLAccountPractice
	  where 1=1
	  --AND a.GLAccountDescriptionID like '3%'
	  AND t.REFRENCE like '%EOM ALLOC%'
	  AND a.GLAccountDescriptionID in ('3001')
	  AND t.PERIODID <> 0
	  AND t.OPENYEAR = @CurrentYear
	  AND t.PERIODID = @CurrentPeriod
	  AND t.VOIDED = 0
	  and p.PracticeID is not null
	  --AND p.PracticeSourceID = 'PBJ'
	) sub
GROUP BY 
	sub.FiscalYear
	,sub.FiscalPeriod
	,sub.PracticeID
	,sub.GLAccountDescriptionID
	,sub.GLAccountDescription

/*Add in calculated carry forward balances for negative balances*/




--DECLARE @Practice varchar(10) = '0' /*0 - All*/  --'DRW'
--DECLARE @AsOfDate date = '11/30/2023'--DATEADD(DAY,-1,DATEFROMPARTS(YEAR(GETDATE()),MONTH(GETDATE()),1))  
--DECLARE @CurrentYear int = YEAR(@AsOfDate) --2023
--DECLARE @CurrentPeriod int = MONTH(@AsOfDate)
--DECLARE @PreviousPeriodYear INT = CASE WHEN @CurrentPeriod > 1 THEN @CurrentYear ELSE @CurrentYear - 1 END
--DECLARE @PreviousPeriod int = CASE WHEN @CurrentPeriod = 1 THEN 12 ELSE @CurrentPeriod - 1 END
--DECLARE @EndDate date = DATEFROMPARTS(@CurrentYear,@CurrentPeriod,1)
--DECLARE @StartDate date = DATEFROMPARTS(@CurrentYear-1,1,1)
--DECLARE @12MonthStartDate date = DATEADD(MONTH,-12,@EndDate)
--DECLARE @6MonthStartDate date = DATEADD(MONTH,-6,@EndDate)



/* Handling negative values in old Carry foward balance method

INSERT INTO rpt.BlueBooks

	([FiscalYear] 
      ,[FiscalPeriod]
      ,[FiscalYearPeriod]
      ,[ReportSection]
      ,[ReportGroupLevel1]
      ,[ReportGroupLevel2]
	  ,[ReportGroupLevel3]
	  --,[ReportGroupLevel4]
      ,[PracticeID]
      ,[ReportingProviderID]
      ,[FiscalPeriodValue]
      ,[UpdatedDatetime])

SELECT
	@CurrentYear as FiscalYear
	,@CurrentPeriod as FiscalPeriod
	,FORMAT(DATEFROMPARTS(@CurrentYear,@CurrentPeriod,1),'MMM-yy') as FiscalYearPeriod
	,'Cash' as ReportSection
	,'Carry Forward Balance' as ReportGroupLevel1
	,'Carry Forward Balance' as ReportGroupLevel2
	,'Carry Forward Balance' as ReportGroupLevel3
	,sub.PracticeID
	,NULL as ReportingProviderID
	,sub.[Ending Balance] as FiscalPeriodValue
	,GETDATE() as UpdatedDatetime

FROM (

	select
	bb.PracticeID
	,p.PracticeName
	,bb.FiscalYear
	,bb.FiscalPeriod
	,bb.FiscalYearPeriod
	,sum(case when bb.ReportGroupLevel1 = 'Carry Forward Balance' THEN bb.FiscalPeriodValue ELSE 0 END) as 'Carry Forward Balance'
	,sum(case when bb.ReportSection = 'Revenue' THEN bb.FiscalPeriodValue ELSE 0 END) as 'Revenue'
	,sum(case when bb.ReportSection = 'Expenses' THEN bb.FiscalPeriodValue ELSE 0 END) as 'Expenses'
	,sum(case when bb.ReportGroupLevel1 = 'Physician Draws' THEN bb.FiscalPeriodValue ELSE 0 END) as 'Physician Draws'
	,sum(case when bb.ReportGroupLevel1 = '401K Contributions' THEN bb.FiscalPeriodValue ELSE 0 END) as '401K Contributions'
	,sum(case when bb.ReportGroupLevel1 = 'Payroll Set Asides' THEN bb.FiscalPeriodValue ELSE 0 END) as 'Payroll Set Asides'
	,sum(case when bb.ReportGroupLevel1 = 'General Set Asides' THEN bb.FiscalPeriodValue ELSE 0 END) as 'General Set Asides'
	,sum(case when bb.ReportGroupLevel1 = 'Asset Purchases' THEN bb.FiscalPeriodValue ELSE 0 END) as 'Asset Purchases'
	,sum(case when bb.ReportGroupLevel1 = 'Carry Forward Balance' THEN bb.FiscalPeriodValue ELSE 0 END)
		+ sum(case when bb.ReportSection = 'Revenue' THEN bb.FiscalPeriodValue ELSE 0 END)
		- sum(case when bb.ReportSection = 'Expenses' THEN bb.FiscalPeriodValue ELSE 0 END)
		+ sum(case when bb.ReportGroupLevel1 = 'Physician Draws' THEN bb.FiscalPeriodValue ELSE 0 END) 
		+ sum(case when bb.ReportGroupLevel1 = '401K Contributions' THEN bb.FiscalPeriodValue ELSE 0 END)
		+ sum(case when bb.ReportGroupLevel1 = 'Payroll Set Asides' THEN bb.FiscalPeriodValue ELSE 0 END)
		+ sum(case when bb.ReportGroupLevel1 = 'General Set Asides' THEN bb.FiscalPeriodValue ELSE 0 END)
		+ sum(case when bb.ReportGroupLevel1 = 'Asset Purchases' THEN bb.FiscalPeriodValue ELSE 0 END) as 'Ending Balance'
	from rpt.BlueBooks bb
		left join dim.Practices p ON p.PracticeID = bb.PracticeID
	where 1=1
		AND bb.ReportSection IN ('Cash','Revenue','Expenses')
		AND bb.FiscalYear = @PreviousPeriodYear
		AND bb.FiscalPeriod = @PreviousPeriod
		--AND bb.PracticeID in ('0~CAH')
		AND bb.PracticeID is not null
	group by 
		bb.FiscalYear
		,bb.FiscalPeriod
		,bb.FiscalYearPeriod
		,bb.PracticeID
		,p.PracticeName
) sub
	left join rpt.BlueBooks bb ON bb.ReportGroupLevel1 = 'Carry Forward Balance' 
							  AND bb.FiscalPeriod = @CurrentPeriod 
							  AND bb.FiscalYear = @CurrentYear
							  AND bb.PracticeID = sub.PracticeID
WHERE 1=1 
	AND bb.PracticeID is null
	AND sub.[Ending Balance] <= 0

	*/



/*
/* If you need to manually load Carry Forward Balances calculated from Previous Period's Ending Balance, run this -->*/
DECLARE @Practice varchar(10) = '0' /*0 - All*/  --'DRW'
DECLARE @AsOfDate date = DATEADD(DAY,-1,DATEFROMPARTS(YEAR(GETDATE()),MONTH(GETDATE()),1))  
DECLARE @CurrentYear int = YEAR(@AsOfDate) --2023
DECLARE @CurrentPeriod int = MONTH(@AsOfDate)
DECLARE @PreviousPeriodYear INT = CASE WHEN @CurrentPeriod > 1 THEN @CurrentYear ELSE @CurrentYear - 1 END
DECLARE @PreviousPeriod int = CASE WHEN @CurrentPeriod = 1 THEN 12 ELSE @CurrentPeriod - 1 END
DECLARE @EndDate date = DATEFROMPARTS(@CurrentYear,@CurrentPeriod,1)
DECLARE @StartDate date = DATEFROMPARTS(@CurrentYear-1,1,1)
DECLARE @12MonthStartDate date = DATEADD(MONTH,-12,@EndDate)
DECLARE @6MonthStartDate date = DATEADD(MONTH,-6,@EndDate)

DELETE FROM rpt.BlueBooks WHERE ReportSection in ('Cash') and ReportGroupLevel1 = 'Carry Forward Balance' and FiscalYear = @CurrentYear and FiscalPeriod = @CurrentPeriod 
INSERT INTO rpt.BlueBooks

SELECT
	@CurrentYear as FiscalYear
	,@CurrentPeriod as FiscalPeriod
	,FORMAT(DATEFROMPARTS(@CurrentYear,@CurrentPeriod,1),'MMM-yy') as FiscalYearPeriod
	,'Cash' as ReportSection
	,'Carry Forward Balance' as ReportGroupLevel1
	,'Carry Forward Balance' as ReportGroupLevel2
	,'Carry Forward Balance' as ReportGroupLevel3
	,sub.PracticeID
	,NULL as ReportingProviderID
	,sub.[Ending Balance] as FiscalPeriodValue
	--,bb.FiscalPeriodValue
	,GETDATE() as UpdatedDatetime

FROM (

	select
	bb.PracticeID
	,p.PracticeName
	,bb.FiscalYear
	,bb.FiscalPeriod
	,bb.FiscalYearPeriod
	,sum(case when bb.ReportGroupLevel1 = 'Carry Forward Balance' THEN bb.FiscalPeriodValue ELSE 0 END) as 'Carry Forward Balance'
	,sum(case when bb.ReportSection = 'Revenue' THEN bb.FiscalPeriodValue ELSE 0 END) as 'Revenue'
	,sum(case when bb.ReportSection = 'Expenses' THEN bb.FiscalPeriodValue ELSE 0 END) as 'Expenses'
	,sum(case when bb.ReportGroupLevel1 = 'Physician Draws' THEN bb.FiscalPeriodValue ELSE 0 END) as 'Physician Draws'
	,sum(case when bb.ReportGroupLevel1 = '401K Contributions' THEN bb.FiscalPeriodValue ELSE 0 END) as '401K Contributions'
	,sum(case when bb.ReportGroupLevel1 = 'Payroll Set Asides' THEN bb.FiscalPeriodValue ELSE 0 END) as 'Payroll Set Asides'
	,sum(case when bb.ReportGroupLevel1 = 'General Set Asides' THEN bb.FiscalPeriodValue ELSE 0 END) as 'General Set Asides'
	,sum(case when bb.ReportGroupLevel1 = 'Asset Purchases' THEN bb.FiscalPeriodValue ELSE 0 END) as 'Asset Purchases'
	,sum(case when bb.ReportGroupLevel1 = 'Carry Forward Balance' THEN bb.FiscalPeriodValue ELSE 0 END)
		+ sum(case when bb.ReportSection = 'Revenue' THEN bb.FiscalPeriodValue ELSE 0 END)
		- sum(case when bb.ReportSection = 'Expenses' THEN bb.FiscalPeriodValue ELSE 0 END)
		+ sum(case when bb.ReportGroupLevel1 = 'Physician Draws' THEN bb.FiscalPeriodValue ELSE 0 END) 
		+ sum(case when bb.ReportGroupLevel1 = '401K Contributions' THEN bb.FiscalPeriodValue ELSE 0 END)
		+ sum(case when bb.ReportGroupLevel1 = 'Payroll Set Asides' THEN bb.FiscalPeriodValue ELSE 0 END)
		+ sum(case when bb.ReportGroupLevel1 = 'General Set Asides' THEN bb.FiscalPeriodValue ELSE 0 END)
		+ sum(case when bb.ReportGroupLevel1 = 'Asset Purchases' THEN bb.FiscalPeriodValue ELSE 0 END) as 'Ending Balance'
	from rpt.BlueBooks bb
		left join dim.Practices p ON p.PracticeID = bb.PracticeID
	where 1=1
		AND bb.ReportSection IN ('Cash','Revenue','Expenses')
		AND bb.FiscalYear = @PreviousPeriodYear
		AND bb.FiscalPeriod = @PreviousPeriod
		--AND bb.PracticeID in ('0~CAH')
		AND (@Practice = '0' OR bb.PracticeID = @Practice)
	group by 
		bb.FiscalYear
		,bb.FiscalPeriod
		,bb.FiscalYearPeriod
		,bb.PracticeID
		,p.PracticeName
) sub
	left join rpt.BlueBooks bb ON bb.ReportGroupLevel1 = 'Carry Forward Balance' 
							  AND bb.FiscalPeriod = @CurrentPeriod 
							  AND bb.FiscalYear = @CurrentYear
							  AND bb.PracticeID = sub.PracticeID
WHERE 1=1 
*/




/* OLD CARRY FORWARD BALANCE METHOD 

SELECT
	sub.FiscalYear
	,sub.FiscalPeriod
	,FORMAT(DATEFROMPARTS(sub.FiscalYear,sub.FiscalPeriod,1),'MMM-yy') as FiscalYearPeriod
	,'Cash' as ReportSection
	,'Carry Forward Balance' as ReportGroupLevel1
	,NULL as ReportGroupLevel2
	,NULL as ReportGroupLevel3
 	,sub.PracticeID
	,NULL as ReportingProviderID
	,SUM(sub.FiscalPeriodValue ) as FiscalPeriodValue
	,GETDATE() as UpdatedDatetime
	
FROM 
	(
	  select 
	  t.ACTINDX
	  ,a.GLAccountDescriptionID
	  ,a.GLAccountDescription
	  ,a.GLAccountNumber
	  ,a.GLAccountName
	  ,a.GLAccountPracticeID
	  ,p.PracticeID
	  ,p.PracticeName
	  ,t.OPENYEAR as FiscalYear
	  ,t.PERIODID as FiscalPeriod
	  ,t.REFRENCE as TransactionReference
	  ,t.DSCRIPTN as TransactionDescription
	  ,t.DEBITAMT as FiscalPeriodDebits
	  ,t.CRDTAMNT as FiscalPeriodCredits
	  ,t.DEBITAMT - T.CRDTAMNT as FiscalPeriodValue
	  --,* 
	  from CORVMAP22.TPG.dbo.GL20000 t 
		left join stg.vGLAccounts a ON a.GLAccountSourceID = t.ACTINDX
		left join dim.Practices p ON p.PracticeSourceID = a.GLAccountPractice
	  where 1=1
	  --AND a.GLAccountDescriptionID like '3%'
	  AND t.REFRENCE like '%EOM ALLOC%'
	  AND a.GLAccountDescriptionID in ('3001')
	  AND t.PERIODID <> 0
	  AND t.OPENYEAR = @CurrentYear
	  AND t.PERIODID = @CurrentPeriod
	  AND t.VOIDED = 0
	  and p.PracticeID is not null
	  --AND p.PracticeSourceID = 'PBJ'
	) sub
GROUP BY 
	sub.FiscalYear
	,sub.FiscalPeriod
	,sub.PracticeID
	,sub.GLAccountDescriptionID
	,sub.GLAccountDescription
*/
GO
