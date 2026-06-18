CREATE VIEW map.vPracticeDepartments as 
SELECT [PracticeDepartmentID]
      ,pd.[PracticeID]
	  ,p.PracticeName
      ,pd.[DepartmentID]
	  ,d.DepartmentName
      ,[PracticeDepartmentEffectiveDate]
      ,[PracticeDepartmentEndDate]
      ,[PracticeDepartmentIsActive]
      ,[PracticeDepartmentUpdatedDatetime]
  FROM [HPIDW].[map].[PracticeDepartments] pd
  left join dim.Departments d ON d.DepartmentID = pd.DepartmentID
  left join dim.Practices p ON p.PracticeID = pd.PracticeID
GO
