CREATE PROCEDURE [stg].[spEPICReloadFactVisitCaseTimesFull] 
AS
BEGIN
    -- Step 1: Delete existing records for the data source
    DELETE FROM fact.VisitCaseTimes 
    WHERE VisitCaseTimesDataSourceID = 5;

    -- Step 2: Define temp table #Temp
    IF OBJECT_ID(N'tempdb..#VCTPerformed') IS NOT NULL
    BEGIN
        DROP TABLE #VCTPerformed;
    END;

    IF OBJECT_ID(N'tempdb..#VCTSchedule') IS NOT NULL
    BEGIN
        DROP TABLE #VCTSchedule;
    END;

	IF OBJECT_ID(N'tempdb..#Temp') IS NOT NULL
    BEGIN
        DROP TABLE #Temp;
    END;

--Temp Table for VCT Performed
    SELECT 
        b.UTILIZATION_ID AS UtilizationID,
        u.CASE_ID AS CaseID,
        b.LINE AS Sequence,
        b.START_DTTM AS EventStartTime,
        b.END_DTTM AS EventEndTime,
        CASE WHEN b.LINE >= 1 AND b.PROC_YN = 'Y' AND st.NAME = 'In Block' THEN b.START_DTTM END AS ProcedureInBlockStartTime,
        CASE WHEN b.LINE >= 1 AND b.PROC_YN = 'Y' AND st.NAME = 'In Block' THEN b.END_DTTM END AS ProcedureInBlockEndTime,
		CASE WHEN b.LINE >= 1 AND b.PROC_YN = 'Y' AND st.NAME = 'Out of Block' THEN b.START_DTTM END AS ProcedureOutOfBlockStartTime,
        CASE WHEN b.LINE >= 1 AND b.PROC_YN = 'Y' AND st.NAME = 'Out of Block' THEN b.END_DTTM END AS ProcedureOutOfBlockEndTime,
		CASE WHEN b.LINE >= 1 AND b.PROC_YN = 'Y' AND st.NAME = 'Overbook' THEN b.START_DTTM END AS ProcedureOverbookStartTime,
        CASE WHEN b.LINE >= 1 AND b.PROC_YN = 'Y' AND st.NAME = 'Overbook' THEN b.END_DTTM END AS ProcedureOverbookEndTime,
        cb.PROCEDURE_START_DTTM,
        cb.PROCEDURE_END_DTTM,
        st.NAME AS SlotType,
        sr.NAME AS SlotReason,
        b.SLOT_LENGTH AS SlotLength,
        b.PROC_YN AS IsProcedure,
        b.REASON_COMMENTS AS ReasonComments,
        CASE WHEN rt.DELAY_REASON_NM IS NULL THEN 'N' ELSE 'Y' END AS IsDelayed,
        rt.DELAY_REASON_NM AS DelayReason
    INTO #VCTPerformed
    FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].UTL_OR_CASE_BLOCK_PERF b
        LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].UTILIZATION u ON u.UTILIZATION_ID = b.UTILIZATION_ID
        LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].V_CASE_ROOM_TURNOVER rt ON rt.CASE_ID = u.CASE_ID
        LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].OR_CASE oc ON oc.OR_CASE_ID = u.CASE_ID
        LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].UTL_OR_CASE_BLOCK_SUM_P cb ON cb.UTILIZATION_ID = b.UTILIZATION_ID
        LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_BLOCK_SLOT_TYPE st ON st.BLOCK_SLOT_TYPE_C = b.BLOCK_SLOT_TYPE_C
        LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_USED_SLOT_REASON sr ON sr.USED_SLOT_REASON_C = b.USED_SLOT_REASON_C
    WHERE oc.LOC_ID IN ('43001006','43001007','43001008','43002001','43004001','43004002','43004003','43004004','43005005','43005006','43005007','43005008','43006001','43006002','43006003','43006004','430050061')

	--Temp Table for VCT Schedule
	    SELECT 
        cbs.UTILIZATION_ID AS UtilizationID,
        u.CASE_ID AS CaseID,
        cbs.LINE AS ScheduleSequence,
		MAX(cbs.LINE) as ScheduleSequenceMax,
        cbs.START_DTTM AS EventStartTime,
        cbs.END_DTTM AS EventEndTime,
        CASE WHEN cbs.LINE >= 1 AND cbs.PROC_YN = 'Y' AND st.NAME = 'In Block' THEN cbs.START_DTTM END AS ProcedureInBlockStartTime,
        CASE WHEN cbs.LINE >= 1 AND cbs.PROC_YN = 'Y' AND st.NAME = 'In Block' THEN cbs.END_DTTM END AS ProcedureInBlockEndTime,
		CASE WHEN cbs.LINE >= 1 AND cbs.PROC_YN = 'Y' AND st.NAME = 'Out of Block' THEN cbs.START_DTTM END AS ProcedureOutOfBlockStartTime,
        CASE WHEN cbs.LINE >= 1 AND cbs.PROC_YN = 'Y' AND st.NAME = 'Out of Block' THEN cbs.END_DTTM END AS ProcedureOutOfBlockEndTime,
		CASE WHEN cbs.LINE >= 1 AND cbs.PROC_YN = 'Y' AND st.NAME = 'Overbook' THEN cbs.START_DTTM END AS ProcedureOverbookStartTime,
        CASE WHEN cbs.LINE >= 1 AND cbs.PROC_YN = 'Y' AND st.NAME = 'Overbook' THEN cbs.END_DTTM END AS ProcedureOverbookEndTime,
        cb.PROCEDURE_START_DTTM,
        cb.PROCEDURE_END_DTTM,
        bt.NAME AS SlotType,
        cbs.SLOT_LENGTH AS SlotLength,
        cbs.PROC_YN AS IsProcedure,
        cbs.REASON_COMMENTS AS ReasonComments,
		bt.NAME as ScheduleSlotType
  INTO #VCTSchedule
  FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].UTL_OR_CASE_BLOCK_SCH cbs
        LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].UTILIZATION u ON u.UTILIZATION_ID = cbs.UTILIZATION_ID
        LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].OR_CASE oc ON oc.OR_CASE_ID = u.CASE_ID
        LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].UTL_OR_CASE_BLOCK_SUM_P cb ON cb.UTILIZATION_ID = cbs.UTILIZATION_ID
        LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_BLOCK_SLOT_TYPE st ON st.BLOCK_SLOT_TYPE_C = cbs.BLOCK_SLOT_TYPE_C
		LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_BLOCK_SLOT_TYPE bt on bt.BLOCK_SLOT_TYPE_C = cbs.BLOCK_SLOT_TYPE_C
    WHERE oc.LOC_ID IN ('43001006','43001007','43001008','43002001','43004001','43004002','43004003','43004004','43005005','43005006','43005007','43005008','43006001','43006002','43006003','43006004','430050061')
		--and u.CASE_ID = '2519580' --cbs.LINE > 9 5~2519580
	GROUP BY
		cbs.UTILIZATION_ID,
        u.CASE_ID,
        cbs.LINE,
        cbs.START_DTTM,
        cbs.END_DTTM,
        cb.PROCEDURE_START_DTTM,
        cb.PROCEDURE_END_DTTM,
        bt.NAME ,
        cbs.SLOT_LENGTH,
        cbs.PROC_YN,
        cbs.REASON_COMMENTS,
		bt.NAME,
		st.NAME
	ORDER BY cbs.LINE;

    
