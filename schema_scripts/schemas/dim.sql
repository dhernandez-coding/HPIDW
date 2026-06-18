IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'dim')
BEGIN
    EXEC('CREATE SCHEMA [dim]')
END
GO
