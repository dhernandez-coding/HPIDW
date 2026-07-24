CREATE procedure [hero].[etl_providers_to_hero] as
-- Using OPENQUERY to force a fresh metadata check against the remote server
--insert into OPENQUERY([hero-db], 
--    'SELECT 
--       [ProviderProviderID]
--    ,[ProviderDataSourceID]
--    ,[ProviderSourceID]
--    ,[ProviderAbbreviation]
--    ,[ProviderFirstName]
--    ,[ProviderMiddleInitial]
--    ,[ProviderLastName]
--    ,[ProviderGender]
--    ,[ProviderSuffix]
--    ,[ProviderStreetAddress1]
--    ,[ProviderStreetAddress2]
--    ,[ProviderCity]
--    ,[ProviderState]
--    ,[ProviderZipCode]
--    ,[ProviderPhone]
--    ,[ProviderFax]
--    ,[ProviderSpecialtyID]
--    ,[ProviderUPIN]
--    ,[ProviderNPI]
--    ,[ProviderIsActive]
--    ,[ProviderUpdatedDateTime]
--    ,[IsDeleted]
--    ,[CreatedDate]
--    ,[ModifiedDate]
--    ,[ModifiedBy]
--    ,[DeletedDate]
--    ,[DeletedBy]
--    ,[IsActive]
 
--    FROM hpi.dbo.Providerss
--    WHERE 1=0'
--)

DROP TABLE IF EXISTS #tempProviders;
select
     [ProviderProviderID]
    ,[ProviderDataSourceID]
    ,[ProviderSourceID]
    ,Coalesce([ProviderAbbreviation], '') as [ProviderAbbreviation]
    ,Coalesce([ProviderFirstName], '') as [ProviderFirstName]
    ,Coalesce([ProviderMiddleInitial], '') as [ProviderMiddleInitial]
    ,Coalesce([ProviderLastName], '') as [ProviderLastName]
    ,Coalesce([ProviderGender], '') as [ProviderGender]
    ,Coalesce([ProviderSuffix], '') as [ProviderSuffix]
    ,Coalesce([ProviderStreetAddress1], '') as [ProviderStreetAddress1]
    ,Coalesce([ProviderStreetAddress2], '') as [ProviderStreetAddress2]
    ,Coalesce([ProviderCity], '') as [ProviderCity]
    ,Coalesce([ProviderState], '') as [ProviderState]
    ,Coalesce([ProviderZipCode], '') as [ProviderZipCode]
    ,Coalesce([ProviderPhone], '') as [ProviderPhone]
    ,Coalesce([ProviderFax], '') as [ProviderFax]
    ,Coalesce([ProviderSpecialtyID], -1) as [ProviderSpecialtyID] -- map to specialties table
    ,Coalesce([ProviderUPIN], '') as [ProviderUPIN]
    ,Coalesce([ProviderNPI], '') as [ProviderNPI]
    ,ProviderIsActive
    ,GetDate() as [ProviderUpdatedDateTime]
    ,0 as IsDeleted -- IsDeleted
    ,GetDate() as CreatedDate -- CreatedDate
    ,GetDate() as ModifiedDate -- ModifiedDate
    ,'ETL' as ModifiedBy -- ModifiedBy
    ,CAST(NULL AS datetime2(7)) as DeletedDate -- DeletedDate
    ,null as DeletedBy -- DeletedBy
    ,Coalesce(ProviderIsActive, 1) as IsActive -- IsActive
	into #tempProviders
from hero.vNewProviders
INSERT INTO [Hero-DB].hpi.stg.Providerss
(ProviderProviderID, ProviderDataSourceID, ProviderSourceID, ProviderAbbreviation,
 ProviderFirstName, ProviderMiddleInitial, ProviderLastName, ProviderGender, ProviderSuffix,
 ProviderStreetAddress1, ProviderStreetAddress2, ProviderCity, ProviderState, ProviderZipCode,
 ProviderPhone, ProviderFax, ProviderSpecialtyID, ProviderUPIN, ProviderNPI,
 ProviderIsActive, ProviderUpdatedDateTime, IsDeleted, CreatedDate, ModifiedDate,
 ModifiedBy, DeletedDate, DeletedBy, IsActive)
SELECT
 t.ProviderProviderID, t.ProviderDataSourceID, t.ProviderSourceID, t.ProviderAbbreviation,
 t.ProviderFirstName, t.ProviderMiddleInitial, t.ProviderLastName, t.ProviderGender, t.ProviderSuffix,
 t.ProviderStreetAddress1, t.ProviderStreetAddress2, t.ProviderCity, t.ProviderState, t.ProviderZipCode,
 t.ProviderPhone, t.ProviderFax, t.ProviderSpecialtyID, t.ProviderUPIN, t.ProviderNPI,
 t.ProviderIsActive, t.ProviderUpdatedDateTime, t.IsDeleted, t.CreatedDate, t.ModifiedDate,
 t.ModifiedBy, t.DeletedDate, t.DeletedBy, t.IsActive
FROM #tempProviders t
exec [HERO-DB].[hpi].[stg].[usp_UpsertProvidersFromStaging]
GO
