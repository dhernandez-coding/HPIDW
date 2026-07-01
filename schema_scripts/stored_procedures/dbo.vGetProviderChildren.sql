CREATE PROCEDURE [dbo].[vGetProviderChildren]
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
   
   Left Join [HPIApp].[dbo].[ProviderLinking] pl on pl.ChildProviderID = p.ProviderID
   --uncomment if we decide on which db to use
   --Left Join [HPIDW].[map].[ProviderLinking] pl on pl.ChildProviderID = p.ProviderID
	Where pl.ParentProviderID = @ProviderID
END
GO
