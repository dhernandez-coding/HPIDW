-- =============================================
-- Author:		Eric Silvestri
-- Create date: 05/28/2025
-- Description:	Extracts, Transforms and Loads Department Data from APM Source System into a dim Table for HPI Customers
-- Change Control

-- =============================================
CREATE PROCEDURE [stg].[spAPMCustomerReloadDimDepartmentsFull]
AS
BEGIN
SET NOCOUNT ON;

delete from dim.Departments where DepartmentDataSourceID = 12

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
	CONCAT('12~',cast(d.Department_ID as varchar(10))) DepartmentID,
	'12' DepartmentDataSourceID,
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
from tievmdb03.Ntier_HPI_Customers.pm.Departments d
where d.Abbreviation in ('IME','JRS','JCJ','OPCL','BSFM    ', 'ALVIS   ')
END
GO
