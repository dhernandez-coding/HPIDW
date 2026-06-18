IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'etl')
BEGIN
    EXEC('CREATE SCHEMA [etl]')
END
GO
