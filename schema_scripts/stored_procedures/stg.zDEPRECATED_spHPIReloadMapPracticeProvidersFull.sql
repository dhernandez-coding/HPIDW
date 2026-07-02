CREATE PROCEDURE [stg].[zDEPRECATED_spHPIReloadMapPracticeProvidersFull] AS

/*
-------------------------------------------------------------------------------------------------------
-- Step 1: Enter relevant provider data, when updating leave unchanged fields as NULL
-------------------------------------------------------------------------------------------------------

DECLARE @DataSourceID [tinyint]							= NULL									-- 0: HPIDW, 1: AllScripts, 5: EPIC
DECLARE @PracticeID [varchar](100)						= 'ZZZ'									-- Enter Practice ID with this format
DECLARE @ProviderID [varchar](100) 						= '0000000'								-- Enter Provider ID with this format. Used to find record to alter when updating existing records.
DECLARE @ProviderAbbreviation [varchar] (100)			= 'ZZZ'									-- Enter Provider Abbreviation with this format
DECLARE @ProviderIsPrimary [bit] 						= NULL									-- 1: Primary practicioner, 0: midlevel
DECLARE @ProviderEffectiveDate [date] 					= DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0)	-- Set to first day of current month for new providers. Not used in updating current providers.
DECLARE @ProviderEndDate [date] 						= '12-31-2099'							-- Do not alter unless decomissioning provider
DECLARE @ProviderIsActive [bit] 						= 1										-- Set to 1 unless decomissioning provider
DECLARE @ProviderUpdatedDatetime [datetime] 			= GETDATE()								-- DO NOT ALTER!
DECLARE @ProviderFTE [decimal](18, 2)					= NULL									-- 0 to 1 decimal scalar of full time employment percentage
DECLARE @ProviderAllocationPercent [decimal](18, 8) 	= NULL									-- 0 to 1 decimal scalar of expense allocation percentage
DECLARE @ProviderLocation [varchar](50) 				= NULL									-- Provider Location ID
DECLARE @ProviderIsSpecialist [bit] 					= NULL									-- Provider Specialty
DECLARE @ProviderIsMidLevel [bit] 						= ABS(@ProviderIsPrimary - 1)			-- DO NOT ALTER!
DECLARE @ProviderGLType [varchar](30) 					= NULL 
DECLARE @ProviderGLTypeID [varchar](30) 				= NULL
DECLARE @ProviderGLProviderID [varchar](10) 			= NULL
DECLARE @ProviderDHSType [int] 							= NULL

-------------------------------------------------------------------------------------------------------
-- Step 2: Choose insert or update action
-------------------------------------------------------------------------------------------------------

DECLARE @ActionType tinyint								= 0										-- 1: Insert new record, 2: Update existing Record

-------------------------------------------------------------------------------------------------------
-- Step 3: Comment out 'ALTER/CREATE PROCEDURE...' at top of this query and then execute ENTIRE page
-------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------
-- Step 4: Open the following Power App link to finalize process : https://apps.powerapps.com/play/e/default-c7ae6850-3a33-412b-a092-8bc8d5dc590e/a/360258f5-223c-4be8-a5ee-8798765d74a4?tenantId=c7ae6850-3a33-412b-a092-8bc8d5dc590e&hint=9981fa39-fd27-4ec7-9f37-f17c03bc2e5b&source=sharebutton&sourcetime=1717535895653
-------------------------------------------------------------------------------------------------------

DECLARE @UserComment varchar(800) =
CASE 
	WHEN @ActionType = 1
		THEN 'Creating map for ' + @ProviderAbbreviation + ' provider in ' + @PracticeID + ' practice.'
	WHEN @ActionType = 2
		THEN 'Updating map for ' + @ProviderAbbreviation + ' provider in ' + @PracticeID + ' practice.'
END

-- Insert new records into PracticeProviders map

IF @ActionType = 1 AND @PracticeID NOT LIKE '%ZZZ%' AND @ProviderID NOT LIKE '%0000000%' AND @ProviderAbbreviation NOT LIKE '%ZZZ%' AND @DataSourceID IS NOT NULL
BEGIN

	INSERT INTO map.PracticeProviders (
		[PracticeID]
		,[ProviderID]
		,[ProviderAbbreviation]
		,[PracticeProviderIsPrimary]
		,[PracticeProviderEffectiveDate]
		,[PracticeProviderEndDate]
		,[PracticeProviderIsActive]
		,[PracticeProviderUpdatedDatetime]
		,[PracticeProviderFTE]
		,[PracticeProviderAllocationPercent]
		,[PracticeProviderLocation]
		,[PracticeProviderIsSpecialist]
		,[PracticeProviderIsMidLevel]
		,[PracticeProviderGLType]
		,[PracticeProviderGLTypeID]
		,[PracticeProviderGLProviderID]
		,[PracticeProviderDHSType]
	)
	SELECT 
		CONCAT(@DataSourceID , '~', @PracticeID)
		,CONCAT(@DataSourceID , '~', @ProviderID)
		,CONCAT('0~',@ProviderAbbreviation)
		,@ProviderIsPrimary 
		,@ProviderEffectiveDate
		,@ProviderEndDate 	
		,@ProviderIsActive 	
		,@ProviderUpdatedDatetime
		,@ProviderFTE
		,@ProviderAllocationPercent
		,@ProviderLocation
		,@ProviderIsSpecialist
		,@ProviderIsMidLevel
		,@ProviderGLType
		,@ProviderGLTypeID
		,@ProviderGLProviderID
		,@ProviderDHSType

	-- Insert log entry of new records into MapLog	

	INSERT INTO dbo.MapLog (
		[MapTable]
		,[ActionType]
		,[UpdatedDateTime]
		,[UserComments]
		,[CommandString]
	)
	SELECT
		'map.PracticeProviders'
		,'INSERT'
		,GETDATE()
		,@UserComment
		,CONCAT('CONCAT(',ISNULL(@DataSourceID,'NULL'),' , ''~'', @PracticeID), CONCAT(',ISNULL(@DataSourceID,'NULL'),' , ''~'', ',ISNULL(@ProviderID,'NULL'),')' ,',',ISNULL(@ProviderAbbreviation,'NULL') ,',',ISNULL(@ProviderIsPrimary,'NULL')  ,',',ISNULL(@ProviderEffectiveDate,'NULL') ,',',ISNULL(@ProviderEndDate,'NULL') 	 ,',',ISNULL(@ProviderIsActive,'NULL') 	 ,',',ISNULL(@ProviderUpdatedDatetime,'NULL') ,',',ISNULL(@ProviderFTE,'NULL') ,',',ISNULL(@ProviderAllocationPercent,'NULL') ,',',ISNULL(@ProviderLocation,'NULL') ,',',ISNULL(@ProviderIsSpecialist,'NULL') ,',',ISNULL(@ProviderIsMidLevel,'NULL') ,',',ISNULL(@ProviderGLType,'NULL') ,',',ISNULL(@ProviderGLTypeID,'NULL') ,',',ISNULL(@ProviderGLProviderID,'NULL') ,',',ISNULL(@ProviderDHSType,'NULL'))
;END

-- Update records in PracticeProviders map

IF @ActionType = 2 AND @PracticeID NOT LIKE '%ZZZ%' AND @ProviderID NOT LIKE '%0000000%' AND @ProviderAbbreviation NOT LIKE '%ZZZ%' AND @DataSourceID IS NOT NULL
BEGIN

	UPDATE  map.PracticeProviders
	SET
		[PracticeID] = CONCAT(@DataSourceID, '~', @PracticeID)
		-- Do not change ProviderID
		,[ProviderAbbreviation] = CONCAT('0~', @ProviderAbbreviation)
		,PracticeProviderIsPrimary = CASE WHEN @ProviderIsPrimary IS NOT NULL THEN @ProviderIsPrimary ELSE PracticeProviderIsPrimary END
		-- Do not change PracticeProviderEffectiveDate
		,PracticeProviderEndDate = CASE WHEN @ProviderEndDate IS NOT NULL THEN @ProviderEndDate ELSE PracticeProviderEndDate END
		,PracticeProviderIsActive = CASE WHEN @ProviderIsActive IS NOT NULL THEN @ProviderIsActive ELSE PracticeProviderIsActive END
		,PracticeProviderUpdatedDatetime = @ProviderUpdatedDatetime -- Always change UpdateDateTime
		,PracticeProviderFTE = CASE WHEN @ProviderFTE IS NOT NULL THEN @ProviderFTE ELSE PracticeProviderFTE END
		,PracticeProviderAllocationPercent = CASE WHEN @ProviderAllocationPercent IS NOT NULL THEN @ProviderAllocationPercent ELSE PracticeProviderAllocationPercent END
		,PracticeProviderLocation = CASE WHEN @ProviderLocation IS NOT NULL THEN @ProviderLocation ELSE PracticeProviderLocation END
		,PracticeProviderIsSpecialist = CASE WHEN @ProviderIsSpecialist IS NOT NULL THEN @ProviderIsSpecialist ELSE PracticeProviderIsSpecialist END
		,PracticeProviderIsMidLevel = CASE WHEN @ProviderIsMidLevel IS NOT NULL THEN @ProviderIsMidLevel ELSE PracticeProviderIsMidLevel END
		,PracticeProviderGLType = CASE WHEN @ProviderGLType IS NOT NULL THEN @ProviderGLType ELSE PracticeProviderGLType END
		,PracticeProviderGLTypeID = CASE WHEN @ProviderGLTypeID IS NOT NULL THEN @ProviderGLTypeID ELSE PracticeProviderGLTypeID END
		,PracticeProviderGLProviderID = CASE WHEN @ProviderGLProviderID IS NOT NULL THEN @ProviderGLProviderID ELSE PracticeProviderGLProviderID END
		,PracticeProviderDHSType = CASE WHEN @ProviderDHSType IS NOT NULL THEN @ProviderDHSType ELSE PracticeProviderDHSType END

	WHERE [ProviderID] = @ProviderID;

	-- Insert log entry of updated records into MapLog

	INSERT INTO dbo.MapLog (
		[MapTable]
		,[ActionType]
		,[UpdatedDateTime]
		,[UserComments]
		,[CommandString]
	)
	SELECT
		'map.PracticeProviders'
		,'UPDATE'
		,GETDATE()
		,@UserComment
		,CONCAT('CONCAT(',ISNULL(@DataSourceID,'NULL'),' , ''~'', @PracticeID), CONCAT(',ISNULL(@DataSourceID,'NULL'),' , ''~'', ',ISNULL(@ProviderID,'NULL'),')' ,',',ISNULL(@ProviderAbbreviation,'NULL') ,',',ISNULL(@ProviderIsPrimary,'NULL')  ,',',ISNULL(@ProviderEffectiveDate,'NULL') ,',',ISNULL(@ProviderEndDate,'NULL') 	 ,',',ISNULL(@ProviderIsActive,'NULL') 	 ,',',ISNULL(@ProviderUpdatedDatetime,'NULL') ,',',ISNULL(@ProviderFTE,'NULL') ,',',ISNULL(@ProviderAllocationPercent,'NULL') ,',',ISNULL(@ProviderLocation,'NULL') ,',',ISNULL(@ProviderIsSpecialist,'NULL') ,',',ISNULL(@ProviderIsMidLevel,'NULL') ,',',ISNULL(@ProviderGLType,'NULL') ,',',ISNULL(@ProviderGLTypeID,'NULL') ,',',ISNULL(@ProviderGLProviderID,'NULL') ,',',ISNULL(@ProviderDHSType,'NULL'))

;END
ELSE
BEGIN
    RAISERROR ('Must choose action type and input valid DataSourceID, ProviderID, PracticeID, and ProviderAbbreviation', 16, 1);
END
*/

