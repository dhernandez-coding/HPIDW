CREATE PROCEDURE [rpt].[spExportEpicPBJCode] AS

/* Declare varaiables */


DECLARE	@sql					varchar(8000)
      ,	@path					varchar(100)
      ,	@filename				varchar(100)
	  , @prevAdvancedOptions	int
	  , @prevXpCmdshell			int
	  , @query					varchar(1000)
	  , @filter_command			varchar(1000)
	  , @delete					varchar(100)

SET		@path =			'C:\Users\Public\Code\CODE_OUTPUT\'
SET		@filename =		'PBJ_CODE_Patient_List' 
SET		@query =		'EXEC rpt.spSelectEpicPBJCode'


/* Set configuration */


SELECT @prevAdvancedOptions = cast(value_in_use as int)
	FROM master.sys.configurations 
	WHERE name = 'show advanced options'

SELECT @prevXpCmdshell = cast(value_in_use as int) 
	FROM master.sys.configurations 
	WHERE name = 'xp_cmdshell'

IF (@prevAdvancedOptions = 0)
	BEGIN
	    EXEC sp_configure 'show advanced options', 1
	    RECONFIGURE
END

IF (@prevXpCmdshell = 0)
	BEGIN
	    EXEC sp_configure 'xp_cmdshell', 1
	    RECONFIGURE
END


/*Execute Command*/


-- Set your SQL command
--SET @sql = 'sqlcmd -S ' + @@SERVERNAME + ' -d HPIDW -E -k -h -1 -W -Q "' + @query + '" -o "' + @path +  + 'temp.csv" -s ","'

SET @sql = 'sqlcmd -S ' + @@SERVERNAME + ' -d HPIDW -E -k -W -Q "' + @query + '" -o "' + @path + 'temp.csv" -s "," -H -1'

-- Execute the SQL command and output to a temp file
EXEC master..xp_cmdshell @sql

-- Set command to filter out lines containing "Warning: Null value is eliminated by an aggregate or other SET operation."
SET @filter_command = 'findstr /v /c:"Warning: Null value is eliminated by an aggregate or other SET operation." "' + @path + 'temp.csv" > "' + @path + @filename + '.csv"'

-- Execute the filter command and output results into a file with the defined name
EXEC master..xp_cmdshell @filter_command
PRINT @filter_command

-- Delete temp file
SET @delete = 'del "' + @path + 'temp.csv"'
EXEC master..xp_cmdshell @delete


/* Reset Configuration */


IF (@prevXpCmdshell = 0)
	BEGIN
		EXEC sp_configure 'xp_cmdshell', 0
		RECONFIGURE
END

IF (@prevAdvancedOptions = 0)
	BEGIN
	    EXEC sp_configure 'show advanced options', 0
	    RECONFIGURE
END
GO
