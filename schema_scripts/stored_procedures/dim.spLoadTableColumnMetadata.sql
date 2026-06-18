CREATE   PROCEDURE [dim].[spLoadTableColumnMetadata]
AS
BEGIN
    SET NOCOUNT ON;

    -- Optional: refresh strategy
    TRUNCATE TABLE dim.TableColumn;

    INSERT INTO dim.TableColumn (
        TableDataBaseName,
        TableSchemaName,
        TableName,
        TableColumnName,
        TableDataType,
        TableMaxLength,
        TableIsNullable,
        TableIsIdentity,
        TableLastModifyDate,
        TableRowCount,
        LoadDatetime
    )
    SELECT 
        DB_NAME() AS TableDataBaseName,
        s.name AS TableSchemaName,
        t.name AS TableName,
        c.name AS TableColumnName,
        ty.name AS TableDataType,
        c.max_length AS TableMaxLength,
        c.is_nullable AS TableIsNullable,
        c.is_identity AS TableIsIdentity,
        o.modify_date AS TableLastModifyDate,
        ISNULL(rc.row_count, 0) AS TableRowCount,
        GETDATE() AS LoadDatetime
    FROM sys.columns c
    JOIN sys.tables t ON c.object_id = t.object_id
    JOIN sys.schemas s ON t.schema_id = s.schema_id
    JOIN sys.types ty ON c.user_type_id = ty.user_type_id
    JOIN sys.objects o ON o.object_id = t.object_id

    -- Estimated row count (metadata-based)
    LEFT JOIN (
        SELECT 
            p.object_id,
            SUM(p.rows) AS row_count
        FROM sys.partitions p
        WHERE p.index_id IN (0, 1)  -- Clustered index or heap
        GROUP BY p.object_id
    ) rc ON t.object_id = rc.object_id

    ORDER BY s.name, t.name, c.column_id;
END;
GO
