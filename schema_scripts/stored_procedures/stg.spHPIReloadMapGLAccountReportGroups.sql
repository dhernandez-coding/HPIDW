CREATE PROCEDURE [stg].[spHPIReloadMapGLAccountReportGroups] as 


DECLARE @AccountCategories  TABLE 
(AccountDescriptionID varchar(10)
,AccountTypeID varchar(10)
,AccountLocationID varchar(100)
,AccountPracticeID varchar(100)
,AccountProviderID varchar(100)
,AccountSubCategory varchar(100)
, AccountCategory varchar(100)
, AccountCategoryRollup varchar(100))

  INSERT INTO @AccountCategories SELECT '4010','59',NULL,NULL,NULL,'Total Professional Services', 'Allergy Collections', 'Total Professional Services'

/*
INSERT INTO @AccountCategories  select '5030',NULL,NULL,NULL,NULL,'Bank Charges','Bank Charges','Administrative Expense'
INSERT INTO @AccountCategories  select '5060',NULL,NULL,NULL,NULL,'Contract Labor Expense','Contract Labor Expense','Labor Expense'
INSERT INTO @AccountCategories  select '5520',NULL,NULL,NULL,NULL,'Temporary Staffing Expense','Contract Labor Expense','Labor Expense'
INSERT INTO @AccountCategories  select '5090',NULL,NULL,NULL,NULL,'Depreciation Expense','Depreciation Expense','Other Operating Expense'
INSERT INTO @AccountCategories  select '5100',NULL,NULL,NULL,NULL,'Dues & Membership Expense','Dues & Membership Expense','Administrative Expense'
INSERT INTO @AccountCategories  select '5120',NULL,NULL,NULL,NULL,'Gain/Loss on Sale of Asset','Gain/Loss on Sale of Asset','Other Operating Expense'
INSERT INTO @AccountCategories  select '5160',NULL,NULL,NULL,NULL,'Insurance - Dental - Owners','Insurance - Dental','Labor Expense'
INSERT INTO @AccountCategories  select '5170',NULL,NULL,NULL,NULL,'Insurance - Health - Owners','Insurance - Health','Labor Expense'
INSERT INTO @AccountCategories  select '5200',NULL,NULL,NULL,NULL,'Insurance - Malpractice','Insurance - Malpractice','Labor Expense'
INSERT INTO @AccountCategories  select '5230',NULL,NULL,NULL,NULL,'Interest Expense','Interest Expense','Other Operating Expense'
INSERT INTO @AccountCategories  select '5050',NULL,NULL,NULL,NULL,'Computer Expense','IT Expense','Administrative Expense'
INSERT INTO @AccountCategories  select '5510',NULL,NULL,NULL,NULL,'Telephone Expense','IT Expense','Administrative Expense'
INSERT INTO @AccountCategories  select '5515',NULL,NULL,NULL,NULL,'Telecommunication/Data Lines','IT Expense','Administrative Expense'
INSERT INTO @AccountCategories  select '5240',NULL,NULL,NULL,NULL,'Lab Expense','Lab Expense','Supply Expense'
INSERT INTO @AccountCategories  select '5372',NULL,NULL,NULL,NULL,'Other Expense Alloc LAB','Lab Expense','Supply Expense'
INSERT INTO @AccountCategories  select '5250',NULL,NULL,NULL,NULL,'Legal & Professional Expense','Legal & Professional Expense','Administrative Expense'
INSERT INTO @AccountCategories  select '5260',NULL,NULL,NULL,NULL,'Management Fee Expense','Management Fee','Administrative Expense'
INSERT INTO @AccountCategories  select '5270',NULL,NULL,NULL,NULL,'Marketing Expense','Marketing Expense','Administrative Expense'
INSERT INTO @AccountCategories  select '5280',NULL,NULL,NULL,NULL,'Meals & Entertainment','Meals & Entertainment','Administrative Expense'
INSERT INTO @AccountCategories  select '5290',NULL,NULL,NULL,NULL,'Meals & Entertainment On Site','Meals & Entertainment','Administrative Expense'
INSERT INTO @AccountCategories  select '5300',NULL,NULL,NULL,NULL,'Medical Supplies','Medical Supplies','Supply Expense'
INSERT INTO @AccountCategories  select '5310',NULL,NULL,NULL,NULL,'Medical Supplies - X-Ray','Medical Supplies','Supply Expense'
INSERT INTO @AccountCategories  select '5307',NULL,NULL,NULL,NULL,'Medical Supplies - Vaccines','Medical Supplies','Supply Expense'
INSERT INTO @AccountCategories  select '5305',NULL,NULL,NULL,NULL,'Medical Supplies - POC Test','Medical Supplies','Supply Expense'
INSERT INTO @AccountCategories  select '5373',NULL,NULL,NULL,NULL,'Other Expense Alloc XRAY','Medical Supplies','Supply Expense'
INSERT INTO @AccountCategories  select '5350',NULL,NULL,NULL,NULL,'Office Expense- Equip Rental/Lease','Office Expenses','Administrative Expense'
INSERT INTO @AccountCategories  select '5340',NULL,NULL,NULL,NULL,'Office Expense','Office Expenses','Administrative Expense'
INSERT INTO @AccountCategories  select '5355',NULL,NULL,NULL,NULL,'Office Expenses - Computer','Office Expenses','Administrative Expense'
INSERT INTO @AccountCategories  select '5345',NULL,NULL,NULL,NULL,'Office Expense-Fast Remits','Office Expenses','Administrative Expense'
INSERT INTO @AccountCategories  select '5360',NULL,NULL,NULL,NULL,'Office Expenses - Magazine Subsc','Office Expenses','Administrative Expense'
INSERT INTO @AccountCategories  select '5180',NULL,NULL,NULL,NULL,'Insurance - Health - Employees','Other Benefits','Labor Expense'
INSERT INTO @AccountCategories  select '5420',NULL,NULL,NULL,NULL,'Payroll Taxes','Other Benefits','Labor Expense'
INSERT INTO @AccountCategories  select '5430',NULL,NULL,NULL,NULL,'Pension Plan Cont - Employees','Other Benefits','Labor Expense'
INSERT INTO @AccountCategories  select '5225',NULL,NULL,NULL,NULL,'Insurance - Other','Other Benefits','Labor Expense'
INSERT INTO @AccountCategories  select '5150',NULL,NULL,NULL,NULL,'Insurance - Disability','Other Benefits','Labor Expense'
INSERT INTO @AccountCategories  select '5220',NULL,NULL,NULL,NULL,'Insurance - Workers Compensation','Other Benefits','Labor Expense'
INSERT INTO @AccountCategories  select '5210',NULL,NULL,NULL,NULL,'Insurance - Property & Liability','Other Benefits','Labor Expense'
INSERT INTO @AccountCategories  select '5425',NULL,NULL,NULL,NULL,'Pension Plan Cont - Owners','Other Benefits','Labor Expense'
INSERT INTO @AccountCategories  select '5190',NULL,NULL,NULL,NULL,'Insurance - Life','Other Benefits','Labor Expense'
INSERT INTO @AccountCategories  select '5530',NULL,NULL,NULL,NULL,'Transcription Expense','Other Expense','Administrative Expense'
INSERT INTO @AccountCategories  select '5020',NULL,NULL,NULL,NULL,'Auto Expense','Other Expense','Administrative Expense'
INSERT INTO @AccountCategories  select '5440',NULL,NULL,NULL,NULL,'Postage Expense','Other Expense','Administrative Expense'
INSERT INTO @AccountCategories  select '5445',NULL,NULL,NULL,NULL,'Reimbursable Expense','Other Expense','Administrative Expense'
        
INSERT INTO @AccountCategories  select '5140',NULL,NULL,NULL,NULL,'Human Resources Expense','Other Expense','Administrative Expense'
INSERT INTO @AccountCategories  select '5130',NULL,NULL,NULL,NULL,'Gift Expense','Other Expense','Administrative Expense'
INSERT INTO @AccountCategories  select '5550',NULL,NULL,NULL,NULL,'Uniforms & Cleaning Expense','Other Expense','Administrative Expense'
INSERT INTO @AccountCategories  select '5005',NULL,NULL,NULL,NULL,'Accounting','Other Expense','Administrative Expense'
INSERT INTO @AccountCategories  select '5010',NULL,NULL,NULL,NULL,'Advertising Expense','Other Expense','Administrative Expense'
INSERT INTO @AccountCategories  select '5070',NULL,NULL,NULL,NULL,'Contributions Expense','Other Expense','Administrative Expense'
INSERT INTO @AccountCategories  select '5110',NULL,NULL,NULL,NULL,'Education Expense','Other Expense','Administrative Expense'
INSERT INTO @AccountCategories  select '5040',NULL,NULL,NULL,NULL,'Collection Expense','Other Expense','Administrative Expense'
INSERT INTO @AccountCategories  select '5470',NULL,NULL,NULL,NULL,'Seminar Expense','Other Expense','Administrative Expense'
INSERT INTO @AccountCategories  select '5370',NULL,NULL,NULL,NULL,'Other Expense Allocation','Other Expense','Administrative Expense'
INSERT INTO @AccountCategories  select '5371',NULL,NULL,NULL,NULL,'Other Expense Allocation Bone Density','Other Expense','Administrative Expense'
INSERT INTO @AccountCategories  select '5232',NULL,NULL,NULL,NULL,'Invoice Clearing','Other Expense','Administrative Expense'

INSERT INTO @AccountCategories  select '5380',NULL,NULL,NULL,NULL,'Payroll - PA/NP Overhead Allocation','Payroll','Labor Expense'
INSERT INTO @AccountCategories  select '5390',NULL,NULL,NULL,NULL,'Payroll - Regular','Payroll','Labor Expense'
INSERT INTO @AccountCategories  select '5400',NULL,NULL,NULL,NULL,'Payroll - Overtime','Payroll','Labor Expense'
INSERT INTO @AccountCategories  select '5410',NULL,NULL,NULL,NULL,'Payroll - Bonus','Payroll','Labor Expense'
INSERT INTO @AccountCategories  select '5450',NULL,NULL,NULL,NULL,'Rent Expense','Rent Expense','Rent Expense'
INSERT INTO @AccountCategories  select '5460',NULL,NULL,NULL,NULL,'Repairs & Maintenance Expense','Repairs & Maintenance Expense','Administrative Expense'
INSERT INTO @AccountCategories  select '5505',NULL,NULL,NULL,NULL,'Taxes - Personal Property','Taxes - Other','Other Operating Expense'
INSERT INTO @AccountCategories  select '5500',NULL,NULL,NULL,NULL,'Taxes - Other','Taxes - Other','Other Operating Expense'
INSERT INTO @AccountCategories  select '5540',NULL,NULL,NULL,NULL,'Travel Expense','Travel','Administrative Expense'
INSERT INTO @AccountCategories  select '5320',NULL,NULL,NULL,NULL,'Mileage Expense','Travel','Administrative Expense'
INSERT INTO @AccountCategories  select '5330',NULL,NULL,NULL,NULL,'Miscellaneous Expense ','Miscellaneous Expense','Administrative Expense'

INSERT INTO @AccountCategories  select '5560',NULL,NULL,NULL,NULL,'Utilities Expense','Utilities Expense','Administrative Expense'

INSERT INTO @AccountCategories  select '4010','00',NULL,NULL,NULL,'Medical Service Income-Misys - Default', 'Collected Revenue', 'Total Professional Services'
INSERT INTO @AccountCategories  select '4010','01',NULL,NULL,NULL,'Medical Service Income-Misys - Direct', 'Collected Revenue', 'Total Professional Services'
INSERT INTO @AccountCategories  select '4010','02',NULL,NULL,NULL,'Medical Service Income-Misys - Split', 'Collected Revenue', 'Total Professional Services'
INSERT INTO @AccountCategories  select '4010','11',NULL,NULL,NULL,'Medical Service Income-Misys - PA', 'Collected Revenue', 'Total Professional Services'
INSERT INTO @AccountCategories  select '4010','12',NULL,NULL,NULL,'Medical Service Income-Misys - ARNP', 'Collected Revenue', 'Total Professional Services'
INSERT INTO @AccountCategories  select '4010','13',NULL,NULL,NULL,'Medical Service Income-Misys - LCSW', 'Collected Revenue', 'Total Professional Services'
INSERT INTO @AccountCategories  select '4010','21',NULL,NULL,NULL,'Medical Service Income-Misys - Associate', 'Collected Revenue', 'Total Professional Services'
INSERT INTO @AccountCategories  select '4010','31',NULL,NULL,NULL,'Medical Service Income-Misys - DME', 'DME Collections', 'Total Professional Services'
INSERT INTO @AccountCategories  select '4010','34',NULL,NULL,NULL,'Medical Service Income-Misys - Ultrasound', 'Ultrasound Collections', 'Total Professional Services'
INSERT INTO @AccountCategories  select '4010','37',NULL,NULL,NULL,'Medical Service Income-Misys - Migraine', 'Migraine Collections', 'Total Professional Services'
INSERT INTO @AccountCategories  select '4010','51',NULL,NULL,NULL,'Medical Service Income-Misys - Lab', 'Lab Collections', 'Total Professional Services'
INSERT INTO @AccountCategories  select '4010','41',NULL,NULL,NULL,'Medical Service Income-Misys - X-ray', 'X-Ray Collections', 'Total Professional Services'
INSERT INTO @AccountCategories  select '4010','52',NULL,NULL,NULL,'Medical Service Income-Misys - Bone Density', 'Bone Density Collections', 'Total Professional Services'
INSERT INTO @AccountCategories  select '4010','53',NULL,NULL,NULL,'Medical Service Income-Misys - Ortho Tech', 'Collected Revenue', 'Total Professional Services'
INSERT INTO @AccountCategories  select '4010','54',NULL,NULL,NULL,'Medical Service Income-Misys - Infusion', 'Collected Revenue', 'Total Professional Services'
INSERT INTO @AccountCategories  select '4010','55',NULL,NULL,NULL,'Medical Service Income-Misys - Smartbeat', 'Collected Revenue', 'Total Professional Services'
INSERT INTO @AccountCategories  select '4010','56',NULL,NULL,NULL,'Medical Service Income-Misys - Max Pulse', 'Collected Revenue', 'Total Professional Services'
INSERT INTO @AccountCategories  select '4010','61',NULL,NULL,NULL,'Medical Service Income-Misys - PI', 'PI Collections', 'Total Professional Services'
INSERT INTO @AccountCategories  select '4010','99',NULL,NULL,NULL,'Medical Service Income-Misys - Admin', 'Collected Revenue', 'Total Professional Services'


INSERT INTO @AccountCategories  select '4012',NULL,NULL,NULL,NULL,'Capitation Income', 'Capitation Income', 'Capitation Income'
INSERT INTO @AccountCategories  select '4015',NULL,NULL,NULL,NULL,'DHS Allocation', 'Collected Revenue', 'Total Professional Services'
INSERT INTO @AccountCategories  select '4025',NULL,NULL,NULL,NULL,'Interest Income', 'Interest Income', 'Interest Income'
INSERT INTO @AccountCategories  select '4030',NULL,NULL,NULL,NULL,'Other Income - Direct', 'Other Income', 'Other Income'

INSERT INTO @AccountCategories  select '4035',NULL,NULL,NULL,NULL,'Other Income - Allocation', 'Other Income - Allocation', 'Other Income - Allocation'
INSERT INTO @AccountCategories  select '4036',NULL,NULL,NULL,NULL,'Other Income - Stimulus', 'Other Income - Stimulus', 'Other Income - Stimulus'
INSERT INTO @AccountCategories  select '4037',NULL,NULL,NULL,NULL,'Other Income - Research', 'Other Income - Research', 'Other Income - Research'

INSERT INTO @AccountCategories  select '4040',NULL,NULL,NULL,NULL,'Investment Income-Default-Admin', 'Investment Income-Default-Admin', 'Investment Income-Default-Admin'
INSERT INTO @AccountCategories  select '4045',NULL,NULL,NULL,NULL,'Capital Gain - ST', 'Capital Gain - ST', 'Capital Gain - ST'
INSERT INTO @AccountCategories  select '4050',NULL,NULL,NULL,NULL,'Capital Gain - LT', 'Capital Gain - LT', 'Capital Gain - LT'        

INSERT INTO @AccountCategories  select '4060',NULL,NULL,NULL,NULL,'Income Guarantee Forgiven', 'Income Guarantee Forgiven', 'Income Guarantee Forgiven'  
INSERT INTO @AccountCategories  select '4065',NULL,NULL,NULL,NULL,'Loan Forgiveness - CAH', 'Loan Forgiveness - CAH', 'Loan Forgiveness - CAH'  
*/
--INSERT INTO @AccountCategories  select '5308',NULL,NULL,NULL,NULL,'DME Expense', 'DME Expense', 'Supply Expense'  


                                                                                                            
--TRUNCATE TABLE map.GLAccountReportGroups
INSERT INTO map.GLAccountReportGroups
SELECT 
	a.AccountDescriptionID as GLAccountDescriptionID
	 ,a.AccountTypeID AS GLAccountTypeID
	 ,a.AccountLocationID as GLAccountLocationID
	 ,a.AccountPracticeID as GLAccountPracticeID
	 ,a.AccountProviderID as GLAccountProviderID
    ,a.AccountCategoryRollup as GLAccountReportGroupLevel1
	,a.AccountCategory as GLAccountReportGroupLevel2
	,a.AccountSubCategory as GLAccountReportGroupLevel3
	,NULL as GLAccountReportGroupLevel1Sort
	,NULL as GLAccountReportGroupLevel2Sort
	,NULL as GLAccountReportGroupLevel3Sort
	,1 as GLAccountReportGroupIsActive 
	,getdate() as GLAccountReportGroupUpdatedDatetime
	,0 as GLAccountIsAllocated
  FROM @AccountCategories a

