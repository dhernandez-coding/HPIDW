CREATE PROCEDURE  [stg].[spHPIReloadMapPracticeDepartmentsFull] AS
/*
CREATE TABLE map.PracticeDepartments
(PracticeDepartmentID int identity(1,1) primary key not null
,PracticeID varchar(100) not null
,DepartmentID varchar(100) not null
,PracticeDepartmentEffectiveDate date
,PracticeDepartmentEndDate date
,PracticeDepartmentIsActive bit
,PracticeDepartmentUpdatedDatetime datetime
)


TRUNCATE TABLE map.PracticeDepartments 
insert into map.PracticeDepartments select '0~CSH','5~43001002001','1/1/2021','12/31/2099',1,getdate()
insert into map.PracticeDepartments select '0~CGW','5~43001009001','1/1/2021','12/31/2099',1,getdate()
insert into map.PracticeDepartments select '0~CGW','5~43001009002','1/1/2021','12/31/2099',1,getdate()
insert into map.PracticeDepartments select '0~DCH','5~43001002002','1/1/2021','12/31/2099',1,getdate()
insert into map.PracticeDepartments select '0~JPN','5~43001001001','1/1/2021','12/31/2099',1,getdate()
insert into map.PracticeDepartments select '0~JPN','5~43001003002','1/1/2021','12/31/2099',1,getdate()
insert into map.PracticeDepartments select '0~JPN','5~43001003001','1/1/2021','12/31/2099',1,getdate()
insert into map.PracticeDepartments select '0~MDW','5~43001009003','1/1/2021','12/31/2099',1,getdate()
insert into map.PracticeDepartments select '0~MDW','5~43001009004','1/1/2021','12/31/2099',1,getdate()
insert into map.PracticeDepartments select '0~BET','5~42501008001','1/1/2021','12/31/2099',1,getdate()
insert into map.PracticeDepartments select '0~CMS','5~42501003001','1/1/2021','12/31/2099',1,getdate()
insert into map.PracticeDepartments select '0~GMM','5~42501002001','1/1/2021','12/31/2099',1,getdate()
insert into map.PracticeDepartments select '0~GMM','5~42501002002','1/1/2021','12/31/2099',1,getdate()
insert into map.PracticeDepartments select '0~MMD','5~42501004001','1/1/2021','12/31/2099',1,getdate()
insert into map.PracticeDepartments select '0~MMD','5~42501005001','1/1/2021','12/31/2099',1,getdate()
insert into map.PracticeDepartments select '0~GMM','5~42501005002','1/1/2021','12/31/2099',1,getdate()
insert into map.PracticeDepartments select '0~MEC','5~42501001001','1/1/2021','12/31/2099',1,getdate()
insert into map.PracticeDepartments select '0~RSG','5~42501007001','1/1/2021','12/31/2099',1,getdate()
insert into map.PracticeDepartments select '0~SCS','5~42501006001','1/1/2021','12/31/2099',1,getdate()
/*Added 2.15.24*/
insert into map.PracticeDepartments select '0~NPS','5~43001009005','1/1/2021','12/31/2099',1,getdate()
insert into map.PracticeDepartments select '0~NPS','5~43001009006','1/1/2021','12/31/2099',1,getdate()
/*Added 2.28.24*/
insert into map.PracticeDepartments select '0~RFH','5~43001009008','1/1/2021','12/31/2099',1,getdate()
insert into map.PracticeDepartments select '0~ADB','5~43001009007','1/1/2021','12/31/2099',1,getdate()
insert into map.PracticeDepartments select '0~PBJ','5~42501012001','1/1/2021','12/31/2099',1,getdate()
insert into map.PracticeDepartments select '0~BLN','5~42501010001','1/1/2021','12/31/2099',1,getdate()
insert into map.PracticeDepartments select '0~RLN','5~42501014001','1/1/2021','12/31/2099',1,getdate()
insert into map.PracticeDepartments select '0~RGS','5~42501011001','1/1/2021','12/31/2099',1,getdate()
insert into map.PracticeDepartments select '0~BAB','5~42501009001','1/1/2021','12/31/2099',1,getdate()
insert into map.PracticeDepartments select '0~MBJ','5~42501013001','1/1/2021','12/31/2099',1,getdate()
/*Added 4.3.24*/
insert into map.PracticeDepartments select '0~RGS','5~42501011002','1/1/2021','12/31/2099',1,getdate()
/*Added 4.26.24*/
insert into map.PracticeDepartments select '0~ACC','5~42501015001','1/1/2021','12/31/2099',1,getdate()
/*Added GMNH 5.2.24*/
insert into map.PracticeDepartments select '0~DB-JB','1~15','1/1/2021','12/31/2099',1,getdate()
/*Added HPIP Anesthesia on 5.29.24*/
insert into map.PracticeDepartments select '0~HPIPAN','5~43001006001','1/1/2021','12/31/2099',1,getdate()
insert into map.PracticeDepartments select '0~HPIPAN','5~43001007001','1/1/2021','12/31/2099',1,getdate()
insert into map.PracticeDepartments select '0~HPIPAN','5~43001008001','1/1/2021','12/31/2099',1,getdate()
insert into map.PracticeDepartments select '0~HPIPAN','5~43004001025','1/1/2021','12/31/2099',1,getdate()
insert into map.PracticeDepartments select '0~HPIPAN','5~43005005030','1/1/2021','12/31/2099',1,getdate()
insert into map.PracticeDepartments select '0~HPIPAN','5~43006001020','1/1/2021','12/31/2099',1,getdate()

