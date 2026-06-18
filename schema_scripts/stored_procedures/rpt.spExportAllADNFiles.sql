CREATE PROCEDURE [rpt].[spExportAllADNFiles] @STARTDATE DATE, @ENDDATE DATE as

--DECLARE @STARTDATE AS DATE 
--DECLARE @ENDDATE AS DATE
DECLARE @GO_LIVE AS DATE

-- Specify the file path for all txt files
DECLARE @FolderPath NVARCHAR(100) = 'C:\Users\Public\ADN\ADN_Output\'

DECLARE @SqlQuery VARCHAR(MAX)
DECLARE @FileName NVARCHAR(256)
DECLARE @FilePath NVARCHAR(512)
DECLARE @Cmd NVARCHAR(MAX)
DECLARE @CmdDynamic NVARCHAR(MAX)

--SET @STARTDATE = '2023-04-28' --DATEADD(MONTH,-3,DATEFROMPARTS(YEAR(GETDATE()),MONTH(GETDATE()),1)); 
--SET @ENDDATE = '2023-05-31' -- DATEADD(DAY,-1,DATEFROMPARTS(YEAR(GETDATE()),MONTH(GETDATE()),1)); 



exec sp_configure 'show advanced options', 1;
reconfigure;
exec sp_configure 'xp_cmdshell', 1;
reconfigure;


SET @GO_LIVE = '4/28/2023';


