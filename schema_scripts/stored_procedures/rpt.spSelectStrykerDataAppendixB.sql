CREATE PROCEDURE rpt.spSelectStrykerDataAppendixB as

DECLARE @StartDate date = DATEFROMPARTS(YEAR(GETDATE())-1,1,1) 
DECLARE @EndDate date = DATEFROMPARTS(YEAR(GETDATE()),MONTH(GETDATE()),1)

DECLARE @TABLE_ProceduresFilter TABLE (
	VisitProcedureVisitID varchar(100)
	,VisitProcedureCode varchar(30)
	,VisitProcedureDescription varchar(300)
	,VisitProcedureType varchar(100))
	
	--SELECT * FROM fact.VisitDiagnoses
----Insert Qualifying Visits by Procedure into temp table
PRINT 'Inserting Qualifying Visits by Procedure into temp table...'

	INSERT INTO @TABLE_ProceduresFilter
	SELECT 
		vp.VisitProcedureVisitID
		,vp.VisitProcedureCode 
		,vp.VisitProcedureDescription
		,vp.VisitProcedureType
	FROM fact.VisitProcedures vp 
	WHERE 1=1
		--AND vp.VisitProcedureType = 'Secondary'
		--AND vp.VisitProcedureVisitID IN ('5~30179305201','5~30179305538','5~30179306931')
		AND (LEFT(vp.VisitProcedureCode,4) IN ('0SR9','0SRB','0SW9','0SWA','0SWB','0SWC','0SWD','0SWE','0SWR','0SWS','0SWT','0SWU','0SWV','0SWW','0SRA','0SRE','0SRR','0SRS','0SU9',
												'0SUB','0SUA','0SUE','0SUR','0SUS','0SP9','0SPA','0SPB','0SPC','0SPD','0SPE','0SPR','0SPS','0SPT','0SPU','0SPV','0SPW','0SRC','0SRD','0SWC',
												'0SWD','0SRT','0SRU','0SRV','0SRW','0SUC','0SUD','0SUT','0SUU','0SUV','0SUW','0QUD','0QUF','0QRD','0QRF','0QPD','0QPF')
				OR vp.VisitProcedureCode IN ('27120','27122','27125','27130','27132','27134','27137','27138','27440','27441','27442','27443','27445','27446','27447','27486','27487') )
	--GROUP BY vp.VisitProcedureVisitID

PRINT 'Returning Results Appendix B...'

	SELECT 
		
		vc.VisitCaseID as 'CaseID'
		,p.PatientMRN as 'MedicalRecordNumber'
		,(SELECT pro.ProviderFirstName+ ' ' +pro.ProviderLastName
        FROM dim.Providers pro 
        WHERE pro.ProviderID = v.VisitPrimaryProviderID)  as 'PrimarySurgeon' 
		,pf.VisitProcedureDescription as 'Primaryproceduredescription'
		,vc.VisitCaseASARating as 'ASAClass'
		, NULL as 'Preference card procedure that information is here OR_LOG_ALL_PROC under the column ALL_PROC_AS_ORDERED'
		, vc.VisitCaseAnesthesiaProviderID as 'AnesthesiaProvider'
		, vc.VisitCaseAnesthesiaType as 'AnesthesiaTypeI'
		,r.RoomName AS ORName
		,vc.VisitCaseTotalTimeNeeded AS 'EstimatedDuration'
		,vc.VisitCaseFirstCaseofDay AS 'FirstCaseOfDayIndicator'
		,vc.VisitCaseScheduleStartDateTime AS 'SchedulePatientinroomTime'
		,vc.VisitCaseORBeginDatetime AS 'ActualPatientinroomTime'
		,vc.VisitCaseProcedureBeginDatetime as 'ActualSurgeryStartTime'
		
		
	 
		
	
	FROM fact.VisitCases vc 
		INNER JOIN @TABLE_ProceduresFilter pf ON pf.VisitProcedureVisitID = vc.VisitCaseVisitID  
		LEFT JOIN fact.Visits2 v ON v.VisitID = vc.VisitCaseVisitID
		LEFT JOIN fact.Accounts a ON a.AccountID = v.VisitAccountID
		LEFT JOIN dim.Patients p ON p.PatientID = v.VisitPatientID
		LEFT JOIN dim.Rooms r on r.RoomID = vc.VisitCaseRoomID

	WHERE 1=1 
		--AND vc.VisitCaseID IN ('5~1901549') 
		AND vc.VisitCaseScheduleStatus <> 'Canceled'
		AND vc.VisitCaseServiceDate >= '5/1/2023' /*Epic Go-live*/
		AND vc.VisitCaseServiceDate >= @StartDate -- DATEFROMPARTS(YEAR(GETDATE())-1,1,1) 
		AND vc.VisitCaseServiceDate < @EndDate --DATEFROMPARTS(YEAR(GETDATE()),MONTH(GETDATE()),1)



/* # Field name Notes / Definition
1 Encounter number/case id One unique identifier should be common across files submitted
2 Medical record number
3 Surgeon name Primary surgeon performing the procedure
4 Procedure description Description of surgical procedure
5 ASA Class ASA physical status classification
6 Preference card procedure name Procedure name of surgeon preference card for case
7 Anesthesia provider Anesthesiologist or CRNA
8 Anesthesia type 1 Primary anesthesia used
9 Anesthesia type 2 Secondary anesthesia used
10 Operating room name/number Operating room name and/or number
11 First assist First assist name
12 Physician assist Physician's assist name
13 Surgical tech Surgical tech name
14 Circulating nurse Circulating nurse name
15 Resident Resident name
16 Estimated duration hh:mm Estimated time for patient in-room time to patient out-of-room time
17 First case of the day indicator Flag or indicator for first OR case of the day in each room
18 Scheduled patient in-room time mm/dd/yyyy hh:mm (Scheduled case start time)
19 Actual patient in-room time mm/dd/yyyy hh:mm
20 Actual surgery start time mm/dd/yyyy hh:mm
21 Tourniquet start time mm/dd/yyyy hh:mm
22 Tourniquet stop time mm/dd/yyyy hh:mm */
GO
