CREATE PROCEDURE [stg].[zDEPRECATED_spHPIReloadDimPracticesFull] as

/*
CREATE TABLE dim.Practices
(PracticeID varchar(100) primary key not null
,PracticeDataSourceID int
,PracticeSourceID varchar(100)
,PracticeName varchar(100)
,PracticeAbbreviation varchar(30)
,PracticeDataSource varchar(30)
,PracticeCompany varchar(30)
,PracticeIsActive bit
,PracticeUpdatedDatetime datetime
)
*/

--TRUNCATE TABLE dim.Practices
/*
insert into dim.Practices SELECT '0~ADB','0','ADB','Dr. A. Doug Beacham','ADB','APM','HPIP',1,getdate()
insert into dim.Practices SELECT '0~AKM','0','AKM','Dr. Angela Morgan','AKM','APM','TPG',1,getdate()
insert into dim.Practices SELECT '0~ANT','0','ANT','Dr. Anton Dreier','ANT','APM','TPG',0,getdate()
insert into dim.Practices SELECT '0~AHC','0','AHC','Dr. Arthur Conley','AHC','APM','TPG',0,getdate()
insert into dim.Practices SELECT '0~ACC','0','ACC','Dr. Ashley Cogar','ACC','APM','TPG',1,getdate()
insert into dim.Practices SELECT '0~BEB','0','BEB','Dr. Barney Blue','BEB','APM','TPG',1,getdate()
insert into dim.Practices SELECT '0~BJM','0','BJM','Dr. Barry Mitchell','BJM','APM','TPG',0,getdate()
insert into dim.Practices SELECT '0~BLN','0','BLN','Dr. Barry Northcutt','BLN','APM','TPG',1,getdate()
insert into dim.Practices SELECT '0~BJB','0','BJB','Dr. Ben Barenberg','BJB','APM','TPG',1,getdate()
insert into dim.Practices SELECT '0~BAB','0','BAB','Dr. Brett Braly','BAB','APM','TPG',1,getdate()
insert into dim.Practices SELECT '0~BET','0','BET','Dr. Brian Thatcher','BET','Epic','TPG',1,getdate()
insert into dim.Practices SELECT '0~CMS','0','CMS','Dr. Cassie Smith','CMS','APM','TPG',1,getdate()
insert into dim.Practices SELECT '0~CAS','0','CAS','Dr. Castel Santana','CAS','APM','TPG',0,getdate()
insert into dim.Practices SELECT '0~CAH','0','CAH','Dr. Charles Hogan','CAH','APM','TPG',1,getdate()
insert into dim.Practices SELECT '0~CCG','0','CCG','Dr. Chesca Craig-Goodell','CCG','APM','CUST',0,getdate()
insert into dim.Practices SELECT '0~CSH','0','CSH','Dr. Christopher Hume','CSH','APM','HPIP',1,getdate()
insert into dim.Practices SELECT '0~CGW','0','CGW','Dr. Clint Wallis','CGW','APM/Epic','HPIP',1,getdate()
insert into dim.Practices SELECT '0~CAD','0','CAD','Dr. Crystal Dockery','CAD','APM','TPG',0,getdate()
insert into dim.Practices SELECT '0~DNR','0','DNR','Dr. D. Neil Roberts','DNR','APM','TPG',0,getdate()
insert into dim.Practices SELECT '0~DRW','0','DRW','Dr. D. Rachelle Wilson','DRW','APM','TPG',1,getdate()
insert into dim.Practices SELECT '0~DCH ','0','DCH ','Dr. Daron Hitt','DCH ','Epic','TPG',1,getdate()
insert into dim.Practices SELECT '0~DWJ','0','DWJ','Dr. Darryl Jackson','DWJ','APM','UNK',0,getdate()
insert into dim.Practices SELECT '0~DDR','0','DDR','Dr. Darryl Robinson','DDR','APM','TPG',1,getdate()
insert into dim.Practices SELECT '0~DKJ','0','DKJ','Dr. David Jayne','DKJ','APM','TPG',0,getdate()
insert into dim.Practices SELECT '0~SDB','0','SDB','Dr. Dean Brown','SDB','APM','CUST',1,getdate()
insert into dim.Practices SELECT '0~DSB','0','DSB','Dr. Deborah Blalock','DSB','APM','TPG',0,getdate()
insert into dim.Practices SELECT '0~DEA','0','DEA','Dr. Donald Adams','DEA','APM','TPG',0,getdate()
insert into dim.Practices SELECT '0~DRB','0','DRB','Dr. Dustin Baker','DRB','APM','CUST',1,getdate()
insert into dim.Practices SELECT '0~EKK','0','EKK','Dr. E. Kim King','EKK','APM','TPG',1,getdate()
insert into dim.Practices SELECT '0~EEC','0','EEC','Dr. Ester Cobb','EEC','APM','TPG',0,getdate()
insert into dim.Practices SELECT '0~GPD','0','GPD','Dr. G Paul Digoy','GPD','APM','TPG',0,getdate()
insert into dim.Practices SELECT '0~GDC','0','GDC','Dr. G. David Casper','GDC','APM','TPG',0,getdate()
insert into dim.Practices SELECT '0~GMM','0','GMM','Dr. Gerardo Myrin','GMM','APM','TPG',0,getdate()
insert into dim.Practices SELECT '0~GPK','0','GPK','Dr. Gregory Kelley','GPK','APM','TPG',1,getdate()
insert into dim.Practices SELECT '0~GJZ','0','GJZ','Dr. Gregory Zeiders','GJZ','APM','TPG',0,getdate()
insert into dim.Practices SELECT '0~HDM','0','HDM','Dr. Hal Martin','HDM','APM','TPG',0,getdate()
insert into dim.Practices SELECT '0~HSL','0','HSL','Dr. Hillary Lawrence','HSL','APM','TPG',1,getdate()
insert into dim.Practices SELECT '0~HAG','0','HAG','Dr. Holly Goracke','HAG','APM','CUST',1,getdate()
insert into dim.Practices SELECT '0~JCJ','0','JCJ','Dr. J. Calvin Johnson','JCJ','APM','HPIP',0,getdate()
insert into dim.Practices SELECT '0~JAM','0','JAM','Dr. Jeff Moore','JAM','APM','TPG',0,getdate()
insert into dim.Practices SELECT '0~JPN','0','JPN','Dr. Jeffrey Nees','JPN','Epic','HPIP',1,getdate()
insert into dim.Practices SELECT '0~JLC','0','JLC','Dr. Jenna Crowder','JLC','APM','TPG',0,getdate()
insert into dim.Practices SELECT '0~JHC','0','JHC','Dr. Jimmy Conway Jr.','JHC','APM','HPIP',0,getdate()
insert into dim.Practices SELECT '0~JEB','0','JEB','Dr. John Beavers','JEB','APM','UNK',0,getdate()
insert into dim.Practices SELECT '0~JCG','0','JCG','Dr. John Goetzinger','JCG','APM','TPG',0,getdate()
insert into dim.Practices SELECT '0~JAK','0','JAK','Dr. John Koontz','JAK','APM','TPG',0,getdate()
insert into dim.Practices SELECT '0~JCB','0','JCB','Dr. Joseph Broome','JCB','APM','CUST',1,getdate()
insert into dim.Practices SELECT '0~JEM','0','JEM','Dr. Josh McWilliams','JEM','APM','UNK',0,getdate()
insert into dim.Practices SELECT '0~JLM','0','JLM','Dr. Judy Magnusson','JLM','APM','TPG',1,getdate()
insert into dim.Practices SELECT '0~KKS','0','KKS','Dr. Karen Swisher','KKS','APM','TPG',0,getdate()
insert into dim.Practices SELECT '0~LCS','0','LCS','Dr. Lance Smith','LCS','APM','TPG',1,getdate()
insert into dim.Practices SELECT '0~LDH','0','LDH','Dr. Latisha Heinlen','LDH','APM','TPG',0,getdate()
insert into dim.Practices SELECT '0~LLK','0','LLK','Dr. Laura Kilkenny','LLK','APM','TPG',1,getdate()
insert into dim.Practices SELECT '0~LRL','0','LRL','Dr. Laura Luick','LRL','APM','TPG',1,getdate()
insert into dim.Practices SELECT '0~LAK','0','LAK','Dr. Lee Kirsch','LAK','APM','TPG',1,getdate()
insert into dim.Practices SELECT '0~MBJ','0','MBJ','Dr. M Brandon Johnson','MBJ','APM','TPG',1,getdate()
insert into dim.Practices SELECT '0~MCL','0','MCL','Dr. M. Carl Limbaugh','MCL','APM','TPG',0,getdate()
insert into dim.Practices SELECT '0~MEM','0','MEM','Dr. Mac Moore','MEM','APM','TPG',1,getdate()
insert into dim.Practices SELECT '0~MMD','0','MMD','Dr. Matthew Diesselhorst','MMD','Epic','TPG',1,getdate()
insert into dim.Practices SELECT '0~MEC','0','MEC','Dr. Maurice Corman','MEC','Epic','TPG',1,getdate()
insert into dim.Practices SELECT '0~MAH','0','MAH','Dr. Megan Hanner','MAH','APM','TPG',0,getdate()
insert into dim.Practices SELECT '0~MJC','0','MJC','Dr. Michael Carl','MJC','APM','TPG',0,getdate()
insert into dim.Practices SELECT '0~MSO','0','MSO','Dr. Michael OBrien','MSO','APM','TPG',1,getdate()
insert into dim.Practices SELECT '0~MOW','0','MOW','Dr. Michael Williams','MOW','APM','TPG',0,getdate()
insert into dim.Practices SELECT '0~MDW','0','MDW','Dr. Michael Winters','MDW','Epic','HPIP',1,getdate()
insert into dim.Practices SELECT '0~MHW','0','MHW','Dr. Michael Wright','MHW','APM','TPG',0,getdate()
insert into dim.Practices SELECT '0~MDV','0','MDV','Dr. Monte Veal','MDV','APM','TPG',0,getdate()
insert into dim.Practices SELECT '0~NMO','0','NMO','Dr. Nathaniel Odor','NMO','APM','TPG',1,getdate()
insert into dim.Practices SELECT '0~NBN','0','NBN','Dr. Ngoc Nguyen','NBN','APM','TPG',1,getdate()
insert into dim.Practices SELECT '0~NRW','0','NRW','Dr. Noel Williams','NRW','APM','TPG',1,getdate()
insert into dim.Practices SELECT '0~PBJ','0','PBJ','Dr. Paul Jacob','PBJ','APM','TPG',1,getdate()
insert into dim.Practices SELECT '0~PAK','0','PAK','Dr. Paul Kammerlocher','PAK','APM','TPG',1,getdate()
insert into dim.Practices SELECT '0~PDM','0','PDM','Dr. Paul Maitino','PDM','APM','CUST',1,getdate()
insert into dim.Practices SELECT '0~RGS','0','RGS','Dr. Raymond Steinmetz','RGS','APM','TPG',1,getdate()
insert into dim.Practices SELECT '0~RDB','0','RDB','Dr. Rick Beller','RDB','APM','UNK',0,getdate()
insert into dim.Practices SELECT '0~RMH','0','RMH','Dr. Rita Hancock','RMH','APM','TPG',1,getdate()
--insert into dim.Practices SELECT '0~RSG','0','RSG','Dr. Robert Glade','RSG','APM','TPG',0,getdate()
insert into dim.Practices SELECT '0~RFH','0','RFH','Dr. Robert Hines','RFH','APM','HPIP',1,getdate()
insert into dim.Practices SELECT '0~RSG','0','RSG','Dr. Robert Spencer','RSG','Epic','TPG',1,getdate()
insert into dim.Practices SELECT '0~RSU','0','RSU','Dr. Robert Unsell','RSU','APM','TPG',1,getdate()
insert into dim.Practices SELECT '0~RAM','0','RAM','Dr. Roger Mueller','RAM','APM','UNK',0,getdate()
insert into dim.Practices SELECT '0~RCD','0','RCD','Dr. Rory Dunham','RCD','APM','TPG',0,getdate()
insert into dim.Practices SELECT '0~RDI','0','RDI','Dr. Russell Ingram','RDI','APM','CUST',1,getdate()
insert into dim.Practices SELECT '0~RLN','0','RLN','Dr. Ryan Nelson','RLN','APM','TPG',1,getdate()
insert into dim.Practices SELECT '0~SKH','0','SKH','Dr. Sam Hong','SKH','APM','HPIP',0,getdate()
insert into dim.Practices SELECT '0~SDN','0','SDN','Dr. Scott Newton','SDN','APM','UNK',0,getdate()
insert into dim.Practices SELECT '0~SMS','0','SMS','Dr. Sheryl Smith','SMS','APM','TPG',1,getdate()
insert into dim.Practices SELECT '0~SLF','0','SLF','Dr. Stacey Foshee','SLF','APM','HPIP',0,getdate()
insert into dim.Practices SELECT '0~SCS','0','SCS','Dr. Stanley Shadid','SCS','Epic','TPG',1,getdate()
insert into dim.Practices SELECT '0~SBC','0','SBC','Dr. Stephen Conner','SBC','APM','TPG',0,getdate()
insert into dim.Practices SELECT '0~SWM','0','SWM','Dr. Stephen Mihalsky','SWM','APM','TPG',0,getdate()
insert into dim.Practices SELECT '0~SDC','0','SDC','Dr. Steven Coupens','SDC','APM','TPG',0,getdate()
insert into dim.Practices SELECT '0~SJL','0','SJL','Dr. Stuart Lisle','SJL','APM','CUST',1,getdate()
insert into dim.Practices SELECT '0~SJH','0','SJH','Dr. Susan Hakel','SJH','APM','TPG',0,getdate()
insert into dim.Practices SELECT '0~TSB','0','TSB','Dr. Thomas Boswell','TSB','APM','TPG',0,getdate()
insert into dim.Practices SELECT '0~TCC','0','TCC','Dr. Thomas Coniglione','TCC','APM','TPG',1,getdate()
insert into dim.Practices SELECT '0~TDR','0','TDR','Dr. Thomas Reeder II','TDR','APM','UNK',0,getdate()
insert into dim.Practices SELECT '0~TMM','0','TMM','Dr. Timothy Moore','TMM','APM','UNK',0,getdate()
insert into dim.Practices SELECT '0~TAK','0','TAK','Dr. Todd Krehbiel','TAK','APM','TPG',1,getdate()
insert into dim.Practices SELECT '0~TDT','0','TDT','Dr. Trey Thomason','TDT','APM','TPG',1,getdate()
insert into dim.Practices SELECT '0~VJD','0','VJD','Dr. Vincent Devlin','VJD','APM','TPG',0,getdate()
insert into dim.Practices SELECT '0~WSB','0','WSB','Dr. W. Stan Bevers','WSB','APM','TPG',1,getdate()
insert into dim.Practices SELECT '0~WAH','0','WAH','Dr. William Herndon','WAH','APM','TPG',0,getdate()
insert into dim.Practices SELECT '0~JTM','0','JTM','J. T. McLaughlin','JTM','APM','TPG',0,getdate()
insert into dim.Practices SELECT '0~JLW','0','JLW','Jeramiah Walker','JLW','APM','TPG',0,getdate()
insert into dim.Practices SELECT '0~GMC','0','GMC','Gilbert Medical Center','GMC','External','TPG',0,getdate()
insert into dim.Practices SELECT '0~NPS','0','NPS','Nevinson P. Sam, D.O.','NPS','EPIC','HPIP',1,0,getdate()
*/