UPDATE map.GLAccountReportGroups SET GLAccountReportGroupLevel1Sort = 1, GLAccountReportGroupLevel2Sort = 2 WHERE GLAccountReportGroupLevel2 = 'Contract Labor Expense'
UPDATE map.GLAccountReportGroups SET GLAccountReportGroupLevel1Sort = 1, GLAccountReportGroupLevel2Sort = 4 WHERE GLAccountReportGroupLevel2 = 'Insurance - Dental'
UPDATE map.GLAccountReportGroups SET GLAccountReportGroupLevel1Sort = 1, GLAccountReportGroupLevel2Sort = 3 WHERE GLAccountReportGroupLevel2 = 'Insurance - Health'
UPDATE map.GLAccountReportGroups SET GLAccountReportGroupLevel1Sort = 1, GLAccountReportGroupLevel2Sort = 5 WHERE GLAccountReportGroupLevel2 = 'Insurance - Malpractice'
UPDATE map.GLAccountReportGroups SET GLAccountReportGroupLevel1Sort = 1, GLAccountReportGroupLevel2Sort = 6 WHERE GLAccountReportGroupLevel2 = 'Other Benefits'
UPDATE map.GLAccountReportGroups SET GLAccountReportGroupLevel1Sort = 1, GLAccountReportGroupLevel2Sort = 1 WHERE GLAccountReportGroupLevel2 = 'Payroll'
UPDATE map.GLAccountReportGroups SET GLAccountReportGroupLevel1Sort = 2, GLAccountReportGroupLevel2Sort = 8 WHERE GLAccountReportGroupLevel2 = 'Lab Expense'
UPDATE map.GLAccountReportGroups SET GLAccountReportGroupLevel1Sort = 2, GLAccountReportGroupLevel2Sort = 7 WHERE GLAccountReportGroupLevel2 = 'Medical Supplies'
UPDATE map.GLAccountReportGroups SET GLAccountReportGroupLevel1Sort = 2, GLAccountReportGroupLevel2Sort = 7 WHERE GLAccountReportGroupLevel2 = 'DME Expense'
UPDATE map.GLAccountReportGroups SET GLAccountReportGroupLevel1Sort = 3, GLAccountReportGroupLevel2Sort = 9 WHERE GLAccountReportGroupLevel2 = 'Rent Expense'
UPDATE map.GLAccountReportGroups SET GLAccountReportGroupLevel1Sort = 4, GLAccountReportGroupLevel2Sort = 15 WHERE GLAccountReportGroupLevel2 = 'Bank Charges'
UPDATE map.GLAccountReportGroups SET GLAccountReportGroupLevel1Sort = 4, GLAccountReportGroupLevel2Sort = 20 WHERE GLAccountReportGroupLevel2 = 'Dues & Membership Expense'
UPDATE map.GLAccountReportGroups SET GLAccountReportGroupLevel1Sort = 4, GLAccountReportGroupLevel2Sort = 13 WHERE GLAccountReportGroupLevel2 = 'IT Expense'
UPDATE map.GLAccountReportGroups SET GLAccountReportGroupLevel1Sort = 4, GLAccountReportGroupLevel2Sort = 11 WHERE GLAccountReportGroupLevel2 = 'Legal & Professional Expense'
UPDATE map.GLAccountReportGroups SET GLAccountReportGroupLevel1Sort = 12, GLAccountReportGroupLevel2Sort = NULL WHERE GLAccountReportGroupLevel2 = 'Capital Gain - LT'
UPDATE map.GLAccountReportGroups SET GLAccountReportGroupLevel1Sort = 13, GLAccountReportGroupLevel2Sort = NULL WHERE GLAccountReportGroupLevel2 = 'Capital Gain - ST'
UPDATE map.GLAccountReportGroups SET GLAccountReportGroupLevel1Sort = 11, GLAccountReportGroupLevel2Sort = 16 WHERE GLAccountReportGroupLevel2 = 'Capitation Income'
UPDATE map.GLAccountReportGroups SET GLAccountReportGroupLevel1Sort = 10, GLAccountReportGroupLevel2Sort = 15 WHERE GLAccountReportGroupLevel2 = 'Income Guarantee Forgiven'
UPDATE map.GLAccountReportGroups SET GLAccountReportGroupLevel1Sort = 8, GLAccountReportGroupLevel2Sort = 13 WHERE GLAccountReportGroupLevel2 = 'Interest Income'
UPDATE map.GLAccountReportGroups SET GLAccountReportGroupLevel1Sort = 9, GLAccountReportGroupLevel2Sort = 14 WHERE GLAccountReportGroupLevel2 = 'Investment Income-Default-Admin'
UPDATE map.GLAccountReportGroups SET GLAccountReportGroupLevel1Sort = 4, GLAccountReportGroupLevel2Sort = 10 WHERE GLAccountReportGroupLevel2 = 'Management Fee'
UPDATE map.GLAccountReportGroups SET GLAccountReportGroupLevel1Sort = 4, GLAccountReportGroupLevel2Sort = 16 WHERE GLAccountReportGroupLevel2 = 'Marketing Expense'
UPDATE map.GLAccountReportGroups SET GLAccountReportGroupLevel1Sort = 4, GLAccountReportGroupLevel2Sort = 19 WHERE GLAccountReportGroupLevel2 = 'Meals & Entertainment'
UPDATE map.GLAccountReportGroups SET GLAccountReportGroupLevel1Sort = 4, GLAccountReportGroupLevel2Sort = 22 WHERE GLAccountReportGroupLevel2 = 'Miscellaneous Expense'
UPDATE map.GLAccountReportGroups SET GLAccountReportGroupLevel1Sort = 4, GLAccountReportGroupLevel2Sort = 12 WHERE GLAccountReportGroupLevel2 = 'Office Expenses'
UPDATE map.GLAccountReportGroups SET GLAccountReportGroupLevel1Sort = 4, GLAccountReportGroupLevel2Sort = 14 WHERE GLAccountReportGroupLevel2 = 'Other Expense'
UPDATE map.GLAccountReportGroups SET GLAccountReportGroupLevel1Sort = 6, GLAccountReportGroupLevel2Sort = 12 WHERE GLAccountReportGroupLevel2 = 'Loan Forgiveness - CAH'
UPDATE map.GLAccountReportGroups SET GLAccountReportGroupLevel1Sort = 5, GLAccountReportGroupLevel2Sort = 11 WHERE GLAccountReportGroupLevel2 = 'Other Income'
UPDATE map.GLAccountReportGroups SET GLAccountReportGroupLevel1Sort = 4, GLAccountReportGroupLevel2Sort = 10 WHERE GLAccountReportGroupLevel2 = 'Other Income - Allocation'
UPDATE map.GLAccountReportGroups SET GLAccountReportGroupLevel1Sort = 2, GLAccountReportGroupLevel2Sort = 8 WHERE GLAccountReportGroupLevel2 = 'Other Income - Research'
UPDATE map.GLAccountReportGroups SET GLAccountReportGroupLevel1Sort = 3, GLAccountReportGroupLevel2Sort = 9 WHERE GLAccountReportGroupLevel2 = 'Other Income - Stimulus'
UPDATE map.GLAccountReportGroups SET GLAccountReportGroupLevel1Sort = 4, GLAccountReportGroupLevel2Sort = 17 WHERE GLAccountReportGroupLevel2 = 'Repairs & Maintenance Expense'
UPDATE map.GLAccountReportGroups SET GLAccountReportGroupLevel1Sort = 4, GLAccountReportGroupLevel2Sort = 18 WHERE GLAccountReportGroupLevel2 = 'Travel'
UPDATE map.GLAccountReportGroups SET GLAccountReportGroupLevel1Sort = 4, GLAccountReportGroupLevel2Sort = 21 WHERE GLAccountReportGroupLevel2 = 'Utilities Expense'
UPDATE map.GLAccountReportGroups SET GLAccountReportGroupLevel1Sort = 5, GLAccountReportGroupLevel2Sort = 25 WHERE GLAccountReportGroupLevel2 = 'Depreciation Expense'
UPDATE map.GLAccountReportGroups SET GLAccountReportGroupLevel1Sort = 5, GLAccountReportGroupLevel2Sort = 26 WHERE GLAccountReportGroupLevel2 = 'Gain/Loss on Sale of Asset'
UPDATE map.GLAccountReportGroups SET GLAccountReportGroupLevel1Sort = 5, GLAccountReportGroupLevel2Sort = 24 WHERE GLAccountReportGroupLevel2 = 'Interest Expense'
UPDATE map.GLAccountReportGroups SET GLAccountReportGroupLevel1Sort = 5, GLAccountReportGroupLevel2Sort = 23 WHERE GLAccountReportGroupLevel2 = 'Taxes - Other'
UPDATE map.GLAccountReportGroups SET GLAccountReportGroupLevel1Sort = 1, GLAccountReportGroupLevel2Sort = 2 WHERE GLAccountReportGroupLevel2 = 'Bone Density Collections'
UPDATE map.GLAccountReportGroups SET GLAccountReportGroupLevel1Sort = 1, GLAccountReportGroupLevel2Sort = 1 WHERE GLAccountReportGroupLevel2 = 'Collected Revenue'
UPDATE map.GLAccountReportGroups SET GLAccountReportGroupLevel1Sort = 1, GLAccountReportGroupLevel2Sort = 4 WHERE GLAccountReportGroupLevel2 = 'DME Collections'
UPDATE map.GLAccountReportGroups SET GLAccountReportGroupLevel1Sort = 1, GLAccountReportGroupLevel2Sort = 3 WHERE GLAccountReportGroupLevel2 = 'Lab Collections'
UPDATE map.GLAccountReportGroups SET GLAccountReportGroupLevel1Sort = 1, GLAccountReportGroupLevel2Sort = 5 WHERE GLAccountReportGroupLevel2 = 'Migraine Collections'
UPDATE map.GLAccountReportGroups SET GLAccountReportGroupLevel1Sort = 1, GLAccountReportGroupLevel2Sort = 6 WHERE GLAccountReportGroupLevel2 = 'Ultrasound Collections'
UPDATE map.GLAccountReportGroups SET GLAccountReportGroupLevel1Sort = 1, GLAccountReportGroupLevel2Sort = 7 WHERE GLAccountReportGroupLevel2 = 'X-Ray Collections'


