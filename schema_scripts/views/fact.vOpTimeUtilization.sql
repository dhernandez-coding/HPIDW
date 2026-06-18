CREATE view [fact].[vOpTimeUtilization] as

SELECT
     sch.*
    ,CASE WHEN sch.VisitCaseScheduleStatus = 'Completed'  THEN sch.ScheduleTotalMinutes ELSE 0 END AS ScheduleUtilizedMinutes
    ,CASE WHEN sch.VisitCaseScheduleStatus = 'Scheduled'  THEN sch.ScheduleTotalMinutes ELSE 0 END AS ScheduleScheduledMinutes
    ,CASE WHEN sch.VisitCaseScheduleStatus = 'Completed'  AND sch.ScheduleSlotAvailabilityType = 'Blocked'     THEN sch.ScheduleTotalMinutes ELSE 0 END AS ScheduleUtilizedBlockMinutes
    ,CASE WHEN sch.VisitCaseScheduleStatus = 'Scheduled'  AND sch.ScheduleSlotAvailabilityType = 'Blocked'     THEN sch.ScheduleTotalMinutes ELSE 0 END AS ScheduleScheduledBlockMinutes
    ,CASE WHEN sch.VisitCaseScheduleStatus = 'Completed'  AND sch.ScheduleSlotAvailabilityType = 'Unblocked'   THEN sch.ScheduleTotalMinutes ELSE 0 END AS ScheduleUtilizedUnblockedMinutes
    ,CASE WHEN sch.VisitCaseScheduleStatus = 'Completed'  AND sch.ScheduleSlotAvailabilityType = 'Unavailable' THEN sch.ScheduleTotalMinutes ELSE 0 END AS ScheduleUtilizedUnavailableMinutes

    -- Dominant classification per case using window function
    -- Picks the lowest priority value across all slots for the same VisitCaseID
    ,CASE
        WHEN sch.VisitCaseID IS NULL THEN NULL
        ELSE FIRST_VALUE( sch.CaseBlockRelationship ) OVER (
            PARTITION BY sch.VisitCaseID
            ORDER BY sch.CaseBlockRelationshipPriority ASC
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        )
     END AS CaseBlockRelationshipFinal

    -- Original block owner using same window function
    ,CASE
        WHEN sch.VisitCaseID IS NULL THEN NULL
        ELSE FIRST_VALUE( sch.OriginalBlockOwner ) OVER (
            PARTITION BY sch.VisitCaseID
            ORDER BY sch.CaseBlockRelationshipPriority ASC
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        )
     END AS OriginalBlockOwnerFinal

