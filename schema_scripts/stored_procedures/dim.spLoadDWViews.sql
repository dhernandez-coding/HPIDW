CREATE   PROCEDURE  [dim].[spLoadDWViews] AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('tempdb..#AllViewsMetadata') IS NOT NULL
        DROP TABLE #AllViewsMetadata;

    CREATE TABLE #AllViewsMetadata (
        database_name SYSNAME,
        schema_name   SYSNAME,
        view_name     SYSNAME,
        create_date   DATETIME,
        modify_date   DATETIME
    );

    DECLARE @dbName SYSNAME;
    DECLARE @sql NVARCHAR(MAX);

    DECLARE db_cursor CURSOR FOR
    SELECT name 
    FROM sys.databases 
    WHERE state = 0 -- ONLINE
      AND database_id > 4; -- exclude system databases

    OPEN db_cursor;
    FETCH NEXT FROM db_cursor INTO @dbName;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @sql = '
        INSERT INTO #AllViewsMetadata
        SELECT 
            ''' + @dbName + ''' AS database_name,
            s.name AS schema_name,
            v.name AS view_name,
            v.create_date,
            v.modify_date
        FROM [' + @dbName + '].sys.views v
        JOIN [' + @dbName + '].sys.schemas s ON v.schema_id = s.schema_id';

        EXEC sp_executesql @sql;

        FETCH NEXT FROM db_cursor INTO @dbName;
    END

    CLOSE db_cursor;
    DEALLOCATE db_cursor;
	TRUNCATE TABLE dim.DWViews;
    -- Insert into permanent table
    INSERT INTO dim.DWViews (
        DataBaseName, SchemaName, ViewName, 
        CreateDatetime, ViewLastModifiedDatetime, 
        LoadDatetime, ViewID
    )
    SELECT 
        database_name,
        schema_name,
        view_name,
        create_date,
        modify_date,
        GETDATE(),
		CONCAT(database_name,'.',schema_name,'.',view_name)
    FROM #AllViewsMetadata;
END
GO
