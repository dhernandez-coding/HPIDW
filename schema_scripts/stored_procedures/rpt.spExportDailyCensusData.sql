-- =============================================
-- Author:		Zeke Herrera
-- Create date: 11/08/2023
-- Description:	Compiles data for Census Report 
-- Change Control: 
--	
-- =============================================
CREATE PROCEDURE [rpt].[spExportDailyCensusData] @currentdate date
AS

BEGIN 
SET NOCOUNT ON;


IF OBJECT_ID(N'Tempdb..##TempCensus') IS NOT NULL
DROP TABLE ##TempCensus



DECLARE @sql      varchar(8000)
      , @path     varchar(100)
      , @filename varchar(100)
--DECLARE @currentdate date
DECLARE @yesterdaydate date 
DECLARE @BeginningMonth date
DECLARE @NextMonth date
--SET @currentdate = cast(GETDATE() as date)
SET @yesterdaydate = DATEADD(DD, -1, @currentdate)
SET @BeginningMonth = CAST(DATEADD(m, DATEDIFF(m, 0, @currentdate), 0) as date)
SET @NextMonth =  CAST(DATEADD(m, DATEDIFF(m, -1, @currentdate), 0) as date)


set @path = 'C:\Users\Public\CensusData\CensusDataOutput\'
set @filename
     = 'HPI_CensusDaily' + CONVERT(NVARCHAR(10), @yesterdaydate, 112) + '_to_' + CONVERT(NVARCHAR(10), @currentdate, 112)



select distinct
		adtin.PAT_ENC_CSN_ID AS PatEncCSNID
		,p.pat_name AS PatientName
		,adtin.PAT_CLASS_C 
		,pc.NAME as PatientClass
		,etin.NAME as EventType
		,adtin.EFFECTIVE_TIME as InEventTime
		,adtout.EFFECTIVE_TIME as OutEventTime
		,etout.Name as OutEventType
		,rm.ROOM_NAME as Room
		,bd.BED_LABEL as Bed
		,l.LocationName
		,a.disch_loc_id 
		,eh.HOSP_ADMSN_TIME as VisitAdmitDatetime
		,eh.HOSP_DISCH_TIME as VisitDischargeDatetime
	INTO #Load
	from [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[CLARITY_ADT] adtin 
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[CLARITY_ADT] adtout ON adtin.NEXT_OUT_EVENT_ID = adtout.EVENT_ID
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[ZC_EVENT_TYPE] etin ON etin.EVENT_TYPE_C = adtin.EVENT_TYPE_C
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[ZC_EVENT_TYPE] etout ON etout.EVENT_TYPE_C = adtout.EVENT_TYPE_C
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[CLARITY_ROM] rm ON rm.ROOM_CSN_ID = adtin.ROOM_CSN_ID 
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[CLARITY_BED] bd ON bd.BED_CSN_ID = adtin.BED_CSN_ID
		LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].PAT_ENC_HSP eh ON eh.PAT_ENC_CSN_ID = adtin.PAT_ENC_CSN_ID
		LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[PATIENT] p ON EH.PAT_ID = P.PAT_ID
		INNER JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].HSP_ACCOUNT a  ON eh.PAT_ENC_CSN_ID = a.PRIM_ENC_CSN_ID
		LEFT JOIN [HPIDW].[dim].[vLocations] l ON a.adm_loc_id = l.LocationSourceID
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[ZC_PAT_CLASS] pc ON pc.ADT_PAT_CLASS_C = adtin.PAT_CLASS_C
	where 1=1 
		AND adtin.EFFECTIVE_TIME < @NextMonth AND adtout.EFFECTIVE_TIME >= @BeginningMonth
		AND adtin.EVENT_TYPE_C IN (1,3)
		AND a.disch_loc_id IN (43004001, 43005005, 43006001) /*HPI CHN, HPI CHS, HPI NWSH*/
		ORDER BY adtin.effective_time


	select
		d.Date
		,ct.CensusTime
		,convert(datetime,d.Date) + convert(datetime,ct.CensusTime) as CensusDatetime
	INTO #Time
	from dim.Dates d
		cross apply (select TIMEFROMPARTS(2,0,0,0,0) as CensusTime UNION ALL SELECT TIMEFROMPARTS(14,0,0,0,0)) ct
	where d.Date between @yesterdaydate and @currentdate



	select *
	INTO ##TempCensus
	FROM #Time T
	LEFT JOIN #Load L
	ON L.InEventTime <= T.CensusDatetime AND L.OutEventTime >= T.CensusDatetime
	WHERE 1=1
--	AND Bed IN ('102-01')
--	and censusdatetime = '2023-10-01 02:00:00.000'
	order by CensusDatetime, PatEncCSNID

	
	--select * 
	--FROM ##TempCensus

DECLARE @query varchar(8000) = 'SET NOCOUNT ON;' + 
'SELECT CAST(DATE as varchar(20)), '','',' + 
'CAST(CensusTime as varchar(20)), '','',' + 
'CAST(CensusDateTime as varchar(25)), '','',' +
'CAST(PatEncCSNID as varchar(20)), '','',' +
'CAST(PatientName as varchar(30)), '','',' +
'CAST(PAT_CLASS_C as varchar(20)), '','',' +
'CAST(PatientClass as varchar(40)), '','',' +
'CAST(EventType as varchar(25)), '','',' +
'CAST(InEventTime as varchar(20)), '','',' +
'CAST(OutEventTime as varchar(20)), '','',' +
'CAST(OutEventType as varchar(20)), '','',' +
'CAST(Room as varchar(30)), '','',' +
'CAST(Bed as varchar(30)), '','',' +
'CAST(LocationName as varchar(35)), '','',' +
'CAST(Disch_Loc_ID as varchar(20)), '','',' +
'CAST(VisitAdmitDatetime as varchar(20)), '','',' +
'CAST(VisitDischargeDatetime as varchar(20)) FROM ##TempCensus'



select @sql
    = 'sqlcmd -S ' + @@SERVERNAME + ' -d HPIDW -E -h -1 -Q "' + @query + '"	-o "' + @path + @filename
      + '.csv" -s ""'




exec sp_configure 'show advanced options', 1;
reconfigure;
exec sp_configure 'xp_cmdshell', 1;
reconfigure;



/*Execute Command*/
exec master..xp_cmdshell @sql



exec sp_configure 'xp_cmdshell', 0;
reconfigure;
exec sp_configure 'show advanced options', 0;
reconfigure;




	
	drop table ##TempCensus
	drop table #Load
	drop table #Time





END
GO
