CREATE PROCEDURE [dbo].[ExportDischageReports]

	@location INT 
    ,@Month INT
	,@Year INT
    ,@LengthOfReportInMonths INT	
	,@ExportLocation varchar(1024)
AS
Begin
-- Notes
--available locations
--43004001 --HPI CHN
--43005005 --HPI CHS
--43006001 --HPI NWSH
--example output path format, must prefix and suffix with a \  (backslash)
--\c\folder\locationyouwant\
--For Testing
--Declare 
--	@location INT  = 43004001
--    ,@Month INT = 7
--	,@Year INT = 2024
--    ,@LengthOfReportInMonths INT = 1
--	--,@ExportLocation varchar(1024) = '\\hpillc.org\persona\profiles\lrichardson.HPILLC\Documents\'
--	,@ExportLocation varchar(1024) = null
--For Testing


-- To allow advanced options to be changed.
EXEC sp_configure 'show advanced options', 1

-- To update the currently configured value for advanced options.
RECONFIGURE

-- To enable the feature.
EXEC sp_configure 'xp_cmdshell', 1

-- To update the currently configured value for this feature.
RECONFIGURE


DECLARE @LocationName varchar(100) = (SELECT case when @location = 43004001 then 'Community Hospital North'
												  when @location = 43005005 then 'Community Hospital South'
												  when @location = 43006001 then 'Northwest Surgical Hospital' end)
--want a more dynamic way to find that actual location
DECLARE @LocationNameForFile varchar(100) = (SELECT case when @location = 43004001 then 'CHN'
												  when @location = 43005005 then 'CHS'
												  when @location = 43006001 then 'NWSH' end)
Declare @ServerName varchar(64) = @@SERVERNAME
Declare @DatabaseName varchar(64) = DB_NAME()
--Null check 
Set @ExportLocation = ISNULL(@ExportLocation, '\\hpillc.org\shared\Corporate\Decision Support\Analytics\State Report\Exports\');
--if value is missing default to 1 month
Set @LengthOfReportInMonths = ISNULL(@LengthOfReportInMonths, 1);
-- if values are missing default to current month

SET @Month = ISNULL(@Month,Month(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 2, 0)));
SET @Year = ISNULL(@Year, YEAR(GETDATE()));

--Default to first of the month
DECLARE @StartDate DATE;
SET @StartDate = DATEFROMPARTS(@Year, @Month, 1);

DECLARE @EndDate DATE;
SET @EndDate = DATEFROMPARTS(@Year, @Month + @LengthOfReportInMonths, 1);

	-- Add the parameters for the stored procedure here
	--@Location int,
	--@startdate datetime,
	--@enddate datetime,
	--@reportingyear int,
	--@reportingperiod int
DECLARE @Parameters VARCHAR(4096) = 
    '@Location = ''' + CAST(@Location AS VARCHAR(MAX)) + '''' +
    ', @startdate = ''' + CAST(@startdate AS VARCHAR(MAX)) + '''' +
    ', @enddate = ''' + CAST(@enddate AS VARCHAR(MAX)) + '''' +
    ', @reportingyear = ''' + CAST(@Year AS VARCHAR(MAX)) + '''' +
    ', @reportingperiod = ''' + CAST(@Month AS VARCHAR(MAX)) + ''''

-- Gather the stored procedure names (ensure they are fully qualified)
DECLARE @EDReportStoredProcedure VARCHAR(4096) = '[rpt].[spSelectStateDischargeReportED_export]'
DECLARE @IPReportStoredProcedure VARCHAR(4096) = '[rpt].[spSelectStateDischargeReportIP_export]'
DECLARE @OPReportStoredProcedure VARCHAR(4096) = '[rpt].[spSelectStateDischargeReportOP_export]'

-- Create the file names
DECLARE @FileExtension VARCHAR(8) = '.xml'
DECLARE @FileSuffix VARCHAR(256) = @LocationNameForFile + '_Discharged_' + CAST(@Month AS VARCHAR(8)) + CAST(@Year AS VARCHAR(8)) + @FileExtension
DECLARE @EDFileName VARCHAR(128) = 'StateReport_ED_' + @FileSuffix
DECLARE @IPFileName VARCHAR(128) = 'StateReport_IP_' + @FileSuffix
DECLARE @OPFileName VARCHAR(128) = 'StateReport_OP_' + @FileSuffix

-- Build the sqlcmd command queries
DECLARE @Cmd VARCHAR(4096) = 'sqlcmd -S ' + @ServerName + ' -d ' + @DatabaseName + ' -E -Q "set nocount on;'

-- The correct approach is to execute the stored procedure first, then apply FOR XML PATH in the query
DECLARE @EDCmd VARCHAR(4096) = @Cmd + 
    'DECLARE @xmlResult XML; ' + 
    'SET @xmlResult = EXEC ' + @EDReportStoredProcedure + ' ' + @Parameters + ' ' + 
    'FOR XML PATH(''root''); ' + 
    'SELECT @xmlResult' + 
    '" -o "' + @ExportLocation + @EDFileName + '"'

DECLARE @IPCmd VARCHAR(4096) = @Cmd + 
    'DECLARE @xmlResult XML; ' + 
    'SET @xmlResult = EXEC ' + @IPReportStoredProcedure + ' ' + @Parameters + ' ' + 
    'FOR XML PATH(''root''); ' + 
    'SELECT @xmlResult' + 
    '" -o "' + @ExportLocation + @IPFileName + '"'

DECLARE @OPCmd VARCHAR(4096) = @Cmd + 
    'DECLARE @xmlResult XML; ' + 
    'SET @xmlResult = EXEC ' + @OPReportStoredProcedure + ' ' + @Parameters + ' ' + 
    'FOR XML PATH(''root''); ' + 
    'SELECT @xmlResult' + 
    '" -o "' + @ExportLocation + @OPFileName + '"'

-- Print the commands to verify them (optional)
--print @EDCmd
--print @IPCmd
--print @OPCmd

-- Execute each query (ED, IP, OP)
EXEC xp_cmdshell @OPCmd
EXEC xp_cmdshell @EDCmd
EXEC xp_cmdshell @IPCmd







-- To enable the feature.
EXEC sp_configure 'xp_cmdshell', 0

-- To update the currently configured value for this feature.
RECONFIGURE
-- To allow advanced options to be changed.
EXEC sp_configure 'show advanced options', 0

-- To update the currently configured value for advanced options.
RECONFIGURE
END
GO
