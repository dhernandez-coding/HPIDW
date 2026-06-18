CREATE procedure [stg].[spHPIReloadMapProviderLinkingIncremental] as

	  Delete From HPIDW.map.ProviderLinking

	  insert into HPIDW.map.ProviderLinking
	  Select 
		  ParentProviderId
		  ,ChildProviderID
		  ,ProviderLinkingMgmtUserID
		  ,ProviderLinkingCreatedDatetime
		  ,ProviderLinkingUpdatedDatetime
		  ,ProviderLinkingIsActive
	  From HPIApp.dbo.ProviderLinking pl
	  WHERE 1=1
		AND pl.ProviderLinkingIsActive <> 0
GO
