CREATE view [fact].[vVisitCaseTimes] as
SELECT
	 vct.VisitCaseTimesCaseID
     ,vct.VisitCaseTimesDataSourceID
     ,CONCAT('5~', [VisitCaseTimesSourceID]) as VisitCaseTimesSourceID
     ,vct.VisitCaseTimeType
     ,vct.VCTPreSetupStartTime
     ,vct.VCTPreSetupEndTime
     ,vct.VCTPreSetupOverbookStartTime
     ,vct.VCTPreSetupOverbookEndTime
     ,vct.VCTPreSetupInBlockStartTime
     ,vct.VCTPreSetupInBlockEndTime
     ,vct.VCTProcedureOverbookPreInBlockStartTime
     ,vct.VCTProcedureOverbookPreInBlockEndTime
     ,vct.VCTProcedureInBlockStartTime
     ,vct.VCTProcedureInBlockEndTime
     ,vct.VCTProcedureOverbookPostInBlockStartTime
     ,vct.VCTProcedureOverbookPostInBlockEndTime
     ,vct.VCTPostCleanupInBlockStartTime
     ,vct.VCTPostCleanupInBlockEndTime
     ,vct.VCTPostCleanupOverbookStartTime
     ,vct.VCTPostCleanupOverbookEndTime
	 ,DATEDIFF(minute, vct.VCTPreSetupStartTime, vct.VCTPreSetupEndTime) as VCTSetupDuration
	 ,DATEDIFF(minute, vct.VCTPreSetupOverbookStartTime, vct.VCTPreSetupOverbookEndTime) as VCTSetupOverbookDuration
	 ,DATEDIFF(minute, vct.VCTPreSetupInBlockStartTime, vct.VCTPreSetupInBlockEndTime) as VCTSetupInBlockDuration
	 ,DATEDIFF(minute, vct.VCTProcedureOverbookPreInBlockStartTime, vct.VCTProcedureOverbookPreInBlockEndTime) as VCTProcedureOverbookPreInBlockDuration
	 ,DATEDIFF(minute, vct.VCTProcedureInBlockStartTime, vct.VCTProcedureInBlockEndTime) as VCTProcedureInBlockDuration
	 ,DATEDIFF(minute, vct.VCTProcedureOverbookPostInBlockStartTime, vct.VCTProcedureOverbookPostInBlockEndTime) as VCTProcedureOverbookPostInBlockDuration
	 ,DATEDIFF(minute, vct.VCTPostCleanupInBlockStartTime, vct.VCTPostCleanupInBlockEndTime) as VCTCleanupInBlockDuration
	 ,DATEDIFF(minute, vct.VCTPostCleanupOverbookStartTime, vct.VCTPostCleanupOverbookEndTime) as VCTCleanupOverbookDuration
     ,vct.VCTScheduleSetupStartTime
     ,vct.VCTScheduleSetupEndTime
     ,vct.VCTScheduleOverbookPreInBlockStartTime
     ,vct.VCTScheduleOverbookPreInBlockEndTime
     ,vct.VCTScheduleInBlockStartTime
     ,vct.VCTScheduleInBlockEndTime
     ,vct.VCTScheduleOutOfBlockStartTime
     ,vct.VCTScheduleIOutOfBlockEndTime
     ,vct.VCTScheduleOverbookPostInBlockStartTime
     ,vct.VCTScheduleOverbookPostInBlockEndTime
     ,vct.VCTScheduleCleanupStartTime
     ,vct.VCTScheculeCleanupEndTime
	 ,DATEDIFF(minute, vct.VCTScheduleSetupStartTime, vct.VCTScheduleSetupEndTime) as VCTScheduleSetupDuration
	 ,DATEDIFF(minute, vct.VCTScheduleOverbookPreInBlockStartTime, vct.VCTScheduleOverbookPreInBlockEndTime) as VCTScheduleOverbookPreInBlockDuration
	 ,DATEDIFF(minute, vct.VCTScheduleInBlockStartTime, vct.VCTScheduleInBlockEndTime) as VCTScheduleInBlockDuration
	 ,DATEDIFF(minute, vct.VCTScheduleOutOfBlockStartTime, vct.VCTScheduleIOutOfBlockEndTime) as VCTScheduleOutOfBlockDuration
	 ,DATEDIFF(minute, vct.VCTScheduleOverbookPostInBlockStartTime, vct.VCTScheduleOverbookPostInBlockEndTime) as VCTScheduleOverbookPostInBlockDuration
	 ,DATEDIFF(minute, vct.VCTScheduleCleanupStartTime, vct.VCTScheculeCleanupEndTime) as VCTScheduleCleanupDuration
	 ,GETDATE() as VCTUpdateDateTime
FROM [HPIDW].[fact].VisitCaseTimes vct
GO
