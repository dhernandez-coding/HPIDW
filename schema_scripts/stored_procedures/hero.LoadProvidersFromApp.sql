CREATE PROCEDURE [hero].[LoadProvidersFromApp] as 
truncate table hero.Providerss

--SET IDENTITY_INSERT hero.Providerss ON;

--PULL HERO DATA DOWN LOCALLY
insert into hero.Providerss
([ProviderID]
      ,[ProviderProviderID]
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
      ,[IsDeleted]
      ,[CreatedDate]
      ,[ModifiedDate]
      ,[ModifiedBy]
      ,[DeletedDate]
      ,[DeletedBy]
      ,[IsActive])
	  
select 
[ProviderID]
      ,[ProviderProviderID]
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


      , NULLIF(NULLIF(ProviderSpecialtyID, 0), -1) AS [ProviderSpecialtyID]



      ,[ProviderUPIN]
      ,[ProviderNPI]
      ,[ProviderIsActive]
      ,[ProviderUpdatedDateTime]
      ,[IsDeleted]
      ,[CreatedDate]
      ,[ModifiedDate]
      ,[ModifiedBy]
      ,[DeletedDate]
      ,[DeletedBy]
      ,[IsActive]
from [hero-db].hpi.dbo.providerss

--UPSERT 0~ records to dim.Providers
MERGE dim.Providers--_Hero 
AS target
USING (
    SELECT
        [ProviderProviderID] as ProviderID
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
            ,CASE 
    WHEN ProviderSpecialtyID BETWEEN 1 AND 13 
        THEN '0~' + CAST(ProviderSpecialtyID AS VARCHAR(10))
    ELSE CAST(NULLIF(NULLIF(ProviderSpecialtyID, 0), -1) AS VARCHAR(10))
 END AS ProviderSpecialtyID
        ,[ProviderUPIN]
        ,[ProviderNPI]
        ,[ProviderIsActive]
        ,[ProviderUpdatedDateTime]

		--select *
    FROM [hero-db].hpi.dbo.providerss 
    WHERE [ProviderProviderID] LIKE '0~%' and ProviderNPI is not null and Trim(ProviderNPI) != ''
) AS source
ON target.ProviderID = source.ProviderID

WHEN MATCHED THEN
    UPDATE SET
        target.ProviderDataSourceID   = source.ProviderDataSourceID
        ,target.ProviderSourceID       = source.ProviderSourceID
        ,target.ProviderAbbreviation   = source.ProviderAbbreviation
        ,target.ProviderFirstName      = source.ProviderFirstName
        ,target.ProviderMiddleInitial  = source.ProviderMiddleInitial
        ,target.ProviderLastName       = source.ProviderLastName
        ,target.ProviderGender         = source.ProviderGender
        ,target.ProviderSuffix         = source.ProviderSuffix
        ,target.ProviderStreetAddress1 = source.ProviderStreetAddress1
        ,target.ProviderStreetAddress2 = source.ProviderStreetAddress2
        ,target.ProviderCity           = source.ProviderCity
        ,target.ProviderState          = source.ProviderState
        ,target.ProviderZipCode        = source.ProviderZipCode
        ,target.ProviderPhone          = source.ProviderPhone
        ,target.ProviderFax            = source.ProviderFax
        ,target.ProviderSpecialtyID = CASE 
    WHEN CHARINDEX('~', source.ProviderSpecialtyID) > 0 
        THEN source.ProviderSpecialtyID
    WHEN source.ProviderSpecialtyID IS NULL 
        THEN NULL
    ELSE target.ProviderSpecialtyID
 END
  

        ,target.ProviderUPIN           = source.ProviderUPIN
        ,target.ProviderNPI            = source.ProviderNPI
        ,target.ProviderIsActive       = source.ProviderIsActive
        ,target.ProviderUpdatedDateTime = ISNULL(TRY_CONVERT(datetime, source.ProviderUpdatedDateTime), '1900-01-01')

