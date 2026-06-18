CREATE PROCEDURE [stg].[spGPReloadDimProvidersFull] as
	--select * from tpg.dbo.GL40200 s4 where s4.sgmtnumb = 4
	--select * from tpg.dbo.GL40200 s4 where s4.sgmtnumb = 5

/*
delete from dim.Providers where ProviderDataSourceID = 10

INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~AAP',10,'AAP','AAP','ALLYSON A PINKLEY PAC',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~ACC',10,'ACC','ACC','ASHLEY C COGAR MD',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~ADB',10,'ADB','ADB','ARTHUR D BEACHAM III DO',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~ADO',10,'ADO','ADO','AMANDA D OBLANDER APRN',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~AEY',10,'AEY','AEY','AEY',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~AHC',10,'AHC','AHC','Dr. Arthur Conley',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~AJG',10,'AJG','AJG','AARON J GILLETTE PAC',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~AKM',10,'AKM','AKM','ANGELA K MORGAN MD',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~ALB',10,'ALB','ALB','AMY L BROOKS APRN',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~ALD',10,'ALD','ALD','ALD',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~ALR',10,'ALR','ALR','ABBEY R KRAHL PAC',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~AMB',10,'AMB','AMB','AMANDA M BARRITT PAC',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~AMM',10,'AMM','AMM','AMBER M MEIWES PAC',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~AMW',10,'AMW','AMW','ANDREA M WRAY PAC',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~ARR',10,'ARR','ARR','APRILL R RIDGEWAY APRN',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~ART',10,'ART','ART','AMANDA R TITUS MD',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~ATA',10,'ATA','ATA','ATA',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~BAB',10,'BAB','BAB','BRETT A BRALY MD',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~BEB',10,'BEB','BEB','BARNEY E BLUE DO',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~BEC',10,'BEC','BEC','BROOKE E CALDWELL APRN',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~BET',10,'BET','BET','BRIAN THATCHER MD',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~BJB',10,'BJB','BJB','BENJAMIN J BARENBERG MD',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~BJC',10,'BJC','BJC','BETHANY J COOK APRN',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~BJM',10,'BJM','BJM','Dr. Barry Mitchell',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~BLN',10,'BLN','BLN','BARRY L NORTHCUTT MD',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~BMD',10,'BMD','BMD','BAILEY M DAUGHERTY APRN',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~CAH',10,'CAH','CAH','CHARLES A HOGAN MD',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~CEB',10,'CEB','CEB','CEB',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~CEM',10,'CEM','CEM','CEM',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~CEW',10,'CEW','CEW','CHRISTINE E WILCOX PAC',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~CMF',10,'CMF','CMF','CHRISTINA M FELARCA PAC',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~CMS',10,'CMS','CMS','CASSIE M SMITH MD',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~CMT',10,'CMT','CMT','CMT',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~CRS',10,'CRS','CRS','CRS',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~DB-JB',10,'DB-JB','DB-JB','DB-JB',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~DCB',10,'DCB','DCB','DUSTIN C BROOKS PAC',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~DCH',10,'DCH','DCH','DARON C HITT MD',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~DDR',10,'DDR','DDR','DARRYL D ROBINSON MD',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~DEA',10,'DEA','DEA','DONALD E ADAMS MD',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~Default',10,'Default','Default','Default',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~DES',10,'DES','DES','DES',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~DKJ',10,'DKJ','DKJ','Dr. David Jayne',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~DMM',10,'DMM','DMM','DANIELLE M MOSS APRN',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~DNR',10,'DNR','DNR','D NEIL ROBERTS MD',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~DRW',10,'DRW','DRW','DRW',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~EEM',10,'EEM','EEM','EEM',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~EKK',10,'EKK','EKK','E KIM KING DO',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~GDR',10,'GDR','GDR','GDR',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~GJZ',10,'GJZ','GJZ','Dr. Gregory Zeiders',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~GMC',10,'GMC','GMC','GMC',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~GMM',10,'GMM','GMM','GERARDO M MYRIN MD',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~GPD',10,'GPD','GPD','Dr. G Paul Digoy',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~GPK',10,'GPK','GPK','GREGORY P KELLEY DO',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~HAG',10,'HAG','HAG','HOLLY A GORACKE MD',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~HCR',10,'HCR','HCR','HEIDI C ROGERS MD',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~HDM',10,'HDM','HDM','Dr. Hal Martin',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~HSL',10,'HSL','HSL','HILLARY S LAWRENCE MD',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~JAK',10,'JAK','JAK','Dr. John Koontz',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~JAM',10,'JAM','JAM','JEFFREY A MOORE MD',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~JBS',10,'JBS','JBS','JBS',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~JCG',10,'JCG','JCG','JOHN C GOETZINGER MD',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~JCJ',10,'JCJ','JCJ','J CALVIN JOHNSON MD',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~JCR',10,'JCR','JCR','JOSEPH C RAWDON CNS',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~JCW',10,'JCW','JCW','JCW',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~JDH',10,'JDH','JDH','JOSEPH D HOSKINS PAC',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~JDM',10,'JDM','JDM','JDM',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~JEB',10,'JEB','JEB','Dr. John Beavers',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~JHC',10,'JHC','JHC','JIMMY H CONWAY JR MD',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~JLD',10,'JLD','JLD','JLD',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~JLK',10,'JLK','JLK','JLK',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~JLM',10,'JLM','JLM','JUDY L MAGNUSSON DO',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~JLR',10,'JLR','JLR','JENNIFER L ROBERTS APRN',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~JLRich',10,'JLRich','JLRich','JLRich',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~JLT',10,'JLT','JLT','JANA L THOMAS APRN',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~JMB',10,'JMB','JMB','JENNIFER M BURNS PAC',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~JMD',10,'JMD','JMD','J.M. DODSON',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~JML',10,'JML','JML','JASON M LEINEN MD',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~JMP',10,'JMP','JMP','JMP',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~JNC',10,'JNC','JNC','JAMES N CLICK PAC',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~JNL',10,'JNL','JNL','JNL',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~JRD',10,'JRD','JRD','JRD',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~JTM',10,'JTM','JTM','J T MCLAUGHLIN PAC',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~JWF',10,'JWF','JWF','JILL W FROST PAC',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~KCM',10,'KCM','KCM','KEVIN C MASON PAC',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~KCS',10,'KCS','KCS','KATRINA C STEWART PAC',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~KDB',10,'KDB','KDB','KDB',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~KLL',10,'KLL','KLL','KLL',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~KMC',10,'KMC','KMC','KEVIN M CHESSMORE PAC',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~KMO',10,'KMO','KMO','KRISTY M OLIVO PAC',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~KRG',10,'KRG','KRG','KENADEY R DAHLENBURG PAC',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~KSR',10,'KSR','KSR','KSR',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~LAG',10,'LAG','LAG','LESLIE A GILLETTE PAC',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~LAK',10,'LAK','LAK','LEE A KIRSCH DO',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~LCS',10,'LCS','LCS','LANCE C SMITH MD',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~LDH',10,'LDH','LDH','LATISHA D HEINLEN MD',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~LDP',10,'LDP','LDP','LAURA D PETRASH PAC',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~LJB',10,'LJB','LJB','LJB',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~LLK',10,'LLK','LLK','LAURA L KILKENNY DO',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~LMG',10,'LMG','LMG','LEE M GERMANY PAC',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~LND',10,'LND','LND','LINDSEY N DASHNER PAC',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~LRL',10,'LRL','LRL','LAURA R LUICK MD',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~LSD',10,'LSD','LSD','LLOYD S DUNKLEBERGER PAC',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~LTC',10,'LTC','LTC','LANEY COMBS',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~MBJ',10,'MBJ','MBJ','M BRANDON JOHNSON MD',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~MCD',10,'MCD','MCD','MCD',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~MDV',10,'MDV','MDV','Dr. Monte Veal',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~MEC',10,'MEC','MEC','MAURICE E CORMAN III MD',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~MEM',10,'MEM','MEM','MAC E MOORE MD',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~MES',10,'MES','MES','MURPHI E SCARBOROUGH PAC',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~MHW',10,'MHW','MHW','MICHAEL H WRIGHT MD',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~MJP',10,'MJP','MJP','MJP',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~MMC',10,'MMC','MMC','MARIAN M CLOPTON PAC',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~MMD',10,'MMD','MMD','Dr. Matthew Diesselhorst',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~MMT',10,'MMT','MMT','MMT',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~MOW',10,'MOW','MOW','Dr. Michael Williams',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~MSB',10,'MSB','MSB','MELANIE S BOGGS APRN',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~MSG',10,'MSG','MSG','MSG',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~MSH',10,'MSH','MSH','MORGAN S HANNI PAC',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~MSO',10,'MSO','MSO','M SEAN OBRIEN DO',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~MSW',10,'MSW','MSW','MADISON S WILLIAMS PAC',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~NBN',10,'NBN','NBN','NGOC B NGUYEN MD',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~NEH',10,'NEH','NEH','NEH',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~NMO',10,'NMO','NMO','NATHANIEL M ODOR MD',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~NRW',10,'NRW','NRW','NOEL R WILLIAMS MD',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~PAK',10,'PAK','PAK','PAUL A KAMMERLOCHER MD',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~PBJ',10,'PBJ','PBJ','PAUL B JACOB DO',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~PL',10,'PL','PL','PL',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~PLH',10,'PLH','PLH','PATRICIA L HALL PAC',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~PLR',10,'PLR','PLR','PLR',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~PTD',10,'PTD','PTD','PHONG T DANG PAC',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~RAP',10,'RAP','RAP','RANDALL A PAPE PAC',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~RBR',10,'RBR','RBR','RBR',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~RCD',10,'RCD','RCD','Dr. Rory Dunham',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~RES',10,'RES','RES','RES',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~RFH',10,'RFH','RFH','ROBERT F HINES MD',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~RGS',10,'RGS','RGS','RAYMOND G STEINMETZ MD',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~RJG',10,'RJG','RJG','RJG',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~RJJ',10,'RJJ','RJJ','RJJ',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~RJS',10,'RJS','RJS','RYNE J SHAFER PAC',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~RLN',10,'RLN','RLN','Ryan L Nelson DO',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~RMH',10,'RMH','RMH','RITA M HANCOCK MD',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~RNH',10,'RNH','RNH','RAINA N HAMLIN APRN',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~RSG',10,'RSG','RSG','Dr. Robert Glade',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~RSU',10,'RSU','RSU','ROBERT S UNSELL MD',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~SBC',10,'SBC','SBC','Dr. Stephen Conner',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~SCS',10,'SCS','SCS','STANLEY SHADID',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~SDC',10,'SDC','SDC','STEVEN D COUPENS MD',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~SEC',10,'SEC','SEC','SHAILYNNE E CLORAN PAC',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~SEE',10,'SEE','SEE','SEE',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~SJM',10,'SJM','SJM','SHELLEY J MCCLURE APRN',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~SLC',10,'SLC','SLC','SHANNAN L CARMOUCHE PAC',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~SMH',10,'SMH','SMH','SARAH M HIGGINBOTHAM APRN',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~SMS',10,'SMS','SMS','Dr. Sheryl Smith',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~SRB',10,'SRB','SRB','SHARLA R BROWN APRN',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~SRE',10,'SRE','SRE','SRE',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~SWM',10,'SWM','SWM','Dr. Stephen Mihalsky',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~TAK',10,'TAK','TAK','TODD A KREHBIEL MD',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~TCC',10,'TCC','TCC','THOMAS C CONIGLIONE MD',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~TCF',10,'TCF','TCF','TAYLOR C FITZPATRICK PAC',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~TDT',10,'TDT','TDT','TREY D THOMASON DO',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~TJR',10,'TJR','TJR','TODD J RAMER APRN',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~TLM',10,'TLM','TLM','TLM',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~VTF',10,'VTF','VTF','VTF',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~VTT',10,'VTT','VTT','V TAMMY THOMAS APRN',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~WSB',10,'WSB','WSB','W STAN BEVERS MD',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~WTM',10,'WTM','WTM','WHITNEY T MASHBURN PAC',1,getdate(),''


/*Create record for second AMB provider*/

INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~AMB2',10,'AMB2','AMB2','AUDRA S BALL',1,getdate(),''


/*2.6.24 Create Record for Labrie*/
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~DDL',10,'DDL','DDL','DEBORAH D LABRIE',1,getdate(),''


--update dim.Providers set ProviderLastName = 'J.M. DODSON' where providerid  = '10~JMD'

/*3.13.2024 Create Record for Jimenez */
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~SUJ',10,'SUJ','SUJ','SUSANA JIMENEZ',1,getdate(),''

/*4.17.2024 Create Record for Mahoney and Jana Sanders */
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~HBM',10,'HBM','HBM','HILARY B MAHONEY',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~JDS',10,'JDS','JDS','JANA SANDERS',1,getdate(),''
 
/*5.13.2024 Create Record for Pfaff */
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~KJP',10,'KJP','KJP','KARLEE J PFAFF',1,getdate(),''

/*5.13.2024 Create Record for Heather Foster */
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~HDF',10,'HDF','HDF','HEATHER D FOSTER',1,getdate(),''

/*5.30.2024 Create record for Michael Stancliff*/
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~MJS',10,'MJS','MJS','MICHAEL J STANCLIFF',1,getdate(),''

/*5.30.2024 Create record for Jillian Yingling*/
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~JRY',10,'JRY','JRY','JILLIAN R YINGLING',1,getdate(),''


