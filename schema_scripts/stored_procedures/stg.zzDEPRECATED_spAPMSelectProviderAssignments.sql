-- =============================================
-- Author:		Ryan Tisserand
-- Create date: 08/19/2022
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [stg].[spAPMSelectProviderAssignments]
AS
BEGIN
SET NOCOUNT ON;
select
	p.ProviderID,
	p.ProviderAbbreviation,
	p.ProviderFirstName,
	p.ProviderLastName,
	pa.ProviderWorksFor,
	wf.ProviderID,
	wf.ProviderAbbreviation,
	wf.ProviderFirstName,
	wf.ProviderLastName,
	pa.ProviderType,
	pa.ProviderSplit
from dim.Providers p
left join dim.ProviderAssignments pa on p.ProviderID = pa.ProviderID
left join dim.Providers wf on pa.ProviderWorksFor = wf.ProviderAbbreviation
END
GO
