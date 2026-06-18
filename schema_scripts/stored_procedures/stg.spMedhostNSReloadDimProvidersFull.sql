-- =============================================
-- Author:		Ryan Tisserand
-- Create date: 03/01/2023
-- Description:	Extracts, Transforms and Loads Provider Data from Medhost Northwest Hospital Source System into a dim Table
-- Change Control
--	1. 03/01/2023 - Ryan Tisserand - Initial build of procedure
--  2. 03/13/2023 - Chris Cross - Added ProviderSpecialtyID
-- =============================================
--exec  [stg].[spMedhostNSReloadDimProvidersFull]
CREATE PROCEDURE [stg].[spMedhostNSReloadDimProvidersFull]
AS
BEGIN
SET NOCOUNT ON;

delete from dim.Providers where ProviderDataSourceID = 2

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
	'2~' + cast(p.ProviderID as varchar(50)) as ProviderID,
	2 as ProviderDataSourceID,
	cast(p.ProviderID as varchar(50)) as ProviderSourceID,
	'' as ProviderAbbreviation,
	case len(p.ProviderName) - len(replace(p.ProviderName,' ',''))
		when 3 then substring(p.ProviderName,charindex(' ',p.ProviderName)+1,(charindex(' ',p.ProviderName, (charindex(' ',p.ProviderName,1))+1)) - charindex(' ',p.ProviderName)-1)
		when 2 then substring(p.ProviderName,charindex(' ',p.ProviderName)+1,(charindex(' ',p.ProviderName, (charindex(' ',p.ProviderName,1))+1)) - charindex(' ',p.ProviderName)-1)
		when 1 then right(p.ProviderName,len(p.ProviderName) - charindex(' ',p.ProviderName))
		else ''
	end as ProviderFirstName,
	case len(p.ProviderName) - len(replace(p.ProviderName,' ',''))
		when 3 then substring(p.ProviderName,charindex(' ',p.ProviderName, (charindex(' ',p.ProviderName, 1))+1),1)
		when 2 then right(p.ProviderName,len(p.ProviderName) - charindex(' ',p.ProviderName, (charindex(' ',p.ProviderName, 1))+1))
		when 1 then ''
		else ''
	end as ProviderMiddleName,
	case when charindex(' ',p.ProviderName) = 0 then p.ProviderName else left(p.ProviderName,charindex(' ',p.ProviderName)-1) end as ProviderLastName,
	'' as ProviderGender,
	p.ProviderSuffix,
	p.ProviderStreetAddress1,
	'' ProviderStreetAddress2,
	p.ProviderCity,
	p.ProviderState,
	p.ProviderZipCode,
	'(' + cast(p.AreaCode as varchar(50)) + ') ' + cast(left(p.OfficePhone,3) as varchar(50)) + '-' +  cast(right(p.OfficePhone,4) as varchar(50)) ProviderPhone,
	'' ProviderFax,
	CONCAT('2~A',p.ProviderSpecialtyAbbreviation) as ProviderSpecialtyID, /*A is a necessary prefix*/
	'' ProviderUPIN,
	CASE WHEN p.ProviderNPI like '%107307914' THEN '1073079141' 
		 WHEN p.ProviderNPI like '%116484464' THEN '1164844643'
		 WHEN p.ProviderNPI = '114330099' THEN '1114330099'
		ELSE p.ProviderNPI
		END as ProviderNPI,
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
	from MHD32.HOSPF100.PHYMAST p
		left join (select
					NWDRNUM
					,MAX(NPINUM) AS NPI
					from MHD32.HOSPF100.PHYNUMB
					where 1=1 
					AND INSCO = 0
					GROUP BY NWDRNUM ) npi ON npi.NWDRNUM = p.NWDRNUM
'
) p

END
GO