-------- /* AssignedDiagnosis */

    DROP TABLE IF EXISTS ##tempDiagADNExport;

    CREATE TABLE ##tempDiagADNExport (
        [Hospital Identifier] varchar(100)
        ,[Encounter/Patient Identifier] varchar(100)
        ,[Diagnosis Code] varchar(100)
        ,[Diagnosis Type] varchar(100)
        )

    INSERT INTO ##tempDiagADNExport
    exec [rpt].[spSelectADNAssignedDiagnosis] @STARTDATE = @STARTDATE, @ENDDATE = @ENDDATE, @GO_LIVE = @GO_LIVE

    set @SqlQuery = replace(
    '
    SET NOCOUNT ON
    SELECT
        replace(cast([Hospital Identifier] as varchar), ''|'', '''')
        ,replace(cast([Encounter/Patient Identifier] as varchar), ''|'', '''')
        ,replace(cast([Diagnosis Code] as varchar), ''|'', '''')
        ,replace(cast([Diagnosis Type] as varchar), ''|'', '''')
    FROM ##tempDiagADNExport
    ', char(10), ' ')

    set @FileName = 'AssignedDiagnosis' + CONVERT(NVARCHAR(50), GETDATE(), 23) + '.txt'
    set @FilePath = @FolderPath + @FileName

    -- Build the full command with query and file path
    set @Cmd = 'sqlcmd -S corvmdb10 -d HPIDW -E -Q "' + @SqlQuery + '" -s"|" -W -h -1 -k -o "' + @FilePath + '"'
    set @CmdDynamic = 'EXEC xp_cmdshell ''' + REPLACE(@Cmd, '''', '''''') + ''''

    -- Export the query results to CSV using dynamic SQL
    EXEC sp_executesql @CmdDynamic

    DROP TABLE ##tempDiagADNExport;

-------- /* AssignedPhysicians */

    DROP TABLE IF EXISTS ##tempPhysADNExport;

    CREATE TABLE ##tempPhysADNExport (
        [Hospital Identifier] varchar(100)
        ,[Encounter/Patient Identifier] varchar(100)
        ,[Physician ID] varchar(100)
        ,[Physician Type] varchar(100)
        )

    INSERT INTO ##tempPhysADNExport
    exec [rpt].[spSelectADNAssignedPhysicians] @STARTDATE = @STARTDATE, @ENDDATE = @ENDDATE, @GO_LIVE = @GO_LIVE

    set @SqlQuery = replace(
    '
    SET NOCOUNT ON
    SELECT
        replace(cast([Hospital Identifier] as varchar), ''|'', '''')
        ,replace(cast([Encounter/Patient Identifier] as varchar), ''|'', '''')
        ,replace(cast([Physician ID] as varchar), ''|'', '''')
        ,replace(cast([Physician Type] as varchar), ''|'', '''')
    FROM ##tempPhysADNExport
    ', char(10), ' ')

    set @FileName = 'AssignedPhysicians' + CONVERT(NVARCHAR(50), GETDATE(), 23) + '.txt'
    set @FilePath = @FolderPath + @FileName

    -- Build the full command with query and file path
    set @Cmd = 'sqlcmd -S corvmdb10 -d HPIDW -E -Q "' + @SqlQuery + '" -s"|" -W -h -1 -k -o "' + @FilePath + '"'
    set @CmdDynamic = 'EXEC xp_cmdshell ''' + REPLACE(@Cmd, '''', '''''') + ''''

    -- Export the query results to CSV using dynamic SQL
    EXEC sp_executesql @CmdDynamic

    DROP TABLE ##tempPhysADNExport;

-------- /* Encounter */

    DROP TABLE IF EXISTS ##tempEncounterADNExport;

    CREATE TABLE ##tempEncounterADNExport (
		[Hospital Identifier] varchar(100)
		,[Encounter/Patient Identifier/Billing ID] varchar(100)
		,[Medical Record Number] varchar(100)
		,[Date of Birth] varchar(100)
		,[Hispanic Ethnicity Indicator] varchar(100)
		,[Race] varchar(100)
		,[Sex] varchar(100)
		,[Birth Weight] varchar(100)
		,[Zip Code] varchar(100)
		,[Internal Hospital ID] varchar(100)
		,[Admission Date] varchar(100)
		,[Discharge Date] varchar(100)
		,[Discharge Status/Disposition] varchar(100)
		,[Patient Type] varchar(100)
		,[Inpatient/Outpatient Flag] varchar(100)
        )

    INSERT INTO ##tempEncounterADNExport
    exec [rpt].[spSelectADNEncounter] @STARTDATE = @STARTDATE, @ENDDATE = @ENDDATE, @GO_LIVE = @GO_LIVE

    set @SqlQuery = replace(
    '
    SET NOCOUNT ON
    SELECT
		replace(cast([Hospital Identifier] as varchar), ''|'', '''')
		,replace(cast([Encounter/Patient Identifier/Billing ID] as varchar), ''|'', '''')
		,replace(cast([Medical Record Number] as varchar), ''|'', '''')
		,replace(cast([Date of Birth] as varchar), ''|'', '''')
		,replace(cast([Hispanic Ethnicity Indicator] as varchar), ''|'', '''')
		,replace(cast([Race] as varchar), ''|'', '''')
		,replace(cast([Sex] as varchar), ''|'', '''')
		,replace(cast([Birth Weight] as varchar), ''|'', '''')
		,replace(cast([Zip Code] as varchar), ''|'', '''')
		,replace(cast([Internal Hospital ID] as varchar), ''|'', '''')
		,replace(cast([Admission Date] as varchar), ''|'', '''')
		,replace(cast([Discharge Date] as varchar), ''|'', '''')
		,replace(cast([Discharge Status/Disposition] as varchar), ''|'', '''')
		,replace(cast([Patient Type] as varchar), ''|'', '''')
		,replace(cast([Inpatient/Outpatient Flag] as varchar), ''|'', '''')
    FROM ##tempEncounterADNExport
    ', char(10), ' ')

    set @FileName = 'Encounters' + CONVERT(NVARCHAR(50), GETDATE(), 23) + '.txt'
    set @FilePath = @FolderPath + @FileName

    -- Build the full command with query and file path
    set @Cmd = 'sqlcmd -S corvmdb10 -d HPIDW -E -Q "' + @SqlQuery + '" -s"|" -W -h -1 -k -o "' + @FilePath + '"'
    set @CmdDynamic = 'EXEC xp_cmdshell ''' + REPLACE(@Cmd, '''', '''''') + ''''

    -- Export the query results to CSV using dynamic SQL
    EXEC sp_executesql @CmdDynamic

    DROP TABLE ##tempEncounterADNExport;

-------- /* IPProc */

    DROP TABLE IF EXISTS ##tempIPProcADNExport;

    CREATE TABLE ##tempIPProcADNExport (
        [Hospital Identifier] varchar(100)
        ,[Encounter/Patient Identifier] varchar(100)
        ,[Procedure Code] varchar(100)
        ,[Procedure Type] varchar(100)
		,[Procedure Physician ID] varchar(100)
		,[Procedure Date] varchar(100)
        )

    INSERT INTO ##tempIPProcADNExport
    exec [rpt].[spSelectADNIPProc] @STARTDATE = @STARTDATE, @ENDDATE = @ENDDATE, @GO_LIVE = @GO_LIVE

    set @SqlQuery = replace(
    '
    SET NOCOUNT ON
    SELECT
        replace(cast([Hospital Identifier] as varchar), ''|'', '''')
        ,replace(cast([Encounter/Patient Identifier] as varchar), ''|'', '''')
        ,replace(cast([Procedure Code] as varchar), ''|'', '''')
        ,replace(cast([Procedure Type] as varchar), ''|'', '''')
		,replace(cast([Procedure Physician ID] as varchar), ''|'', '''')
		,replace(cast([Procedure Date] as varchar), ''|'', '''')
    FROM ##tempIPProcADNExport
    ', char(10), ' ')

    set @FileName = 'IPProc' + CONVERT(NVARCHAR(50), GETDATE(), 23) + '.txt'
    set @FilePath = @FolderPath + @FileName

    -- Build the full command with query and file path
    set @Cmd = 'sqlcmd -S corvmdb10 -d HPIDW -E -Q "' + @SqlQuery + '" -s"|" -W -h -1 -k -o "' + @FilePath + '"'
    set @CmdDynamic = 'EXEC xp_cmdshell ''' + REPLACE(@Cmd, '''', '''''') + ''''

    -- Export the query results to CSV using dynamic SQL
    EXEC sp_executesql @CmdDynamic

    DROP TABLE ##tempIPProcADNExport;

-------- /* OPProc */

    DROP TABLE IF EXISTS ##tempOPProcADNExport;

    CREATE TABLE ##tempOPProcADNExport (
        [Hospital Identifier] varchar(100)
        ,[Encounter/Patient Identifier] varchar(100)
        ,[CPT/HCPCS Code] varchar(100)
        ,[Procedure Physician ID] varchar(100)
		,[Procedure Date] varchar(100)
        )

    INSERT INTO ##tempOPProcADNExport
    exec [rpt].[spSelectADNOPProc] @STARTDATE = @STARTDATE, @ENDDATE = @ENDDATE, @GO_LIVE = @GO_LIVE

    set @SqlQuery = replace(
    '
    SET NOCOUNT ON
    SELECT
		replace(cast([Hospital Identifier] as varchar), ''|'', '''')
		,replace(cast([Encounter/Patient Identifier] as varchar), ''|'', '''')
		,replace(cast([CPT/HCPCS Code] as varchar), ''|'', '''')
		,replace(cast([Procedure Physician ID] as varchar), ''|'', '''')
		,replace(cast([Procedure Date] as varchar), ''|'', '''')
    FROM ##tempOPProcADNExport
    ', char(10), ' ')

    set @FileName = 'OPProc' + CONVERT(NVARCHAR(50), GETDATE(), 23) + '.txt'
    set @FilePath = @FolderPath + @FileName

    -- Build the full command with query and file path
    set @Cmd = 'sqlcmd -S corvmdb10 -d HPIDW -E -Q "' + @SqlQuery + '" -s"|" -W -h -1 -k -o "' + @FilePath + '"'
    set @CmdDynamic = 'EXEC xp_cmdshell ''' + REPLACE(@Cmd, '''', '''''') + ''''

    -- Export the query results to CSV using dynamic SQL
    EXEC sp_executesql @CmdDynamic

    DROP TABLE ##tempOPProcADNExport;

------ /* Payer */

    DROP TABLE IF EXISTS ##tempPayerADNExport;

    CREATE TABLE ##tempPayerADNExport (
        HospitalIdentifier varchar(100)
        ,EncounterPatientIdentifier varchar(100)
        ,PayerInsuranceCode varchar(100)
        ,ADNStandardPayerCode varchar(100)
        ,PayerType varchar(100)
		--,[HIC Number] varchar(100)
        )

    INSERT INTO ##tempPayerADNExport
    exec [rpt].[spSelectADNPayerFile] @STARTDATE = @STARTDATE, @ENDDATE = @ENDDATE, @GO_LIVE = @GO_LIVE

    set @SqlQuery = replace(
    '
    SET NOCOUNT ON
    SELECT
		replace(cast(HospitalIdentifier as varchar), ''|'', '''')
		,replace(cast(EncounterPatientIdentifier as varchar), ''|'', '''')
		,replace(cast(PayerInsuranceCode as varchar), ''|'', '''')
		,replace(cast(ADNStandardPayerCode as varchar), ''|'', '''')
		,replace(cast(PayerType as varchar), ''|'', '''')
    FROM ##tempPayerADNExport
    ', char(10), ' ')

    set @FileName = 'Payer' + CONVERT(NVARCHAR(50), GETDATE(), 23) + '.txt'
    set @FilePath = @FolderPath + @FileName

    -- Build the full command with query and file path
    set @Cmd = 'sqlcmd -S corvmdb10 -d HPIDW -E -Q "' + @SqlQuery + '" -s"|" -W -h -1 -k -o "' + @FilePath + '"'
    set @CmdDynamic = 'EXEC xp_cmdshell ''' + REPLACE(@Cmd, '''', '''''') + ''''

    -- Export the query results to CSV using dynamic SQL
    EXEC sp_executesql @CmdDynamic

    DROP TABLE ##tempPayerADNExport;

-------- /* PhysicianMaster */

    DROP TABLE IF EXISTS ##tempPhysicianADNExport;

    CREATE TABLE ##tempPhysicianADNExport (
        HospitalIdentifier varchar(100)
        ,PhysicianID varchar(100)
        ,PhysiciansFullName varchar(100)
        --,[Hospital's Internal Specialty Code] varchar(100)
		--,[ADN Standard Specialty Code] varchar(100)
        )

    INSERT INTO ##tempPhysicianADNExport
    exec [rpt].[spSelectADNPhysicianMasterFile]

    set @SqlQuery = replace(
    '
    SET NOCOUNT ON
    SELECT
		replace(cast(HospitalIdentifier as varchar), ''|'', '''')
		,replace(cast(PhysicianID as varchar), ''|'', '''')
		,replace(cast(PhysiciansFullName as varchar), ''|'', '''')
    FROM ##tempPhysicianADNExport
    ', char(10), ' ')

    set @FileName = 'PhysicianMaster' + CONVERT(NVARCHAR(50), GETDATE(), 23) + '.txt'
    set @FilePath = @FolderPath + @FileName

    -- Build the full command with query and file path
    set @Cmd = 'sqlcmd -S corvmdb10 -d HPIDW -E -Q "' + @SqlQuery + '" -s"|" -W -h -1 -k -o "' + @FilePath + '"'
    set @CmdDynamic = 'EXEC xp_cmdshell ''' + REPLACE(@Cmd, '''', '''''') + ''''

    -- Export the query results to CSV using dynamic SQL
    EXEC sp_executesql @CmdDynamic

    DROP TABLE ##tempPhysicianADNExport;


exec sp_configure 'xp_cmdshell', 0;
reconfigure;
exec sp_configure 'show advanced options', 0;
reconfigure;
GO
