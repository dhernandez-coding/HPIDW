CREATE PROCEDURE [stg].[spMedhostNSReloadFactTransactions2Incremental]
as

BEGIN
/*Deletes last 10 days of posted transactions and reloads just those days*/
DELETE FROM fact.Transactions2 WHERE TransactionDataSourceID = 2 AND TransactionDateOfPosting >= convert(date,DATEADD(DAY,-10,GETDATE()))

/*Query for Transactions  - Charges*/
INSERT INTO fact.Transactions2
	(--[TransactionID]
      [TransactionDatasourceID]
      ,[TransactionSourceID]
      ,[TransactionVisitID]
	  ,[TransactionAccountID]
      ,[TransactionDepartmentID]
      ,[TransactionPayerID]
      ,[TransactionBillingProviderID]
      ,[TransactionBillingType]
      ,[TransactionType]
      ,[TransactionSubType]
      ,[TransactionRevenueCode]
      ,[TransactionRevenueCodeDescription]
      ,[TransactionCode]
      ,[TransactionDescription]
      ,[TransactionCPTCode]
      ,[TransactionModifier1]
      ,[TransactionModifier2]
      ,[TransactionModifier3]
      ,[TransactionModifier4]
      ,[TransactionUnits]
      ,[TransactionAmount]
      ,[TransactionDateOfService]
      ,[TransactionDateOfPosting]
      ,[TransactionDateOfBilling]
      ,[TransactionReportingPeriodID]
      ,[TransactionStatus]
      ,[TransactionIsActive]
      ,[TransactionUpdatedDateTime]
	  )

  SELECT 
	--CONCAT('2~CHG~',c.PATNO,'~',c.BATCH,'~',c.SEQ#,'~',c.REF#) as TransactionID /*This is not unique*/
	'2' as TransactionDatasourceID
	,CONCAT('CHG~',c.PATNO,'~',c.BATCH,'~',c.SEQ#,'~',c.REF#) as TransactionSourceID
	,CONCAT('2~',c.PATNO) as TransactionVisitID
	,CONCAT('2~',c.PATNO) as TransactionAccountID
	,CONCAT('2~',c.DEPT) as TransactionDepartmentID
	,CONCAT('2~',CASE WHEN c.AINSCO = '0' THEN '999' ELSE c.AINSCO END) as TransactionPayerID 
	,CONCAT('2~',c.NWDOCNO) as TransactionBillingProviderID
	,'HB' as TransactionBillingType --c.BILLID as TransactionBillingType
	,'Charge' as TransactionType
	,'Charge' as TransactionSubType
	,c.INSCD as TransactionRevenueCode
	,c.LITRL as TransactionRevenueCodeDescription
	,c.SVCCD as TransactionCode
	,c.ChargeDescription as TransactionDescription
	,c.CPTCDA as TransactionCPTCode
	,c.MOD1 as TransactionModifier1
	,c.MOD2 as TransactionModifier2
	,c.MOD3 as TransactionModifier3
	,c.MOD4 as TransactionModifier4
	,c.QTY as TransactionUnits
	,c.AMT1 as TransactionAmount
	,CASE WHEN c.ISDATE = '0001-01-01' THEN NULL ELSE c.ISDATE END as TransactionDateOfService
	,CASE WHEN c.ISPDATEA = '0001-01-01' THEN NULL ELSE c.ISPDATEA END as TransactionDateOfPosting
	,CASE WHEN c.ISBILDTE = '0001-01-01' THEN NULL ELSE c.ISBILDTE END as TransactionDateOfBilling
	,cast(c.ISMTENDD as varchar(100)) as TransactionReportingPeriodID
	,'Active' as TransactionStatus
	,1 as TransactionIsActive
	,GETDATE() as TransactionUpdatedDatetime
 --select * 
 FROM OPENQUERY([hmsls],'
	select 
	cd.DESC AS ChargeDescription
	,rc.LITRL
	,c.*
	from MHD32.HOSPF100.ACCUMCHG c
		left join MHD32.HOSPF100.CHRGDESC cd ON cd.SVCCD = c.SVCCD
		left join MHD32.HOSPF100.INSCDSUM rc ON rc.INSCD4 = c.INSCD
	where 1=1 
	AND CAST(ISPDATEA as DATE) >= (CURRENT_DATE - 10 DAYS)  /*Exclude older transactions for processing sake*/
	AND (c.INSCD IS NULL OR c.INSCD > 8) /*Exclude Payments and Adjustments*/

	') c

  
/*Query for Transactions  - Adjustments, Payments*/
INSERT INTO fact.Transactions2
	(--[TransactionID]
      [TransactionDatasourceID]
      ,[TransactionSourceID]
      ,[TransactionVisitID]
	  ,[TransactionAccountID]
      ,[TransactionDepartmentID]
      ,[TransactionPayerID]
      ,[TransactionBillingProviderID]
      ,[TransactionBillingType]
      ,[TransactionType]
      ,[TransactionSubType]
      ,[TransactionRevenueCode]
      ,[TransactionRevenueCodeDescription]
      ,[TransactionCode]
      ,[TransactionDescription]
      ,[TransactionCPTCode]
      ,[TransactionModifier1]
      ,[TransactionModifier2]
      ,[TransactionModifier3]
      ,[TransactionModifier4]
      ,[TransactionUnits]
      ,[TransactionAmount]
      ,[TransactionDateOfService]
      ,[TransactionDateOfPosting]
      ,[TransactionDateOfBilling]
      ,[TransactionReportingPeriodID]
      ,[TransactionStatus]
      ,[TransactionIsActive]
      ,[TransactionUpdatedDateTime]
	  )

SELECT-- CONCAT('2~RECID~',t.PATNO,'~',t.BATCH,'~',t.SEQNUM,'~',t.TCODE) as TransactionID /*This is not unique*/
	'2' as TransactionDatasourceID
	,CONCAT('RECID~',t.PATNO,'~',t.BATCH,'~',t.SEQNUM,'~',t.TCODE) as TransactionSourceID
	,CONCAT('2~',t.PATNO) as TransactionVisitID
	,CONCAT('2~',t.PATNO) as TransactionAccountID
	,NULL as TransactionDepartmentID
	,CONCAT('2~',t.INSCOP) as TransactionPayerID
	,CONCAT('2~',t.NWDRNUM) as TransactionBillingProviderID
	,'HB' as TransactionBillingType --NULL as TransactionBillingType
	,CASE WHEN t.RECID in ('P','R') THEN 'Payment'
		  WHEN t.RECID IN ('A') THEN 'Adjustment'
	      ELSE t.RECID END as TransactionType
	,CASE WHEN t.RECID in ('P') THEN 'Payment - Regular'
	      WHEN t.RECID in ('R') THEN 'Payment - Bad Debt'
	      WHEN t.RECID IN ('A') THEN 'Adjustment'
	      ELSE t.RECID END as TransactionSubType
	,NULL as TransactionRevenueCode
	,NULL as TransactionRevenueCode
	,t.TCODE as TransactionCode
	,t.TRNDSC as TransactionDescription
	,NULL as TransactionCPTCode
	,NULL as TransactionModifier1
	,NULL as TransactionModifier1
	,NULL as TransactionModifier1
	,NULL as TransactionModifier1
	,1 as TransactionUnits
	,t.TAMT as TransactionAmount
	,t.ISOTRDATE as TransactionDateOfService
	,t.ISOODATE as TransactionDateOfPosting
	,NULL as TransactionDateOfBilling
	,t.ISOMTENDD as TransactionReportingPeriodID
	,'Active' as TransactionStatus
	,1 as TransactionIsActive
	,GETDATE() as TransactionUpdatedDatetime
  --select t.*
  FROM OPENQUERY([hmsls],'
	select --count(1)
	cd.TRNDSC
	,a.*
	from MHD32.HOSPF100.ARACCUM a
		left join MHD32.HOSPF100.ARDESC cd ON cd.TRNCDE = a.TCODE
	where 1=1
	AND CAST(ISOODATE as DATE) >= (CURRENT_DATE - 10 DAYS) 
	and a.RECID not in (''M'')
	--and PATNO = 600267
	--fetch first 100 rows only
	--order by PATNO
	') t
	
END
GO