/*
UPDATE dim.Practices SET PracticeIsSameStore = 1 WHERE PracticeID = '0~ACC'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~ADB'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~AHC'
UPDATE dim.Practices SET PracticeIsSameStore = 1 WHERE PracticeID = '0~AKM'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~ANT'
UPDATE dim.Practices SET PracticeIsSameStore = 1 WHERE PracticeID = '0~BAB'
UPDATE dim.Practices SET PracticeIsSameStore = 1 WHERE PracticeID = '0~BEB'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~BET'
UPDATE dim.Practices SET PracticeIsSameStore = 1 WHERE PracticeID = '0~BJB'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~BJM'
UPDATE dim.Practices SET PracticeIsSameStore = 1 WHERE PracticeID = '0~BLN'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~CAD'
UPDATE dim.Practices SET PracticeIsSameStore = 1 WHERE PracticeID = '0~CAH'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~CAS'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~CCG'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~CGW'
UPDATE dim.Practices SET PracticeIsSameStore = 1 WHERE PracticeID = '0~CMS'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~CSH'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~DCH '
UPDATE dim.Practices SET PracticeIsSameStore = 1 WHERE PracticeID = '0~DDR'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~DEA'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~DKJ'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~DNR'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~DRB'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~DRW'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~DSB'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~DWJ'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~EEC'
UPDATE dim.Practices SET PracticeIsSameStore = 1 WHERE PracticeID = '0~EKK'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~GDC'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~GJZ'
UPDATE dim.Practices SET PracticeIsSameStore = 1 WHERE PracticeID = '0~GMC'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~GMM'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~GPD'
UPDATE dim.Practices SET PracticeIsSameStore = 1 WHERE PracticeID = '0~GPK'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~HAG'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~HDM'
UPDATE dim.Practices SET PracticeIsSameStore = 1 WHERE PracticeID = '0~HSL'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~JAK'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~JAM'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~JCB'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~JCG'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~JCJ'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~JEB'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~JEM'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~JHC'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~JLC'
UPDATE dim.Practices SET PracticeIsSameStore = 1 WHERE PracticeID = '0~JLM'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~JLW'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~JPN'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~JTM'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~KKS'
UPDATE dim.Practices SET PracticeIsSameStore = 1 WHERE PracticeID = '0~LAK'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~LCS'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~LDH'
UPDATE dim.Practices SET PracticeIsSameStore = 1 WHERE PracticeID = '0~LLK'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~LRL'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~MAH'
UPDATE dim.Practices SET PracticeIsSameStore = 1 WHERE PracticeID = '0~MBJ'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~MCL'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~MDV'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~MDW'
UPDATE dim.Practices SET PracticeIsSameStore = 1 WHERE PracticeID = '0~MEC'
UPDATE dim.Practices SET PracticeIsSameStore = 1 WHERE PracticeID = '0~MEM'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~MHW'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~MJC'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~MMD'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~MOW'
UPDATE dim.Practices SET PracticeIsSameStore = 1 WHERE PracticeID = '0~MSO'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~NBN'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~NMO'
UPDATE dim.Practices SET PracticeIsSameStore = 1 WHERE PracticeID = '0~NRW'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~PAK'
UPDATE dim.Practices SET PracticeIsSameStore = 1 WHERE PracticeID = '0~PBJ'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~PDM'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~RAM'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~RCD'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~RDB'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~RDI'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~RFH'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~RGS'
UPDATE dim.Practices SET PracticeIsSameStore = 1 WHERE PracticeID = '0~RLN'
UPDATE dim.Practices SET PracticeIsSameStore = 1 WHERE PracticeID = '0~RMH'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~RSG'
UPDATE dim.Practices SET PracticeIsSameStore = 1 WHERE PracticeID = '0~RSU'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~SBC'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~SCS'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~SDB'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~SDC'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~SDN'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~SJH'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~SJL'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~SKH'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~SLF'
UPDATE dim.Practices SET PracticeIsSameStore = 1 WHERE PracticeID = '0~SMS'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~SWM'
UPDATE dim.Practices SET PracticeIsSameStore = 1 WHERE PracticeID = '0~TAK'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~TCC'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~TDR'
UPDATE dim.Practices SET PracticeIsSameStore = 1 WHERE PracticeID = '0~TDT'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~TMM'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~TSB'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~VJD'
UPDATE dim.Practices SET PracticeIsSameStore = 0 WHERE PracticeID = '0~WAH'
UPDATE dim.Practices SET PracticeIsSameStore = 1 WHERE PracticeID = '0~WSB'



/*4.26.24 - Adding GL Practice ID and GL Location mapping */
UPDATE dim.Practices SET PracticeGLLocationID = '28',PracticeGLLocation = 'OSSO Cogar',PracticeGLPracticeID = '50' WHERE PracticeID = '0~ACC                            '
UPDATE dim.Practices SET PracticeGLLocationID = '16',PracticeGLLocation = 'Morgan Clinic',PracticeGLPracticeID = '43' WHERE PracticeID = '0~AKM                            '
UPDATE dim.Practices SET PracticeGLLocationID = '1',PracticeGLLocation = 'OSSO Broadway',PracticeGLPracticeID = '33' WHERE PracticeID = '0~BAB                            '
UPDATE dim.Practices SET PracticeGLLocationID = '11',PracticeGLLocation = 'TPG FP - Western',PracticeGLPracticeID = '19' WHERE PracticeID = '0~BEB                            '
UPDATE dim.Practices SET PracticeGLLocationID = '12',PracticeGLLocation = 'TPG FP - 89th',PracticeGLPracticeID = '71' WHERE PracticeID = '0~BET                            '
UPDATE dim.Practices SET PracticeGLLocationID = '8',PracticeGLLocation = 'OBGYN',PracticeGLPracticeID = '54' WHERE PracticeID = '0~BJB                            '
UPDATE dim.Practices SET PracticeGLLocationID = '1',PracticeGLLocation = 'OSSO Broadway',PracticeGLPracticeID = '18' WHERE PracticeID = '0~BLN                            '
UPDATE dim.Practices SET PracticeGLLocationID = '9',PracticeGLLocation = 'FHCS',PracticeGLPracticeID = '53' WHERE PracticeID = '0~CAH                            '
UPDATE dim.Practices SET PracticeGLLocationID = '3',PracticeGLLocation = 'OSSO Edmond',PracticeGLPracticeID = '60' WHERE PracticeID = '0~CMS                            '
----UPDATE dim.Practices SET PracticeGLLocationID = '13',PracticeGLLocation = 'Gilbert Medical Center',PracticeGLPracticeID = '28' WHERE PracticeID = '0~DB-JB                          '
UPDATE dim.Practices SET PracticeGLLocationID = '4',PracticeGLLocation = 'OSSO Spine and Pain Management',PracticeGLPracticeID = '14' WHERE PracticeID = '0~DDR                            '
----UPDATE dim.Practices SET PracticeGLLocationID = '0',PracticeGLLocation = 'Default',PracticeGLPracticeID = '0' WHERE PracticeID = '0~Default                        '
----UPDATE dim.Practices SET PracticeGLLocationID = '1',PracticeGLLocation = 'OSSO Broadway',PracticeGLPracticeID = '0' WHERE PracticeID = '0~Default                        '
----UPDATE dim.Practices SET PracticeGLLocationID = '5',PracticeGLLocation = 'OSSO Spine Center',PracticeGLPracticeID = '0' WHERE PracticeID = '0~Default                        '
----UPDATE dim.Practices SET PracticeGLLocationID = '15',PracticeGLLocation = 'OCOE',PracticeGLPracticeID = '0' WHERE PracticeID = '0~Default                        '
UPDATE dim.Practices SET PracticeGLLocationID = '20',PracticeGLLocation = 'GYN Yukon',PracticeGLPracticeID = '47' WHERE PracticeID = '0~DRW                            '
UPDATE dim.Practices SET PracticeGLLocationID = '12',PracticeGLLocation = 'TPG FP - 89th',PracticeGLPracticeID = '20' WHERE PracticeID = '0~EKK                            '
UPDATE dim.Practices SET PracticeGLLocationID = '13',PracticeGLLocation = 'Gilbert Medical Center',PracticeGLPracticeID = '42' WHERE PracticeID = '0~GMC                            '
UPDATE dim.Practices SET PracticeGLLocationID = '14',PracticeGLLocation = 'TPG - Choctaw',PracticeGLPracticeID = '29' WHERE PracticeID = '0~GPK                            '
UPDATE dim.Practices SET PracticeGLLocationID = '33',PracticeGLLocation = 'Spectrum',PracticeGLPracticeID = '51' WHERE PracticeID = '0~HSL                            '
UPDATE dim.Practices SET PracticeGLLocationID = '9',PracticeGLLocation = 'FHCS',PracticeGLPracticeID = '10' WHERE PracticeID = '0~JLM                            '
UPDATE dim.Practices SET PracticeGLLocationID = '12',PracticeGLLocation = 'TPG FP - 89th',PracticeGLPracticeID = '49' WHERE PracticeID = '0~LAK                            '
UPDATE dim.Practices SET PracticeGLLocationID = '32',PracticeGLLocation = 'APEX',PracticeGLPracticeID = '63' WHERE PracticeID = '0~LCS                            '
UPDATE dim.Practices SET PracticeGLLocationID = '9',PracticeGLLocation = 'FHCS',PracticeGLPracticeID = '16' WHERE PracticeID = '0~LLK                            '
UPDATE dim.Practices SET PracticeGLLocationID = '5',PracticeGLLocation = 'OSSO Spine Center',PracticeGLPracticeID = '62' WHERE PracticeID = '0~LRL                            '
UPDATE dim.Practices SET PracticeGLLocationID = '1',PracticeGLLocation = 'OSSO Broadway',PracticeGLPracticeID = '35' WHERE PracticeID = '0~MBJ                            '
UPDATE dim.Practices SET PracticeGLLocationID = '25',PracticeGLLocation = 'Piedmont',PracticeGLPracticeID = '57' WHERE PracticeID = '0~MEC                            '
UPDATE dim.Practices SET PracticeGLLocationID = '24',PracticeGLLocation = 'OSSO SKI',PracticeGLPracticeID = '24' WHERE PracticeID = '0~MEM                            '
UPDATE dim.Practices SET PracticeGLLocationID = '18',PracticeGLLocation = 'TPG LakePointe',PracticeGLPracticeID = '61' WHERE PracticeID = '0~MMD                            '
UPDATE dim.Practices SET PracticeGLLocationID = '15',PracticeGLLocation = 'OCOE',PracticeGLPracticeID = '31' WHERE PracticeID = '0~MSO                            '
UPDATE dim.Practices SET PracticeGLLocationID = '13',PracticeGLLocation = 'Gilbert Medical Center',PracticeGLPracticeID = '68' WHERE PracticeID = '0~NBN                            '
UPDATE dim.Practices SET PracticeGLLocationID = '15',PracticeGLLocation = 'OCOE',PracticeGLPracticeID = '69' WHERE PracticeID = '0~NMO                            '
UPDATE dim.Practices SET PracticeGLLocationID = '8',PracticeGLLocation = 'OBGYN',PracticeGLPracticeID = '22' WHERE PracticeID = '0~NRW                            '
UPDATE dim.Practices SET PracticeGLLocationID = '5',PracticeGLLocation = 'OSSO Spine Center',PracticeGLPracticeID = '64' WHERE PracticeID = '0~PAK                            '
UPDATE dim.Practices SET PracticeGLLocationID = '1',PracticeGLLocation = 'OSSO Broadway',PracticeGLPracticeID = '34' WHERE PracticeID = '0~PBJ                            '
UPDATE dim.Practices SET PracticeGLLocationID = '1',PracticeGLLocation = 'OSSO Broadway',PracticeGLPracticeID = '66' WHERE PracticeID = '0~RGS                            '
UPDATE dim.Practices SET PracticeGLLocationID = '1',PracticeGLLocation = 'OSSO Broadway',PracticeGLPracticeID = '30' WHERE PracticeID = '0~RLN                            '
UPDATE dim.Practices SET PracticeGLLocationID = '27',PracticeGLLocation = 'Norman',PracticeGLPracticeID = '48' WHERE PracticeID = '0~RMH                            '
UPDATE dim.Practices SET PracticeGLLocationID = '29',PracticeGLLocation = 'The Fatigue Center',PracticeGLPracticeID = '70' WHERE PracticeID = '0~RSG                            '
UPDATE dim.Practices SET PracticeGLLocationID = '2',PracticeGLLocation = 'OSSO S',PracticeGLPracticeID = '4' WHERE PracticeID = '0~RSU                            '
UPDATE dim.Practices SET PracticeGLLocationID = '23',PracticeGLLocation = 'Greater OK Gastro',PracticeGLPracticeID = '67' WHERE PracticeID = '0~SCS                            '
UPDATE dim.Practices SET PracticeGLLocationID = '5',PracticeGLLocation = 'OSSO Spine Center',PracticeGLPracticeID = '26' WHERE PracticeID = '0~SMS                            '
UPDATE dim.Practices SET PracticeGLLocationID = '17',PracticeGLLocation = 'Krehbiel Clinic',PracticeGLPracticeID = '44' WHERE PracticeID = '0~TAK                            '
UPDATE dim.Practices SET PracticeGLLocationID = '1',PracticeGLLocation = 'OSSO Broadway',PracticeGLPracticeID = '25' WHERE PracticeID = '0~TCC                            '
----UPDATE dim.Practices SET PracticeGLLocationID = '22',PracticeGLLocation = 'Hinton',PracticeGLPracticeID = '55' WHERE PracticeID = '0~TDT                            '
----UPDATE dim.Practices SET PracticeGLLocationID = '30',PracticeGLLocation = 'Binger',PracticeGLPracticeID = '55' WHERE PracticeID = '0~TDT                            '
----UPDATE dim.Practices SET PracticeGLLocationID = '31',PracticeGLLocation = 'Hydro',PracticeGLPracticeID = '55' WHERE PracticeID = '0~TDT                            '
UPDATE dim.Practices SET PracticeGLLocationID = '9',PracticeGLLocation = 'FHCS',PracticeGLPracticeID = '8' WHERE PracticeID = '0~WSB'

