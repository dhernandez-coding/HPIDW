CREATE PROCEDURE [dim].[spReloadHeroProviderLinking_INCREMENTAL] as
truncate table map.ProviderLinking
insert into map.ProviderLinking select * from hero.vProviderLinking
GO