SELECT
	vct.*
INTO #Temp
FROM(   
-- VCT Performed
	 SELECT
        CONCAT('5~',t.CaseID,'~Performed') AS VisitCaseTimesCaseID,
        '5' AS VisitCaseTimesDataSourceID,
		t.CaseID as VisitCaseTimesSourceID,
		'Performed' as VisitCaseTimeType,
        MAX(CASE WHEN t.Sequence = 1 AND t.IsProcedure = 'N' THEN t.EventStartTime END) AS VCTPreSetupStartTime,
        MAX(CASE WHEN t.Sequence = 1 AND t.IsProcedure = 'N' THEN t.EventEndTime END) AS VCTPreSetupEndTime,
        MIN(CASE WHEN t.Sequence > 1 AND t.IsProcedure = 'N' AND t.SlotType = 'OverBook' AND t.EventStartTime < sub.ProcedureInBlockStartTime THEN t.EventStartTime END) AS VCTPreSetupOverbookStartTime,
        MAX(CASE WHEN t.Sequence > 1 AND t.IsProcedure = 'N' AND t.SlotType = 'OverBook' AND t.EventEndTime <= sub.ProcedureInBlockStartTime THEN t.EventEndTime END) AS VCTPreSetupOverbookEndTime,
        MIN(CASE WHEN t.Sequence > 1 AND t.IsProcedure = 'N' AND t.SlotType = 'In Block' AND t.EventStartTime < sub.ProcedureInBlockStartTime THEN t.EventStartTime END) AS VCTPreSetupInBlockStartTime,
        MAX(CASE WHEN t.Sequence > 1 AND t.IsProcedure = 'N' AND t.SlotType = 'In Block' AND t.EventEndTime <= sub.ProcedureInBlockStartTime THEN t.EventEndTime END) AS VCTPreSetupInBlockEndTime,
        MIN(CASE WHEN sub.ProcedureInBlockStartTime > t.EventStartTime AND t.IsProcedure = 'Y' AND t.SlotType = 'OverBook' THEN t.EventStartTime END) AS VCTProcedureOverbookPreInBlockStartTime,
        MAX(CASE WHEN sub.ProcedureInBlockStartTime >= t.EventEndTime AND t.IsProcedure = 'Y' AND t.SlotType = 'OverBook' THEN t.EventEndTime END) AS VCTProcedureOverbookPreInBlockEndTime,
		MIN(CASE WHEN (sub.ProcedureInBlockStartTime > t.EventStartTime or sub.ProcedureOutOfBlockStartTime = t.EventEndTime) AND t.IsProcedure = 'Y' AND t.SlotType = 'Out of Block' THEN t.EventStartTime END) AS VCTProcedureOutOfBlockPreInBlockStartTime,
        MAX(CASE WHEN (sub.ProcedureInBlockStartTime >= t.EventEndTime or sub.ProcedureOutOfBlockStartTime >= t.EventEndTime) AND t.IsProcedure = 'Y' AND t.SlotType = 'Out of Block' THEN t.EventEndTime END) AS VCTProcedureOutOfBlockPreInBlockEndTime,
        MAX(t.ProcedureInBlockStartTime) AS VCTProcedureInBlockStartTime,
        MAX(t.ProcedureInBlockEndTime) AS VCTProcedureInBlockEndTime,
        MAX(CASE WHEN sub.ProcedureInBlockEndTime <= t.EventStartTime AND t.Sequence > 1 AND t.IsProcedure = 'Y' AND t.SlotType = 'OverBook' THEN t.EventStartTime END) AS VCTProcedureOverbookPostInBlockStartTime,
        MAX(CASE WHEN sub.ProcedureInBlockEndTime < t.EventEndTime AND t.Sequence > 1 AND t.IsProcedure = 'Y' AND t.SlotType = 'OverBook' THEN t.EventEndTime END) AS VCTProcedureOverbookPostInBlockEndTime,
		MAX(CASE WHEN (sub.ProcedureInBlockEndTime <= t.EventStartTime or sub.ProcedureOutOfBlockStartTime <= t.EventStartTime) AND t.Sequence > 1 AND t.IsProcedure = 'Y' AND t.SlotType = 'Out of Block' THEN t.EventStartTime END) AS VCTProcedureOutOfBlockPostInBlockStartTime,
        MAX(CASE WHEN (sub.ProcedureInBlockEndTime < t.EventEndTime or sub.ProcedureOutOfBlockStartTime <= t.EventEndTime) AND t.Sequence > 1 AND t.IsProcedure = 'Y' AND t.SlotType = 'Out of Block' THEN t.EventEndTime END) AS VCTProcedureOutOfBlockPostInBlockEndTime,
        MIN(CASE WHEN sub.ProcedureInBlockEndTime = t.EventStartTime AND t.Sequence > 1 AND t.IsProcedure = 'N' AND t.SlotType = 'In Block' THEN t.EventStartTime END) AS VCTPostCleanupInBlockStartTime,
        MAX(CASE WHEN sub.ProcedureInBlockEndTime < t.EventEndTime AND t.Sequence > 1 AND t.IsProcedure = 'N' AND t.SlotType = 'In Block' THEN t.EventEndTime END) AS VCTPostCleanupInBlockEndTime,
        MIN(CASE WHEN sub.ProcedureInBlockEndTime <= t.EventStartTime AND t.Sequence > 1 AND t.IsProcedure = 'N' AND t.SlotType = 'OverBook' THEN t.EventStartTime END) AS VCTPostCleanupOverbookStartTime,
        MAX(CASE WHEN sub.ProcedureInBlockEndTime < t.EventEndTime AND t.Sequence > 1 AND t.IsProcedure = 'N' AND t.SlotType = 'OverBook' THEN t.EventEndTime END) AS VCTPostCleanupOverbookEndTime,
		null as VCTScheduleSetupStartTime,
		null as VCTScheduleSetupEndTime,
		null as VCTScheduleOverbookPreInBlockStartTime,
		null as VCTScheduleOverbookPreInBlockEndTime,
		null as VCTScheduleInBlockStartTime,
		null as VCTScheduleInBlockEndTime,
		null as VCTScheduleOutOfBlockStartTime,
		null as VCTScheduleIOutOfBlockEndTime,
		null as VCTScheduleOverbookPostInBlockStartTime,
		null as VCTScheduleOverbookPostInBlockEndTime,
		null as VCTScheduleCleanupStartTime,
		null as VCTScheculeCleanupEndTime
    FROM #VCTPerformed t
        LEFT JOIN (SELECT
                        t.CaseID,
                        MAX(t.ProcedureInBlockStartTime) AS ProcedureInBlockStartTime,
                        MAX(t.ProcedureInBlockEndTime) AS ProcedureInBlockEndTime,
                        MAX(t.ProcedureOutOfBlockStartTime) AS ProcedureOutOfBlockStartTime,
                        MAX(t.ProcedureOutOfBlockEndTime) AS ProcedureOutOfBlockEndTime,
						MAX(t.ProcedureOverbookStartTime) AS ProcedureOverbookStartTime,
                        MAX(t.ProcedureOverbookEndTime) AS ProcedureOverbookEndTime
                    FROM #VCTPerformed t
                    WHERE t.ProcedureInBlockStartTime IS NOT NULL or t.ProcedureOutOfBlockStartTime IS NOT NULL or t.ProcedureOverbookStartTime IS NOT NULL
                    GROUP BY t.CaseID) sub ON sub.CaseID = t.CaseID
    GROUP BY t.CaseID


UNION ALL

-- VCT Schedule

    SELECT
        CONCAT('5~',t.CaseID,'~Schedule') AS VisitCaseTimesCaseID,
        '5' AS VisitCaseTimesDataSourceID,
		t.CaseID as VisitCaseTimesSourceID,
		'Schedule' as VisitCaseTimeType,
		null as VCTPreSetupStartTime,
        null as VCTPreSetupEndTime,
        null as VCTPreSetupOverbookStartTime,
        null as VCTPreSetupOverbookEndTime,
        null as VCTPreSetupInBlockStartTime,
        null as VCTPreSetupInBlockEndTime,
        null as VCTProcedureOverbookPreInBlockStartTime,
        null as VCTProcedureOverbookPreInBlockEndTime,
		null as VCTProcedureOutOfBlockPreInBlockStart,
		null as VCTProcedureOutOfBlockPreInBlockEndTime,
        null as VCTProcedureInBlockStartTime,
        null as VCTProcedureInBlockEndTime,
        null as VCTProcedureOverbookPostInBlockStartTime,
        null as VCTProcedureOverbookPostInBlockEndTime,
		null as VCTProcedureOutOfBlockPostInBlockStartTime,
		null as VCTProcedureOutOfBlockPostInBlockEndTime,
        null as VCTPostCleanupInBlockStartTime,
        null as VCTPostCleanupInBlockEndTime,
        null as VCTPostCleanupOverbookStartTime,
        null as VCTPostCleanupOverbookEndTime,
        MAX(CASE WHEN t.ScheduleSequence = 1 AND t.IsProcedure = 'N' THEN t.EventStartTime END) AS VCTScheduleSetupStartTime, --Setup Start
        MAX(CASE WHEN (sub.ProcedureInBlockStartTime >= t.EventEndTime or sub.ProcedureOutOfBlockStartTime >= t.EventEndTime or sub.ProcedureOverbookStartTime >= t.EventEndTime) and t.ScheduleSequence >= 1 AND t.IsProcedure = 'N' THEN t.EventEndTime END) AS VCTScheduleSetupEndTime, --Setup End
        MIN(CASE WHEN (sub.ProcedureInBlockStartTime = t.EventEndTime or sub.ProcedureOutOfBlockStartTime = t.EventEndTime) AND t.IsProcedure = 'Y' AND t.SlotType = 'OverBook' THEN t.EventStartTime END) AS VCTScheduleOverbookPreInBlockStartTime, --Procedure Overbook Start
        MAX(CASE WHEN (sub.ProcedureInBlockStartTime >= t.EventEndTime or sub.ProcedureOutOfBlockStartTime >= t.EventEndTime) AND t.IsProcedure = 'Y' AND t.SlotType = 'OverBook' THEN t.EventEndTime END) AS VCTScheduleOverbookPreInBlockEndTime,--Procedure Overbook End
        MAX(t.ProcedureInBlockStartTime) AS VCTScheduleInBlockStartTime, --Procedure Inblock Start
        MAX(t.ProcedureInBlockEndTime) AS VCTScheduleInBlockEndTime, -- Procedure Inblock End
		MAX(t.ProcedureOutOfBlockStartTime) AS VCTScheduleOutOfBlockStartTime, --Procedure Out Of Block Start
        MAX(t.ProcedureOutOfBlockEndTime) AS VCTScheduleIOutOfBlockEndTime, -- Procedure Out of Block End
        MAX(CASE WHEN (sub.ProcedureInBlockEndTime <= t.EventStartTime or sub.ProcedureOverbookStartTime = t.EventStartTime) AND t.ScheduleSequence >= 1 AND t.IsProcedure = 'Y' AND t.SlotType = 'OverBook' THEN t.EventStartTime END) AS VCTScheduleOverbookPostInBlockStartTime, --Procedure Overbook Post Inblock Start
        MAX(CASE WHEN (sub.ProcedureInBlockEndTime < t.EventEndTime or sub.ProcedureOverbookEndTime = t.EventEndTime) AND t.ScheduleSequence >= 1 AND t.IsProcedure = 'Y' AND t.SlotType = 'OverBook' THEN t.EventEndTime END) AS VCTScheduleOverbookPostInBlockEndTime, --Procedure Overbook Post Inblock End
        MIN(CASE WHEN (sub.ProcedureInBlockEndTime = t.EventStartTime or sub.ProcedureOutOfBlockEndTime = t.EventStartTime  or sub.ProcedureOverbookEndTime = t.EventStartTime) AND t.ScheduleSequence > 1 AND t.IsProcedure = 'N'THEN t.EventStartTime END) AS VCTScheduleCleanupStartTime, --Start Cleanup
        MAX(CASE WHEN (sub.ProcedureInBlockEndTime < t.EventEndTime or sub.ProcedureOutOfBlockEndTime <= t.EventStartTime or sub.ProcedureOverbookEndTime <= t.EventStartTime) AND t.ScheduleSequence = sub2.SequenceMax AND t.IsProcedure = 'N' THEN t.EventEndTime END) AS VCTScheculeCleanupEndTime --End Cleanup
    FROM #VCTSchedule t
        LEFT JOIN (SELECT
                        t.CaseID,
                        MAX(t.ProcedureInBlockStartTime) AS ProcedureInBlockStartTime,
                        MAX(t.ProcedureInBlockEndTime) AS ProcedureInBlockEndTime,
                        MAX(t.ProcedureOutOfBlockStartTime) AS ProcedureOutOfBlockStartTime,
                        MAX(t.ProcedureOutOfBlockEndTime) AS ProcedureOutOfBlockEndTime,
						MAX(t.ProcedureOverbookStartTime) AS ProcedureOverbookStartTime,
                        MAX(t.ProcedureOverbookEndTime) AS ProcedureOverbookEndTime
                    FROM #VCTSchedule t
                    WHERE t.ProcedureInBlockStartTime IS NOT NULL or t.ProcedureOutOfBlockStartTime IS NOT NULL or t.ProcedureOverbookStartTime IS NOT NULL
                    GROUP BY t.CaseID) sub ON sub.CaseID = t.CaseID
        LEFT JOIN (SELECT
                        t.CaseID,
						MAX(t.ScheduleSequence) as SequenceMax
                    FROM #VCTSchedule t
                    GROUP BY 
						t.CaseID) sub2 on sub2.CaseID = t.CaseID
						
    GROUP BY t.CaseID

	) vct