UPDATE dim.Practices SET PracticeGLLocationID = '1',PracticeGLLocation = 'OSSO Broadway',PracticeGLPracticeID = '58' WHERE PracticeID = '0~ADB'
UPDATE dim.Practices SET PracticeGLLocationID = '7',PracticeGLLocation = 'OSSO Mercy',PracticeGLPracticeID = '12' WHERE PracticeID = '0~CRS'
UPDATE dim.Practices SET PracticeGLLocationID = '3',PracticeGLLocation = 'OSSO Edmond',PracticeGLPracticeID = '17' WHERE PracticeID = '0~DEA'
UPDATE dim.Practices SET PracticeGLLocationID = '23',PracticeGLLocation = 'Greater OK Gastro',PracticeGLPracticeID = '27' WHERE PracticeID = '0~DNR'
UPDATE dim.Practices SET PracticeGLLocationID = '5',PracticeGLLocation = 'OSSO Spine Center',PracticeGLPracticeID = '56' WHERE PracticeID = '0~GMM'
UPDATE dim.Practices SET PracticeGLLocationID = '3',PracticeGLLocation = 'OSSO Edmond',PracticeGLPracticeID = '65' WHERE PracticeID = '0~JAM'
UPDATE dim.Practices SET PracticeGLLocationID = '2',PracticeGLLocation = 'OSSO S',PracticeGLPracticeID = '3' WHERE PracticeID = '0~JHC'
UPDATE dim.Practices SET PracticeGLLocationID = '21',PracticeGLLocation = 'Rheumatology North',PracticeGLPracticeID = '52' WHERE PracticeID = '0~LDH'
UPDATE dim.Practices SET PracticeGLLocationID = '5',PracticeGLLocation = 'OSSO Spine Center',PracticeGLPracticeID = '6' WHERE PracticeID = '0~MHW'
UPDATE dim.Practices SET PracticeGLLocationID = '1',PracticeGLLocation = 'OSSO Broadway',PracticeGLPracticeID = '5' WHERE PracticeID = '0~SDC'
UPDATE dim.Practices SET PracticeGLLocationID = '6',PracticeGLLocation = 'OSSO Bryant',PracticeGLPracticeID = '23' WHERE PracticeID = '0~SWM'


