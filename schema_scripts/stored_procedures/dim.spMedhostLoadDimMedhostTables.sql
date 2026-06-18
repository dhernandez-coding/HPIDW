-- =============================================
-- Author:		<Jacob Roan>
-- Create date: <2/18/2023>
-- Description:	<Uses db2 system tables to generate a dynamic sql query to get row count info from all tables in medhost db>
-- Statistics: <~ 39608 tables to process, >
-- =============================================
CREATE PROCEDURE dim.spMedhostLoadDimMedhostTables
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

-- reference to medhost db2 sys tables

--select * from openquery(hmsls, 'select distinct table_catalog from qsys2.tables')
--select * from openquery(hmsls, 'select distinct table_schema from qsys2.tables order by table_schema')
--select * from openquery(hmsls, 'select * from qsys2.tables where table_type = ''base table''')
--select * from openquery(hmsls, 'select * from qsys2.columns fetch first 100 rows only')

-- reference to landing table in hpidw

--create table dim.MedhostTables (
--	TableCatalog varchar(50)
--	,TableSchema varchar(50)
--	,TableName varchar(50)
--	,TableType varchar(50)
--	,RowCnt int
--	,IsCounted bit
--)

-- table var for storing all tables from server

declare @TempMedhostTables table 
	(
	RowNum int
	,TableCatalog varchar(50)
	,TableSchema varchar(50)
	,TableName varchar(50)
	,TableType varchar(50)
	)

-- table var for storing returned rowcount from dynamic sql query

declare @TempTablesRowCount table
	(
	TableCatalog varchar(50)
	,TableSchema varchar(50)
	,TableName varchar(50)
	,TableType varchar(50)
	,RowCnt int
	,IsCounted bit
	)

-- get all tables in db
	
insert into @TempMedhostTables
select * from openquery(hmsls, 
	'select
		ROW_NUMBER() OVER()
       ,table_catalog
	   ,table_schema
	   ,table_name
	   ,table_type
from qsys2.tables
where table_type = ''BASE TABLE''
order by table_catalog, table_schema, table_name
-- fetch first 100 rows only
')

-- select * from @TempMedhostTables

-- begin dynamic sql query to get rowcount for each table

declare 
	@openquery nvarchar(4000)
	,@tsql nvarchar(4000)
	,@linkedserver nvarchar(4000)
	,@schemaname varchar(50)
	,@tablename varchar(50)
	,@numtables int
	,@currentnum int

set @linkedserver = 'hmsls'
set @openquery = 'select * from openquery('+ @linkedserver + ','''
set @numtables = (select count(1) from @TempMedhostTables)
set @currentnum = 1

print @numtables

-- exit once the last table returned from db is reached

while @currentnum <= @numtables
begin
	begin try

		set @schemaname = (select TableSchema from @TempMedhostTables where RowNum = @currentnum)
		set @tablename = (select TableName from @TempMedhostTables where RowNum = @currentnum)

		set @tsql = 'select
						''''MHD32'''' as catalogname
						,'''''+ @schemaname +''''' as schemaname
						,'''''+ @tablename +''''' as tablename
						,''''BASE TABLE'''' as basetable
						,count(1) as rowcount
						,1 as IsCounted
					from mhd32.'+ @schemaname +'.'+@tablename+'
					'')'

		insert into @TempTablesRowCount 
		exec (@openquery+@tsql)

		set @currentnum = @currentnum + 1

		print @currentnum

	end try

	begin catch -- catch to ignore tables that were returned from systables but are inaccessible due to permissions or error

	insert into @TempTablesRowCount values
		(
			'MHD32'
			,@schemaname
			,@tablename
			,'BASE TABLE'
			,0 -- assumed 0 row count
			,0 -- IsCounted = false
		)

	set @currentnum = @currentnum + 1

	print @currentnum

	end catch

end

truncate table dim.MedhostTables

insert into dim.MedhostTables
select * from @TempTablesRowCount

END
GO