/*
--TRUNCATE TABLE --map.PracticeProviders 
INSERT INTO map.PracticeProviders VALUES ('0~ACC','1~13939','ACC','1','01/01/2021','12/31/2099','1',GETDATE(),'1','0.700000210000063')
INSERT INTO map.PracticeProviders VALUES ('0~AKM','1~13940','AKM','1','01/01/2021','12/31/2099','1',GETDATE(),'1','0.5')
INSERT INTO map.PracticeProviders VALUES ('0~NRW','1~13941','ALR','0','01/01/2021','12/31/2099','1',GETDATE(),'1','0.125')
INSERT INTO map.PracticeProviders VALUES ('0~ADB','1~13942','AMW','0','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~BEB','1~13944','BEB','1','01/01/2021','12/31/2099','1',GETDATE(),'1','1')
INSERT INTO map.PracticeProviders VALUES ('0~JCB','1~13945','BEC','0','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~BLN','1~13946','BLN','1','01/01/2021','12/31/2099','1',GETDATE(),'1','1')
INSERT INTO map.PracticeProviders VALUES ('0~BAB','1~13947','BAB','1','01/01/2021','12/31/2099','1',GETDATE(),'1','0.25')
INSERT INTO map.PracticeProviders VALUES ('0~DRW','1~13953','CEW','0','01/01/2021','12/31/2099','1',GETDATE(),'0','0')
INSERT INTO map.PracticeProviders VALUES ('0~RLN','1~13955','CMF','0','09/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~BAB','1~13955','CMF','0','01/01/2021','08/31/2021','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~NRW','1~13956','CMM','0','01/01/2021','12/31/2099','1',GETDATE(),'1','0.125')
INSERT INTO map.PracticeProviders VALUES ('0~CSH','1~13957','CSH','1','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~DCH','1~13959','DCH','1','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~MSO','1~13961','DDL','0','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~DDR','1~13962','DDR','1','01/01/2021','12/31/2099','1',GETDATE(),'1','0.333333333333333')
INSERT INTO map.PracticeProviders VALUES ('0~DEA','1~13963','DEA','1','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~DNR','1~13964','DNR','1','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~DRB','1~13965','DRB','1','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~DRW','1~13966','DRW','1','01/01/2021','12/31/2099','1',GETDATE(),'1','0.333333333333333')
INSERT INTO map.PracticeProviders VALUES ('0~EKK','1~13968','EKK','1','01/01/2021','12/31/2099','1',GETDATE(),'1','0.5')
INSERT INTO map.PracticeProviders VALUES ('0~GPK','1~13970','GPK','1','01/01/2021','12/31/2099','1',GETDATE(),'1','1')
INSERT INTO map.PracticeProviders VALUES ('0~HSL','1~13971','HSL','1','01/01/2021','12/31/2099','1',GETDATE(),'1','0.4')
INSERT INTO map.PracticeProviders VALUES ('0~JCB','1~13972','JCB','1','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~JCJ','1~13973','JCJ','1','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~JHC','1~13977','JHC','1','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~JLM','1~13978','JLM','1','01/01/2021','12/31/2099','1',GETDATE(),'1','1')
INSERT INTO map.PracticeProviders VALUES ('0~SMS','1~13979','JMB','0','01/01/2021','12/31/2099','1',GETDATE(),'1','0.5')
INSERT INTO map.PracticeProviders VALUES ('0~DDR','1~13980','JML','0','01/01/2021','12/31/2099','1',GETDATE(),'1','0.333333333333333')
INSERT INTO map.PracticeProviders VALUES ('0~MEM','1~13981','JNC','0','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~MSO','1~13983','KCM','0','01/01/2021','12/31/2099','1',GETDATE(),'1','0.5')
INSERT INTO map.PracticeProviders VALUES ('0~PBJ','1~13986','KMO','0','01/01/2021','12/31/2099','1',GETDATE(),'1','0.25')
INSERT INTO map.PracticeProviders VALUES ('0~LAK','1~13987','LAK','1','01/01/2021','12/31/2099','1',GETDATE(),'1','1')
INSERT INTO map.PracticeProviders VALUES ('0~DEA','1~13988','LDP','0','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~LLK','1~13989','LLK','1','01/01/2021','12/31/2099','1',GETDATE(),'1','1')
INSERT INTO map.PracticeProviders VALUES ('0~RSU','1~13990','LND','0','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~MAH','1~13991','MAH','1','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~MBJ','1~13992','MBJ','1','01/01/2021','12/31/2099','1',GETDATE(),'1','0.5')
INSERT INTO map.PracticeProviders VALUES ('0~MEM','1~13994','MEM','1','01/01/2021','12/31/2099','1',GETDATE(),'1','0.5')
INSERT INTO map.PracticeProviders VALUES ('0~MHW','1~13995','MHW','1','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~MSO','1~13998','MSO','1','01/01/2021','12/31/2099','1',GETDATE(),'1','0.5')
INSERT INTO map.PracticeProviders VALUES ('0~NRW','1~13999','NRW','1','01/01/2021','12/31/2099','1',GETDATE(),'1','0.125')
INSERT INTO map.PracticeProviders VALUES ('0~PBJ','1~14000','PBJ','1','01/01/2021','12/31/2099','1',GETDATE(),'1','0.25')
INSERT INTO map.PracticeProviders VALUES ('0~NRW','1~14001','PLH','0','01/01/2021','12/31/2099','1',GETDATE(),'1','0.125')
INSERT INTO map.PracticeProviders VALUES ('0~PBJ','1~14003','RAP','0','01/01/2021','12/31/2099','1',GETDATE(),'1','0.25')
INSERT INTO map.PracticeProviders VALUES ('0~RFH','1~14005','RFH','1','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~RLN','1~14006','RLN','1','01/01/2021','12/31/2099','1',GETDATE(),'1','0.333333333333333')
INSERT INTO map.PracticeProviders VALUES ('0~RMH','1~14007','RMH','1','01/01/2021','12/31/2099','1',GETDATE(),'1','1')
INSERT INTO map.PracticeProviders VALUES ('0~RSU','1~14008','RSU','1','01/01/2021','12/31/2099','1',GETDATE(),'1','1')
INSERT INTO map.PracticeProviders VALUES ('0~SMS','1~14009','SCS','1','01/01/2021','12/31/2099','1',GETDATE(),'1','0.5')
INSERT INTO map.PracticeProviders VALUES ('0~SDB','1~14010','SDB','1','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~SDC','1~14011','SDC','1','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~BAB','1~14012','SEC','0','01/01/2021','12/31/2099','1',GETDATE(),'1','0.25')
INSERT INTO map.PracticeProviders VALUES ('0~NRW','1~14013','SLC','0','01/01/2021','12/31/2099','1',GETDATE(),'1','0.125')
INSERT INTO map.PracticeProviders VALUES ('0~TAK','1~14016','TAK','1','01/01/2021','12/31/2099','1',GETDATE(),'1','0.900000090000009')
INSERT INTO map.PracticeProviders VALUES ('0~TCC','1~14017','TCC','1','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~BEB','1~14018','TCM','0','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~MHW','1~14021','VTT','0','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~WSB','1~14022','WSB','1','01/01/2021','12/31/2099','1',GETDATE(),'1','1')
INSERT INTO map.PracticeProviders VALUES ('0~CMS','1~16310','JWF','0','01/01/2021','12/31/2099','1',GETDATE(),'0.5','0.2')
INSERT INTO map.PracticeProviders VALUES ('0~RDI','1~17424','RDI','1','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~JTM','1~17425','JTM','1','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~RLN','1~17426','MSW','0','01/01/2021','12/31/2099','1',GETDATE(),'1','0.333333333333333')
INSERT INTO map.PracticeProviders VALUES ('0~RDI','1~17513','CRH','0','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~TAK','1~17530','JLR','0','01/01/2021','12/31/2099','1',GETDATE(),'0.111111','0.099999909999991')
INSERT INTO map.PracticeProviders VALUES ('0~LDH','1~17534','LDH','1','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~NRW','1~17546','ALB','0','01/01/2021','12/31/2099','1',GETDATE(),'1','0.125')
INSERT INTO map.PracticeProviders VALUES ('0~SKH','1~17713','SKH','1','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~HSL','1~17729','WTM','0','01/01/2021','12/31/2099','1',GETDATE(),'0.5','0.2')
INSERT INTO map.PracticeProviders VALUES ('0~CAH','1~17781','CAH','1','01/01/2021','12/31/2099','1',GETDATE(),'1','1')
INSERT INTO map.PracticeProviders VALUES ('0~BAB','1~17884','KCS','0','01/01/2021','12/31/2099','1',GETDATE(),'1','0.25')
INSERT INTO map.PracticeProviders VALUES ('0~DDR','1~17898','LMG','0','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~BJB','1~17927','BJB','1','01/01/2021','12/31/2099','1',GETDATE(),'1','1')
INSERT INTO map.PracticeProviders VALUES ('0~LDH','1~17940','INF','0','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~DNR','1~17954','ALG','0','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~LDH','1~17982','JCR','0','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~SJL','1~17984','SJL','1','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~TDT','1~17989','TDT','1','01/01/2021','12/31/2099','1',GETDATE(),'1','0.5')
INSERT INTO map.PracticeProviders VALUES ('0~JCB','1~18014','JRR','0','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~GMM','1~18195','GMM','1','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~PBJ','1~18356','LSD','0','01/01/2021','12/31/2099','1',GETDATE(),'1','0.25')
INSERT INTO map.PracticeProviders VALUES ('0~JLC','1~18363','JLC','1','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~CAD','1~18383','CAD','1','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~NRW','1~18416','BJC','0','01/01/2021','12/31/2099','1',GETDATE(),'1','0.125')
INSERT INTO map.PracticeProviders VALUES ('0~MBJ','1~18424','SMH','0','01/01/2021','12/31/2099','1',GETDATE(),'1','0.5')
INSERT INTO map.PracticeProviders VALUES ('0~DDR','1~18471','MSB','0','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~ADB','1~18488','ADB','1','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~JPN','1~18514','JPN','1','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~EKK','1~18524','KMC','0','01/01/2021','12/31/2099','1',GETDATE(),'1','0.5')
INSERT INTO map.PracticeProviders VALUES ('0~LDH','1~18531','SRB','0','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~DDR','1~18564','RNH','0','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~TDT','1~18624','DMM','0','01/01/2021','12/31/2099','1',GETDATE(),'1','0.5')
INSERT INTO map.PracticeProviders VALUES ('0~JCB','1~18633','KAC','0','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~JCB','1~18716','AAT','0','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~GPK','1~18738','JER','0','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~MEC','1~18747','MEC','1','01/01/2021','12/31/2099','1',GETDATE(),'1','0.5')
INSERT INTO map.PracticeProviders VALUES ('0~HAG','1~18757','HAG','1','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~LDH','1~18768','ADO','0','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~AKM','1~18824','MMC','0','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~JPN','1~18894','KGA','0','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~MEM','1~18898','AJG','0','01/01/2021','12/31/2099','1',GETDATE(),'1','0.5')
INSERT INTO map.PracticeProviders VALUES ('0~CMS','1~18906','CMS','1','01/01/2021','12/31/2099','1',GETDATE(),'1','0.4')
INSERT INTO map.PracticeProviders VALUES ('0~DDR','1~18960','DCB','0','01/01/2021','12/31/2099','1',GETDATE(),'1','0.333333333333333')
INSERT INTO map.PracticeProviders VALUES ('0~LDH','1~19052','HCR','0','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~PAK','1~19061','PAK','1','01/01/2021','12/31/2099','1',GETDATE(),'1','1')
INSERT INTO map.PracticeProviders VALUES ('0~MEC','1~19087','AMM','0','01/01/2021','12/31/2099','1',GETDATE(),'1','0.5')
INSERT INTO map.PracticeProviders VALUES ('0~ANT','1~19088','ANT','1','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~JAM','1~19091','JAM','1','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~CMS','1~19105','PTD','0','01/01/2021','12/31/2099','1',GETDATE(),'1','0.4')
INSERT INTO map.PracticeProviders VALUES ('0~LRL','1~19107','LRL','1','01/01/2021','12/31/2099','1',GETDATE(),'1','1')
INSERT INTO map.PracticeProviders VALUES ('0~ACC','1~19149','MSH','0','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~LDH','1~19203','ART','0','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~NRW','1~19233','CHB','0','01/01/2021','12/31/2099','1',GETDATE(),'1','0.125')
INSERT INTO map.PracticeProviders VALUES ('0~JCB','1~19266','BNM','0','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~HSL','1~19271','PRL','0','01/01/2021','12/31/2099','1',GETDATE(),'1','0.4')
INSERT INTO map.PracticeProviders VALUES ('0~LCS','1~19300','LCS','1','01/01/2021','12/31/2099','1',GETDATE(),'1','0.333333333333333')
INSERT INTO map.PracticeProviders VALUES ('0~LCS','1~19301','JDH','0','01/01/2021','12/31/2099','1',GETDATE(),'1','0.333333333333333')
INSERT INTO map.PracticeProviders VALUES ('0~LDH','1~19319','JCG','0','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~MBJ','1~19329','RJS','0','09/01/2021','12/31/2099','1',GETDATE(),'1','0.25')
INSERT INTO map.PracticeProviders VALUES ('0~BAB','1~19329','RJS','0','01/01/2021','08/31/2021','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~RGS','1~19376','RGS','1','01/01/2021','12/31/2099','1',GETDATE(),'1','1')
INSERT INTO map.PracticeProviders VALUES ('0~NBN','1~19377','NBN','1','01/01/2021','12/31/2099','1',GETDATE(),'1','0.5')
INSERT INTO map.PracticeProviders VALUES ('0~JCB','1~19414','JKY','0','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~CMS','1~19437','SJM','0','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~JCB','1~19449','MCC','0','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~TDT','1~19481','KRG','0','01/01/2021','12/31/2099','1',GETDATE(),'1','1')
INSERT INTO map.PracticeProviders VALUES ('0~DRW','1~19547','ARR','0','01/01/2021','12/31/2099','1',GETDATE(),'1','0.333333333333333')
INSERT INTO map.PracticeProviders VALUES ('0~PAK','1~19607','AAP','0','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~CGW','1~19619','CGW','1','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~RLN','1~19711','MES','0','01/01/2021','12/31/2099','1',GETDATE(),'1','0.333333333333333')
INSERT INTO map.PracticeProviders VALUES ('0~LCS','1~19749','TJR','0','01/01/2021','12/31/2099','1',GETDATE(),'1','0.333333333333333')
INSERT INTO map.PracticeProviders VALUES ('0~NMO','1~19760','NMO','1','01/01/2021','12/31/2099','1',GETDATE(),'1','1')
INSERT INTO map.PracticeProviders VALUES ('0~JCB','1~19786','MJL','0','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~ACC','1~19830','ASB','0','01/01/2021','12/31/2099','1',GETDATE(),'0.428571','0.299999789999937')
INSERT INTO map.PracticeProviders VALUES ('0~TDT','1~19831','JLT','0','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~AKM','1~19895','TCF','0','01/01/2021','12/31/2099','1',GETDATE(),'1','0.5')
INSERT INTO map.PracticeProviders VALUES ('0~CGW','1~19898','AQN','0','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~CMS','1~19913','AMB','0','01/01/2021','12/31/2099','1',GETDATE(),NULL,NULL)
INSERT INTO map.PracticeProviders VALUES ('0~NBN','1~19928','LAG','0','01/01/2021','12/31/2099','1',GETDATE(),'1','0.5')
INSERT INTO map.PracticeProviders VALUES ('0~TDT','1~19990','BMD','0','01/01/2021','12/31/2099','1',GETDATE(),'1','1')
INSERT INTO map.PracticeProviders VALUES ('0~SCS','5~109725','SCS','1','01/01/2021','12/31/2099','1',GETDATE(),'1','0.45')
INSERT INTO map.PracticeProviders VALUES ('0~MMD','5~101349','MMD','1','01/01/2021','12/31/2099','1',GETDATE(),'1','0.5')

INSERT INTO map.PracticeProviders VALUES ('0~MMD','5~136623','JNL','0','01/01/2021','12/31/2099','1',GETDATE(),'1','0.5')
INSERT INTO map.PracticeProviders VALUES ('0~SCS','5~105546','LTC','0','01/01/2021','12/31/2099','1',GETDATE(),'1','0.45') 
INSERT INTO map.PracticeProviders VALUES ('0~SCS','5~117670','KSR','0','01/01/2021','12/31/2099','1',GETDATE(),'0.22','0.10') 

INSERT INTO map.PracticeProviders VALUES ('0~RSG','5~P1000074','RSG','1','01/01/2021','12/31/2099','1',GETDATE(),'1','1')
INSERT INTO map.PracticeProviders VALUES ('0~DRW','1~20102','JMD','0','01/01/2021','12/31/2099','1',GETDATE(),'1','0.333333333333333')

/*Added Sam, Nevinson on 2.15.2024*/
INSERT INTO map.PracticeProviders VALUES ('0~NPS','5~127137','NPS','1','01/01/2021','12/31/2099','1',GETDATE(),'1','1',NULL,'1','0')