GROUP BY
	    VisitCaseTimesCaseID,
        VisitCaseTimesDataSourceID,
		VisitCaseTimesSourceID,
		VisitCaseTimeType,
        VCTPreSetupStartTime,
        VCTPreSetupEndTime,
        VCTPreSetupOverbookStartTime,
        VCTPreSetupOverbookEndTime,
        VCTPreSetupInBlockStartTime,
        VCTPreSetupInBlockEndTime,
        VCTProcedureOverbookPreInBlockStartTime,
        VCTProcedureOverbookPreInBlockEndTime,
		VCTProcedureOutOfBlockPreInBlockStartTime,
		VCTProcedureOutOfBlockPreInBlockEndTime,
        VCTProcedureInBlockStartTime,
        VCTProcedureInBlockEndTime,
        VCTProcedureOverbookPostInBlockStartTime,
        VCTProcedureOverbookPostInBlockEndTime,
		VCTProcedureOutOfBlockPostInBlockStartTime,
		VCTProcedureOutOfBlockPostInBlockEndTime,
        VCTPostCleanupInBlockStartTime,
        VCTPostCleanupInBlockEndTime,
        VCTPostCleanupOverbookStartTime,
        VCTPostCleanupOverbookEndTime,
		VCTScheduleSetupStartTime,
		VCTScheduleSetupEndTime,
		VCTScheduleOverbookPreInBlockStartTime,
		VCTScheduleOverbookPreInBlockEndTime,
		VCTScheduleInBlockStartTime,
		VCTScheduleInBlockEndTime,
		VCTScheduleOutOfBlockStartTime,
		VCTScheduleIOutOfBlockEndTime,
		VCTScheduleOverbookPostInBlockStartTime,
		VCTScheduleOverbookPostInBlockEndTime,
		VCTScheduleCleanupStartTime,
		VCTScheculeCleanupEndTime



    -- Step 4: Insert into fact.VisitCaseTimes
    INSERT INTO fact.VisitCaseTimes
    (
        VisitCaseTimesCaseID,
        VisitCaseTimesDataSourceID,
		VisitCaseTimesSourceID,
		VisitCaseTimeType,
        VCTPreSetupStartTime,
        VCTPreSetupEndTime,
        VCTPreSetupOverbookStartTime,
        VCTPreSetupOverbookEndTime,
        VCTPreSetupInBlockStartTime,
        VCTPreSetupInBlockEndTime,
        VCTProcedureOverbookPreInBlockStartTime,
        VCTProcedureOverbookPreInBlockEndTime,
		VCTProcedureOutOfBlockPreInBlockStartTime,
		VCTProcedureOutOfBlockPreInBlockEndTime,
        VCTProcedureInBlockStartTime,
        VCTProcedureInBlockEndTime,
        VCTProcedureOverbookPostInBlockStartTime,
        VCTProcedureOverbookPostInBlockEndTime,
		VCTProcedureOutOfBlockPostInBlockStartTime,
		VCTProcedureOutOfBlockPostInBlockEndTime,
        VCTPostCleanupInBlockStartTime,
        VCTPostCleanupInBlockEndTime,
        VCTPostCleanupOverbookStartTime,
        VCTPostCleanupOverbookEndTime,
		VCTScheduleSetupStartTime,
		VCTScheduleSetupEndTime,
		VCTScheduleOverbookPreInBlockStartTime,
		VCTScheduleOverbookPreInBlockEndTime,
		VCTScheduleInBlockStartTime,
		VCTScheduleInBlockEndTime,
		VCTScheduleOutOfBlockStartTime,
		VCTScheduleIOutOfBlockEndTime,
		VCTScheduleOverbookPostInBlockStartTime,
		VCTScheduleOverbookPostInBlockEndTime,
		VCTScheduleCleanupStartTime,
		VCTScheculeCleanupEndTime
    )
    SELECT
		VisitCaseTimesCaseID,
        VisitCaseTimesDataSourceID,
		VisitCaseTimesSourceID,
		VisitCaseTimeType,
        VCTPreSetupStartTime,
        VCTPreSetupEndTime,
        VCTPreSetupOverbookStartTime,
        VCTPreSetupOverbookEndTime,
        VCTPreSetupInBlockStartTime,
        VCTPreSetupInBlockEndTime,
        VCTProcedureOverbookPreInBlockStartTime,
        VCTProcedureOverbookPreInBlockEndTime,
		VCTProcedureOutOfBlockPreInBlockStartTime,
		VCTProcedureOutOfBlockPreInBlockEndTime,
        VCTProcedureInBlockStartTime,
        VCTProcedureInBlockEndTime,
        VCTProcedureOverbookPostInBlockStartTime,
        VCTProcedureOverbookPostInBlockEndTime,
		VCTProcedureOutOfBlockPostInBlockStartTime,
		VCTProcedureOutOfBlockPostInBlockEndTime,
        VCTPostCleanupInBlockStartTime,
        VCTPostCleanupInBlockEndTime,
        VCTPostCleanupOverbookStartTime,
        VCTPostCleanupOverbookEndTime,
		VCTScheduleSetupStartTime,
		VCTScheduleSetupEndTime,
		VCTScheduleOverbookPreInBlockStartTime,
		VCTScheduleOverbookPreInBlockEndTime,
		VCTScheduleInBlockStartTime,
		VCTScheduleInBlockEndTime,
		VCTScheduleOutOfBlockStartTime,
		VCTScheduleIOutOfBlockEndTime,
		VCTScheduleOverbookPostInBlockStartTime,
		VCTScheduleOverbookPostInBlockEndTime,
		VCTScheduleCleanupStartTime,
		VCTScheculeCleanupEndTime
    FROM #Temp;

