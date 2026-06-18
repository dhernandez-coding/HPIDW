CREATE PROCEDURE [rpt].[spLoadMetricNewMetric] AS

		-- ==================================================================
		-- Author:		Robert Beaird
		-- Create date: 6-3-2024
		-- Edit date:   6-7-2024
		-- Description:	Creates new row items for new metrics to be loaded
		-- ==================================================================

-----------------------------------------------------------------------------
--			1 - Comment out "ALTER PROCEDURE..." line above.				-
--			2 - Fill values into DECLARE staments below.					-
--			3 - Execute entire query page.									-
-----------------------------------------------------------------------------


DECLARE @MetName [varchar](100) =				''									-- Name of Metric
DECLARE @MetDescription [varchar](300) =		'' 									-- Description of Metric
DECLARE @MetQuerySource [varchar](100) =		''									-- Primary table being queried for Metric
DECLARE @MetLoadProcedure [varchar](100) =		''									-- Stored procedure use to load Metric
DECLARE @MetTypeID [int] =						1									-- 1: Single value, 2: Fraction, 3: Percentage
DECLARE @MetCategory [varchar](20) =			''									-- 'Provider'	OR	'Hospital'
DECLARE @MetCreateDate [date] =					FORMAT(GETDATE(), 'YYYY-MM-DD')		-- Do not change, inserts current date


IF LEN(@MetName) > 5 BEGIN

	INSERT INTO [HPIDW].[rpt].[Metrics](
		[MetricName]
		,[MetricDescription]
		,[MetricQuerySource]
		,[MetricLoadProcedure]
		,[MetricTypeID]
		,[MetricCategory]
		,[MetricUpdateDate]
		,[MetricCreateDate]
	)

	SELECT
		@MetName
		,@MetDescription
		,@MetQuerySource
		,@MetLoadProcedure
		,@MetTypeID
		,@MetCategory
		,@MetCreateDate
		,@MetCreateDate;
END
ELSE BEGIN
    RAISERROR ('Use a more descriptive metric name...', 16, 1);
END;
GO
