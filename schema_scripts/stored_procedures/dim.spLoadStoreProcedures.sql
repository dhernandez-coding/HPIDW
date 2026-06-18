CREATE PROCEDURE [dim].[spLoadStoreProcedures] AS
BEGIN
    SET NOCOUNT ON;

    -- Create global temp table accessible from all DBs during the session
    IF OBJECT_ID('tempdb..##AllProcedures') IS NOT NULL DROP TABLE ##AllProcedures;

    CREATE TABLE ##AllProcedures (
        StoreProcedureID VARCHAR(300),
        DatabaseName VARCHAR(100),
        SchemaName VARCHAR(50),
        ProcedureName VARCHAR(200),
        Definition VARCHAR(MAX),
        CreateDate DATETIME,
        ModifyDate DATETIME
    );

    DECLARE @DatabaseName SYSNAME;
    DECLARE @SQL NVARCHAR(MAX);

    DECLARE db_cursor CURSOR FOR
    SELECT name
    FROM sys.databases
    WHERE state_desc = 'ONLINE'
      AND name NOT IN ('master', 'tempdb', 'model', 'msdb');

    OPEN db_cursor;
    FETCH NEXT FROM db_cursor INTO @DatabaseName;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @SQL = '
        INSERT INTO ##AllProcedures (
            StoreProcedureID,
            DatabaseName,
            SchemaName,
            ProcedureName,
            Definition,
            CreateDate,
            ModifyDate
        )
        SELECT  
            CONCAT(s.name, ''.'', p.name) AS StoreProcedureID,
            ''' + @DatabaseName + ''' AS DatabaseName,
            s.name AS SchemaName,
            p.name AS ProcedureName,
            m.definition AS Definition,
            p.create_date AS CreateDate,
            p.modify_date AS ModifyDate
        FROM [' + @DatabaseName + '].sys.procedures p
        INNER JOIN [' + @DatabaseName + '].sys.schemas s ON p.schema_id = s.schema_id
        LEFT JOIN [' + @DatabaseName + '].sys.sql_modules m ON p.object_id = m.object_id;';

        EXEC sp_executesql @SQL;
        FETCH NEXT FROM db_cursor INTO @DatabaseName;
    END

    CLOSE db_cursor;
    DEALLOCATE db_cursor;

    -- Insert from global temp table into your actual table
    TRUNCATE TABLE dim.StoreProcedures;

    INSERT INTO dim.StoreProcedures (
        StoreProcedureID,
        DatabaseName,
        SchemaName,
        ProcedureName,
        Definition,
        CreateDate,
        ModifyDate
    )
    SELECT
        StoreProcedureID,
        DatabaseName,
        SchemaName,
        ProcedureName,
        Definition,
        CreateDate,
        ModifyDate
    FROM ##AllProcedures;

    -- Clean up
    DROP TABLE ##AllProcedures;
END;
GO
