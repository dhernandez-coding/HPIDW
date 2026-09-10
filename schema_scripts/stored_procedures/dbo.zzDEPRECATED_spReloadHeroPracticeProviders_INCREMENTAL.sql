create procedure spReloadHeroPracticeProviders_INCREMENTAL as
	  truncate table map.PracticeProviders_Hero

	  insert into map.PracticeProviders_Hero (
	  [PracticeProviderID]
      ,[PracticeID]
      ,[ProviderID]
      ,[ProviderAbbreviation]
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
	  )
	    select 
		
		[PracticeProviderID]
      ,[PracticeID]
      ,[ProviderID]
      ,[ProviderAbbreviation]
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
	  
	  From 	  hero.vPracticeProviders
GO
