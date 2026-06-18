-- =============================================
-- Author:		Eric Silvestri
-- Create date: 05/28/2025
-- Description:	Extracts, Transforms and Loads Provider Data from APM Source System into a dim Table
-- Change Control
-- =============================================

CREATE PROCEDURE [stg].[spAPMCustomersReloadDimProvidersFull] AS
BEGIN
SET NOCOUNT ON;

delete from dim.Providers where ProviderDataSourceID = 12

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
	'12' + '~' + cast(p.Practitioner_ID as varchar(50)) ProviderID,
	12 ProviderDataSourceID,
	p.Practitioner_ID ProviderSourceID,
	p.Abbreviation ProviderAbbreviation,
	p.First_Name ProviderFirstName,
	p.Middle_Initial ProviderMiddleInitial,
	p.Last_Name ProviderLastName,
	p.Sex ProviderGender,
	p.Suffix ProviderSuffix,
	p.Street1 ProviderStreetAddress1,
	p.Street2 ProviderStreetAddress2,
	p.City ProviderCity,
	p.[State] ProviderState,
	p.Zip_Code ProviderZipCode,
	p.Phone ProviderPhone,
	p.Fax_Number ProviderFax,
	'' ProviderSpecialtyID,
	p.UPIN ProviderUPIN,
	REPLACE(ISNULL(pbn.Individual_Billing_Number,''),' ','') as ProviderNPI,
	1 ProviderIsActive,
	getdate() ProviderUpdatedDateTime
	--p.Is_Non_Person ProviderIsNonPerson,
	--p.Is_Mid_Level ProviderIsMidLevel
from tievmdb03.Ntier_HPI_Customers.PM.Practitioners p
	LEFT JOIN tievmdb03.Ntier_HPI_Customers.[PM].Provider_Info pi on p.Practitioner_ID = pi.Practitioner_ID
	LEFT JOIN tievmdb03.Ntier_HPI_Customers.[PM].[Provider_Billing_Numbers] pbn on pbn.Provider_Info_ID = pi.Provider_Info_ID AND pbn.Profile_ID in (20) /*npi*/
--left join tievmdb03.Ntier_627200.PM.Specialties s on p.Specialty_ID = s.Specialty_ID
--left join map.ProviderAssignments pa on '1' + '~' + cast(p.Practitioner_ID as varchar(50)) = pa.ProviderAssignmentProviderID
where 1=1
	and p.last_name like '%alvis%'
	AND P.Practitioner_Id IN ('92811','47056','95823','98834','98968','47022','99110','99114','98834') --I added 15352 for including Alvis but no 100% sure if thats the record we should pull from this table. MAybe 99143

END
GO