--UPDATE map.PracticeProviders set PracticeID = '0~RSG', ProviderAbbreviation = 'RSG'  where ProviderID = '5~P1000074'
--UPDATE map.PracticeProviders set PracticeProviderFTE = NULL, PracticeProviderAllocationPercent = NULL where PracticeProviderID = 120



/*Added on 3.7.2024*/
	/* Haddock at LCS */
	INSERT INTO map.PracticeProviders VALUES ('0~LCS','1~20199','DSH','0','01/01/2021','12/31/2099','1',GETDATE(),'1','0.25',NULL,1,1)
	UPDATE  map.PracticeProviders SET practiceproviderallocationpercent = 0.25 where practiceID = '0~LCS'

	/* Jimenez at SMS */
	INSERT INTO map.PracticeProviders VALUES ('0~SMS','1~20211','SUJ','0','01/01/2021','12/31/2099','1',GETDATE(),'1','0.00',NULL,1,1)
	UPDATE  map.PracticeProviders SET practiceproviderallocationpercent = 0.5 where practiceID = '0~SMS'

	/* Pfaff at SCS */
	INSERT INTO map.PracticeProviders VALUES ('0~SCS','5~127870','KJP','0','01/01/2021','12/31/2099','1',GETDATE(),'1','0.225',NULL,1,1)
	
	/* Needham at SCS */
	INSERT INTO map.PracticeProviders VALUES ('0~SCS','5~102684','CAN','0','01/01/2021','12/31/2099','1',GETDATE(),'1','0.225',NULL,1,1)
	UPDATE  map.PracticeProviders SET practiceproviderallocationpercent = 0.225 where practiceID = '0~SCS' and providerid <> '5~117670'

	/* Remove Katrina Stewart from BAB and reset allocation percent for remaining providers*/
	UPDATE map.PracticeProviders 
	SET PracticeProviderEndDate = '1/31/2023', PracticeProviderFTE = NULL, PracticeProviderAllocationPercent = NULL 
	WHERE PracticeID = '0~BAB' AND ProviderID = '1~17884'

	UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0.333333333333333 WHERE PracticeID = '0~BAB' AND PracticeProviderAllocationPercent IS NOT NULL