--Added GMNH on 5.2.24
INSERT INTO dim.Practices SELECT '0~DB-JB',0,'DB-JB','GMNH','DB-JB','APM','TPG',1,0,GETDATE(),'13','Gilbert Medical Center','28'

--Removed Barenberg and Noel Williams from IsSameStore and Added Odor 5.16.2024
 update dim.practices set PracticeIsSameStore = 0 where PracticeID in ('0~BJB','0~NRW')
 update dim.practices set PracticeIsSameStore = 1 where PracticeID in ('0~NMO')

--Added HPIP Anesthesia on 5.29.24
INSERT INTO dim.Practices SELECT '0~HPIPAN',0,'HPIPAN','HPIP Anesthesia','HPIPAN','EPIC','HPIP',1,0,GETDATE(),NULL,NULL,NULL

--Updated Same Store designation for Cassie Smith on 7.30.2024
  UPDATE dim.Practices SET PracticeIsSameStore = 0, PracticeUpdatedDatetime = GETDATE() WHERE PracticeID = '0~CMS'


--Added New Practices on 8.19.24
INSERT INTO dim.Practices SELECT '0~EBJ',0,'EBJ','Eric B. Johnson, M.D.','EBJ','EPIC','TPG',1,0,GETDATE(),1,'OSSO Broadway','72'
INSERT INTO dim.Practices SELECT '0~NRJ',0,'NRJ','Nicholas R. Johnson, M.D.','NRJ','EPIC','TPG',1,0,GETDATE(),1,'OSSO Broadway','73'
INSERT INTO dim.Practices SELECT '0~SJA',0,'SJA','Shehan J. Abeyewardene, M.D.','SJA','EPIC','TPG',1,0,GETDATE(),2,'OSSO S','74'
INSERT INTO dim.Practices SELECT '0~WAS',0,'WAS','Wade A. Schwerdtfeger, M.D.','WAS','EPIC','TPG',1,0,GETDATE(),5,'OSSO Spine Center','75'


