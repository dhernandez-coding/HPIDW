/*==============================================================================
  rpt.spExportAJRRProcedures2027
  Runs rpt.spSelectAJRRProcedures2027 and writes the result as a CSV file:
      \\hpillc.org\shared\Everyone\Data_Hub\Hospital\AJRR\AJRR_MM.DD.YYYY.csv
  (run date; a rerun on the same day overwrites the file)

  CSV format
    - Header row with the exact Procedure Layout column names
    - Every value wrapped in double quotes (embedded quotes doubled), because
      AnesthesiaType ("1,2,5") and implant names can contain commas
    - UTF-8, CRLF line endings

  Requires
    - xp_cmdshell enabled
    - The SQL Server service account (the account xp_cmdshell runs as) needs
      write access to the AJRR share
    - CREATE TABLE permission in the rpt schema (staging tables are rebuilt
      each run): rpt.AJRRProcedures2027_Export, rpt.AJRRProcedures2027_CSV

  Usage
    EXEC rpt.spExportAJRRProcedures2027;
    EXEC rpt.spExportAJRRProcedures2027 @OutputFolder = N'\\some\other\folder';
==============================================================================*/
CREATE   PROCEDURE [rpt].[spExportAJRRProcedures2027]
     @OutputFolder NVARCHAR(400) = N'\\hpillc.org\shared\Everyone\Data_Hub\Hospital\AJRR'
    ,@RunDate      DATE          = NULL
AS
BEGIN
SET NOCOUNT ON;

DECLARE @FileDate CHAR(10)       = REPLACE(CONVERT(CHAR(10), ISNULL(@RunDate, GETDATE()), 110), '-', '.');  -- MM.DD.YYYY
DECLARE @FilePath NVARCHAR(500)  = @OutputFolder + N'\AJRR_' + @FileDate + N'.csv';
DECLARE @Header   NVARCHAR(MAX);
DECLARE @RowExpr  NVARCHAR(MAX);
DECLARE @sql      NVARCHAR(MAX);
DECLARE @cmd      VARCHAR(8000);
DECLARE @Rows     INT;

/*--- 1. Build the data ------------------------------------------------------*/
EXEC rpt.spSelectAJRRProcedures2027 @ExportToTable = 1;

SELECT @Rows = COUNT(*) FROM rpt.AJRRProcedures2027_Export;
IF @Rows = 0
BEGIN
    RAISERROR('rpt.spSelectAJRRProcedures2027 returned no rows; no file written.', 16, 1);
    RETURN;
END;

/*--- 2. Turn each row into one quoted CSV line ------------------------------*/
SELECT  @Header = STRING_AGG(CONVERT(NVARCHAR(MAX), N'"' + REPLACE(c.name, N'"', N'""') + N'"'), N',')
                      WITHIN GROUP (ORDER BY c.column_id)
       ,@RowExpr = STRING_AGG(CONVERT(NVARCHAR(MAX),
                      N'''"'' + REPLACE(ISNULL(CONVERT(NVARCHAR(MAX), ' + QUOTENAME(c.name) + N'), N''''), N''"'', N''""'') + N''"'''),
                      N' + N'','' + ')
                      WITHIN GROUP (ORDER BY c.column_id)
FROM sys.columns c
WHERE c.object_id = OBJECT_ID(N'rpt.AJRRProcedures2027_Export')
  AND c.name <> N'ExportRowNum';

DROP TABLE IF EXISTS rpt.AJRRProcedures2027_CSV;
CREATE TABLE rpt.AJRRProcedures2027_CSV (
     [LineNo] INT           NOT NULL PRIMARY KEY
    ,Line   NVARCHAR(MAX) NOT NULL
);

INSERT INTO rpt.AJRRProcedures2027_CSV ([LineNo], Line) VALUES (0, @Header);

SET @sql = N'INSERT INTO rpt.AJRRProcedures2027_CSV (LineNo, Line)
SELECT ExportRowNum, ' + @RowExpr + N'
FROM rpt.AJRRProcedures2027_Export;';
EXEC sp_executesql @sql;

/*--- 3. Write the file with bcp ---------------------------------------------*/
SET @cmd = 'bcp "SELECT Line FROM ' + DB_NAME() + '.rpt.AJRRProcedures2027_CSV ORDER BY LineNo" queryout "'
         + CONVERT(VARCHAR(500), @FilePath) + '" -c -C 65001 -T -S "' + @@SERVERNAME + '"';

DECLARE @Out TABLE (Line NVARCHAR(4000));
INSERT INTO @Out EXEC master..xp_cmdshell @cmd;

IF EXISTS (SELECT 1 FROM @Out WHERE Line LIKE '%Error%' OR Line LIKE '%Unable to open%' OR Line LIKE '%Access is denied%')
BEGIN
    SELECT Line AS bcp_output FROM @Out WHERE Line IS NOT NULL;
    RAISERROR('bcp failed writing %s. See bcp_output result set.', 16, 1, @FilePath);
    RETURN;
END;

SELECT @Rows AS RowsExported, @FilePath AS FileWritten;
END
GO