/*Added 3.13.24*/

	/* adding missing providers and updating missing data in allocation and FTE columns */

	/* ADB */
	UPDATE  map.PracticeProviders SET practiceproviderallocationpercent = 0.5, PracticeProviderFTE = 1 where practiceID = '0~ADB'

	/* CGW */
	UPDATE  map.PracticeProviders SET practiceproviderallocationpercent = 0.5, PracticeProviderFTE = 1 where practiceID = '0~CGW'

	/* CSH */
	INSERT INTO map.PracticeProviders VALUES ('0~CSH','5~102495','CSH','1','01/01/2021','12/31/2099','1',GETDATE(),'1','0.5',NULL,NULL,0)
	INSERT INTO map.PracticeProviders VALUES ('0~CSH','5~131966','CSH','0','01/01/2021','12/31/2099','1',GETDATE(),'1','0.5',NULL,NULL,1)

	/* DCH */
	UPDATE  map.PracticeProviders SET practiceproviderallocationpercent = 1, PracticeProviderFTE = 1 where practiceID = '0~DCH'

	/* JHC */
	UPDATE  map.PracticeProviders SET practiceproviderallocationpercent = 1, PracticeProviderFTE = 1 where practiceID = '0~JHC'

	/* JPN */
	UPDATE  map.PracticeProviders SET practiceproviderallocationpercent = 0.5, PracticeProviderFTE = 1 where practiceID = '0~JPN'

	/* MDW */
	INSERT INTO map.PracticeProviders VALUES ('0~MDW','5~105864','MDW','1','01/01/2021','12/31/2099','1',GETDATE(),'1','1',NULL,NULL,0)

	/* NPS */
	UPDATE  map.PracticeProviders SET practiceproviderallocationpercent = 1, PracticeProviderFTE = 1 where practiceID = '0~NPS'

	/* RFH */
	UPDATE  map.PracticeProviders SET practiceproviderallocationpercent = 1, PracticeProviderFTE = 1 where practiceID = '0~RFH'

	/* SKH */
	UPDATE  map.PracticeProviders SET practiceproviderallocationpercent = 1, PracticeProviderFTE = 1 where practiceID = '0~SKH'


/*Added 3.14.24*/

	/* SCS  */
	UPDATE  map.PracticeProviders 
	SET practiceproviderallocationpercent = 0, PracticeProviderEndDate = '10/30/2023', PracticeProviderIsActive = 0, PracticeProviderFTE = 0 
	where PracticeID = '0~SCS' and providerid = '5~117670'

	UPDATE  map.PracticeProviders 
	SET practiceproviderallocationpercent = 0
	where PracticeID = '0~SCS' and providerid = '5~102684'

	UPDATE  map.PracticeProviders 
	SET practiceproviderallocationpercent = 0, PracticeProviderEffectiveDate = '4/1/2024'
	where PracticeID = '0~SCS' and providerid = '5~127870'

	UPDATE  map.PracticeProviders 
	SET practiceproviderallocationpercent = .5
	where PracticeID = '0~SCS' and providerid in ('5~105546', '5~109725')



/* 3/20/24 */



	UPDATE  map.PracticeProviders 
	SET PracticeProviderIsActive = 0
	where PracticeID = '0~CSH' and providerid = '1~13957'
	
	DELETE FROM map.PracticeProviders
	where ProviderID = '1~13957'
-- PracticeProviderID	PracticeID	ProviderID	ProviderAbbreviation	PracticeProviderIsPrimary	PracticeProviderEffectiveDate	PracticeProviderEndDate	PracticeProviderIsActive	PracticeProviderUpdatedDatetime	PracticeProviderFTE	PracticeProviderAllocationPercent	PracticeProviderLocation	PracticeProviderIsSpecialist	PracticeProviderIsMidLevel 
-- 13	0~CSH	1~13957	CSH	1	2021-01-01	2099-12-31	0	2023-11-08 14:11:06.173	NULL	NULL	NULL	NULL	NULL


/* 4/3/24 */ -
	/* add MES to RGS practice */
	INSERT INTO map.PracticeProviders 
		VALUES ('0~RGS','5~125582','MES','0','04/01/2024','12/31/2099','1',GETDATE(),'0.5','0.0',NULL,NULL,1) /*--Per Nick update the Allocation to 25% for April 2024--*/

	/* adjust providers in RGS */
	UPDATE  map.PracticeProviders 
		SET PracticeProviderAllocationPercent = '1.00'  /*--Per Nick update the Allocation to 75% for April 2024--*/
		where PracticeID = '0~RGS' and providerid = '1~19376'  

	/* adjust providers in RLN */
	UPDATE  map.PracticeProviders 
		SET PracticeProviderAllocationPercent = '0.42'
		where PracticeID = '0~RLN' and providerid = '1~14006'
	UPDATE  map.PracticeProviders 
		SET PracticeProviderAllocationPercent = '0.42'
		where PracticeID = '0~RLN' and providerid = '1~17426'
	UPDATE  map.PracticeProviders 
		SET PracticeProviderAllocationPercent = '0.16', PracticeProviderFTE = '0.5'
		where PracticeID = '0~RLN' and providerid = '1~19711'


	/* add AQN to MDW practice */
	INSERT INTO map.PracticeProviders 
		VALUES ('0~MDW','5~126867','AQN','0','04/01/2024','12/31/2099','1',GETDATE(),'0.5','0',NULL,NULL,1)

	/* adjust providers in CGW */
	UPDATE  map.PracticeProviders 
		SET PracticeProviderFTE = '0.5'
		where PracticeID = '0~CGW' and providerid = '1~19898'

	--------- Cost allocations for both practices do not change with James (AQN) adding a second practice (MDW) per email from Nick Henson on 4/1 -----------

