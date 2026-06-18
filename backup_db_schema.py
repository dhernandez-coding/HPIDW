import os
import sys
import shutil
import pyodbc

# Connection details
SERVER = "CORVMDB10"
DATABASE = "HPIDW"
CONNECTION_STRING = f"DRIVER={{ODBC Driver 17 for SQL Server}};SERVER={SERVER};DATABASE={DATABASE};Trusted_Connection=yes;"

# Output directories setup
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
OUTPUT_DIR = os.path.join(BASE_DIR, "schema_scripts")

CATEGORIES = {
    "schemas": "schemas",
    "tables": "tables",
    "views": "views",
    "stored_procedures": "stored_procedures",
    "functions": "functions"
}

def clean_and_prepare_dirs():
    """Ensure output folders exist and are empty of old SQL files to prevent orphaned files."""
    print("Preparing output directories...")
    if os.path.exists(OUTPUT_DIR):
        # We delete only the subfolders to preserve the main output folder
        for cat_dir in CATEGORIES.values():
            full_path = os.path.join(OUTPUT_DIR, cat_dir)
            if os.path.exists(full_path):
                shutil.rmtree(full_path)
    
    # Recreate all directories
    for cat_dir in CATEGORIES.values():
        os.makedirs(os.path.join(OUTPUT_DIR, cat_dir), exist_ok=True)

def generate_schema_ddls(cursor):
    """Scripts DDL for user schemas that contain objects."""
    print("Scripting schemas...")
    cursor.execute("""
        SELECT s.name
        FROM sys.schemas s
        JOIN sys.objects o ON s.schema_id = o.schema_id
        WHERE o.is_ms_shipped = 0 AND o.type IN ('U', 'V', 'P', 'FN', 'TF', 'IF')
        GROUP BY s.name
        ORDER BY s.name
    """)
    schemas = [r[0] for r in cursor.fetchall()]
    
    for schema in schemas:
        # Avoid scripting sys-like schemas
        if schema in ('sys', 'INFORMATION_SCHEMA'):
            continue
            
        ddl = f"""IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = '{schema}')
BEGIN
    EXEC('CREATE SCHEMA [{schema}]')
END
GO
"""
        file_path = os.path.join(OUTPUT_DIR, CATEGORIES["schemas"], f"{schema}.sql")
        with open(file_path, "w", encoding="utf-8") as f:
            f.write(ddl)

