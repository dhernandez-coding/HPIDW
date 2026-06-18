-- =============================================
-- Author:		Ryan Tisserand
-- Create date: 09/05/2022
-- Description:	Generates a Data Dictionary for the HPIDW database
-- Change Control
--	1. 08/31/2022 - Initial build of procedure
-- =============================================
CREATE PROCEDURE dim.spDataDictionary
AS
BEGIN
SET NOCOUNT ON;

DECLARE @DBSHCO TABLE
	(
		DSTC varchar(500),
		DatabaseName varchar(500),
		SchemaName varchar(500),
		TableName varchar(500),
		ColumnName varchar(500),
		ColumnID INT, 
		DataType varchar(500)
	)
declare @DBS table(ID int identity(1,1),DatabaseName varchar(500),CreationDate datetime)
declare @Counter int
declare @DBCount int
declare @DB varchar(500)
declare @SQL varchar(MAX)
insert into @DBS
select name,create_date
from sys.databases 
where name = 'HPIDW'
order by name
set @Counter = 0
set @DBCount = (select COUNT(ID) from @DBS)
while @Counter < @DBCount
begin
set @Counter = @Counter + 1
set @DB = (select DatabaseName from @DBS where ID = @Counter)
set @SQL =
' 
	select 
	''[' + @DB + ']'' + ''.['' + S.name + '']'' + ''.['' + T.name + '']'' + ''.['' + C.name +'']'' DSTC,
	''' + @DB + ''' DatabaseName, S.name SchemaName, T.name TableName, C.name ColumnName,
	C.column_id ColumnID,
	case 
		when Y.name LIKE(''%char%'') 
		then Y.name + ''('' + CAST(C.max_length AS varchar(50)) + '')''
		when Y.name LIKE(''%decimal%'') 
		then Y.name + ''('' + CAST(Y.precision AS varchar(50)) + '','' + CAST(Y.scale AS varchar(50)) + '')''
		else Y.name
	end DataType
	from [' + @DB + '].sys.tables T
	left join [' + @DB + '].sys.schemas S ON T.schema_id = S.schema_id
	left join [' + @DB + '].sys.objects O ON T.object_id = O.object_id
	left join [' + @DB + '].sys.columns C ON O.object_id = C.object_id
	left join [' + @DB + '].sys.types Y   ON C.system_type_id = Y.system_type_id
	where T.type = ''U'' and Y.name <> ''sysname''
'
insert into @DBSHCO
exec(@SQL)
end
select * 
from @DBSHCO
order by
	DatabaseName,
	SchemaName,
	TableName,
	ColumnID

END
GO
