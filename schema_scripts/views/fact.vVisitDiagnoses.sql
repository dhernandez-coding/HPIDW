CREATE view [fact].[vVisitDiagnoses] as

SELECT
	[VisitDiagnosisID]
	,[VisitDiagnosisDataSourceID]
	,[VisitDiagnosisSourceID]
	,[VisitDiagnosisVisitID]
	,[VisitDiagnosisAccountID]
	,[VisitDiagnosisType]
	,[VisitDiagnosisSequence]
	,[VisitDiagnosisCodeType]
	,[VisitDiagnosisCode]
	,[VisitDiagnosisDescription]
	,CONCAT([VisitDiagnosisCode],' - ',[VisitDiagnosisDescription],' (',[VisitDiagnosisCodeType],')') as VisitDiagnosisCodeWithDescription
	,[VisitDiagnosisDate]
	,[VisitDiagnosisIsPrimary]
	,[VisitDiagnosisIsActive]
	,[VisitDiagnosisUpdatedDatetime]
FROM [HPIDW].[fact].[VisitDiagnoses]
GO
