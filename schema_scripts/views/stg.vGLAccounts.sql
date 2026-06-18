CREATE VIEW [stg].[vGLAccounts] as

select
	CAST(a.ACTINDX as VARCHAR (100)) as GLAccountSourceID
	,i.ACTNUMST as GLAccountNumber
	,a.ACTDESCR as GLAccountName
	,a.ACTNUMBR_1 as GLAccountDescriptionID
	,a.ACTNUMBR_2 as GLAccountTypeID
	,a.ACTNUMBR_3 as GLAccountLocationID
	,a.ACTNUMBR_4 as GLAccountPracticeID
	,a.ACTNUMBR_5 as GLAccountProviderID
	,a.ACCATNUM as GLAccountCategoryID
	,s1.DSCRIPTN as GLAccountDescription
	,s2.DSCRIPTN as GLAccountType
	,s3.DSCRIPTN as GLAccountLocation
	,s4.DSCRIPTN as GLAccountPractice
	,CASE WHEN a.ACTNUMBR_5 = '096' THEN 'AMB2' /*Mapping for Ball since Barrit is also AMB*/
		  WHEN s5.DSCRIPTN = 'N/A' THEN '0'
		  ELSE s5.DSCRIPTN END as GLAccountProvider
	,CASE WHEN s5.DSCRIPTN is null THEN s4.DSCRIPTN
		  WHEN s5.DSCRIPTN = 'N/A' THEN s4.DSCRIPTN
		  WHEN s5.DSCRIPTN = '0' THEN s4.DSCRIPTN
		  WHEN a.ACTNUMBR_5 = '096' THEN 'AMB2' /*Mapping for Ball since Barrit is also AMB*/
		  ELSE s5.DSCRIPTN END as GLAccountReportingProvider
	,c.ACCATDSC as GLAccountCategory
	,CASE a.PSTNGTYP WHEN 0 THEN 'Balance Sheet' ELSE 'Profit and Loss' END as GLAccountReportType

	/*Chris Cross - 2/12/25 - Added conditional logic to separate x-ray and lab expenses per Nick H.*/
	,CASE WHEN LEFT(i.ACTNUMST,1) = '5' AND a.ACTNUMBR_2 = '41' THEN '02_X-ray Expense'
		  WHEN LEFT(i.ACTNUMST,1) = '5' AND a.ACTNUMBR_2 = '51' THEN '02_Lab Expense'
		  ELSE CONCAT(RIGHT(CONCAT('00',rg.GLAccountReportGroupLevel1Sort),2),'_',rg.GLAccountReportGroupLevel1) END as GLAccountReportGroupLevel1
	,CASE WHEN LEFT(i.ACTNUMST,1) = '5' AND a.ACTNUMBR_2 = '41' THEN '08_X-ray Expense'
		  WHEN LEFT(i.ACTNUMST,1) = '5' AND a.ACTNUMBR_2 = '51' THEN '08_Lab Expense'
		  ELSE CONCAT(RIGHT(CONCAT('00',rg.GLAccountReportGroupLevel2Sort),2),'_',rg.GLAccountReportGroupLevel2) END as GLAccountReportGroupLevel2
	
	,CASE WHEN LEFT(i.ACTNUMST,1) = '5' AND a.ACTNUMBR_2 = '41' THEN '02_Ancillary Service Expenses' --4.16.26 - Chris - maybe switch this to 02_Ancillary Service Expenses for Board Packet?
		  WHEN LEFT(i.ACTNUMST,1) = '5' AND a.ACTNUMBR_2 = '51' THEN '02_Ancillary Service Expenses' --4.16.26 - Chris - maybe switch this to 02_Ancillary Service Expenses for Board Packet?
		  ELSE CONCAT(RIGHT(CONCAT('00',rg.GLAccountReportGroupLevel3Sort),2),'_',rg.GLAccountReportGroupLevel3) END as GLAccountReportGroupLevel3
	--,CASE WHEN LEFT(i.ACTNUMST,1) = '5' AND a.ACTNUMBR_2 = '41' THEN '02_X-ray Expense' --4.16.26 - Chris - maybe switch this to 02_Ancillary Service Expenses for Board Packet?
		--  WHEN LEFT(i.ACTNUMST,1) = '5' AND a.ACTNUMBR_2 = '51' THEN '02_Lab Expense' --4.16.26 - Chris - maybe switch this to 02_Ancillary Service Expenses for Board Packet?
		--  ELSE CONCAT(RIGHT(CONCAT('00',rg.GLAccountReportGroupLevel3Sort),2),'_',rg.GLAccountReportGroupLevel3) END as GLAccountReportGroupLevel3
	,concat('0~',s4.DSCRIPTN) as PracticeID
	,CASE WHEN a.TPCLBLNC = 0 THEN 'Debit' ELSE 'Credit' END as GLAccountBalanceType
	,CASE WHEN a.ACCTTYPE = 1 THEN 'Posting Account'
		  WHEN a.ACCTTYPE = 2 THEN 'Unit Account'
		  WHEN a.ACCTTYPE = 3 THEN 'Posting Allocation Account'
		  WHEN a.ACCTTYPE = 4 THEN 'Unit Allocation Account'
	 END as GLAccountPostingType
	,rg.GLAccountIsAllocated
	,a.ACTIVE as GLAccountIsActive
	,GETDATE() as GLAccountUpdatedDatetime
