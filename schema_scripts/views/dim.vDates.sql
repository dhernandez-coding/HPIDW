CREATE VIEW dim.vDates as
 SELECT [DateKey]
      ,[Date]
      ,[Day]
      ,[DaySuffix]
      ,[Weekday]
      ,[WeekDayName]
      ,[IsWeekend]
      ,[IsHoliday]
      ,[DOWInMonth]
      ,[DayOfYear]
      ,[WeekOfMonth]
      ,[WeekOfYear]
      ,[ISOWeekOfYear]
      ,[Month]
      ,[MonthName]
      ,[Quarter]
      ,[QuarterName]
      ,[Year]
      ,[MMYYYY]
      ,[MonthYear]
      ,[FirstDayOfWeek]
      ,[LastDayOfWeek]
      ,[FirstDayOfMonth]
      ,[LastDayOfMonth]
      ,[FirstDayOfQuarter]
      ,[LastDayOfQuarter]
      ,[FirstDayOfYear]
      ,[LastDayOfYear]
      ,[FirstDayOfNextMonth]
      ,[FirstDayOfNextYear]
  FROM [HPIDW].[dim].[Dates] d
  WHERE 1=1
	AND d.Date >= DATEFROMPARTS(YEAR(GETDATE())-10,1,1)
	AND d.Date < DATEFROMPARTS(YEAR(GETDATE())+1,1,1)
GO
