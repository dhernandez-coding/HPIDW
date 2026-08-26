create Procedure hero.HERO_FRESH_RELOAD as
-- the purpose of this sproc is to recreate all of the hero tables on prem with the local data as the initial spawn data and clean reload over the top of it with updates from the Hero application



delete from dim.Providers_Hero
delete from dim.Practices_HERO
delete from map.PracticeProviders_HERO
delete from dim.Specialties_hero 
delete from map.ProviderLinking_Hero




insert into dim.Providers_hero select * from dim.Providers
insert into dim.Practices_HERO select * from dim.Practices
insert into map.PracticeProviders_HERO select * from map.PracticeProviders_HERO
insert into dim.Specialties_hero select * from dim.Specialties_hero
insert into map.ProviderLinking_Hero select * from map.ProviderLinking




exec dim.spReloadHeroProviders_INCREMENTAL
exec dim.spReloadHeroPractices_INCREMENTAL
exec map.spReloadHeroPracticeProviders_INCREMENTAL
exec dim.spReloadHeroSpecialties_INCREMENTAL
exec dim.spReloadHeroProviderLinking_INCREMENTAL



--to prove its not reinserting records
--select count(*) as 'providercount' from dim.Providers_Hero
--select count(*) as 'practicecount' from dim.Practices_HERO
--select count(*) as 'practiceprovidercount' from map.PracticeProviders_HERO
--select count(*) as 'specialtycount' from dim.Specialties_hero
--select count(*) as 'providerlinkingcount' from map.ProviderLinking_Hero
GO
