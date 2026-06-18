-- =============================================
-- Author:		Riley Roberson
-- Create date: 02-19-2024
-- Description:	Uses  Chris/Zeke's logic daily census export to capture 2am/2pm time but stretched back over the past month
-- Change Control: v1
-- =============================================
CREATE PROCEDURE [rpt].[spLoadHistoricalCensus]
AS


BEGIN 
SET NOCOUNT ON;

IF OBJECT_ID(N'Tempdb..#Load') IS NOT NULL
DROP TABLE #Load
IF OBJECT_ID(N'Tempdb..#Time') IS NOT NULL
DROP TABLE #Time
IF OBJECT_ID(N'Tempdb..##TempCensus') IS NOT NULL
DROP TABLE ##TempCensus


DECLARE @currentdate date
DECLARE @lastmonthdate date 
DECLARE @BeginningMonth date
DECLARE @NextMonth date
SET @currentdate = cast(GETDATE() as date)
SET @lastmonthdate = DATEADD(DD, -30, @currentdate)
SET @BeginningMonth = CAST(DATEADD(m, DATEDIFF(m, 0, @currentdate), 0) as date)
SET @NextMonth =  CAST(DATEADD(m, DATEDIFF(m, -1, @currentdate), 0) as date)

SELECT DISTINCT
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
	FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[CLARITY_ADT] adtin 
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
	WHERE 1=1 
		AND adtin.EFFECTIVE_TIME < @NextMonth AND adtout.EFFECTIVE_TIME >= @BeginningMonth
		AND adtin.EVENT_TYPE_C IN (1,3)
		AND a.disch_loc_id IN (43004001, 43005005, 43006001) /*HPI CHN, HPI CHS, HPI NWSH*/
		ORDER BY adtin.effective_time
--SELECT * FROM #Load
			
	SELECT
		d.Date
		,ct.CensusTime
		,convert(datetime,d.Date) + convert(datetime,ct.CensusTime) as CensusDatetime
		,d.WeekDayName
		,d.IsWeekend
		,d.IsHoliday
	INTO #Time
	FROM dim.Dates d
		cross apply (select TIMEFROMPARTS(2,0,0,0,0) as CensusTime UNION ALL SELECT TIMEFROMPARTS(14,0,0,0,0)) ct
	WHERE d.Date between @lastmonthdate and @currentdate -- 30 days start and end date variables
	--select * from #Time


	SELECT *
	INTO ##TempCensus
	FROM #Time T
	LEFT JOIN #Load L
	ON L.InEventTime <= T.CensusDatetime AND L.OutEventTime >= T.CensusDatetime
	WHERE 1=1
--	AND Bed IN ('102-01')
--	and censusdatetime = '2023-10-01 02:00:00.000'
	ORDER BY CensusDatetime, PatEncCSNID

SELECT * FROM ##TempCensus

END
GO