from CORVMAP22.TPG.dbo.GL00100 a  --GL Accounts
	inner join CORVMAP22.TPG.dbo.GL00102 c on a.ACCATNUM = c.ACCATNUM --categories
	inner join CORVMAP22.TPG.dbo.GL00105 i on a.ACTINDX = i.ACTINDX --for account number
	left join CORVMAP22.TPG.dbo.GL40200 s1 ON s1.SGMNTID = a.ACTNUMBR_1 AND s1.SGMTNUMB = 1
	left join CORVMAP22.TPG.dbo.GL40200 s2 ON s2.SGMNTID = a.ACTNUMBR_2 AND s2.SGMTNUMB = 2
	left join CORVMAP22.TPG.dbo.GL40200 s3 ON s3.SGMNTID = a.ACTNUMBR_3 AND s3.SGMTNUMB = 3
	left join CORVMAP22.TPG.dbo.GL40200 s4 ON s4.SGMNTID = a.ACTNUMBR_4 AND s4.SGMTNUMB = 4
	left join CORVMAP22.TPG.dbo.GL40200 s5 ON s5.SGMNTID = a.ACTNUMBR_5 AND s5.SGMTNUMB = 5
	left join map.GLAccountReportGroups rg ON rg.GLAccountDescriptionID = a.ACTNUMBR_1
											and (ISNULL(rg.GLAccountTypeID,a.ACTNUMBR_2) = a.ACTNUMBR_2)
											--and (rg.GLAccountTypeID is not null OR rg.GLAccountTypeID = a.ACTNUMBR_2)
											and (rg.GLAccountLocationID is null OR rg.GLAccountLocationID = a.ACTNUMBR_3)
											and (rg.GLAccountPracticeID is null OR rg.GLAccountPracticeID = a.ACTNUMBR_4)
											and (rg.GLAccountProviderID is null OR rg.GLAccountProviderID = a.ACTNUMBR_5)
where 1=1 --and s4.DSCRIPTN ='PBJ'


UNION ALL 