/*Adding in Expense Allocation Flag*/
 UPDATE map.GLAccountReportGroups SET GLAccountIsAllocated = 1 WHERE GLAccountDescriptionID in (
  '5030'
  ,'5040'
  ,'5050'
  ,'5270'
  ,'5300'
  ,'5305'
  ,'5307'
  ,'5310'
  ,'5355'
  ,'5440'
  ,'5450'
  ,'5505'
  ,'5510'
  ,'5308')

 UPDATE map.GLAccountReportGroups SET GLAccountIsAllocated = 0 WHERE GLAccountDescriptionID not in (
  '5030'
  ,'5040'
  ,'5050'
  ,'5270'
  ,'5300'
  ,'5305'
  ,'5307'
  ,'5310'
  ,'5355'
  ,'5440'
  ,'5450'
  ,'5505'
  ,'5510'
  ,'5308')


  UPDATE map.GLAccountReportGroups SET GLAccountReportGroupLevel3Sort = 2 WHERE GLAccountDescriptionID = '5308'


  
  UPDATE map.GLAccountReportGroups SET GLAccountTypeID = '01' WHERE GLAccountDescriptionID = '5240' AND GLAccountTypeID is null


  INSERT INTO map.GLAccountReportGroups SELECT '5240','03',NULL,NULL,NULL,'Ancillary Service Expenses','Lab Expense','Lab Expense',2,8,8,1,GETDATE(),0
  INSERT INTO map.GLAccountReportGroups SELECT '5240','21',NULL,NULL,NULL,'Ancillary Service Expenses','Lab Expense','Lab Expense',2,8,8,1,GETDATE(),0
  INSERT INTO map.GLAccountReportGroups SELECT '5240','51',NULL,NULL,NULL,'Ancillary Service Expenses','Lab Expense','Lab Expense',2,8,8,1,GETDATE(),0
  
  INSERT INTO map.GLAccountReportGroups SELECT '5240','59',NULL,NULL,NULL,'Ancillary Service Expenses','Allergy Expense','Allergy Expense',2,8,8,1,GETDATE(),0
    UPDATE map.GLAccountReportGroups 
	SET GLAccountReportGroupLevel1 = 'Administrative Expense',
    GLAccountReportGroupLevel1Sort = 2,
    GLAccountReportGroupLevel2 = 'Professional Services Expense',
    GLAccountReportGroupLevel2Sort = 1,
    GLAccountReportGroupLevel3 = 'Administrative Expense' ,
    GLAccountIsAllocated = 1
	WHERE GLAccountDescriptionID = '5240'
	AND GLAccountTypeID= '01'

	UPDATE map.GLAccountReportGroups 
	SET GLAccountReportGroupLevel1 = 'Lab Expense',
    GLAccountReportGroupLevel1Sort = 2,
    GLAccountReportGroupLevel2 = 'Lab Expense',
    GLAccountReportGroupLevel2Sort = 1,
    GLAccountReportGroupLevel3 = 'Ancillary Service Expenses' ,
    GLAccountIsAllocated = 1
	WHERE GLAccountDescriptionID = '5240'
	AND GLAccountTypeID in ('51','03','21')

	UPDATE map.GLAccountReportGroups 
	SET GLAccountReportGroupLevel1 = 'Administrative Expense',
    GLAccountReportGroupLevel1Sort = 2,
    GLAccountReportGroupLevel2 = 'Professional Services Expense',
    GLAccountReportGroupLevel2Sort = 1,
    GLAccountReportGroupLevel3 = 'Ancillary Service Expenses' ,
    GLAccountIsAllocated = 1
	WHERE GLAccountDescriptionID = '5240'
	AND GLAccountTypeID in ('59')


	/*4/7/26 - Chris Cross - Added PI Collections mapping back to report group level 2 per Lindsay for type 61*/
	UPDATE map.GLAccountReportGroups SET GLAccountReportGroupLevel2 = 'PI Collections', GLAccountReportGroupLevel2Sort = 6, GLAccountReportGroupUpdatedDatetime = GETDATE() WHERE GLAccountDescriptionID = '4010' and GLAccountTypeID = '61'

	/*4/16/2026 - Chris Cross - Updated 5372 and 5310 expense accounts back to Lab and X-Ray Expense groupings per Nick*/

	UPDATE map.GLAccountReportGroups 
	SET GLAccountReportGroupLevel1 = 'Lab Expense',
    GLAccountReportGroupLevel1Sort = 2,
    GLAccountReportGroupLevel2 = 'Lab Expense',
    GLAccountReportGroupLevel2Sort = 8,
    GLAccountReportGroupLevel3 = 'Ancillary Service Expenses' ,
    GLAccountIsAllocated = 8
	--select * from map.GLAccountReportGroups
	WHERE GLAccountDescriptionID = '5372'

	
	UPDATE map.GLAccountReportGroups 
	SET GLAccountReportGroupLevel1 = 'X-ray Expense',
    GLAccountReportGroupLevel1Sort = 2,
    GLAccountReportGroupLevel2 = 'X-ray Expense', --Medical Supplies
    GLAccountReportGroupLevel2Sort = 7,
    GLAccountReportGroupLevel3 = 'Ancillary Service Expenses' , --Medical Supplies - X-Ray
    GLAccountIsAllocated = 8
	--select * from map.GLAccountReportGroups
	WHERE GLAccountDescriptionID = '5310'

	UPDATE map.GLAccountReportGroups SET GLAccountReportGroupLevel1 = 'Administrative Expense', GLAccountReportGroupLevel1Sort = 4, GLAccountReportGroupLevel3 = 'Ancillary Service Expenses', GLAccountReportGroupLevel3Sort = 2 WHERE GLAccountDescriptionID = 'ALLERGY EXPENSE'
	UPDATE map.GLAccountReportGroups SET GLAccountReportGroupLevel1 = 'Administrative Expense', GLAccountReportGroupLevel1Sort = 4, GLAccountReportGroupLevel3 = 'Ancillary Service Expenses', GLAccountReportGroupLevel3Sort = 2 WHERE GLAccountDescriptionID = 'ALLOCATED X-RAY EXPENSE'
	UPDATE map.GLAccountReportGroups SET GLAccountReportGroupLevel1 = 'Lab Expense', GLAccountReportGroupLevel1Sort = 2, GLAccountReportGroupLevel3 = 'Ancillary Service Expenses', GLAccountReportGroupLevel3Sort = 2 WHERE GLAccountDescriptionID = 'LAB DIRECTOR FEE'
	UPDATE map.GLAccountReportGroups SET GLAccountReportGroupLevel1 = 'Supply Expense', GLAccountReportGroupLevel1Sort = 2, GLAccountReportGroupLevel3 = 'Ancillary Service Expenses', GLAccountReportGroupLevel3Sort = 2 WHERE GLAccountDescriptionID = 'LAB SUPPLIES'
	UPDATE map.GLAccountReportGroups SET GLAccountReportGroupLevel1 = 'Administrative Expense', GLAccountReportGroupLevel1Sort = 4, GLAccountReportGroupLevel3 = 'Ancillary Service Expenses', GLAccountReportGroupLevel3Sort = 2 WHERE GLAccountDescriptionID = 'MAMMOGRAPHY EXPENSE'
	UPDATE map.GLAccountReportGroups SET GLAccountReportGroupLevel1 = 'Administrative Expense', GLAccountReportGroupLevel1Sort = 4, GLAccountReportGroupLevel3 = 'Ancillary Service Expenses', GLAccountReportGroupLevel3Sort = 2 WHERE GLAccountDescriptionID = 'X-RAY EXPENSE'
	UPDATE map.GLAccountReportGroups SET GLAccountReportGroupLevel1 = 'Administrative Expense', GLAccountReportGroupLevel1Sort = 4, GLAccountReportGroupLevel3 = 'Ancillary Service Expenses', GLAccountReportGroupLevel3Sort = 2 WHERE GLAccountDescriptionID = 'LAB EXPENSES ALLOCATED OUT'
	UPDATE map.GLAccountReportGroups SET GLAccountReportGroupLevel1 = 'Administrative Expense', GLAccountReportGroupLevel1Sort = 4, GLAccountReportGroupLevel3 = 'Ancillary Service Expenses', GLAccountReportGroupLevel3Sort = 2 WHERE GLAccountDescriptionID = 'X-RAY EXPENSES ALLOCATED OUT'  
	UPDATE  map.GLAccountReportGroups SET GLAccountReportGroupLevel1Sort=4 WHERE GLAccountReportGroupLevel1 = 'Administrative Expense' AND GLAccountReportGroupLevel1Sort=2

	
	UPDATE map.GLAccountReportGroups SET GLAccountReportGroupLevel3 = GLAccountReportGroupLevel1, GLAccountReportGroupLevel3Sort = NULL WHERE  LEFT(GLAccountDescriptionID,1) = '5' AND GLAccountReportGroupLevel3 <> 'Ancillary Service Expenses'
	UPDATE map.GLAccountReportGroups SET GLAccountReportGroupLevel3 = GLAccountReportGroupLevel1, GLAccountReportGroupLevel3Sort = NULL WHERE  LEFT(GLAccountDescriptionID,1) = '4' AND GLAccountReportGroupLevel3 <> GLAccountReportGroupLevel1
	
