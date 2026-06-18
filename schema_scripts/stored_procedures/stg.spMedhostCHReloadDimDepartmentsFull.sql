-- =============================================
-- Author:		Ryan Tisserand
-- Create date: 03/15/2023
-- Description:	Extracts, Transforms and Loads Department Data from Medhost Community Hospital Source System into a dim Table
-- Change Control
--	1. 03/15/2023 - Ryan Tisserand - Initial build of procedure
-- =============================================
CREATE PROCEDURE [stg].[spMedhostCHReloadDimDepartmentsFull]
AS
BEGIN
SET NOCOUNT ON;

delete from dim.Departments where DepartmentDataSourceID = 8

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
	'8~' + d.SVCCD DepartmentID,
	8 DepartmentDataSourceID,
	d.SVCCD DepartmentSourceID,
	d.HSVDSC DepartmentName,
	'8~' + d.SITE_LOCD DepartmentLocationID,
	'8~' + d.SITE_LOCD DepartmentParentLocationID,
	'8~' + d.SITE_LOCD DepartmentServiceAreaLocationID,
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
	from HOSPF110.STATHDL
'
) d
END
GO
