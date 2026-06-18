CREATE PROCEDURE [dbo].[spCreateReloadTableProcedureINCREMENTALTemplate] as 

SET NOCOUNT ON

DECLARE @Database varchar(10) = 'HPIDW' --Input target Database
DECLARE @Schema varchar(10) = 'dim' --Input target Schema
DECLARE @Table varchar(30) = 'Practices' --Input target table
DECLARE @DatasourceID int = 0 -- Input target DatasourceID from dim.Datasources
DECLARE @DatasourceName varchar(100) = (SELECT TOP 1 DatasourceName FROM dim.Datasources WHERE DatasourceID = @DatasourceID)
DECLARE @PrimaryKeyDelimeter varchar(1) = '~' --'~'
DECLARE @IncrementStartDate varchar(10) = CONVERT(varchar(10),DATEADD(DAY,-30,GETDATE()),126)
DECLARE @IncrementEndDate varchar(10) = CONVERT(varchar(10),GETDATE(),126)

DECLARE @Output varchar(max)


/*-----Build Information Schema Table-----*/
DECLARE @TableInfo table (TableName varchar(100), ColumnPosition int, ColumnName varchar(100), ColumnDataType varchar(100))

	INSERT INTO @TableInfo
		SELECT 
			t.TABLE_NAME AS TableName
			,c.ORDINAL_POSITION as ColumnPosition
			,c.COLUMN_NAME as ColumnName
			,CONCAT(c.DATA_TYPE, CASE WHEN c.CHARACTER_MAXIMUM_LENGTH is not null THEN CONCAT('(',c.CHARACTER_MAXIMUM_LENGTH,')') END) as ColumnDataType  
		FROM INFORMATION_SCHEMA.TABLES t 
			LEFT JOIN INFORMATION_SCHEMA.COLUMNS c ON c.TABLE_CATALOG = t.TABLE_CATALOG 
												  and c.TABLE_SCHEMA = t.TABLE_SCHEMA
												  and c.TABLE_NAME = t.TABLE_NAME
		WHERE 1=1
			AND t.TABLE_CATALOG = @Database
			AND t.TABLE_SCHEMA = @Schema
			AND t.TABLE_NAME = @Table 

DECLARE @OutputColumns varchar(max)
DECLARE @OutputColumnsDataType varchar(max)
DECLARE @OutputColumnsNull varchar(max)
DECLARE @OutputColumnsUpdate varchar(max)
DECLARE @OutputColumnsInsert varchar(max)
DECLARE @OutputPrimaryKeyColumn varchar(max) = (SELECT TOP 1 ColumnName FROM @TableInfo WHERE ColumnPosition = 1)
DECLARE @OutputDatasourceColumn varchar(max) = (SELECT TOP 1 ColumnName FROM @TableInfo WHERE ColumnName like '%DatasourceID')
DECLARE @CurrentRow int = 1
DECLARE @EndingRow int = (select max(ColumnPosition) from @TableInfo)

	WHILE @CurrentRow <= @EndingRow
		BEGIN
		SET @OutputColumns = CONCAT(@OutputColumns,CASE WHEN @CurrentRow > 1 THEN ',' END,(SELECT TOP 1 ColumnName FROM @TableInfo WHERE ColumnPosition = @CurrentRow), char(10), char(9)) 
		SET @OutputColumnsDataType = CONCAT(@OutputColumnsDataType,CASE WHEN @CurrentRow > 1 THEN ',' END,(SELECT TOP 1 CONCAT(ColumnName,' ',ColumnDataType) FROM @TableInfo WHERE ColumnPosition = @CurrentRow), char(10), char(9))
		SET @OutputColumnsNull = CONCAT(@OutputColumnsNull
											, CASE WHEN @CurrentRow = 1 THEN 'CONCAT(' + convert(varchar(10),@DatasourceID) + @PrimaryKeyDelimeter + ',<Insert record ID from Source here>) AS '
												   WHEN @CurrentRow = 2 THEN ',' + convert(varchar(10),@DatasourceID) + ' AS '
												   WHEN @CurrentRow = 3 THEN ',<Insert record ID from Source here> AS '
												   WHEN @CurrentRow > 1 THEN ',NULL AS ' END
											, (SELECT TOP 1 ColumnName FROM @TableInfo WHERE ColumnPosition = @CurrentRow)
											, char(10)
											, char(9))  
		SET @OutputColumnsUpdate = CONCAT(@OutputColumnsUpdate
											, CASE WHEN @CurrentRow > 1 THEN ',target.' ELSE 'target.' END
											, (SELECT TOP 1 ColumnName FROM @TableInfo WHERE ColumnPosition = @CurrentRow)
											, ' = source.'
											, (SELECT TOP 1 ColumnName FROM @TableInfo WHERE ColumnPosition = @CurrentRow)
											, char(10)
											, char(9))  
	    SET @OutputColumnsInsert = CONCAT(@OutputColumnsInsert,CASE WHEN @CurrentRow > 1 THEN ',source.' ELSE 'source.' END,(SELECT TOP 1 ColumnName FROM @TableInfo WHERE ColumnPosition = @CurrentRow), char(10), char(9)) 
		SET @CurrentRow = @CurrentRow + 1
		END

