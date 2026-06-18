IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'rpt')
BEGIN
    EXEC('CREATE SCHEMA [rpt]')
END
GO
