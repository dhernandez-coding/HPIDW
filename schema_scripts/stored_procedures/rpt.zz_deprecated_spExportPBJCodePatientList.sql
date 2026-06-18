CREATE procedure [rpt].[spExportPBJCodePatientList] as

 --Specify the file path for file

DECLARE @FolderPath NVARCHAR(100) = '\\corvmft01\FTPRoot\CodeTechnology\'
--DECLARE @FolderPath NVARCHAR(100) = 'C:\Users\Public\PBJ Test'
DECLARE @SqlQuery VARCHAR(MAX)
DECLARE @FileName NVARCHAR(256)
DECLARE @FilePath NVARCHAR(512)
DECLARE @Cmd NVARCHAR(MAX)
DECLARE @CmdDynamic NVARCHAR(MAX)



DROP TABLE IF EXISTS ##tempPBJCodeExport;

    CREATE TABLE ##tempPBJCodeExport (
        [Patient_Name] varchar(100)
        ,[Patient_ID] varchar(100)
        ,[Physician] varchar(100)
        ,[Physician ID] varchar(100)
		,[Apt Date] varchar(100)
		,[Apt Time] varchar(100)
		,[Appt_Cancelled_Date] varchar(100)
		,[SSN] varchar(100)
		,[DOB] varchar(100)
		,[Age] varchar(100)
		,[Gender] varchar(100)
		,[Marital Status] varchar(100)
		,[Ethnicity] varchar(100)
		,[Language] varchar(100)
		,[Patient_Street1] varchar(100)
        ,[Patient_Street2] varchar(100)
        ,[City] varchar(100)
        ,[State] varchar(100)
		,[Zip] varchar(100)
		,[Patient_Home_Phone] varchar(100)
		,[Patient_Work_Phone] varchar(100)
		,[Patient_Cell_Phone] varchar(100)
		,[Patient_Email] varchar(100)
		,[Primary Policy] varchar(100)
		,[Prim_Policy_Carrier_ID] varchar(100)
		,[Prim_Policy_Group_No] varchar(100)
		,[Secondary Policy] varchar(100)
		,[Sec_Policy_Carrier_ID] varchar(100)
		,[Sec_Policy_Group_No] varchar(100)
		,[Appt_Comments] varchar(100)
        )

		
    INSERT INTO ##tempPBJCodeExport
    exec [rpt].[spPBJCodeTechPatientList]

    set @SqlQuery = replace(
    '
	SET NOCOUNT ON
    SELECT
		*
    FROM ##tempPBJCodeExport
    ', char(10), ' ')

    set @FileName = 'PBJ CODE Patient List' + '.xls'
    set @FilePath = @FolderPath + @FileName

    -- Build the full command with query and file path
    set @Cmd = 'sqlcmd -S corvmdb10 -d HPIDW -E -Q "' + @SqlQuery + '" -s"," -W  -k -o "' + @FilePath + '"'
    set @CmdDynamic = 'EXEC xp_cmdshell ''' + REPLACE(@Cmd, '''', '''''') + ''''

    -- Export the query results to CSV using dynamic SQL
    EXEC sp_executesql @CmdDynamic

    DROP TABLE ##tempPBJCodeExport;
GO