/*9.3.2024 Create record for Eric Johnson*/
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~EBJ',10,'EBJ','EBJ','ERIC B JOHNSON',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~NRJ',10,'NRJ','NRJ','NICHOLAS R JOHNSON',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~SJA',10,'SJA','SJA','SHEHAN J ABEYEWARDENE',1,getdate(),''
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~WAS',10,'WAS','WAS','WADE A SCHWERDTFEGER',1,getdate(),''

/*2.13.2025 Create record for Tanja Pittman*/
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~TAP',10,'TAP','TAP','TANJA A. PITTMAN',1,getdate(),''

/*4.14.2025 Create record for Pamela Migliaccio*/
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~PLM',10,'PLM','PLM','PAMELA L. MIGLIACCIO',1,getdate(),''

/*8.12.2025 Create record for Katherine Gilchrist*/
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~KEG',10,'KEG','KEG','KATHERINE E. GILCHRIST',1,getdate(),''

/*8.12.2025 Create record for Pamela Migliaccio*/
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT   '10~NAH',10,'NAH','NAH','NATHAN A. HARRIS',1,getdate(),''

/*9.8.2025 Create record for Erin Olmsted*/
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT '10~EMO',10,'EMO','EMO','ERIN M. OLMSTED',1,getdate(),''

/*9.12.2025 Create record for Rian D. Wilson*/
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT '10~RDW',10,'RDW','RDW','RYAN D. WILSON',1,getdate(),'1922094184'