FROM (

    SELECT
         s.ScheduleID
        ,s.ScheduleDataSourceID
        ,s.ScheduleRoomID
        ,s.ScheduleRoomSourceID
        ,s.ScheduleRoomName
        ,s.ScheduleLocationID
        ,s.ScheduleLocationName
        ,s.ScheduleDate
        ,s.ScheduleDOWInMonth
        ,s.ScheduleWeekDayName
        ,s.ScheduleWeekDayOrder
        ,s.ScheduleTimeSlotName
        ,s.ScheduleTimeSlotStartDatetime
        ,s.ScheduleTimeSlotEndDatetime
        ,s.ScheduleTimeSlotMinutes
        ,s.ScheduleSlotAvailabilityType
        ,s.ScheduleRoomStartTime
        ,s.ScheduleRoomEndTime
        ,s.ScheduleRoomProviderID
        ,s.ScheduleOriginalBlockName
        ,s.ScheduleCurrentBlockName
        ,s.ScheduleBlockKey
        ,s.ScheduleRoomComments
        ,s.ScheduleBlockModifiedReason
        ,s.ScheduleBlockDaysSinceRelease
        ,CASE
            WHEN s.ScheduleBlockReleasedTimely = 1 THEN 'Yes'
            WHEN s.ScheduleBlockReleasedTimely = 0 THEN 'No'
            ELSE NULL
         END AS ScheduleBlockReleasedTimely
        ,s.ScheduleTimeSlotAMPMFlag
        ,s.ScheduleTimeSlotUpdateDatetime

        ,c.VisitCaseSourceID
        ,c.VisitCaseVisitID
        ,c.VisitCaseID
        ,c.VisitCaseCSN
        ,c.VisitCaseScheduleStatus

        ,CASE WHEN crt.DELAY_REASON_NM IS NULL THEN 'N' ELSE 'Y' END AS CaseDelay
        ,crt.DELAY_REASON_NM AS DelayReason

        ,CASE
            WHEN c.VisitCaseID IS NULL THEN s.ScheduleTimeSlotStartDatetime
            WHEN c.VisitCaseBeginDatetime > s.ScheduleTimeSlotStartDatetime THEN c.VisitCaseBeginDatetime
            ELSE s.ScheduleTimeSlotStartDatetime
         END AS FromDateTime
        ,CASE
            WHEN c.VisitCaseID IS NULL THEN s.ScheduleTimeSlotEndDatetime
            WHEN c.VisitCaseEndDatetime < s.ScheduleTimeSlotEndDatetime THEN c.VisitCaseEndDatetime
            ELSE s.ScheduleTimeSlotEndDatetime
         END AS ThroughDateTime

        ,CASE
            WHEN c.VisitCaseID IS NULL THEN 0
            WHEN c.VisitCaseBeginDatetime <= s.ScheduleTimeSlotStartDatetime AND c.VisitCaseEndDatetime >= s.ScheduleTimeSlotEndDatetime
                THEN DATEDIFF(MINUTE, s.ScheduleTimeSlotStartDatetime, s.ScheduleTimeSlotEndDatetime)
            WHEN c.VisitCaseBeginDatetime >= s.ScheduleTimeSlotStartDatetime AND c.VisitCaseEndDatetime >= s.ScheduleTimeSlotEndDatetime
                THEN DATEDIFF(MINUTE, c.VisitCaseBeginDatetime, s.ScheduleTimeSlotEndDatetime)
            WHEN c.VisitCaseBeginDatetime >= s.ScheduleTimeSlotStartDatetime AND c.VisitCaseEndDatetime <= s.ScheduleTimeSlotEndDatetime
                THEN DATEDIFF(MINUTE, c.VisitCaseBeginDatetime, c.VisitCaseEndDatetime)
            WHEN c.VisitCaseBeginDatetime <= s.ScheduleTimeSlotStartDatetime AND c.VisitCaseEndDatetime <= s.ScheduleTimeSlotEndDatetime
                THEN DATEDIFF(MINUTE, s.ScheduleTimeSlotStartDatetime, c.VisitCaseEndDatetime)
            ELSE 0
         END AS ScheduleTotalMinutes

        ,s.ScheduleTimeSlotMinutes AS ScheduleAvailableTotalMinutes
        ,CASE WHEN s.ScheduleSlotAvailabilityType = 'Blocked'     AND c.VisitCaseID IS NULL THEN s.ScheduleTimeSlotMinutes ELSE 0 END AS ScheduleAvailableBlockMinutes
        ,CASE WHEN s.ScheduleSlotAvailabilityType = 'Unblocked'   AND c.VisitCaseID IS NULL THEN s.ScheduleTimeSlotMinutes ELSE 0 END AS ScheduleAvailableUnblockedMinutes
        ,CASE WHEN s.ScheduleSlotAvailabilityType = 'Unavailable' AND c.VisitCaseID IS NULL THEN s.ScheduleTimeSlotMinutes ELSE 0 END AS ScheduleAvailableUnavailableMinutes

        -- Slot-level classification
        ,CASE
            WHEN c.VisitCaseID IS NULL
                THEN NULL
            WHEN s.ScheduleSlotAvailabilityType = 'Blocked'
                AND (s.ScheduleBlockModifiedReason IS NULL
                    OR s.ScheduleBlockModifiedReason != 'Manual Block Release')
                AND s.ScheduleRoomProviderID =
                    REPLACE(c.VisitCasePrimaryProviderID, '5~', '')
                THEN 'In Block'
            WHEN s.ScheduleSlotAvailabilityType = 'Unblocked'
                AND s.ScheduleBlockModifiedReason = 'Manual Block Release'
                THEN 'In Released Block'
            WHEN s.ScheduleSlotAvailabilityType = 'Blocked'
                AND (s.ScheduleBlockModifiedReason IS NULL
                    OR s.ScheduleBlockModifiedReason != 'Manual Block Release')
                AND s.ScheduleRoomProviderID !=
                    REPLACE(c.VisitCasePrimaryProviderID, '5~', '')
                THEN 'In Another Providers Block'
            WHEN s.ScheduleSlotAvailabilityType = 'Unblocked'
                AND (s.ScheduleBlockModifiedReason IS NULL
                    OR s.ScheduleBlockModifiedReason != 'Manual Block Release')
                THEN 'Out of Block'
            ELSE 'Other'
         END AS CaseBlockRelationship

        -- Priority for window function
        ,CASE
            WHEN c.VisitCaseID IS NULL
                THEN NULL
            WHEN s.ScheduleSlotAvailabilityType = 'Blocked'
                AND (s.ScheduleBlockModifiedReason IS NULL
                    OR s.ScheduleBlockModifiedReason != 'Manual Block Release')
                AND s.ScheduleRoomProviderID =
                    REPLACE(c.VisitCasePrimaryProviderID, '5~', '')
                THEN 1
            WHEN s.ScheduleSlotAvailabilityType = 'Unblocked'
                AND s.ScheduleBlockModifiedReason = 'Manual Block Release'
                THEN 2
            WHEN s.ScheduleSlotAvailabilityType = 'Blocked'
                AND (s.ScheduleBlockModifiedReason IS NULL
                    OR s.ScheduleBlockModifiedReason != 'Manual Block Release')
                AND s.ScheduleRoomProviderID !=
                    REPLACE(c.VisitCasePrimaryProviderID, '5~', '')
                THEN 3
            WHEN s.ScheduleSlotAvailabilityType = 'Unblocked'
                AND (s.ScheduleBlockModifiedReason IS NULL
                    OR s.ScheduleBlockModifiedReason != 'Manual Block Release')
                THEN 4
            ELSE 5
         END AS CaseBlockRelationshipPriority

        -- Original block owner
        ,CASE
            WHEN c.VisitCaseID IS NULL
                THEN NULL
            WHEN s.ScheduleBlockModifiedReason = 'Manual Block Release'
                THEN s.ScheduleOriginalBlockName
            ELSE NULL
         END AS OriginalBlockOwner

        ,c.VisitCasePrimaryProviderID
        ,c.ProviderFullName

    FROM [HPIDW].[dim].[Schedules] s

        LEFT JOIN [HPIDW].[fact].[vVisitCases] c
            ON  s.ScheduleRoomSourceID       = c.VisitCaseORID
            AND s.ScheduleDate               = CAST(c.VisitCaseScheduledDatetime AS DATE)
            AND c.VisitCaseBeginDatetime      < s.ScheduleTimeSlotEndDatetime
            AND c.VisitCaseEndDatetime        > s.ScheduleTimeSlotStartDatetime

        LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].V_CASE_ROOM_TURNOVER crt
            ON  crt.CASE_ID = c.VisitCaseSourceID

) sch


