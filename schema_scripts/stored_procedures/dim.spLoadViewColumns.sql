CREATE PROCEDURE [dim].[spLoadViewColumns] AS
BEGIN
    SET NOCOUNT ON;

    -- Optional: truncate or refresh strategy
    TRUNCATE TABLE dim.ViewColumns;

    -- Create temp table to collect results
    IF OBJECT_ID('tempdb..#AllViewColumns') IS NOT NULL
        DROP TABLE #AllViewColumns;

    CREATE TABLE #AllViewColumns (
        ViewName NVARCHAR(255),
        ViewColumnName NVARCHAR(255),
        ViewColumnDataType NVARCHAR(50),
        ViewColumnMaxLength INT,
        ViewColumnIsNullable BIT,
        ViewColumnsLoadDatetime DATETIME,
        ViewID NVARCHAR(300)
    );

    DECLARE @dbName SYSNAME;
    DECLARE @sql NVARCHAR(MAX);

    DECLARE db_cursor CURSOR FOR
    SELECT name
    FROM sys.databases
    WHERE state = 0           -- ONLINE
      AND database_id > 4     -- Exclude system DBs
      AND name NOT IN ('distribution'); -- Optional: exclude replication DB

    OPEN db_cursor;
    FETCH NEXT FROM db_cursor INTO @dbName;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @sql = '
        INSERT INTO #AllViewColumns (
            ViewName,
            ViewColumnName,
            ViewColumnDataType,
            ViewColumnMaxLength,
            ViewColumnIsNullable,
            ViewColumnsLoadDatetime,
            ViewID
        )
        SELECT 
            v.name AS ViewName,
            c.name AS ViewColumnName,
            ty.name AS ViewColumnDataType,
            c.max_length,
            c.is_nullable,
            GETDATE() AS ViewColumnsLoadDatetime,
            ''' + @dbName + ''' + ''.'' + s.name + ''.'' + v.name AS ViewID
        FROM [' + @dbName + '].sys.views v
        JOIN [' + @dbName + '].sys.columns c ON v.object_id = c.object_id
        JOIN [' + @dbName + '].sys.schemas s ON v.schema_id = s.schema_id
        JOIN [' + @dbName + '].sys.types ty ON c.user_type_id = ty.user_type_id;
        ';
        
        EXEC sp_executesql @sql;

        FETCH NEXT FROM db_cursor INTO @dbName;
    END

    CLOSE db_cursor;
    DEALLOCATE db_cursor;

    -- Load into destination table
    INSERT INTO dim.ViewColumns
    SELECT * FROM #AllViewColumns;

END;
GO
