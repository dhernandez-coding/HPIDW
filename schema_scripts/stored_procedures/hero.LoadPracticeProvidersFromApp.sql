create PROCEDURE hero.LoadPracticeProvidersFromApp as 

truncate table hero.PRacticeProviderss

--SET IDENTITY_INSERT hero.SourceSystems ON;


insert into hero.PracticeProviderss
(
 [Id]
      ,[PracticeID]
      ,[ProviderID]
      ,[PracticeProviderIsDefaultPractice]
      ,[PracticeProviderIsDefaultReferralPractice]
      ,[PracticeProviderIsPrimary]
      ,[PracticeProviderIsSpecialist]
      ,[PracticeProviderIsMidLevel]
      ,[PracticeProviderIsReferralTarget]
      ,[PracticeProviderIsAffiliate]
      ,[PracticeProviderEffectiveDate]
      ,[PracticeProviderEndDate]
      ,[PracticeProviderFTE]
      ,[PracticeProviderAllocationPercent]
      ,[PracticeProviderLocation]
      ,[PracticeProviderGLType]
      ,[PracticeProviderGLTypeID]
      ,[PracticeProviderGLProviderID]
      ,[PracticeProviderDHSType]
      ,[PracticeProviderID]
      ,[EpicPracticeProviderID]
      ,[PracticeProviderIsActive]
      ,[PracticeProviderUpdatedDatetime]
      ,[CreatedDate]
      ,[ModifiedDate]
      ,[ModifiedBy]
      ,[DeletedDate]
      ,[DeletedBy]
      ,[IsDeleted]
      ,[IsActive])
	  
select 
 [Id]
      ,[PracticeID]
      ,[ProviderID]
      ,[PracticeProviderIsDefaultPractice]
      ,[PracticeProviderIsDefaultReferralPractice]
      ,[PracticeProviderIsPrimary]
      ,[PracticeProviderIsSpecialist]
      ,[PracticeProviderIsMidLevel]
      ,[PracticeProviderIsReferralTarget]
      ,[PracticeProviderIsAffiliate]
      ,[PracticeProviderEffectiveDate]
      ,[PracticeProviderEndDate]
      ,[PracticeProviderFTE]
      ,[PracticeProviderAllocationPercent]
      ,[PracticeProviderLocation]
      ,[PracticeProviderGLType]
      ,[PracticeProviderGLTypeID]
      ,[PracticeProviderGLProviderID]
      ,[PracticeProviderDHSType]
      ,[PracticeProviderID]
      ,[EpicPracticeProviderID]
      ,[PracticeProviderIsActive]
      ,[PracticeProviderUpdatedDatetime]
      ,[CreatedDate]
      ,[ModifiedDate]
      ,[ModifiedBy]
      ,[DeletedDate]
      ,[DeletedBy]
      ,[IsDeleted]
      ,[IsActive]
from [hero-db].hpi.dbo.PracticeProviderss
GO