--Here we need to revisit and check the category and category id

   SELECT  
	 CAST(CONCAT(CASE WHEN rg.GLAccountReportGroupLevel1 like '%Expense%' THEN '5' ELSE '4' END, '_', t.account,'-',t.practice,'-',mc.FixedClass) as varchar(255)) as GLAccountSourceID
	,CAST(CONCAT(CASE WHEN rg.GLAccountReportGroupLevel1 like '%Expense%' THEN '5' ELSE '4' END, '_', t.account,'-',t.practice,'-',mc.FixedClass) as varchar(255)) as GLAccountNumber
	,CAST(CONCAT(t.account,'-',t.practice,'-',mc.FixedClass) as varchar(255)) as GLAccountName
	,CAST(t.account as varchar(100)) as GLAccountDescriptionID
	,CAST(rg.GLAccountTypeID as varchar(100)) AS GLAccountTypeID
	,CAST(NULL AS varchar(100)) AS GLAccountLocationID
	,CAST(t.Practice as varchar(100)) as GLAccountPracticeID
	,CAST(mc.FixedClass as varchar(100)) as GLAccountProviderID
	,CAST(NULL as int) as GLAccountCategoryID
	,CAST(t.account as varchar(255)) as GLAccountDescription
	,CAST(rg.GLAccountTypeID as varchar(100)) as GLAccountType
	,CAST(NULL as varchar(100)) as GLAccountLocation
	,CAST(t.Practice as varchar(100)) as GLAccountPractice
	,CAST(mc.FixedClass as varchar(100)) as GLAccountProvider
	,CAST(mc.FixedClass as varchar(100)) as GLAccountReportingProvider
	,CAST(NULL as varchar(255)) as GLAccountCategory
	,CAST('Profit and Loss' as varchar(100)) as GLAccountReportType
	
	/* Pull Level sorts directly from MapGL mapping */
	,CAST(CONCAT(RIGHT(CONCAT('00',rg.GLAccountReportGroupLevel1Sort),2),'_',rg.GLAccountReportGroupLevel1) as varchar(100)) as GLAccountReportGroupLevel1
	,CAST(CONCAT(RIGHT(CONCAT('00',rg.GLAccountReportGroupLevel2Sort),2),'_',rg.GLAccountReportGroupLevel2) as varchar(100)) as GLAccountReportGroupLevel2
	,CAST(CONCAT(RIGHT(CONCAT('00',rg.GLAccountReportGroupLevel3Sort),2),'_',rg.GLAccountReportGroupLevel3) as varchar(100)) as GLAccountReportGroupLevel3
	
	,CAST(concat('0~',t.Practice) as varchar(100)) as PracticeID
	,CAST(
	    CASE 
	        WHEN t.account_type LIKE '%Income%' THEN 'Credit'
	        WHEN t.account_type LIKE '%Expense%' THEN 'Debit'
			WHEN t.account = 'ACCOUNTS RECEIVABLE-TPG LAB' THEN 'Credit'
	    END 
	as varchar(50)) as GLAccountBalanceType
	,CAST(NULL as varchar(100)) as GLAccountPostingType
	,rg.GLAccountIsAllocated
	,CAST(1 as smallint) as GLAccountIsActive
	,GETDATE() as GLAccountUpdatedDatetime
	
FROM [HPIDW].[stg].[THPTransactions] t
	LEFT JOIN map.GLAccountReportGroups rg ON rg.GLAccountDescriptionID = t.account
	INNER JOIN map.vTHPClass mc	ON mc.[class] = t.[class] AND mc.Practice = t.Practice
where 1=1
		AND (
        t.account_type LIKE '%Income%' 
        OR t.account_type LIKE '%Expense%' 
        OR t.account = 'ACCOUNTS RECEIVABLE-TPG LAB' -- FIX: Adding this to include other income
    )
	AND t.account <> 'OTHER INCOME - NONTAX HTH INSUR'
group by
	 t.Practice
	,t.account
	,t.account_type
	--,t.Class
	,mc.FixedClass
	,rg.GLAccountTypeID
	,rg.GLAccountReportGroupLevel1Sort
	,rg.GLAccountReportGroupLevel1
	,rg.GLAccountReportGroupLevel2Sort
	,rg.GLAccountReportGroupLevel2
	,rg.GLAccountReportGroupLevel3Sort
	,rg.GLAccountReportGroupLevel3
	,rg.GLAccountIsAllocated
	
--GO
