CREATE    VIEW [rpt].[VUSPI_Fact_OutpatientSurgeryUnit_ORMinutes] AS


select
	vc.VisitCaseLocationID as facility_id
	,l.LocationName as facility_name
	,vc.VisitCaseServiceDate as service_date
	,'Outpatient Surgery Unit' AS master_department
    ,CASE 
        WHEN l.LocationName LIKE '%ENDO%' THEN 'Endoscopy' 
		WHEN l.LocationName LIKE '%PAIN%' THEN 'Pain' 
        ELSE 'OR' 
     END AS sub_department
    ,'OR Minutes' AS unit_of_service
    ,'Minutes' AS unit_type
    ,SUM(CAST(vc.VisitCaseMinutesInOR AS DECIMAL(18,2))) AS actual_volume
from fact.VisitCases vc
	left join dim.locations l ON l.LocationID = vc.VisitCaseLocationID
	left join fact.Visits2 v ON v.VisitID = vc.VisitCaseVisitID
	left join fact.Accounts a ON a.AccountID = v.VisitAccountID
where 1=1
	and vc.VisitCaseDatesourceID = 5
	and vc.VisitCaseScheduleStatus = 'Completed'
	and a.AccountClass = 'Outpatient'
	and vc.VisitCaseMinutesInOR is not null
group by
	vc.VisitCaseLocationID
	,l.LocationName
	,vc.VisitCaseServiceDate
GO