--THP MAPPING 00

	-- 1. Map Administrative Expenses
--INSERT INTO map.GLAccountReportGroups (GLAccountDescriptionID, GLAccountReportGroupLevel1, GLAccountReportGroupLevel1Sort, GLAccountReportGroupLevel2, GLAccountReportGroupLevel2Sort, GLAccountReportGroupLevel3, GLAccountReportGroupLevel3Sort, GLAccountReportGroupIsActive, GLAccountReportGroupUpdatedDatetime, GLAccountIsAllocated)
--VALUES ('ALLOCATED CVFC OFFICE EXPENSE', 'Administrative Expense', 4, 'Miscellaneous Expense', 1, 'Administrative Expense', 1, 1, GETDATE(), 1);

--INSERT INTO map.GLAccountReportGroups (GLAccountDescriptionID, GLAccountReportGroupLevel1, GLAccountReportGroupLevel1Sort, GLAccountReportGroupLevel2, GLAccountReportGroupLevel2Sort, GLAccountReportGroupLevel3, GLAccountReportGroupLevel3Sort, GLAccountReportGroupIsActive, GLAccountReportGroupUpdatedDatetime, GLAccountIsAllocated)
--VALUES ('ALLOCATED THP OFFICE EXPENSE', 'Administrative Expense', 4, 'Miscellaneous Expense', 1, 'Administrative Expense', 1, 1, GETDATE(), 1);

