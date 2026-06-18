/*

This query compiles volumes for labor productivity departments where labor targets are based on the volume during the pay period. It sums cases or transfers in 
for the pay periods given by HPI. It unions each "department," for lack of better term, because PACU and sterile processing both take into account all cases.

*/
CREATE VIEW [rpt].[vLaborVolumeDepartmentTargets] AS 

SELECT
	--sub.[PayPeriodStartDate]
	--,sub.[PayPeriodEndDate]
	sub.[PayDate]
	,sub.LocationName
	,sub.TargetEvents
	,sub.LaborTarget
	,sub.TargetEvents * lst.TargetVariable										AS StatsHours
FROM (

-- 1: Pain and OR cases: querying all cases from our data warehouse and then grouping them by location/department

	SELECT
		CAST(p.PayDate AS DATE)													AS PayDate
		,c.VisitCaseLocationID													AS LocationID
		,CASE WHEN l.LocationName = 'HPI CHN PAIN'		THEN 'Pain North'
			WHEN l.LocationName = 'HPI CHN OR'			THEN 'Surgery North'
			WHEN l.LocationName = 'HPI CHS PAIN'		THEN 'Pain South'
			WHEN l.LocationName = 'HPI CHS OR'			THEN 'Surgery South'
			WHEN l.LocationName = 'HPI NWSH OR'			THEN 'Surgery NWSH'
			WHEN l.LocationName = 'HPI CHS ENDOSCOPY'	THEN NULL
			WHEN l.LocationName = 'HPI CHN ENDOSCOPY'	THEN NULL
			ELSE NULL END														AS LocationName
		,COUNT(DISTINCT c.VisitCaseID)											AS TargetEvents -- Surgical Cases
		,NULL /*CASE WHEN l.LocationName = 'HPI CHN PAIN'	THEN (COUNT(DISTINCT c.VisitCaseID)*0.9) 
			WHEN l.LocationName = 'HPI CHN OR'				THEN (COUNT(DISTINCT c.VisitCaseID)*4.6)
			WHEN l.LocationName = 'HPI CHS PAIN'			THEN (COUNT(DISTINCT c.VisitCaseID)*0.9)
			WHEN l.LocationName = 'HPI CHS OR'				THEN (COUNT(DISTINCT c.VisitCaseID)*4.6)
			WHEN l.LocationName = 'HPI NWSH OR'				THEN (COUNT(DISTINCT c.VisitCaseID)*10.0)
			WHEN l.LocationName = 'HPI CHS ENDOSCOPY'		THEN (COUNT(DISTINCT c.VisitCaseID)*0.0)
			WHEN l.LocationName = 'HPI CHN ENDOSCOPY'		THEN (COUNT(DISTINCT c.VisitCaseID)*0.0)
		ELSE null END*/															AS LaborTarget
	FROM fact.VisitCases c

	LEFT JOIN map.LaborPayPeriods p 
		ON cast(c.VisitCaseServiceDate as date) = P.PayPeriodDate
	LEFT JOIN dim.Locations l 
		ON l.LocationID = c.VisitCaseLocationID

	WHERE 1=1
		AND c.VisitCaseLogStatus = 'Posted'
		AND p.PayDate IS NOT NULL
		AND c.VisitCaseDatesourceID = 5

	GROUP BY 
		c.VisitCaseLocationID
		,p.PayDate
		,l.LocationName

	--ORDER BY PayDate

-- 2: all Med/Surg and ICU from Clarity ADT feed, bringing in all transfers in (event type 3) 
-- and then grouping by department, excluding emergency since it will be its own union

UNION ALL

	SELECT
		CAST(p.PayDate AS DATE)														AS PayDate
		,cd.DEPARTMENT_ID															AS LocationID
		,CASE 
			WHEN cd.DEPARTMENT_NAME = 'HPI CHN MED/SURG'	THEN 'Med-Surg North'
			WHEN cd.DEPARTMENT_NAME = 'HPI CHS MED/SURG'	THEN 'Med-Surg South'
			WHEN cd.DEPARTMENT_NAME = 'HPI CHS ICU'			THEN 'ICU South'
			WHEN cd.DEPARTMENT_NAME = 'HPI NWSH MED/SURG'	THEN 'Med-Surg NWSH'	  
			ELSE NULL 
		END																			AS LocationName --NULL
		,COUNT(DISTINCT EVENT_ID)													AS TargetEvents
		,NULL /*CASE
			WHEN cd.DEPARTMENT_NAME = 'HPI CHN MED/SURG'	THEN (COUNT(DISTINCT EVENT_ID)*11.2) 
			WHEN cd.DEPARTMENT_NAME = 'HPI CHS MED/SURG'	THEN (COUNT(DISTINCT EVENT_ID)*11.2) 
			WHEN cd.DEPARTMENT_NAME = 'HPI CHS ICU'			THEN (COUNT(DISTINCT EVENT_ID)*16.8) 
			WHEN cd.DEPARTMENT_NAME = 'HPI NWSH MED/SURG'	THEN (COUNT(DISTINCT EVENT_ID)*30.0) 
			ELSE NULL
			END		*/																AS LaborTarget

	FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[CLARITY_ADT] adtin

	LEFT JOIN map.LaborPayPeriods p
		ON CAST(adtin.EFFECTIVE_TIME AS date) = p.PayPeriodDate
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[CLARITY_DEP] cd
		ON cd.DEPARTMENT_ID = adtin.DEPARTMENT_ID
			AND cd.department_name not like '%emergency%'
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].PAT_ENC_HSP eh
		ON eh.PAT_ENC_CSN_ID = adtin.PAT_ENC_CSN_ID
	INNER JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].HSP_ACCOUNT a
		ON eh.PAT_ENC_CSN_ID = a.PRIM_ENC_CSN_ID
			AND a.disch_loc_id IN (43004001, 43005005, 43006001) /*HPI CHN, HPI CHS, HPI NWSH*/
	
	WHERE 1=1 
		AND adtin.EVENT_TYPE_C = 3 -- transfer into -- 1 admit, 3 transfer in, 4 transfer out
		AND p.PayDate is not null
		
	GROUP BY 
		cd.DEPARTMENT_ID
		,p.PayDate
		,cd.DEPARTMENT_NAME
		

