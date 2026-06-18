CREATE PROCEDURE [rpt].[spLoadBlueBookAR] 

	--@CurrentYear int 
	--,@CurrentPeriod int 
	--,@Practice varchar(10)
	
as

--SET NOCOUNT ON

DECLARE @Practice varchar(10) = '0' /*0 - All*/  --'DRW'
DECLARE @AsOfDate date = DATEADD(DAY,-1,DATEFROMPARTS(YEAR(GETDATE()),MONTH(GETDATE()),1))  
DECLARE @CurrentYear int = YEAR(@AsOfDate) --2023
DECLARE @CurrentPeriod int = MONTH(@AsOfDate)
DECLARE @EndDate date = DATEFROMPARTS(@CurrentYear,@CurrentPeriod,1)
DECLARE @StartDate date = DATEFROMPARTS(@CurrentYear-1,1,1)
DECLARE @12MonthStartDate date = DATEADD(MONTH,-12,@EndDate)
DECLARE @6MonthStartDate date = DATEADD(MONTH,-6,@EndDate)

--select @Practice, @AsOfDate, @CurrentYear,@CurrentPeriod

DELETE FROM rpt.BlueBooks WHERE ReportSection in ('AR Aging') and FiscalYear = @CurrentYear and FiscalPeriod = @CurrentPeriod