--INSERT INTO map.GLAccountReportGroups (GLAccountDescriptionID, GLAccountReportGroupLevel1, GLAccountReportGroupLevel1Sort, GLAccountReportGroupLevel2, GLAccountReportGroupLevel2Sort, GLAccountReportGroupLevel3, GLAccountReportGroupLevel3Sort, GLAccountReportGroupIsActive, GLAccountReportGroupUpdatedDatetime, GLAccountIsAllocated)
--VALUES ('AUTO MILEAGE', 'Administrative Expense', 4, 'Miscellaneous Expense', 1, 'Administrative Expense', 1, 1, GETDATE(), 0);

--INSERT INTO map.GLAccountReportGroups (GLAccountDescriptionID, GLAccountReportGroupLevel1, GLAccountReportGroupLevel1Sort, GLAccountReportGroupLevel2, GLAccountReportGroupLevel2Sort, GLAccountReportGroupLevel3, GLAccountReportGroupLevel3Sort, GLAccountReportGroupIsActive, GLAccountReportGroupUpdatedDatetime, GLAccountIsAllocated)
--VALUES ('BUSINESS GIFTS', 'Administrative Expense', 4, 'Miscellaneous Expense', 1, 'Administrative Expense', 1, 1, GETDATE(), 0);

--INSERT INTO map.GLAccountReportGroups (GLAccountDescriptionID, GLAccountReportGroupLevel1, GLAccountReportGroupLevel1Sort, GLAccountReportGroupLevel2, GLAccountReportGroupLevel2Sort, GLAccountReportGroupLevel3, GLAccountReportGroupLevel3Sort, GLAccountReportGroupIsActive, GLAccountReportGroupUpdatedDatetime, GLAccountIsAllocated)
--VALUES ('NOTE PYBL - CASH OUT', 'Administrative Expense', 4, 'Miscellaneous Expense', 1, 'Administrative Expense', 1, 1, GETDATE(), 0);

