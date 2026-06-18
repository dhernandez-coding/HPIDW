CREATE VIEW [fact].[vVisitStatsPB] AS


SELECT
	  vs.[VisitStatsID]
      ,vs.[VisitStatsDataSourceID]
      ,vs.[VisitStatsProviderID]
	  ,p.ProviderFullName as VisitStatsProviderName
	  ,pd.PracticeID
	  ,pr.PracticeName
      ,vs.[VisitStatsDepartmentID]
	  ,d.DepartmentName as VisitStatsDepartmentName
      ,vs.[VisitStatsDate]
      ,vs.[VisitStatsAvailableHours]
      ,vs.[VisitStatsBookedHours]
      ,vs.[VisitStatsAvailableOpeningsOnDay]
      ,vs.[VisitStatsRegularOpeningsOnDay]
      ,vs.[VisitStatsSameDayRegularBooked]
      ,vs.[VisitStatsRegularBooked]
      ,vs.[VisitStatsOverbookOpenings]
      ,vs.[VisitStatsSameDayOverbooked]
      ,vs.[VisitStatsOverbooked]
      ,vs.[VisitStatsArrivedCount]
      ,vs.[VisitStatsNoShowCount]
      ,vs.[VisitStatsLeftWithoutBeingSeenCount]
      ,vs.[VisitStatsCompletedCount]
      ,vs.[VisitStatsScheduledCount]
      ,vs.[VisitStatsCanceledCount]
      ,vs.[VisitStatsPatientCanceledCount]
      ,vs.[VisitStatsSameDayCanceledCount]
      ,vs.[VisitStatsLateCanceledCount]
      ,vs.[VisitStatsLateProviderCanceledCount]
      ,vs.[VisitStatsRescheduledCount]
      ,vs.[VisitStatsSameDayBooked]
      ,vs.[VisitStatsForTodayLeadDays]
      ,vs.[VisitStatsForTodayCount]
      ,vs.[VisitStatsMadeTodayLeadDays]
      ,vs.[VisitStatsMadeTodayCount]
      ,vs.[VisitStatsRegularAvailableHours]
      ,vs.[VisitStatsOverbookAvailableHours]
      ,vs.[VisitStatsUnavailableOpeningsUsed]
      ,vs.[VisitStatsHeldOpeningsUsed]
      ,vs.[VisitStatsUpdateDate]
  FROM [HPIDW].[fact].[VisitStatsPB] vs
	LEFT JOIN dim.vProviders p on p.ProviderID = vs.VisitStatsProviderID
	LEFT JOIN dim.vDepartments d on d.DepartmentID = vs.VisitStatsDepartmentID
	LEFT JOIN map.PracticeDepartments pd on pd.DepartmentID = vs.VisitStatsDepartmentID
	LEFT JOIN dim.Practices pr on pr.PracticeID = pd.PracticeID
  WHERE 1=1 
  	AND p.ProviderFullName NOT LIKE 'TPG%'
	AND p.ProviderFullName NOT LIKE 'HPIP%'
	AND p.ProviderFullName NOT LIKE 'CCC%'
	AND p.ProviderFullName NOT LIKE '%XR%'
	AND year(vs.[VisitStatsDate]) >= (year(getdate()) - 2)
GO
