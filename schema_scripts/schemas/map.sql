IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'map')
BEGIN
    EXEC('CREATE SCHEMA [map]')
END
GO
