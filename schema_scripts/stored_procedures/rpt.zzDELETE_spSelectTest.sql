CREATE PROCEDURE rpt.zzDELETE_spSelectTest as 

SET NOCOUNT ON

DECLARE @Table1 TABLE (ID int, Name varchar(5))
INSERT INTO @Table1 SELECT 1,'TEST1'
INSERT INTO @Table1 SELECT 2,'TEST2'


DECLARE @Table2 TABLE (ID int, TestDate date)
INSERT INTO @Table2 SELECT 1,'1/1/2024'
INSERT INTO @Table2 SELECT 2,GETDATE()


SELECT t1.ID,t1.Name,t2.TestDate,convert(varchar(10),t2.TestDate) as DateConverted,GETDATE() as RefreshDate
FROM @Table1 t1 
	LEFT JOIN @Table2 T2 on t1.ID = t2.ID
GO
