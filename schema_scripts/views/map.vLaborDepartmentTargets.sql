CREATE VIEW map.vLaborDepartmentTargets AS

  SELECT
  
  LDT.*
  ,CONCAT(LDT.Department,LDT.Paydate) AS UniqueID

  FROM [HPIDW].[map].[LaborDepartmentTargets] LDT
GO
