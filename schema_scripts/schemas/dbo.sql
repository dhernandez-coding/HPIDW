IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'dbo')
BEGIN
    EXEC('CREATE SCHEMA [dbo]')
END
GO
