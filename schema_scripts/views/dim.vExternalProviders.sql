Create View dim.ExternalProviders
as
Select
[ProviderID]
      ,[ProviderDataSourceID]
      ,[ProviderSourceID]
      ,[ProviderAbbreviation]
      ,[ProviderFirstName]
      ,[ProviderMiddleInitial]
      ,[ProviderLastName]
      ,[ProviderGender]
      ,[ProviderSuffix]
      ,[ProviderStreetAddress1]
      ,[ProviderStreetAddress2]
      ,[ProviderCity]
      ,[ProviderState]
      ,[ProviderZipCode]
      ,[ProviderPhone]
      ,[ProviderFax]
      ,[ProviderSpecialtyID]
      ,[ProviderUPIN]
      ,[ProviderNPI]
      ,[ProviderIsActive]
      ,[ProviderUpdatedDateTime]
From dim.Providers Where ProviderDataSourceID <> 0
GO
