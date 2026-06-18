-- =============================================
-- Author:      Diego Hernandez
-- Create date: 06/03/2025
-- Description: Loads metadata for all user tables from all databases
-- =============================================
CREATE PROCEDURE [dim].[spLoadDWTable]
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('tempdb..#AllTablesMetadata') IS NOT NULL
        DROP TABLE #AllTablesMetadata;

    CREATE TABLE #AllTablesMetadata (
        database_name SYSNAME,
        schema_name   SYSNAME,
        table_name    SYSNAME,
        create_date   DATETIME,
        modify_date   DATETIME
    );

    DECLARE @dbName SYSNAME;
    DECLARE db_cursor CURSOR FOR
        SELECT name 
        FROM sys.databases 
        WHERE state = 0 -- ONLINE
          AND database_id > 4; -- exclude system databases

    OPEN db_cursor;
    FETCH NEXT FROM db_cursor INTO @dbName;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE @sql NVARCHAR(MAX);
        SET @sql = '
        INSERT INTO #AllTablesMetadata
        SELECT 
            ''' + @dbName + ''' AS database_name,
            s.name AS schema_name,
            t.name AS table_name,
            t.create_date,
            t.modify_date
        FROM [' + @dbName + '].sys.tables t
        JOIN [' + @dbName + '].sys.schemas s ON t.schema_id = s.schema_id
        JOIN [' + @dbName + '].sys.objects o ON o.object_id = t.object_id
        WHERE t.is_ms_shipped = 0;';

        EXEC sp_executesql @sql;

        FETCH NEXT FROM db_cursor INTO @dbName;
    END

    CLOSE db_cursor;
    DEALLOCATE db_cursor;
	TRUNCATE TABLE dim.DWTables;
    -- Insert into destination table
    INSERT INTO dim.DWTables (DataBaseName, SchemaName, TableName, CreateDatetime, LastModifiedDatetime, TableID)
    SELECT 
        database_name,
        schema_name,
        table_name,
        create_date,
        modify_date,
		CONCAT(database_name,'.',schema_name,'.',table_name)
    FROM #AllTablesMetadata;
END
GO
