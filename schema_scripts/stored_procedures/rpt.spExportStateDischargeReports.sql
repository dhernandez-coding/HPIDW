/*
================================================================================
 rpt.spExportStateDischargeReports
================================================================================
 Runs spSelectStateDischargeReportOP / IP / ED for each of the three
 facilities (9 runs) and writes each result to its own XML file:

     StateReport_<OP|ED|IP>_<CHN|CHS|NWSH>_Discharged_<M><YYYY>.xml
     e.g. StateReport_OP_CHN_Discharged_82026.xml  (August 2026; month has no
     leading zero). The month/year come from @startdate.

 Usage (@ExportPath defaults to the State Report\Exports share; pass another
 folder to override. Re-running a month OVERWRITES that month's files):
     -- 1) Dry run first: lists the 9 files it WOULD write, runs nothing
     EXEC rpt.spExportStateDischargeReports @DryRun = 1;

     -- 2) Real run, prior month (default)
     EXEC rpt.spExportStateDischargeReports;

     -- 3) A specific month (note the end date - see below)
     EXEC rpt.spExportStateDischargeReports
          @startdate = '2026-07-01', @enddate = '2026-08-01';

 FORMATTING: bcp writes the XML as a single line. With @PrettyPrint = 1 (default)
 each file is re-saved indented (2 spaces) by a PowerShell one-liner run through
 xp_cmdshell; content, UTF-8 encoding and the absence of an XML declaration are
 unchanged. If that step fails the file is kept as-is and the row reads
 'WRITTEN - NOT FORMATTED'. Set @PrettyPrint = 0 to skip it.

 PROC NAMES: calls rpt.spSelectStateDischargeReportOP / ED / IP. If the procs
 still carry a suffix (e.g. spSelectStateDischargeReportED_NEW), pass
 @ProcSuffix = N'_NEW'. The dry run flags any proc it cannot find.

 DATE CONVENTION: the discharge procs filter DISCH_DATE_TIME <= @enddate, and
 a date with no time is midnight at the START of that day. So @enddate must be
 the FIRST day of the following month (which is what the procs' own defaults
 use). Passing the last day of the month (e.g. 2026-07-31) drops every
 discharge on the 31st. This proc defaults to prior month on that convention.

 KNOWN ISSUE IN THE SELECT PROCS (not changed here): their own NULL-date
 defaults build the dates with YEAR(GETDATE()) and prior-month + 1, which
 breaks in January (month 13 -> DATEFROMPARTS error, and the start date lands
 in the wrong year). This proc always passes explicit dates, so it is not
 affected, but the procs themselves should be fixed before anyone relies on
 their defaults in January.

 HOW THE FILES ARE WRITTEN
   1. Each select proc is run with INSERT ... EXEC into a global temp table
      (##StateDischargeExport_<spid>) so the record count can be read from the
      XML trailer and bcp never has to describe the proc's result set itself.
   2. bcp queryout writes that XML (UTF-8) to @ExportPath via xp_cmdshell.
   Requirements: bcp installed on the SQL Server, and the account that
   xp_cmdshell runs as (service account, or the proxy account if one is
   configured) must be able to write to @ExportPath and log in to this
   instance (bcp uses -T).

   XP_CMDSHELL: on a real run the proc turns xp_cmdshell ON itself, but only if
   it is currently off, and puts it back afterwards (also if the run errors).
   If it was already on, it is left on. 'show advanced options' is restored the
   same way. The login that runs the proc (or the Agent job owner) needs
   sysadmin / ALTER SETTINGS permission to do this. A dry run changes no
   settings. If the settings cannot be put back, the proc ends with an error
   saying so - turn xp_cmdshell off manually in that case.

 SHAREPOINT: SQL Server cannot write to SharePoint itself. Point @ExportPath at
 a folder on or reachable from the SQL Server, then move the files to the
 library from there (SQL Agent PowerShell step, Power Automate, or a synced
 folder).

 If bcp complains about -C 65001 (client tools older than SQL Server 2016),
 replace "-c -C 65001" in the command below with "-w" (UTF-16 output).
================================================================================
*/