INSERT INTO dim.Practices SELECT '0~EXT',0,'EXT','External','EXT','EPIC','EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~HPICH',0,'HPICH','HPI Community Hospital','HPICH','EPIC',NULL,1,0,GETDATE(),NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~THP',0,'THP','Total Healthcare Partners','THP','EPIC','THP',1,0,GETDATE(),NULL,NULL,NULL

--Added Specialties ON 8.20.2024
UPDATE dim.Practices SET PracticeCompany = 'TPG',PracticeSpecialty = 'Ortho' WHERE PracticeID = '0~ACC'
UPDATE dim.Practices SET PracticeCompany = 'HPIP',PracticeSpecialty = 'Pain' WHERE PracticeID = '0~ADB'
UPDATE dim.Practices SET PracticeCompany = 'TPG',PracticeSpecialty = 'Primary' WHERE PracticeID = '0~AKM'
UPDATE dim.Practices SET PracticeCompany = 'TPG',PracticeSpecialty = 'Spine' WHERE PracticeID = '0~BAB'
UPDATE dim.Practices SET PracticeCompany = 'TPG',PracticeSpecialty = 'Primary' WHERE PracticeID = '0~BEB'
UPDATE dim.Practices SET PracticeCompany = 'TPG',PracticeSpecialty = 'Primary' WHERE PracticeID = '0~BET'
UPDATE dim.Practices SET PracticeCompany = 'TPG',PracticeSpecialty = 'Gynecology' WHERE PracticeID = '0~BJB'
UPDATE dim.Practices SET PracticeCompany = 'TPG',PracticeSpecialty = 'Ortho' WHERE PracticeID = '0~BLN'
UPDATE dim.Practices SET PracticeCompany = 'TPG',PracticeSpecialty = 'Spine' WHERE PracticeID = '0~CAH'
UPDATE dim.Practices SET PracticeCompany = 'HPIP',PracticeSpecialty = 'Gastro' WHERE PracticeID = '0~CGW'
UPDATE dim.Practices SET PracticeCompany = 'TPG',PracticeSpecialty = 'Endo ' WHERE PracticeID = '0~CMS'
UPDATE dim.Practices SET PracticeCompany = 'HPIP',PracticeSpecialty = 'Spine' WHERE PracticeID = '0~CSH'
UPDATE dim.Practices SET PracticeCompany = 'CUST',PracticeSpecialty = 'Primary' WHERE PracticeID = '0~DB-JB'
UPDATE dim.Practices SET PracticeCompany = 'HPIP',PracticeSpecialty = 'Ortho' WHERE PracticeID = '0~DCH '
UPDATE dim.Practices SET PracticeCompany = 'TPG',PracticeSpecialty = 'Pain' WHERE PracticeID = '0~DDR'
UPDATE dim.Practices SET PracticeCompany = 'TPG',PracticeSpecialty = 'Primary' WHERE PracticeID = '0~DRB'
UPDATE dim.Practices SET PracticeCompany = 'TPG',PracticeSpecialty = 'Primary' WHERE PracticeID = '0~DRW'
UPDATE dim.Practices SET PracticeCompany = 'TPG',PracticeSpecialty = 'Ortho' WHERE PracticeID = '0~EBJ'
UPDATE dim.Practices SET PracticeCompany = 'TPG',PracticeSpecialty = 'Primary' WHERE PracticeID = '0~EKK'
UPDATE dim.Practices SET PracticeCompany = 'EXTERNAL',PracticeSpecialty = '' WHERE PracticeID = '0~EXT'
UPDATE dim.Practices SET PracticeCompany = 'TPG',PracticeSpecialty = 'Primary' WHERE PracticeID = '0~GPK'
UPDATE dim.Practices SET PracticeCompany = 'TPG',PracticeSpecialty = 'Primary' WHERE PracticeID = '0~HAG'
UPDATE dim.Practices SET PracticeCompany = 'NULL',PracticeSpecialty = '' WHERE PracticeID = '0~HPICH'
UPDATE dim.Practices SET PracticeCompany = 'HPIP',PracticeSpecialty = '' WHERE PracticeID = '0~HPIPAN'
UPDATE dim.Practices SET PracticeCompany = 'TPG',PracticeSpecialty = 'Derm' WHERE PracticeID = '0~HSL'
UPDATE dim.Practices SET PracticeCompany = 'TPG',PracticeSpecialty = 'Primary' WHERE PracticeID = '0~JCB'
UPDATE dim.Practices SET PracticeCompany = 'TPG',PracticeSpecialty = 'Primary' WHERE PracticeID = '0~JLM'
UPDATE dim.Practices SET PracticeCompany = 'HPIP',PracticeSpecialty = 'Spine' WHERE PracticeID = '0~JPN'
UPDATE dim.Practices SET PracticeCompany = 'TPG',PracticeSpecialty = 'Primary' WHERE PracticeID = '0~LAK'
UPDATE dim.Practices SET PracticeCompany = 'TPG',PracticeSpecialty = 'Spine' WHERE PracticeID = '0~LCS'
UPDATE dim.Practices SET PracticeCompany = 'TPG',PracticeSpecialty = 'Primary' WHERE PracticeID = '0~LLK'
UPDATE dim.Practices SET PracticeCompany = 'TPG',PracticeSpecialty = 'Ortho' WHERE PracticeID = '0~LRL'
UPDATE dim.Practices SET PracticeCompany = 'TPG',PracticeSpecialty = 'Ortho' WHERE PracticeID = '0~MBJ'
UPDATE dim.Practices SET PracticeCompany = 'HPIP',PracticeSpecialty = 'Gastro' WHERE PracticeID = '0~MDW'
UPDATE dim.Practices SET PracticeCompany = 'TPG',PracticeSpecialty = 'Primary' WHERE PracticeID = '0~MEC'
UPDATE dim.Practices SET PracticeCompany = 'TPG',PracticeSpecialty = 'Ortho' WHERE PracticeID = '0~MEM'
UPDATE dim.Practices SET PracticeCompany = 'TPG',PracticeSpecialty = 'Ortho' WHERE PracticeID = '0~MMD'
UPDATE dim.Practices SET PracticeCompany = 'TPG',PracticeSpecialty = 'Ortho' WHERE PracticeID = '0~MSO'
UPDATE dim.Practices SET PracticeCompany = 'TPG',PracticeSpecialty = 'Derm' WHERE PracticeID = '0~NBN'
UPDATE dim.Practices SET PracticeCompany = 'TPG',PracticeSpecialty = 'Ortho' WHERE PracticeID = '0~NMO'
UPDATE dim.Practices SET PracticeCompany = 'HPIP',PracticeSpecialty = 'Pain' WHERE PracticeID = '0~NPS'
UPDATE dim.Practices SET PracticeCompany = 'TPG',PracticeSpecialty = 'Ortho' WHERE PracticeID = '0~NRJ'
UPDATE dim.Practices SET PracticeCompany = 'TPG',PracticeSpecialty = 'Gynecology' WHERE PracticeID = '0~NRW'
UPDATE dim.Practices SET PracticeCompany = 'TPG',PracticeSpecialty = 'Ortho' WHERE PracticeID = '0~PAK'
UPDATE dim.Practices SET PracticeCompany = 'TPG',PracticeSpecialty = 'Ortho' WHERE PracticeID = '0~PBJ'
UPDATE dim.Practices SET PracticeCompany = 'CUST',PracticeSpecialty = 'Ortho' WHERE PracticeID = '0~PDM'
UPDATE dim.Practices SET PracticeCompany = 'TPG',PracticeSpecialty = 'Primary' WHERE PracticeID = '0~RDI'
UPDATE dim.Practices SET PracticeCompany = 'HPIP',PracticeSpecialty = 'Ortho' WHERE PracticeID = '0~RFH'
UPDATE dim.Practices SET PracticeCompany = 'TPG',PracticeSpecialty = 'Ortho' WHERE PracticeID = '0~RGS'
UPDATE dim.Practices SET PracticeCompany = 'TPG',PracticeSpecialty = 'Ortho' WHERE PracticeID = '0~RLN'
UPDATE dim.Practices SET PracticeCompany = 'TPG',PracticeSpecialty = 'Pain' WHERE PracticeID = '0~RMH'
UPDATE dim.Practices SET PracticeCompany = 'TPG',PracticeSpecialty = 'Primary' WHERE PracticeID = '0~RSG'
UPDATE dim.Practices SET PracticeCompany = 'TPG',PracticeSpecialty = 'Ortho' WHERE PracticeID = '0~RSU'
UPDATE dim.Practices SET PracticeCompany = 'TPG',PracticeSpecialty = 'Primary' WHERE PracticeID = '0~SCS'
UPDATE dim.Practices SET PracticeCompany = 'TPG',PracticeSpecialty = 'Primary' WHERE PracticeID = '0~SDB'
UPDATE dim.Practices SET PracticeCompany = 'TPG',PracticeSpecialty = 'Ortho' WHERE PracticeID = '0~SJA'
UPDATE dim.Practices SET PracticeCompany = 'TPG',PracticeSpecialty = 'Primary' WHERE PracticeID = '0~SJL'
UPDATE dim.Practices SET PracticeCompany = 'TPG',PracticeSpecialty = 'Ortho' WHERE PracticeID = '0~SMS'
UPDATE dim.Practices SET PracticeCompany = 'TPG',PracticeSpecialty = 'Primary' WHERE PracticeID = '0~TAK'
UPDATE dim.Practices SET PracticeCompany = 'TPG',PracticeSpecialty = 'Ortho' WHERE PracticeID = '0~TCC'
UPDATE dim.Practices SET PracticeCompany = 'TPG',PracticeSpecialty = 'Primary' WHERE PracticeID = '0~TDT'
UPDATE dim.Practices SET PracticeCompany = 'THP',PracticeSpecialty = 'Primary' WHERE PracticeID = '0~THP'
UPDATE dim.Practices SET PracticeCompany = 'TPG',PracticeSpecialty = 'Ortho' WHERE PracticeID = '0~WAS'
UPDATE dim.Practices SET PracticeCompany = 'TPG',PracticeSpecialty = 'Primary' WHERE PracticeID = '0~WSB'

