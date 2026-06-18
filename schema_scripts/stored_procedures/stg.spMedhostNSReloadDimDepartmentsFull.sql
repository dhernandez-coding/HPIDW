-- =============================================
-- Author:		Ryan Tisserand
-- Create date: 03/15/2023
-- Description:	Extracts, Transforms and Loads Department Data from Medhost Northwest Surgical Hospital Source System into a dim Table
-- Change Control
--	1. 03/15/2023 - Ryan Tisserand - Initial build of procedure
-- =============================================
CREATE PROCEDURE [stg].[spMedhostNSReloadDimDepartmentsFull]
AS
BEGIN
SET NOCOUNT ON;

delete from dim.Departments where DepartmentDataSourceID = 2

insert into dim.Departments
(
	[DepartmentID]
      ,[DepartmentDataSourceID]
      ,[DepartmentSourceID]
      ,[DepartmentName]
      ,[DepartmentLocationID]
      ,[DepartmentParentLocationID]
      ,[DepartmentServiceAreaLocationID]
      ,[DepartmentAbbreviation]
      ,[DepartmentDescription]
      ,[DepartmentStreetAddress1]
      ,[DepartmentStreetAddress2]
      ,[DepartmentCity]
      ,[DepartmentState]
      ,[DepartmentZipCode]
      ,[DepartmentPhone]
      ,[DepartmentFederalTaxID]
      ,[DepartmentIsActive]
      ,[DepartmentUpdatedDateTime]
)

select
	'2~' + d.SVCCD DepartmentID,
	2 DepartmentDataSourceID,
	d.SVCCD DepartmentSourceID,
	d.HSVDSC DepartmentName,
	'2~' + d.SITE_LOCD DepartmentLocationID,
	'2~' + d.SITE_LOCD DepartmentParentLocationID,
	'2~' + d.SITE_LOCD DepartmentServiceAreaLocationID,
	d.SVCCD DepartmentAbbreviation,
	d.HSVDSC DepartmentDescription,
	'' DepartmentStreetAddress1,
	'' DepartmentStreetAddress2,
	'' DepartmentCity,
	'' DepartmentState,
	'' DepartmentZipCode,
	'' DepartmentPhone,
	'' DepartmentFederalTaxID,
	1 DepartmentIsActive,
	getdate() DepartmentUpdatedDateTime
from openquery
([HMSLS],
'
	select
		*
	from HOSPF100.STATHDL
'
) d
END
GO
