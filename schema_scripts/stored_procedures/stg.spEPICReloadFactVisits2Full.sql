CREATE PROCEDURE [stg].[spEPICReloadFactVisits2Full] 
	AS 
	BEGIN
		SET NOCOUNT OFF;
		PRINT 'Creating #StagingTable...';
	DROP TABLE IF EXISTS #StagingTable
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

	INSERT INTO #StagingTable

	SELECT
		*
	FROM OPENQUERY([CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM],
		'
		SELECT 
		CONCAT(''5~'',e.PAT_ENC_CSN_ID) as VisitID
		, 5 as VisitDatasourceID
		, e.PAT_ENC_CSN_ID as VisitSourceID
		, CONCAT(''5~'',e.PAT_ID) as VisitPatientID
		, CASE WHEN e.HSP_ACCOUNT_ID IS NULL THEN NULL ELSE CONCAT(''5~'',e.HSP_ACCOUNT_ID) END as VisitAccountID

		, CASE WHEN loc1.LOC_ID IS NOT NULL THEN CONCAT(''5~'',loc1.LOC_ID) END as VisitLocationID
		, CASE WHEN dep1.DEPARTMENT_ID IS NOT NULL THEN CONCAT(''5~'',dep1.DEPARTMENT_ID) END as VisitDepartmentID
		, NULL as VisitRoomID --eh.ROOM_ID

		, CASE WHEN COALESCE(eh.DISCHARGE_PROV_ID,eh.ADMISSION_PROV_ID,har.ATTENDING_PROV_ID,e.VISIT_PROV_ID) IS NOT NULL 
			   THEN CONCAT(''5~'',COALESCE(eh.DISCHARGE_PROV_ID,eh.ADMISSION_PROV_ID,e.VISIT_PROV_ID,har.ATTENDING_PROV_ID,har.ATTENDING_PROV_ID)) END as VisitPrimaryProviderID
		, CASE WHEN e.VISIT_PROV_ID IS NOT NULL THEN CONCAT(''5~'',e.VISIT_PROV_ID) END as VisitAppointmentProviderID
		, CASE WHEN eh.ADMISSION_PROV_ID IS NOT NULL THEN CONCAT(''5~'',eh.ADMISSION_PROV_ID) END as VisitAdmittingProviderID
		, CASE WHEN har.ATTENDING_PROV_ID IS NOT NULL THEN CONCAT(''5~'',har.ATTENDING_PROV_ID) END as VisitAttendingProviderID
		, CASE WHEN eh.DISCHARGE_PROV_ID IS NOT NULL THEN CONCAT(''5~'',eh.DISCHARGE_PROV_ID) END as VisitDischargeProviderID

		, COALESCE(pc.NAME, et.NAME) as VisitType
		, COALESCE(prc.EXTERNAL_NAME, hs.NAME) as VisitService

		, CASE WHEN est.NAME = ''Invalid'' THEN st.NAME /*To get more granular results like Cancelled and No Show*/
			   WHEN est.NAME = ''Possible'' THEN ''Scheduled'' 
			   when est.name = ''Complete'' then ''Completed''
			   ELSE est.NAME END AS VisitStatus

		, e.EFFECTIVE_DATE_DT as VisitDateOfService
		, e.EFFECTIVE_DATE_DTTM as VisitDatetimeOfService

		, e.APPT_MADE_DATE as VisitDateOfScheduling
		, e.APPT_TIME as VisitDateOfAppointment
		, COALESCE(eh.HOSP_ADMSN_TIME, e.CHECKIN_TIME) as VisitDateOfAdmission
		, COALESCE(eh.HOSP_DISCH_TIME, e.CHECKOUT_TIME) as VisitDateOfDischarge
		, e.ENC_CLOSE_DATE as VisitDateofClosing
		, e.APPT_CANCEL_DATE as VisitDateOfCancellation
		, can.NAME as VisitCancellationReason
		, CASE WHEN e.HSP_ACCOUNT_ID IS NULL THEN 1 
			   WHEN e.PAT_ENC_CSN_ID = har.PRIM_ENC_CSN_ID THEN 1 
			   ELSE 0 END  as VisitIsPrimary
		,1 AS VisitIsActive
		,GETDATE() as VisitUpdatedDatetime

		from [CLARITY].[ORGFILTER].PAT_ENC e
			left join [CLARITY].[ORGFILTER].ZC_APPT_STATUS st ON st.APPT_STATUS_C = e.APPT_STATUS_c
			left join [CLARITY].[ORGFILTER].ZC_CALCULATED_ENC_STAT est ON est.CALCULATED_ENC_STAT_C = e.CALCULATED_ENC_STAT_C
			left join [CLARITY].[ORGFILTER].CLARITY_DEP dep1 ON e.EFFECTIVE_DEPT_ID = dep1.DEPARTMENT_ID
			left join [CLARITY].[ORGFILTER].CLARITY_LOC loc1 ON loc1.LOC_ID = dep1.REV_LOC_ID --e.PRIMARY_LOC_ID --AND loc1.SERV_AREA_ID in (425,430) /*HPI and TPG*/
			left join [CLARITY].[ORGFILTER].[ZC_DISP_ENC_TYPE] et ON et.DISP_ENC_TYPE_C = e.ENC_TYPE_C
			left join [CLARITY].[ORGFILTER].[CLARITY_PRC] prc ON prc.PRC_ID = e.APPT_PRC_ID
			left join [CLARITY].[ORGFILTER].HSP_ACCOUNT har ON har.HSP_ACCOUNT_ID = e.HSP_ACCOUNT_ID
			left join [CLARITY].[ORGFILTER].ZC_CANCEL_REASON can ON can.CANCEL_REASON_C = e.CANCEL_REASON_C

			/*Hospital Encounter Info*/
			left join [CLARITY].[ORGFILTER].PAT_ENC_HSP eh ON eh.PAT_ENC_CSN_ID = e.PAT_ENC_CSN_ID
			left join [CLARITY].[ORGFILTER].[ZC_PAT_STATUS] ps ON ps.ADT_PATIENT_STAT_C = eh.ADT_PATIENT_STAT_C
			left join [CLARITY].[ORGFILTER].[ZC_PAT_CLASS] pc ON pc.ADT_PAT_CLASS_C = eh.ADT_PAT_CLASS_C
			left join [CLARITY].[ORGFILTER].ZC_PAT_SERVICE hs ON eh.HOSP_SERV_C = hs.HOSP_SERV_C
			--left join [CLARITY].[ORGFILTER].ZC_ED_DISPOSITION edd ON eh.ED_DISPOSITION_C = edd.ED_DISPOSITION_C
		
			/*Provider Info*/
			left join [CLARITY].[ORGFILTER].CLARITY_SER ser1 ON ser1.PROV_ID = e.VISIT_PROV_ID
			left join [CLARITY].[ORGFILTER].CLARITY_SER ser2 ON ser2.PROV_ID = eh.ADMISSION_PROV_ID
			left join [CLARITY].[ORGFILTER].CLARITY_SER ser3 ON ser3.PROV_ID = eh.DISCHARGE_PROV_ID

	   where 1=1
		AND e.ENC_TYPE_C in (3 /*Hospital Encounter*/
							,50 /*Appointment*/
							,53 /*Anesthesia Event*/
							,101 /*Office Visit*/
							,1003 /*Procedure Visit*/
							,83 /*Pre-admission Testing*/
							--,51 /*Surgery*/ 
							--,55 /*Ancillary Procedure*/
							)

		AND e.CONTACT_DATE >= ''1/1/2021''
		AND (loc1.SERV_AREA_ID in (425,430,452000)) --or eh.ADT_SERV_AREA_ID in (425,430) /*HPI*/)
		--AND e.HSP_ACCOUNT_ID in (606127165,606102824)
		')
	-- Safety check and transaction
    IF (SELECT COUNT(1) FROM #StagingTable) >= 10
		BEGIN
		    BEGIN TRY
		        BEGIN TRANSACTION;
		        PRINT 'At least 10 rows found. Deleting and reloading fact.Visits2...';

				PRINT 'Deleting FROM fact.Visits2...'
		        DELETE FROM fact.Visits2 WHERE VisitDatasourceID = 5;

				PRINT 'Inserting INTO act.Visits2...'
		        INSERT INTO fact.Visits2 (
		            [VisitID], [VisitDatasourceID], [VisitSourceID], [VisitPatientID],
		            [VisitAccountID], [VisitLocationID], [VisitDepartmentID], [VisitRoomID],
		            [VisitPrimaryProviderID], [VisitAppointmentProviderID], [VisitAdmittingProviderID],
		            [VisitAttendingProviderID], [VisitDischargeProviderID], [VisitType], [VisitService],
		            [VisitStatus], [VisitDateOfService], [VisitDatetimeOfService],
		            [VisitDateOfScheduling], [VisitDateOfAppointment], [VisitDateOfAdmission],
		            [VisitDateOfDischarge], [VisitDateofClosing], [VisitDateOfCancellation],
		            [VisitCancellationReason], [VisitIsPrimary], [VisitIsActive], [VisitUpdatedDatetime]
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

		DROP TABLE IF EXISTS #StagingTable
END;
GO