/*Added MSO ON 5.29.24*/
insert into map.PracticeDepartments select '0~MSO','5~42501016001','1/1/2021','12/31/2099',1,getdate()
insert into map.PracticeDepartments select '0~MSO','5~42501017001','1/1/2021','12/31/2099',1,getdate()

/*Added Odor (NMO) ON 5.29.24*/
insert into map.PracticeDepartments select '0~NMO','5~42501018001','1/1/2021','12/31/2099',1,getdate()
insert into map.PracticeDepartments select '0~NMO','5~42501019001','1/1/2021','12/31/2099',1,getdate()


/*Added Northcutt (BLN) ON 5.29.24*/
insert into map.PracticeDepartments select '0~BLN','5~42501010002','1/1/2021','12/31/2099',1,getdate()

/*Added Thatcher (BET) ON 5.29.24*/
insert into map.PracticeDepartments select '0~BET','5~42501008002','1/1/2021','12/31/2099',1,getdate()

/*Added Smith (SMS) ON 6.28.24*/
insert into map.PracticeDepartments select '0~SMS','5~42501023001','1/1/2021','12/31/2099',1,getdate()
insert into map.PracticeDepartments select '0~SMS','5~42501024001','1/1/2021','12/31/2099',1,getdate()

/*Added Kammerlocher (PAK) ON 6.28.24*/
insert into map.PracticeDepartments select '0~PAK','5~42501020001','1/1/2021','12/31/2099',1,getdate()

/*Added Luick (LRL) ON 6.28.24*/
insert into map.PracticeDepartments select '0~LRL','5~42501021001','1/1/2021','12/31/2099',1,getdate()
insert into map.PracticeDepartments select '0~LRL','5~42501022001','1/1/2021','12/31/2099',1,getdate()

/*Added Odor (NMO) ON 8.01.24*/
insert into map.PracticeDepartments select '0~NMO','5~42501025001','1/1/2021','12/31/2099',1,getdate()

/*Added Kirsch (LAK) ON 8.01.24*/
insert into map.PracticeDepartments select '0~LAK','5~42501008004','1/1/2021','12/31/2099',1,getdate()

/*Added King (EKK) ON 8.01.24*/
insert into map.PracticeDepartments select '0~EKK','5~42501008003','1/1/2021','12/31/2099',1,getdate()