/*8.22.24 - Created new practices for Referral mapping*/
INSERT INTO dim.Practices SELECT '0~9931008665',0,'9931008665','COMMUNITY HOSPITAL',NULL,NULL,'CH',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~43004001004',0,'43004001004','HPI CHN CT',NULL,NULL,'CH',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~43004001014',0,'43004001014','HPI CHN MAIN OR',NULL,NULL,'CH',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~43004001001',0,'43004001001','HPI CHN MED/SURG',NULL,NULL,'CH',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~43004001005',0,'43004001005','HPI CHN MRI',NULL,NULL,'CH',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~43004001036',0,'43004001036','HPI CHN OP PROCEDURES',NULL,NULL,'CH',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~43004002',0,'43004002','HPI CHN OR',NULL,NULL,'CH',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~43004001009',0,'43004001009','HPI CHN PHARMACY',NULL,NULL,'CH',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~43004001003',0,'43004001003','HPI CHN RADIOLOGY',NULL,NULL,'CH',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~43005005005',0,'43005005005','HPI CHS CT',NULL,NULL,'CH',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~43005005010',0,'43005005010','HPI CHS IP PT',NULL,NULL,'CH',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~43005005013',0,'43005005013','HPI CHS MAIN OR',NULL,NULL,'CH',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~43005005006',0,'43005005006','HPI CHS MRI',NULL,NULL,'CH',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~43005005027',0,'43005005027','HPI CHS OP OT HAND',NULL,NULL,'CH',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~43005005023',0,'43005005023','HPI CHS OP PROCEDURES',NULL,NULL,'CH',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~43005005025',0,'43005005025','HPI CHS OP PT QUAIL',NULL,NULL,'CH',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~43005005026',0,'43005005026','HPI CHS OP PT SOUTH',NULL,NULL,'CH',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~43005005016',0,'43005005016','HPI CHS PAIN',NULL,NULL,'CH',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~43005005004',0,'43005005004','HPI CHS RADIOLOGY',NULL,NULL,'CH',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~43004001',0,'43004001','HPI COMMUNITY HOSPITAL NORTH',NULL,NULL,'CH',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~9931009378',0,'9931009378','HPI COMMUNITY HOSPITAL NORTH CAMPUS - IMAGING',NULL,NULL,'CH',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~9931009576',0,'9931009576','HPI COMMUNITY HOSPITAL OUTPATIENT THERAPY - QUAIL POINTE',NULL,NULL,'CH',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~9931009583',0,'9931009583','HPI COMMUNITY HOSPITAL OUTPATIENT THERAPY - SOUTH',NULL,NULL,'CH',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~9931009575',0,'9931009575','HPI COMMUNITY HOSPITAL OUTPATIENT THERAPY - SOUTH - HAND THERAPY',NULL,NULL,'CH',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~43005005',0,'43005005','HPI COMMUNITY HOSPITAL SOUTH',NULL,NULL,'CH',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~9931009379',0,'9931009379','HPI COMMUNITY HOSPITAL SOUTH CAMPUS - IMAGING',NULL,NULL,'CH',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~9931009380',0,'9931009380','HPI COMMUNITY HOSPITAL SOUTH CAMPUS - MRI',NULL,NULL,'CH',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~9931008077',0,'9931008077','HPI COMMUNITY HOSPITAL SOUTH CAMPUS - OUTPATIENT HOSPITAL',NULL,NULL,'CH',1,0,GETDATE(),NULL,NULL,NULL,NULL