/* 4/10/24 Adjustments to RGS  */
	/* adjust providers in RGS */
	UPDATE  map.PracticeProviders 
		SET PracticeProviderAllocationPercent = '0.00'  /*--Per Nick update the Allocation to 25% for April 2024--*/
		where PracticeID = '0~RGS' and providerid = '5~125582'  
	
	UPDATE  map.PracticeProviders 
		SET PracticeProviderAllocationPercent = '1.00'  /*--Per Nick update the Allocation to 75% for April 2024--*/
		where PracticeID = '0~RGS' and providerid = '1~19376'  

/* 4/17/2024 Adjustsments to RSG (Spencer)*/
	/*Add Mahoney and Sanders*/
	INSERT INTO map.PracticeProviders VALUES ('0~RSG','5~130875','HBM','0','03/01/2024','12/31/2099','1',GETDATE(),'1','0.333333',NULL,0,1)
	INSERT INTO map.PracticeProviders VALUES ('0~RSG','5~119249','JDS','0','03/01/2024','12/31/2099','1',GETDATE(),'1','0.333333',NULL,0,1)
	UPDATE map.PracticeProviders SET practiceproviderallocationpercent = 0.333333 where practiceID = '0~RSG'

/* 4/30/24 Added GL Provider ID from GL Accounts*/

	DECLARE @TEMP1 TABLE (ProviderAbbr varchar(10), ProviderID varchar(30))

	INSERT INTO @TEMP1
	select
		a.GLAccountProvider
		,a.GLAccountProviderID
	from stg.vGLAccounts a 
	where a.GLAccountNumber like '4010%'
	GROUP BY 
		a.GLAccountProviderID
		,a.GLAccountProvider


	select
	CONCAT('update map.PracticeProviders SET PracticeProviderGLProviderID = ''',t.ProviderID,''' WHERE PracticeProviderID = ',pp.PracticeProviderID) as updatestatement
	, t.*
	, pp.*
	from map.PracticeProviders pp
		left join @TEMP1 T on T.ProviderAbbr = PP.ProviderAbbreviation 
	where t.ProviderID is not null

	update map.PracticeProviders SET PracticeProviderGLProviderID = '019  ' WHERE PracticeProviderID = 3
	update map.PracticeProviders SET PracticeProviderGLProviderID = '014  ' WHERE PracticeProviderID = 4
	update map.PracticeProviders SET PracticeProviderGLProviderID = '022  ' WHERE PracticeProviderID = 8
	update map.PracticeProviders SET PracticeProviderGLProviderID = '040  ' WHERE PracticeProviderID = 9
	update map.PracticeProviders SET PracticeProviderGLProviderID = '045  ' WHERE PracticeProviderID = 10
	update map.PracticeProviders SET PracticeProviderGLProviderID = '045  ' WHERE PracticeProviderID = 11
	update map.PracticeProviders SET PracticeProviderGLProviderID = '009  ' WHERE PracticeProviderID = 14
	update map.PracticeProviders SET PracticeProviderGLProviderID = '104  ' WHERE PracticeProviderID = 15
	update map.PracticeProviders SET PracticeProviderGLProviderID = '032  ' WHERE PracticeProviderID = 28
	update map.PracticeProviders SET PracticeProviderGLProviderID = '008  ' WHERE PracticeProviderID = 29
	update map.PracticeProviders SET PracticeProviderGLProviderID = '001  ' WHERE PracticeProviderID = 30
	update map.PracticeProviders SET PracticeProviderGLProviderID = '028  ' WHERE PracticeProviderID = 31
	update map.PracticeProviders SET PracticeProviderGLProviderID = '044  ' WHERE PracticeProviderID = 32
	update map.PracticeProviders SET PracticeProviderGLProviderID = '039  ' WHERE PracticeProviderID = 34
	update map.PracticeProviders SET PracticeProviderGLProviderID = '005  ' WHERE PracticeProviderID = 36
	update map.PracticeProviders SET PracticeProviderGLProviderID = '023  ' WHERE PracticeProviderID = 44
	update map.PracticeProviders SET PracticeProviderGLProviderID = '030  ' WHERE PracticeProviderID = 45
	update map.PracticeProviders SET PracticeProviderGLProviderID = '031  ' WHERE PracticeProviderID = 48
	update map.PracticeProviders SET PracticeProviderGLProviderID = '043  ' WHERE PracticeProviderID = 53
	update map.PracticeProviders SET PracticeProviderGLProviderID = '002  ' WHERE PracticeProviderID = 54
	update map.PracticeProviders SET PracticeProviderGLProviderID = '037  ' WHERE PracticeProviderID = 58
	update map.PracticeProviders SET PracticeProviderGLProviderID = '102  ' WHERE PracticeProviderID = 60
	update map.PracticeProviders SET PracticeProviderGLProviderID = '010  ' WHERE PracticeProviderID = 62
	update map.PracticeProviders SET PracticeProviderGLProviderID = '047  ' WHERE PracticeProviderID = 63
	update map.PracticeProviders SET PracticeProviderGLProviderID = '048  ' WHERE PracticeProviderID = 65
	update map.PracticeProviders SET PracticeProviderGLProviderID = '015  ' WHERE PracticeProviderID = 67
	update map.PracticeProviders SET PracticeProviderGLProviderID = '049  ' WHERE PracticeProviderID = 67
	update map.PracticeProviders SET PracticeProviderGLProviderID = '051  ' WHERE PracticeProviderID = 69
	update map.PracticeProviders SET PracticeProviderGLProviderID = '053  ' WHERE PracticeProviderID = 71
	update map.PracticeProviders SET PracticeProviderGLProviderID = '054  ' WHERE PracticeProviderID = 72
	update map.PracticeProviders SET PracticeProviderGLProviderID = '057  ' WHERE PracticeProviderID = 76
	update map.PracticeProviders SET PracticeProviderGLProviderID = '058  ' WHERE PracticeProviderID = 81
	update map.PracticeProviders SET PracticeProviderGLProviderID = '061  ' WHERE PracticeProviderID = 84
	update map.PracticeProviders SET PracticeProviderGLProviderID = '059  ' WHERE PracticeProviderID = 85
	update map.PracticeProviders SET PracticeProviderGLProviderID = '062  ' WHERE PracticeProviderID = 86
	update map.PracticeProviders SET PracticeProviderGLProviderID = '063  ' WHERE PracticeProviderID = 87
	update map.PracticeProviders SET PracticeProviderGLProviderID = '064  ' WHERE PracticeProviderID = 89
	update map.PracticeProviders SET PracticeProviderGLProviderID = '065  ' WHERE PracticeProviderID = 90
	update map.PracticeProviders SET PracticeProviderGLProviderID = '066  ' WHERE PracticeProviderID = 91
	update map.PracticeProviders SET PracticeProviderGLProviderID = '067  ' WHERE PracticeProviderID = 92
	update map.PracticeProviders SET PracticeProviderGLProviderID = '069  ' WHERE PracticeProviderID = 98
	update map.PracticeProviders SET PracticeProviderGLProviderID = '070  ' WHERE PracticeProviderID = 99
	update map.PracticeProviders SET PracticeProviderGLProviderID = '071  ' WHERE PracticeProviderID = 101
	update map.PracticeProviders SET PracticeProviderGLProviderID = '073  ' WHERE PracticeProviderID = 103
	update map.PracticeProviders SET PracticeProviderGLProviderID = '075  ' WHERE PracticeProviderID = 104
	update map.PracticeProviders SET PracticeProviderGLProviderID = '074  ' WHERE PracticeProviderID = 106
	update map.PracticeProviders SET PracticeProviderGLProviderID = '076  ' WHERE PracticeProviderID = 109
	update map.PracticeProviders SET PracticeProviderGLProviderID = '077  ' WHERE PracticeProviderID = 111
	update map.PracticeProviders SET PracticeProviderGLProviderID = '079  ' WHERE PracticeProviderID = 112
	update map.PracticeProviders SET PracticeProviderGLProviderID = '080  ' WHERE PracticeProviderID = 117
	update map.PracticeProviders SET PracticeProviderGLProviderID = '083  ' WHERE PracticeProviderID = 118
	update map.PracticeProviders SET PracticeProviderGLProviderID = '081  ' WHERE PracticeProviderID = 119
	update map.PracticeProviders SET PracticeProviderGLProviderID = '081  ' WHERE PracticeProviderID = 120
	update map.PracticeProviders SET PracticeProviderGLProviderID = '086  ' WHERE PracticeProviderID = 124
	update map.PracticeProviders SET PracticeProviderGLProviderID = '088  ' WHERE PracticeProviderID = 126
	update map.PracticeProviders SET PracticeProviderGLProviderID = '089  ' WHERE PracticeProviderID = 127
	update map.PracticeProviders SET PracticeProviderGLProviderID = '090  ' WHERE PracticeProviderID = 128
	update map.PracticeProviders SET PracticeProviderGLProviderID = '092  ' WHERE PracticeProviderID = 130
	update map.PracticeProviders SET PracticeProviderGLProviderID = '093  ' WHERE PracticeProviderID = 131
	update map.PracticeProviders SET PracticeProviderGLProviderID = '098  ' WHERE PracticeProviderID = 134
	update map.PracticeProviders SET PracticeProviderGLProviderID = '095  ' WHERE PracticeProviderID = 135
	update map.PracticeProviders SET PracticeProviderGLProviderID = '097  ' WHERE PracticeProviderID = 136
	update map.PracticeProviders SET PracticeProviderGLProviderID = '098  ' WHERE PracticeProviderID = 138
	update map.PracticeProviders SET PracticeProviderGLProviderID = '099  ' WHERE PracticeProviderID = 139
	update map.PracticeProviders SET PracticeProviderGLProviderID = '100  ' WHERE PracticeProviderID = 140
	update map.PracticeProviders SET PracticeProviderGLProviderID = '094  ' WHERE PracticeProviderID = 146
	update map.PracticeProviders SET PracticeProviderGLProviderID = '013  ' WHERE PracticeProviderID = 147
	update map.PracticeProviders SET PracticeProviderGLProviderID = '087  ' WHERE PracticeProviderID = 148
	update map.PracticeProviders SET PracticeProviderGLProviderID = '084  ' WHERE PracticeProviderID = 149
	update map.PracticeProviders SET PracticeProviderGLProviderID = '103  ' WHERE PracticeProviderID = 150
	update map.PracticeProviders SET PracticeProviderGLProviderID = '107  ' WHERE PracticeProviderID = 152
	update map.PracticeProviders SET PracticeProviderGLProviderID = '110  ' WHERE PracticeProviderID = 153
	update map.PracticeProviders SET PracticeProviderGLProviderID = '092  ' WHERE PracticeProviderID = 160

	update map.PracticeProviders set PracticeProviderGLType = 'PA', PracticeProviderGLTypeID = '11' where PracticeProviderID = 111
	UPDATE map.PracticeProviders SET PracticeProviderGLProviderID = '082' WHERE ProviderID = '1~19271'
	update map.PracticeProviders SET PracticeProviderGLType = 'PA', PracticeProviderGLTypeID = '11', PracticeProviderGLProviderID = '002' WHERE ProviderID in ('1~14013')
	update map.PracticeProviders SET ProviderAbbreviation = 'CEB',PracticeProviderGLProviderID = '078' WHERE ProviderID in ('1~19233')
	update map.PracticeProviders SET ProviderAbbreviation = 'CMT',PracticeProviderGLProviderID = '018' WHERE ProviderID in ('1~13956')

	/*5.3.24 - Added record for BET (Thatcher) */
	 INSERT INTO map.PracticeProviders SELECT '0~BET','5~122551','BET',1,'1/1/2021','12/31/2099',1,getdate(),1,1,null,0,0,null,null,null,null

	 /*5/16/24 - Updated flags for TPG Board Packet */
	 update map.PracticeProviders set PracticeProviderIsSpecialist = 1 where PracticeID = '0~RGS'
 
	/*5.30.24 - Added record for Michael Stancliff  and updated allocation for Mason for MSO */
	INSERT INTO map.PracticeProviders SELECT '0~MSO','1~20274','MJS',1,'4/15/2024','12/31/2099',1,getdate(),1,.33333333,null,1,1,'PA','11','112','2'
	UPDATE map.PracticeProviders SET PracticeProviderEndDate = '12/31/2099',PracticeProviderAllocationPercent = null, PracticeProviderFTE = null WHERE PracticeID = '0~MSO' AND ProviderID = '1~13983'
	
	/*5.30.24 - Updated termination record for Jennifer Burns, updated allocation for Jimenez at SMS */
	UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0, PracticeProviderFTE = null WHERE PracticeID = '0~SMS' AND ProviderID = '1~13979'
	UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0.5, PracticeProviderFTE = 1 WHERE PracticeID = '0~SMS' AND ProviderID = '1~20211'

	/*5.30.24 - Updated termination record for Katrina Stewart at BAB */
	UPDATE map.PracticeProviders SET PracticeProviderEndDate = '12/31/2099', PracticeProviderAllocationPercent = null, PracticeProviderFTE = null WHERE PracticeID = '0~BAB' AND ProviderID = '1~17884'

	/*6.7.2 - CMS - Remove allocation percent */
	UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = null where PracticeID = '0~CMS' and providerid in ('1~16310','1~19105')

	/*6.7.2 - DRW -  */
	UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 1 where PracticeID = '0~DRW' and providerid in ('1~13966')

	/*6.7.2 - SCS - Remove Alyssa Race allocation percent */
	UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = null where PracticeID = '0~SCS' and providerid in ('5~142583')

	/*6.7.2 - MSO - Set Mason's allocation percent to 0% so he stays in the packet */
	UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0 where PracticeID = '0~MSO' and providerid in ('1~13983')

	/*6.13.14 - MBJ - Add Yingling */
	INSERT INTO map.PracticeProviders SELECT '0~MBJ','5~P1024887','JRY',0,'6/1/2024','12/31/2099',1,getdate(),1,'0.333333333',null,1,1,'PA','11','113','2'
	UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = '0.333333333' where PracticeProviderFTE is not null AND PracticeID = '0~MBJ'

	/*6.13.14 - DDR - Per Lindsay, remove Dustin Brooks from packet*/
	UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = null,PracticeProviderFTE = 0 where PracticeID = '0~DDR' and ProviderID = '1~18960'
	UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = null,PracticeProviderFTE = null where PracticeID = '0~DDR' and ProviderID not in ('1~13980','1~13962')

	/*6.13.14 - MMD - Per Lindsay, remove mid-level allocation from packet*/
	UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0,PracticeProviderFTE = 1 where PracticeID = '0~MMD' and ProviderID = '5~136623'
	UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 1,PracticeProviderFTE = 1 where PracticeID = '0~MMD' and ProviderID = '5~101349'

	/*6.13.14 - NRW - Per Lindsay, remove mid-level allocation from packet*/
	UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0,PracticeProviderFTE = 1 where PracticeID = '0~NRW' and ProviderID <> '1~13999'
	UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 1,PracticeProviderFTE = 1 where PracticeID = '0~NRW' and ProviderID = '1~13999'

	/*09.03.2024  Added Wade A. Schwerdtfeger, M.D., Shehan J. Abeywardene, M.D., Nicholas R. Johnson, M.D., Eric B. Johnson, M.D.*/
	INSERT INTO map.PracticeProviders VALUES ('0~WAS','5~126434','WAS','1','01/01/2021','12/31/2099','1',GETDATE(),'1','1','1','0',NULL,NULL,NULL,NULL,NULL)
	INSERT INTO map.PracticeProviders VALUES ('0~SJA','5~144782','SJA','1','01/01/2021','12/31/2099','1',GETDATE(),'1','1','1','0',NULL,NULL,NULL,NULL,NULL)
	INSERT INTO map.PracticeProviders VALUES ('0~NRJ','5~144067','NRJ','1','01/01/2021','12/31/2099','1',GETDATE(),'1','1','1','0',NULL,NULL,NULL,NULL,NULL)
	INSERT INTO map.PracticeProviders VALUES ('0~EBJ','5~144543','EBJ','1','01/01/2021','12/31/2099','1',GETDATE(),'1','1','1','0',NULL,NULL,NULL,NULL,NULL)

	UPDATE map.PracticeProviders SET PracticeProviderLocation = NULL, PracticeProviderIsSpecialist = 1, PracticeProviderIsMidLevel = 0 where PracticeID = '0~WAS' and ProviderID = '5~126434'
	UPDATE map.PracticeProviders SET PracticeProviderLocation = NULL, PracticeProviderIsSpecialist = 1, PracticeProviderIsMidLevel = 0 where PracticeID = '0~SJA' and ProviderID = '5~144782'
	UPDATE map.PracticeProviders SET PracticeProviderLocation = NULL, PracticeProviderIsSpecialist = 1, PracticeProviderIsMidLevel = 0 where PracticeID = '0~NRJ' and ProviderID = '5~144067'
	UPDATE map.PracticeProviders SET PracticeProviderLocation = NULL, PracticeProviderIsSpecialist = 1, PracticeProviderIsMidLevel = 0 where PracticeID = '0~EBJ' and ProviderID = '5~144543'
	
	/*09.06.2024 - Updated Michael Stancliff to not be listed as the primary provider in MSO */
	UPDATE map.PracticeProviders SET PracticeProviderIsPrimary = 0 WHERE PracticeID = '0~MSO' and ProviderID = '1~20274'

	/*9-10-24 - SMS - Changed Jimenez allocation from 50% to 0% */
	UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = null, PracticeProviderFTE = null WHERE PracticeID = '0~SMS' AND ProviderID = '1~20211'
	UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = null, PracticeProviderFTE = null WHERE PracticeID = '0~SMS' AND ProviderID = '1~13979'
	UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 1 WHERE PracticeID = '0~SMS' AND ProviderID = '1~14009'

	/*10-07-24 - NMO/NRJ - Added Pape, Olivo, and Dunkleberger as PAs */
	INSERT INTO map.PracticeProviders VALUES ('0~NRJ','5~122305','KMO','0','01/01/2021','12/31/2099','1',GETDATE(),'1','0',NULL,'1','1','PA','11','044','2')
	INSERT INTO map.PracticeProviders VALUES ('0~NRJ','5~104092','RAP','0','01/01/2021','12/31/2099','1',GETDATE(),'1','0',NULL,'1','1','PA','11','030','2')
	INSERT INTO map.PracticeProviders VALUES ('0~NRJ','5~120997','LSD','0','01/01/2021','12/31/2099','1',GETDATE(),'1','0',NULL,'1','1','PA','11','058','2')

	INSERT INTO map.PracticeProviders VALUES ('0~NMO','5~122305','KMO','0','01/01/2021','12/31/2099','1',GETDATE(),'1','0',NULL,'1','1','PA','11','044','2')
	INSERT INTO map.PracticeProviders VALUES ('0~NMO','5~104092','RAP','0','01/01/2021','12/31/2099','1',GETDATE(),'1','0',NULL,'1','1','PA','11','030','2')
	INSERT INTO map.PracticeProviders VALUES ('0~NMO','5~120997','LSD','0','01/01/2021','12/31/2099','1',GETDATE(),'1','0',NULL,'1','1','PA','11','058','2')

	
/* 2.11.25 - Per Nick - Updates to BAB - Remove Cloran from Blue Book midlevel pages*/
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = NULL, PracticeProviderFTE = null, PracticeProviderUpdatedDatetime = getdate() WHERE PracticeID = '0~BAB' and ProviderID = '1~14012'
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0.5, PracticeProviderUpdatedDatetime = getdate() WHERE PracticeID = '0~BAB' and ProviderID in ('1~19329','1~13947')


/* 2.11.25 - Per Nick - Updates to LCS - Remove Ramer from Blue Book midlevel pages*/
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = NULL, PracticeProviderFTE = null, PracticeProviderUpdatedDatetime = getdate() WHERE PracticeID = '0~LCS' and ProviderID = '1~19749'
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0.33333333, PracticeProviderUpdatedDatetime = getdate() WHERE PracticeID = '0~LCS' and ProviderID in ('1~19301','1~19300','1~20199')


/* 2.11.25 - Per Nick - Updates to MSO - Remove Mason from Blue Book midlevel pages*/
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = NULL, PracticeProviderFTE = null, PracticeProviderUpdatedDatetime = getdate() WHERE PracticeID = '0~MSO' and ProviderID = '1~13983'

/* 2.13.25 - Per Nick - Updates to SCS - Set Pfaff allocation to 33%*/
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0.33333333, PracticeProviderFTE = 1, PracticeProviderUpdatedDatetime = getdate() WHERE PracticeID = '0~sCS' and ProviderID = '5~127870'
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0.33333333, PracticeProviderUpdatedDatetime = getdate() WHERE PracticeID = '0~SCS' and ProviderID in ('5~105546','5~109725')

/*2.14.25 - RLN and MBJ - Add Yingling to RLN; Update Allocation Percents for RLN per Nick */
INSERT INTO map.PracticeProviders SELECT '0~RLN','5~P1024887','JRY',0,'1/1/2025','12/31/2099',1,getdate(),1,'0',null,1,1,'PA','11','113','2'
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = '0' where ProviderID = '5~P1024887' AND PracticeID = '0~MBJ'
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = '0.50',PracticeProviderUpdatedDatetime = getdate() where ProviderID in ('1~13992','1~18424') AND PracticeID = '0~MBJ'


/* 4.14.25 - Per Nick - Updates to SCS - Set Pfaff allocation to 33%*/
INSERT INTO map.PracticeProviders SELECT '0~SCS','5~114504','PLM',0,'4/1/2025','12/31/2099',1,getdate(),1,'0',null,0,1,'APRN','12','118','2'


/* 5.12.25 - Per Nick - Updates to SCS - Set Migliaccio allocation to 100% for Choctaw (34) only*/
UPDATE map.PracticeProviders SET PracticeProviderLocation = 'Shadid Choctaw',PracticeProviderAllocationPercent = 1.00, PracticeProviderUpdatedDatetime = getdate() WHERE PracticeID = '0~SCS' and ProviderID in ('5~114504')

/* 7.7.25 - Per Nick - Updates to RLN - Remove Yingling and Scarborough from Blue Book midlevel pages*/
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = NULL, PracticeProviderFTE = null, PracticeProviderUpdatedDatetime = getdate() WHERE PracticeID = '0~RLN' and ProviderID in ('1~19711','5~P1024887')
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = .5, PracticeProviderUpdatedDatetime = getdate() WHERE PracticeID = '0~RLN' and ProviderID in ('1~17426','1~14006')

/* 7.16.25 Per Nick removed all of the mid level providers from NRJ, and added Gilchrist*/
--delete from map.PracticeProviders where PracticeProviderID in ('173','174','175')
INSERT INTO map.PracticeProviders SELECT '0~NRJ','5~146086','KEG',0,'7/1/2025','12/31/2099',1,getdate(),1,'0',null,1,1,'PA','11','120',null
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = .5, PracticeProviderUpdatedDatetime = getdate() WHERE PracticeID = '0~NRJ' AND ProviderID in ('5~143697','5~146086')

/* 7.16.25 - Per Nick - Updates to MBJ - Remove Yingling from Blue Book midlevel pages*/
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = NULL, PracticeProviderFTE = null, PracticeProviderUpdatedDatetime = getdate() WHERE PracticeID = '0~MBJ' and ProviderID = '5~P1024887'

/* 7.16.25 - Per Nick - Updates to SCS - Remove Courtney Needham from Blue Book midlevel pages*/
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = NULL, PracticeProviderFTE = null, PracticeProviderUpdatedDatetime = getdate() WHERE PracticeID = '0~SCS' and ProviderID = '5~102684'
		
/* 7.16.25 - Per Nick - Updates gl codes for June*/
UPDATE map.PracticeProviders SET PracticeProviderGLTypeID = '01', PracticeProviderGLProviderID = '000', PracticeProviderUpdatedDatetime = getdate() WHERE PracticeID = '0~RLN' and ProviderID = '1~19711'
UPDATE map.PracticeProviders SET PracticeProviderGLTypeID = '01', PracticeProviderGLProviderID = '000', PracticeProviderUpdatedDatetime = getdate() WHERE PracticeID = '0~RLN' and ProviderID = '5~P1024887'
update dim.practices SET PracticeIsActive = 0 where PracticeID in ('0~CMS')
update dim.practices SET PracticeIsActive = 0 where PracticeID in ('0~CMS')
			
/* 8.12.25 Added Nathan Harris to LCS*/
INSERT INTO map.PracticeProviders SELECT '0~LCS','5~148220','NAH',0,'6/18/2025','12/31/2099',1,getdate(),1,'0.25',null,1,1,'APRN','12','119',null
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = .25, PracticeProviderUpdatedDatetime = getdate() WHERE PracticeID = '0~LCS' AND ProviderID in ('1~19301','1~19300','1~20199')


/* 9.8.25 Added Erin Olmsted to MEC*/
INSERT INTO map.PracticeProviders SELECT '0~MEC','5~P1015064','EMO',0,'8/1/2025','12/31/2099',1,getdate(),1,'0.33333333',null,0,1,'APRN','12','121',1
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = .33333333, PracticeProviderUpdatedDatetime = getdate() WHERE PracticeID = '0~MEC' AND ProviderID in ('1~19087','1~18747')

/* 9.8.25 Added Ryan D. Wilson, Chelsea Rommel, and Charley Baldwin to RDW*/
INSERT INTO map.PracticeProviders SELECT '0~RDW','5~105843','RDW',1,'9/15/2025','12/31/2099',1,getdate(),1,'0.33333333',null,0,0,NULL,NULL,NULL,NULL
INSERT INTO map.PracticeProviders SELECT '0~RDW','5~P1015494','CMR',0,'10/8/2025','12/31/2099',1,getdate(),1,'0.33333333',null,0,1,'Associate','21','122',1
INSERT INTO map.PracticeProviders SELECT '0~RDW','5~126977','CCB',0,'10/8/2025','12/31/2099',1,getdate(),1,'0.33333333',null,0,1,'APRN','12','123',1

/* 9.8.25 Added Laura B. Buford to LBB*/
INSERT INTO map.PracticeProviders SELECT '0~LBB','1~20387','LBB',1,'9/1/2025','12/31/2099',1,getdate(),1,'1.0',null,1,0,NULL,NULL,NULL,NULL

/* 9.8.25 Added Cooksey to NPS*/
INSERT INTO map.PracticeProviders SELECT '0~NPS','5~P1035082','KRC',0,'7/1/2025','12/31/2099',1,getdate(),1,0,null,1,1,NULL,NULL,NULL,NULL


/* 10.1.25 Added Goforth to WSB*/
INSERT INTO map.PracticeProviders SELECT '0~WSB','5~114118','SRG',0,'1/1/2000','12/31/2099',1,getdate(),1,0,null,0,0,'PA','11','115',NULL


/* 10.1.2025 Added Jamie Merideth to TAK*/
update map.practiceproviders set ProviderID = '1~19378', ProviderAbbreviation = 'JDM', PracticeProviderIsActive = 1, PracticeProviderUpdatedDatetime = getdate(), PracticeProviderIsSpecialist = 0
,PracticeProviderGLType = 'APRN', PracticeProviderGLTypeID = '12', PracticeProviderGLProviderID = '085'
where PracticeProviderID = 193

/* 10.1.2025 Updated Allocation Percents per Nick */
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0.7, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 1
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0.3, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 134
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0.5, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 2
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0.5, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 136
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0.5, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 8
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0.5, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 120
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 1, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 165
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 1, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 7
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0.33333333, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 16
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0.33333333, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 29
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0.33333333, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 179
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 1, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 172
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 1, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 21
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 1, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 27
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 1, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 33
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 1, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 198
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0.25, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 116
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0.25, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 152
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0.25, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 192
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0.25, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 117
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0.5, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 38
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0.5, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 85
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0.5, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 96
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 106
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0.5, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 194
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0.5, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 39
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0.5, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 101
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0.5, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 41
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0.5, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 15
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 166
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0.5, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 122
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0.5, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 139
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 1, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 132
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0.5, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 171
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0.5, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 191
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 1, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 105
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0.33333333, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 43
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 81
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0.33333333, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 32
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0.33333333, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 45
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0.5, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 195
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0.5, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 197
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 196
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0.5, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 121
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0.5, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 160
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0.5, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 47
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0.5, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 63
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 1, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 48
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0.33333333, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 144
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0.33333333, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 162
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0.33333333, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 163
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0.33333333, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 142
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 1, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 182
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0.33333333, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 148
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0.33333333, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 154
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 1, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 170
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0.5, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 50
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0.5, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 180
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 1, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 55
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 65
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 193
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0.33333333, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 78
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0.33333333, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 126
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0.33333333, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 140
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 92
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 1, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 169
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 1, PracticeProviderUpdatedDatetime = GETDATE() WHERE PracticeProviderID = 59

/* 10.14.25 - Per Michael - Updates gl codes for October - Changed Other Provider record from 084 to 000*/
UPDATE map.PracticeProviders SET PracticeProviderGLProviderID = '000', PracticeProviderUpdatedDatetime = getdate() WHERE PracticeID = '0~SCS' and ProviderID = '5~117670'


/* 11.10.25 Added Annabeth Heinz to DDR*/
INSERT INTO map.PracticeProviders SELECT '0~DDR','1~20392','ACH',0,'10/1/2025','12/31/2099',1,getdate(),1,0,null,1,1,'PA',11,124,2

/* 2.9.26 - Per Nick - Updates to NMO - Remove midlevels from Blue Book */
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = NULL, PracticeProviderFTE = null, PracticeProviderUpdatedDatetime = getdate() WHERE PracticeID = '0~NMO' and ProviderID = '5~122305'
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = NULL, PracticeProviderFTE = null, PracticeProviderUpdatedDatetime = getdate() WHERE PracticeID = '0~NMO' and ProviderID = '5~104092'
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = NULL, PracticeProviderFTE = null, PracticeProviderUpdatedDatetime = getdate() WHERE PracticeID = '0~NMO' and ProviderID = '5~120997'


/* 2.9.26 - Per Nick - Updates to TDT - Remove midlevels from Blue Book and reset allocation percentages*/
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = NULL, PracticeProviderFTE = null, PracticeProviderUpdatedDatetime = getdate() WHERE PracticeID = '0~TDT' and ProviderID = '1~19990'
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0.25, PracticeProviderUpdatedDatetime = getdate() WHERE PracticeID = '0~TDT' and ProviderID = '1~19481'
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = 0.75, PracticeProviderUpdatedDatetime = getdate() WHERE PracticeID = '0~TDT' and ProviderID = '1~17989'

/* 3.2.26 Added Taylor Ramos Gatliff to TDT*/
INSERT INTO map.PracticeProviders SELECT '0~TDT','5~139562','TRG',0,'2/1/2026','12/31/2099',1,getdate(),1,0,'Binger',0,1,'APRN',12,125,2


/*3.31.26 - Per Nick - Updates to TDT - Update PracticeProviderGLProviderID*/
UPDATE map.PracticeProviders SET PracticeProviderGLProviderID = '000', PracticeProviderUpdatedDatetime = getdate() WHERE PracticeID = '0~TDT' and ProviderID = '1~19481'
UPDATE map.PracticeProviders SET PracticeProviderGLProviderID = '000', PracticeProviderUpdatedDatetime = getdate() WHERE PracticeID = '0~TDT' and ProviderID = '1~19990'
UPDATE map.PracticeProviders SET PracticeProviderGLType = NULL, PracticeProviderGLTypeID = NULL, PracticeProviderUpdatedDatetime = getdate() WHERE PracticeID = '0~TDT' and ProviderID = '1~17989'

/*3.31.26 - Per Nick - Updates to TAK - Remove Jennifer Roberts from Blue Book */
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = NULL, PracticeProviderFTE = null, PracticeProviderGLProviderID = '000', PracticeProviderUpdatedDatetime = getdate() WHERE PracticeID = '0~TAK' and ProviderID = '1~17530'

/*3.31.26 Added Chris Harris to CDH*/
INSERT INTO map.PracticeProviders SELECT '0~CDH','5~135242','CDH',1,'3/23/2026','12/31/2099',1,getdate(),1,1,null,0,0,NULL,NULL,NULL,NULL

/*3.31.26 Added Ashley Martin to SCS*/
INSERT INTO map.PracticeProviders SELECT '0~SCS','5~150822','AAM',0,'3/16/2026','12/31/2099',1,getdate(),1,0,'Shadid Choctaw',0,1,'APRN',12,126,2

/*3.31.26 Added Maria Nguyen to DDR*/
INSERT INTO map.PracticeProviders SELECT '0~DDR','1~20402','MN',0,'3/23/2026','12/31/2099',1,getdate(),1,0,NULL,1,1,'PA',11,127,2

/*4.30.26 - Per Michael - Updates to TDT - Update PracticeProviderGLProviderID for Dahlenburg back to 088*/
UPDATE map.PracticeProviders SET PracticeProviderGLProviderID = '088', PracticeProviderUpdatedDatetime = getdate() WHERE PracticeID = '0~TDT' and ProviderID = '1~19481'
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = '0.33333333', PracticeProviderUpdatedDatetime = getdate() WHERE PracticeID = '0~TDT' and ProviderID in ('1~17989','1~19481','5~139562')

/*4.30.26 Added Thilly Nelson to DDR*/
INSERT INTO map.PracticeProviders SELECT '0~DDR','5~131334','TRN',0,'4/6/2026','12/31/2099',1,getdate(),1,0,NULL,1,1,'APRN',12,128,2

/*4.30.26 Added Hannah Hover to NPS*/
INSERT INTO map.PracticeProviders SELECT '0~NPS','5~P1024750','HAH',0,'3/1/2026','12/31/2099',1,getdate(),1,0,NULL,1,1,NULL,NULL,NULL,NULL

/*4.30.26 Added Paul Maitino to PDM*/
INSERT INTO map.PracticeProviders SELECT '0~PDM','5~103250','PDM',1,'3/1/2026','12/31/2099',1,getdate(),1,1,NULL,1,0,NULL,NULL,NULL,NULL

/*6.2.26 - Per Michael - Updates gl codes for April - Changed Other Provider record for DUNKLEBERGER, LLOYD S from 058 to 000*/
UPDATE map.PracticeProviders SET PracticeProviderGLProviderID = '000', PracticeProviderUpdatedDatetime = getdate() WHERE PracticeID = '0~PBJ' and ProviderID = '1~18356'

/*7.1.26 - Per Nick - Updates to TDT - Remove Moss from Blue Book*/
UPDATE map.PracticeProviders SET PracticeProviderAllocationPercent = NULL, PracticeProviderFTE = null, PracticeProviderGLProviderID = '000', PracticeProviderUpdatedDatetime = getdate() WHERE PracticeID = '0~TDT' and ProviderID = '1~18624'

/*7.1.26 Added Kenzie V. Hart to ACC*/
INSERT INTO map.PracticeProviders SELECT '0~ACC','5~P1040276','KVH',0,'5/26/2026','12/31/2099',1,getdate(),1,0,NULL,1,1,'PA',11,130,2


	select * from map.vPracticeProviders p where p.PracticeID = '0~acc'
	
	select * from map.vPracticeProviders p where p.PracticeID = '0~NRJ'
	select * from dim.Practices p where p.PracticeName like '%Harris%'
	
select * from dim.vProviders p where p.ProviderFullName like '%HART, KEN%'

	select * from dim.vProviders p where p.providerdatasourceid = 10 and providerfullname like '%Nguyen%' order by Providerupdateddatetime

*/





--SELECT * FROM dim.vproviders p where p.ProviderFullName like '%Gatliff%'
--SELECT * FROM dim.vproviders p where p.ProviderFullName like 'Buford, L%'
--SELECT * FROM dim.vproviders p where p.ProviderFullName like 'Rommel%'
--SELECT * FROM dim.vproviders p where p.ProviderFullName like 'Baldwin, C%'
GO