/*Added these for Referral mapping to CHS and CHN departments on 8.23.2024*/
INSERT INTO map.PracticeDepartments SELECT '0~43004001004','5~43004001004','1/1/2021','12/31/2099',1,getdate()
INSERT INTO map.PracticeDepartments SELECT '0~43004001014','5~43004001014','1/1/2021','12/31/2099',1,getdate()
INSERT INTO map.PracticeDepartments SELECT '0~43004001001','5~43004001001','1/1/2021','12/31/2099',1,getdate()
INSERT INTO map.PracticeDepartments SELECT '0~43004001005','5~43004001005','1/1/2021','12/31/2099',1,getdate()
INSERT INTO map.PracticeDepartments SELECT '0~43004001036','5~43004001036','1/1/2021','12/31/2099',1,getdate()
INSERT INTO map.PracticeDepartments SELECT '0~43004001009','5~43004001009','1/1/2021','12/31/2099',1,getdate()
INSERT INTO map.PracticeDepartments SELECT '0~43004001003','5~43004001003','1/1/2021','12/31/2099',1,getdate()
INSERT INTO map.PracticeDepartments SELECT '0~43005005005','5~43005005005','1/1/2021','12/31/2099',1,getdate()
INSERT INTO map.PracticeDepartments SELECT '0~43005005010','5~43005005010','1/1/2021','12/31/2099',1,getdate()
INSERT INTO map.PracticeDepartments SELECT '0~43005005013','5~43005005013','1/1/2021','12/31/2099',1,getdate()
INSERT INTO map.PracticeDepartments SELECT '0~43005005006','5~43005005006','1/1/2021','12/31/2099',1,getdate()
INSERT INTO map.PracticeDepartments SELECT '0~43005005027','5~43005005027','1/1/2021','12/31/2099',1,getdate()
INSERT INTO map.PracticeDepartments SELECT '0~43005005023','5~43005005023','1/1/2021','12/31/2099',1,getdate()
INSERT INTO map.PracticeDepartments SELECT '0~43005005025','5~43005005025','1/1/2021','12/31/2099',1,getdate()
INSERT INTO map.PracticeDepartments SELECT '0~43005005026','5~43005005026','1/1/2021','12/31/2099',1,getdate()
INSERT INTO map.PracticeDepartments SELECT '0~43005005016','5~43005005016','1/1/2021','12/31/2099',1,getdate()
INSERT INTO map.PracticeDepartments SELECT '0~43005005004','5~43005005004','1/1/2021','12/31/2099',1,getdate()

Added Wade A. Schwerdtfeger, M.D., Shehan J. Abeywardene, M.D., Nicholas R. Johnson, M.D., Eric B. Johnson, M.D.
insert into map.PracticeDepartments select '0~WAS','5~42501029001','1/1/2021','12/31/2099',1,getdate()
insert into map.PracticeDepartments select '0~SJA','5~42501028001','1/1/2021','12/31/2099',1,getdate()
insert into map.PracticeDepartments select '0~NRJ','5~42501026002','1/1/2021','12/31/2099',1,getdate()
insert into map.PracticeDepartments select '0~NRJ','5~42501026001','1/1/2021','12/31/2099',1,getdate()
insert into map.PracticeDepartments select '0~EBJ','5~42501027001','1/1/2021','12/31/2099',1,getdate()

Added Mac Moore practice dept mapping
insert into map.PracticeDepartments select '0~MEM','5~42501034001','1/1/2021','12/31/2099',1,getdate()
insert into map.PracticeDepartments select '0~MEM','5~42501035001','1/1/2021','12/31/2099',1,getdate()

4/30/2025 - Added new Choctaw department for Shadid
insert into map.PracticeDepartments select '0~SCS','5~42501006002','1/1/2021','12/31/2099',1,getdate(),'0~549'



6/3/2025 - Added new departments for Bevers and Magnusson
insert into map.PracticeDepartments select '0~WSB','5~42501040001','1/1/2021','12/31/2099',1,getdate(),'0~570'
insert into map.PracticeDepartments select '0~JLM','5~42501039001','1/1/2021','12/31/2099',1,getdate(),'0~508'

7/1/2025 - Added new departments for Thomason
insert into map.PracticeDepartments select '0~TDT','5~42501042001','1/1/2021','12/31/2099',1,getdate(),'0~563'
insert into map.PracticeDepartments select '0~TDT','5~42501041001','1/1/2021','12/31/2099',1,getdate(),'0~563'
insert into map.PracticeDepartments select '0~TDT','5~42501043001','1/1/2021','12/31/2099',1,getdate(),'0~563'