/*9.12.2025 Create record for Laura B. Buford*/
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT '10~LBB',10,'LBB','LBB','LAURA B. BUFORD',1,getdate(),'1861803058'

/*9.12.2025 Create record for Chelsea M. Rommell*/
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT '10~CMR',10,'CMR','CMR','CHELSEA M. ROMMELL',1,getdate(),'19326292684'

/*9.12.2025 Create record for Charley C. Baldwin*/
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT '10~CCB',10,'CCB','CCB','CHARLEY C. BALDWIN',1,getdate(),'1437830353'

/*10.10.2025 Create record for Sheila Goforth*/
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT '10~SRG',10,'SRG','SRG','SHEILA R. GOFORTH',1,getdate(),'1689626210'

/*01.13.2026 Update record for Jamie Merideth*/
UPDATE dim.Providers SET ProviderNPI = '1306436019' WHERE ProviderID = '10~JDM'

/*03.02.2026 Create record for Taylor Ramos-Gatliff*/
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT '10~TRG',10,'TRG','TRG','TAYLOR RAMOS-GATLIFF',1,getdate(),'1265246904'

/*03.31.2026 Create record for Christopher D. Harris*/
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT '10~CDH',10,'CDH','CDH','CHRISTOPHER D. HARRIS',1,getdate(),'1790275923'

/*03.31.2026 Create record for Ashley A. Martin*/
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT '10~AAM',10,'AAM','AAM','ASHLEY A. MARTIN',1,getdate(),'1710855515'

/*03.31.2026 Create record for Maria Nguyen*/
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT '10~MN',10,'MN','MN','MARIA NGUYEN',1,getdate(),'1115922895'

/*04.30.2026 Create record for Thilly R. Nelson*/
INSERT INTO dim.Providers (ProviderID,ProviderDataSourceID,ProviderSourceID,ProviderAbbreviation, ProviderLastName,ProviderIsActive,ProviderUpdatedDatetime,ProviderNPI) SELECT '10~TRN',10,'TRN','TRN','THILLY R. NELSON',1,getdate(),'1487444766'


select * from dim.vProviders p where p.ProviderFullName like '%thilly%'


*/
GO
