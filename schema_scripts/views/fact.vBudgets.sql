CREATE VIEW [fact].[vBudgets] as


select 
	   [BudgetID]
      ,[BudgetDatasourceID]
      ,[BudgetSourceID]
      ,b.BudgetTypeID [BudgetTypeID]
	  ,bt.BudgetTypeName as BudgetTypeName
      ,[BudgetDate]
      ,[BudgetLocationID]
	  ,l.LocationName as BudgetLocationName
      ,[BudgetDepartmentID]
	  ,d.DepartmentName as BudgetDepartmentName
      ,[BudgetServiceLineID]
	  ,sl.ServiceLineName as BudgetServiceLineName
      ,[BudgetSpecialtyID]
	  ,s.SpecialtyName as BudgetSpecialtyName
      ,[BudgetProviderID]
	  ,CASE WHEN prv.ProviderID is not null THEN CONCAT(prv.ProviderLastName, ', ', prv.ProviderFirstName) END as BudgetProviderName
      ,[BudgetPayerGroupID]
	  ,pg.PayerGroupName as BudgetPayerGroupName
      ,[BudgetPayerCategoryID]
      ,[BudgetPayerID]
      ,[BudgetPayerPlanID]
      ,[BudgetValue]
      ,[BudgetIsActive]
      ,[BudgetUpdatedDatetime]
--select *
from fact.Budgets b
	left join dim.BudgetTypes bt ON bt.BudgetTypeID = b.BudgetTypeID
	left join dim.ServiceLines sl ON sl.ServiceLineID = b.BudgetServiceLineID
	left join dim.Providers prv ON prv.ProviderID = b.BudgetProviderID
	left join dim.Specialties s ON s.SpecialtyID = b.BudgetSpecialtyID
	left join dim.PayerGroups pg ON pg.PayerGroupID = b.BudgetPayerGroupID
	left join dim.Locations l ON l.LocationID = b.BudgetLocationID
	left join dim.Departments d ON d.DepartmentID = b.BudgetDepartmentID
GO