10/1/2025 - Added new departments for Hancock
insert into map.PracticeDepartments select '0~RMH','5~42501045001','1/1/2021','12/31/2099',1,getdate(),'0~545'


10/7/2025 - Added new departments for Rian Wilson
insert into map.PracticeDepartments select '0~RDW','5~42501046001','1/1/2021','12/31/2099',1,getdate(),'0~654'


12/1/2025 - Added new departments for Angela Morgan
insert into map.PracticeDepartments select '0~AKM','5~42501047001','1/1/2021','12/31/2099',1,getdate(),'0~324'


2/11/2026 - Added new departments for Sam Nevinson
insert into map.PracticeDepartments select '0~NPS','5~43001070001','1/1/2021','12/31/2099',1,getdate(),'0~532'

2/11/2026 - Added new departments for Shehan J. Abeyewardene, M.D.
insert into map.PracticeDepartments select '0~SJA','5~43001090101','1/1/2021','12/31/2099',1,getdate(),'0~553'

3/31/2026 - Added new departments for Christopher D. Harris
insert into map.PracticeDepartments select '0~CDH','5~45200100101','1/1/2021','12/31/2099',1,getdate(),NULL
insert into map.PracticeDepartments select '0~CDH','5~45200100102','1/1/2021','12/31/2099',1,getdate(),NULL

4/30/2026 - Added new departments for Paul Maitino HPIP
insert into map.PracticeDepartments select '0~PDM','5~43001100101','1/1/2021','12/31/2099',1,getdate(),NULL

7/31/2026 - Added new departments for Christopher S. Hume
insert into map.PracticeDepartments select '0~CSH2','5~42501050001','1/1/2021','12/31/2099',1,getdate(),NULL

7/31/2026 - Added new departments for Erin L.Balzer
insert into map.PracticeDepartments select '0~ELB','5~42501049001','1/1/2021','12/31/2099',1,getdate(),NULL

7/31/2026 - Added new departments for Michael R. Harvey
insert into map.PracticeDepartments select '0~MRH','5~42501048001','1/1/2021','12/31/2099',1,getdate(),NULL



--select * from dim.departments d where d.DepartmentName like '%harvey%'

select * from dim.vPractices p where p.practicename like '%maitino%'
SELECT * FROM map.vPracticeDepartments where practiceid = '0~CSH2'
SELECT * FROM map.vPracticeDepartments where practiceid = '0~ELB'
SELECT * FROM map.vPracticeDepartments where practiceid = '0~MRH'

SELECT * FROM map.vPracticeProviders where practiceid = '0~PDM'
SELECT * FROM map.vPracticeProviders where practiceid = '0~rfh'
SELECT * FROM map.vPracticeProviders where practiceid = '0~nps'

SELECT * FROM map.vPracticeProviders where practiceid = '0~OPCL'

SELECT * FROM rpt.Bluebooks b where b.PracticeID = '0~PDM' and fiscalperiodvalue <> 0
SELECT * FROM rpt.Bluebooks b where b.PracticeID = '0~' and fiscalperiodvalue <> 0
SELECT * FROM rpt.Bluebooks b where b.PracticeID = '0~OPCL' and fiscalperiodvalue <> 0

select * from hpiapp.dbo.Practices p where p.practicename like '%Harris%'

5~43001100101



*/

--select * from map.vPracticeDepartments pd where pd.practiceid = '0~CDH' --pd.DepartmentID in ('5~42501023001')
--select * from dim.departments d where d.DepartmentName like '%HUME%'

--select * from HPIApp.dbo.Practices p where p.PracticeName like '%Nevinson%'


