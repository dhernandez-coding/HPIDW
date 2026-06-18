IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'fact')
BEGIN
    EXEC('CREATE SCHEMA [fact]')
END
GO