09.03.2024 - updated NMO GL Location
UPDATE dim.Practices SET PracticeGLLocationId = 1 WHERE PracticeID = '0~NMO'


/*10.2.2024 - Added new external practices for referral mapping*/
INSERT INTO dim.Practices SELECT '0~EXT1',0,'EXT1','72D MEDICAL GROUP - TINKER AIR FORCE BASE CLINIC',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT2',0,'EXT2','ALIGN INTERVENTIONAL PAIN',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT3',0,'EXT3','ARCHWELL HEALTH',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT4',0,'EXT4','ASSOCIATES IN FAMILY PRACTICE',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT5',0,'EXT5','CANADIAN VALLEY FAMILY CARE',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT6',0,'EXT6','CCC CHOE MEDICAL GROUP',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT7',0,'EXT7','CCC KNIGHT FOOT AND ANKLE',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT8',0,'EXT8','CCC LOWE PLASTIC SURGERY',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT9',0,'EXT9','CCC NEUROSURGICAL & SPINE ASSOCIATES OF OKLAHOMA, PC',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT10',0,'EXT10','CCC OKLAHOMA UROLOGY - YUKON',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT11',0,'EXT11','CCC REMEDY RHEUMATOLOGY',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT12',0,'EXT12','CCC RONALD R HOPKINS DO PLLC',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT13',0,'EXT13','CCC SOS SPINE, PAIN & WELLNESS INSTITUTE',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT14',0,'EXT14','CCC SOUTHWEST ORTHOPAEDIC SPECIALISTS, PLLC',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT15',0,'EXT15','CCC SOUTHWEST ORTHOPAEDIC SPECIALISTS, PLLC ',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT16',0,'EXT16','CCC TRAIL CREEK WELLNESS',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT17',0,'EXT17','CHOE MEDICAL GROUP',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT18',0,'EXT18','CLEVELAND AREA HOSPITAL',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT19',0,'EXT19','COMPREHENSIVE PAIN CENTER',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT20',0,'EXT20','CONCENTRA MEDICAL CENTER',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT21',0,'EXT21','CONCENTRA URGENT CARE',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT22',0,'EXT22','CROSSWAY MEDICAL CLINIC',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT23',0,'EXT23','ELITE PAIN AND HEALTH',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT24',0,'EXT24','ELITE WELLNESS',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT25',0,'EXT25','ENCOMPASS WELLNESS AND AESTHETICS',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT26',0,'EXT26','FIRST MED PRIMARY CARE',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT27',0,'EXT27','H. DIANA O''CONNOR, DO',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT28',0,'EXT28','HEALTHCARE ONE',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT29',0,'EXT29','ICP Northwest Internal Medicine',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT30',0,'EXT30','ICP Oklahoma CV Surgeons',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT31',0,'EXT31','IHMG GUTHRIE',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT32',0,'EXT32','IHMG NORTH MACARTHUR',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT33',0,'EXT33','IHMG ORTHOPEDICS YUKON',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT34',0,'EXT34','IMG Canadian Valley Women''s Clinic',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT35',0,'EXT35','IMG Great Plains Family Practice',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT36',0,'EXT36','IMG INTEGRIS Baptist Medical Center Portland Avenue Gastroenterology',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT37',0,'EXT37','IMG INTEGRIS Baptist Women''s Health',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT38',0,'EXT38','IMG INTEGRIS Family Care - Baptist',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT39',0,'EXT39','IMG INTEGRIS Family Care - Central',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT40',0,'EXT40','IMG INTEGRIS Family Care - Coffee Creek',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT41',0,'EXT41','IMG INTEGRIS Family Care - Council Crossing',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT42',0,'EXT42','IMG INTEGRIS Family Care - Del City',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT43',0,'EXT43','IMG INTEGRIS Family Care - Edmond East',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT44',0,'EXT44','IMG INTEGRIS Family Care - Edmond Renaissance',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT45',0,'EXT45','IMG INTEGRIS Family Care - Edmond Women''s Health',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT46',0,'EXT46','IMG INTEGRIS Family Care - Hefner Pointe',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT47',0,'EXT47','IMG INTEGRIS Family Care - Hinton',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT48',0,'EXT48','IMG INTEGRIS Family Care - Lake Pointe',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT49',0,'EXT49','IMG INTEGRIS Family Care - Memorial West',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT50',0,'EXT50','IMG INTEGRIS Family Care - Moore',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT51',0,'EXT51','IMG INTEGRIS Family Care - Norman',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT52',0,'EXT52','IMG INTEGRIS Family Care - North MacArthur',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT53',0,'EXT53','IMG INTEGRIS Family Care - NW Family Medicine',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT54',0,'EXT54','IMG INTEGRIS Family Care - South',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT55',0,'EXT55','IMG INTEGRIS Family Care - Southwest',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT56',0,'EXT56','IMG INTEGRIS Family Care - Surrey Hills',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT57',0,'EXT57','IMG INTEGRIS Family Care - Yukon',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT58',0,'EXT58','IMG INTEGRIS Family Care Clinic',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT59',0,'EXT59','IMG INTEGRIS Orthopedics - Central',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT60',0,'EXT60','IMG INTEGRIS Orthopedics - Edmond',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT61',0,'EXT61','IMG INTEGRIS Orthopedics - Yukon',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT62',0,'EXT62','IMG INTEGRIS Pain Management',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT63',0,'EXT63','IMG INTEGRIS Pulmonology',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT64',0,'EXT64','IMMEDIATE CARE OF OKLAHOMA',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT65',0,'EXT65','INTEGRATIVE MEDICAL SOLUTIONS',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT66',0,'EXT66','INTEGRIS Cancer Institute of Oklahoma',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT67',0,'EXT67','INTEGRIS Central Oklahoma Cancer Center',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT68',0,'EXT68','INTEGRIS HEALTH MEDICAL GROUP BAPTIST PULMONARY MEDICINE',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT69',0,'EXT69','INTEGRIS Health Medical Group- Cross Timbers',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT70',0,'EXT70','INTEGRIS Health Medical Group Endocrinology and Rheumatology South',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT71',0,'EXT71','INTEGRIS Health Medical Group General and Colorectal Surgery',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT72',0,'EXT72','INTEGRIS Health Medical Group Mustang',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT73',0,'EXT73','INTEGRIS Health Medical Group Newcastle',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT74',0,'EXT74','INTEGRIS Health Medical Group Orthopedics Trauma',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT75',0,'EXT75','INTEGRIS Health Urgent Care - North OKC',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT76',0,'EXT76','INTEGRIS HENNESSEY MEDICAL CLINIC',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT77',0,'EXT77','INTEGRIS MEDICAL GROUP ENID',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT78',0,'EXT78','INTEGRIS MEDICAL GROUP GROVE',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT79',0,'EXT79','INTEGRIS Nazih Zuhdi Transplant Institute',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT80',0,'EXT80','KHALID KHAN, MD',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT81',0,'EXT81','MCBRIDE ORTHOPEDIC HOSPITAL CLINIC, LLC',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT82',0,'EXT82','MERCY ADA',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT83',0,'EXT83','MERCY CLINIC PRIMARY CARE EDMOND MEMORIAL',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT84',0,'EXT84','MERCY CLINIC OKLAHOMA COMMUNITIES',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT85',0,'EXT85','MERCY CLINIC ORTHOPEDIC ASSOCIATES',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT86',0,'EXT86','MERCY CLINIC PAIN MANAGEMENT - EDMOND I-35',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT87',0,'EXT87','MERCY CLINIC PRIMARY CARE NORTH PORTLAND',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT88',0,'EXT88','MIDWEST MEDICAL GROUP',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT89',0,'EXT89','MIND MOOD PAIN',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT90',0,'EXT90','MODERN CONCIERGE MEDICINE',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT91',0,'EXT91','MODERN ENDOCRINE',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT92',0,'EXT92','NEUROSURGICAL SERVICES PLLC',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT93',0,'EXT93','NORMAN REGIONAL ',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT94',0,'EXT94','NORMAN REGIONAL PRIMARY CARE NEWCASTLE',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT95',0,'EXT95','OKLAHOMA CENTER FOR SPINE & PAIN SOLUTIONS PC',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT96',0,'EXT96','OKLAHOMA CITY INDIAN CLINIC',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT97',0,'EXT97','OKLAHOMA FOOT AND ANKLE ASSOCIATES',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT98',0,'EXT98','OKLAHOMA PAIN INSTITUTE',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT99',0,'EXT99','OKLAHOMA PAIN MANAGEMENT',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT100',0,'EXT100','OKLAHOMA SPINE HOSPITAL',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT101',0,'EXT101','OPTIMAL HEALTH ASSOCIATES',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT102',0,'EXT102','ORTHO PLUS',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT103',0,'EXT103','ORTHOPAEDIC & SPORTS MEDICINE CENTER OSC',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT104',0,'EXT104','OU HEALTH',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT105',0,'EXT105','PILLARS OF CARE ',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT106',0,'EXT106','PRIMARY HEALTH PARTNERS',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT107',0,'EXT107','RANDALL PAIN MANAGEMENT',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT108',0,'EXT108','RICHARD MORGAN',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT109',0,'EXT109','SOUTHSIDE FAMILY CARE',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT110',0,'EXT110','SOUTHWEST MEDICAL AFFILATES',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT111',0,'EXT111','SPECTRUM DERMATOLOGY',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT112',0,'EXT112','SPINE SURGERY ASSOCIATES, PLLC',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT113',0,'EXT113','SSM HEALTH',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT114',0,'EXT114','SSM HEALTH ST. ANTHONY HOSPITAL - OKLAHOMA CITY',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT115',0,'EXT115','The Blakeburn Clinic',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT116',0,'EXT116','THE CLINIC AT HOBBY LOBBY',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT117',0,'EXT117','TOTAL HEALTHCARE PARTNERS',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT118',0,'EXT118','TRI-CITY FAMILY CARE',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT119',0,'EXT119','TYLER PHILLIPS, MD',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT120',0,'EXT120','UROLOGY ASSOCIATES, INC.',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT121',0,'EXT121','VA MEDICAL CENTER - OKC',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT122',0,'EXT122','VIP CARE',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT123',0,'EXT123','WESTERN OKLAHOMA PAIN SPECIALISTS',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT124',0,'EXT124','WILSON MEDICAL',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT125',0,'EXT125','WOODS FAMILY MEDICINE',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT126',0,'EXT126','YOUR HEALTH LLC',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT127',0,'EXT127','CCC SURGICAL PARTNERS OF OKLAHOMA',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT128',0,'EXT128','CCC UROLOGY SPECIALISTS OF CENTRAL OK',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT129',0,'EXT129','KEYHOLE BRAIN & SPINE',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT130',0,'EXT130','OKLAHOMA OTOLARYNGOLOGY ASSOCIATES',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT131',0,'EXT131','OKLAHOMA SPINE AND MUSCULOSKELETAL',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT132',0,'EXT132','RHEUMATOLOGY ASSOCIATES OF OKLAHOMA',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT133',0,'EXT133','SURGICAL PARTNERS OF OKLAHOMA, PLLC',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL
INSERT INTO dim.Practices SELECT '0~EXT134',0,'EXT134','ZEIDERS ORTHOPEDICS SOUTH OKLAHOMA CITY',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL

