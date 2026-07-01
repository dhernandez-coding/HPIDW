CREATE View [map].[vPracticeProviders] 
WITH SCHEMABINDING
as
SELECT [PracticeProviderID]
      ,pp.[PracticeID]
	  ,pr.PracticeName
      ,pp.[ProviderID]
	  ,p.ProviderDataSourceID
	  ,pl.ParentProviderID as ParentProviderID
	  ,CONCAT(p.ProviderLastName,', ',p.ProviderFirstName,' ',p.ProviderMiddleInitial) AS ProviderFullName
	  ,p.ProviderFirstName
	  ,p.ProviderMiddleInitial
	  ,p.ProviderLastName
      ,pp.[ProviderAbbreviation]
      ,[PracticeProviderIsPrimary]
      ,[PracticeProviderEffectiveDate]
      ,[PracticeProviderEndDate]
      ,[PracticeProviderIsActive]
      ,[PracticeProviderUpdatedDatetime]
      ,[PracticeProviderFTE]
      ,[PracticeProviderAllocationPercent]
      ,[PracticeProviderLocation]
      ,[PracticeProviderIsSpecialist]
      ,[PracticeProviderIsMidLevel]
	  ,[PracticeProviderGLType]
      ,[PracticeProviderGLTypeID]
      ,[PracticeProviderGLProviderID]
	  ,[PracticeProviderDHSType]
FROM [map].[PracticeProviders] pp 
  left join dim.Providers p  ON p.ProviderID = pp.ProviderID
  left join  dim.Practices pr ON pr.PracticeID = pp.PracticeID
  left join  map.ProviderLinking pl ON pl.ChildProviderID = pp.ProviderID
GO
