CREATE VIEW [rpt].[vBlueBooks] AS 
 SELECT 
	  bb.[BlueBooksID]
      ,bb.[FiscalYear]
      ,bb.[FiscalPeriod]
      ,bb.[FiscalYearPeriod]
	  ,DATEFROMPARTS(bb.FiscalYear,CASE WHEN bb.FiscalPeriod = 0 THEN 1 ELSE bb.FiscalPeriod END,1) as FiscalPeriodDate
      ,bb.[ReportSection]
      ,bb.[ReportGroupLevel1]
       ,CASE WHEN bb.ReportSection in ('Revenue','Expenses') THEN RIGHT(bb.ReportGroupLevel1,(LEN(bb.ReportGroupLevel1) - 3)) 
       ELSE bb.ReportGroupLevel1 END as ReportGroupLevel1Clean
      ,bb.[ReportGroupLevel2]
      ,CASE WHEN bb.ReportSection in ('Revenue','Expenses') THEN RIGHT(bb.ReportGroupLevel2,(LEN(bb.ReportGroupLevel2) - 3)) 
       ELSE bb.ReportGroupLevel2 END as ReportGroupLevel2Clean
      ,bb.[ReportGroupLevel3]
      ,CASE WHEN bb.ReportSection in ('Revenue','Expenses') THEN RIGHT(bb.ReportGroupLevel3,(LEN(bb.ReportGroupLevel3) - 3)) 
       ELSE bb.ReportGroupLevel3 END as ReportGroupLevel3Clean
      ,bb.[ReportGroupLevel4]
      ,bb.[PracticeID]
      ,bb.[ReportingProviderID]
      ,bb.[FiscalPeriodValue]
      ,bb.[FiscalPeriodNumerator]
      ,bb.[FiscalPeriodDenominator]
	  ,CASE WHEN ReportSection like '%Charge Lag%' OR ReportSection like '%Payment Lag%' THEN 'Fraction' ELSE 'Sum' END as FiscalPeriodValueType
	  ,'Actual' as ReportSectionType
      ,bb.[UpdatedDatetime]
  --select distinct FiscalYear, FiscalPeriod
  FROM [HPIDW].[rpt].[BlueBooks] bb
	left join dim.Practices p ON p.PracticeID = bb.PracticeID
  WHERE 1=1
	AND (p.PracticeCompany <> 'EXTERNAL' OR p.PracticeCompany IS NULL) -- Modifying this to include 10~Default DH
	AND bb.FiscalYear >= 2023
    --AND DATEFROMPARTS(bb.FiscalYear,CASE WHEN bb.FiscalPeriod = 0 THEN 1 ELSE bb.FiscalPeriod END,1) < DATEADD(
    --MONTH, -1,
    --DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1) -- just for excluding apr
GO
