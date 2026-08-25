CREATE view [hero].[vNewProviders] as 


SELECT
    ProviderProviderID
    ,ProviderDataSourceID
    ,ProviderSourceID
    ,ProviderAbbreviation
    ,ProviderFirstName
    ,ProviderMiddleInitial
    ,ProviderLastName
    ,ProviderGender
    ,ProviderSuffix
    ,ProviderNPI
    ,ProviderStreetAddress1
    ,ProviderStreetAddress2
    ,ProviderCity
    ,ProviderState
    ,ProviderZipCode
    ,ProviderPhone
    ,ProviderFax
    ,ProviderUPIN
    ,ProviderIsActive
    ,ProviderUpdatedDateTime
    ,cast(ISNULL(
        TRY_CONVERT(int,
            CASE
                WHEN CHARINDEX('~', ProviderSpecialtyID) > 0
                THEN SUBSTRING(ProviderSpecialtyID, CHARINDEX('~', ProviderSpecialtyID) + 1, LEN(ProviderSpecialtyID))
                ELSE ProviderSpecialtyID
            END
        ),
        4
    ) as int) as [ProviderSpecialtyID]
    ,ProviderSpecialtyID as pid
FROM (
    SELECT *
    FROM (
        SELECT *,
            ROW_NUMBER() OVER (
                PARTITION BY ProviderNPI
                ORDER BY ProviderUpdatedDateTime DESC, ProviderID DESC
            ) AS rn
        FROM (
            SELECT s.*
            FROM (
                SELECT s.*
                FROM (
                    SELECT
                        [ProviderID] as ProviderProviderID
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
                        ,ProviderSpecialtyID
                        ,ProviderId
                    FROM dim.Providers p
                    --WHERE p.ProviderId not like '0~%'
                    --  AND p.ProviderNPI is not null
                    --  AND p.ProviderNPI <> ''
					where ProviderId not in 
						(select ProviderId from dim.Providers_HEro)  --biggest group, most dont have npi's
						and ProviderNPI is not null and Trim(ProviderNPI) != '' -- most of this group doesnt come over because it is a 0 record
						and ProviderID not like '0~%'
                ) s
                --WHERE NOT EXISTS (
                --    SELECT 1 FROM map.vProviderLinking l WHERE l.ChildProviderId = s.ProviderId
                --)
            ) s
            WHERE NOT EXISTS (
                SELECT 1 FROM [hero].Providerss h WHERE h.ProviderNPI = s.ProviderNPI
            )
        ) s
    ) x
) final
WHERE final.rn = 1;
/*this is used for gettig new providers into the app*/
--WITH RankedProviders AS (
--    SELECT
--        [ProviderID] as ProviderProviderID
--        ,[ProviderDataSourceID]
--        ,[ProviderSourceID]
--        ,[ProviderAbbreviation]
--        ,[ProviderFirstName]
--        ,[ProviderMiddleInitial]
--        ,[ProviderLastName]
--        ,[ProviderGender]
--        ,[ProviderSuffix]
--        ,ProviderNPI
--        ,[ProviderStreetAddress1]
--        ,[ProviderStreetAddress2]
--        ,[ProviderCity]
--        ,[ProviderState]
--        ,[ProviderZipCode]
--        ,[ProviderPhone]
--        ,[ProviderFax]
--        ,ProviderUPIN
--        ,ProviderIsActive
--        ,ProviderUpdatedDateTime
--        ,cast(ISNULL(
--            TRY_CONVERT(int,
--                CASE
--                    WHEN CHARINDEX('~', p.ProviderSpecialtyID) > 0
--                    THEN SUBSTRING(p.ProviderSpecialtyID, CHARINDEX('~', p.ProviderSpecialtyID) + 1, LEN(p.ProviderSpecialtyID))
--                    ELSE p.ProviderSpecialtyID
--                END
--            ),
--            4
--        ) as int) as [ProviderSpecialtyID]

--        ,ProviderSpecialtyID as pid
--        --,Coalesce([ProviderSpecialtyID], 4) as [ProviderSpecialtyID]--4 is general i nthe HPI app

--        ,ROW_NUMBER() OVER (
--            PARTITION BY p.ProviderNPI
--            ORDER BY p.ProviderUpdatedDateTime DESC, p.ProviderID DESC
--        ) AS rn

--    FROM dim.Providers p
--    WHERE p.ProviderNPI is not null and p.ProviderNPI <> ''
--    AND NOT EXISTS (
--        SELECT 1 FROM map.vProviderLinking l WHERE l.ChildProviderId = p.ProviderId
--    )
--    AND NOT EXISTS (
--        SELECT 1 FROM [hero].Providerss h WHERE h.ProviderNPI = p.ProviderNPI
--    )
--    AND p.ProviderId not like '0~%'
--)
--SELECT *
--FROM RankedProviders
--WHERE rn = 1
GO
