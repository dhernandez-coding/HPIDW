CREATE PROCEDURE [rpt].[spSelectStrykerDataAppendixC] as



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
				OR vp.VisitProcedureCode IN ('27120','27122','27125','27130','27132','27134','27137','27138','27440','27441','27442','27443','27445','27446','27447','27486','27487') );
	--GROUP BY vp.VisitProcedureVisitID


WITH CTE AS (
SELECT
a.*
,pf.*
FROM fact.VisitCases vc 
		INNER JOIN @TABLE_ProceduresFilter pf ON pf.VisitProcedureVisitID = vc.VisitCaseVisitID  AND  pf.VisitProcedureType = 'Principal'
		LEFT JOIN fact.Visits2 v ON v.VisitID = vc.VisitCaseVisitID
		LEFT JOIN fact.Accounts a ON a.AccountID = v.VisitAccountID

WHERE 1=1 
		--AND vc.VisitCaseID IN ('5~1901549') 
		AND vc.VisitCaseScheduleStatus <> 'Canceled'
		AND vc.VisitCaseServiceDate >= '5/1/2023' /*Epic Go-live*/
		AND vc.VisitCaseServiceDate >= @StartDate -- DATEFROMPARTS(YEAR(GETDATE())-1,1,1) 
		AND vc.VisitCaseServiceDate < @EndDate --DATEFROMPARTS(YEAR(GETDATE()),MONTH(GETDATE()),1)
)

SELECT 
	CTE.AccountDateOfDischarge,
    a2.AccountID AS ReadmissionAccountID
    ,a2.AccountDateOfAdmission AS 'DateofReturnToHospital'
	,p.PatientMRN as 'MedicalRecordNumber'
	,a2.AccountDateOfDischarge as 'ReturnToHospitalDateOfDischarge'
	,a2.AccountClass as 'ReturnToHospitalEncounterType'
	,(SELECT TOP 1 vp.VisitProcedureCode FROM fact.VisitProcedures vp WHERE vp.VisitProcedureType = 'Principal') as 'PrimaryProcedure'
	,(SELECT STRING_AGG(vp.VisitProcedureCode, ',') FROM fact.VisitProcedures vp WHERE 1=1 AND  vp.VisitProcedureVisitID = vc.VisitCaseVisitID AND vp.VisitProcedureType = 'Secondary' ) as 'AllProceduresCode' 
	,(SELECT STRING_AGG(vdc.VisitDiagnosisCode, ',') FROM fact.VisitDiagnoses vdc WHERE vdc.VisitDiagnosisVisitID = vc.VisitCaseVisitID) as 'AllDiagnosisCode' 
		
FROM CTE cte
LEFT JOIN fact.Accounts a2 ON a2.AccountPatientID = cte.AccountPatientID
    AND a2.AccountDateOfAdmission > cte.AccountDateOfDischarge
    AND a2.AccountDateOfAdmission <= DATEADD(DAY, 90, cte.AccountDateOfDischarge)
LEFT JOIN dim.Patients p ON p.PatientID = a2.AccountPatientID
LEFT JOIN fact.VisitProcedures vp ON vp.VisitProcedureAccountID = a2.AccountID
LEFT JOIN fact.Visits2 v ON a2.AccountID = v.VisitAccountID
LEFT JOIN fact.VisitCases vc ON v.VisitID = vc.VisitCaseVisitID
WHERE a2.AccountID IS NOT NULL;
GO