WHEN NOT MATCHED BY TARGET THEN
    INSERT (
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
    )
    VALUES (
        Concat('0~', source.ProviderNPI)
        ,0 -- For HERO
		,source.ProviderID
        ,source.ProviderAbbreviation
        ,source.ProviderFirstName
        ,source.ProviderMiddleInitial
        ,source.ProviderLastName
        ,source.ProviderGender
        ,source.ProviderSuffix
        ,source.ProviderStreetAddress1
        ,source.ProviderStreetAddress2
        ,source.ProviderCity
        ,source.ProviderState
        ,source.ProviderZipCode
        ,source.ProviderPhone
        ,source.ProviderFax
        ,source.ProviderSpecialtyID
        ,source.ProviderUPIN
        ,source.ProviderNPI
        ,source.ProviderIsActive
		,ISNULL(TRY_CONVERT(datetime, source.ProviderUpdatedDateTime), '1900-01-01')
        
    );




	--select * From [hero-db].hpi.dbo.specialtiess
--	MERGE dim.Providers--_Hero AS target

--USING (

--    SELECT
--        concat(concat(pa.SourceSystemId,'~'), pa.value)  as ProviderID
--        ,pa.SourceSystemId as [ProviderDataSourceID]
--        ,pa.Value as [ProviderSourceID]
--        ,p.[ProviderAbbreviation]
--        ,p.[ProviderFirstName]
--        ,p.[ProviderMiddleInitial]
--        ,p.[ProviderLastName]
--        ,p.[ProviderGender]
--        ,p.[ProviderSuffix]
--        ,p.[ProviderStreetAddress1]
--        ,p.[ProviderStreetAddress2]
--        ,p.[ProviderCity]
--        ,p.[ProviderState]
--        ,p.[ProviderZipCode]
--        ,p.[ProviderPhone]
--        ,p.[ProviderFax]
--        ,p.[ProviderSpecialtyID]
--        ,p.[ProviderUPIN]
--        ,p.[ProviderNPI]
--        ,p.[ProviderIsActive]
--        ,p.[ProviderUpdatedDateTime]
--    FROM [hero-db].hpi.dbo.ProviderAliases pa
--	left join [hero-db].hpi.dbo.Providerss p on pa.ProviderID = p.ProviderID
    

--) AS source

--ON target.ProviderID = source.ProviderID

--WHEN NOT MATCHED BY TARGET THEN

--    INSERT (
--	        [ProviderID]
--        ,[ProviderDataSourceID]
--        ,[ProviderSourceID]
--		 ,[ProviderAbbreviation]
--        ,[ProviderFirstName]
--        ,[ProviderMiddleInitial]
--        ,[ProviderLastName]
--        ,[ProviderGender]
--        ,[ProviderSuffix]
--        ,[ProviderStreetAddress1]
--        ,[ProviderStreetAddress2]
--        ,[ProviderCity]
--        ,[ProviderState]
--        ,[ProviderZipCode]
--        ,[ProviderPhone]
--		,[ProviderFax]
--        ,[ProviderSpecialtyID]
--        ,[ProviderUPIN]
--		,[ProviderNPI]
--        ,[ProviderIsActive]
--        ,[ProviderUpdatedDateTime]
--    )

--    VALUES (
--        source.ProviderID
--        ,source.ProviderDataSourceID
--        ,source.ProviderSourceID
--        ,source.ProviderAbbreviation
--        ,source.ProviderFirstName
--        ,source.ProviderMiddleInitial
--        ,source.ProviderLastName
--        ,source.ProviderGender
--        ,source.ProviderSuffix
--        ,source.ProviderStreetAddress1
--        ,source.ProviderStreetAddress2
--        ,source.ProviderCity
--        ,source.ProviderState
--		,source.ProviderZipCode
--        ,source.ProviderPhone
--        ,source.ProviderFax
--        ,source.ProviderSpecialtyID
--        ,source.ProviderUPIN
--        ,source.ProviderNPI
--        ,source.ProviderIsActive
--        ,ISNULL(TRY_CONVERT(datetime, source.ProviderUpdatedDateTime), '1900-01-01')

--    );

	--CREATE UPDATE PRoviders from other systems added via the app(shouldnt ever update, just insert providers that were added to the app as aliases
GO
