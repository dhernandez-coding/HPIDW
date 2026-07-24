CREATE View [map].[vPracticeProviders] 
WITH SCHEMABINDING
as

select pp.Id as PracticeProviderID
      ,p.[PracticePracticeID] as PracticeID
      ,p.[PracticeName]
      ,pr.[ProviderProviderID] as ProviderID
      ,[ProviderDataSourceID]
      ,null as [ParentProviderID]
      ,Concat(pr.ProviderFirstName, ' ',pr.ProviderMiddleInitial, ' ',pr.ProviderLastName) [ProviderFullName]
      ,[ProviderFirstName]
      ,[ProviderMiddleInitial]
      ,[ProviderLastName]
      ,[ProviderAbbreviation]
      ,[PracticeProviderIsPrimary]
      ,[PracticeProviderEffectiveDate]
      ,[PracticeProviderEndDate]
      ,[PracticeProviderIsActive]
      ,[PracticeProviderUpdatedDatetime]
      ,[PracticeProviderFTE]
      ,[PracticeProviderAllocationPercent]
      ,l.LocationName as [PracticeProviderLocation]
      ,[PracticeProviderIsSpecialist]
      ,[PracticeProviderIsMidLevel]
      ,[PracticeProviderGLType]
      ,[PracticeProviderGLTypeID]
      ,[PracticeProviderGLProviderID]
      ,[PracticeProviderDHSType] from hero.PracticeProviderss pp
	  left join hero.PRacticess p on pp.PracticeID = p.PracticeID 
	  left join hero.Providerss pr on pp.ProviderID = pr.ProviderID
	  left join hero.ProviderAliases pa on pr.PRoviderID = pa.Id
	  left join hero.Locationss l on pp.PracticeProviderLocation = l.LocationID
WHERE EXISTS (
    SELECT 1 FROM dbo.DWConfig WHERE Name = 'UseAppTables' AND [Value] = 1
)

UNION ALL





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
  left join dim.vProviders p  ON p.ProviderID = pp.ProviderID
  left join  dim.vPractices pr ON pr.PracticeID = pp.PracticeID
  left join  map.vProviderLinking pl ON pl.ChildProviderID = pp.ProviderID
  where 1=1  and
EXISTS (
    SELECT 1 FROM dbo.DWConfig WHERE Name = 'UseAppTables' AND [Value] = 0
)
GO
