CREATE VIEW [rpt].[vNewAndSurgicalVisits] AS
select
	p.PracticeCompany
	,p.PracticeSpecialty
	,p.PracticeID
	,p.PracticeName
	,p.PracticeIsSameStore
	,prv.ProviderFullName as Provider
	,bb.FiscalYear
	,bb.FiscalPeriod
	,d.Quarter
	,d.QuarterName
	,FORMAT(DATEFROMPARTS(2024, bb.FiscalPeriod, 1), 'MMM') as FiscalPeriodName
	,CONCAT(bb.FiscalYear,RIGHT(CONCAT('00',bb.FiscalPeriod),2)) AS FiscalYearPeriodSort
	,bb.FiscalYearPeriod
	
	,bb.ReportGroupLevel1
	,bb.ReportGroupLevel2
	,bb.FiscalPeriodValue
	,CASE WHEN ((P.PracticeCompany = 'HPIP' or p.PracticeAbbreviation='BET') AND p.PracticeName not in ('HPIP Anesthesia')) OR p.PracticeIsSameStore = 1 THEN 'Include' ELSE 'Exclude' END as IsIncluded
from rpt.BlueBooks bb
	left join dim.Practices p ON p.PracticeID = bb.PracticeID
	LEFT JOIN (
    SELECT
        Year,
        Month,
        MAX(Quarter) AS Quarter,
        MAX(QuarterName) AS QuarterName
    FROM dim.dates
    GROUP BY Year, Month
) d
    ON bb.FiscalYear = d.Year
   AND bb.FiscalPeriod = d.Month
	--left join dim.dates d on bb.FiscalPeriod = d.Month and bb.FiscalYear = d.Year --Wrong Join, this is creating duplicates
	left join dim.vProviders prv ON prv.ProviderID = bb.ReportingProviderID
where 1=1
	AND ((bb.ReportSection IN ('Non-assist Visits') AND bb.ReportGroupLevel1 = 'Surgical Visits') 
		OR (bb.ReportSection IN ('Visits') AND bb.ReportGroupLevel2 = 'New PT Visits'))
	AND bb.FiscalYear >= 2023
	--AND bb.FiscalYear < YEAR(GETDATE())
GO