-- 3: all ER from Clarity ADT feed, grouping by department 

UNION ALL 

	SELECT
		CAST(p.PayDate AS DATE)														AS PayDate
		,cd.DEPARTMENT_ID															AS LocationID
		,CASE WHEN cd.DEPARTMENT_NAME = 'HPI CHN EMERGENCY'		THEN 'ER North'
			  WHEN cd.DEPARTMENT_NAME = 'HPI CHS EMERGENCY'		THEN 'ER South'
			  WHEN cd.DEPARTMENT_NAME = 'HPI NWSH EMERGENCY'	THEN 'ER NWSH'
			  ELSE NULL END															AS LocationName 
		,COUNT(DISTINCT EVENT_ID)													AS TargetEvents
		,NULL /*CASE WHEN cd.DEPARTMENT_NAME like '%EMERGENCY' THEN (COUNT(DISTINCT EVENT_ID)*3.0)
		ELSE null END*/																AS LaborTarget
	FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[CLARITY_ADT] adtin

	LEFT JOIN map.LaborPayPeriods p 
		ON cast(adtin.EFFECTIVE_TIME as date) = p.PayPeriodDate
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[CLARITY_DEP] cd 
		ON cd.DEPARTMENT_ID = adtin.DEPARTMENT_ID
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].PAT_ENC_HSP eh 
		ON eh.PAT_ENC_CSN_ID = adtin.PAT_ENC_CSN_ID
	INNER JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].HSP_ACCOUNT a 
		ON eh.PAT_ENC_CSN_ID = a.PRIM_ENC_CSN_ID
	
	WHERE 1=1 
		AND adtin.EVENT_TYPE_C IN(1,3) -- transfer into -- 1 admit, 3 transfer in, 4 transfer out
		AND a.disch_loc_id IN (43004001, 43005005, 43006001) /*HPI CHN, HPI CHS, HPI NWSH*/
		AND cd.Department_name like '%EMERGENCY'
		and p.PayDate is NOT NULL

	GROUP BY 
		cd.DEPARTMENT_ID
		,p.PayDate
		,cd.DEPARTMENT_NAME
		

-- 4: all CT units coming from our data warehouse

