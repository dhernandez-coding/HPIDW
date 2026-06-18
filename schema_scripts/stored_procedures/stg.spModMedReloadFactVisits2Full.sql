CREATE   PROCEDURE [stg].[spModMedReloadFactVisits2Full]
AS
BEGIN
    SET NOCOUNT OFF;

    PRINT 'Creating #StagingTable...';

    DROP TABLE IF EXISTS #StagingTable;

    CREATE TABLE #StagingTable (
        [VisitID] VARCHAR(100),
        [VisitDatasourceID] INT,
        [VisitSourceID] VARCHAR(100),
        [VisitPatientID] VARCHAR(100),
        [VisitAccountID] VARCHAR(100),
        [VisitLocationID] VARCHAR(100),
        [VisitDepartmentID] VARCHAR(100),
        [VisitRoomID] VARCHAR(100),
        [VisitPrimaryProviderID] VARCHAR(100),
        [VisitAppointmentProviderID] VARCHAR(100),
        [VisitAdmittingProviderID] VARCHAR(100),
        [VisitAttendingProviderID] VARCHAR(100),
        [VisitDischargeProviderID] VARCHAR(100),
        [VisitType] VARCHAR(100),
        [VisitService] VARCHAR(100),
        [VisitStatus] VARCHAR(100),
        [VisitDateOfService] DATE,
        [VisitDatetimeOfService] DATETIME,
        [VisitDateOfScheduling] DATETIME,
        [VisitDateOfAppointment] DATETIME,
        [VisitDateOfAdmission] DATETIME,
        [VisitDateOfDischarge] DATETIME,
        [VisitDateofClosing] DATETIME,
        [VisitDateOfCancellation] DATETIME,
        [VisitCancellationReason] VARCHAR(100),
        [VisitIsPrimary] BIT,
        [VisitIsActive] BIT,
        [VisitUpdatedDatetime] DATETIME
    );

    ------------------------------------------------------------
    -- Load ModMed Visits (basic mapping)
    ------------------------------------------------------------
    INSERT INTO #StagingTable
SELECT
    '16~' + CAST(v.visit_id AS VARCHAR(100))     AS VisitID,
    16                                          AS VisitDatasourceID,
    CAST(v.visit_id AS VARCHAR(100))             AS VisitSourceID,
    '16~' + CAST(v.patient_id AS VARCHAR(100))   AS VisitPatientID,
    '16~' + CAST(MAX(b.bill_id) AS VARCHAR(100)) AS VisitAccountID,

    '16~' + CAST(v.facility_id AS VARCHAR(100))  AS VisitLocationID,
    NULL                                        AS VisitDepartmentID,
    NULL                                        AS VisitRoomID,

    '16~' + CAST(v.primary_provider_id AS VARCHAR(100)) AS VisitPrimaryProviderID,
    '16~' + CAST(v.physician_id AS VARCHAR(100))        AS VisitAppointmentProviderID,
    '16~' + CAST(v.primary_provider_id AS VARCHAR(100)) AS VisitAdmittingProviderID,
    '16~' + CAST(v.primary_provider_id AS VARCHAR(100)) AS VisitAttendingProviderID,
    '16~' + CAST(v.primary_provider_id AS VARCHAR(100)) AS VisitDischargeProviderID,

    v.type                                      AS VisitType,
    v.bill_as                            AS VisitService,
    v.visit_status                              AS VisitStatus,

    CAST(v.visit_date AS DATE)                  AS VisitDateOfService,

    CASE WHEN v.visit_date < '1753-01-01' THEN NULL
         ELSE CAST(v.visit_date AS DATETIME) END AS VisitDatetimeOfService,

    CASE WHEN v.date_created < '1753-01-01' THEN NULL
         ELSE CAST(v.date_created AS DATETIME) END AS VisitDateOfScheduling,

    CASE WHEN v.visit_date < '1753-01-01' THEN NULL
         ELSE CAST(v.visit_date AS DATETIME) END AS VisitDateOfAppointment,

    CAST(v.visit_date AS DATE)                  AS VisitDateOfAdmission,

    CASE WHEN v.finalized_date < '1753-01-01' THEN NULL
         ELSE CAST(v.finalized_date AS DATETIME) END AS VisitDateOfDischarge,

    CASE WHEN v.finalized_date_ld < '1753-01-01' THEN NULL
         ELSE CAST(v.finalized_date_ld AS DATETIME) END                                        AS VisitDateofClosing,

     NULL AS VisitDateOfCancellation,

    NULL                                        AS VisitCancellationReason,

    NULL                                           AS VisitIsPrimary,
    CASE WHEN v.archived = 1 THEN 0 ELSE 1 END  AS VisitIsActive,
    GETDATE()                                   AS VisitUpdatedDatetime
FROM [HPIDW].[stg].[ModMed_Visits] v
LEFT JOIN [HPIDW].[stg].ModMed_Bills b
    ON b.visit_id = v.visit_id
GROUP BY
    v.visit_id,
    v.patient_id,
    v.facility_id,
    v.primary_provider_id,
    v.physician_id,
    v.type,
    v.bill_as,
    v.visit_status,
    v.visit_date,
    v.date_created,
    v.finalized_date,
    v.finalized_date_ld,
    v.archived;

    ------------------------------------------------------------
    -- Safety check and transaction
    ------------------------------------------------------------
    IF (SELECT COUNT(1) FROM #StagingTable) >= 10
    BEGIN
        BEGIN TRY
            BEGIN TRANSACTION;

                PRINT 'At least 10 rows found. Reloading fact.Visits2 for ModMed...';

                DELETE FROM fact.Visits2
                WHERE VisitDatasourceID = 16;

                INSERT INTO fact.Visits2 (
                    [VisitID],
                    [VisitDatasourceID],
                    [VisitSourceID],
                    [VisitPatientID],
                    [VisitAccountID],
                    [VisitLocationID],
                    [VisitDepartmentID],
                    [VisitRoomID],
                    [VisitPrimaryProviderID],
                    [VisitAppointmentProviderID],
                    [VisitAdmittingProviderID],
                    [VisitAttendingProviderID],
                    [VisitDischargeProviderID],
                    [VisitType],
                    [VisitService],
                    [VisitStatus],
                    [VisitDateOfService],
                    [VisitDatetimeOfService],
                    [VisitDateOfScheduling],
                    [VisitDateOfAppointment],
                    [VisitDateOfAdmission],
                    [VisitDateOfDischarge],
                    [VisitDateofClosing],
                    [VisitDateOfCancellation],
                    [VisitCancellationReason],
                    [VisitIsPrimary],
                    [VisitIsActive],
                    [VisitUpdatedDatetime]
                )
                SELECT * FROM #StagingTable;

            COMMIT TRANSACTION;
        END TRY
        BEGIN CATCH
            ROLLBACK TRANSACTION;
            PRINT ERROR_MESSAGE();
        END CATCH
    END
    ELSE
    BEGIN
        PRINT 'Less than 10 rows found. Skipping delete and reload.';
    END

    DROP TABLE IF EXISTS #StagingTable;
END;
GO
