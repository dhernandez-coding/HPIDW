-- =============================================
-- Author:		Ryan Tisserand
-- Create date: 03/01/2023
-- Description:	Extracts, Transforms and Loads Provider Data from Medhost Community Hospital Source System into a dim Table
-- Change Control
--	1. 03/01/2023 - Ryan Tisserand - Initial build of procedure
-- =============================================
CREATE PROCEDURE [stg].[spMedhostCHReloadDimProvidersFull]
AS
BEGIN
SET NOCOUNT ON;

delete from dim.Providers where ProviderDataSourceID = 8

insert into dim.Providers
(
	ProviderID,
	ProviderDataSourceID,
	ProviderSourceID,
	ProviderAbbreviation,
	ProviderFirstName,
	ProviderMiddleInitial,
	ProviderLastName,
	ProviderGender,
	ProviderSuffix,
	ProviderStreetAddress1,
	ProviderStreetAddress2,
	ProviderCity,
	ProviderState,
	ProviderZipCode,
	ProviderPhone,
	ProviderFax,
	ProviderSpecialtyID,
	ProviderUPIN,
	ProviderNPI,
	ProviderIsActive,
	ProviderUpdatedDateTime
)

select
	'8~' + cast(p.ProviderID as varchar(50)) ProviderID,
	8 ProviderDataSourceID,
	cast(p.ProviderID as varchar(50)) ProviderSourceID,
	'' ProviderAbbreviation,
	case len(p.ProviderName) - len(replace(p.ProviderName,' ',''))
		when 3 then substring(p.ProviderName,charindex(' ',p.ProviderName)+1,(charindex(' ',p.ProviderName, (charindex(' ',p.ProviderName,1))+1)) - charindex(' ',p.ProviderName)-1)
		when 2 then substring(p.ProviderName,charindex(' ',p.ProviderName)+1,(charindex(' ',p.ProviderName, (charindex(' ',p.ProviderName,1))+1)) - charindex(' ',p.ProviderName)-1)
		when 1 then right(p.ProviderName,len(p.ProviderName) - charindex(' ',p.ProviderName))
		else ''
	end ProviderFirstName,
	case len(p.ProviderName) - len(replace(p.ProviderName,' ',''))
		when 3 then substring(p.ProviderName,charindex(' ',p.ProviderName, (charindex(' ',p.ProviderName, 1))+1),1)
		when 2 then right(p.ProviderName,len(p.ProviderName) - charindex(' ',p.ProviderName, (charindex(' ',p.ProviderName, 1))+1))
		when 1 then ''
		else ''
	end ProviderMiddleName,
	case when charindex(' ',p.ProviderName) = 0 then p.ProviderName else left(p.ProviderName,charindex(' ',p.ProviderName)-1) end ProviderLastName,
	'' ProviderGender,
	p.ProviderSuffix,
	p.ProviderStreetAddress1,
	'' ProviderStreetAddress2,
	p.ProviderCity,
	p.ProviderState,
	p.ProviderZipCode,
	'(' + cast(p.AreaCode as varchar(50)) + ') ' + cast(left(p.OfficePhone,3) as varchar(50)) + '-' +  cast(right(p.OfficePhone,4) as varchar(50)) ProviderPhone,
	'' ProviderFax,
	CONCAT('8~A',p.ProviderSpecialtyAbbreviation) as ProviderSpecialtyID, /*A is a necessary prefix*/
	'' ProviderUPIN,
	CASE WHEN p.ProviderNPI = '187181570' THEN '1871811570'
	     WHEN p.ProviderNPI = '7946789654' THEN '1104022417'
	
		ELSE p.ProviderNPI END as ProviderNPI,
	1 as ProviderIsActive,
	getdate() as ProviderUpdatedDateTime

from openquery
(HMSLS, 
'
	select
		p.NWDRNUM ProviderID,
		p.PHNAME ProviderName,
		p.PHYTYP ProviderSuffix,
		p.PHADDR ProviderStreetAddress1,
		p.DCITY ProviderCity,
		p.PHST ProviderState,
		p.DZIP ProviderZipCode,
		p.OARC AreaCode,
		p.OTEL OfficePhone,
		p.DSPEC ProviderSpecialtyAbbreviation,
		npi.NPI as ProviderNPI
	from MHD32.HOSPF110.PHYMAST p
		left join (select
					NWDRNUM
					,MAX(NPINUM) AS NPI
					from MHD32.HOSPF110.PHYNUMB
					where 1=1 
					AND INSCO = 0
					GROUP BY NWDRNUM ) npi ON npi.NWDRNUM = p.NWDRNUM
'
) p

END
GO
