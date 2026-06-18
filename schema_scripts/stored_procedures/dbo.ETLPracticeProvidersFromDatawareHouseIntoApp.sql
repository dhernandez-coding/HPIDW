Create Procedure ETLPracticeProvidersFromDatawareHouseIntoApp
As

Insert into HPIApp.dbo.PracticeProviders
Select 

mappedResults.[PracticeProviderID]
     , pc.[PracticeID]
	 
	  ,mappedResults.EpicPracticeProviderID
	,p.ProviderID as 'ProviderID'
      ,0 as [IsReferralTarget]
      ,0 as [IsHPIPrimaryCare]
      ,0 as [IsHPISpecialist]
      ,0 as [IsAffiliate]
	  
      ,mappedResults.[EpicPracticeProviderUpdatedDatetime]
      ,mappedResults.[ProviderAbbreviation]
      ,mappedResults.[PracticeProviderIsPrimary]
      ,mappedResults.[PracticeProviderEffectiveDate]
      ,mappedResults.[PracticeProviderEndDate]
      ,mappedResults.[PracticeProviderIsActive]
      ,mappedResults.[PracticeProviderUpdatedDatetime]
      ,mappedResults.[PracticeProviderFTE]
      ,mappedResults.[PracticeProviderAllocationPercent]
      ,mappedResults.[PracticeProviderLocation]
      ,mappedResults.[PracticeProviderIsSpecialist]
      ,mappedResults.[PracticeProviderIsMidLevel]
      ,mappedResults.[PracticeProviderGLType]
      ,mappedResults.[PracticeProviderGLTypeID]
      ,mappedResults.[PracticeProviderGLProviderID]
      ,mappedResults.[PracticeProviderDHSType]
	  ,0 as TableSource
From (
Select 
	results.PracticeProviderID as PracticeProviderID
	,results.EpicPracticeProviderID
	,COALESCE(pl.[ParentProviderID],COALESCE(pl2.ParentProviderID, '9') ) as 'ProviderID'
      ,results.[PracticeID]
      ,0 as [IsReferralTarget]
      ,0 as [IsHPIPrimaryCare]
      ,0 as [IsHPISpecialist]
      ,0 as [IsAffiliate]
      ,results.[ProviderAbbreviation]
      ,results.[PracticeProviderIsPrimary]
      ,results.[PracticeProviderEffectiveDate]
      ,results.[PracticeProviderEndDate]
      ,results.[PracticeProviderIsActive]
      ,results.[PracticeProviderUpdatedDatetime]
	  
      ,null as [EpicPracticeProviderUpdatedDatetime]
      ,results.[PracticeProviderFTE]
      ,results.[PracticeProviderAllocationPercent]
      ,results.[PracticeProviderLocation]
      ,results.[PracticeProviderIsSpecialist]
      ,results.[PracticeProviderIsMidLevel]
      ,results.[PracticeProviderGLType]
      ,results.[PracticeProviderGLTypeID]
      ,results.[PracticeProviderGLProviderID]
      ,results.[PracticeProviderDHSType]
From (
  SELECT 
  0 as 'PracticeProviderID'
  ,epp.EpicPracticeProviderID
	,
      epp.[ProviderID]
      ,epp.[PracticeID]
      ,epp.[IsReferralTarget]
      ,epp.[IsHPIPrimaryCare]
      ,epp.[IsHPISpecialist]
      ,epp.[IsAffiliate]	  
      ,'' as [ProviderAbbreviation]
      ,0 as [PracticeProviderIsPrimary]
      ,null as [PracticeProviderEffectiveDate]
      ,null as [PracticeProviderEndDate]
      ,0 as [PracticeProviderIsActive]
      ,'' as [PracticeProviderUpdatedDatetime]
	  ,epp.[EpicPracticeProviderUpdatedDatetime]
      ,0 as [PracticeProviderFTE]
      ,0 as [PracticeProviderAllocationPercent]
      ,'' as [PracticeProviderLocation]
      ,0 as [PracticeProviderIsSpecialist]
      ,0 as [PracticeProviderIsMidLevel]
      ,'' as [PracticeProviderGLType]
      ,0 as [PracticeProviderGLTypeID]
      ,0 as [PracticeProviderGLProviderID]
      ,'' as [PracticeProviderDHSType]
  FROM [HPIDW].[map].[EpicPracticeProviders] epp
Union ALL
    SELECT 
	pp.PracticeProviderID
	,0 as 'EpicPracticeProviderID'
     , pp.[ProviderID]
      ,pp.[PracticeID]
      ,0 as [IsReferralTarget]
      ,0 as [IsHPIPrimaryCare]
      ,0 as [IsHPISpecialist]
      ,0 as [IsAffiliate]
      ,pp.[ProviderAbbreviation]
      ,pp.[PracticeProviderIsPrimary]
      ,pp.[PracticeProviderEffectiveDate]
      ,pp.[PracticeProviderEndDate]
      ,pp.[PracticeProviderIsActive]
      ,pp.[PracticeProviderUpdatedDatetime]
	  ,null as [EpicPracticeProviderUpdatedDatetime]
      ,pp.[PracticeProviderFTE]
      ,pp.[PracticeProviderAllocationPercent]
      ,pp.[PracticeProviderLocation]
      ,pp.[PracticeProviderIsSpecialist]
      ,pp.[PracticeProviderIsMidLevel]
      ,pp.[PracticeProviderGLType]
      ,pp.[PracticeProviderGLTypeID]
      ,pp.[PracticeProviderGLProviderID]
      ,pp.[PracticeProviderDHSType]
  FROM [HPIDW].[map].[PracticeProviders] pp
  ) as results
  left join map.ProviderLinking pl on results.ProviderID = pl.ChildProviderID
  left join map.ProviderLinking pl2 on results.ProviderID = pl.ParentProviderID
   ) as mappedResults
   left join HPIApp.dbo.Providers p on mappedResults.ProviderID = p.ProviderProviderID
  
   left join HPIApp.dbo.Practices pc on mappedResults.PracticeID = pc.PracticePracticeID
GO