--INSERT INTO map.GLAccountReportGroups (GLAccountDescriptionID, GLAccountReportGroupLevel1, GLAccountReportGroupLevel1Sort, GLAccountReportGroupLevel2, GLAccountReportGroupLevel2Sort, GLAccountReportGroupLevel3, GLAccountReportGroupLevel3Sort, GLAccountReportGroupIsActive, GLAccountReportGroupUpdatedDatetime, GLAccountIsAllocated)
--VALUES ('OFFICE EXPENSE - CVFC', 'Administrative Expense', 4, 'Miscellaneous Expense', 1, 'Administrative Expense', 1, 1, GETDATE(), 0);

--INSERT INTO map.GLAccountReportGroups (GLAccountDescriptionID, GLAccountReportGroupLevel1, GLAccountReportGroupLevel1Sort, GLAccountReportGroupLevel2, GLAccountReportGroupLevel2Sort, GLAccountReportGroupLevel3, GLAccountReportGroupLevel3Sort, GLAccountReportGroupIsActive, GLAccountReportGroupUpdatedDatetime, GLAccountIsAllocated)
--VALUES ('UTILITIES', 'Administrative Expense', 4, 'Miscellaneous Expense', 1, 'Administrative Expense', 1, 1, GETDATE(), 0);

--INSERT INTO map.GLAccountReportGroups (GLAccountDescriptionID, GLAccountReportGroupLevel1, GLAccountReportGroupLevel1Sort, GLAccountReportGroupLevel2, GLAccountReportGroupLevel2Sort, GLAccountReportGroupLevel3, GLAccountReportGroupLevel3Sort, GLAccountReportGroupIsActive, GLAccountReportGroupUpdatedDatetime, GLAccountIsAllocated)
--VALUES ('OTHER INCOME - VOIDED CHECKS', 'Other Income', 5, 'Other Income', 1, 'Other Income', 1, 1, GETDATE(), 0);

