CREATE view [hero].[vPracticeProviders] as
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
	  
	,coalesce(try_cast([PracticeProviderUpdatedDatetime] as Datetime), GetDate())  as [PracticeProviderUpdatedDatetime]	
      
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
GO
