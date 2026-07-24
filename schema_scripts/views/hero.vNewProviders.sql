CREATE view [hero].[vNewProviders] as 

/*this is used for gettig new providers into the app*/
Select [ProviderID] as ProviderProviderID
      ,[ProviderDataSourceID]
      ,[ProviderSourceID]
      ,[ProviderAbbreviation]
      ,[ProviderFirstName]
      ,[ProviderMiddleInitial]
      ,[ProviderLastName]
      ,[ProviderGender]
      ,[ProviderSuffix]
	  ,ProviderNPI
      ,[ProviderStreetAddress1]
      ,[ProviderStreetAddress2]
      ,[ProviderCity]
      ,[ProviderState]
      ,[ProviderZipCode]
      ,[ProviderPhone]
      ,[ProviderFax]
	  ,ProviderUPIN
	  ,ProviderIsActive
	  ,ProviderUpdatedDateTime
	  ,cast(ISNULL(
   TRY_CONVERT(int,
        CASE 
            WHEN CHARINDEX('~', p.ProviderSpecialtyID) > 0 
                THEN SUBSTRING(p.ProviderSpecialtyID, CHARINDEX('~', p.ProviderSpecialtyID) + 1, LEN(p.ProviderSpecialtyID))
            ELSE p.ProviderSpecialtyID
        END
    ),
    4
) as int) as [ProviderSpecialtyID],

	ProviderSpecialtyID as pid
      --,Coalesce([ProviderSpecialtyID], 4) as [ProviderSpecialtyID]--4 is general i nthe HPI app
	  from dim.Providers p
where ProviderNPi is not null and Trim(ProviderNPI) <> ''
 AND  ProviderId not in (select ChildProviderId from map.vProviderLinking) and ProviderId not in (select ProviderProviderId from [hero].Providerss)
GO