INSERT INTO dim.Practices SELECT '0~EXT135',0,'EXT135','JAMES M ALVIS',NULL,NULL,'EXTERNAL',1,0,GETDATE(),NULL,NULL,NULL,NULL


--Updated Same Store designation for Hillary Lawrence on 10.25.2024
  UPDATE dim.Practices SET PracticeIsSameStore = 0, PracticeUpdatedDatetime = GETDATE() WHERE PracticeID = '0~HSL'

/*Added 9/12/25*/
INSERT INTO dim.Practices SELECT '0~RDW',0,'RDW','Rian D. Wilson','RDW','EPIC','TPG',1,0,GETDATE(),11,NULL,77,'Family Med'
INSERT INTO dim.Practices SELECT '0~LBB',0,'LBB','Laura B. Buford','LBB','APM','TPG',1,0,GETDATE(),19,NULL,76,'Derm'

/*Added 3/31/2026*/
INSERT INTO dim.Practices SELECT '0~CDH',0,'CDH','Christopher D. Harris','CDH','EPIC','TPG',1,0,GETDATE(),35,NULL,78,'Family Med','4/1/2026'

/*Updated 4/30/206 - Set Kilkenny to Inactive*/
UPDATE dim.Practices SET PracticeIsActive = 0, PracticeUpdatedDatetime = GETDATE() WHERE PracticeID = '0~LLK'

/*Updated 5/1/2026 - Set PDM to HPIP*/
UPDATE dim.Practices SET PracticeCompany = 'HPIP', PracticeDataSource = 'EPIC', PracticeUpdatedDatetime = getdate() WHERE PracticeID = '0~PDM'

/*Updated 6/2/206 - Set Kelley to Inactive*/
UPDATE dim.Practices SET PracticeIsActive = 0, PracticeUpdatedDatetime = GETDATE() WHERE PracticeID = '0~GPK'


select * from dim.Practices p where p.practicename like '%kell%'
*/
GO
