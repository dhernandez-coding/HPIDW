CREATE view [fact].[vVisitProcedures] as

SELECT
	[VisitProcedureID]
	,[VisitProcedureDataSourceID]
	,[VisitProcedureSourceID]
	,[VisitProcedureVisitID]
	,VisitProcedureAccountID
	,[VisitProcedureType]
	,[VisitProcedureSequence]
	,[VisitProcedureCodeType]
	,[VisitProcedureCode]
	,[VisitProcedureDescription]
	,CONCAT([VisitProcedureCode],' - ',[VisitProcedureDescription],' (',[VisitProcedureCodeType],')') as VisitProcedureCodeWithDescription
	,[VisitProcedureMod1]
	,[VisitProcedureMod2]
	,[VisitProcedureMod3]
	,[VisitProcedureMod4]
	,[VisitProcedureProviderID]
	,[VisitProcedureDate]
	,[VisitProcedureIsPrimary]
	,[VisitProcedureIsActive]
	,[VisitProcedureUpdatedDatetime]
FROM [HPIDW].[fact].[VisitProcedures]
GO