UNION ALL 

	SELECT
		CAST(p.PayDate AS DATE)													AS PayDate
		,t.[TransactionDepartmentID]											AS LocationID
		,CASE	WHEN dept.DepartmentName = 'HPI CHN CT' THEN 'Imaging CT North'
				WHEN dept.DepartmentName = 'HPI CHS CT' THEN 'Imaging CT South'
				ELSE NULL 
		END																		AS LocationName
		--,d.FirstDayOfMonth
		--,d.[Date]
		,SUM(CASE WHEN t.TransactionIsCTCharge = 'Yes' THEN t.TransactionUnits ELSE 0 END)	AS TargetEvents
		,NULL																	AS LaborTarget
	FROM [fact].[vTransactions2] t

	LEFT JOIN map.LaborPayPeriods p 
		ON cast(t.TransactionDateOfService as date) = P.PayPeriodDate
	LEFT JOIN dim.Dates d 
		ON d.[Date] = convert(date,t.TransactionDateOfService)
	LEFT JOIN dim.Departments dept 
		ON dept.DepartmentID = t.TransactionDepartmentID

	WHERE 1=1
		AND t.TransactionBillingType = 'HB'
		AND t.TransactionType = 'Charge'
		AND t.TransactionStatus = 'Active'
		AND t.TransactionIsCTCharge = 'Yes'
		AND t.TransactionDateOfService >= '1/1/2023'
		and p.PayDate IS NOT NULL
		AND t.TransactionDatasourceID = 5

	GROUP BY 
		t.[TransactionDepartmentID]
		,p.PayDate
		,dept.DepartmentName



-- 5: all MRI units, coming from our data warehouse
UNION ALL

	SELECT
		CAST(p.PayDate AS DATE)																AS PayDate
		,t.[TransactionDepartmentID]														AS LocationID
		,CASE WHEN dept.DepartmentName = 'HPI CHS MRI' THEN 'Imaging MRI South'
			  WHEN dept.DepartmentName = 'HPI CHN MRI' THEN 'Imaging MRI North'
			  ELSE NULL END																	AS LocationName
		--,d.FirstDayOfMonth
		--,d.Date
		,SUM(CASE WHEN t.TransactionIsMRICharge = 'Yes' THEN t.TransactionUnits ELSE 0 END)	AS TargetEvents
		,NULL																				AS LaborTarget
	FROM [fact].[vTransactions2] t

	LEFT JOIN map.LaborPayPeriods p 
		ON cast(t.TransactionDateOfService as date) = P.PayPeriodDate
	LEFT JOIN dim.Dates d 
		ON d.Date = convert(date,t.TransactionDateOfService)
	LEFT JOIN dim.Departments dept 
		ON dept.DepartmentID = t.TransactionDepartmentID

	WHERE 1=1
		AND t.TransactionBillingType = 'HB'
		AND t.TransactionType = 'Charge'
		AND t.TransactionStatus = 'Active'
		AND t.TransactionIsMRICharge = 'Yes'
		AND t.TransactionDateOfService >= '1/1/2023'
		and p.PayDate is NOT NULL
		AND t.TransactionDatasourceID = 5

	GROUP BY 
		t.[TransactionDepartmentID]
		,p.PayDate
		,dept.DepartmentName



-- 6: all ultrasound units, coming from our data warehouse 
UNION ALL

	SELECT
		CAST(p.PayDate AS DATE)													AS PayDate
		,t.[TransactionDepartmentID]											AS LocationID
		,CASE WHEN dept.DepartmentName = 'HPI CHS ULTRASOUND' THEN 'Imaging Ultrasound South'
			  WHEN dept.DepartmentName = 'HPI CHN ULTRASOUND' THEN 'Imaging Ultrasound North'
			  ELSE NULL END														AS LocationName
		--,d.FirstDayOfMonth
		--,d.[Date]
		,SUM(CASE 
			WHEN t.TransactionIsUltrasoundCharge = 'Yes' THEN t.TransactionUnits 
			ELSE 0 END)															AS TargetEvents
		,NULL																	AS LaborTarget
	FROM [fact].[vTransactions2] t

	LEFT JOIN map.LaborPayPeriods p 
		ON cast(t.TransactionDateOfService as date) = P.PayPeriodDate
	LEFT JOIN dim.Dates d 
		ON d.Date = convert(date,t.TransactionDateOfService)
	LEFT JOIN dim.Departments dept 
		ON dept.DepartmentID = t.TransactionDepartmentID
	WHERE 1=1
		AND t.TransactionBillingType = 'HB'
		AND t.TransactionType = 'Charge'
		AND t.TransactionStatus = 'Active'
		AND t.TransactionIsUltrasoundCharge = 'Yes'
		AND t.TransactionDateOfService >= '1/1/2023'
		and p.PayDate IS NOT NULL
		AND t.TransactionDatasourceID = 5

	GROUP BY 
		t.[TransactionDepartmentID]
		,p.PayDate
		,dept.DepartmentName

-- 7: all cases, still grouped by locations like the first query, but this time using location logic just to group into PACU North/South/NWSH

