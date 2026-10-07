CREATE VIEW [rpt].[VUSPI_Fact_Stats_ClinicalOperations] AS


/*Patient Days - added by Chris Cross on 10/6/2026*/
WITH CTE_DailyPatientDays AS (
	select 
		a.AccountLocationID as facility_id
		,l.LocationName as facility_name
		,d.Date as service_date
		,'Clincial Operations' as master_department
		,'' as sub_department
		--, CASE 
		--	WHEN a.AccountClass = 'Inpatient' THEN 'Inpatient'
		--	ELSE 'Observation'
		--  END as sub_department
		,'Patient Days' as unit_of_service
		,'days' as unit_type
		,count(distinct a.AccountID) as actual_volume
	 --select d.Date, a.AccountDateOfAdmission, a.AccountDateOfDischarge, a.AccountID, l.LocationName, a.AccountClass, a.AccountTotalCharges
	from dim.Dates d
		LEFT JOIN fact.vAccounts a ON d.Date >= convert(date,a.AccountDateOfAdmission) 
									   AND d.Date < convert(date,ISNULL(a.AccountDateOfDischarge,GETDATE())) 
		LEFT JOIN dim.Locations l ON l.LocationID = a.AccountLocationID	
	where 1=1
		AND a.AccountIsActive = 1
		AND a.AccountDataSourceID = 5
		AND a.AccountSourceID like '6%'
		AND a.AccountTotalCharges > 0
		AND a.AccountLocationID in ('5~43006001','5~43005005','5~43004001')
		AND d.Date >= '1/1/2024'
		AND (a.AccountClass = 'Inpatient' OR (a.AccountClass = 'Outpatient' AND a.AccountType = 'Observation')) 
	group by 
		a.AccountLocationID --as facility_id
		,l.LocationName --as facility_name
		,d.Date --as service_date
		--, CASE 
		--	WHEN a.AccountClass = 'Inpatient' THEN 'Inpatient'
		--	ELSE 'Observation'
		--  END --as sub_department
		),

CTE_DailyCharges AS 
	(
	select
		a.AccountLocationID as facility_id
		,l.LocationName as facility_name
		,d.Date as service_date
		,'Clinical Operations' as master_department
		,'' as sub_department
		,'Gross Revenue' as unit_of_service
		,'Charges' as unit_type
		,sum(case when a.AccountClass = 'Inpatient' OR a.AccountType = 'Observation' THEN t.TransactionAmount ELSE 0 END) as InpatientCharges
		,sum(case when a.AccountClass <> 'Inpatient' AND a.AccountType <> 'Observation' THEN t.TransactionAmount ELSE 0 END) as OutpatientCharges
		,sum(t.TransactionAmount) as TotalCharges
	from fact.Transactions2 t 
		left join dim.Dates d ON t.TransactionDateOfPosting = d.Date
		left join fact.Accounts a ON a.AccountID = t.TransactionAccountID
		left join dim.Locations l ON l.LocationID = a.AccountLocationID
	where 1=1
		AND t.TransactionDatasourceID = 5
		AND t.TransactionType = 'Charge'
		AND a.AccountID is not null
		AND a.AccountTotalCharges > 0
		AND a.AccountSourceID like '6%'
		AND a.AccountLocationID in ('5~43006001','5~43005005','5~43004001')
		AND d.Date between '1/1/2023' and GETDATE()
	group by 
		a.AccountLocationID
		,l.LocationName
		,d.Date
	),

CTE_DailyPatientDaysAdjustment AS (
	select
		dc.facility_id
		,dc.facility_name
		,d.Date
		,sum(dc.TotalCharges) TotalChargesLast90
		,sum(dc.InpatientCharges) InpatientChargesLast90
		,CASE WHEN sum(dc.InpatientCharges) = 0 THEN 1 ELSE sum(dc.TotalCharges) / sum(dc.InpatientCharges) END as AdjustmentFactor
	from dim.Dates d
		LEFT JOIN CTE_DailyCharges dc ON dc.service_date <= d.date AND dc.service_date >= DATEADD(DAY,-90,d.Date)
	where 1=1
		AND d.Date between '1/1/2024' and getdate()
	group by 
		dc.facility_id
		,dc.facility_name
		,d.Date
	--order by 
	--	dc.facility_id
	--	,d.Date
	)

SELECT
	pd.facility_id
	,pd.facility_name
	,pd.service_date as service_date
	,'Clinical Operations' as master_department
	,'' as sub_department
	,'Adjusted Patient Days' as unit_of_service
	,'days' as unit_type
	,pd.actual_volume as PatientDays
	,a.AdjustmentFactor as AdjustmentFactor
	,pd.actual_volume * isnull(a.AdjustmentFactor,1) as actual_volume
FROM CTE_DailyPatientDays pd
	LEFT JOIN CTE_DailyPatientDaysAdjustment a ON a.Date = pd.service_date
												  and a.facility_id = pd.facility_id
WHERE 1=1
--ORDER BY
--	pd.facility_id
--	,pd.service_date
	

--select * from rpt.VUSPI_Fact_Stats_ClinicalOperations order by facility_id, service_Date
	
	

	


/* --Replaced by Chris Cross on 10/6/2026
SELECT 
    a.AccountLocationID AS facility_id,
    l.LocationName AS facility_name,
    CAST(a.AccountDateOfAdmission AS DATE) AS service_date,
    'Clinical Operations' AS master_department,
    CASE 
        WHEN a.AccountClass = 'Inpatient' THEN 'Inpatient'
        ELSE 'Observation'
    END AS sub_department,
    'Patient Days' AS unit_of_service,
    'days' AS unit_type,
    SUM(DATEDIFF(day, a.AccountDateOfAdmission, a.AccountDateOfDischarge)) AS actual_volume
FROM fact.vAccounts a
LEFT JOIN dim.vLocations l ON l.LocationID = a.AccountLocationID
WHERE 1=1 
  AND a.AccountDataSourceID = 5
  AND a.AccountIsActive = 1
  AND (a.AccountClass = 'Inpatient' OR (a.AccountClass = 'Outpatient' AND a.AccountType = 'Observation'))
  AND a.AccountLocationID IN (
      '5~43001006','5~43001007','5~43001008','5~43002001','5~43004001',
      '5~43004002','5~43004003','5~43004004','5~43005005','5~43005006',
      '5~43005007','5~43005008','5~43006001','5~43006002','5~43006003',
      '5~43006004','5~430050061'
  )
  AND a.AccountDateOfAdmission IS NOT NULL
  AND a.AccountDateOfDischarge IS NOT NULL
  AND DATEDIFF(day, a.AccountDateOfAdmission, a.AccountDateOfDischarge) >= 1
GROUP BY 
    a.AccountLocationID,
    l.LocationName,
    CAST(a.AccountDateOfAdmission AS DATE),
    CASE 
        WHEN a.AccountClass = 'Inpatient' THEN 'Inpatient'
        ELSE 'Observation'
    END;
*/
GO
