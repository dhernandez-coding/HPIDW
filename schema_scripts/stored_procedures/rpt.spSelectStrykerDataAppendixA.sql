CREATE PROCEDURE [rpt].[spSelectStrykerDataAppendixA] as

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


----Output Results
	PRINT 'Returning Results...'
	SELECT 
		
		vc.VisitCaseID as 'CaseID'
		,p.PatientMRN as 'MedicalRecordNumber'
		,p.PatientFirstName as 'FirstName'
		,p.PatientLastName as 'LastName'
		,p.PatientDateOfBirth as 'DOB'
		,LEFT(p.PatientGender,1) as 'Gender'
		,NULL AS 'BMI'
		,NULL AS 'Height'
		,NULL AS 'Weight'
		,NULL as 'RACE'
		,p.PatientEmailAddress as 'PatientEmailAddress'
		,vc.VisitCaseAdmissionStatus as 'AdmissionStatus' --I need to search this one 
		,vc.VisitCasePatientClass as 'Encounter type'
		,pf.VisitProcedureCode as 'PrimaryProcedureCode' 
		,pf.VisitProcedureDescription as 'Primaryproceduredescription'
		,NULL as 'SideOfBody'
		,(SELECT pro.ProviderFirstName+ ' ' +pro.ProviderLastName
        FROM dim.vProviders pro 
        WHERE pro.ProviderID = v.VisitPrimaryProviderID)  as 'PrimarySurgeon' 
		,(SELECT pro.ProviderNPI
        FROM dim.vProviders pro 
        WHERE pro.ProviderID = v.VisitPrimaryProviderID) as 'Primary surgeon NPI'
		,v.VisitDateOfAdmission as 'DateAndTimeAdmission'
		,vc.VisitCaseProcedureEndDatetime as 'DateOfSurgery'
		,v.VisitDateOfDischarge as 'DateAndTimedischarge'
		,(SELECT STRING_AGG(pf.VisitProcedureCode, ',') FROM @TABLE_ProceduresFilter pf WHERE 1=1 AND  pf.VisitProcedureVisitID = vc.VisitCaseVisitID AND pf.VisitProcedureType = 'Secondary' ) as 'AllProceduresCode' 
		,(SELECT STRING_AGG(vdc.VisitDiagnosisCode, ',') FROM fact.VisitDiagnoses vdc WHERE vdc.VisitDiagnosisVisitID = vc.VisitCaseVisitID) as 'AllDiagnosisCode' 
		,NULL AS 'Present on admission status'
		,NULL as 'DischargeCode'
		,vc.VisitCaseDischargeDisposition as  'DischargeDisposition' 
		,a.AccountDRG as 'DRG'
		,(SELECT dim.PayerName 
        FROM dim.Payers dim 
        WHERE dim.PayerID = a.accountPrimaryPayerID) as 'PrimaryPayor' 
		,(SELECT pg.PayerGroupName 
		FROM dim.PayerGroups pg
		WHERE pg.PayerGroupID = 
       (SELECT p.PayerGroupID 
        FROM dim.Payers p 
        WHERE p.PayerID = a.accountPrimaryPayerID)) as 'PrimaryPayorGroup'
		,NUll AS 'Reimbursement'
		,NULL as 'Flexion'
		,NULL as 'Extension'
		,NULL as 'DistanceWalkedOneTime'
		,NULL as 'DistanceOnDaySurgery'
		,NULL as 'VASPainScore'

		--,vc.*
		,v.VisitID
		,a.AccountID
		
	FROM fact.VisitCases vc 
		INNER JOIN @TABLE_ProceduresFilter pf ON pf.VisitProcedureVisitID = vc.VisitCaseVisitID  AND  pf.VisitProcedureType = 'Principal'
		LEFT JOIN fact.Visits2 v ON v.VisitID = vc.VisitCaseVisitID
		LEFT JOIN fact.Accounts a ON a.AccountID = v.VisitAccountID
		LEFT JOIN dim.Patients p ON p.PatientID = v.VisitPatientID
		LEFT JOIN fact.Visits vs ON vs.VisitID =  v.VisitID
		--INNER JOIN fact.VisitDiagnoses vdc on vdc.VisitDiagnosisVisitID = vc.VisitCaseVisitID

	WHERE 1=1 
		--AND vc.VisitCaseID IN ('5~1901549') 
		AND vc.VisitCaseScheduleStatus <> 'Canceled'
		AND vc.VisitCaseServiceDate >= '5/1/2023' /*Epic Go-live*/
		AND vc.VisitCaseServiceDate >= @StartDate -- DATEFROMPARTS(YEAR(GETDATE())-1,1,1) 
		AND vc.VisitCaseServiceDate < @EndDate --DATEFROMPARTS(YEAR(GETDATE()),MONTH(GETDATE()),1)
		--AND
GO
