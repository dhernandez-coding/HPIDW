create view map.zzvProviderLinking
with schemabinding as
select [ID]
      ,[ParentProviderID]
      ,[ChildProviderID]
      ,[ProviderLinkingMgmtUserID]
      ,[ProviderLinkingCreatedDatetime]
      ,[ProviderLinkingUpdatedDatetime]
      ,[ProviderLinkingIsActive] 
from dbo._vProviderLinking 
WHERE EXISTS (
    SELECT 1 FROM dbo.DWConfig WHERE Name = 'UseAppTables' AND [Value] = 1
)


UNION ALL 
  select [ID]
      ,[ParentProviderID]
      ,[ChildProviderID]
      ,[ProviderLinkingMgmtUserID]
      ,[ProviderLinkingCreatedDatetime]
      ,[ProviderLinkingUpdatedDatetime]
      ,[ProviderLinkingIsActive] 
  from map.ProviderLinking where 1=1 and
EXISTS (
    SELECT 1 FROM dbo.DWConfig WHERE Name = 'UseAppTables' AND [Value] = 0
)
GO