--	UPDATE map.GLAccountReportGroups
--SET 
--    GLAccountReportGroupLevel1 = 'Other Income',
--    GLAccountReportGroupLevel1Sort = 5,
--    GLAccountReportGroupLevel2 = 'Other Income',
--    GLAccountReportGroupLevel2Sort = 1,
--    GLAccountReportGroupLevel3 = 'Other Income',
--    GLAccountReportGroupLevel3Sort = 1
--WHERE GLAccountDescriptionID IN (
--    'OTHER INCOME - VOIDED CHECKS'
--);


--UPDATE map.GLAccountReportGroups
--SET 
--    GLAccountReportGroupLevel1 = 'Other Operating Expense',
--    GLAccountReportGroupLevel1Sort = 5,
--    GLAccountReportGroupLevel2 = 'Other Operating Expense',
--    GLAccountReportGroupLevel2Sort = 1,
--    GLAccountReportGroupLevel3 = 'Other Operating Expense',
--    GLAccountReportGroupLevel3Sort = 1
--WHERE GLAccountDescriptionID = 'NOTE PYBL - CASH OUT


--	UPDATE SELECT * from map.GLAccountReportGroups
--SET GLAccountReportGroupLevel3 = 'Other Income',
--    GLAccountReportGroupLevel3Sort = 11
--WHERE GLAccountDescriptionID = 'OTHER INCOME - NONTAX HTH INSUR';


