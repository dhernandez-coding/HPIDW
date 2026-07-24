IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'hero')
BEGIN
    EXEC('CREATE SCHEMA [hero]')
END
GO
