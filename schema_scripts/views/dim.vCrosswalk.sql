CREATE VIEW [dim].[vCrosswalk] as

SELECT [DW_DepartmentID]
      ,[DW_DepartmentSourceID]
      ,[DW_DepartmentName]
      ,[UKG_Department]
      ,[Assumed_Service_Unit]
  FROM [HPIDW].[dim].[Crosswalk]
GO
