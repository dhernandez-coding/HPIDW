CREATE PROCEDURE [dbo].[vGetProviderUnassignedChildren]
	-- Add the parameters for the stored procedure here
	@ProviderID varchar(max)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
   Select
	   p.[ProviderID]
      ,p.[ProviderDataSourceID]
      ,p.[ProviderSourceID]
      ,p.[ProviderAbbreviation]
      ,p.[ProviderFirstName]
      ,p.[ProviderMiddleInitial]
      ,p.[ProviderLastName]
      ,p.[ProviderGender]
      ,p.[ProviderSuffix]
      ,p.[ProviderStreetAddress1]
      ,p.[ProviderStreetAddress2]
      ,p.[ProviderCity]
      ,p.[ProviderState]
      ,p.[ProviderZipCode]
      ,p.[ProviderPhone]
      ,p.[ProviderFax]
      ,p.[ProviderSpecialtyID]
      ,p.[ProviderUPIN]
      ,p.[ProviderNPI]
      ,p.[ProviderIsActive]
      ,Cast(p.[ProviderUpdatedDateTime] as Date) as ProviderUpdatedDateTime
   
   from dim.vProviders p
   
	Where
	
	(p.ProviderID not in (select ChildProviderID from HPIApp.dbo.ProviderLinking)
	AND p.ProviderID not in (select ParentProviderID from HPIApp.dbo.ProviderLinking))
	-- (p.ProviderID not in (select ChildProviderID from map.ProviderLinking)
	--AND p.ProviderID not in (select ParentProviderID from map.ProviderLinking))
END
GO