/*
SELECT
     sch.*
    ,CASE WHEN sch.VisitCaseScheduleStatus = 'Completed'  THEN sch.ScheduleTotalMinutes ELSE 0 END AS ScheduleUtilizedMinutes
    ,CASE WHEN sch.VisitCaseScheduleStatus = 'Scheduled'  THEN sch.ScheduleTotalMinutes ELSE 0 END AS ScheduleScheduledMinutes
    ,CASE WHEN sch.VisitCaseScheduleStatus = 'Completed'  AND sch.ScheduleSlotAvailabilityType = 'Blocked'    THEN sch.ScheduleTotalMinutes ELSE 0 END AS ScheduleUtilizedBlockMinutes
    ,CASE WHEN sch.VisitCaseScheduleStatus = 'Scheduled'  AND sch.ScheduleSlotAvailabilityType = 'Blocked'    THEN sch.ScheduleTotalMinutes ELSE 0 END AS ScheduleScheduledBlockMinutes
    ,CASE WHEN sch.VisitCaseScheduleStatus = 'Completed'  AND sch.ScheduleSlotAvailabilityType = 'Unblocked'  THEN sch.ScheduleTotalMinutes ELSE 0 END AS ScheduleUtilizedUnblockedMinutes
    ,CASE WHEN sch.VisitCaseScheduleStatus = 'Completed'  AND sch.ScheduleSlotAvailabilityType = 'Unavailable' THEN sch.ScheduleTotalMinutes ELSE 0 END AS ScheduleUtilizedUnavailableMinutes

FROM (

    SELECT
         s.ScheduleID
        ,s.ScheduleDataSourceID
        ,s.ScheduleRoomID
        ,s.ScheduleRoomSourceID
        ,s.ScheduleRoomName
        ,s.ScheduleLocationID
        ,s.ScheduleLocationName
        ,s.ScheduleDate
        ,s.ScheduleDOWInMonth
        ,s.ScheduleWeekDayName
        ,s.ScheduleWeekDayOrder
        ,s.ScheduleTimeSlotName
        ,s.ScheduleTimeSlotStartDatetime
        ,s.ScheduleTimeSlotEndDatetime
        ,s.ScheduleTimeSlotMinutes
        ,s.ScheduleSlotAvailabilityType
        ,s.ScheduleRoomStartTime
        ,s.ScheduleRoomEndTime
        ,s.ScheduleRoomProviderID
        ,s.ScheduleOriginalBlockName
        ,s.ScheduleCurrentBlockName
        ,s.ScheduleBlockKey
        ,s.ScheduleRoomComments
        ,s.ScheduleBlockModifiedReason
        ,s.ScheduleBlockDaysSinceRelease
        ,CASE
            WHEN s.ScheduleBlockReleasedTimely = 1 THEN 'Yes'
            WHEN s.ScheduleBlockReleasedTimely = 0 THEN 'No'
            ELSE NULL
         END AS ScheduleBlockReleasedTimely
        ,s.ScheduleTimeSlotAMPMFlag
        ,s.ScheduleTimeSlotUpdateDatetime

        -- Case identity columns — NULL when no case overlaps this slot
        ,c.VisitCaseSourceID
        ,c.VisitCaseVisitID
        ,c.VisitCaseID
        ,c.VisitCaseCSN
        ,c.VisitCaseScheduleStatus

        -- Delay columns from Epic linked server
        ,CASE WHEN crt.DELAY_REASON_NM IS NULL THEN 'N' ELSE 'Y' END AS CaseDelay
        ,crt.DELAY_REASON_NM AS DelayReason

        -- Overlap window for this slot
        ,CASE
            WHEN c.VisitCaseID IS NULL THEN s.ScheduleTimeSlotStartDatetime
            WHEN c.VisitCaseBeginDatetime > s.ScheduleTimeSlotStartDatetime THEN c.VisitCaseBeginDatetime
            ELSE s.ScheduleTimeSlotStartDatetime
         END AS FromDateTime
        ,CASE
            WHEN c.VisitCaseID IS NULL THEN s.ScheduleTimeSlotEndDatetime
            WHEN c.VisitCaseEndDatetime < s.ScheduleTimeSlotEndDatetime  THEN c.VisitCaseEndDatetime
            ELSE s.ScheduleTimeSlotEndDatetime
         END AS ThroughDateTime

        -- Actual utilized minutes within this slot (0 for empty slots)
        ,CASE
            WHEN c.VisitCaseID IS NULL THEN 0
            WHEN c.VisitCaseBeginDatetime <= s.ScheduleTimeSlotStartDatetime AND c.VisitCaseEndDatetime >= s.ScheduleTimeSlotEndDatetime
                THEN DATEDIFF(MINUTE, s.ScheduleTimeSlotStartDatetime, s.ScheduleTimeSlotEndDatetime)
            WHEN c.VisitCaseBeginDatetime >= s.ScheduleTimeSlotStartDatetime AND c.VisitCaseEndDatetime >= s.ScheduleTimeSlotEndDatetime
                THEN DATEDIFF(MINUTE, c.VisitCaseBeginDatetime, s.ScheduleTimeSlotEndDatetime)
            WHEN c.VisitCaseBeginDatetime >= s.ScheduleTimeSlotStartDatetime AND c.VisitCaseEndDatetime <= s.ScheduleTimeSlotEndDatetime
                THEN DATEDIFF(MINUTE, c.VisitCaseBeginDatetime, c.VisitCaseEndDatetime)
            WHEN c.VisitCaseBeginDatetime <= s.ScheduleTimeSlotStartDatetime AND c.VisitCaseEndDatetime <= s.ScheduleTimeSlotEndDatetime
                THEN DATEDIFF(MINUTE, s.ScheduleTimeSlotStartDatetime, c.VisitCaseEndDatetime)
            ELSE 0
         END AS ScheduleTotalMinutes

        -- Available minutes — always the full slot width (denominator for utilization %)
        -- One row per slot now, so no double-count risk
        ,s.ScheduleTimeSlotMinutes AS ScheduleAvailableTotalMinutes

        -- Available by type — only populated when the slot has NO case
        -- Uses c.VisitCaseID IS NULL instead of the old c.VisitCaseScheduleStartDatetime IS NULL
        -- because VisitCaseScheduleStartDatetime was a case column only populated in the
        -- old INNER JOIN branch, making it an unreliable empty-slot proxy
        ,CASE WHEN s.ScheduleSlotAvailabilityType = 'Blocked'     AND c.VisitCaseID IS NULL THEN s.ScheduleTimeSlotMinutes ELSE 0 END AS ScheduleAvailableBlockMinutes
        ,CASE WHEN s.ScheduleSlotAvailabilityType = 'Unblocked'   AND c.VisitCaseID IS NULL THEN s.ScheduleTimeSlotMinutes ELSE 0 END AS ScheduleAvailableUnblockedMinutes
        ,CASE WHEN s.ScheduleSlotAvailabilityType = 'Unavailable' AND c.VisitCaseID IS NULL THEN s.ScheduleTimeSlotMinutes ELSE 0 END AS ScheduleAvailableUnavailableMinutes

    FROM [HPIDW].[dim].[Schedules] s

        -- LEFT JOIN: every schedule slot appears exactly once.
        -- Case columns are populated only when a case's OR window overlaps the slot.
        -- Empty slots get NULLs for all case columns.
        LEFT JOIN [HPIDW].[fact].[VisitCases] c
            ON  s.ScheduleRoomSourceID       = c.VisitCaseORID
            AND s.ScheduleDate               = CAST(c.VisitCaseScheduledDatetime AS DATE)
            AND c.VisitCaseBeginDatetime      < s.ScheduleTimeSlotEndDatetime
            AND c.VisitCaseEndDatetime        > s.ScheduleTimeSlotStartDatetime

        -- Epic linked-server join for delay reason — LEFT so missing turnover rows
        -- don't drop the slot from the result set
        LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].V_CASE_ROOM_TURNOVER crt
            ON  crt.CASE_ID = c.VisitCaseSourceID

) sch
*/
GO
