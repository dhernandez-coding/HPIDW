-- =============================================
-- Author:		Ryan Tisserand
-- Create date: <Create Date,,>
-- Description:	Extracts, Transforms and Loads Department Data from APM Source System into a dim Table
-- Change Control
--	1. 11/23/2022 - Ryan Tisserand - Initial build of procedure
--  2. 03/10/2023 - Ryan Tisserand - Added delete statement to replace truncate job step
-- =============================================
CREATE PROCEDURE [stg].[spAPMReloadDimDepartmentsFull]
AS
BEGIN
SET NOCOUNT ON;

delete from dim.Departments where DepartmentDataSourceID = 1

insert into dim.Departments
(
	DepartmentID,
	DepartmentDataSourceID,
	DepartmentSourceID,
	DepartmentName,
	DepartmentAbbreviation,
	DepartmentDescription,
	DepartmentStreetAddress1,
	DepartmentStreetAddress2,
	DepartmentCity,
	DepartmentState,
	DepartmentZipCode,
	DepartmentPhone,
	DepartmentFederalTaxID,
	DepartmentIsActive,
	DepartmentUpdatedDateTime
)
select 
	'1~' + cast(d.Department_ID as varchar(10)) DepartmentID,
	'1' DepartmentDataSourceID,
	cast(d.Department_ID as varchar(10)) DepartmentSourceID,
	d.[Name] DepartmentName,
	d.Abbreviation DepartmentAbbreviation,
	d.[Description] DepartmentDescription,
	d.Street1 DepartmentStreetAddress1,
	d.Street2 DepartmentStreetAddress2,
	d.City DepartmentCity,
	d.[State] DepartmentState,
	d.Zip_Code DepartmentZipCode,
	d.Phone DepartmentPhone,
	d.Federal_ID_No DepartmentFederalTaxID,
	1 as DepartmentIsActive,
	GETDATE() as DepartmentUpdatedDatetime
from tievmdb03.Ntier_627200.pm.Departments d
END
GO
