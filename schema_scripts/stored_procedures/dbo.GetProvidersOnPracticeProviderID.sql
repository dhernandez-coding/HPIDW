CREATE PROCEDURE GetProvidersOnPracticeProviderID
	-- Add the parameters for the stored procedure here
	@PracticeProviderID int
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   Select * from dbo.Providers P
   left join dbo.PracticeProviders pp on P.ProviderID = pp.ProviderID
   where pp.PracticeProviderID = @PracticeProviderID
END
GO