def generate_table_ddl(cursor, schema_name, table_name):
    """Dynamically generates high-fidelity CREATE TABLE statement from metadata."""
    # Query column details
    cursor.execute("""
        SELECT 
            c.name AS column_name,
            t.name AS data_type,
            c.max_length,
            c.precision,
            c.scale,
            c.is_nullable,
            c.is_identity,
            CAST(ic.seed_value AS NUMERIC(38,0)) AS seed_value,
            CAST(ic.increment_value AS NUMERIC(38,0)) AS increment_value,
            CAST(dc.definition AS NVARCHAR(MAX)) AS default_definition
        FROM sys.columns c
        JOIN sys.types t ON c.user_type_id = t.user_type_id
        JOIN sys.tables tb ON c.object_id = tb.object_id
        JOIN sys.schemas s ON tb.schema_id = s.schema_id
        LEFT JOIN sys.identity_columns ic ON c.object_id = ic.object_id AND c.column_id = ic.column_id
        LEFT JOIN sys.default_constraints dc ON c.default_object_id = dc.object_id
        WHERE s.name = ? AND tb.name = ?
        ORDER BY c.column_id
    """, (schema_name, table_name))
    columns = cursor.fetchall()
    
    if not columns:
        return None
        
    ddl_lines = []
    for col in columns:
        col_name, data_type, max_len, prec, scale, is_nullable, is_identity, seed, incr, default_def = col
        
        # Resolve data type size formatting
        if data_type in ('varchar', 'char', 'nvarchar', 'nchar', 'varbinary', 'binary'):
            if max_len == -1:
                size = 'MAX'
            else:
                size = str(max_len if data_type not in ('nvarchar', 'nchar') else max_len // 2)
            type_str = f"{data_type}({size})"
        elif data_type in ('decimal', 'numeric'):
            type_str = f"{data_type}({prec},{scale})"
        else:
            type_str = data_type
            
        col_def = f"    [{col_name}] {type_str.upper()}"
        
        if is_identity:
            col_def += f" IDENTITY({int(seed)},{int(incr)})"
            
        if not is_nullable:
            col_def += " NOT NULL"
        else:
            col_def += " NULL"
            
        if default_def:
            col_def += f" DEFAULT {default_def}"
            
        ddl_lines.append(col_def)
        
    # Query primary key constraint
    cursor.execute("""
        SELECT 
            i.name AS pk_name,
            COL_NAME(ic.object_id, ic.column_id) AS column_name
        FROM sys.indexes i
        JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
        JOIN sys.tables tb ON i.object_id = tb.object_id
        JOIN sys.schemas s ON tb.schema_id = s.schema_id
        WHERE s.name = ? AND tb.name = ? AND i.is_primary_key = 1
        ORDER BY ic.key_ordinal
    """, (schema_name, table_name))
    pk_cols = cursor.fetchall()
    
    if pk_cols:
        pk_name = pk_cols[0][0]
        pk_col_list = ", ".join([f"[{c[1]}]" for c in pk_cols])
        ddl_lines.append(f"    CONSTRAINT [{pk_name}] PRIMARY KEY ({pk_col_list})")
        
    ddl = f"CREATE TABLE [{schema_name}].[{table_name}] (\n" + ",\n".join(ddl_lines) + "\n);\nGO\n"
    return ddl

def script_tables(cursor):
    """Scripts all user tables."""
    print("Scripting tables...")
    cursor.execute("""
        SELECT s.name AS schema_name, t.name AS table_name
        FROM sys.tables t
        JOIN sys.schemas s ON t.schema_id = s.schema_id
        WHERE t.is_ms_shipped = 0
        ORDER BY s.name, t.name
    """)
    tables = cursor.fetchall()
    
    for schema_name, table_name in tables:
        ddl = generate_table_ddl(cursor, schema_name, table_name)
        if ddl:
            file_name = f"{schema_name}.{table_name}.sql"
            file_path = os.path.join(OUTPUT_DIR, CATEGORIES["tables"], file_name)
            with open(file_path, "w", encoding="utf-8") as f:
                f.write(ddl)

def script_modules(cursor):
    """Scripts views, stored procedures, and functions from sys.sql_modules."""
    print("Scripting views, stored procedures, and functions...")
    cursor.execute("""
        SELECT 
            s.name AS schema_name,
            o.name AS object_name,
            o.type_desc,
            sm.definition
        FROM sys.sql_modules sm
        JOIN sys.objects o ON sm.object_id = o.object_id
        JOIN sys.schemas s ON o.schema_id = s.schema_id
        WHERE o.is_ms_shipped = 0
        ORDER BY o.type_desc, s.name, o.name
    """)
    objects = cursor.fetchall()
    
    for schema_name, object_name, type_desc, definition in objects:
        if not definition:
            continue
            
        # Standardize file naming
        file_name = f"{schema_name}.{object_name}.sql"
        
        # Route to correct folder
        if type_desc == "VIEW":
            folder = CATEGORIES["views"]
        elif type_desc == "SQL_STORED_PROCEDURE":
            folder = CATEGORIES["stored_procedures"]
        elif type_desc in ("SQL_SCALAR_FUNCTION", "SQL_TABLE_VALUED_FUNCTION", "SQL_INLINE_TABLE_VALUED_FUNCTION"):
            folder = CATEGORIES["functions"]
        else:
            # Fallback for any other modules
            folder = CATEGORIES["functions"]
            
        # Ensure definition has a GO at the end for clean SQL execution context
        clean_definition = definition.strip()
        
        # Redact client secrets to prevent GitHub push protection blocks
        import re
        clean_definition = re.sub(
            r"(@ClientSecret\s+NVARCHAR\(\d+\)\s*=\s*)[N]?'[^']+'", 
            r"\1N'********'", 
            clean_definition, 
            flags=re.IGNORECASE
        )
        
        if not clean_definition.upper().endswith("GO"):
            clean_definition += "\nGO\n"
        else:
            clean_definition += "\n"
            
        file_path = os.path.join(OUTPUT_DIR, folder, file_name)
        with open(file_path, "w", encoding="utf-8") as f:
            f.write(clean_definition)

def main():
    print(f"Connecting to database {DATABASE} on {SERVER}...")
    try:
        conn = pyodbc.connect(CONNECTION_STRING)
        cursor = conn.cursor()
    except Exception as e:
        print(f"Error connecting to database: {e}")
        sys.exit(1)
        
    clean_and_prepare_dirs()
    
    try:
        generate_schema_ddls(cursor)
        script_tables(cursor)
        script_modules(cursor)
        print("\nBackup completed successfully!")
    except Exception as e:
        print(f"An error occurred during execution: {e}")
        sys.exit(1)
    finally:
        if 'cursor' in locals():
            cursor.close()
        if 'conn' in locals():
            conn.close()

if __name__ == "__main__":
    main()
