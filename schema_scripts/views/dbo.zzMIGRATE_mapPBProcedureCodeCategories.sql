--USE HPIDW
CREATE VIEW [dbo].[zzMIGRATE_mapPBProcedureCodeCategories] as

/*
	1. Logan - Redesign App DB table to match this schema (PBProcedureCode, Description, CategoryID, ServiceLineID, DHSCategoryID, IsLocationDependent, IsInPlay, IsTHPLab, FirstPostDate, LastPostDate, TotalPostedCharges)
	2. Logan - Load App DB table with the infrormation in this view (HPIDW.dbo.zzMIGRATE_mapPBProcedureCodeCategories
	3. Logan - ETL to hpi_etl tables
	4. Logan - Create a view in HPIDW.app.xxxxxxx for UPSERT procedure of this info into App DB table (pointed to hpi_etl table)
	5. Logan - Design nightly ETL process to UPSERT records from this view into App DB table (insert new records and only update FirstPostDate, LastPostDate, TotalChargesPosted columns) 
	6. Logan - Redesign front end of HERO to match new schmea
	7. Logan - Determine ETL frequency back to hpi_etl
	6. Chris - Repoint dependent views to new HPI_etl tables
*/


SELECT


	COALESCE(t.TransactionCPTCode,t.TransactionCode) as ProcedureCode
	,MAX(t.TransactionCPTDescription) as CptDescription
	,pc.ProcedureCode as MappedProcedureCode
	,pc.ProcedureCodeCategoryId as ProcedureCodeCategoryId
	--,pcc.ProcedureCategory as Category
	,pc.ProcedureCodeServiceLineId as ProcedureCodeServiceLineId
	--,sl.ServiceLineName as ServiceLine
	,pc.ProcedureCodeDHSCategoryId as ProcedureCodeDHSCategoryId
	--,dhsc.DHSCategoryName as DHSCategory
	,pc.ProcedureCodeIsLocationDependent as ProcedureCodeIsLocationDependent


	,pc.ProcedureCodeInPlay as ProcedureCodeInPlay
	,pc.ProcedureCodeTHPLab as ProcedureCodeTHPLab
	,CASE WHEN pc.ProcedureCode is null THEN 0 ELSE 1 END  AS IsMapped

	,MIN(t.TransactionDateOfPosting) as FirstPostDate
	,MAX(t.TransactionDateOfPosting) as LastPostDate
	,SUM(t.TransactionAmount) as TotalCharges
	,COUNT(t.TransactionAmount) as ChargeCount
FROM HPIDW.fact.TransactionsPB t
	left join HPIAPP.dbo.PbProcedureCodes pc ON pc.ProcedureCode = COALESCE(t.TransactionCPTCode,t.TransactionCode)
	Left Join HPIApp.dbo.PBProcedureCategories pcc on pc.ProcedureCodeCategoryId = pcc.Id
	Left Join HPIApp.dbo.ServiceLines sl on pc.ProcedureCodeServiceLineId = sl.ServiceLineID
	left join HPIApp.dbo.DHSCategories dhsc on pc.ProcedureCodeDHSCategoryId = dhsc.DHSCategoryID
WHERE 1=1
	AND t.TransactionType = 'Charge'
GROUP BY 
	COALESCE(t.TransactionCPTCode,t.TransactionCode)
	,pc.ProcedureCode
	,pc.ProcedureCodeCategoryId
	,pcc.ProcedureCategory
	,pc.ProcedureCodeServiceLineId
	,sl.ServiceLineName
	,pc.ProcedureCodeIsLocationDependent
	,pc.ProcedureCodeDHSCategoryId
	,dhsc.DHSCategoryName
	,pc.ProcedureCodeInPlay
	,pc.ProcedureCodeTHPLab
--ORDER BY 
--	PBProcedureCode
GO
