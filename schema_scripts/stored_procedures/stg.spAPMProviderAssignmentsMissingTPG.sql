-- =============================================
-- Author:		Ryan Tisserand
-- Create date: 10/21/2022
-- Description:	Not used, just to show missing APM values from TPG file
-- =============================================
CREATE PROCEDURE stg.spAPMProviderAssignmentsMissingTPG
AS
BEGIN
SET NOCOUNT ON;
declare @ProviderAssignments table(ProviderAbbreviation varchar(50),AssignmentType varchar(50),WorksFor varchar(50), Split varchar(50))
insert into @ProviderAssignments select 'AAG','Aux','EKK',''
insert into @ProviderAssignments select 'ACC','Primary','ACC',''
insert into @ProviderAssignments select 'AEM','Aux','JCB',''
insert into @ProviderAssignments select 'AEY','Aux','EKK',''
insert into @ProviderAssignments select 'AHC','Primary','AHC',''
insert into @ProviderAssignments select 'AKM','Primary','AKM',''
insert into @ProviderAssignments select 'ALB','Aux','NRW',''
insert into @ProviderAssignments select 'ALK','Aux','JCB',''
insert into @ProviderAssignments select 'ALR','Aux','NRW',''
insert into @ProviderAssignments select 'AMG','Aux','JCB',''
insert into @ProviderAssignments select 'AMK','Aux','DKJ',''
insert into @ProviderAssignments select 'AMW','Aux','ADB',''
insert into @ProviderAssignments select 'ATA','Aux','NRW',''
insert into @ProviderAssignments select 'AVA','Aux','','Y'
insert into @ProviderAssignments select 'BAB','Aux','NRW',''
insert into @ProviderAssignments select 'BEB','Primary','BEB',''
insert into @ProviderAssignments select 'BEC','Aux','JCB',''
insert into @ProviderAssignments select 'BJM','Primary','BJM',''
insert into @ProviderAssignments select 'BLN','Primary','BLN',''
insert into @ProviderAssignments select 'BRB','Primary','BRB',''
insert into @ProviderAssignments select 'CCG','Primary','CCG',''
insert into @ProviderAssignments select 'CEM','Aux','MEM',''
insert into @ProviderAssignments select 'CEW','Aux','DRD',''
insert into @ProviderAssignments select 'CJS','Aux','JCB',''
insert into @ProviderAssignments select 'CLC','Aux','EKK',''
insert into @ProviderAssignments select 'CLJ','Aux','CSH',''
insert into @ProviderAssignments select 'CLS','Aux','JCB',''
insert into @ProviderAssignments select 'CMF','Aux','','Y'
insert into @ProviderAssignments select 'CMM','Aux','NRW',''
insert into @ProviderAssignments select 'CRH','Aux','RDI',''
insert into @ProviderAssignments select 'CSH','Primary','CSH',''
insert into @ProviderAssignments select 'CTJ','Aux','JCB',''
insert into @ProviderAssignments select 'DCH','Primary','DCH',''
insert into @ProviderAssignments select 'DDL','Aux','MSO',''
insert into @ProviderAssignments select 'DDR','Primary','DDR',''
insert into @ProviderAssignments select 'DEA','Primary','DEA',''
insert into @ProviderAssignments select 'DKJ','Primary','DKJ',''
insert into @ProviderAssignments select 'DMW','Aux','JCB',''
insert into @ProviderAssignments select 'DNR','Primary','DNR',''
insert into @ProviderAssignments select 'DRB','Primary','DRB',''
insert into @ProviderAssignments select 'DRD','Primary','DRD',''
insert into @ProviderAssignments select 'DSB','Primary','DSB',''
insert into @ProviderAssignments select 'DWJ','Primary','DWJ',''
insert into @ProviderAssignments select 'EAM','Aux','EKK',''
insert into @ProviderAssignments select 'ECB','Aux','',''
insert into @ProviderAssignments select 'EEC','Primary','EEC',''
insert into @ProviderAssignments select 'EEM','Aux','NRW',''
insert into @ProviderAssignments select 'EKK','Primary','EKK',''
insert into @ProviderAssignments select 'GDC','Primary','GDC',''
insert into @ProviderAssignments select 'GDR','Aux','DDR',''
insert into @ProviderAssignments select 'GJZ','Primary','GJZ',''
insert into @ProviderAssignments select 'GPD','Primary','GPD',''
insert into @ProviderAssignments select 'GPK','Primary','GPK',''
insert into @ProviderAssignments select 'HDM','Primary','HDM',''
insert into @ProviderAssignments select 'HLH','Aux','JCB',''
insert into @ProviderAssignments select 'HLK','Aux','PDM',''
insert into @ProviderAssignments select 'HRH','Aux','MOW',''
insert into @ProviderAssignments select 'HSL','Primary','HSL',''
insert into @ProviderAssignments select 'JAK','Primary','JAK',''
insert into @ProviderAssignments select 'JAS','Aux','JCB',''
insert into @ProviderAssignments select 'JCB','Primary','JCB',''
insert into @ProviderAssignments select 'JCJ','Primary','JCJ',''
insert into @ProviderAssignments select 'JCR','Aux','LDH',''
insert into @ProviderAssignments select 'JCW','Aux','MHW',''
insert into @ProviderAssignments select 'JDT','Aux','AHC',''
insert into @ProviderAssignments select 'JEB','Primary','JEB',''
insert into @ProviderAssignments select 'JEM','Aux','JEM',''
insert into @ProviderAssignments select 'JHC','Primary','JHC',''
insert into @ProviderAssignments select 'JKV','Aux','JCB',''
insert into @ProviderAssignments select 'JLD','Aux','MEM',''
insert into @ProviderAssignments select 'JLM','Primary','JLM',''
insert into @ProviderAssignments select 'JLR','Aux','TAK',''
insert into @ProviderAssignments select 'JLW','Primary','',''
insert into @ProviderAssignments select 'JMA','Aux','JCB',''
insert into @ProviderAssignments select 'JMB','Aux','SCS',''
insert into @ProviderAssignments select 'JML','Aux','MHW',''
insert into @ProviderAssignments select 'JMP','Aux','RSU',''
insert into @ProviderAssignments select 'JNC','Aux','MEM',''
insert into @ProviderAssignments select 'JNK','Aux','NRW',''
insert into @ProviderAssignments select 'JRR','Aux','JCB',''
insert into @ProviderAssignments select 'JTM','Aux','JTM',''
insert into @ProviderAssignments select 'KCM','Aux','MSO',''
insert into @ProviderAssignments select 'KDB','Aux','MHW',''
insert into @ProviderAssignments select 'KEC','Aux','',''
insert into @ProviderAssignments select 'KKS','Aux','KKS',''
insert into @ProviderAssignments select 'KMC','Aux','EKK',''
insert into @ProviderAssignments select 'KMD','Aux','JCB',''
insert into @ProviderAssignments select 'KMO','Aux','PBJ',''
insert into @ProviderAssignments select 'KSR','Aux','JCB',''
insert into @ProviderAssignments select 'LAK','Primary','LAK',''
insert into @ProviderAssignments select 'LDH','Primary','LDH',''
insert into @ProviderAssignments select 'LDP','Aux','DEA',''
insert into @ProviderAssignments select 'LFS','Aux','JCB',''
insert into @ProviderAssignments select 'LLK','Primary','LLK',''
insert into @ProviderAssignments select 'LND','Aux','RSU',''
insert into @ProviderAssignments select 'MAH','Primary','MAH',''
insert into @ProviderAssignments select 'MBJ','Primary','MBJ',''
insert into @ProviderAssignments select 'MCD','Aux','MHW',''
insert into @ProviderAssignments select 'MCL','Primary','MCL',''
insert into @ProviderAssignments select 'MDJ','Aux','AHC',''
insert into @ProviderAssignments select 'MDV','Primary','MDV',''
insert into @ProviderAssignments select 'MEM','Primary','MEM',''
insert into @ProviderAssignments select 'MGC','Aux','JCB',''
insert into @ProviderAssignments select 'MHW','Primary','MHW',''
insert into @ProviderAssignments select 'MIG','Aux','RSU',''
insert into @ProviderAssignments select 'MJC','Primary','MJC',''
insert into @ProviderAssignments select 'MJP','Aux','AHC',''
insert into @ProviderAssignments select 'MKJ','Aux','JCB',''
insert into @ProviderAssignments select 'MLC','Aux','DRD',''
insert into @ProviderAssignments select 'MLM','Aux','JCB',''
insert into @ProviderAssignments select 'MLS','Aux','','Y'
insert into @ProviderAssignments select 'MMT','Aux','','Y'
insert into @ProviderAssignments select 'MOW','Primary','MOW',''
insert into @ProviderAssignments select 'MRM','Aux','EKK',''
insert into @ProviderAssignments select 'MSO','Primary','MSO',''
insert into @ProviderAssignments select 'MSW','Aux','RLN',''
insert into @ProviderAssignments select 'NRW','Primary','NRW',''
insert into @ProviderAssignments select 'PBJ','Primary','PBJ',''
insert into @ProviderAssignments select 'PDL','Aux','EKK',''
insert into @ProviderAssignments select 'PDM','Primary','PDM',''
insert into @ProviderAssignments select 'PLH','Aux','NRW',''
insert into @ProviderAssignments select 'PLR','Aux','NRW',''
insert into @ProviderAssignments select 'RAM','Primary','RAM',''
insert into @ProviderAssignments select 'RAP','Aux','PBJ',''
insert into @ProviderAssignments select 'RBR','Aux','RCD',''
insert into @ProviderAssignments select 'RCD','Primary','RCD',''
insert into @ProviderAssignments select 'RDB','Primary','RDB',''
insert into @ProviderAssignments select 'RDI','Primary','RDI',''
insert into @ProviderAssignments select 'RED','Primary','',''
insert into @ProviderAssignments select 'RES','Aux','','Y'
insert into @ProviderAssignments select 'RFH','Primary','RFH',''
insert into @ProviderAssignments select 'RLN','Primary','RLN',''
insert into @ProviderAssignments select 'RMH','Primary','RMH',''
insert into @ProviderAssignments select 'RSG','Primary','RSG',''
insert into @ProviderAssignments select 'RSU','Primary','RSU',''
insert into @ProviderAssignments select 'RVM','Aux','JCB',''
insert into @ProviderAssignments select 'SAK','Aux','JCB',''
insert into @ProviderAssignments select 'SBC','Primary','SBC',''
insert into @ProviderAssignments select 'SCS','Primary','SCS',''
insert into @ProviderAssignments select 'SDB','Primary','SDB',''
insert into @ProviderAssignments select 'SDC','Primary','SDC',''
insert into @ProviderAssignments select 'SDN','Primary','SDN',''
insert into @ProviderAssignments select 'SEC','Aux','BRB',''
insert into @ProviderAssignments select 'SEE','Aux','JHC',''
insert into @ProviderAssignments select 'SEP','Aux','MOW',''
insert into @ProviderAssignments select 'SJH','Primary','SJH',''
insert into @ProviderAssignments select 'SKA','Aux','JCB',''
insert into @ProviderAssignments select 'SLC','Aux','NRW',''
insert into @ProviderAssignments select 'SLF','Primary','SLF',''
insert into @ProviderAssignments select 'SLJ','Aux','CCG',''
insert into @ProviderAssignments select 'SLL','Aux','JCB',''
insert into @ProviderAssignments select 'SRE','Aux','DNR',''
insert into @ProviderAssignments select 'SWM','Primary','SWM',''
insert into @ProviderAssignments select 'TAK','Primary','TAK',''
insert into @ProviderAssignments select 'TAL','Aux','JLW',''
insert into @ProviderAssignments select 'TCC','Primary','TCC',''
insert into @ProviderAssignments select 'TCM','Aux','BEB',''
insert into @ProviderAssignments select 'TDR','Primary','TDR',''
insert into @ProviderAssignments select 'TLM','Aux','DEA',''
insert into @ProviderAssignments select 'TMM','Primary','TMM',''
insert into @ProviderAssignments select 'TRL','Aux','JCB',''
insert into @ProviderAssignments select 'TSB','Primary','TSB',''
insert into @ProviderAssignments select 'VJD','Aux','VJD',''
insert into @ProviderAssignments select 'VLZ','Aux','SLF',''
insert into @ProviderAssignments select 'VTF','Aux','AHC',''
insert into @ProviderAssignments select 'VTT','Aux','MHW',''
insert into @ProviderAssignments select 'WAH','Primary','WAH',''
insert into @ProviderAssignments select 'WSB','Primary','WSB',''
insert into @ProviderAssignments select 'MWP','Aux','SLF',''
insert into @ProviderAssignments select 'WTM','Aux','HSL',''
insert into @ProviderAssignments select 'JRD','Aux','PBJ',''
insert into @ProviderAssignments select 'CAH','Primary','CAH',''
insert into @ProviderAssignments select 'SKH','Primary','SKH',''
insert into @ProviderAssignments select 'RJG','Aux','DDR',''
insert into @ProviderAssignments select 'KCS','Aux','BRB',''
insert into @ProviderAssignments select 'LMG','Aux','DDR',''
insert into @ProviderAssignments select 'INF','Aux','LDH',''
insert into @ProviderAssignments select 'ALG','Aux','DNR',''
insert into @ProviderAssignments select 'BJB','Primary','BJB',''
insert into @ProviderAssignments select 'LKB','Aux','','Y'
insert into @ProviderAssignments select 'SJL','Primary','SJL',''
insert into @ProviderAssignments select 'LJB','Aux','DRD',''
insert into @ProviderAssignments select 'TDT','Primary','TDT',''
insert into @ProviderAssignments select 'HLW','Aux','JCB',''
insert into @ProviderAssignments select 'BDP','Aux','JCB',''
insert into @ProviderAssignments select 'TAT','Aux','JCB',''
insert into @ProviderAssignments select 'EAW','Aux','JCB',''
insert into @ProviderAssignments select 'RRB','Aux','JCB',''
insert into @ProviderAssignments select 'GMM','Primary','GMM',''
insert into @ProviderAssignments select 'LSD','Aux','PBJ',''
insert into @ProviderAssignments select 'CAD','Primary','CAD',''
insert into @ProviderAssignments select 'JLC','Primary','JLC',''
insert into @ProviderAssignments select 'BJC','Aux','NRW',''
insert into @ProviderAssignments select 'NET','Aux','','Y'
insert into @ProviderAssignments select 'SMH','Aux','MBJ',''
insert into @ProviderAssignments select 'MSG','Aux','ACC',''
insert into @ProviderAssignments select 'MSB','Aux','DDR',''
insert into @ProviderAssignments select 'JPN','Primary','JPN',''
insert into @ProviderAssignments select 'ADB','Primary','ADB',''
insert into @ProviderAssignments select 'RNH','Aux','DDR',''
insert into @ProviderAssignments select 'SRB','Aux','LDH',''
insert into @ProviderAssignments select 'DMM','Aux','TDT',''
insert into @ProviderAssignments select 'KAC','Aux','JCB',''
insert into @ProviderAssignments select 'CAS','Primary','CAS',''
insert into @ProviderAssignments select 'AMB','Aux','CAS',''
insert into @ProviderAssignments select 'JER','Aux','GPK',''
insert into @ProviderAssignments select 'MEC','Primary','MEC',''
insert into @ProviderAssignments select 'AAT','Aux','JCB',''
insert into @ProviderAssignments select 'ADO','Aux','LDH',''
insert into @ProviderAssignments select 'HAG','Primary','HAG',''
insert into @ProviderAssignments select 'MMC','Aux','AKM',''
insert into @ProviderAssignments select 'AJG','Aux','MEM',''
insert into @ProviderAssignments select 'KGA','Aux','JPN',''
insert into @ProviderAssignments select 'KLL','Aux','GMM',''
insert into @ProviderAssignments select 'DCB','Aux','DDR',''
insert into @ProviderAssignments select 'CMS','Primary','CMS',''
insert into @ProviderAssignments select 'HCR','Aux','LDH',''
insert into @ProviderAssignments select 'PAK','Primary','PAK',''
insert into @ProviderAssignments select 'ANT','Primary','ANT',''
insert into @ProviderAssignments select 'AMM','Aux','MEC',''
insert into @ProviderAssignments select 'JAM','Primary','JAM',''
insert into @ProviderAssignments select 'PTD','Aux','CMS',''
insert into @ProviderAssignments select 'CEP','Aux','PDM',''
insert into @ProviderAssignments select 'LRL','Primary','LRL',''
insert into @ProviderAssignments select 'MSH','Aux','ACC',''
insert into @ProviderAssignments select 'CHB','Aux','NRW',''
insert into @ProviderAssignments select 'RJS','Aux','BRB',''
insert into @ProviderAssignments select 'LCS','Primary','LCS',''
insert into @ProviderAssignments select 'JDH','Aux','LCS',''
insert into @ProviderAssignments select 'ART','Aux','LDH',''
insert into @ProviderAssignments select 'JCG','Aux','LDH',''
insert into @ProviderAssignments select 'PRL','Aux','HSL',''
insert into @ProviderAssignments select 'SCHS','Primary','SCHS',''
insert into @ProviderAssignments select 'BNM','Aux','JCB',''
insert into @ProviderAssignments select 'JDM','Aux','TAK',''
insert into @ProviderAssignments select 'RGS','Primary','RGS',''
insert into @ProviderAssignments select 'NBN','Primary','NBN',''
insert into @ProviderAssignments select 'JKY','Aux','JCB',''
insert into @ProviderAssignments select 'KRG','Aux','TDT',''
insert into @ProviderAssignments select 'SJM','Aux','CMS',''
insert into @ProviderAssignments select 'ARR','Aux','DRD',''
insert into @ProviderAssignments select 'MCC','Aux','JCB',''
insert into @ProviderAssignments select 'AAP','Aux','PAK',''
insert into @ProviderAssignments select 'CGW','Primary','CGW',''
insert into @ProviderAssignments select 'MES','Aux','RLN',''
insert into @ProviderAssignments select 'TJR','Aux','LCS',''

select 
	pa.*,
	p.*
from @ProviderAssignments pa
left join dim.Providers p on pa.ProviderAbbreviation = p.ProviderAbbreviation
where p.ProviderID is null

END
GO