CREATE   PROCEDURE [rpt].[spExportStateDischargeReports]
	 @ExportPath nvarchar(260) = N'\\hpillc.org\shared\Corporate\Decision Support\Analytics\State Report\Exports'
	,@startdate  datetime = NULL
	,@enddate    datetime = NULL
	,@SkipEmpty  bit      = 0   -- 1 = don't write a file when the report has 0 records
	,@DryRun     bit      = 0   -- 1 = list the files only; run nothing, write nothing
	,@ProcSuffix nvarchar(20) = N''  -- e.g. N'_NEW' to call spSelectStateDischargeReportOP_NEW etc.
	,@PrettyPrint bit     = 1   -- 1 = re-save each file indented (PowerShell via xp_cmdshell); 0 = leave as one line
AS
BEGIN
SET NOCOUNT ON;

IF @ExportPath IS NULL OR LTRIM(RTRIM(@ExportPath)) = N''
	THROW 50001, N'@ExportPath is required: a folder the SQL Server (xp_cmdshell) account can write to.', 1;

IF RIGHT(@ExportPath, 1) = N'\'
	SET @ExportPath = LEFT(@ExportPath, LEN(@ExportPath) - 1);

-- Default period = prior calendar month; end date = first day of current month
SET @startdate = ISNULL(@startdate, DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 1, 0));
SET @enddate   = ISNULL(@enddate,   DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0));

/* ------------------------------------------------------------
   The 9 jobs: every report type x every facility
   ------------------------------------------------------------ */
CREATE TABLE #Jobs (
	JobID      int IDENTITY(1,1) PRIMARY KEY,
	ReportType char(2)        NOT NULL,
	ProcName   sysname        NOT NULL,
	Location   int            NOT NULL,
	Facility   varchar(10)    NOT NULL,
	FileName   nvarchar(260)  NOT NULL,
	Records    int            NULL,
	Status     varchar(30)    NULL,
	Message    nvarchar(4000) NULL
);

DECLARE @period varchar(6) = CAST(MONTH(@startdate) AS varchar(2)) + CAST(YEAR(@startdate) AS varchar(4));   -- M + YYYY, no leading zero (8 + 2026 = 82026)

INSERT INTO #Jobs (ReportType, ProcName, Location, Facility, FileName)
SELECT r.ReportType
	  ,N'spSelectStateDischargeReport' + r.ReportType + ISNULL(@ProcSuffix, N'')
	  ,f.Location
	  ,f.Facility
	  ,N'StateReport_' + r.ReportType + N'_' + f.Facility + N'_Discharged_' + @period + N'.xml'
FROM (VALUES ('OP', 1), ('ED', 2), ('IP', 3)) AS r(ReportType, Ord)
CROSS JOIN (VALUES (43004001, 'CHN', 1), (43005005, 'CHS', 2), (43006001, 'NWSH', 3)) AS f(Location, Facility, Ord)
ORDER BY f.Ord, r.Ord;

/* ------------------------------------------------------------
   Run each job
   ------------------------------------------------------------ */
