-- =============================================
-- Author:		Eric Silvestri
-- Create date: 08/13/2023
-- Description:	Stored proceedure to export the rpt.spAPMEncore files to .csv
-- Change Control
--	
-- =============================================

CREATE procedure [rpt].[spExportAPMEncoreFiles] as

-- Specify the file path for file

DECLARE @FolderPath NVARCHAR(100) = '\\corvmft01\FTPRoot\Encore\'  
DECLARE @SqlQuery VARCHAR(MAX)
DECLARE @FileName NVARCHAR(256)
DECLARE @FilePath NVARCHAR(512)
DECLARE @Cmd NVARCHAR(MAX)
DECLARE @CmdDynamic NVARCHAR(MAX)



DROP TABLE IF EXISTS ##tempAPMEncoreExport;

    CREATE TABLE ##tempAPMEncoreExport (
        [PatNo] varchar(100)
        ,[LName] varchar(100)
        ,[FName] varchar(100)
        ,[Mi] varchar(100)
		,[DOB] varchar(100)
		,[Home Phone] varchar(100)
		,[Appt Date] varchar(100)
		,[Appt Time] varchar(100)
		,[Appt Type] varchar(100)
		,[Resource] varchar(100)
		,[Resource Desc] varchar(100)
		,[Loc] varchar(100)
		,[Loc Desc] varchar(100)
		,[Enc No] varchar(100)
		,[Patient SSN] varchar(100)
        )

    INSERT INTO ##tempAPMEncoreExport
    exec [rpt].[spAPMEncore]


    set @SqlQuery = replace(
    '
	SET NOCOUNT ON

	PRINT ''PatNo,LName,FName,Mi,DOB,Home,Appt Date,Appt Time,Appt Type,Resource,Resource Desc,Loc,Loc Desc,Enc No,Patient SSN''

	SELECT
		*
    FROM ##tempAPMEncoreExport
    ', char(10), ' ')

    set @FileName = 'HPI_ENCORE_' + CONVERT(NVARCHAR(50), GETDATE(), 23) + '.csv'
    set @FilePath = @FolderPath + @FileName

    -- Build the full command with query and file path
    set @Cmd = 'sqlcmd -S corvmdb10 -d HPIDW -E -h -1 -Q "' + @SqlQuery + '" -s"," -W -k -o "' + @FilePath + '"'
    set @CmdDynamic = 'EXEC xp_cmdshell ''' + REPLACE(@Cmd, '''', '''''') + ''''

    -- Export the query results to CSV using dynamic SQL
    EXEC sp_executesql @CmdDynamic

    DROP TABLE ##tempAPMEncoreExport;
GO