/*Epic Data*/
INSERT INTO rpt.BlueBooks
([FiscalYear]
      ,[FiscalPeriod]
      ,[FiscalYearPeriod]
      ,[ReportSection]
      ,[ReportGroupLevel1]
      ,[ReportGroupLevel2]
	  --,[ReportGroupLevel3]
      ,[PracticeID]
      ,[ReportingProviderID]
      ,[FiscalPeriodValue]
      ,[UpdatedDatetime])

	SELECT
		@CurrentYear as FiscalYear
		,@CurrentPeriod as FiscalPeriod
		,FORMAT(DATEFROMPARTS(@CurrentYear,@CurrentPeriod,1),'MMM-yy') as FiscalYearPeriod
		,'AR Aging' as ReportSection
		,sub.ReportGroupLevel1
		,sub.ReportGroupLevel2
		,sub.PracticeID
		,sub.ReportingProviderID
		--,sum(sub.ARAmountAll) as ARAmountAll
		,sum(sub.ARAmountActive) as FiscalPeriodValue--AmountActive
		--,sum(sub.ARAmountBadDebt) as AmountBadDebt
		,GETDATE() as UpdatedDatetime
	FROM (
		select 
			tx.TX_ID
			,tx.SERVICE_DATE
			,ISNULL(pg.PayerGroupName,'Other Commercial') as ReportGroupLevel1
			,CASE WHEN DATEDIFF(D,tx.SERVICE_DATE,@AsOfDate) BETWEEN 0 AND 30 THEN '0-30'
				  WHEN DATEDIFF(D,tx.SERVICE_DATE,@AsOfDate) BETWEEN 31 AND 60 THEN '31-60'
				  WHEN DATEDIFF(D,tx.SERVICE_DATE,@AsOfDate) BETWEEN 61 AND 90 THEN '61-90'
				  WHEN DATEDIFF(D,tx.SERVICE_DATE,@AsOfDate) BETWEEN 91 AND 120 THEN '91-120'
				  WHEN DATEDIFF(D,tx.SERVICE_DATE,@AsOfDate) > 120 THEN '121+'
				  ELSE NULL END as ReportGroupLevel2
			,pt.PracticeID
			,CONCAT('5~',tx.BILLING_PROV_ID) as ReportingProviderID
			,count(1) as DetailCount
			,sum(tx.ARAmountAll) as ARAmountAll
			,sum(tx.ARAmountActive) as ARAmountActive
			,sum(tx.ARAmountBadDebt) as ARAmountBadDebt
		FROM OPENQUERY([CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM],
		'select
			t.TX_ID
			,tx.SERVICE_DATE
			,tx.DEPARTMENT_ID
			,tx.PAYOR_ID
			,tx.BILLING_PROV_ID
			,count(1) as DetailCount
			,sum(t.AMOUNT) as ARAmountAll
			,sum(t.ACTIVE_AR_AMOUNT) as ARAmountActive
			,sum(t.BAD_DEBT_AR_AMOUNT) as ARAmountBadDebt
		from CLARITY.[ORGFILTER].CLARITY_TDL_TRAN t
			left join CLARITY.[ORGFILTER].ARPB_TRANSACTIONS tx ON tx.TX_ID = t.TX_ID

		where 1=1
			AND t.TRAN_TYPE = 1
			AND t.DETAIL_TYPE < 40 
			AND t.POST_DATE <= DATEADD(DAY,-1,DATEFROMPARTS(YEAR(GETDATE()),MONTH(GETDATE()),1)) --@AsOfDate
			AND (t.SERV_AREA_ID IN (425,430)
				OR (t.SERV_AREA_ID IN (452000) AND t.ORIG_SERVICE_DATE >= ''3/23/2026''))
			--AND tx.DEPARTMENT_ID IN (''42501006001'')
		group by
			t.TX_ID
			,tx.SERVICE_DATE
			,tx.DEPARTMENT_ID
			,tx.PAYOR_ID
			,tx.BILLING_PROV_ID
		') tx
			left join dim.Departments d ON d.DepartmentID = CONCAT('5~',tx.DEPARTMENT_ID)
			left join map.PracticeDepartments pd ON pd.DepartmentID = CONCAT('5~',tx.DEPARTMENT_ID)
			left join dim.Practices pt ON pt.PracticeID = pd.PracticeID
			left join dim.Payers py ON py.PayerID = CONCAT('5~',ISNULL(tx.PAYOR_ID,'0')) /*If no assigned Payor then assign to self-pay*/
			left join dim.PayerGroups pg ON pg.PayerGroupID = py.PayerGroupID
		where 1=1 
			AND pd.DepartmentID is not null
		group by 
			tx.TX_ID
			,tx.SERVICE_DATE
			,pt.PracticeID
			,tx.BILLING_PROV_ID
			,pg.PayerGroupName
		) sub
	WHERE 1=1
		AND sub.ARAmountAll > 0
	GROUP BY 
		sub.ReportGroupLevel1
		,sub.ReportGroupLevel2
		,sub.PracticeID
		,sub.ReportingProviderID

/*--Old methodology that returns only current AR--
	SELECT 
	@CurrentYear as FiscalYear
	,@CurrentPeriod as FiscalPeriod
	,FORMAT(DATEFROMPARTS(@CurrentYear,@CurrentPeriod,1),'MMM-yy') as FiscalYearPeriod
	, 'AR Aging' as [ReportSection]
	,ISNULL(pg.PayerGroupName,'Other Commercial') as ReportGroupLevel1
	,CASE WHEN DATEDIFF(D,TX.SERVICE_DATE,GETDATE()) BETWEEN 0 AND 30 THEN '0-30'
			WHEN DATEDIFF(D,TX.SERVICE_DATE,GETDATE()) BETWEEN 31 AND 60 THEN '31-60'
			WHEN DATEDIFF(D,TX.SERVICE_DATE,GETDATE()) BETWEEN 61 AND 90 THEN '61-90'
			WHEN DATEDIFF(D,TX.SERVICE_DATE,GETDATE()) BETWEEN 91 AND 120 THEN '91-120'
			WHEN DATEDIFF(D,TX.SERVICE_DATE,GETDATE()) > 120 THEN '121+'
			ELSE NULL END  as [ReportGroupLevel2]
	,pt.PracticeID as [PracticeID]
	,CONCAT('5~',tx.BILLING_PROV_ID) as [ReportingProviderID]
	,SUM(TX.OUTSTANDING_AMT) as[FiscalPeriodValue]
	,getdate() as [UpdatedDatetime]
	--,CASE WHEN a.BAD_DEBT_BALANCE > 0 THEN 'Y' else 'N' end as [IsBadDebt]

	FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].CLARITY.[ORGFILTER].ARPB_TRANSACTIONS tx
	left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].CLARITY.[ORGFILTER].ARPB_TX_MODERATE tm ON tm.TX_ID = tx.TX_ID	
	left join dim.Departments d ON d.DepartmentID = CONCAT('5~',tx.DEPARTMENT_ID)
	left join map.PracticeDepartments pd ON pd.DepartmentID = CONCAT('5~',tx.DEPARTMENT_ID)
	left join dim.Practices pt ON pt.PracticeID = pd.PracticeID
	left join dim.Payers py ON py.PayerID = CONCAT('5~',tx.Payor_ID)
	left join dim.PayerGroups pg ON pg.PayerGroupID = py.PayerGroupID

	WHERE 1=1 
	AND TX.SERVICE_AREA_ID in (425,430)
	AND TX.TX_TYPE_C = 1 /*Charges*/
	AND TX.OUTSTANDING_AMT > 0 -- no credits
	and ISNULL(tm.AR_CLASS_C,0) <> 2 /*Exclude bad debt*/
	AND pd.DepartmentID is not null 

	GROUP BY 
	pt.PracticeID
	,tx.BILLING_PROV_ID
	,pg.PayerGroupName
	,CASE WHEN DATEDIFF(D,TX.SERVICE_DATE,GETDATE()) BETWEEN 0 AND 30 THEN '0-30'
		WHEN DATEDIFF(D,TX.SERVICE_DATE,GETDATE()) BETWEEN 31 AND 60 THEN '31-60'
		WHEN DATEDIFF(D,TX.SERVICE_DATE,GETDATE()) BETWEEN 61 AND 90 THEN '61-90'
		WHEN DATEDIFF(D,TX.SERVICE_DATE,GETDATE()) BETWEEN 91 AND 120 THEN '91-120'
		WHEN DATEDIFF(D,TX.SERVICE_DATE,GETDATE()) > 120 THEN '121+'
		ELSE NULL END 
	--,CASE WHEN a.BAD_DEBT_BALANCE > 0 THEN 'Y' else 'N' end 
*/

/*APM Data*/
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
		@CurrentYear as FiscalYear
		,@CurrentPeriod as FiscalPeriod
		,FORMAT(DATEFROMPARTS(@CurrentYear,@CurrentPeriod,1),'MMM-yy') as FiscalYearPeriod
		, 'AR Aging' as [ReportSection]	
		, ISNULL(pg.PayerGroupName,'Other Commercial') as ReportGroupLevel1
		, sub.ARAgingGroup as ReportGroupLevel2
		, NULL as ReportGroupLevel3
		--, sub.IsPI as ReportGroupLevel4
		 ,sub.ReportGroupLevel4 as ReportGroupLevel4 
		, pt.PracticeID as PracticeID
		, CONCAT('1~',sub.Billing_Prov_Practitioner_ID) as ReportingProviderID
		, SUM(sub.ARBalance) as FiscalPeriodValue
		, GETDATE() as UpdatedDatetime
	FROM (
		select --top 100 
		a.Account_Number
		,a.Voucher_Number
		,a.Service_Date
		,CASE WHEN DATEDIFF(DAY,a.Service_Date,GETDATE()) <= 30 then '0-30'
			  WHEN DATEDIFF(DAY,a.Service_Date,GETDATE()) BETWEEN 31 AND 60 then '31-60'
			  WHEN DATEDIFF(DAY,a.Service_Date,GETDATE()) BETWEEN 61 AND 90 then '61-90'
			  WHEN DATEDIFF(DAY,a.Service_Date,GETDATE()) BETWEEN 91 AND 120 then '91-120' 
			  WHEN DATEDIFF(DAY,a.Service_Date,GETDATE()) > 120 then '121+' END as ARAgingGroup
		,a.Carrier_ID
		,a.Carrier_Name
		,a.Insurance_Category_ID
		,a.Ins_Category_Abbreviation
		,a.Ins_Category_Description
		,a.Ins_Rpt_Class_Description
		,a.Billing_Prov_Practitioner_ID
		,a.Billing_Prov_Abbreviation
		--, CASE WHEN  Department_Abbreviation ='FKVP'
		--THEN 'PI' END AS 'IsPI'
		,CASE --Test for special conditions for special reports for drs king and thomason
			WHEN a.Department_Abbreviation IN ('FKVP','FKVPRXS') THEN 'PI'
			WHEN a.Location_ID = 135 AND A.BILLING_PROV_ABBREVIATION ='TDT' THEN 'Hinton'
			WHEN a.Location_ID = 223 AND A.BILLING_PROV_ABBREVIATION ='TDT' THEN 'Binger'
			WHEN a.Location_ID = 230 AND A.BILLING_PROV_ABBREVIATION ='TDT' THEN 'Hydro'
			WHEN a.Location_ID = 95 AND A.BILLING_PROV_ABBREVIATION ='TDT' THEN 'Hinton'
		END AS 'ReportGroupLevel4'
		,ISNULL(a.Fees,0) as Charges
		,ISNULL(a.Posted_Adjustments,0) as Adjustments
		,ISNULL(a.Posted_Payments,0) as Payments
		,ISNULL(a.Posted_Refunds,0) as Refunds
		,ISNULL(a.Posted_Misc_Debits,0) as Debits
		,ISNULL(a.Fees,0) 
			- ISNULL(a.Posted_Adjustments,0) 
			- ISNULL(a.Posted_Payments,0) 
			+ ISNULL(a.Posted_Refunds,0) 
			+ ISNULL(a.Posted_Misc_Debits,0) as ARBalance
		,CASE WHEN ISNULL(a.Fees,0) 
			- ISNULL(a.Posted_Adjustments,0) 
			- ISNULL(a.Posted_Payments,0) 
			+ ISNULL(a.Posted_Refunds,0) 
			+ ISNULL(a.Posted_Misc_Debits,0) < 0 THEN 'Yes' ELSE 'No' END as IsCreditBalance 
		FROM tievmdb03.Ntier_627200.PM.[vwATB] a
		WHERE 1=1
			AND (ISNULL(a.Fees,0) 
				- ISNULL(a.Posted_Adjustments,0) 
				- ISNULL(a.Posted_Payments,0) 
				+ ISNULL(a.Posted_Refunds,0) 
				+ ISNULL(a.Posted_Misc_Debits,0)) > 0 /*Exclude Credit and Zero Balances*/
			AND a.Ins_Rpt_Class_Description <> 'Collections' /*Exclude Bad Debt*/
		) sub
		left join map.PracticeProviders pp ON pp.ProviderID = CONCAT('1~',sub.Billing_Prov_Practitioner_ID)
											AND pp.PracticeProviderEffectiveDate <=  DATEFROMPARTS(@CurrentYear, @CurrentPeriod, 1)
											AND pp.PracticeProviderEndDate >= DATEFROMPARTS(@CurrentYear, @CurrentPeriod, 1)
		left join dim.Practices pt ON pt.PracticeID = pp.PracticeID
		left join dim.Payers py ON py.PayerID =  CONCAT('1~',ISNULL(convert(varchar,sub.Carrier_ID),'SELF')) /*If no assigned Payor then assign to self-pay*/
		left join dim.PayerGroups pg ON pg.PayerGroupID = py.PayerGroupID
	GROUP BY 
		sub.ARAgingGroup
		,pg.PayerGroupName
		--,sub.IsPI
		,ReportGroupLevel4
		,pt.PracticeID
		,sub.Billing_Prov_Practitioner_ID
		

/*APM Customer Data*/
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
		@CurrentYear as FiscalYear
		,@CurrentPeriod as FiscalPeriod
		,FORMAT(DATEFROMPARTS(@CurrentYear,@CurrentPeriod,1),'MMM-yy') as FiscalYearPeriod
		, 'AR Aging' as [ReportSection]	
		, ISNULL(pg.PayerGroupName,'Other Commercial') as ReportGroupLevel1
		, sub.ARAgingGroup as ReportGroupLevel2
		, NULL as ReportGroupLevel3
		--, sub.IsPI as ReportGroupLevel4
		 ,sub.ReportGroupLevel4 as ReportGroupLevel4 
		, CASE 
			  WHEN sub.Department_ID = 45 THEN '0~JRS'
			  WHEN sub.Department_ID = 46 THEN '0~OPCL'
			  ELSE pt.PracticeID 
			END as PracticeID
		, CONCAT('12~',sub.Billing_Prov_Practitioner_ID) as ReportingProviderID
		, SUM(sub.ARBalance) as FiscalPeriodValue
		, GETDATE() as UpdatedDatetime
	FROM (
		select --top 100 
		a.Account_Number
		,a.Voucher_Number
		,a.Service_Date
		,CASE WHEN DATEDIFF(DAY,a.Service_Date,GETDATE()) <= 30 then '0-30'
			  WHEN DATEDIFF(DAY,a.Service_Date,GETDATE()) BETWEEN 31 AND 60 then '31-60'
			  WHEN DATEDIFF(DAY,a.Service_Date,GETDATE()) BETWEEN 61 AND 90 then '61-90'
			  WHEN DATEDIFF(DAY,a.Service_Date,GETDATE()) BETWEEN 91 AND 120 then '91-120' 
			  WHEN DATEDIFF(DAY,a.Service_Date,GETDATE()) > 120 then '121+' END as ARAgingGroup
		,a.Carrier_ID
		,a.Carrier_Name
		,a.Insurance_Category_ID
		,a.Ins_Category_Abbreviation
		,a.Ins_Category_Description
		,a.Ins_Rpt_Class_Description
		,a.Billing_Prov_Practitioner_ID
		,a.Billing_Prov_Abbreviation
		,a.Department_ID
		--, CASE WHEN  Department_Abbreviation ='FKVP'
		--THEN 'PI' END AS 'IsPI'
		,CASE --Test for special conditions for special reports for drs king and thomason
			WHEN a.Department_Abbreviation IN ('FKVP','FKVPRXS') THEN 'PI'
			WHEN a.Location_ID = 135 AND A.BILLING_PROV_ABBREVIATION ='TDT' THEN 'Hinton'
			WHEN a.Location_ID = 223 AND A.BILLING_PROV_ABBREVIATION ='TDT' THEN 'Binger'
			WHEN a.Location_ID = 230 AND A.BILLING_PROV_ABBREVIATION ='TDT' THEN 'Hydro'
			WHEN a.Location_ID = 95 AND A.BILLING_PROV_ABBREVIATION ='TDT' THEN 'Hinton'
		END AS 'ReportGroupLevel4'
		,ISNULL(a.Fees,0) as Charges
		,ISNULL(a.Posted_Adjustments,0) as Adjustments
		,ISNULL(a.Posted_Payments,0) as Payments
		,ISNULL(a.Posted_Refunds,0) as Refunds
		,ISNULL(a.Posted_Misc_Debits,0) as Debits
		,ISNULL(a.Fees,0) 
			- ISNULL(a.Posted_Adjustments,0) 
			- ISNULL(a.Posted_Payments,0) 
			+ ISNULL(a.Posted_Refunds,0) 
			+ ISNULL(a.Posted_Misc_Debits,0) as ARBalance
		,CASE WHEN ISNULL(a.Fees,0) 
			- ISNULL(a.Posted_Adjustments,0) 
			- ISNULL(a.Posted_Payments,0) 
			+ ISNULL(a.Posted_Refunds,0) 
			+ ISNULL(a.Posted_Misc_Debits,0) < 0 THEN 'Yes' ELSE 'No' END as IsCreditBalance 
		FROM tievmdb03.Ntier_HPI_Customers.PM.[vwATB] a
		WHERE 1=1
			AND (ISNULL(a.Fees,0) 
				- ISNULL(a.Posted_Adjustments,0) 
				- ISNULL(a.Posted_Payments,0) 
				+ ISNULL(a.Posted_Refunds,0) 
				+ ISNULL(a.Posted_Misc_Debits,0)) > 0 /*Exclude Credit and Zero Balances*/
			AND a.Ins_Rpt_Class_Description <> 'Collections' /*Exclude Bad Debt*/
		) sub
		LEFT JOIN map.PracticeProviders pp 	 ON pp.ProviderID = CONCAT('12~',sub.Billing_Prov_Practitioner_ID)
				 AND pp.PracticeProviderEffectiveDate <= DATEFROMPARTS(@CurrentYear, @CurrentPeriod, 1)
				 AND pp.PracticeProviderEndDate >= DATEFROMPARTS(@CurrentYear, @CurrentPeriod, 1)
				 -- ADD THIS TO PREVENT DUPLICATE AR FOR OPCL AND JRS 04/03/2026 DH
				 AND (
				     sub.Billing_Prov_Practitioner_ID <> '95823' 
				     OR (sub.Billing_Prov_Practitioner_ID = '95823' AND (
				          (sub.Department_ID = '45' AND pp.PracticeID = '0~JRS') OR
				          (sub.Department_ID = '46' AND pp.PracticeID = '0~OPCL')
				        )) 
				 )
		left join dim.Practices pt ON pt.PracticeID = pp.PracticeID
		left join dim.Payers py ON py.PayerID =  CONCAT('12~',ISNULL(convert(varchar,sub.Carrier_ID),'SELF')) /*If no assigned Payor then assign to self-pay*/
		left join dim.PayerGroups pg ON pg.PayerGroupID = py.PayerGroupID
	GROUP BY 
		sub.ARAgingGroup
		,pg.PayerGroupName
		--,sub.IsPI
		,ReportGroupLevel4
		,pt.PracticeID
		,sub.Billing_Prov_Practitioner_ID
		,sub.Department_ID


	
/*ModMed  Data*/


INSERT INTO rpt.BlueBooks
([FiscalYear]
      ,[FiscalPeriod]
      ,[FiscalYearPeriod]
      ,[ReportSection]
      ,[ReportGroupLevel1]
      ,[ReportGroupLevel2]
      ,[PracticeID]
      ,[ReportingProviderID]
      ,[FiscalPeriodValue]
      ,[UpdatedDatetime])


	
	SELECT 
		@CurrentYear as FiscalYear
		,@CurrentPeriod as FiscalPeriod
		,FORMAT(DATEFROMPARTS(@CurrentYear,@CurrentPeriod,1),'MMM-yy') as FiscalYearPeriod
		, 'AR Aging' as [ReportSection]	
		, ISNULL(p.PayerGroupName,'Other Commercial') as ReportGroupLevel1
		, p.ARAgingGroup as ReportGroupLevel2
		, p.PracticeID as PracticeID
		, CONCAT('15~',p.primary_provider_id) as ReportingProviderID
		, SUM(p.ARBalance) as FiscalPeriodValue
		, GETDATE() as UpdatedDatetime

		FROM(

SELECT
    b.bill_id,

    CASE 
        WHEN ar.ARCoverageBucket = 'Self-Pay'
            THEN '53623-pod37'
        ELSE ar.payer_id
    END AS payer_id,

    ar.ARBalance,
	CASE 
		WHEN ar.payer_id is null and ar.ARCoverageBucket = 'Self-Pay' THEN '0~7'      --Self-Pay
		ELSE p.PayerGroupID END as PayerGroupID,

	CASE 
		WHEN ar.payer_id is null and ar.ARCoverageBucket = 'Self-Pay' THEN 'Self-Pay'
		ELSE pg.PayerGroupName END as PayerGroupName,
    b.service_date,
    b.primary_provider_id,

    CASE 
        WHEN DATEDIFF(DAY,b.service_date,GETDATE()) <= 30 THEN '0-30'
        WHEN DATEDIFF(DAY,b.service_date,GETDATE()) BETWEEN 31 AND 60 THEN '31-60'
        WHEN DATEDIFF(DAY,b.service_date,GETDATE()) BETWEEN 61 AND 90 THEN '61-90'
        WHEN DATEDIFF(DAY,b.service_date,GETDATE()) BETWEEN 91 AND 120 THEN '91-120'
        ELSE '121+'
    END AS ARAgingGroup,

    CASE 
        WHEN b.primary_provider_id IN ('16609184-pod37','219144-pod37') THEN '0~NBN'
        WHEN b.primary_provider_id = '18914534-pod37' THEN '0~LBB'
    END AS PracticeID

FROM stg.ModMed_Bills b

INNER JOIN (
    SELECT
        bill_id,

        /* Collapse Primary + Secondary + Tertiary into Insurance */
        CASE 
            WHEN coverage_type = 'Self-Pay' THEN 'Self-Pay'
            ELSE 'Insurance'
        END AS ARCoverageBucket,

        /* Use payer_id only for insurance rows */
        MAX(payer_id) AS payer_id,

        SUM(balance) AS ARBalance
    FROM stg.ModMed_AR
    GROUP BY
        bill_id,
        CASE 
            WHEN coverage_type = 'Self-Pay' THEN 'Self-Pay'
            ELSE 'Insurance'
        END
) ar
    ON ar.bill_id = b.bill_id
	LEFT JOIN dim.Payers p
		ON p.PayerID = CONCAT('15~',ar.payer_id)
	LEFT JOIN [dim].[PayerGroups] pg 
		ON p.PayerGroupID = pg.PayerGroupID
		) p

	GROUP BY 
		p.ARAgingGroup
		,p.PayerGroupName
		,p.PracticeID
		,p.primary_provider_id




--	SELECT 
--		@CurrentYear as FiscalYear
--		,@CurrentPeriod as FiscalPeriod
--		,FORMAT(DATEFROMPARTS(@CurrentYear,@CurrentPeriod,1),'MMM-yy') as FiscalYearPeriod
--		, 'AR Aging' as [ReportSection]	
--		, ISNULL(p.PayerGroupName,'Other Commercial') as ReportGroupLevel1
--		, p.ARAgingGroup as ReportGroupLevel2
--		, p.PracticeID as PracticeID
--		, CONCAT('15~',p.primary_provider_id) as ReportingProviderID
--		, SUM(p.ARBalance) as FiscalPeriodValue
--		, GETDATE() as UpdatedDatetime

--		FROM(

--SELECT b.bill_id,
--CASE 
--WHEN c.payer_id is null and c.coverage_type = 'Self-Pay' THEN '53623-pod37'
--ELSE c.payer_id END as payer_id,
--CASE 
--WHEN c.payer_id is null and c.coverage_type = 'Self-Pay' THEN 'Self-Pay'
--ELSE p.PayerName END as PayerName,
--CASE 
--WHEN c.payer_id is null and c.coverage_type = 'Self-Pay' THEN '0~7'      --Self-Pay
--ELSE p.PayerGroupID END as PayerGroupID,
--CASE 
--WHEN c.payer_id is null and c.coverage_type = 'Self-Pay' THEN 'Self-Pay'
--ELSE pg.PayerGroupName END as PayerGroupName,
--b.service_date,
--b.primary_provider_id,
--CASE WHEN DATEDIFF(DAY,b.service_date,GETDATE()) <= 30 then '0-30'
--			  WHEN DATEDIFF(DAY,b.service_date,GETDATE()) BETWEEN 31 AND 60 then '31-60'
--			  WHEN DATEDIFF(DAY,b.service_date,GETDATE()) BETWEEN 61 AND 90 then '61-90'
--			  WHEN DATEDIFF(DAY,b.service_date,GETDATE()) BETWEEN 91 AND 120 then '91-120' 
--			  WHEN DATEDIFF(DAY,b.service_date,GETDATE()) > 120 then '121+' END as ARAgingGroup,
--CASE WHEN b.primary_provider_id = '16609184-pod37' THEN '0~NBN'
--	 WHEN b.primary_provider_id = '219144-pod37' THEN '0~NBN'
--	 WHEN b.primary_provider_id = '18914534-pod37' THEN '0~LBB' END AS PracticeID,
--MAX(b.total_posted_charges) as Charges,
--MAX(b.total_payments) as Payments,
--MAX(b.applied_adjustments_total) as Adjustments,
--MAX(b.balance) as ARBalance
--FROM stg.ModMed_Bills b
--LEFT JOIN  stg.ModMed_Charges c on c.bill_id = b.bill_id
--	AND c.bill_id is not null
--LEFT JOIN dim.payers p on p.PayerID = CONCAT('15~',c.payer_id)
--LEFT JOIN [dim].[PayerGroups] pg on p.PayerGroupID = pg.PayerGroupID
--LEFT JOIN [dim].[Providers] pr on pr.ProviderID = CONCAT('15~',b.primary_provider_id)

--WHERE b.balance > 0
--GROUP BY b.bill_id,c.payer_id, b.service_date,p.PayerName,p.PayerGroupID,pg.PayerGroupName,b.primary_provider_id, c.coverage_type

--) p
--	GROUP BY 
--		p.ARAgingGroup
--		,p.PayerGroupName
--		,p.PracticeID
--		,p.primary_provider_id
GO