--PRINT @OutputColumns


SET @Output = --CONVERT(varchar(10),@DatasourceID) + ' ' + @DatasourceName
'
CREATE PROCEDURE ' + @Schema + '.spReload' + @DatasourceName + @Table + '_INCREMENTAL as
		
/* 
-- =============================================
-- Author:		Chris Cross
-- Create date: ' + CONVERT(varchar(100),GETDATE()) + '
-- Edit date:   
-- Description:	INCREMENTAL reload for ' + @Schema + '.' + @Table + ' from ' + @DatasourceName + '
-- ============================================= 
*/
BEGIN

/*-----INSERT INTO @StagingTable-----*/
	PRINT ''Creating @StagingTable....''
	DECLARE @StagingTable table 
	(' + @OutputColumnsDataType + 
		')
	
	PRINT ''Inserting records from Datasource into @StagingTable....''
	INSERT INTO @StagingTable 
	(' + @OutputColumns + ')

	SELECT
	' + @OutputColumnsNull + '
	FROM <insert source tables here>
	WHERE 1=1
		AND <Insert Incremental Date Column> between ' + @IncrementStartDate + ' AND ' + @IncrementEndDate + '

IF (SELECT COUNT(1) FROM @StagingTable) >= 10 
	BEGIN 
	PRINT ''At least 10 records exist in the staging table.  Proceed with delete and reload...''

/*-----DELETE/DEACTIVATE old records----*/
	PRINT ''Deleting records in Datasource....''
	DELETE FROM ' + @Schema + '.' + @Table + ' WHERE ' +  @OutputDatasourceColumn + ' = ' + convert(varchar(10),@DatasourceID) + ' AND <Insert Incremental Date Column> between ' + @IncrementStartDate + ' AND ' + @IncrementEndDate + '

/*-----UPDATE existing records----*/
/*----------Commented out for INCREMENTAL reload based on modified date range----------
	PRINT ''Updating records in Datasource from @StagingTable....''
	UPDATE target
	SET ' + @OutputColumnsUpdate + '
	FROM ' + @Schema + '.' + @Table + ' target
		INNER JOIN @StagingTable source ON source.' + @OutputPrimaryKeyColumn + ' = target.' + @OutputPrimaryKeyColumn + '
*/

/*-----INSERT new records-----*/
	PRINT ''Inserting new records in Datasource from @StagingTable....''
	INSERT INTO ' + @Schema + '.' + @TABLE + '
	(' + @OutputColumns + ')

	SELECT
	' + @OutputColumnsInsert + '
	FROM @StagingTable source
	--	LEFT JOIN ' + @Schema + '.' + @Table + ' target ON target.' + @OutputPrimaryKeyColumn + ' = source.' + @OutputPrimaryKeyColumn + '
	WHERE 1=1
	--	AND target.' + @OutputPrimaryKeyColumn + ' IS NULL 

	END

ELSE
	BEGIN
	PRINT ''Less than 10 records in the staging table. Ending job without delete and reload...''
	END

END
'

PRINT CAST(@Output AS NTEXT)
GO