--UPDATE map.GLAccountReportGroups
--SET GLAccountReportGroupLevel3 = GLAccountReportGroupLevel1,
--    GLAccountReportGroupLevel3Sort = GLAccountReportGroupLevel1Sort
--WHERE GLAccountReportGroupLevel3 = 'Other Income' 
--  AND GLAccountReportGroupLevel1 != 'Other Income';

--INSERT INTO map.GLAccountReportGroups (
--    GLAccountDescriptionID, 
--    GLAccountReportGroupLevel1, 
--    GLAccountReportGroupLevel1Sort,
--    GLAccountReportGroupLevel2,
--    GLAccountReportGroupLevel2Sort,
--    GLAccountReportGroupLevel3,
--    GLAccountReportGroupLevel3Sort,
--    GLAccountReportGroupIsActive
--)
--VALUES (
--    'ACCOUNTS RECEIVABLE-TPG LAB', 
--    'Other Income', 5, 
--    'Other Income', 11, 
--    'Other Income', 11, 
--    1
--);

	--SELECT * from map.GLAccountReportGroups WHERE  LEFT(GLAccountDescriptionID,1) = '4' AND GLAccountReportGroupLevel3 <> GLAccountReportGroupLevel1
	
	--SELECT * from map.GLAccountReportGroups where LEFT(GLAccountDescriptionID,1) = '5' AND GLAccountReportGroupLevel3 <> 'Ancillary Service Expenses'

;
GO
