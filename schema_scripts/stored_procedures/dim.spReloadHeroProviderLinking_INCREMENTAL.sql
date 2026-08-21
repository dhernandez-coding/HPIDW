CREATE PROCEDURE dim.spReloadHeroProviderLinking_INCREMENTAL as
truncate table map.ProviderLinking_hero
insert into map.ProviderLinking_hero select * from hero.vProviderLinking
GO