END;


	
	/*
			
			select * from #Temp2 where ORCaseTimesCaseID = '5~2462557'
			
			 SELECT 
			b.UTILIZATION_ID as UtilizationID
			,u.CASE_ID as CaseID
			,b.LINE as Sequence
			,b.START_DTTM as EventStartTime
			,b.END_DTTM as EventEndTime
			,CASE WHEN b.LINE > 1 and b.PROC_YN = 'Y' and st.NAME = 'In Block' THEN b.START_DTTM END as ProcedureInBlockStartTime
			,CASE WHEN b.LINE > 1 and b.PROC_YN = 'Y' and st.NAME = 'In Block' THEN b.END_DTTM END as ProcedureInBlockEndTime
			,st.NAME as SlotType
			,sr.NAME as SlotReason
			,b.SLOT_LENGTH as SlotLength
			,b.PROC_YN as IsProcedure
			,b.REASON_COMMENTS as ReasonComments
			,CASE WHEN rt.DELAY_REASON_NM IS NULL THEN 'N' ELSE 'Y' END as IsDelayed
			,rt.DELAY_REASON_NM as DelayReason
		FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].UTL_OR_CASE_BLOCK_PERF b
			LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].UTILIZATION u on u.UTILIZATION_ID = b.UTILIZATION_ID
			LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].V_CASE_ROOM_TURNOVER rt on rt.CASE_ID = u.CASE_ID
			LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].OR_CASE oc on oc.OR_CASE_ID = u.CASE_ID
			--LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].clarity_loc loc on loc.loc_id = u.LOCATION_ID --To filter down to 430 SA
			LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_BLOCK_SLOT_TYPE st on st.BLOCK_SLOT_TYPE_C = b.BLOCK_SLOT_TYPE_C
			LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_USED_SLOT_REASON sr on sr.USED_SLOT_REASON_C = b.USED_SLOT_REASON_C
		 WHERE oc.LOC_ID in ('43001006','43001007','43001008','43002001','43004001','43004002','43004003','43004004','43005005','43005006','43005007','43005008','43006001','43006002','43006003','43006004','430050061') 
			and u.CASE_ID = '2462557'
			*/
GO
