Create PROCEDURE [dbo].[RemoveProviderChildren]
	-- Add the parameters for the stored procedure here
	@ProviderID varchar(max)
	
AS
BEGIN
	Delete 
   from [HPIApp].[dbo].[ProviderLinking]
   -- from [HPIDW].[map].[ProviderLinking] pl
   
	Where ParentProviderID = @ProviderID
END
GO