UNION ALL

	SELECT
		CAST(p.PayDate AS DATE)																AS PayDate
		,c.VisitCaseLocationID													AS LocationID
		,CASE WHEN l.LocationName like '%CHN%'	then 'PACU North'
			WHEN l.LocationName like '%CHS%'	then 'PACU South'
			WHEN l.LocationName like '%NWSH%'	then 'PACU NWSH'
			ELSE NULL end														AS LocationName
		,COUNT(DISTINCT c.VisitCaseID)											AS TargetEvents -- Surgical Cases
		,NULL /*COUNT(DISTINCT c.VisitCaseID) * 1*/								AS LaborTarget
	FROM fact.VisitCases c

	LEFT JOIN map.LaborPayPeriods p
		ON c.VisitCaseServiceDate = p.PayPeriodDate
	LEFT JOIN dim.Locations l 
		ON l.LocationID = c.VisitCaseLocationID

	WHERE 1=1
		AND c.VisitCaseLogStatus = 'Posted'
		AND p.PayDate IS NOT NULL
		AND c.VisitCaseDatesourceID = 5

	GROUP BY
		c.VisitCaseLocationID
		,p.PayDate
		,l.LocationName


-- 8: all cases, still grouped by locations like the first query, but this time using location logic just to group into Sterile Processing North/South/NWSH 
UNION ALL

	SELECT
		CAST(p.PayDate AS DATE)													AS PayDate
		,c.VisitCaseLocationID													AS LocationID
		--,c.VisitCaseService
		,CASE WHEN l.LocationName like '%CHN%'	then 'Sterile Processing North'
			--WHEN l.LocationName like '%CHS%'	then 'Sterile Processing South'
			--WHEN l.LocationName like '%NWSH%'	then 'Sterile Processing NWSH'
			ELSE NULL end														AS LocationName
		,COUNT(DISTINCT c.VisitCaseID)											AS TargetEvents -- Surgical Cases
		,NULL /*COUNT(DISTINCT c.VisitCaseID) * 1*/								AS LaborTarget
	FROM fact.VisitCases c

	LEFT JOIN map.LaborPayPeriods p 
		ON cast(c.VisitCaseServiceDate AS Date) = p.PayPeriodDate
	LEFT JOIN dim.Locations l 
		ON l.LocationID = c.VisitCaseLocationID

	WHERE 1=1
		AND c.VisitCaseLogStatus = 'Posted'
		AND (l.LocationName LIKE '%CHN%')
			--OR l.LocationName LIKE '%CHS%'
			--OR l.LocationName LIKE '%NWSH%')
		AND p.PayDate IS NOT NULL
		AND c.VisitCaseDatesourceID = 5

	GROUP BY 				   
		c.VisitCaseLocationID   
		,p.PayDate
		,l.LocationName

-- 9: all GI coming from Clarity ADT using transfer in logic and grouping by location
UNION ALL

	SELECT 
		CAST(p.PayDate AS DATE)															AS PayDate
		,cd.DEPARTMENT_ID																AS LocationID
		,CASE WHEN cd.DEPARTMENT_NAME = 'HPI CHS ENDOSCOPY' THEN 'Gastro South'
			  ELSE NULL END																AS LocationName
		,COUNT(DISTINCT EVENT_ID)														AS TargetEvents
		,NULL /*CASE WHEN cd.DEPARTMENT_NAME like '%endo%' THEN (COUNT(DISTINCT EVENT_ID)*0.9) 
		else null end*/																	AS LaborTarget

	FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[CLARITY_ADT] adtin

	LEFT JOIN map.LaborPayPeriods p 
		ON CAST(adtin.EFFECTIVE_TIME AS date) = p.PayPeriodDate
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[CLARITY_DEP] cd
		ON cd.DEPARTMENT_ID = adtin.DEPARTMENT_ID
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].PAT_ENC_HSP eh 
		ON eh.PAT_ENC_CSN_ID = adtin.PAT_ENC_CSN_ID
	INNER JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].HSP_ACCOUNT a  
		ON eh.PAT_ENC_CSN_ID = a.PRIM_ENC_CSN_ID
	
	WHERE 1=1 
		AND adtin.EVENT_TYPE_C IN(1,3) -- transfer into -- 1 admit, 3 transfer in, 4 transfer out
		AND a.disch_loc_id IN (43004001, 43005005, 43006001) /*HPI CHN, HPI CHS, HPI NWSH*/
		AND cd.Department_name like '%end%'
		AND cd.Department_name not like '%CHN%'
		and p.PayDate IS NOT NULL

	GROUP BY
		cd.DEPARTMENT_ID
		,p.PayDate
		,cd.DEPARTMENT_NAME

 --10: all outpatient cases grouped by location
