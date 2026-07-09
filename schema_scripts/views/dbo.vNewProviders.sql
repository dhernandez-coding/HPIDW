CREATE view vNewProviders as 
Select [ProviderID] as ProviderProviderID
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
	  ,
	  ISNULL(
    TRY_CONVERT(int,
        CASE 
            WHEN CHARINDEX('~', p.ProviderSpecialtyID) > 0 
                THEN SUBSTRING(p.ProviderSpecialtyID, CHARINDEX('~', p.ProviderSpecialtyID) + 1, LEN(p.ProviderSpecialtyID))
            ELSE p.ProviderSpecialtyID
        END
    ),
    4
) as [ProviderSpecialtyID],

	ProviderSpecialtyID as pid
      --,Coalesce([ProviderSpecialtyID], 4) as [ProviderSpecialtyID]--4 is general i nthe HPI app
	  from dim.Providers p
where ProviderNPi is not null and Trim(ProviderNPI) <> ''
 AND  ProviderId not in (select ChildProviderId from map.ProviderLinking) and ProviderId not in (select ProviderProviderId from [hero-db].hpi.dbo.Providerss)
GO
