CREATE view [map].[vProviderLinking]
as
--with schemabinding as
--select [ID]
--      ,[ParentProviderID]
--      ,[ChildProviderID]
--      ,[ProviderLinkingMgmtUserID]
--      ,[ProviderLinkingCreatedDatetime]
--      ,[ProviderLinkingUpdatedDatetime]
--      ,[ProviderLinkingIsActive] 
--from hero._vProviderLinking 
--WHERE EXISTS (
--    SELECT 1 FROM dbo.DWConfig WHERE Name = 'UseAppTables' AND [Value] = 1
--)


--UNION ALL 
  select [ID]
      ,[ParentProviderID]
      ,[ChildProviderID]
      ,[ProviderLinkingMgmtUserID]
      ,[ProviderLinkingCreatedDatetime]
      ,[ProviderLinkingUpdatedDatetime]
      ,[ProviderLinkingIsActive] 
  from map.ProviderLinking_PREHERO 
  where 1=1 
  
--AND EXISTS (
--    SELECT 1 FROM dbo.DWConfig WHERE Name = 'UseAppTables' AND [Value] = 0
--)
GO
