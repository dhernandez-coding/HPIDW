create VIEW [rpt].[VUSPI_Fact_Stats_PostSurgicalUnit_PatDays] AS


/*Patient Days - added by Chris Cross on 10/6/2026*/

	select 
		a.AccountLocationID as facility_id
		,l.LocationName as facility_name
		,d.Date as service_date
		,'Post Surgical Unit' as master_department
		,'' as sub_department
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
GO
