-- =============================================
-- Author:		Ryan Tisserand
-- Create date: 02/24/2023
-- Description:	Extracts, Transforms and Loads Provider Data from internal Source System into a dim Table
-- Change Control
--	1. 02/24/2023 - Ryan Tisserand - Initial build of procedure
-- =============================================
CREATE PROCEDURE [stg].[spHPIReloadDimProvidersFull]
AS
BEGIN
SET NOCOUNT Off;

PRINT 'Inserting records into #TEMP_Staging Table....'
	drop table if exists #TEMP_Staging
	select 
		p.ProviderProviderID as ProviderID,
		0 as ProviderDataSourceID,
		p.ProviderID as ProviderSourceID,
		NULL AS ProviderAbbreviation,
		p.ProviderFirstName as ProviderFirstName,
		p.ProviderMiddleInitial as ProviderMiddleInitial,
		p.ProviderLastName as ProviderLastName,
		p.ProviderGender as ProviderGender,
		p.ProviderSuffix as ProviderSuffix,
		p.ProviderStreetAddress1 as ProviderStreetAddress1,
		p.ProviderStreetAddress2 as ProviderStreetAddress2,
		p.ProviderCity as ProviderCity,
		p.ProviderState as ProviderState,
		p.ProviderZipCode as ProviderZipCode,
		p.ProviderPhone as ProviderPhone,
		p.ProviderFax as ProviderFax,
		CASE WHEN p.ProviderSpecialtyID is not null THEN CONCAT('0~',p.ProviderSpecialtyID) END AS ProviderSpecialtyID,
		p.ProviderUPIN as ProviderUPIN,
		p.ProviderNPI as ProviderNPI,
		p.ProviderIsActive as ProviderIsActive,
		GETDATE() AS ProviderUpdatedDateTime
	--select * 
	 INTO #TEMP_Staging
	 FROM [HPIApp].dbo.Providers p
	 where 
	 1=1 and
	 p.IsDeleted  = 0


IF (SELECT COUNT(*) FROM #TEMP_Staging)  > 100 
BEGIN
	PRINT 'Deleting records from dim.Providers...'
	delete from dim.Providers where ProviderDataSourceID = 0


	PRINT 'Inserting records into dim.Providers...'
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
		p.ProviderID as ProviderID,
		0 as ProviderDataSourceID,
		p.ProviderID as ProviderSourceID,
		NULL AS ProviderAbbreviation,
		p.ProviderFirstName as ProviderFirstName,
		p.ProviderMiddleInitial as ProviderMiddleInitial,
		p.ProviderLastName as ProviderLastName,
		p.ProviderGender as ProviderGender,
		p.ProviderSuffix as ProviderSuffix,
		p.ProviderStreetAddress1 as ProviderStreetAddress1,
		p.ProviderStreetAddress2 as ProviderStreetAddress2,
		p.ProviderCity as ProviderCity,
		p.ProviderState as ProviderState,
		p.ProviderZipCode as ProviderZipCode,
		p.ProviderPhone as ProviderPhone,
		p.ProviderFax as ProviderFax,
		p.ProviderSpecialtyID AS ProviderSpecialtyID,
		p.ProviderUPIN as ProviderUPIN,
		p.ProviderNPI as ProviderNPI,
		p.ProviderIsActive as ProviderIsActive,
		GETDATE() AS ProviderUpdatedDateTime
	--select * 
	 FROM #TEMP_Staging p --[HPIApp].dbo.Providers p
	 where 
	 1=1 
END

ELSE 
	PRINT 'Less than 100 records in source.  Stopping job without proceeding.'



/*
select 
	'5~' + cast(p.PROV_ID as varchar(50)) ProviderID,
	5 ProviderDataSourceID,
	p.PROV_ID ProviderSourceID, 
	p.PROV_ABBR ProviderAbbreviation,
	case when len(p.PROV_NAME) - len(replace(p.PROV_NAME,' ','')) = 2
		then substring(p.PROV_NAME,charindex(' ',p.PROV_NAME)+1,(charindex(' ',p.PROV_NAME, (charindex(' ',p.PROV_NAME,1))+1)) - charindex(' ',p.PROV_NAME)-1)
		else right(p.PROV_NAME,CASE WHEN len(p.PROV_NAME) - charindex(' ',p.PROV_NAME) >= 1 THEN len(p.PROV_NAME) - charindex(' ',p.PROV_NAME) ELSE 0 END)
	end ProviderFirstName,
	case when len(p.PROV_NAME) - len(replace(p.PROV_NAME,' ','')) = 2
		then right(p.PROV_NAME,1)
		else ''
	end ProviderMiddleInitial,
	replace(replace(substring(p.PROV_NAME,1,charindex(' ',p.PROV_NAME)),',',''),' ','') ProviderLastName,
	x.ABBR ProviderGender, 
	p.CLINICIAN_TITLE ProviderSuffix, 
	a.addr_line_1 ProvderStreetAddress1, 
	a.addr_line_2 ProviderStreetAddress2, 
	a.CITY ProviderCity, 
	t.ABBR ProviderState, 
	a.ZIP ProviderZipCode,
	p.OFFICE_PHONE_NUM ProviderPhone, 
	p.OFFICE_FAX_NUM ProviderFax, 
	CASE WHEN si.SPECIALTY_C is not null THEN CONCAT('5~',si.SPECIALTY_C) END ProviderSpecialtyID,
	p.UPIN ProviderUPIN, 
	pa.NPI ProviderNPI,
	case when p.ACTIVE_STATUS = 'Active' then 1 else 0 end ProviderIsActive,
	getdate() ProviderUpdatedDateTime
from [100.65.16.149].[CLARITY].[ORGFILTER].[CLARITY_SER] p
left join [100.65.16.149].[CLARITY].[ORGFILTER].[CLARITY_SER_2] pa on p.PROV_ID = pa.PROV_ID
left join [100.65.16.149].[CLARITY].[ORGFILTER].[CLARITY_SER_ADDR] a on p.PROV_ID = a.PROV_ID and a.PRIMARY_ADDR_YN = 'Y'
left join [100.65.16.149].[CLARITY].[ORGFILTER].[CLARITY_SER_SPEC] si on p.PROV_ID = si.PROV_ID and si.line = 1
--left join [100.65.16.148].[CLARITY].[ORGFILTER].[ZC_SPECIALTY] s on si.SPECIALTY_C = s.SPECIALTY_C
left join [100.65.16.149].[CLARITY].[ORGFILTER].[ZC_SEX] x on p.SEX_C = x.RCPT_MEM_SEX_C 
left join [100.65.16.149].[CLARITY].[ORGFILTER].[ZC_STATE] t on a.STATE_C = t.STATE_C
left join [100.65.16.149].[CLARITY].[ORGFILTER].[ZC_STAFF_RESOURCE] r on p.STAFF_RESOURCE_C = r.STAFF_RESOURCE_C
*/

END
GO
