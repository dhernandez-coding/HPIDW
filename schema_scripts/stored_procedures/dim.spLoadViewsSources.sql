CREATE   PROCEDURE [dim].[spLoadViewsSources] AS
BEGIN
    SET NOCOUNT ON;

    -- Optional: refresh strategy
    TRUNCATE TABLE dim.ViewsSources;

    -- Create temp table
    IF OBJECT_ID('tempdb..#AllViewsSources') IS NOT NULL
        DROP TABLE #AllViewsSources;

    CREATE TABLE #AllViewsSources (
        ViewSchema NVARCHAR(255),
        ViewName NVARCHAR(255),
        ViewSourceSchemaName NVARCHAR(255),
        ViewSource NVARCHAR(255),
        ViewSourceLoadDatetime DATETIME,
        ViewID NVARCHAR(300),
        ViewSourceID NVARCHAR(300)
    );

    DECLARE @dbName SYSNAME;
    DECLARE @sql NVARCHAR(MAX);

    DECLARE db_cursor CURSOR FOR
    SELECT name
    FROM sys.databases
    WHERE state = 0           -- ONLINE
      AND database_id > 4     -- Exclude system DBs
      AND name NOT IN ('distribution');  -- Optional: exclude replication db

    OPEN db_cursor;
    FETCH NEXT FROM db_cursor INTO @dbName;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @sql = '
        INSERT INTO #AllViewsSources (
            ViewSchema,
            ViewName,
            ViewSourceSchemaName,
            ViewSource,
            ViewSourceLoadDatetime,
            ViewID,
            ViewSourceID
        )
        SELECT DISTINCT 
            s.name AS ViewSchema,
            v.name AS ViewName,
            d.referenced_schema_name AS ViewSourceSchemaName,
            d.referenced_entity_name AS ViewSource,
            GETDATE() AS ViewSourceLoadDatetime,
            ''' + @dbName + ''' + ''.'' + s.name + ''.'' + v.name AS ViewID,
            ''' + @dbName + ''' + ''.'' + d.referenced_schema_name + ''.'' + d.referenced_entity_name AS ViewSourceID
        FROM [' + @dbName + '].sys.views v
        JOIN [' + @dbName + '].sys.schemas s ON v.schema_id = s.schema_id
        JOIN [' + @dbName + '].sys.sql_expression_dependencies d ON v.object_id = d.referencing_id
        WHERE d.referenced_id IS NOT NULL;
        ';

        EXEC sp_executesql @sql;

        FETCH NEXT FROM db_cursor INTO @dbName;
    END

    CLOSE db_cursor;
    DEALLOCATE db_cursor;

    -- Load to destination table
    INSERT INTO dim.ViewsSources
    SELECT * FROM #AllViewsSources;
END;
GO
