create procedure [stg].[spHPIReloadDimPayerGroupsFull]
AS
BEGIN
SET NOCOUNT ON;


 DELETE FROM dim.PayerGroups WHERE PayerGroupDataSourceID = 0

 INSERT INTO dim.PayerGroups
 ([PayerGroupID],
	[PayerGroupDataSourceID],
	[PayerGroupsourceID],
	[PayerGroupName],
	[PayerGroupIsActive],
	[PayerGroupUpdatedDateTime]
	)

 SELECT
	concat('0~',g.PayerGroupID) as ID
	,0 as DatasourceID
	,CONVERT(varchar(100),g.PayerGroupID) as PayerGroupsourceID
	,g.PayerGroupName
    ,1 as [IsActive]
	,GETDATE() AS [UpdatedDateTime]
 --select * 
 FROM [HPIApp].dbo.PayerGroups g

 END
GO