/* Possible INSERT clauses for map.PracticeDepartments for APM 8/27/26
-- TPG Main Clinics & Solo Practices
INSERT INTO map.PracticeDepartments SELECT '0~BEB',   '1~1',   '1/1/2020', '12/31/2099', 1, GETDATE() -- Barney Blue, M.D.
INSERT INTO map.PracticeDepartments SELECT '0~WSB',   '1~3',   '1/1/2020', '12/31/2099', 1, GETDATE() -- William Bevers, M.D.
INSERT INTO map.PracticeDepartments SELECT '0~GPK',   '1~4',   '1/1/2020', '12/31/2099', 1, GETDATE() -- Gregory Kelley, M.D.
INSERT INTO map.PracticeDepartments SELECT '0~RSU',   '1~6',   '1/1/2020', '12/31/2099', 1, GETDATE() -- Robert Unsell, M.D.
INSERT INTO map.PracticeDepartments SELECT '0~DDR',   '1~8',   '1/1/2020', '12/31/2099', 1, GETDATE() -- Darryl Robinson, M.D.
INSERT INTO map.PracticeDepartments SELECT '0~AKM',   '1~9',   '1/1/2020', '12/31/2099', 1, GETDATE() -- Angela Morgan, M.D.
INSERT INTO map.PracticeDepartments SELECT '0~EMK',   '1~10',  '1/1/2020', '12/31/2099', 1, GETDATE() -- Edwin King, M.D. (Fountain Park)
INSERT INTO map.PracticeDepartments SELECT '0~EMK',   '1~25',  '1/1/2020', '12/31/2099', 1, GETDATE() -- Edwin King, M.D. (Fountain Park)
INSERT INTO map.PracticeDepartments SELECT '0~TAK',   '1~16',  '1/1/2020', '12/31/2099', 1, GETDATE() -- Todd Krehbiel, M.D.
INSERT INTO map.PracticeDepartments SELECT '0~TDT',   '1~31',  '1/1/2020', '12/31/2099', 1, GETDATE() -- Trey Thomason, D.O.
INSERT INTO map.PracticeDepartments SELECT '0~RMH',   '1~39',  '1/1/2020', '12/31/2099', 1, GETDATE() -- Rita Hancock, M.D.
INSERT INTO map.PracticeDepartments SELECT '0~NBN',   '1~42',  '1/1/2020', '12/31/2099', 1, GETDATE() -- Ngoc Bao Nguyen, M.D.
INSERT INTO map.PracticeDepartments SELECT '0~LCS',   '1~44',  '1/1/2020', '12/31/2099', 1, GETDATE() -- Lance Smith, M.D.
INSERT INTO map.PracticeDepartments SELECT '0~LBB',   '1~45',  '1/1/2020', '12/31/2099', 1, GETDATE() -- Laura Buford, M.D.
-- Customer / Partner Clinics (DataSource 12)
INSERT INTO map.PracticeDepartments SELECT '0~IFMB',  '12~101', '1/1/2020', '12/31/2099', 1, GETDATE() -- Integris Binger
INSERT INTO map.PracticeDepartments SELECT '0~IFMH',  '12~100', '1/1/2020', '12/31/2099', 1, GETDATE() -- Integris Hinton
INSERT INTO map.PracticeDepartments SELECT '0~IFMH',  '12~125', '1/1/2020', '12/31/2099', 1, GETDATE() -- Integris Hinton
INSERT INTO map.PracticeDepartments SELECT '0~IFMH2', '12~102', '1/1/2020', '12/31/2099', 1, GETDATE() -- Integris Hydro
INSERT INTO map.PracticeDepartments SELECT '0~IFMH2', '12~124', '1/1/2020', '12/31/2099', 1, GETDATE() -- Integris Hydro
INSERT INTO map.PracticeDepartments SELECT '0~CHC',   '12~87',  '1/1/2020', '12/31/2099', 1, GETDATE() -- Community Health Center RHC
INSERT INTO map.PracticeDepartments SELECT '0~CHC',   '12~94',  '1/1/2020', '12/31/2099', 1, GETDATE() -- Community Health Center ER
INSERT INTO map.PracticeDepartments SELECT '0~CHC',   '12~95',  '1/1/2020', '12/31/2099', 1, GETDATE() -- Community Health Center Hosp
INSERT INTO map.PracticeDepartments SELECT '0~SCS',   '12~109', '1/1/2020', '12/31/2099', 1, GETDATE() -- Shadid Choctaw

*/
GO
