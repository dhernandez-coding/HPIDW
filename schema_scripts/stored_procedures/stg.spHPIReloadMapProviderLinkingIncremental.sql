CREATE PROCEDURE [stg].[spHPIReloadMapProviderLinkingIncremental] as


INSERT INTO map.ProviderLinking
	([ParentProviderID]
      ,[ChildProviderID]
      ,[ProviderLinkingMgmtUserID]
      ,[ProviderLinkingCreatedDatetime]
      ,[ProviderLinkingUpdatedDatetime]
      ,[ProviderLinkingIsActive]
	  )

select
	p0.ProviderID as ParentProviderID
	,p.ProviderID as ChildProviderID
	,0 [ProviderLinkingMgmtUserID]
    ,getdate() [ProviderLinkingCreatedDatetime]
    ,getdate() [ProviderLinkingUpdatedDatetime]
    ,1 [ProviderLinkingIsActive]

from dim.Providers p
	LEFT JOIN map.ProviderLinking pl ON pl.ChildProviderID = p.ProviderID
	LEFT JOIN dim.Providers p0 ON p0.ProviderID = CONCAT('0~',p.ProviderNPI)
where 1=1
	AND p.ProviderDataSourceID <> 0
	AND ISNUMERIC(p.ProviderNPI) = 1 
	AND p.ProviderNPI NOT IN ('0'
								,'000'
								,'000000'
								,'000000000'
								,'0000000000'
								,'0000000009'
								,'000000002'
								,'9999999'
								,'99999999'
								,'9999999999')
	AND pl.ParentProviderID is null
	AND p0.ProviderID is not null /*Don't load into map table if 0 record doesn't already exist*/

/*
select
	p.ProviderNPI
	,p.*
from dim.Providers p
	LEFT JOIN map.ProviderLinking_PREHERO pl ON pl.ChildProviderID = p.ProviderID
where 1=1
	AND p.ProviderDataSourceID <> 0
	AND ISNUMERIC(p.ProviderNPI) = 1 
	AND p.ProviderNPI NOT IN ('0'
								,'000'
								,'000000'
								,'000000000'
								,'0000000000'
								,'0000000009'
								,'000000002'
								,'9999999'
								,'99999999'
								,'9999999999')
	AND pl.ParentProviderID is null


--Old Logic

	  --Delete From HPIDW.map.ProviderLinking

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
*/
GO
