-- =============================================
-- Author:		Ryan Tisserand
-- Create date: 11/23/2022
-- Description:	Extracts, Transforms and Loads Payer Data from APM Source System into a dim Table
-- Change Control
--	1. 11/23/2022 - Ryan Tisserand - Initial build of procedure
--  2. 03/10/2023 - Ryan Tisserand - Added delete statement to replace truncate job step
--  3. 
-- =============================================
CREATE PROCEDURE [stg].[spAPMReloadDimPayersFull]
AS
BEGIN
SET NOCOUNT ON;

delete from dim.Payers where PayerDataSourceID = 1

--Insert one row for NULL values from source system
insert into dim.Payers(PayerID,PayerDataSourceID,PayerSourceID,PayerGroupID,PayerCategoryID,PayerName,PayerAbbreviation)select '1~SELF',1,'SELF','0~7','1~-1','Self-Pay','Self-Pay'

insert into dim.Payers
(
	PayerID,
	PayerDataSourceID,
	PayerSourceID,
	PayerGroupID,
	PayerCategoryID,
	PayerName,
	PayerAbbreviation,
	PayerStreetAddress1,
	PayerStreetAddress2,
	PayerCity,
	PayerState,
	PayerZipCode,
	PayerIsActive,
	PayerUpdatedDateTime
)
select 
	'1' + '~' + cast(p.Carrier_ID as varchar(50)) PayerID,
	1 PayerDataSourceID,
	p.Carrier_ID PayerSourceID,
	pg.PayerGroupID PayerGroupID,
	'1~' + cast(p.Insurance_Category_ID as varchar(50)) PayerCategoryID,
	p.[Name] PayerName,
	p.Abbreviation PayerAbbreviation,
	p.Street1 PayerStreetAddress1,
	p.Street2 PayerStreetAddres2,
	p.[City] PayerCity,
	p.[State] PayerState,
	p.Zip_Code PayerZipCode,
	1 PayerIsActive,
	getdate() PayerUpdatedDateTime
from tievmdb03.Ntier_627200.PM.Carriers p
	left join dim.PayerCategories pc ON pc.PayerCategoryID = ('1~' + cast(p.Insurance_Category_ID as varchar(50)))
	left join map.PayerGroupPayerCategories pg ON pg.PayerCategoryID = pc.PayerCategoryID

--select * from tievmdb03.Ntier_627200.PM.Carriers p where p.Name like '%Blue%'
----select * from tievmdb03.Ntier_627200.PM.Insurance_Plans p where p.Name like '%Blue%'
--select * from tievmdb03.Ntier_627200.PM.Insurance_Categories p where p.Name like '%Blue%'
--select * from tievmdb03.Ntier_627200.PM.Insurance_Groups p
--select * from tievmdb03.Ntier_627200.PM.Insurance_Reporting_Classes p

--select * from tievmdb03.Ntier_627200.PM.Ins_Group_Membership p
--left join tievmdb03.Ntier_627200.PM.Insurance_Categories i on p.Insurance_Category_ID = i.Insurance_Category_ID
--left join map.PayerCategories c on i.[Description] = c.PayerSubCategory
END
GO