DECLARE @stage     sysname = N'##StateDischargeExport_' + CAST(@@SPID AS nvarchar(10));
DECLARE @JobID     int = 0;
DECLARE @MaxJobID  int = (SELECT MAX(JobID) FROM #Jobs);
DECLARE @ProcName  sysname;
DECLARE @Location  int;
DECLARE @FileName  nvarchar(260);
DECLARE @FullPath  nvarchar(520);
DECLARE @sql       nvarchar(max);
DECLARE @cmd       nvarchar(4000);
DECLARE @rc        int;
DECLARE @records   int;
DECLARE @msg       nvarchar(4000);
DECLARE @fmtNote   nvarchar(1000);

CREATE TABLE #CmdOut (Line nvarchar(4000) NULL);

-- Remember the current xp_cmdshell settings so they can be put back exactly as found
DECLARE @prevAdv     int = CONVERT(int, (SELECT value_in_use FROM sys.configurations WHERE name = N'show advanced options'));
DECLARE @prevXp      int = CONVERT(int, (SELECT value_in_use FROM sys.configurations WHERE name = N'xp_cmdshell'));
DECLARE @changedAdv  bit = 0;
DECLARE @changedXp   bit = 0;
DECLARE @err         nvarchar(2000) = NULL;
DECLARE @restoreErr  nvarchar(2000) = NULL;

BEGIN TRY

	IF @DryRun = 0 AND @prevXp = 0
	BEGIN
		IF @prevAdv = 0
		BEGIN
			EXEC sp_configure 'show advanced options', 1;
			RECONFIGURE;
			SET @changedAdv = 1;
		END
		EXEC sp_configure 'xp_cmdshell', 1;
		RECONFIGURE;
		SET @changedXp = 1;
	END

WHILE @JobID < @MaxJobID
BEGIN
	SET @JobID += 1;
	SET @records = NULL;

	SELECT @ProcName = ProcName, @Location = Location, @FileName = FileName
	FROM #Jobs WHERE JobID = @JobID;

	SET @FullPath = @ExportPath + N'\' + @FileName;

	IF @DryRun = 1
	BEGIN
		UPDATE #Jobs
		SET Status  = CASE WHEN OBJECT_ID(N'rpt.' + QUOTENAME(@ProcName), N'P') IS NULL THEN 'PROC NOT FOUND' ELSE 'DRY RUN' END
		   ,Message = N'rpt.' + @ProcName + N'  ->  ' + @FullPath
		WHERE JobID = @JobID;
		CONTINUE;
	END

	BEGIN TRY
		-- Fresh global staging table (global so bcp's separate connection can read it)
		-- (EXEC (...) cannot contain function calls such as QUOTENAME, so build the SQL in @sql first)
		SET @sql = N'DROP TABLE ' + QUOTENAME(@stage);
		IF OBJECT_ID(N'tempdb..' + @stage) IS NOT NULL
			EXEC sp_executesql @sql;
		SET @sql = N'CREATE TABLE ' + QUOTENAME(@stage) + N' (x xml NULL)';
		EXEC sp_executesql @sql;

		-- Run the report for this facility
		SET @sql = N'INSERT INTO ' + QUOTENAME(@stage) + N' (x) EXEC rpt.' + QUOTENAME(@ProcName)
				 + N' @startdate = @s, @enddate = @e, @Location = @l;';
		EXEC sp_executesql @sql
			,N'@s datetime, @e datetime, @l int'
			,@s = @startdate, @e = @enddate, @l = @Location;

		-- Record count from the XML trailer
		SET @sql = N'SELECT @r = x.value(''(/hci_data/trailer/total_records)[1]'', ''int'') FROM '
				 + QUOTENAME(@stage) + N';';
		EXEC sp_executesql @sql, N'@r int OUTPUT', @r = @records OUTPUT;

		IF @records IS NULL
			THROW 50010, N'Report returned no XML, or the trailer/total_records node was missing.', 1;

		IF @records = 0 AND @SkipEmpty = 1
		BEGIN
			UPDATE #Jobs SET Records = 0, Status = 'SKIPPED', Message = N'0 records - file not written'
			WHERE JobID = @JobID;
			CONTINUE;
		END

		-- Write the file
		SET @cmd = N'bcp "SELECT x FROM ' + QUOTENAME(@stage) + N'" queryout "' + @FullPath
				 + N'" -S "' + @@SERVERNAME + N'" -T -c -C 65001';

		DELETE FROM #CmdOut;
		INSERT INTO #CmdOut (Line) EXEC @rc = master.dbo.xp_cmdshell @cmd;

		IF @rc <> 0 OR NOT EXISTS (SELECT 1 FROM #CmdOut WHERE Line LIKE N'%rows copied%')
		BEGIN
			SET @msg = (SELECT STRING_AGG(CAST(Line AS nvarchar(max)), N' | ') FROM #CmdOut WHERE Line IS NOT NULL);
			SET @msg = N'bcp failed (rc=' + ISNULL(CAST(@rc AS nvarchar(10)), N'?') + N'): ' + ISNULL(LEFT(@msg, 1800), N'');
			THROW 50011, @msg, 1;
		END

		-- Optional: re-save the file indented. bcp writes the XML as one line.
		-- Non-fatal: if this step fails the file is still valid XML, just not indented.
		SET @fmtNote = NULL;
		IF @PrettyPrint = 1
		BEGIN
			SET @cmd = N'powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "'
					 + N'$ErrorActionPreference=''Stop''; $p=''' + REPLACE(@FullPath, N'''', N'''''') + N'''; '
					 + N'$d=New-Object System.Xml.XmlDocument; $d.Load($p); '
					 + N'$s=New-Object System.Xml.XmlWriterSettings; $s.Indent=$true; $s.IndentChars=''  ''; $s.OmitXmlDeclaration=$true; '
					 + N'$s.Encoding=New-Object System.Text.UTF8Encoding($false); '
					 + N'$w=[System.Xml.XmlWriter]::Create($p,$s); $d.Save($w); $w.Close()"';

			DELETE FROM #CmdOut;
			INSERT INTO #CmdOut (Line) EXEC @rc = master.dbo.xp_cmdshell @cmd;

			IF @rc <> 0
			BEGIN
				SET @fmtNote = (SELECT STRING_AGG(CAST(Line AS nvarchar(max)), N' | ') FROM #CmdOut WHERE Line IS NOT NULL);
				SET @fmtNote = N'formatting step failed (rc=' + ISNULL(CAST(@rc AS nvarchar(10)), N'?') + N'): ' + ISNULL(LEFT(@fmtNote, 600), N'');
			END
		END

		UPDATE #Jobs
		SET Records = @records
		   ,Status  = CASE WHEN @fmtNote IS NULL THEN 'WRITTEN' ELSE 'WRITTEN - NOT FORMATTED' END
		   ,Message = @FullPath + ISNULL(N'   |   ' + @fmtNote, N'')
		WHERE JobID = @JobID;
	END TRY
	BEGIN CATCH
		UPDATE #Jobs SET Records = @records, Status = 'FAILED', Message = LEFT(ERROR_MESSAGE(), 4000)
		WHERE JobID = @JobID;
	END CATCH
END

END TRY
BEGIN CATCH
	SET @err = N'Export stopped unexpectedly: ' + LEFT(ERROR_MESSAGE(), 1900);
END CATCH

-- Put xp_cmdshell back the way it was found (runs whether or not the export succeeded)
BEGIN TRY
	IF @changedXp = 1
	BEGIN
		EXEC sp_configure 'xp_cmdshell', 0;
		RECONFIGURE;
	END
	IF @changedAdv = 1
	BEGIN
		EXEC sp_configure 'show advanced options', 0;
		RECONFIGURE;
	END
END TRY
BEGIN CATCH
	SET @restoreErr = N'Export finished, but xp_cmdshell could NOT be set back to its original setting - turn it off manually. ' + LEFT(ERROR_MESSAGE(), 1500);
END CATCH

SET @sql = N'DROP TABLE ' + QUOTENAME(@stage);
IF OBJECT_ID(N'tempdb..' + @stage) IS NOT NULL
	EXEC sp_executesql @sql;

/* ------------------------------------------------------------
   Summary, then fail loudly if anything failed (so an Agent job step fails)
   ------------------------------------------------------------ */
SELECT ReportType, Facility, Location, FileName, Records, Status, Message
FROM #Jobs
ORDER BY JobID;

IF @err IS NOT NULL
	THROW 50030, @err, 1;

IF @restoreErr IS NOT NULL
	THROW 50031, @restoreErr, 1;

IF EXISTS (SELECT 1 FROM #Jobs WHERE Status = 'FAILED')
	THROW 50020, N'One or more state discharge exports failed - see the result set for details.', 1;

END
GO