UNION ALL

	SELECT 
		CAST(p.PayDate AS DATE)															AS PayDate
		,cd.DEPARTMENT_ID																AS LocationID
		,CASE WHEN cd.DEPARTMENT_NAME like '%CHN%'	then 'Outpatient North'
			WHEN cd.DEPARTMENT_NAME like '%CHS%'	then 'Outpatient South'
			--WHEN cd.DEPARTMENT_NAME like '%NWSH%'	then 'Outpatient NWSH'
			ELSE NULL end														AS LocationName
		,COUNT(DISTINCT EVENT_ID)														AS TargetEvents
		,NULL /*CASE WHEN cd.DEPARTMENT_NAME like '%endo%' THEN (COUNT(DISTINCT EVENT_ID)*0.9) 
		else null end*/																	AS LaborTarget

	FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[CLARITY_ADT] adtin

	LEFT JOIN map.LaborPayPeriods p 
		ON CAST(adtin.EFFECTIVE_TIME AS date) = p.PayPeriodDate
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[CLARITY_DEP] cd
		ON cd.DEPARTMENT_ID = adtin.DEPARTMENT_ID
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].PAT_ENC_HSP eh 
		ON eh.PAT_ENC_CSN_ID = adtin.PAT_ENC_CSN_ID
	INNER JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].HSP_ACCOUNT a  
		ON eh.PAT_ENC_CSN_ID = a.PRIM_ENC_CSN_ID
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_ACCT_BASECLS_HA bc 
		ON bc.ACCT_BASECLS_HA_C = a.ACCT_BASECLS_HA_C
	
	WHERE 1=1 
		AND adtin.EVENT_TYPE_C IN(1,3) -- transfer into -- 1 admit, 3 transfer in, 4 transfer out
		AND a.disch_loc_id IN (43004001, 43005005, 43006001) /*HPI CHN, HPI CHS, HPI NWSH*/
		and p.PayDate IS NOT NULL
		AND bc.ABBR = 'OP' --outpatient accounts
		AND (cd.DEPARTMENT_NAME like '%CHN%' OR cd.DEPARTMENT_NAME like '%CHS%')


	GROUP BY
		cd.DEPARTMENT_ID
		,p.PayDate
		,cd.DEPARTMENT_NAME
		

-- 11: all imaging units coming from our data warehouse

UNION ALL 

	SELECT
		CAST(p.PayDate AS DATE)													AS PayDate
		,t.[TransactionDepartmentID]											AS LocationID
		,CASE	WHEN dept.DepartmentName like '%CHN%'	THEN 'Imaging North'
				WHEN dept.DepartmentName like '%CHS%'	THEN 'Imaging South'
				WHEN dept.DepartmentName like '%NWSH%'	THEN 'Imaging NWSH'
				ELSE dept.DepartmentName 
		END																		AS LocationName
		--,d.FirstDayOfMonth
		--,d.[Date]
		,SUM(CASE
			WHEN t.TransactionIsCTCharge = 'Yes'			THEN t.TransactionUnits 
			WHEN t.TransactionIsUltrasoundCharge = 'Yes'	THEN t.TransactionUnits
			WHEN t.TransactionIsMRICharge = 'Yes'			THEN t.TransactionUnits
			ELSE 0 END)															AS TargetEvents
		,NULL																	AS LaborTarget
	FROM [fact].[vTransactions2] t

	LEFT JOIN map.LaborPayPeriods p 
		ON cast(t.TransactionDateOfService as date) = P.PayPeriodDate
	LEFT JOIN dim.Dates d 
		ON d.[Date] = convert(date,t.TransactionDateOfService)
	LEFT JOIN dim.Departments dept 
		ON dept.DepartmentID = t.TransactionDepartmentID

	WHERE 1=1
		AND t.TransactionBillingType = 'HB'
		AND t.TransactionType = 'Charge'
		AND t.TransactionStatus = 'Active'
		AND (
			t.TransactionIsCTCharge = 'Yes'
			OR t.TransactionIsUltrasoundCharge = 'Yes'
			OR t.TransactionIsMRICharge = 'Yes'
			)
		AND t.TransactionDateOfService >= '1/1/2023'
		and p.PayDate IS NOT NULL
		AND (
			dept.DepartmentName like '%ULTRASOUND'
			OR dept.DepartmentName like '% MRI'
			OR dept.DepartmentName like '% CT'
			)
		AND t.TransactionDatasourceID = 5

	GROUP BY 
		t.[TransactionDepartmentID]
		,p.PayDate
		,dept.DepartmentName


) sub

LEFT JOIN [map].[LaborStatsTargets] lst
	ON sub.LocationName = lst.Department
		AND lst.Department IS NOT NULL

WHERE 1=1
	--AND sub.PayDate IS NOT NULL
GO
