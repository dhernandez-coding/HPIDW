CREATE VIEW [rpt].[vUSPI_Fact_Stats_Emergency_EDVisits] AS

SELECT 
	a.LocationID as facility_id
	,a.Location as facility_name
	,convert(date,a.HospitalAdmissionTime) as service_date
	,'Emergency' as master_department
	,'Emergency Room-Mgmt' as sub_department
	,'ED Visits' as unit_of_service
	,'count' as unit_type
	,count(distinct a.CSN) as actual_volume
FROM OPENQUERY([CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM],'		
	SELECT 	
		l.LOC_ID as LocationID
		,l.LOC_NAME as Location
		,d.DEPARTMENT_NAME as LastDepartment
		,e.HSP_ACCOUNT_ID as HAR
		,e.PAT_ENC_CSN_ID as CSN
		,p.PAT_MRN_ID as MRN
		,e.ADT_ARRIVAL_TIME as ArrivalTime
		,e.HOSP_ADMSN_TIME as HospitalAdmissionTime
		,e.EMER_ADM_DATE AS EDAdmissionTime
		,e.ED_DISP_TIME as EDDispositionTime
		,e.ED_DEPARTURE_TIME as EDDepartureTime
		,e.OP_ADM_DATE AS OPAdmissionTime
		,e.INP_ADM_DATE as InpatientAdmitTime
		,e.HOSP_DISCH_TIME as HospitalDischargeTime
		--,e.*
	FROM [Clarity].[ORGFILTER].PAT_ENC_HSP e	
		LEFT JOIN [Clarity].[ORGFILTER].CLARITY_DEP d ON d.DEPARTMENT_ID = e.DEPARTMENT_ID
		LEFT JOIN [Clarity].[ORGFILTER].CLARITY_LOC l ON l.LOC_ID = d.REV_LOC_ID
		--LEFT JOIN [Clarity].[ORGFILTER].PAT_ENC pe ON pe.PAT_ENC_CSN_ID = e.PAT_ENC_CSN_ID
		LEFT JOIN [Clarity].[ORGFILTER].PATIENT p ON p.PAT_ID = e.PAT_ID
	WHERE 1=1	
		AND d.REV_LOC_ID IN (''43004001'' --CHN
							,''43005001'' --CHS
							,''43006001'' --NWSH
							)
		AND e.ED_EPISODE_ID is not null
		AND e.HOSP_ADMSN_TIME between ''1/1/2024'' AND GETDATE()
		--AND e.HSP_ACCOUNT_ID = ''608573210''
		') A
GROUP BY	
	a.LocationID 
	,a.Location
	,convert(date,a.HospitalAdmissionTime)
GO
