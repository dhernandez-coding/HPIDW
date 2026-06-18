CREATE PROCEDURE [etl].[spCreateNewDimTable] as

DECLARE @SchemaName varchar(100) = 'dim' --'fact'
DECLARE @EntityName varchar(100) = 'Location'
DECLARE @PluralName varchar(100) = Concat(@EntityName,'s')

DECLARE @sql VARCHAR(MAX) = 
	'CREATE TABLE ' + @SchemaName + '.' + @PluralName + 
	'
	(
		' + @EntityName + 'ID varchar(100) primary key not null
		, ' + @EntityName + 'DatasourceID int
		, ' + @EntityName + 'SourceID varchar(100)
		, ' + @EntityName + 'Name varchar(100)
		, ' + @EntityName + 'IsActive bit
		, ' + @EntityName + 'UpdatedDatetime datetime
	)'

print @sql
GO
