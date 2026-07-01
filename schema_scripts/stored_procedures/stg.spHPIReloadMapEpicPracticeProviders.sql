--ALTER PROCEDURE.EpicPracticeProviders
--(
--EpicPracticeProviderID int identity(1,1) not null
--,ProviderID varchar(100)
--,PracticeID varchar(100)
--,EpicPracticeProviderUpdatedDatetime datetime
--)

--SELECT p.ProviderFullName,pp.* FROM map.EpicPracticeProviders pp LEFT JOIN dim.vProviders p ON p.providerid = pp.providerid

CREATE   PROCEDURE [stg].[spHPIReloadMapEpicPracticeProviders] as
/*
TRUNCATE TABLE map.EpicPracticeProviders
INSERT INTO map.EpicPracticeProviders SELECT '5~102495','0~CSH',1,0,1,0,GETDATE() --Provider: HUME, CHRISTOPHER S; Practice: Dr. Christopher Hume
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000509','0~DCH ',1,0,1,0,GETDATE() --Provider: HITT, DARON C; Practice: Dr. Daron Hitt
INSERT INTO map.EpicPracticeProviders SELECT '5~103992','0~MSO',1,0,1,0,GETDATE() --Provider: O'BRIEN, MICHAEL S; Practice: M. Sean O'Brien, D.O.
INSERT INTO map.EpicPracticeProviders SELECT '5~122305','0~PBJ',1,0,1,0,GETDATE() --Provider: OLIVO, KRISTY M; Practice: Paul B. Jacob, D.O.
INSERT INTO map.EpicPracticeProviders SELECT '5~P1007406','0~MEC',1,1,0,0,GETDATE() --Provider: MEIWES, AMBER M; Practice: Ric Corman, M.D.
INSERT INTO map.EpicPracticeProviders SELECT '5~134089','0~BAB',1,0,1,0,GETDATE() --Provider: SHAFER, RYNE; Practice: Brett A. Braly, M.D.
INSERT INTO map.EpicPracticeProviders SELECT '5~109725','0~SCS',1,1,0,0,GETDATE() --Provider: SHADID, STANLEY C; Practice: S. Christopher Shadid, M.D.
INSERT INTO map.EpicPracticeProviders SELECT '5~108149','0~JPN',1,0,1,0,GETDATE() --Provider: NEES, JEFFREY P; Practice: Dr. Jeffrey Nees
INSERT INTO map.EpicPracticeProviders SELECT '5~131966','0~CSH',1,0,0,0,GETDATE() --Provider: MILLER, MATTHEW J; Practice: Dr. Christopher Hume
INSERT INTO map.EpicPracticeProviders SELECT '5~101349','0~MMD',0,0,0,0,GETDATE() --Provider: DIESSELHORST, MATTHEW M; Practice: Matthew M. Diesselhorst, M.D.
INSERT INTO map.EpicPracticeProviders SELECT '5~105864','0~MDW',1,0,1,0,GETDATE() --Provider: WINTERS, MICHAEL D; Practice: Dr. Michael Winters
INSERT INTO map.EpicPracticeProviders SELECT '5~126867','0~CGW',1,0,1,0,GETDATE() --Provider: JAMES, AMY N; Practice: Dr. Clint Wallis
INSERT INTO map.EpicPracticeProviders SELECT '5~105546','0~SCS',1,1,0,0,GETDATE() --Provider: COMBS, LANEY T; Practice: S. Christopher Shadid, M.D.
INSERT INTO map.EpicPracticeProviders SELECT '5~127137','0~NPS',1,0,1,0,GETDATE() --Provider: SAM, NEVINSON P; Practice: Nevinson P. Sam, D.O.
INSERT INTO map.EpicPracticeProviders SELECT '5~102837','0~EKK',1,1,0,0,GETDATE() --Provider: KING, EDWIN KIM; Practice: E. Kim King, D.O.
INSERT INTO map.EpicPracticeProviders SELECT '5~101012','0~ACC',1,0,1,0,GETDATE() --Provider: COGAR, ASHLEY; Practice: Ashley C. Cogar, M.D.
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000468','0~RFH',1,0,1,0,GETDATE() --Provider: HINES, ROBERT F; Practice: Dr. Robert Hines
INSERT INTO map.EpicPracticeProviders SELECT '5~108183','0~BLN',1,0,1,0,GETDATE() --Provider: NORTHCUTT, BARRY L; Practice: Barry L. Northcutt, M.D.
INSERT INTO map.EpicPracticeProviders SELECT '5~121121','0~RLN',1,0,1,0,GETDATE() --Provider: WILLIAMS, MADISON S; Practice: Ryan L. Nelson, D.O.
INSERT INTO map.EpicPracticeProviders SELECT '5~105579','0~CGW',1,0,1,0,GETDATE() --Provider: WALLIS, CLINTON G; Practice: Dr. Clint Wallis
INSERT INTO map.EpicPracticeProviders SELECT '5~109260','0~MEC',1,1,0,0,GETDATE() --Provider: CORMAN III, MAURICE E; Practice: Ric Corman, M.D.
INSERT INTO map.EpicPracticeProviders SELECT '5~119683','0~NMO',1,0,1,0,GETDATE() --Provider: ODOR, NATHANIEL MONNET; Practice: Nathaniel M. Odor, M.D.
INSERT INTO map.EpicPracticeProviders SELECT '5~108509','0~SMS',1,0,1,0,GETDATE() --Provider: SMITH, SHERYL M; Practice: Sheri M. Smith, M.D.
INSERT INTO map.EpicPracticeProviders SELECT '5~103742','0~MEM',1,0,1,0,GETDATE() --Provider: MOORE, MAC E; Practice: Mac E. Moore, M.D.
INSERT INTO map.EpicPracticeProviders SELECT '5~109040','0~THP',1,1,0,0,GETDATE() --Provider: MEREDITH, STEFANIE L; Practice: Total Healthcare Partners
INSERT INTO map.EpicPracticeProviders SELECT '5~125582','0~RLN',1,0,1,0,GETDATE() --Provider: SCARBOROUGH, MURPHI; Practice: Ryan L. Nelson, D.O.
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000090','0~TAK',1,1,0,0,GETDATE() --Provider: KREHBIEL, TODD A; Practice: Todd A. Krehbiel, M.D.
INSERT INTO map.EpicPracticeProviders SELECT '5~136623','0~EXT',1,0,0,0,GETDATE() --Provider: LAZENBY, JOHN; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~109682','0~MBJ',1,0,1,0,GETDATE() --Provider: JOHNSON, MICHAEL B; Practice: M. Brandon Johnson, M.D.
INSERT INTO map.EpicPracticeProviders SELECT '5~107124','0~WSB',1,1,0,0,GETDATE() --Provider: BEVERS, WILLIAM S; Practice: W. Stan Bevers, M.D.
INSERT INTO map.EpicPracticeProviders SELECT '5~109977','0~BAB',1,0,1,0,GETDATE() --Provider: BRALY, BRETT A; Practice: Brett A. Braly, M.D.
INSERT INTO map.EpicPracticeProviders SELECT '5~125176','0~MBJ',1,0,1,0,GETDATE() --Provider: HIGGINBOTHAM, SARAH M; Practice: M. Brandon Johnson, M.D.
INSERT INTO map.EpicPracticeProviders SELECT '5~109511','0~EXT',0,0,0,0,GETDATE() --Provider: PROVIDER NOT IN SYSTEM; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~102862','0~LAK',1,1,0,0,GETDATE() --Provider: KIRSCH, LEE A; Practice: Lee A. Kirsch, D.O.
INSERT INTO map.EpicPracticeProviders SELECT '5~103885','0~RLN',1,0,1,0,GETDATE() --Provider: NELSON, RYAN L; Practice: Ryan L. Nelson, D.O.
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008822','0~JPN',1,0,1,0,GETDATE() --Provider: ANDERSON, KOBY; Practice: Dr. Jeffrey Nees
INSERT INTO map.EpicPracticeProviders SELECT '5~114334','0~MSO',1,0,1,0,GETDATE() --Provider: STANCLIFF, MICHAEL J; Practice: M. Sean O'Brien, D.O.
INSERT INTO map.EpicPracticeProviders SELECT '5~132626','0~RGS',1,0,1,0,GETDATE() --Provider: STEINMETZ, RAYMOND G; Practice: R. Garrett Steinmetz, M.D.
INSERT INTO map.EpicPracticeProviders SELECT '5~102536','0~THP',1,1,0,0,GETDATE() --Provider: INGRAM, RUSSELL D; Practice: Total Healthcare Partners
INSERT INTO map.EpicPracticeProviders SELECT '5~107959','0~JLM',1,1,0,0,GETDATE() --Provider: MAGNUSSON, JUDY L; Practice: Judy L. Magnusson, M.D.
INSERT INTO map.EpicPracticeProviders SELECT '5~105130','0~EXT',1,0,0,1,GETDATE() --Provider: STEVENS, QUALLS E; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~109844','0~PBJ',1,0,1,0,GETDATE() --Provider: JACOB, PAUL B; Practice: Paul B. Jacob, D.O.
INSERT INTO map.EpicPracticeProviders SELECT '5~P1005646','0~LRL',1,0,1,0,GETDATE() --Provider: LUICK, LAURA RUTH; Practice: Laura R. Luick, M.D.
INSERT INTO map.EpicPracticeProviders SELECT '5~123179','0~ADB',1,0,1,0,GETDATE() --Provider: WRAY, ANDREA MICHELLE; Practice: Dr. A. Doug Beacham
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000856','0~THP',1,1,0,0,GETDATE() --Provider: LISLE, STUART JOSEPH; Practice: Total Healthcare Partners
INSERT INTO map.EpicPracticeProviders SELECT '5~122551','0~BET',1,1,0,0,GETDATE() --Provider: THATCHER, BRIAN E; Practice: Brian Thatcher, M.D.
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001334','0~RSU',1,0,1,0,GETDATE() --Provider: UNSELL, ROBERT S; Practice: Robert S. Unsell, M.D.
INSERT INTO map.EpicPracticeProviders SELECT '5~103250','0~EXT',1,0,0,1,GETDATE() --Provider: MAITINO, PAUL D; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~120997','0~PBJ',1,0,1,0,GETDATE() --Provider: DUNKLEBERGER, LLOYD S; Practice: Paul B. Jacob, D.O.
INSERT INTO map.EpicPracticeProviders SELECT '5~102785','0~GPK',1,1,0,0,GETDATE() --Provider: KELLEY, GREGORY P; Practice: Gregory P. Kelley, M.D.
INSERT INTO map.EpicPracticeProviders SELECT '5~108021','0~THP',1,1,0,0,GETDATE() --Provider: MCCOY, WADE T; Practice: Total Healthcare Partners
INSERT INTO map.EpicPracticeProviders SELECT '5~110422','0~DDR',1,0,1,0,GETDATE() --Provider: ROBINSON, DARRYL D; Practice: Darryl D. Robinson, M.D.
INSERT INTO map.EpicPracticeProviders SELECT '5~119924','0~THP',1,1,0,0,GETDATE() --Provider: DREIER, ANTON; Practice: Total Healthcare Partners
INSERT INTO map.EpicPracticeProviders SELECT '5~107829','0~LLK',1,1,0,0,GETDATE() --Provider: KILKENNY, LAURA, L; Practice: Laura L. Kilkenny, M.D.
INSERT INTO map.EpicPracticeProviders SELECT '5~100659','0~THP',1,1,0,0,GETDATE() --Provider: BROWN, STEVEN D; Practice: Total Healthcare Partners
INSERT INTO map.EpicPracticeProviders SELECT '5~121719','0~EXT',1,0,0,0,GETDATE() --Provider: STEWART, KATRINA; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~100628','0~EXT',1,0,0,0,GETDATE() --Provider: BROWN, CURTIS L; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~100246','0~THP',1,0,0,0,GETDATE() --Provider: BAKER, DUSTIN R; Practice: Total Healthcare Partners
INSERT INTO map.EpicPracticeProviders SELECT '5~103755','0~AKM',1,0,0,0,GETDATE() --Provider: MORGAN, ANGELA K; Practice: Angela K. Morgan, M.D.
INSERT INTO map.EpicPracticeProviders SELECT '5~P1011819','0~LCS',1,0,1,0,GETDATE() --Provider: RAMER, TODD J; Practice: Lance C. Smith, M.D.
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000554','0~ADB',1,0,1,0,GETDATE() --Provider: BEACHAM III, ARTHUR DOUGLAS; Practice: Dr. A. Doug Beacham
INSERT INTO map.EpicPracticeProviders SELECT '5~100617','0~THP',1,1,0,0,GETDATE() --Provider: BROOME, JOSEPH C; Practice: Total Healthcare Partners
INSERT INTO map.EpicPracticeProviders SELECT '5~102378','0~EXT',0,0,0,0,GETDATE() --Provider: HOLLINGSWORTH, KYLE; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~107898','0~DDR',1,0,1,0,GETDATE() --Provider: LEINEN, JASON M; Practice: Darryl D. Robinson, M.D.
INSERT INTO map.EpicPracticeProviders SELECT '5~P1004114','0~EXT',1,0,0,1,GETDATE() --Provider: PIERSON, BRANDON W; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~100636','0~EXT',1,0,0,0,GETDATE() --Provider: BROWN, JAMES M; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~129276','0~EXT',1,0,0,0,GETDATE() --Provider: SALOUS, AHMED S; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~102218','0~EXT',1,0,0,0,GETDATE() --Provider: HAYES, CHRISTOPHER D; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1024887','0~MBJ',1,0,0,0,GETDATE() --Provider: YINGLING, JILL; Practice: M. Brandon Johnson, M.D.
INSERT INTO map.EpicPracticeProviders SELECT '5~123372','0~SMS',1,0,1,0,GETDATE() --Provider: BURNS, JENNIFER M; Practice: Sheri M. Smith, M.D.
INSERT INTO map.EpicPracticeProviders SELECT '5~112659','0~THP',1,1,0,0,GETDATE() --Provider: GORACKE, HOLLY A; Practice: Total Healthcare Partners
INSERT INTO map.EpicPracticeProviders SELECT '5~124194','0~EXT',1,0,0,1,GETDATE() --Provider: COLLINS, BENJAMIN A; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000829','0~LCS',1,0,1,0,GETDATE() --Provider: SMITH, LANCE CRAIG; Practice: Lance C. Smith, M.D.
INSERT INTO map.EpicPracticeProviders SELECT '5~100396','0~EXT',1,0,0,1,GETDATE() --Provider: BERRYHILL, WAYNE E; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~121041','0~CAH',1,0,1,0,GETDATE() --Provider: HOGAN, CHARLES A; Practice: Charles A. Hogan, M.D.
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001061','0~TDT',1,1,0,0,GETDATE() --Provider: THOMASON, TREY; Practice: Thomason Medical Clinic
INSERT INTO map.EpicPracticeProviders SELECT '5~104608','0~THP',1,1,0,0,GETDATE() --Provider: ROTHWELL, PAUL D; Practice: Total Healthcare Partners
INSERT INTO map.EpicPracticeProviders SELECT '5~114057','0~ACC',1,0,1,0,GETDATE() --Provider: BALL, AUDRA S; Practice: Ashley C. Cogar, M.D.
INSERT INTO map.EpicPracticeProviders SELECT '5~104092','0~PBJ',1,0,1,0,GETDATE() --Provider: PAPE, RANDALL A; Practice: Paul B. Jacob, D.O.
INSERT INTO map.EpicPracticeProviders SELECT '5~104125','0~BAB',1,0,1,0,GETDATE() --Provider: CLORAN, SHAILYNNE ESTELLE; Practice: Brett A. Braly, M.D.
INSERT INTO map.EpicPracticeProviders SELECT '5~127870','0~SCS',1,1,0,0,GETDATE() --Provider: PFAFF, KARLEE; Practice: S. Christopher Shadid, M.D.
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001645','0~THP',1,1,0,0,GETDATE() --Provider: STURLIN, CANDACE L; Practice: Total Healthcare Partners
INSERT INTO map.EpicPracticeProviders SELECT '5~103039','0~EXT',1,0,0,1,GETDATE() --Provider: LE, HAMILTON; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~117670','0~SCS',1,1,0,0,GETDATE() --Provider: ROBERTS, KIMBERLY SUZANNE; Practice: S. Christopher Shadid, M.D.
INSERT INTO map.EpicPracticeProviders SELECT '5~105803','0~EXT',1,0,0,1,GETDATE() --Provider: WILLIAMS, NOEL R; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~103228','0~EXT',1,0,0,0,GETDATE() --Provider: MACKEY, BRUCE A; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~101623','0~THP',1,1,0,0,GETDATE() --Provider: FISHER, DAVID E; Practice: Total Healthcare Partners
INSERT INTO map.EpicPracticeProviders SELECT '5~107789','0~PAK',1,0,1,0,GETDATE() --Provider: KAMMERLOCHER, PAUL A; Practice: Paul A. Kammerlocher, M.D.
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000375','0~EXT',1,0,0,0,GETDATE() --Provider: PARMELEE, JOHN KENNETH; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~105386','0~EXT',0,0,0,0,GETDATE() --Provider: TOMA, ALEDA A; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~117296','0~EXT',0,0,0,0,GETDATE() --Provider: TORRES COONS, MELISSA LUCIA; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~102065','0~EXT',1,0,0,1,GETDATE() --Provider: HAGOOD, BRADY S; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~127740','0~EXT',0,0,0,0,GETDATE() --Provider: DEWINDT, DOUGLAS; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~102022','0~EXT',1,0,0,0,GETDATE() --Provider: GRUBBS, JOEL S; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~109411','0~EXT',1,0,0,0,GETDATE() --Provider: ROOF, LINDSAY K; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~103999','0~EXT',1,0,0,0,GETDATE() --Provider: O'CONNOR, HELEN DIANA; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~130928','0~EXT',1,0,0,0,GETDATE() --Provider: BARNES, CHRISTYN R; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~109445','0~EXT',1,0,0,0,GETDATE() --Provider: STEPP JR, ROBERT G; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1026781','0~EXT',1,0,0,0,GETDATE() --Provider: TIPPY, CHRISTINA; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~117998','0~EXT',1,0,0,0,GETDATE() --Provider: ESTEP, RANDEL DEAN; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1026813','0~EXT',1,0,0,0,GETDATE() --Provider: ICE, JAMES; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000368','0~EXT',1,0,0,0,GETDATE() --Provider: WALKER, JERAMIAH LOUIS; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~104505','0~EXT',0,0,0,0,GETDATE() --Provider: RIDDLE, DOUGLAS R; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~123258','0~EXT',1,0,0,0,GETDATE() --Provider: KUPIEC II, THOMAS C; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~107504','0~EXT',1,0,0,0,GETDATE() --Provider: FOWLER, JOEY D; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~125683','0~EXT',1,0,0,0,GETDATE() --Provider: HILL, COLIN G; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~134108','0~EXT',1,0,0,0,GETDATE() --Provider: BENAVIDES, ANALEE LIZZETTE; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~105747','0~EXT',1,0,0,0,GETDATE() --Provider: WILBANKS, AARON P; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~123660','0~LCS',1,0,1,0,GETDATE() --Provider: HOSKINS, JOSEPH; Practice: Lance C. Smith, M.D.
INSERT INTO map.EpicPracticeProviders SELECT '5~P1027231','0~AKM',1,1,0,0,GETDATE() --Provider: FITZPATRICK, TAYLOR C; Practice: Angela K. Morgan, M.D.
INSERT INTO map.EpicPracticeProviders SELECT '5~P1013388','0~EXT',1,0,0,0,GETDATE() --Provider: BROOKS, DUSTIN COREY; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1018101','0~EXT',1,0,0,1,GETDATE() --Provider: GOETZINGER, JOHN; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~107651','0~EXT',1,0,0,1,GETDATE() --Provider: HEINLEN, LATISHA D; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~100467','0~BEB',1,1,0,0,GETDATE() --Provider: BLUE, BARNEY E; Practice: Barney E. Blue, M.D.
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001814','0~EXT',1,0,0,0,GETDATE() --Provider: WRIGHT, GARRETT KEITH; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000074','0~RSG',1,1,0,0,GETDATE() --Provider: SPENCER, ROBERT G; Practice: Robert G. Spencer, M.D.
INSERT INTO map.EpicPracticeProviders SELECT '5~102771','0~EXT',1,0,0,0,GETDATE() --Provider: KAZENSKE, FAUSTINO M; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~105988','0~EXT',1,0,0,1,GETDATE() --Provider: ZEIDERS, GREGORY J; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~115463','0~EXT',0,0,0,0,GETDATE() --Provider: HOPKINS, JEFFREY ALAN; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~107978','0~EXT',1,0,0,0,GETDATE() --Provider: MARSHALL, MELANIE R; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~105623','0~EXT',1,0,0,0,GETDATE() --Provider: WATKINS, RICHARD D; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001854','0~EXT',1,0,0,1,GETDATE() --Provider: OBLANDER, AMANDA; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~108377','0~EXT',1,0,0,0,GETDATE() --Provider: ROSS, DEAN L; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~105641','0~EXT',0,0,0,0,GETDATE() --Provider: WAYMAN, MISTY L; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001168','0~EXT',1,0,0,0,GETDATE() --Provider: FREDERICK, JEFFREY ALAN; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~101082','0~EXT',1,0,0,1,GETDATE() --Provider: COOK, SHON W; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~104436','0~EXT',0,0,0,0,GETDATE() --Provider: REED, EMILY; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~109442','0~EXT',1,0,0,0,GETDATE() --Provider: STANFIELD, C BLAKE; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~102057','0~LCS',1,0,1,0,GETDATE() --Provider: HADDOCK, DAVID S; Practice: Lance C. Smith, M.D.
INSERT INTO map.EpicPracticeProviders SELECT '5~100214','0~EXT',1,0,0,0,GETDATE() --Provider: AVANT, KRISTOPHER; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~109323','0~EXT',0,0,0,0,GETDATE() --Provider: JACKSON, RHETT L; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000562','0~EXT',0,0,0,0,GETDATE() --Provider: CLICK, RUSSELL CRAIG; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~104006','0~EXT',1,0,0,0,GETDATE() --Provider: ODOR, JAMES M; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1026737','0~EXT',1,0,0,0,GETDATE() --Provider: RAMSEY, DELANA; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~104490','0~EXT',1,0,0,0,GETDATE() --Provider: RICHARDS, STEVEN V; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~103722','0~EXT',1,0,0,0,GETDATE() --Provider: MONTGOMERY, ELIZABETH J; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~107034','0~EXT',1,0,0,0,GETDATE() --Provider: ANDERSON, SERENA S; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1004790','0~EXT',1,0,0,1,GETDATE() --Provider: ENIX, JESSICA L; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1017895','0~TDT',1,1,0,0,GETDATE() --Provider: DAUGHERTY, BAILEY MARIE; Practice: Thomason Medical Clinic
INSERT INTO map.EpicPracticeProviders SELECT '5~105263','0~EXT',1,0,0,1,GETDATE() --Provider: TAYLOR, STEPHANIE L; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~108957','0~EXT',0,0,0,0,GETDATE() --Provider: FAULKNER, REBECCA A; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~128776','0~EXT',0,0,0,0,GETDATE() --Provider: SEARS, RACHEL ELIZABETH; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~115002','0~EXT',1,0,0,1,GETDATE() --Provider: BARENBERG, BENJAMIN; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~112375','0~EXT',0,0,0,0,GETDATE() --Provider: KENDRICK, MARY S; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~107093','0~EXT',1,0,0,0,GETDATE() --Provider: BARRY, CHRISTOPHER J; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1007297','0~EXT',1,0,0,0,GETDATE() --Provider: EDERER, AUSTIN KURT; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~129229','0~EXT',1,0,0,0,GETDATE() --Provider: STEELE, CAMERON P; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~107024','0~EXT',0,0,0,1,GETDATE() --Provider: ALVIS, JAMES M; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~126560','0~EXT',1,0,0,0,GETDATE() --Provider: MORAN, ADAM; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~109482','0~EXT',0,0,0,0,GETDATE() --Provider: WAUGH, ASHLEE M; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1030614','0~EXT',1,0,0,0,GETDATE() --Provider: COMPTON, CENA; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1025332','0~EXT',1,0,0,0,GETDATE() --Provider: CRAIG, LINDSEY J; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~136746','0~EXT',1,0,0,0,GETDATE() --Provider: GRUDE, BONNIE NADAENE; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~108721','0~EXT',1,0,0,0,GETDATE() --Provider: WHEELER, HEATHER NICOLE; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~101260','0~EXT',1,0,0,1,GETDATE() --Provider: WILSON, DAWN RACHELLE; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~108060','0~EXT',1,0,0,0,GETDATE() --Provider: MEYER HANNER, MEGAN, D; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~110696','0~EXT',1,0,0,1,GETDATE() --Provider: STONE, JONATHAN B; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~121783','0~EXT',0,0,0,0,GETDATE() --Provider: KUMAR, ANJAN; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1005827','0~EXT',1,0,0,0,GETDATE() --Provider: FREELAND, BRIAN PAUL; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~107844','0~EXT',0,0,0,0,GETDATE() --Provider: KIRKENDALL, KENAN L; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~105039','0~EXT',1,0,0,0,GETDATE() --Provider: SPARKES, JUSTIN S; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1003804','0~EXT',0,0,0,0,GETDATE() --Provider: WEST, LISA DANETTE; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~103651','0~EXT',1,0,0,0,GETDATE() --Provider: MILLER, JEFFREY A; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~109225','0~EXT',0,0,0,0,GETDATE() --Provider: BARRETO, ANGELIQUE; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~102521','0~EXT',0,0,0,0,GETDATE() --Provider: HYDE, GLEN D; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~105859','0~EXT',1,0,0,0,GETDATE() --Provider: WINSLOW, CLINTON A; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~119172','0~TDT',1,1,0,0,GETDATE() --Provider: MOSS, DANIELLE MARIE; Practice: Thomason Medical Clinic
INSERT INTO map.EpicPracticeProviders SELECT '5~114273','0~EXT',0,0,0,0,GETDATE() --Provider: MILLER, SHANNON R; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~104886','0~EXT',1,0,0,0,GETDATE() --Provider: SIEMS, AMI L; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000785','0~RMH',1,0,1,0,GETDATE() --Provider: HANCOCK, RITA MALVASO; Practice: Rita M. Hancock, M.D.
INSERT INTO map.EpicPracticeProviders SELECT '5~P1010261','0~EXT',1,0,0,0,GETDATE() --Provider: BARTHOLOMEW, JOANNA; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~107532','0~EXT',1,0,0,0,GETDATE() --Provider: GALLEGOS, LOAHN; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000567','0~EXT',0,0,0,0,GETDATE() --Provider: MENZ, GEORGE DOUGLAS; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1025178','0~EXT',1,0,0,0,GETDATE() --Provider: PASSMORE, TERESA L; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1010624','0~EXT',1,0,0,0,GETDATE() --Provider: RAWDON, JOSEPH C; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~101006','0~EXT',1,0,0,0,GETDATE() --Provider: CODDING, CHRISTINE E; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~101098','0~EXT',0,0,0,0,GETDATE() --Provider: CORBISHLEY, ANDREA M; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~127424','0~EXT',1,0,0,1,GETDATE() --Provider: FELARCA, CHRISTINA M; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~109145','0~EXT',1,0,0,0,GETDATE() --Provider: WONG, GRAND F; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001768','0~EXT',0,0,0,0,GETDATE() --Provider: CHEATWOOD, JEREMY S; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~102198','0~EXT',1,0,0,0,GETDATE() --Provider: HASSELL, SCOTT; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000104','0~EXT',0,0,0,0,GETDATE() --Provider: KNOX, J MARK; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~127425','0~EXT',0,0,0,0,GETDATE() --Provider: PANNELL, JENNIFER LYNN; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000550','0~EXT',1,0,0,0,GETDATE() --Provider: PARKS, WENDY; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~108327','0~EXT',0,0,0,0,GETDATE() --Provider: REYNOLDS, ROBERT E; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~105983','0~EXT',0,0,0,0,GETDATE() --Provider: ZACHARIAS, LINDA A; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~117700','0~EXT',1,0,0,0,GETDATE() --Provider: AHMAD, MOHSIN; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1004462','0~EXT',0,0,0,0,GETDATE() --Provider: HACKER, DAWN MARIE; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1030506','0~EXT',0,0,0,0,GETDATE() --Provider: MILLER, LAURA B; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~104462','0~EXT',1,0,0,0,GETDATE() --Provider: REMONDINO, ROBERT L; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~123300','0~EXT',0,0,0,0,GETDATE() --Provider: WEBB, KATIE L; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~107806','0~EXT',0,0,0,0,GETDATE() --Provider: KELLY, STEPHEN B; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~100498','0~EXT',0,0,0,0,GETDATE() --Provider: BONDURANT, WILLIAM L; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~130208','0~TDT',0,0,0,0,GETDATE() --Provider: DAHLENBURG, KENADEY; Practice: Thomason Medical Clinic
INSERT INTO map.EpicPracticeProviders SELECT '5~104244','0~EXT',1,0,0,0,GETDATE() --Provider: PIRTLE, HAYELI D; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~130718','0~EXT',0,0,0,0,GETDATE() --Provider: WARFORD, TRAVIS; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108511','0~EXT',1,0,0,0,GETDATE() --Provider: SNELL, BRIAN E; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~102145','0~EXT',1,0,0,0,GETDATE() --Provider: HARGROVE, KEVIN W; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~108714','0~EXT',0,0,0,0,GETDATE() --Provider: WEST, DEREK L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101141','0~EXT',0,0,0,0,GETDATE() --Provider: COYNER-GREGORY, CHARLOTTE A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107689','0~EXT',0,0,0,0,GETDATE() --Provider: HIRSCH, JEFFREY G; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109372','0~EXT',1,0,0,0,GETDATE() --Provider: MORGAN, RICHARD R; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~102997','0~EXT',1,0,0,0,GETDATE() --Provider: LANGERMAN JR, RICHARD J; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000082','0~EXT',1,0,0,0,GETDATE() --Provider: HAHN, MICHAEL R; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~113573','0~EXT',0,0,0,0,GETDATE() --Provider: RANDALL, STEVE E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002020','0~EXT',0,0,0,0,GETDATE() --Provider: AUSTIN, MATTHEW B; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002381','0~EXT',1,0,0,1,GETDATE() --Provider: CARMOUCHE, SHANNAN LEE; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001821','0~EXT',0,0,0,0,GETDATE() --Provider: HOLLIMAN, BRENT KEITH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114212','0~EXT',1,0,0,0,GETDATE() --Provider: KRITTENBRINK, ANDREA L; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000157','0~EXT',0,0,0,0,GETDATE() --Provider: SCHLINKE, SHAWN C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109788','0~EXT',0,0,0,0,GETDATE() --Provider: VO, LOUISE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~119425','0~EXT',0,0,0,0,GETDATE() --Provider: WEAVER, CHRISTINA LOUISE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104280','0~EXT',1,0,0,0,GETDATE() --Provider: PORTER, JUSTIN R; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~102302','0~EXT',1,0,0,0,GETDATE() --Provider: HICKSON III, JOHNNY D; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001014','0~EXT',1,0,0,1,GETDATE() --Provider: TITUS, AMANDA; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~100120','0~EXT',0,0,0,0,GETDATE() --Provider: AMUNDSEN II, GERALD A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109798','0~EXT',0,0,0,0,GETDATE() --Provider: GARNER, JENNIFER G; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000986','0~EXT',1,0,0,0,GETDATE() --Provider: GORTON, JORGE ALLEN; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~130816','0~EXT',0,0,0,0,GETDATE() --Provider: HAWORTH, KELLI A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104428','0~EXT',0,0,0,0,GETDATE() --Provider: REDDEN, CHRISTOPHER B; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103098','0~EXT',1,0,0,0,GETDATE() --Provider: LEVINGS, BRIAN A; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1004290','0~EXT',0,0,0,0,GETDATE() --Provider: KOENIG, BRANT THOMAS; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1021317','0~EXT',0,0,0,0,GETDATE() --Provider: ROACH, LACEY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101060','0~TCC',1,0,1,0,GETDATE() --Provider: CONIGLIONE, THOMAS C; Practice: Dr. Thomas Coniglione
INSERT INTO map.EpicPracticeProviders SELECT '5~P1005020','0~EXT',0,0,0,0,GETDATE() --Provider: COOPER, PAUL BRANDON; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~119376','0~EXT',0,0,0,0,GETDATE() --Provider: FRENCH, RYAN JAMES; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114233','0~EXT',0,0,0,0,GETDATE() --Provider: LOFTIS, MELISSA A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114276','0~EXT',0,0,0,0,GETDATE() --Provider: MINER, THERESE D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108383','0~EXT',0,0,0,0,GETDATE() --Provider: ROYDER, CLAYTON H; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000170','0~EXT',1,0,0,0,GETDATE() --Provider: SAMUEL, JESSE; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~109757','0~EXT',1,0,0,0,GETDATE() --Provider: SHAH, GARGI; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1005042','0~EXT',0,0,0,0,GETDATE() --Provider: TROOP, JOEL KEITH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104248','0~EXT',0,0,0,0,GETDATE() --Provider: PITMAN, GABRIEL M; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1009757','0~EXT',0,0,0,0,GETDATE() --Provider: AKRAM, BUSHRA; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~105363','0~EXT',0,0,0,0,GETDATE() --Provider: TIBBS, ROBERT E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113060','0~EXT',0,0,0,0,GETDATE() --Provider: ALDRICH, RYAN K; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100089','0~EXT',0,0,0,0,GETDATE() --Provider: ALLEN, HENRY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001909','0~EXT',1,0,0,0,GETDATE() --Provider: BALZER, ERIN LEIGH; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~111741','0~EXT',1,0,0,0,GETDATE() --Provider: BROCK, RICHARD D; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~107335','0~EXT',0,0,0,0,GETDATE() --Provider: CRAIG-GOODELL, CHESCA D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107445','0~EXT',0,0,0,0,GETDATE() --Provider: EMERSON, JASON C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101722','0~EXT',0,0,0,0,GETDATE() --Provider: FRENCH, KYLE B; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1017045','0~EXT',0,0,0,0,GETDATE() --Provider: GRAY, MALLORY JO; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~132363','0~EXT',0,0,0,0,GETDATE() --Provider: GREEN, JAMES C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~102267','0~EXT',0,0,0,0,GETDATE() --Provider: HENDERSON, SARAH K; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114220','0~THP',1,1,0,0,GETDATE() --Provider: LAMB, JEREMY B; Practice: Total Healthcare Partners
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001394','0~EXT',1,0,0,0,GETDATE() --Provider: MCCARGO, ASHLEY DAWN; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~108030','0~EXT',1,0,0,0,GETDATE() --Provider: MCGHEE, PHILLIP A; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~104842','0~EXT',0,0,0,0,GETDATE() --Provider: SHEPHERD, JAYNA N; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1021403','0~EXT',0,0,0,0,GETDATE() --Provider: SMITH, ANDREA LYNN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105274','0~EXT',1,0,0,1,GETDATE() --Provider: TELCOCCI, CHRISTINA; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~126836','0~EXT',0,0,0,0,GETDATE() --Provider: WADE, AARON CLAY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108139','0~EXT',0,0,0,0,GETDATE() --Provider: NASR, FADI F; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000672','0~EXT',0,0,0,0,GETDATE() --Provider: COX, JOSEPH BRIDGER; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1027452','0~EXT',0,0,0,0,GETDATE() --Provider: PORRITT, ERIC; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110824','0~EXT',0,0,0,0,GETDATE() --Provider: BIGGERS, RYAN M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100742','0~EXT',1,0,0,0,GETDATE() --Provider: CABRERA, BRITTANY F; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~101875','0~EXT',1,0,0,0,GETDATE() --Provider: GLASGOW, ERIN K; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~114769','0~EXT',0,0,0,0,GETDATE() --Provider: JOHNSON, JAMES CALVIN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109349','0~EXT',0,0,0,0,GETDATE() --Provider: LOFGREN, KATHRYN JANE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001968','0~EXT',0,0,0,0,GETDATE() --Provider: WAUGH III, WALTER SCOTT; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001228','0~EXT',0,0,0,0,GETDATE() --Provider: STEPHENS, JAMES W; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~113368','0~EXT',1,0,0,0,GETDATE() --Provider: GERMAN, ROBERT A; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~107166','0~EXT',0,0,0,0,GETDATE() --Provider: BREEDLOVE, ERIKA E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000235','0~EXT',0,0,0,0,GETDATE() --Provider: CAMERON, RACHEL MARIE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107258','0~EXT',0,0,0,0,GETDATE() --Provider: CHAN, PETER P; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~130587','0~EXT',1,0,0,1,GETDATE() --Provider: DANG, PHONG T; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~102082','0~EXT',1,0,0,1,GETDATE() --Provider: HALL, PATRICIA; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1028214','0~EXT',1,0,0,0,GETDATE() --Provider: HELTON, BRADLEY; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000262','0~EXT',0,0,0,0,GETDATE() --Provider: JOHNSON, DAVID A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~102924','0~EXT',1,0,0,0,GETDATE() --Provider: KRISHNAN, PREETHI S; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~108167','0~EXT',1,0,0,0,GETDATE() --Provider: NGUYEN, ERIN N; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~109419','0~EXT',0,0,0,0,GETDATE() --Provider: SABINE, JEFFREY L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1013911','0~EXT',1,0,0,0,GETDATE() --Provider: WEBB, SAMAREA D; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~105740','0~EXT',0,0,0,0,GETDATE() --Provider: WIENECKE, ROBERT J; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~102391','0~EXT',1,0,0,1,GETDATE() --Provider: HOLZER, MICHAEL S; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~108258','0~EXT',0,0,0,0,GETDATE() --Provider: PINAROC, NESTOR M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100570','0~EXT',1,0,0,0,GETDATE() --Provider: BRANTLEY, STEVEN P; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000081','0~EXT',0,0,0,0,GETDATE() --Provider: JACKSON, INGRID WORRELL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000265','0~EXT',1,0,0,0,GETDATE() --Provider: KAMMERER, BRANDI; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1005560','0~EXT',0,0,0,0,GETDATE() --Provider: PHILLIPS, KENDALL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108548','0~EXT',0,0,0,0,GETDATE() --Provider: STOCKTON, DARIN K; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008482','0~EXT',0,0,0,0,GETDATE() --Provider: WAGSTAFF, TAMMY L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108726','0~EXT',0,0,0,0,GETDATE() --Provider: WHITE, BENJAMIN T; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1006419','0~EXT',1,0,0,0,GETDATE() --Provider: SMITH, CASSIE MARIE; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~105552','0~EXT',0,0,0,0,GETDATE() --Provider: WALIA, ATUL A; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002002','0~EXT',0,0,0,0,GETDATE() --Provider: SAVAGE, ADAM MICHAEL; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~122252','0~EXT',0,0,0,0,GETDATE() --Provider: RHODES, DAVID A; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~109262','0~EXT',0,0,0,0,GETDATE() --Provider: COX, DEMETRA G; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107707','0~EXT',0,0,0,0,GETDATE() --Provider: HOLLRAH, DAVID N; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1013727','0~EXT',1,0,0,0,GETDATE() --Provider: ILAOA, ISAAC; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~103103','0~EXT',0,0,0,0,GETDATE() --Provider: LEWIS, KORI; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1015003','0~EXT',0,0,0,0,GETDATE() --Provider: ODONNELL, REBECCA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114955','0~EXT',1,0,0,0,GETDATE() --Provider: PADILLA, MICHAEL ANTHONY; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1027322','0~EXT',0,0,0,0,GETDATE() --Provider: RAU, DANIEL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109724','0~EXT',1,0,0,0,GETDATE() --Provider: SEMORE, JENNIFER; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~108554','0~EXT',0,0,0,0,GETDATE() --Provider: STOUT, DARREL L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000827','0~EXT',0,0,0,0,GETDATE() --Provider: TRAN, TUNG MINH B; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002922','0~EXT',0,0,0,0,GETDATE() --Provider: VISCARRA, SARAH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001672','0~EXT',0,0,0,0,GETDATE() --Provider: CHRISTENSEN, BLAKE D; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~135863','0~EXT',0,0,0,0,GETDATE() --Provider: ARCHER, JACOB; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~124396','0~EXT',1,0,0,0,GETDATE() --Provider: MYRIN, GERARDO M; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001065','0~EXT',0,0,0,0,GETDATE() --Provider: PICKRELL, MICHAEL B; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~107092','0~EXT',1,0,0,0,GETDATE() --Provider: BARRETT, REBECCA L; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~109271','0~EXT',0,0,0,0,GETDATE() --Provider: DECK III, LAWRENCE V; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101439','0~EXT',0,0,0,0,GETDATE() --Provider: DUREN, KELLY L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1012405','0~EXT',0,0,0,0,GETDATE() --Provider: ESTRADA, EVODIO HECTOR; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101569','0~EXT',0,0,0,0,GETDATE() --Provider: FANNING, JANET L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101676','0~EXT',0,0,0,0,GETDATE() --Provider: FOSTER, DARLENE K; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~115091','0~EXT',0,0,0,0,GETDATE() --Provider: GOODWIN CHAMBERS, SHANNON BETH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~120908','0~EXT',1,0,0,0,GETDATE() --Provider: JOSEPH, MARY ANN; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~102808','0~EXT',1,0,0,0,GETDATE() --Provider: KESINGER, ADRIENNE; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~104595','0~EXT',1,0,0,1,GETDATE() --Provider: KRAHL, ABBEY R; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~128359','0~EXT',1,0,0,0,GETDATE() --Provider: LANE, KATHRYN LYNN; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~109389','0~EXT',1,0,0,0,GETDATE() --Provider: MARKLAND, CASEY L; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000052','0~EXT',0,0,0,0,GETDATE() --Provider: NAIDU, SACHIDANANDAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112413','0~EXT',0,0,0,0,GETDATE() --Provider: PASCUAL CHAGMAN, VICTOR E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109390','0~EXT',0,0,0,0,GETDATE() --Provider: PHAM, DANIEL H; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113521','0~EXT',1,0,0,0,GETDATE() --Provider: POTTHOFF, BRYAN; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~126060','0~EXT',0,0,0,0,GETDATE() --Provider: PREWITT, JONATHAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105026','0~EXT',1,0,0,0,GETDATE() --Provider: SOO, CHENG-LUN; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1003227','0~EXT',0,0,0,0,GETDATE() --Provider: WALKER, AMY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101658','0~EXT',0,0,0,0,GETDATE() --Provider: FONG, WINSTON; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~131398','0~EXT',0,0,0,0,GETDATE() --Provider: STEPANOVICH, BLAKE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~130422','0~EXT',0,0,0,0,GETDATE() --Provider: MOORE, JEFFERY A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100584','0~EXT',1,0,0,0,GETDATE() --Provider: BREED, JASON S; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~119923','0~EXT',0,0,0,0,GETDATE() --Provider: BUZZARD, KRISTEN R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112424','0~EXT',0,0,0,0,GETDATE() --Provider: CAIL, MELINDA J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000846','0~EXT',0,0,0,0,GETDATE() --Provider: CRABTREE, TINA MARIE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109655','0~EXT',1,0,0,0,GETDATE() --Provider: FILKINS, MEGAN D; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~121016','0~EXT',0,0,0,0,GETDATE() --Provider: FISHER, BRANDI; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109559','0~EXT',1,0,0,0,GETDATE() --Provider: GARCIA, ANA K; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1025288','0~EXT',0,0,0,0,GETDATE() --Provider: HARRIS, DEIRDRENEY ANDRIA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1020976','0~EXT',1,0,0,0,GETDATE() --Provider: HOFFMAN, CAROLYN A; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000287','0~EXT',0,0,0,0,GETDATE() --Provider: KLABZUBA, JEANIE L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113158','0~EXT',0,0,0,0,GETDATE() --Provider: LAWRENCE, JEFFREY P; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~123016','0~EXT',0,0,0,0,GETDATE() --Provider: MAJOR, RYAN T; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000129','0~EXT',0,0,0,0,GETDATE() --Provider: MCCOLLOM, BRENDON; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~136241','0~EXT',0,0,0,0,GETDATE() --Provider: O'BRIEN, BLAKE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108193','0~EXT',0,0,0,0,GETDATE() --Provider: OLSEN, L TODD; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~143629','0~EXT',0,0,0,0,GETDATE() --Provider: POPE, JORDEN D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1010980','0~EXT',0,0,0,0,GETDATE() --Provider: POWERS, PAUL J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1016959','0~EXT',0,0,0,0,GETDATE() --Provider: ROBERTSON, DESTINY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108504','0~EXT',0,0,0,0,GETDATE() --Provider: SMITH, JOSHUA S; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~118362','0~EXT',0,0,0,0,GETDATE() --Provider: THOMAS, JANA LYNN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1027042','0~EXT',0,0,0,0,GETDATE() --Provider: TORRES, MELISSA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108765','0~EXT',1,0,0,0,GETDATE() --Provider: WILSON, MICHAEL K; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002314','0~EXT',0,0,0,0,GETDATE() --Provider: ZYBACH, NIKKI; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100891','0~EXT',0,0,0,0,GETDATE() --Provider: CHANSOLME, DAVID H; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~104676','0~EXT',1,0,0,0,GETDATE() --Provider: SANDS, STEVEN; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~107304','0~EXT',1,0,0,0,GETDATE() --Provider: CONLEY, ARTHUR H; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~109315','0~EXT',0,0,0,0,GETDATE() --Provider: HOOVER, GEOFFREY W; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~102823','0~EXT',1,0,0,0,GETDATE() --Provider: KIEHN, MICHAEL E; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~103882','0~EXT',0,0,0,0,GETDATE() --Provider: NELSON, JENNIFER K; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1027349','0~EXT',0,0,0,0,GETDATE() --Provider: CABRERA, JOANNA STACY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100931','0~EXT',0,0,0,0,GETDATE() --Provider: CHOHAN, SAADIA N; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000079','0~EXT',0,0,0,0,GETDATE() --Provider: CONRADY, RICKIE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101124','0~EXT',0,0,0,0,GETDATE() --Provider: COUPENS, STEVEN D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~115227','0~EXT',1,0,0,0,GETDATE() --Provider: DE GASTON, DAVID EVANS; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1025097','0~EXT',0,0,0,0,GETDATE() --Provider: DUELL, BRYAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101543','0~EXT',1,0,0,0,GETDATE() --Provider: ESPINOZA ERVIN, CHRISTOPHER; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~107466','0~EXT',0,0,0,0,GETDATE() --Provider: FARHOOD, LISA M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1031857','0~EXT',1,0,0,0,GETDATE() --Provider: GANN, LACEY; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~111955','0~EXT',0,0,0,0,GETDATE() --Provider: JAMISON, JOSEPH A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~129826','0~EXT',1,0,0,0,GETDATE() --Provider: KEOPPEL, KELSEY; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~108168','0~EXT',0,0,0,0,GETDATE() --Provider: NGUYEN, JOSEPH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000568','0~EXT',0,0,0,0,GETDATE() --Provider: O'DONNELL, DANIEL JOSEPH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108219','0~EXT',0,0,0,0,GETDATE() --Provider: PARIKH, SHRILEKHA C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100621','0~EXT',0,0,0,0,GETDATE() --Provider: PATIN, COURTNEY L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104547','0~EXT',0,0,0,0,GETDATE() --Provider: ROBERTSON, JOHN A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112797','0~EXT',0,0,0,0,GETDATE() --Provider: SHAKIR, SADIQ A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000256','0~EXT',0,0,0,0,GETDATE() --Provider: SHARP, ANTHONY DAVID; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109484','0~EXT',0,0,0,0,GETDATE() --Provider: WEBB, TED E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105657','0~EXT',0,0,0,0,GETDATE() --Provider: WEBBER, REGINA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105894','0~EXT',1,0,0,0,GETDATE() --Provider: WOODS, BRONWYN L; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~104223','0~EXT',0,0,0,1,GETDATE() --Provider: PHILLIPS, TERRELL R; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~120419','0~EXT',0,0,0,0,GETDATE() --Provider: MCGIVERN, KYLE VON; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~123403','0~EXT',0,0,0,0,GETDATE() --Provider: KNIGHT, CHAD MICHAEL; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~109763','0~EXT',0,0,0,0,GETDATE() --Provider: TAYLOR, AUSTIN L; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~109386','0~EXT',1,0,0,0,GETDATE() --Provider: PARDO, GABRIEL; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~103139','0~EXT',1,0,0,0,GETDATE() --Provider: LITTLE JR, JESSE S; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~127235','0~EXT',0,0,0,0,GETDATE() --Provider: WILEY, KEVIN F; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000440','0~EXT',0,0,0,0,GETDATE() --Provider: BAGGS, SHANDY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110257','0~EXT',0,0,0,0,GETDATE() --Provider: BOBB, DAVID W; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100512','0~EXT',1,0,0,0,GETDATE() --Provider: BORROR, KERI A; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000476','0~EXT',0,0,0,0,GETDATE() --Provider: BOYLES, PRESTON HEATH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107423','0~EXT',0,0,0,0,GETDATE() --Provider: EARLEY, KRISTIN, F; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~115036','0~EXT',0,0,0,0,GETDATE() --Provider: FAIRLIE, GREGORY WILLIAM; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000107','0~EXT',0,0,0,0,GETDATE() --Provider: GORE, JAMIE LYNN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000732','0~EXT',0,0,0,0,GETDATE() --Provider: HICKSON, NICOLE OGLE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1006064','0~EXT',0,0,0,0,GETDATE() --Provider: HINES, MARY MARGARET; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~125177','0~EXT',1,0,0,0,GETDATE() --Provider: HIXON, NANCY-KA E; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~102577','0~HPICH',1,0,0,0,GETDATE() --Provider: JAMES, CHRISTOPHER; Practice: HPI CH
INSERT INTO map.EpicPracticeProviders SELECT '5~113204','0~EXT',0,0,0,0,GETDATE() --Provider: JAMES, JENNIFER; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107802','0~EXT',1,0,0,0,GETDATE() --Provider: KEATHLY, LAYNE M; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~115906','0~EXT',1,0,0,1,GETDATE() --Provider: LAWRENCE, HILLARY SETH; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000472','0~EXT',0,0,0,0,GETDATE() --Provider: LIVINGSTON, PATRICK G; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000604','0~EXT',0,0,0,0,GETDATE() --Provider: MARANTO, MICHELE W; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109382','0~EXT',0,0,0,0,GETDATE() --Provider: OLAY, MICHAEL P; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000097','0~EXT',0,0,0,0,GETDATE() --Provider: ORME, LAURIE A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104088','0~EXT',1,0,0,0,GETDATE() --Provider: PALMER, PHILIP; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000788','0~EXT',0,0,0,0,GETDATE() --Provider: PASQUALI-BOWERS, JANET S; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1003492','0~EXT',0,0,0,0,GETDATE() --Provider: PINGLETON, WENDY JEAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112014','0~EXT',1,0,0,0,GETDATE() --Provider: RAPACZ, JOHN P; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~111754','0~EXT',0,0,0,0,GETDATE() --Provider: SALEEMI, MUDASSIR M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108414','0~EXT',1,0,0,0,GETDATE() --Provider: SCHANK, BOB J; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~108477','0~EXT',0,0,0,0,GETDATE() --Provider: SHIRES, ERNESTINE C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105471','0~EXT',0,0,0,0,GETDATE() --Provider: VANCLEAVE, ROBIN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105687','0~EXT',1,0,0,0,GETDATE() --Provider: WEST, ERIC; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1013265','0~EXT',0,0,0,0,GETDATE() --Provider: WHITE, DARCY D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114397','0~EXT',0,0,0,0,GETDATE() --Provider: WILLIAMS, TRACY S; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108781','0~EXT',0,0,0,0,GETDATE() --Provider: WOMACK, CHARLES E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~129233','0~EXT',1,0,0,0,GETDATE() --Provider: YOKELL, NATHANIEL; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~116244','0~EXT',1,0,0,0,GETDATE() --Provider: SNYDER, CHARLES T; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~132884','0~EXT',0,0,0,0,GETDATE() --Provider: DOSS, WILLIAM; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~122526','0~EXT',1,0,0,0,GETDATE() --Provider: BERKLEY, CHELSEA; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~121831','0~EXT',0,0,0,0,GETDATE() --Provider: MIDDLETON, BLAKE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109595','0~EXT',0,0,0,0,GETDATE() --Provider: STETSON, NATHANIEL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~121372','0~EXT',1,0,0,0,GETDATE() --Provider: RUSH, DAVID ALAN; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~105498','0~EXT',1,0,0,0,GETDATE() --Provider: VAVRICKA, TIMOTHY A; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~118328','0~EXT',0,0,0,0,GETDATE() --Provider: BONILLA, SHAWN PATRICK; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109252','0~EXT',0,0,0,0,GETDATE() --Provider: CONAWAY, KEITH A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1014083','0~EXT',0,0,0,0,GETDATE() --Provider: CORDIS, CORBIN ELIZABETH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~125205','0~EXT',0,0,0,0,GETDATE() --Provider: CURRY, MICHAEL CODY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110424','0~EXT',0,0,0,0,GETDATE() --Provider: DENNIS, LYDIA J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110414','0~EXT',0,0,0,0,GETDATE() --Provider: DIMICK, SUSAN M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000057','0~EXT',0,0,0,0,GETDATE() --Provider: DIMSKI, ROBERT; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101430','0~EXT',0,0,0,0,GETDATE() --Provider: DUNHAM, RORY C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109285','0~EXT',1,0,0,0,GETDATE() --Provider: FOXEN, JESSICA; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~101726','0~EXT',1,0,0,0,GETDATE() --Provider: FRIEDMAN, EMILY D; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~107576','0~EXT',0,0,0,0,GETDATE() --Provider: GOTCHER, RYAN N; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~102223','0~EXT',0,0,0,0,GETDATE() --Provider: HAYNES, DOUGLAS W; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1017962','0~EXT',0,0,0,0,GETDATE() --Provider: HILL, MADELEINE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~141322','0~EXT',0,0,0,0,GETDATE() --Provider: LAMBERT, LAUREN M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000169','0~EXT',0,0,0,0,GETDATE() --Provider: MANKIN, ALICE JOY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1010554','0~EXT',0,0,0,0,GETDATE() --Provider: MCLAUGHLIN, CARLEY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111461','0~HPICH',1,0,0,0,GETDATE() --Provider: MCWILLIAMS, JOSH E; Practice: HPI CH
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000594','0~EXT',0,0,0,0,GETDATE() --Provider: MILLER, KRISTIN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~130927','0~EXT',1,0,0,0,GETDATE() --Provider: MITCHUM, TYLER J; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1023172','0~EXT',0,0,0,0,GETDATE() --Provider: NGUYEN, KHANH MAI; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~119925','0~EXT',1,0,0,0,GETDATE() --Provider: NOTTINGHAM, BRAXTON LANE; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~113870','0~EXT',0,0,0,0,GETDATE() --Provider: RICCITELLI, KEVIN M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1004163','0~EXT',0,0,0,0,GETDATE() --Provider: RODRIGUEZ, HILDA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103960','0~EXT',0,0,0,0,GETDATE() --Provider: SCOTT, ANDREA R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~118117','0~EXT',0,0,0,0,GETDATE() --Provider: SMITH, JENNIFER E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108521','0~EXT',0,0,0,0,GETDATE() --Provider: SPARKS, RHONDA A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105049','0~EXT',1,0,0,0,GETDATE() --Provider: SPENCER, GREGORY M; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~114336','0~EXT',0,0,0,0,GETDATE() --Provider: STATES, MELISSA M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~127084','0~EXT',1,0,0,0,GETDATE() --Provider: TERRY, BLAIR; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~108593','0~EXT',0,0,0,0,GETDATE() --Provider: THOMAS, AMANDA L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109461','0~EXT',0,0,0,0,GETDATE() --Provider: THOMPSON, IAN S; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008021','0~EXT',1,0,0,0,GETDATE() --Provider: UTLEY, JULIE B; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1013913','0~EXT',0,0,0,0,GETDATE() --Provider: WARRINGTON, LISA RENEE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112985','0~EXT',0,0,0,0,GETDATE() --Provider: WILSON, DAVID S; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109161','0~EXT',1,0,0,0,GETDATE() --Provider: ZOGLEMAN, JENNIFER L; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~104041','0~EXT',0,0,0,0,GETDATE() --Provider: ORGILL, RICHARD D; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1011932','0~EXT',0,0,0,0,GETDATE() --Provider: VINCENT, RYAN; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~101689','0~EXT',0,0,0,0,GETDATE() --Provider: FRALEY, ANDREA L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~102941','0~EXT',0,0,0,0,GETDATE() --Provider: KUMAR, ANA A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110288','0~EXT',0,0,0,0,GETDATE() --Provider: GLOMSET, JOHN L III; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110127','0~EXT',0,0,0,0,GETDATE() --Provider: MARTIN, MICHAEL D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101249','0~EXT',0,0,0,0,GETDATE() --Provider: DAVIS, JOEL M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113919','0~EXT',0,0,0,0,GETDATE() --Provider: CAPELLE, JONATHAN H; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101524','0~EXT',0,0,0,0,GETDATE() --Provider: ENGELBRECHT, VALERIE A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~132362','0~EXT',0,0,0,0,GETDATE() --Provider: WARREN, SHERISA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112202','0~EXT',0,0,0,0,GETDATE() --Provider: ALLEN, ERIN K; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100290','0~EXT',0,0,0,0,GETDATE() --Provider: BARNES, HEATHER D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~125600','0~EXT',0,0,0,0,GETDATE() --Provider: BHELLA, MADISON; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000957','0~EXT',0,0,0,0,GETDATE() --Provider: BOST, DEKODA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1005514','0~EXT',0,0,0,0,GETDATE() --Provider: BROTHERTON, KYLE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100868','0~EXT',0,0,0,0,GETDATE() --Provider: CERDA, ALISHA R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~124362','0~EXT',0,0,0,0,GETDATE() --Provider: CHARLTON, NATHAN JAMES; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001087','0~EXT',0,0,0,0,GETDATE() --Provider: CORTEZ, DANA S; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101185','0~EXT',1,0,0,0,GETDATE() --Provider: CRUZAN, JEFFREY; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1010790','0~EXT',0,0,0,0,GETDATE() --Provider: DARWICHE, GENEVIEVE KATHLEEN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107378','0~EXT',0,0,0,0,GETDATE() --Provider: DELEON, DAVID M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109275','0~EXT',0,0,0,0,GETDATE() --Provider: DITTO, STEVEN W; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112735','0~EXT',0,0,0,0,GETDATE() --Provider: GARDNER, ADAM; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107594','0~EXT',1,0,0,0,GETDATE() --Provider: GRIFFIN, GARY E; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~122133','0~EXT',1,0,0,0,GETDATE() --Provider: HABASH, NABIL; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~125164','0~EXT',0,0,0,0,GETDATE() --Provider: HAMADA, NOHA F; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~143620','0~EXT',0,0,0,0,GETDATE() --Provider: JENKINS, KELCIE LEEANNE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~102907','0~EXT',0,0,0,0,GETDATE() --Provider: KOONTZ, JOHN A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001725','0~EXT',1,0,0,0,GETDATE() --Provider: LOWERY, CHELSEA; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~112847','0~EXT',0,0,0,0,GETDATE() --Provider: MCMAHAN, MICHAEL ZANN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1020271','0~EXT',0,0,0,0,GETDATE() --Provider: MILLER, SHERRY ANN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109391','0~EXT',0,0,0,0,GETDATE() --Provider: PHAM, THUAN V; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109394','0~EXT',1,0,0,0,GETDATE() --Provider: PICKRELL, LORI L; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1003166','0~EXT',0,0,0,0,GETDATE() --Provider: POPE, ROSS E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104351','0~EXT',0,0,0,0,GETDATE() --Provider: PURVIS, BRETT; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1016331','0~EXT',0,0,0,0,GETDATE() --Provider: REDDING SLOOTHER, AMBER; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~124295','0~EXT',0,0,0,0,GETDATE() --Provider: ROWE, ROBERT A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111265','0~EXT',0,0,0,0,GETDATE() --Provider: SANDLER, DENNIS E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109421','0~EXT',0,0,0,0,GETDATE() --Provider: SCHENK, CURTIS; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104801','0~EXT',0,0,0,0,GETDATE() --Provider: SERES, DONNA M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109433','0~EXT',0,0,0,0,GETDATE() --Provider: SIECK, CHRISTIAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~129230','0~EXT',1,0,0,0,GETDATE() --Provider: TIPPS, JACOB M; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~105570','0~EXT',0,0,0,0,GETDATE() --Provider: WALL, RAYMOND L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1005246','0~EXT',0,0,0,0,GETDATE() --Provider: WARD, JENNIFER NICOLE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105783','0~EXT',0,0,0,0,GETDATE() --Provider: WILLIAMS, CURTIS B; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~125136','0~EXT',0,0,0,0,GETDATE() --Provider: COOK, JERED M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~102807','0~EXT',1,0,0,0,GETDATE() --Provider: KERSHEN, JOSHUA C; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~112469','0~EXT',0,0,0,0,GETDATE() --Provider: LEHR, ROBERT B; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~104429','0~EXT',0,0,0,0,GETDATE() --Provider: REDDICK, BRADLEY J; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~114910','0~EXT',1,0,0,0,GETDATE() --Provider: BOECKMAN, MATTHEW J; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~130510','0~EXT',1,0,0,0,GETDATE() --Provider: POLLARD, EMILY M; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000456','0~EXT',0,0,0,0,GETDATE() --Provider: ELLIS, SHAWN M; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1007667','0~EXT',0,0,0,0,GETDATE() --Provider: HULSE, ROBERT TRENT; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~127133','0~EXT',1,0,0,0,GETDATE() --Provider: WOOLARD, JOSHUA; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~109230','0~EXT',0,0,0,0,GETDATE() --Provider: BOCK, ALAN S; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~121675','0~EXT',1,0,0,1,GETDATE() --Provider: BROOKS, AMY LYNN; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~109236','0~EXT',0,0,0,0,GETDATE() --Provider: BUNDY, JOHN MCCALL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~134088','0~EXT',1,0,0,1,GETDATE() --Provider: BUTTS, CASEY; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002331','0~EXT',0,0,0,0,GETDATE() --Provider: CAMPBELL, ERIC; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100827','0~EXT',1,0,0,0,GETDATE() --Provider: CARROLL, NICOLE; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~120012','0~EXT',0,0,0,0,GETDATE() --Provider: COLSTON, ANNA CANOY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109264','0~EXT',0,0,0,0,GETDATE() --Provider: CRAWFORD, MICHAEL K; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107407','0~EXT',0,0,0,0,GETDATE() --Provider: DOWELL, MATTHEW S; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109278','0~EXT',0,0,0,0,GETDATE() --Provider: ELLIOTT, MICHAEL S; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107459','0~EXT',0,0,0,0,GETDATE() --Provider: EVANS, FRANK J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1004482','0~EXT',1,0,0,0,GETDATE() --Provider: FIORAZO, JOSEPH; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~101364','0~EXT',1,0,0,0,GETDATE() --Provider: FRAZIER, JESSICA C; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~112232','0~EXT',0,0,0,0,GETDATE() --Provider: FUNDERBURK JR, CHARLES H; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101795','0~EXT',0,0,0,0,GETDATE() --Provider: GARRISON, PATRICK MICHAEL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113694','0~EXT',0,0,0,0,GETDATE() --Provider: GILES, DANNY W; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~140859','0~EXT',0,0,0,0,GETDATE() --Provider: GUTSCHENRITTER, TYLER E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109301','0~EXT',0,0,0,0,GETDATE() --Provider: HAAG, MATTHEW J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001143','0~EXT',0,0,0,0,GETDATE() --Provider: HAYMANS, LAUREN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~119563','0~EXT',0,0,0,0,GETDATE() --Provider: HENRICHS, ALLISON DIANE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1019492','0~EXT',0,0,0,0,GETDATE() --Provider: HESAMI, NAZANIN SARA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107710','0~EXT',0,0,0,0,GETDATE() --Provider: HOPKINS, LAUREN C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~102415','0~EXT',0,0,0,0,GETDATE() --Provider: HOPKINS, RONALD R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107711','0~EXT',0,0,0,0,GETDATE() --Provider: HOPKINS, STEPHEN A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002041','0~EXT',0,0,0,0,GETDATE() --Provider: JANG, JAMES MINSU; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114179','0~EXT',0,0,0,0,GETDATE() --Provider: JOHNSON, APRIL B; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1026884','0~EXT',0,0,0,0,GETDATE() --Provider: KIRKENDALL, KENDRA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103095','0~EXT',0,0,0,0,GETDATE() --Provider: LEVERETT, JOE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001454','0~EXT',0,0,0,0,GETDATE() --Provider: LEWIS, KRISTIN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103123','0~EXT',0,0,0,0,GETDATE() --Provider: LINDENAU, MELISSA A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103149','0~EXT',0,0,0,0,GETDATE() --Provider: LIVINGSTON, TANYA L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001158','0~EXT',0,0,0,0,GETDATE() --Provider: LUONG, NHU THUY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~125763','0~EXT',1,0,0,0,GETDATE() --Provider: MARVIN, WHITNEY E; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~135647','0~EXT',0,0,0,0,GETDATE() --Provider: MASELLI, VITO; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1013671','0~EXT',0,0,0,0,GETDATE() --Provider: MILLS, SEAN PATRICK; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~126559','0~EXT',0,0,0,0,GETDATE() --Provider: MONFORE, NATOSHA N; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1014303','0~EXT',0,0,0,0,GETDATE() --Provider: MORGAN, LYNDAL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103765','0~EXT',1,0,0,0,GETDATE() --Provider: MORGAN, MICHAEL E; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~108165','0~EXT',0,0,0,0,GETDATE() --Provider: NEWTON, TIMOTHY R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~123571','0~EXT',1,0,0,0,GETDATE() --Provider: NYBERG, CARL; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~116519','0~EXT',0,0,0,0,GETDATE() --Provider: OGDEN, SUSAN E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114867','0~EXT',0,0,0,0,GETDATE() --Provider: PRICE, ALICIA K; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109408','0~EXT',0,0,0,0,GETDATE() --Provider: RIGGS, DEBRA A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~119249','0~RSG',0,0,0,0,GETDATE() --Provider: SANDERS, JANA; Practice: Robert G. Spencer, M.D.
INSERT INTO map.EpicPracticeProviders SELECT '5~P1007883','0~EXT',0,0,0,0,GETDATE() --Provider: SCHULZE II, DAVID WAYNE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109454','0~EXT',0,0,0,0,GETDATE() --Provider: SWYGERT, TRINA D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105462','0~EXT',0,0,0,0,GETDATE() --Provider: UNDERHILL, FLOYD K; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000269','0~EXT',0,0,0,0,GETDATE() --Provider: WILKS, JONATHAN D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002657','0~EXT',0,0,0,0,GETDATE() --Provider: WOODS, ABBEY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1027180','0~EXT',0,0,0,0,GETDATE() --Provider: YATES, ROBIN A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~136367','0~EXT',0,0,0,0,GETDATE() --Provider: YINGLING, JOHN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~135734','0~EXT',0,0,0,0,GETDATE() --Provider: MAHONEY, STEPHEN T; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1017591','0~EXT',0,0,0,0,GETDATE() --Provider: VALANTINE, BRANDON; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1015253','0~EXT',1,0,0,0,GETDATE() --Provider: CHRISTENSEN, SARAH; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~103181','0~EXT',0,0,0,0,GETDATE() --Provider: LOPEZ JR, MARTIN J; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1005108','0~EXT',1,0,0,0,GETDATE() --Provider: CHOE, JAMES; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~102551','0~EXT',0,0,0,0,GETDATE() --Provider: JACKSON, JAMES J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108704','0~EXT',0,0,0,0,GETDATE() --Provider: WEITZEL, MARC, M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100288','0~EXT',0,0,0,0,GETDATE() --Provider: BARNES, DANIEL P; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107852','0~EXT',0,0,0,0,GETDATE() --Provider: KNUTSON, ZAKARY A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~118653','0~EXT',0,0,0,0,GETDATE() --Provider: FAROOQ, SAIF ULLAH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109374','0~EXT',0,0,0,0,GETDATE() --Provider: MOSES, MARK; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114939','0~EXT',0,0,0,0,GETDATE() --Provider: BERRY, RIANA ROXANNE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100523','0~EXT',0,0,0,0,GETDATE() --Provider: BOURNE, CATRINA F; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001588','0~EXT',1,0,0,0,GETDATE() --Provider: BUKSH, AHMED BILAL; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~107241','0~EXT',1,0,0,0,GETDATE() --Provider: CARRO JR, ARMANDO A; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~125882','0~EXT',0,0,0,0,GETDATE() --Provider: CHANG, HAN-CHIH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100992','0~EXT',0,0,0,0,GETDATE() --Provider: CLINKENBEARD, DANIEL C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109259','0~EXT',0,0,0,0,GETDATE() --Provider: CORLEY, STANLEY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109263','0~EXT',0,0,0,0,GETDATE() --Provider: COX, LOUIS H; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114383','0~EXT',0,0,0,0,GETDATE() --Provider: DANIELS, MEGAN N; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109273','0~EXT',0,0,0,0,GETDATE() --Provider: DENG, ZEMING; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110973','0~EXT',0,0,0,0,GETDATE() --Provider: EARLEY, MITCHELL L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114386','0~EXT',0,0,0,0,GETDATE() --Provider: ELLIOTT, JOANNA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1017680','0~EXT',0,0,0,0,GETDATE() --Provider: ESTRADA, ERIC ROBERT; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1009088','0~EXT',0,0,0,0,GETDATE() --Provider: GANNON, PATRICK RUSSELL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101783','0~EXT',0,0,0,0,GETDATE() --Provider: GARINGER, LINDSAY LEIGH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1005756','0~EXT',1,0,0,0,GETDATE() --Provider: GHATA, GEORGE; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002573','0~EXT',0,0,0,0,GETDATE() --Provider: GIDEON, HERNDON; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~136394','0~EXT',1,0,0,0,GETDATE() --Provider: GLENDENNING, ALEXANDRIA; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~102034','0~EXT',0,0,0,0,GETDATE() --Provider: GUNDERSON, ROBERT J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~102087','0~EXT',0,0,0,0,GETDATE() --Provider: HAMAKER, ALLEN J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1011769','0~EXT',0,0,0,0,GETDATE() --Provider: HARDEN, BRANDI GYNN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008541','0~EXT',0,0,0,0,GETDATE() --Provider: HARGRAVE, JERI L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107730','0~EXT',0,0,0,0,GETDATE() --Provider: HULL, MICHAEL SHANE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002361','0~EXT',0,0,0,0,GETDATE() --Provider: JARVIS, THOMAS ALAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1005822','0~EXT',0,0,0,0,GETDATE() --Provider: JOHNSON, JERIMIAH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1026598','0~EXT',0,0,0,0,GETDATE() --Provider: KEARNEY, MADISON LEIGH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112764','0~EXT',0,0,0,0,GETDATE() --Provider: KINZIE, TIMOTHY L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~118108','0~EXT',0,0,0,0,GETDATE() --Provider: KRISHNAMURTHY, ASHOK S; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114223','0~EXT',0,0,0,0,GETDATE() --Provider: LANGE, MICHELE L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1014325','0~EXT',0,0,0,0,GETDATE() --Provider: LEAL, KAREN S; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107969','0~EXT',0,0,0,0,GETDATE() --Provider: MANNING, VALERIE B; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1011405','0~EXT',0,0,0,0,GETDATE() --Provider: MARCUM, CRYSTAL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~140786','0~EXT',0,0,0,0,GETDATE() --Provider: MASON, AMY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000963','0~EXT',0,0,0,0,GETDATE() --Provider: MATHEW, SHERIL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109360','0~EXT',0,0,0,0,GETDATE() --Provider: MCGOURAN, FRANCIS J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~119812','0~EXT',0,0,0,0,GETDATE() --Provider: MCLAUGHLIN, JERRY T; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001616','0~EXT',0,0,0,0,GETDATE() --Provider: MEIER, MEGAN L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103738','0~EXT',1,0,0,0,GETDATE() --Provider: MOORE, JEREMY A; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~103868','0~EXT',0,0,0,0,GETDATE() --Provider: NASSAR, WADDAH N; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~102684','0~SCS',1,0,0,0,GETDATE() --Provider: NEEDHAM, COURTNEY A; Practice: S. Christopher Shadid, M.D.
INSERT INTO map.EpicPracticeProviders SELECT '5~134064','0~EXT',0,0,0,0,GETDATE() --Provider: NETTLES, ROBYN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1016905','0~EXT',0,0,0,0,GETDATE() --Provider: OSBORN, MARK E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104072','0~EXT',1,0,0,0,GETDATE() --Provider: OWENS JR., TOMAS; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~134901','0~EXT',0,0,0,0,GETDATE() --Provider: PEARSON, CARLIE M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109416','0~EXT',0,0,0,0,GETDATE() --Provider: RUIDERA, GRACE M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000126','0~EXT',0,0,0,0,GETDATE() --Provider: SACKET, STEVEN KYLE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001929','0~EXT',0,0,0,0,GETDATE() --Provider: SALE, ASHLEY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1016609','0~EXT',0,0,0,0,GETDATE() --Provider: SANDERSON, MIKE LYNN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104740','0~EXT',0,0,0,0,GETDATE() --Provider: SCHRADER, STUART W; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104756','0~EXT',0,0,0,0,GETDATE() --Provider: SCHWARZ, KRISTALLENA S; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1005489','0~EXT',0,0,0,0,GETDATE() --Provider: SOLOMON, ALISHA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1013577','0~EXT',0,0,0,0,GETDATE() --Provider: SPEARS, JOSHUA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105043','0~EXT',0,0,0,0,GETDATE() --Provider: SPEEGLE, DAVID B; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001193','0~EXT',0,0,0,0,GETDATE() --Provider: SPRADLIN, MEGAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1029209','0~EXT',0,0,0,0,GETDATE() --Provider: STAPLETON, AMEE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1011778','0~EXT',0,0,0,0,GETDATE() --Provider: TETTEH, NANA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1023754','0~EXT',0,0,0,0,GETDATE() --Provider: TILLMAN, DESHELL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114360','0~EXT',0,0,0,0,GETDATE() --Provider: TORRES CARRANCO, AMIE M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1031953','0~EXT',0,0,0,0,GETDATE() --Provider: TORRES COONS, MELISSA L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1021839','0~EXT',0,0,0,0,GETDATE() --Provider: WALSH, SARAH KATHRYN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~123723','0~EXT',0,0,0,0,GETDATE() --Provider: WILLIAMS, MITCHELL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100270','0~EXT',0,0,0,0,GETDATE() --Provider: BANKHEAD, ROY W; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~108052','0~EXT',0,0,0,0,GETDATE() --Provider: MELTON, JIM G; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002773','0~EXT',0,0,0,0,GETDATE() --Provider: LEONARD, JASON EDWARD; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1005166','0~EXT',1,0,0,1,GETDATE() --Provider: BLICK, BRIAN E; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000908','0~EXT',0,0,0,0,GETDATE() --Provider: FARROW, AARON; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~120560','0~EXT',0,0,0,0,GETDATE() --Provider: PARSONS, BLAKE P; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111756','0~EXT',0,0,0,0,GETDATE() --Provider: BOUVETTE, CHRISTOPHER M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101817','0~EXT',0,0,0,0,GETDATE() --Provider: GEIB, TIMOTHY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112359','0~EXT',0,0,0,0,GETDATE() --Provider: GIBSON, BREEANNA D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103691','0~EXT',0,0,0,0,GETDATE() --Provider: MITCHELL, JAMES D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114491','0~EXT',0,0,0,0,GETDATE() --Provider: NELSON, ELIZABETH M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109970','0~EXT',0,0,0,0,GETDATE() --Provider: PICKETT, GREG D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111372','0~EXT',0,0,0,0,GETDATE() --Provider: ANDERSON, MICHAEL T; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100139','0~EXT',1,0,0,0,GETDATE() --Provider: ANDERSON, RACHEL LACY; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~133036','0~EXT',1,0,0,0,GETDATE() --Provider: AUSTIN, MADISON; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1011833','0~EXT',0,0,0,0,GETDATE() --Provider: BACKUS, JEANA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113054','0~EXT',0,0,0,0,GETDATE() --Provider: BALLARD, LYDIA R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114059','0~EXT',0,0,0,0,GETDATE() --Provider: BAUGHMAN, JENAE C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008137','0~EXT',0,0,0,0,GETDATE() --Provider: BEAVER, ERIC RAY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107115','0~EXT',0,0,0,0,GETDATE() --Provider: BELT, JAY C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1011870','0~EXT',0,0,0,0,GETDATE() --Provider: BITTLE, KIMBERLY LOUISE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000914','0~EXT',0,0,0,0,GETDATE() --Provider: BOLTON, SHARON P; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107195','0~EXT',0,0,0,0,GETDATE() --Provider: BRYAN, JONATHAN A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000563','0~EXT',0,0,0,0,GETDATE() --Provider: BYRD, JALYN DENISE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008720','0~EXT',0,0,0,0,GETDATE() --Provider: CALDWELL, CINDY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100853','0~EXT',0,0,0,0,GETDATE() --Provider: CASTEEL, ANGELIA E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100879','0~EXT',0,0,0,0,GETDATE() --Provider: CHAMBERS, SUSAN L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107307','0~EXT',0,0,0,0,GETDATE() --Provider: CONNERY, STEPHEN M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111892','0~EXT',0,0,0,0,GETDATE() --Provider: CONWAY JR, JIMMY H; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1009971','0~EXT',1,0,0,0,GETDATE() --Provider: DAWSON, MICHELLE R; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~113019','0~EXT',0,0,0,0,GETDATE() --Provider: DEROCHER, ERICK C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101343','0~EXT',0,0,0,0,GETDATE() --Provider: DICKMAN, GERALD L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109644','0~EXT',0,0,0,0,GETDATE() --Provider: DROOBY, DEAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109277','0~EXT',0,0,0,0,GETDATE() --Provider: DYE, DAVID B; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107469','0~EXT',0,0,0,0,GETDATE() --Provider: FAUBION, SHELLY D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1003381','0~EXT',0,0,0,0,GETDATE() --Provider: FERRELL, JENNIFER; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1009836','0~EXT',0,0,0,0,GETDATE() --Provider: FISHER, JACOB; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~116369','0~EXT',0,0,0,0,GETDATE() --Provider: FRENCH, KENT ANTHONY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1012771','0~EXT',0,0,0,0,GETDATE() --Provider: GABLE, TINA M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~118037','0~EXT',0,0,0,0,GETDATE() --Provider: HALEEM AHMED AMIN, AMGAD MOHAMMED; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1009619','0~EXT',0,0,0,0,GETDATE() --Provider: HANEBUTT, DANA GAYLE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~137620','0~EXT',0,0,0,0,GETDATE() --Provider: HANEY, LUKE DANIEL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~137443','0~EXT',1,0,0,0,GETDATE() --Provider: HARVEY, MICHAEL R; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~107658','0~EXT',0,0,0,0,GETDATE() --Provider: HENRY, JAYSON D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1007015','0~EXT',0,0,0,0,GETDATE() --Provider: HESKETT, HANNAH E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~135427','0~EXT',0,0,0,0,GETDATE() --Provider: HOLLENBECK, NATHAN V; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~102411','0~EXT',0,0,0,0,GETDATE() --Provider: HOOVER, JEFFREY C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113924','0~EXT',0,0,0,0,GETDATE() --Provider: JATALA, SUMMER; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~102602','0~EXT',1,0,0,0,GETDATE() --Provider: JAY, DATHAN D; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~143781','0~EXT',0,0,0,0,GETDATE() --Provider: JOHNSON, CYNTHIA GAYLE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~102686','0~EXT',0,0,0,0,GETDATE() --Provider: JONES, DANIEL J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1013239','0~EXT',0,0,0,0,GETDATE() --Provider: JOSE-MATHEWS, JESSNIE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~126148','0~EXT',0,0,0,0,GETDATE() --Provider: KELLER, KRISTI DIANE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002213','0~EXT',0,0,0,0,GETDATE() --Provider: KEY, CHRISTINA RENATA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000864','0~EXT',1,0,0,0,GETDATE() --Provider: KHAN, KHALID A; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~107842','0~EXT',0,0,0,0,GETDATE() --Provider: KIRK, CLINT F; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110920','0~EXT',0,0,0,0,GETDATE() --Provider: KRODEL, JOHN M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~102966','0~EXT',0,0,0,0,GETDATE() --Provider: LACEFIELD, CARY L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008278','0~EXT',0,0,0,0,GETDATE() --Provider: LE, HENRY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1009255','0~EXT',0,0,0,0,GETDATE() --Provider: LI, JENNIFER SI; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000292','0~EXT',0,0,0,0,GETDATE() --Provider: LOGAN, SHAWNA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103289','0~EXT',0,0,0,0,GETDATE() --Provider: MARGO, BRADLEY J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114796','0~EXT',0,0,0,0,GETDATE() --Provider: MCARTHUR, KASEE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112677','0~EXT',0,0,0,0,GETDATE() --Provider: MCDANIEL, TANNER E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109363','0~EXT',0,0,0,0,GETDATE() --Provider: MEFFORD, TRENTON L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1003238','0~EXT',0,0,0,0,GETDATE() --Provider: MELSON, SCOTT; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108061','0~EXT',0,0,0,0,GETDATE() --Provider: MIHALSKY, STEPHEN W; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002375','0~EXT',1,0,0,0,GETDATE() --Provider: MILLER, KRISTY M; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~103714','0~EXT',1,0,0,0,GETDATE() --Provider: MOLINA, MARCO T; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~110982','0~EXT',0,0,0,0,GETDATE() --Provider: MUNNEKE, JOHN A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~123335','0~EXT',0,0,0,0,GETDATE() --Provider: NARVAIZ, TARA R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1006681','0~EXT',0,0,0,0,GETDATE() --Provider: PEARSON, ABIGAIL L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~130704','0~EXT',0,0,0,0,GETDATE() --Provider: PICKELSIMER, JACKELINE VANESSA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108266','0~EXT',0,0,0,0,GETDATE() --Provider: POK, VISAL, M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1003283','0~EXT',0,0,0,0,GETDATE() --Provider: REDING, ERIC LANE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~120271','0~EXT',0,0,0,0,GETDATE() --Provider: RIGGS, STERLING; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104515','0~EXT',0,0,0,0,GETDATE() --Provider: RINGUS, VYTAUTAS M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104531','0~EXT',0,0,0,0,GETDATE() --Provider: RIZVI, SYED M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113551','0~EXT',0,0,0,0,GETDATE() --Provider: SCHULTZ, STEVEN C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~133603','0~EXT',1,0,0,0,GETDATE() --Provider: SCHUTZ, CHRISTINA; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~104790','0~EXT',0,0,0,0,GETDATE() --Provider: SEITSINGER, DAVID W; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104806','0~EXT',0,0,0,0,GETDATE() --Provider: SHADID, CHRISTOPHER CHARLES; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108452','0~EXT',0,0,0,0,GETDATE() --Provider: SHAH, VATSALA N; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1010761','0~EXT',0,0,0,0,GETDATE() --Provider: SHEPPARD ROWE, JENNIFER MARIE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104925','0~EXT',0,0,0,0,GETDATE() --Provider: SIZELOVE, AARON S; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1007842','0~EXT',0,0,0,0,GETDATE() --Provider: SLOOTHEER, ROY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~137376','0~EXT',0,0,0,0,GETDATE() --Provider: SMITH, JODI E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1019088','0~EXT',0,0,0,0,GETDATE() --Provider: SMITH, LANCE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105020','0~EXT',0,0,0,0,GETDATE() --Provider: SNYDER, HOWARD T; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112593','0~EXT',0,0,0,0,GETDATE() --Provider: STEWART, ROBERT S; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105167','0~EXT',0,0,0,0,GETDATE() --Provider: STOUT, MARK P; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109827','0~EXT',0,0,0,0,GETDATE() --Provider: TESKE, TIMOTHY W; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~123018','0~EXT',0,0,0,0,GETDATE() --Provider: THOMAS, ASHLEY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~119307','0~EXT',0,0,0,0,GETDATE() --Provider: THROWER, MICHAEL ALAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112056','0~EXT',0,0,0,0,GETDATE() --Provider: TUCKER, SEAN R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113117','0~EXT',0,0,0,0,GETDATE() --Provider: TURNER, RYAN R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1018873','0~EXT',0,0,0,0,GETDATE() --Provider: VA CLINIC, SOUTH OKC; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000205','0~EXT',0,0,0,0,GETDATE() --Provider: VELASQUEZ, TORIBIO C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~132317','0~EXT',1,0,0,0,GETDATE() --Provider: WAGNER, DUSTIN; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~123656','0~EXT',0,0,0,0,GETDATE() --Provider: WELLMAN, AMBER MARIE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000488','0~EXT',0,0,0,0,GETDATE() --Provider: WILLIAMS, AMY LEE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114375','0~EXT',0,0,0,0,GETDATE() --Provider: WOODALL, GINGER L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001897','0~EXT',0,0,0,0,GETDATE() --Provider: YOKELL, RICHARD ALLAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1003311','0~EXT',0,0,0,0,GETDATE() --Provider: ZACHARY, DANIELLE N; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008356','0~EXT',0,0,0,0,GETDATE() --Provider: OVERBEY, NATHAN; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000216','0~EXT',0,0,0,0,GETDATE() --Provider: MCCOY, DAVID RUSSELL; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~110345','0~EXT',0,0,0,0,GETDATE() --Provider: BROWN, MICHAEL S; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~103546','0~EXT',0,0,0,0,GETDATE() --Provider: MCMINN JR, JOHNNY RUSSELL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109976','0~EXT',0,0,0,0,GETDATE() --Provider: ARCHBALD, EMILY G; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109231','0~EXT',0,0,0,0,GETDATE() --Provider: BOND, JAMES L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1006717','0~EXT',0,0,0,0,GETDATE() --Provider: CRAMER, TIMOTHY LUKE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107431','0~EXT',0,0,0,0,GETDATE() --Provider: EDMONDS, WILLIAM B; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103920','0~EXT',0,0,0,0,GETDATE() --Provider: NGUYEN, SON H; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~118147','0~EXT',0,0,0,0,GETDATE() --Provider: SESTAK, ANDREA L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100527','0~EXT',1,0,0,1,GETDATE() --Provider: BOWEN, ASHLEY B; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~112250','0~EXT',0,0,0,0,GETDATE() --Provider: CHENOWETH, BRIAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107288','0~EXT',0,0,0,0,GETDATE() --Provider: COCHRAN, DANIEL C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103079','0~EXT',0,0,0,0,GETDATE() --Provider: LEHMAN, THOMAS P; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108005','0~EXT',0,0,0,0,GETDATE() --Provider: MAY, BETH, D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109969','0~EXT',0,0,0,0,GETDATE() --Provider: NGUYEN, BEN G; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104109','0~EXT',1,0,0,0,GETDATE() --Provider: PARKINSON, ANDREW B; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~123017','0~EXT',0,0,0,0,GETDATE() --Provider: PHILLIPS, TYLER R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109414','0~EXT',0,0,0,0,GETDATE() --Provider: ROSS, KAREN M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~123443','0~EXT',0,0,0,0,GETDATE() --Provider: SHREVE, MARK C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~115483','0~EXT',0,0,0,0,GETDATE() --Provider: WOODSON, JEREMY ROBERT; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110521','0~EXT',0,0,0,0,GETDATE() --Provider: ABERNATHY, BOB R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1007103','0~EXT',0,0,0,0,GETDATE() --Provider: ADAY, CAITLIN REBECCA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114047','0~EXT',0,0,0,0,GETDATE() --Provider: ALDAVA, REBECCA R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000802','0~EXT',0,0,0,0,GETDATE() --Provider: ARTHURS JR, DARREL RAY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107049','0~EXT',0,0,0,0,GETDATE() --Provider: ARTHURS, STEPHEN R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000144','0~EXT',0,0,0,0,GETDATE() --Provider: BAHU-BAUGH, NAJWA A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~129117','0~EXT',0,0,0,0,GETDATE() --Provider: BANT, KATELYN TAYLOR; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~119104','0~EXT',0,0,0,0,GETDATE() --Provider: BARRITT, AMANDA MARIE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001610','0~EXT',0,0,0,0,GETDATE() --Provider: BELLER, JACK JUAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~115431','0~EXT',0,0,0,0,GETDATE() --Provider: BLOUGH, AMY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1024483','0~EXT',0,0,0,0,GETDATE() --Provider: BOLLING, JANA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100522','0~EXT',0,0,0,0,GETDATE() --Provider: BOURLAND, JOE B; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1025774','0~EXT',0,0,0,0,GETDATE() --Provider: BOWLER, COURTNEY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1023723','0~EXT',0,0,0,0,GETDATE() --Provider: BROWN, DENIESE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107201','0~EXT',0,0,0,0,GETDATE() --Provider: BUCKLEY, DUSTAN P; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100703','0~EXT',1,0,0,0,GETDATE() --Provider: BURGET, BRADLEY E; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~107212','0~EXT',0,0,0,0,GETDATE() --Provider: BURKLE ROBISON, ANN MAUREEN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100809','0~EXT',0,0,0,0,GETDATE() --Provider: CARPENTER, CARY L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100839','0~EXT',0,0,0,0,GETDATE() --Provider: CARTER, MARIE J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002366','0~EXT',0,0,0,0,GETDATE() --Provider: CHANG, MARIA CORAZON; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100901','0~EXT',0,0,0,0,GETDATE() --Provider: CHATTERJI, ROBI P; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002710','0~EXT',0,0,0,0,GETDATE() --Provider: COOK, MELISSA K; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109809','0~EXT',0,0,0,0,GETDATE() --Provider: COOPER, EMILY J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~143667','0~EXT',1,0,0,0,GETDATE() --Provider: CROSS, DONNA; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000382','0~EXT',0,0,0,0,GETDATE() --Provider: CROTTS, WENDY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008275','0~EXT',0,0,0,0,GETDATE() --Provider: CROWDER, JENNA LYNN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1003514','0~EXT',0,0,0,0,GETDATE() --Provider: CUMPSTON, CARMEN SANDER; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000073','0~EXT',1,0,0,0,GETDATE() --Provider: CURTESS, LISA; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~107356','0~EXT',0,0,0,0,GETDATE() --Provider: DAVENPORT, JEFFREY C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113718','0~EXT',0,0,0,0,GETDATE() --Provider: DECAMP, NICOLE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114385','0~EXT',0,0,0,0,GETDATE() --Provider: DICINTIO, ROBERT; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~138127','0~EXT',0,0,0,0,GETDATE() --Provider: DIFFENDAFFER, DEREK C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114085','0~EXT',0,0,0,0,GETDATE() --Provider: DUFF, MELODIE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109964','0~EXT',0,0,0,0,GETDATE() --Provider: DUTOIT, FRANCOIS J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101509','0~EXT',1,0,0,0,GETDATE() --Provider: ELLIS, CHESTON P; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1003272','0~EXT',0,0,0,0,GETDATE() --Provider: ENGELMAN, CARA G; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1014949','0~EXT',0,0,0,0,GETDATE() --Provider: EVERETT, BRITTNY RENEE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107476','0~EXT',0,0,0,0,GETDATE() --Provider: FINCH, COREY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002455','0~EXT',0,0,0,0,GETDATE() --Provider: FLAMING, LINDSAY M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101654','0~EXT',0,0,0,0,GETDATE() --Provider: FOLGER, TERESA A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1015744','0~EXT',0,0,0,0,GETDATE() --Provider: FORSTER, TIFFANY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101729','0~EXT',1,0,0,0,GETDATE() --Provider: FRIESE, ATHENA J; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000108','0~EXT',1,0,0,0,GETDATE() --Provider: GOLDEN, VICTORIA ERIN; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~109295','0~EXT',0,0,0,0,GETDATE() --Provider: GORDON, KRISTA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101937','0~EXT',0,0,0,0,GETDATE() --Provider: GOVETT, GREGG S; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107583','0~EXT',0,0,0,0,GETDATE() --Provider: GRAHAM, TREVA J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109296','0~EXT',0,0,0,0,GETDATE() --Provider: GRANT, GREGORY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1021150','0~EXT',0,0,0,0,GETDATE() --Provider: GREGORY, KELLY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~102081','0~EXT',0,0,0,0,GETDATE() --Provider: HALL, MARGARET A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114025','0~EXT',0,0,0,0,GETDATE() --Provider: HELMS, CHRISTINA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114158','0~EXT',0,0,0,0,GETDATE() --Provider: HERNANDEZ, GINA E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114161','0~EXT',0,0,0,0,GETDATE() --Provider: HILL, DARRELL R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1013611','0~EXT',0,0,0,0,GETDATE() --Provider: HODGES, JACI R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~142278','0~EXT',0,0,0,0,GETDATE() --Provider: HOLEMAN, JENNIFER; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111408','0~EXT',0,0,0,0,GETDATE() --Provider: JAYNE, DAVID K; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113269','0~EXT',0,0,0,0,GETDATE() --Provider: JONES, JEFFREY CLYDE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1004298','0~EXT',0,0,0,0,GETDATE() --Provider: KADAVY, NATHAN CARL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~102743','0~EXT',0,0,0,0,GETDATE() --Provider: KALLENBERGER, DAVID A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109814','0~EXT',0,0,0,0,GETDATE() --Provider: KELLER, DAVID E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000867','0~EXT',0,0,0,0,GETDATE() --Provider: KESTER, RISE LYNN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109332','0~EXT',0,0,0,0,GETDATE() --Provider: KOONS, KELLI D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000479','0~EXT',0,0,0,0,GETDATE() --Provider: KUBIER, MARTIN J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109338','0~EXT',0,0,0,0,GETDATE() --Provider: LANDES, MICHAEL D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103099','0~EXT',0,0,0,0,GETDATE() --Provider: LEVY, BRIAN P; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1005969','0~EXT',0,0,0,0,GETDATE() --Provider: MARTIN, JAIME DAWN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~142189','0~EXT',0,0,0,0,GETDATE() --Provider: MCCOY, KIMBERLY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111637','0~EXT',0,0,0,0,GETDATE() --Provider: MCCULLOH, THOMAS W; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114265','0~EXT',0,0,0,0,GETDATE() --Provider: MCFADDEN, HEATHER; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1011190','0~EXT',0,0,0,0,GETDATE() --Provider: MCMAINS, ASHLEY DIANE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~133732','0~EXT',0,0,0,0,GETDATE() --Provider: MCQUEEN, MEGAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109364','0~EXT',0,0,0,0,GETDATE() --Provider: MERRILL, THOMAS H; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114400','0~EXT',0,0,0,0,GETDATE() --Provider: MILES, LAURA SARFATIS; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103661','0~EXT',0,0,0,0,GETDATE() --Provider: MILLER, REBECCA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114279','0~EXT',1,0,0,0,GETDATE() --Provider: MONCHO, AMELIA; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1027353','0~EXT',0,0,0,0,GETDATE() --Provider: MOORE, JEFFREY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103815','0~EXT',0,0,0,0,GETDATE() --Provider: MUCKALA, ASHLEY N; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111177','0~EXT',0,0,0,0,GETDATE() --Provider: NGUYEN, ALBERT T; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008603','0~EXT',0,0,0,0,GETDATE() --Provider: NGUYEN, DAN L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109789','0~EXT',0,0,0,0,GETDATE() --Provider: NGUYEN, NGHIEP G; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000167','0~EXT',0,0,0,0,GETDATE() --Provider: NGUYEN, YEN DUNG THI; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108174','0~EXT',0,0,0,0,GETDATE() --Provider: NICKELS, TERRY D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1019753','0~EXT',0,0,0,0,GETDATE() --Provider: NUKUNA, KEHDINGA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1007394','0~EXT',0,0,0,0,GETDATE() --Provider: NUSRAT, RABEEYA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109380','0~EXT',0,0,0,0,GETDATE() --Provider: OBRIEN, KEVIN L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000535','0~EXT',0,0,0,0,GETDATE() --Provider: PADEN, MARK; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1023282','0~EXT',0,0,0,0,GETDATE() --Provider: PATEL, KRIYA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002921','0~EXT',0,0,0,0,GETDATE() --Provider: PATTON, KERRI ELIZABETH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1028081','0~EXT',0,0,0,0,GETDATE() --Provider: PAUL, TOMMY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008419','0~EXT',0,0,0,0,GETDATE() --Provider: PERRY, SARA E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104263','0~EXT',0,0,0,0,GETDATE() --Provider: PONDER, COREY E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104278','0~EXT',0,0,0,0,GETDATE() --Provider: PORTER, CATHERINE E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1003457','0~EXT',0,0,0,0,GETDATE() --Provider: PRATT, KAYLA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~118350','0~EXT',0,0,0,0,GETDATE() --Provider: QUALLS, STEVEN DALE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109857','0~EXT',0,0,0,0,GETDATE() --Provider: RAZAQ, MOHAMMAD; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104804','0~EXT',0,0,0,0,GETDATE() --Provider: REITER, JACY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108320','0~EXT',0,0,0,0,GETDATE() --Provider: RENSHAW, CHRISTOPHER, M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104561','0~EXT',1,0,0,0,GETDATE() --Provider: RODGERS, MARVIN D; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1017491','0~EXT',0,0,0,0,GETDATE() --Provider: ROOSTAEYAN, ALISON; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1006772','0~EXT',0,0,0,0,GETDATE() --Provider: SAHAI, PRIYA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113828','0~EXT',0,0,0,0,GETDATE() --Provider: SANTANA, CASTEL A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104749','0~EXT',0,0,0,0,GETDATE() --Provider: SCHULTZ, TARA L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1014809','0~EXT',0,0,0,0,GETDATE() --Provider: SEGREST, MORGAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~128321','0~EXT',0,0,0,0,GETDATE() --Provider: SEVER, CHARLES ALLEN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111050','0~EXT',0,0,0,0,GETDATE() --Provider: SHAHSAVARI, MEHRAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104827','0~EXT',0,0,0,0,GETDATE() --Provider: SHAW, TANNA M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104829','0~EXT',0,0,0,0,GETDATE() --Provider: SHEARER, CHRISTOPHER; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~135471','0~EXT',0,0,0,0,GETDATE() --Provider: SHORT, RENEE E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110253','0~EXT',0,0,0,0,GETDATE() --Provider: SHRECK, GARRICK L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110352','0~EXT',0,0,0,0,GETDATE() --Provider: SHULTZ, AMY L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1011642','0~EXT',0,0,0,0,GETDATE() --Provider: SMALL, TINA C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~125668','0~HPICH',1,0,0,0,GETDATE() --Provider: SMITH, JACK B; Practice: HPI CH
INSERT INTO map.EpicPracticeProviders SELECT '5~P1010153','0~EXT',0,0,0,0,GETDATE() --Provider: SNAPP, TAYLOR; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105047','0~EXT',0,0,0,0,GETDATE() --Provider: SPENCE, LISA L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1005721','0~EXT',0,0,0,0,GETDATE() --Provider: SPILLARS, RODGER BRANNON; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113427','0~EXT',0,0,0,0,GETDATE() --Provider: STAFFORD, BRUCE A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111893','0~EXT',1,0,0,0,GETDATE() --Provider: STANEK, SHEILA J; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~105862','0~EXT',0,0,0,0,GETDATE() --Provider: STANLEY, BRENNA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1019575','0~EXT',0,0,0,0,GETDATE() --Provider: STOVALL, CAMRYN TRICE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~128500','0~EXT',0,0,0,0,GETDATE() --Provider: STRELLER, JESSICA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000128','0~EXT',0,0,0,0,GETDATE() --Provider: STUDEBAKER, MARION KENT; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1028643','0~EXT',0,0,0,0,GETDATE() --Provider: SVAST, MAJA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~135488','0~EXT',0,0,0,0,GETDATE() --Provider: TAYLOR, JENNA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1016330','0~EXT',0,0,0,0,GETDATE() --Provider: TERRELL, KAYLEE DAWN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008323','0~EXT',0,0,0,0,GETDATE() --Provider: TRAN VY AI; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105432','0~EXT',1,0,0,0,GETDATE() --Provider: TRUONG, TERRENCE; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001259','0~EXT',0,0,0,0,GETDATE() --Provider: URICE, TOMAS DUKE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109468','0~EXT',0,0,0,0,GETDATE() --Provider: VERAGIWALA, JIGNESH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000124','0~EXT',0,0,0,0,GETDATE() --Provider: VERONNEAU, BETTINA G; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~126670','0~EXT',1,0,0,0,GETDATE() --Provider: VIRDI, JASPREET K; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1016261','0~EXT',0,0,0,0,GETDATE() --Provider: WALKER, MELISSA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~122812','0~EXT',0,0,0,0,GETDATE() --Provider: WALTER, JEFFREY SCOTT; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000512','0~EXT',0,0,0,0,GETDATE() --Provider: WARD, MARY ANN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000537','0~EXT',0,0,0,0,GETDATE() --Provider: WATSON, JACQUELINE R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105751','0~EXT',0,0,0,0,GETDATE() --Provider: WILCOX, CHRISTINE E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105757','0~EXT',0,0,0,0,GETDATE() --Provider: WILKE, ALISHA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000183','0~EXT',0,0,0,0,GETDATE() --Provider: WILLIAMS, JOHN DAVID; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111615','0~EXT',1,0,0,0,GETDATE() --Provider: WILSON, BRADLEY A; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~105843','0~EXT',0,0,0,0,GETDATE() --Provider: WILSON, RYAN D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113466','0~EXT',0,0,0,0,GETDATE() --Provider: WOOD, CARRIE A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~141209','0~EXT',1,0,0,0,GETDATE() --Provider: YABLUCHANSKA, VALERIYA; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1004060','0~EXT',0,0,0,0,GETDATE() --Provider: YOUNG, TIMOTHY EARL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104665','0~EXT',1,0,0,1,GETDATE() --Provider: SAMARA, ESBER NABEEH SHEA; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~108355','0~EXT',0,0,0,0,GETDATE() --Provider: ROBERTS, DAVID N; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~104988','0~EXT',0,0,0,0,GETDATE() --Provider: SMITH, MARCUS; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001370','0~EXT',0,0,0,0,GETDATE() --Provider: BEALL, DOUGLAS P; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1024157','0~EXT',0,0,0,0,GETDATE() --Provider: FALTER, JENNIFER L; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~109585','0~EXT',1,0,0,0,GETDATE() --Provider: ROGERS, CRAIG A; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1027528','0~EXT',0,0,0,0,GETDATE() --Provider: BURKE, JOHN FREDERICK; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~100508','0~EXT',0,0,0,0,GETDATE() --Provider: BOOTH, KELEY J; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~103777','0~EXT',0,0,0,0,GETDATE() --Provider: MORRIS, JENNIFER M; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~110122','0~EXT',0,0,0,0,GETDATE() --Provider: SMITH, KIMBERLY S; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~111176','0~EXT',0,0,0,0,GETDATE() --Provider: LAM, YAOHAN; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~113779','0~EXT',0,0,0,0,GETDATE() --Provider: HAPANI, SANJAYKUMAR J; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~120036','0~EXT',0,0,0,0,GETDATE() --Provider: NOLLIN, ZACHARY MYLES; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~140826','0~EXT',1,0,0,0,GETDATE() --Provider: ALLEGRA, PAUL R; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~110320','0~EXT',0,0,0,0,GETDATE() --Provider: JUSTIZ, ALINA C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110687','0~EXT',0,0,0,0,GETDATE() --Provider: SHIPLEY, WINSTON D II; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1013881','0~EXT',0,0,0,0,GETDATE() --Provider: BOYDSTUN, SETH MICHAEL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114808','0~EXT',0,0,0,0,GETDATE() --Provider: HAMATI, JOSEPH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000659','0~EXT',0,0,0,0,GETDATE() --Provider: ROUGAS, STACIE E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1009679','0~EXT',0,0,0,0,GETDATE() --Provider: BURK, KANDICE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113844','0~EXT',0,0,0,0,GETDATE() --Provider: DE LA GARZA, SCOTT M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~138875','0~EXT',0,0,0,0,GETDATE() --Provider: KOWACK, SHILANA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104734','0~EXT',0,0,0,0,GETDATE() --Provider: SCHNITZ, WILLIAM M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1021347','0~EXT',1,0,0,1,GETDATE() --Provider: SHARRAH, DAVID; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~135764','0~EXT',0,0,0,0,GETDATE() --Provider: THOMAS, JONES P; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108637','0~EXT',0,0,0,0,GETDATE() --Provider: UHLAND, ZANE E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105469','0~EXT',0,0,0,0,GETDATE() --Provider: VALENTINE, NATHAN I; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105476','0~EXT',0,0,0,0,GETDATE() --Provider: VANHOOSER, DAVID W; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105526','0~EXT',0,0,0,0,GETDATE() --Provider: VISOR, RICKY L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000198','0~EXT',0,0,0,0,GETDATE() --Provider: AARON, MICHAEL E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107001','0~EXT',0,0,0,0,GETDATE() --Provider: ABBAS, SYED A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002906','0~EXT',1,0,0,0,GETDATE() --Provider: ADAMS, JARED M; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1029357','0~EXT',0,0,0,0,GETDATE() --Provider: AINSWORTH, JARED; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~133848','0~EXT',0,0,0,0,GETDATE() --Provider: ALVA, NISHITH N; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1017368','0~EXT',0,0,0,0,GETDATE() --Provider: APLIN, ZACHREY DOUGLAS; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~131790','0~EXT',0,0,0,0,GETDATE() --Provider: ARIKAPUDI, SOWMINYA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109220','0~EXT',0,0,0,0,GETDATE() --Provider: ASHOK, KRISHNAMURTHY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107054','0~EXT',0,0,0,0,GETDATE() --Provider: ASLAM, RIZWAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001126','0~EXT',0,0,0,0,GETDATE() --Provider: ATTERBERRY, ANGELA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109224','0~EXT',0,0,0,0,GETDATE() --Provider: BADGETT, BLAKE A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1018991','0~EXT',0,0,0,0,GETDATE() --Provider: BAKER, DUSTIN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1020540','0~EXT',0,0,0,0,GETDATE() --Provider: BARREIRO, GUILHERME CARDINALI; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~125290','0~EXT',0,0,0,0,GETDATE() --Provider: BARRETT, CORTNEY L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100309','0~EXT',0,0,0,0,GETDATE() --Provider: BASS, BRANDI N; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~122529','0~EXT',0,0,0,0,GETDATE() --Provider: BATTON, AARON ROSE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110713','0~EXT',0,0,0,0,GETDATE() --Provider: BLAKEBURN, ROBERT V; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~142900','0~EXT',1,0,0,0,GETDATE() --Provider: BLOCK JR, JAMES P; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~107147','0~EXT',0,0,0,0,GETDATE() --Provider: BLUTH, BRIAN, L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~125161','0~HPICH',1,0,0,0,GETDATE() --Provider: BOGGS, MELANIE S; Practice: HPI CH
INSERT INTO map.EpicPracticeProviders SELECT '5~131650','0~EXT',0,0,0,0,GETDATE() --Provider: BOUKNIGHT, ASHLEY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100528','0~EXT',0,0,0,0,GETDATE() --Provider: BOWEN, DINA M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1020071','0~THP',0,0,0,0,GETDATE() --Provider: BROWN, DEAN; Practice: Total Healthcare Partners
INSERT INTO map.EpicPracticeProviders SELECT '5~P1031064','0~EXT',0,0,0,0,GETDATE() --Provider: BURGET, BRAD; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1010064','0~EXT',0,0,0,0,GETDATE() --Provider: BURTON, SHERRIE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100732','0~EXT',1,0,0,0,GETDATE() --Provider: BUYTEN, JEFFREY A; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~117552','0~EXT',0,0,0,0,GETDATE() --Provider: CARTER, REBECCA KATHLEEN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1005115','0~EXT',0,0,0,0,GETDATE() --Provider: CHANSKI, ALICIA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~133153','0~EXT',1,0,0,0,GETDATE() --Provider: CHARBENEAU, SHEA; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000528','0~EXT',0,0,0,0,GETDATE() --Provider: CHESSER, WILLIAM H; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008411','0~EKK',1,1,0,0,GETDATE() --Provider: CHESSMORE, KEVIN; Practice: E. Kim King, M.D.
INSERT INTO map.EpicPracticeProviders SELECT '5~100947','0~EXT',1,0,0,0,GETDATE() --Provider: CLAPP, TODD D; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1005248','0~EXT',0,0,0,0,GETDATE() --Provider: COCHRAN, ASHLEY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113818','0~EXT',0,0,0,0,GETDATE() --Provider: COLE, JEREMY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~125175','0~EXT',0,0,0,0,GETDATE() --Provider: COOK, BETHANY J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101108','0~EXT',0,0,0,0,GETDATE() --Provider: COSBY, DONNA R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1029652','0~EXT',0,0,0,0,GETDATE() --Provider: COX, ANTHONY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113011','0~EXT',0,0,0,0,GETDATE() --Provider: CUMMINGS, STEVEN W; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1007597','0~EXT',0,0,0,0,GETDATE() --Provider: DAVIS, CASSIE ELIZABETH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111373','0~EXT',0,0,0,0,GETDATE() --Provider: DAVIS, MITCHELL R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001701','0~EXT',0,0,0,0,GETDATE() --Provider: DAWSON, DAVID  WARREN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111987','0~EXT',0,0,0,0,GETDATE() --Provider: DEARMAN, ERICA D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~130325','0~EXT',1,0,0,0,GETDATE() --Provider: DEBERRY, INDIGO; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~101332','0~EXT',0,0,0,0,GETDATE() --Provider: DEWITT, CHRISTI R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1028847','0~EXT',0,0,0,0,GETDATE() --Provider: DIEZ-AVILA, LUIS; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114079','0~EXT',0,0,0,0,GETDATE() --Provider: DODSON, JODI M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101370','0~EXT',0,0,0,0,GETDATE() --Provider: DOMEK, DAVID B; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101388','0~EXT',0,0,0,0,GETDATE() --Provider: DOWNS, KRISTEN A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101409','0~EXT',0,0,0,0,GETDATE() --Provider: DRIVER, WHITNEY C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109276','0~EXT',0,0,0,0,GETDATE() --Provider: DUFFY, KENNETH M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101425','0~EXT',0,0,0,0,GETDATE() --Provider: DUMIGAN, RONALD MATTHEW; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1005126','0~EXT',0,0,0,0,GETDATE() --Provider: EDMINSTEN, CHAD STEVEN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107441','0~EXT',1,0,0,0,GETDATE() --Provider: ELLIS, JOHN W; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~137182','0~EXT',0,0,0,0,GETDATE() --Provider: ELLSWORTH, JOSHUA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101601','0~EXT',0,0,0,0,GETDATE() --Provider: FERRELL, CHARLES W; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1019893','0~THP',1,1,0,0,GETDATE() --Provider: FISHER, DAVID; Practice: Total Healthcare Partners
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000271','0~EXT',0,0,0,0,GETDATE() --Provider: FLORES, CATHERINE BARRETT; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101656','0~EXT',0,0,0,0,GETDATE() --Provider: FONG, DANIEL NELSON; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~140512','0~EXT',1,0,0,0,GETDATE() --Provider: FORD, KASSIDY; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~132581','0~EXT',1,0,0,0,GETDATE() --Provider: GIUSTI, JESSICA REYES; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~107562','0~EXT',0,0,0,0,GETDATE() --Provider: GODDARD, MICHAEL W; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1017791','0~EXT',1,0,0,0,GETDATE() --Provider: GOODSPEED, HANNAH R; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~110915','0~EXT',0,0,0,0,GETDATE() --Provider: GORDON, ELY R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001162','0~EXT',0,0,0,0,GETDATE() --Provider: HAGAN, CYNTHIA ANN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110140','0~EXT',0,0,0,0,GETDATE() --Provider: HAGGINS, SYDNEY E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1018268','0~EXT',0,0,0,0,GETDATE() --Provider: HAHN, KAYLA MARIE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008514','0~EXT',0,0,0,0,GETDATE() --Provider: HALL, KATHRYN A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~121549','0~EXT',0,0,0,0,GETDATE() --Provider: HARRIS, JERRUS; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1027944','0~EXT',0,0,0,0,GETDATE() --Provider: HATLEY, PHILLIP CRAIG; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~119665','0~THP',0,0,0,0,GETDATE() --Provider: HAUCK, CHRISTINE RENEE; Practice: Total Healthcare Partners
INSERT INTO map.EpicPracticeProviders SELECT '5~110533','0~EXT',0,0,0,0,GETDATE() --Provider: HESTER, CASEY N; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1004863','0~EXT',0,0,0,0,GETDATE() --Provider: HIGHLEY, CHRISTINA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1025168','0~EXT',0,0,0,0,GETDATE() --Provider: HIGHTOWER, RYAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107700','0~EXT',0,0,0,0,GETDATE() --Provider: HOLDEN, DAVID L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008241','0~EXT',0,0,0,0,GETDATE() --Provider: HOUGH, LACEY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110214','0~EXT',0,0,0,0,GETDATE() --Provider: HOUSMAN, ABBY M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112163','0~EXT',0,0,0,0,GETDATE() --Provider: HSIEH, MISTY D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1017747','0~EXT',0,0,0,0,GETDATE() --Provider: HUNTER, KALE JOSEPH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000185','0~EXT',0,0,0,0,GETDATE() --Provider: HUSER III, J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112365','0~EXT',0,0,0,0,GETDATE() --Provider: IVEY, JUNE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1028864','0~EXT',0,0,0,0,GETDATE() --Provider: JACKSON, RHETT; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~118042','0~EXT',0,0,0,0,GETDATE() --Provider: JARVIS, TAMMY KAY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~102647','0~EXT',0,0,0,0,GETDATE() --Provider: JOHNSON, CYNTHIA K; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1018838','0~EXT',0,0,0,0,GETDATE() --Provider: JOHNSON, MARIAH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1030116','0~EXT',0,0,0,0,GETDATE() --Provider: KENSHALO, MEGAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000061','0~EXT',0,0,0,0,GETDATE() --Provider: KIDWELL, TRACY ADELLE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114204','0~EXT',0,0,0,0,GETDATE() --Provider: KIPPENBERGER, LISA D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1011501','0~EXT',0,0,0,0,GETDATE() --Provider: KNEDLER, KAITLYN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109333','0~EXT',0,0,0,0,GETDATE() --Provider: KRABLIN, JAMES B; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008152','0~EXT',0,0,0,0,GETDATE() --Provider: KRAMER, KATHRYN MARIE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~102927','0~EXT',0,0,0,0,GETDATE() --Provider: KROUS, TIMOTHY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1030313','0~EXT',0,0,0,0,GETDATE() --Provider: KUMAR, ANJAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103036','0~EXT',0,0,0,0,GETDATE() --Provider: LAYNE, KEITH R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1032477','0~EXT',0,0,0,0,GETDATE() --Provider: LEE, HAEJUN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~127416','0~EXT',0,0,0,0,GETDATE() --Provider: LEWIS, TAYLOR; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113230','0~EXT',0,0,0,0,GETDATE() --Provider: LEWIS, THOMAS R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1004556','0~EXT',0,0,0,0,GETDATE() --Provider: LICH, BRIAN F; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103140','0~EXT',0,0,0,0,GETDATE() --Provider: LITTLE, KATHERINE S; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103154','0~EXT',0,0,0,0,GETDATE() --Provider: LO, PATRICK P; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103155','0~EXT',0,0,0,0,GETDATE() --Provider: LOCKWOOD, ROBERT J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000228','0~EXT',0,0,0,0,GETDATE() --Provider: LONG, JONATHON RAY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113365','0~EXT',0,0,0,0,GETDATE() --Provider: LOVE, VERNON M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111243','0~EXT',1,0,0,0,GETDATE() --Provider: LUO, JINHE; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1017789','0~EXT',0,0,0,0,GETDATE() --Provider: MACH, ALEXANDER CUOC-CUONG; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1026551','0~EXT',0,0,0,0,GETDATE() --Provider: MAH-MCCAA, BRENDA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109353','0~EXT',0,0,0,0,GETDATE() --Provider: MAIDT, MICHAEL L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110796','0~EXT',0,0,0,0,GETDATE() --Provider: MANN, MARK B; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109847','0~EXT',0,0,0,0,GETDATE() --Provider: MANNING-PLAIN, JOY A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103303','0~HPICH',1,0,0,0,GETDATE() --Provider: MARTENS, JEFFREY D; Practice: HPI CH
INSERT INTO map.EpicPracticeProviders SELECT '5~114253','0~EXT',0,0,0,0,GETDATE() --Provider: MATHEW, FEBI R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110679','0~EXT',0,0,0,0,GETDATE() --Provider: MATSON, ROBIN L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~129131','0~EXT',0,0,0,0,GETDATE() --Provider: MCDANIEL, KERRIE D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114266','0~EXT',0,0,0,0,GETDATE() --Provider: MCGUIRE, CARRIE H; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000948','0~EXT',0,0,0,0,GETDATE() --Provider: MEDINA, ANDRIA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108053','0~EXT',0,0,0,0,GETDATE() --Provider: MENDOZA, YADER A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~115467','0~EXT',0,0,0,0,GETDATE() --Provider: MERRELL, MICHELLE KATHLEEN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1013856','0~EXT',0,0,0,0,GETDATE() --Provider: MIMS, MARK MATTHEW; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109370','0~EXT',0,0,0,0,GETDATE() --Provider: MITCHELL, CHARLES H; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103710','0~EXT',1,0,0,0,GETDATE() --Provider: MOHAMMAD, SHIRIN N; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1012610','0~EXT',0,0,0,0,GETDATE() --Provider: MORGAN, JEREMY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109373','0~EXT',1,0,0,0,GETDATE() --Provider: MOSER, TIMOTHY J; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~111356','0~EXT',0,0,0,0,GETDATE() --Provider: NASR, FAYSAL L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001785','0~EXT',0,0,0,0,GETDATE() --Provider: NELSON, BRADLEY D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1004720','0~EXT',0,0,0,0,GETDATE() --Provider: NESBIT, WILLIAM HUGH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113913','0~EXT',0,0,0,0,GETDATE() --Provider: NGUYEN, TUAN A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112651','0~EXT',0,0,0,0,GETDATE() --Provider: ODEN, RYAN W; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1026627','0~EXT',0,0,0,0,GETDATE() --Provider: OYERINDE, TOYIN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113971','0~EXT',0,0,0,0,GETDATE() --Provider: PARKER, LACY ELISE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109387','0~EXT',0,0,0,0,GETDATE() --Provider: PAULS, RONALD E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1015123','0~EXT',0,0,0,0,GETDATE() --Provider: PETERS, GRACE ELIZABETH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104221','0~EXT',0,0,0,0,GETDATE() --Provider: PHILIP, NEENA S; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1018877','0~EXT',0,0,0,0,GETDATE() --Provider: PICKLE, TAWNA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109510','0~EXT',0,0,0,0,GETDATE() --Provider: PROVIDER, NO PCP; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~119937','0~EXT',0,0,0,0,GETDATE() --Provider: PROVOST, JESSICA RAE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~120104','0~EXT',0,0,0,0,GETDATE() --Provider: REDD, LATOSHA L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~118234','0~EXT',0,0,0,0,GETDATE() --Provider: RESNEDER, JOHN RAY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114446','0~EXT',0,0,0,0,GETDATE() --Provider: RHODES, MANDI BROOKE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108332','0~EXT',0,0,0,0,GETDATE() --Provider: RICHARDS, WENDELL L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002216','0~EXT',0,0,0,0,GETDATE() --Provider: RICHARDSON, MICHAEL SHANE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104503','0~EXT',0,0,0,0,GETDATE() --Provider: RICKNER, KYLE W; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104522','0~EXT',0,0,0,0,GETDATE() --Provider: RITCHIE, JANET; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104620','0~EXT',1,0,0,0,GETDATE() --Provider: ROYSTON, JAYME; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000207','0~EXT',0,0,0,0,GETDATE() --Provider: RUFFIN, LARRY LEE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1003877','0~EXT',0,0,0,0,GETDATE() --Provider: RUSSELL, GEORGE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114301','0~EXT',0,0,0,0,GETDATE() --Provider: SANDERS, BILLY G; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113328','0~EXT',0,0,0,0,GETDATE() --Provider: SANNER, MARTY K; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104688','0~EXT',0,0,0,0,GETDATE() --Provider: SATZLER, NANCY S; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1017141','0~EXT',0,0,0,0,GETDATE() --Provider: SHARMA, RAJESH KUMAR; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~124741','0~EXT',0,0,0,0,GETDATE() --Provider: SHIRAZI, CAMERON P; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000742','0~EXT',0,0,0,0,GETDATE() --Provider: SHIRK, LARA EILEEN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000411','0~EXT',0,0,0,0,GETDATE() --Provider: SHORT, JAMES R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~130312','0~EXT',0,0,0,0,GETDATE() --Provider: SIDDIQUI, ANAS; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~119424','0~EXT',0,0,0,0,GETDATE() --Provider: SIMON, ALLIE S; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000745','0~EXT',0,0,0,0,GETDATE() --Provider: SIMPSON, JEANIE KAY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104917','0~EXT',0,0,0,0,GETDATE() --Provider: SINGH, RAM A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~133617','0~EXT',0,0,0,0,GETDATE() --Provider: SMITH, DANNYEL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000471','0~EXT',0,0,0,0,GETDATE() --Provider: SMITH, JONATHAN J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109440','0~EXT',0,0,0,0,GETDATE() --Provider: SMITHTON, CORBY W; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1027088','0~EXT',0,0,0,0,GETDATE() --Provider: STEPHENS, STEPHANIE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108557','0~EXT',0,0,0,0,GETDATE() --Provider: STRAMSKI, ROBERT S; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000069','0~EXT',0,0,0,0,GETDATE() --Provider: STUART, DANNA KAY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111704','0~EXT',0,0,0,0,GETDATE() --Provider: STUBBS, SCOTT N; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110314','0~EXT',0,0,0,0,GETDATE() --Provider: SWENSON, RICHARD T; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105235','0~EXT',0,0,0,0,GETDATE() --Provider: TAN, SALLY Q; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105237','0~EXT',0,0,0,0,GETDATE() --Provider: TARON, TRISHA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1020173','0~EXT',0,0,0,0,GETDATE() --Provider: TAYLOR, STEPHANIE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111104','0~EXT',0,0,0,0,GETDATE() --Provider: TAYLOR-BRISTOW, SHELEATHA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~139423','0~EXT',0,0,0,0,GETDATE() --Provider: THOMAS, BEENA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100618','0~EXT',0,0,0,0,GETDATE() --Provider: THOMAS, KACI D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1010817','0~EXT',0,0,0,0,GETDATE() --Provider: TRAN, LILLIAN TUYEN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1010531','0~EXT',0,0,0,0,GETDATE() --Provider: TRAN, QUY TIEN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105465','0~EXT',0,0,0,0,GETDATE() --Provider: UPTON, ANGELA D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~121458','0~EXT',0,0,0,0,GETDATE() --Provider: VIRGIL, WHITLEY DANIELLE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000644','0~EXT',0,0,0,0,GETDATE() --Provider: WALKER, LINDSI R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101005','0~EXT',0,0,0,0,GETDATE() --Provider: WATKINS, SALLYE B; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~115488','0~EXT',0,0,0,0,GETDATE() --Provider: WHEELER, DEANNA JOY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109492','0~EXT',0,0,0,0,GETDATE() --Provider: WIGHT, JAMES F; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000804','0~EXT',0,0,0,0,GETDATE() --Provider: WILLIAMSON, AUBREY E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105888','0~EXT',1,0,0,0,GETDATE() --Provider: WOOD, MARK W; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001769','0~EXT',0,0,0,0,GETDATE() --Provider: YOUNG, JESSICA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114835','0~EXT',0,0,0,0,GETDATE() --Provider: ZEAVIN, SPENCER TRACY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109160','0~EXT',0,0,0,0,GETDATE() --Provider: ZIMMERMAN, BROOKS; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101855','0~EXT',1,0,0,0,GETDATE() --Provider: GILCHRIST, JOHN MARK; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~103530','0~EXT',1,0,0,0,GETDATE() --Provider: MCLAUGHLIN, MICHAEL P; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1017846','0~NBN',1,0,1,0,GETDATE() --Provider: NGUYEN, NGOC BAO THI; Practice: Ngoc Nguyen, M.D.
INSERT INTO map.EpicPracticeProviders SELECT '5~104875','0~EXT',0,0,0,0,GETDATE() --Provider: SHOWALTER III, THOMAS; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~109093','0~EXT',0,0,0,0,GETDATE() --Provider: SALINS, SALOMI T; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~122527','0~EXT',0,0,0,0,GETDATE() --Provider: SUHAIB, OMER; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1003144','0~EXT',1,0,0,1,GETDATE() --Provider: HIGLEY, JARED PRESTON; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~131725','0~EXT',0,0,0,0,GETDATE() --Provider: SMITH, ZACHARY D; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~103607','0~EXT',0,0,0,0,GETDATE() --Provider: META, GENTIAN; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001256','0~EXT',0,0,0,0,GETDATE() --Provider: STIDHAM, SHANE EDWARD; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1010378','0~EXT',0,0,0,0,GETDATE() --Provider: NGUYEN, DAN THACH DAM; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~107276','0~EXT',0,0,0,0,GETDATE() --Provider: CLAPP, JANAE M; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~110601','0~EXT',0,0,0,0,GETDATE() --Provider: SPENCE, CAPLE A; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~108729','0~EXT',0,0,0,0,GETDATE() --Provider: WHITE, JEREMY R; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~143697','0~NRJ',1,0,1,0,GETDATE() --Provider: JOHNSON, NICK; Practice: Nicholas R. Johnson, M.D.
INSERT INTO map.EpicPracticeProviders SELECT '5~120037','0~EXT',0,0,0,0,GETDATE() --Provider: ROOT, GREGORY PHILLIP; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110260','0~EXT',0,0,0,0,GETDATE() --Provider: JUSTIZ, RAFAEL   III; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104069','0~EXT',0,0,0,0,GETDATE() --Provider: OWENS, MICHAEL C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~102073','0~EXT',0,0,0,0,GETDATE() --Provider: HALKO, GREG E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1016119','0~EXT',0,0,0,0,GETDATE() --Provider: OKLAHOMA, ALLERGY & ASTHMA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104624','0~EXT',0,0,0,0,GETDATE() --Provider: RUFFIN, RICHARD A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1007966','0~EXT',0,0,0,0,GETDATE() --Provider: STRAEHLA, LEILA MAE MCKENZIE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100828','0~EXT',0,0,0,0,GETDATE() --Provider: CARSON, CRAIG W; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113499','0~EXT',0,0,0,0,GETDATE() --Provider: HENNEBRY, THOMAS A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1027558','0~EXT',0,0,0,0,GETDATE() --Provider: LOPEZ, MARTIN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103226','0~EXT',0,0,0,0,GETDATE() --Provider: MACK, ALEICIA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112658','0~EXT',0,0,0,0,GETDATE() --Provider: MORTON, JORDAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103967','0~EXT',0,0,0,0,GETDATE() --Provider: NOUH, AMER B; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113868','0~EXT',0,0,0,0,GETDATE() --Provider: PREVO, PATRICK T; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108428','0~EXT',0,0,0,0,GETDATE() --Provider: SCHRADER, JOHN O; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113422','0~EXT',0,0,0,0,GETDATE() --Provider: WIENECKE, GRETCHEN M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001097','0~EXT',1,0,0,0,GETDATE() --Provider: WOOTTON, COLE WAYNE; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~117336','0~EXT',0,0,0,0,GETDATE() --Provider: BELLINGER, SAMANTHA ANN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1018331','0~EXT',0,0,0,0,GETDATE() --Provider: CONCENTRA, MEDICAL CENTERS; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101396','0~EXT',0,0,0,0,GETDATE() --Provider: DRAELOS, MATTHEW T; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111702','0~EXT',0,0,0,0,GETDATE() --Provider: ERTL, WILLIAM J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1012977','0~EXT',0,0,0,0,GETDATE() --Provider: FURR, JAMES; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101917','0~EXT',0,0,0,0,GETDATE() --Provider: GOODELL, RONALD JEFFREY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110323','0~EXT',0,0,0,0,GETDATE() --Provider: KENNEDY, DIANA L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103203','0~EXT',0,0,0,0,GETDATE() --Provider: LOWE, JULIE B; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~136510','0~EXT',0,0,0,0,GETDATE() --Provider: MASHBURN, SARAH G; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112327','0~EXT',1,0,0,0,GETDATE() --Provider: MAYO, COREY E; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~111774','0~EXT',0,0,0,0,GETDATE() --Provider: PUCKETT, TIMOTHY A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104769','0~EXT',0,0,0,0,GETDATE() --Provider: SCOTT, LANCE V; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105232','0~EXT',0,0,0,0,GETDATE() --Provider: TAHIRKHELI, NAEEM K; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1029337','0~EXT',0,0,0,0,GETDATE() --Provider: TURPIN, BROCK; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001841','0~EXT',0,0,0,0,GETDATE() --Provider: WHITE, CHRISTOPHER B; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110878','0~EXT',0,0,0,0,GETDATE() --Provider: ABOU ELMAGD, AHMED; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001801','0~EXT',0,0,0,0,GETDATE() --Provider: ACRE, BETH HOLDERBY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100041','0~EXT',0,0,0,0,GETDATE() --Provider: ADHAM, MEHDI N; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~118590','0~EXT',0,0,0,0,GETDATE() --Provider: AHMAD, BILAL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100062','0~EXT',0,0,0,0,GETDATE() --Provider: ALASAD, BASHAR S; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~121835','0~EXT',0,0,0,0,GETDATE() --Provider: ALI, HANIA M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100083','0~EXT',0,0,0,0,GETDATE() --Provider: ALI, MUNAWAR; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1023352','0~EXT',0,0,0,0,GETDATE() --Provider: ALLEN, KEELY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000933','0~EXT',0,0,0,0,GETDATE() --Provider: ALLEN, KIMBERLY A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1014537','0~EXT',0,0,0,0,GETDATE() --Provider: ALVILLAR, STEPHANIE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1003266','0~EXT',0,0,0,0,GETDATE() --Provider: AMPARANO, ANGELA DONNICE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113150','0~EXT',0,0,0,0,GETDATE() --Provider: ANDERSON, DAVID R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100128','0~EXT',0,0,0,0,GETDATE() --Provider: ANDERSON, GARY B; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~130623','0~EXT',0,0,0,0,GETDATE() --Provider: ANDERSON, HANNAH F; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000176','0~EXT',0,0,0,0,GETDATE() --Provider: ANDERSON, MICHAEL BLAKE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1006023','0~EXT',0,0,0,0,GETDATE() --Provider: ANGEL, SHERYL WESLEY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~124616','0~EXT',0,0,0,0,GETDATE() --Provider: ANTO, LAUREN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1013810','0~EXT',0,0,0,0,GETDATE() --Provider: APRIL, SULLIVAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109221','0~EXT',1,0,0,0,GETDATE() --Provider: ASIF, SHAHIDA; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1026361','0~EXT',0,0,0,0,GETDATE() --Provider: AYISI, GLORIA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002973','0~EXT',0,0,0,0,GETDATE() --Provider: BAGGETT, STEPANKA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~115270','0~EXT',0,0,0,0,GETDATE() --Provider: BAKER, BRIAN BRODY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113730','0~EXT',0,0,0,0,GETDATE() --Provider: BAKER, MARY Z; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~126977','0~EXT',0,0,0,0,GETDATE() --Provider: BALDWIN, CHARLEY C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1004792','0~EXT',0,0,0,0,GETDATE() --Provider: BANSAL, SHIVENDRA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1029931','0~EXT',0,0,0,0,GETDATE() --Provider: BARRON, LINDSAY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000576','0~EXT',0,0,0,0,GETDATE() --Provider: BARTLOW, ANGELA DIANE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1032171','0~EXT',0,0,0,0,GETDATE() --Provider: BARTNICKI, CAREY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000270','0~EXT',0,0,0,0,GETDATE() --Provider: BARVE, ARCHANA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1006148','0~EXT',0,0,0,0,GETDATE() --Provider: BATTERSHELL, MCKENZIE M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107101','0~EXT',0,0,0,0,GETDATE() --Provider: BAYLOR, DUSTIN L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1010934','0~EXT',0,0,0,0,GETDATE() --Provider: BEACH, SHAYLEA DAWN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001805','0~EXT',0,0,0,0,GETDATE() --Provider: BEAMON, SHELBY MATTHIAS; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~125208','0~EXT',0,0,0,0,GETDATE() --Provider: BEAN, ANDREA ANN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111546','0~EXT',0,0,0,0,GETDATE() --Provider: BEAVERS, JOHN ERIC; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~115464','0~EXT',0,0,0,0,GETDATE() --Provider: BENTLEY, JAYNE ANN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107117','0~EXT',0,0,0,0,GETDATE() --Provider: BERENDS, JENNIFER L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1003022','0~EXT',0,0,0,0,GETDATE() --Provider: BESHAW, MICHELLE MARIE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1004073','0~EXT',0,0,0,0,GETDATE() --Provider: BILLINGS, CHRISTOPHER W; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~138657','0~EXT',0,0,0,0,GETDATE() --Provider: BOGNER, ANGELA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000130','0~EXT',1,0,0,0,GETDATE() --Provider: BOTCHLET, SARA MARIE; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~100524','0~EXT',0,0,0,0,GETDATE() --Provider: BOVA, ABBY R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1013350','0~EXT',0,0,0,0,GETDATE() --Provider: BRANTON, RACHEL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107172','0~EXT',0,0,0,0,GETDATE() --Provider: BRIGGS, PAUL A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1019936','0~EXT',0,0,0,0,GETDATE() --Provider: BROWN, JAMES; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111416','0~EXT',0,0,0,0,GETDATE() --Provider: BROWN, SAMUEL D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~125303','0~EXT',0,0,0,0,GETDATE() --Provider: BRYAN, KIMBERLY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100691','0~EXT',0,0,0,0,GETDATE() --Provider: BULLOCK, PETER P; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~136922','0~EXT',0,0,0,0,GETDATE() --Provider: BURNEIKIS, TALIA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1004331','0~EXT',0,0,0,0,GETDATE() --Provider: BURTON, BEAU JAMES; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100722','0~EXT',0,0,0,0,GETDATE() --Provider: BUSHMAN, JONATHAN K; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~116138','0~EXT',0,0,0,0,GETDATE() --Provider: BUTLER, LESLIE DIANE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000064','0~EXT',0,0,0,0,GETDATE() --Provider: CECIL, JULIAN DAVID; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~124694','0~EXT',0,0,0,0,GETDATE() --Provider: CERO, KRISTLE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1018329','0~EXT',0,0,0,0,GETDATE() --Provider: CHA, HAE YOUNG; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110452','0~EXT',0,0,0,0,GETDATE() --Provider: CHANDLER, BRENT D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107260','0~EXT',0,0,0,0,GETDATE() --Provider: CHARBONEAU, SEMIRA, D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~119216','0~EXT',0,0,0,0,GETDATE() --Provider: CHAU, QUYNH DIEM; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~136573','0~EXT',0,0,0,0,GETDATE() --Provider: CHAUNCEY, JAMES BROWN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~127223','0~EXT',0,0,0,0,GETDATE() --Provider: CHERIAN, IVY R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110318','0~EXT',0,0,0,0,GETDATE() --Provider: CHIAFFITELLI, JOHN J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1004125','0~EXT',0,0,0,0,GETDATE() --Provider: CHILDS, CHARLES MARTIN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008549','0~EXT',0,0,0,0,GETDATE() --Provider: CHOATE, KASEY LEE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110682','0~EXT',0,0,0,0,GETDATE() --Provider: CHORLEY, DAVID N; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001628','0~EXT',0,0,0,0,GETDATE() --Provider: CLAYTON, LISA JEAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109800','0~EXT',0,0,0,0,GETDATE() --Provider: CLOUD, JOHN M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114865','0~EXT',0,0,0,0,GETDATE() --Provider: COFFEY, J CLIFTON; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1004486','0~EXT',0,0,0,0,GETDATE() --Provider: COFFMAN, DAMON HOLT; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1006294','0~EXT',0,0,0,0,GETDATE() --Provider: COLON-SANTIAGO, MARIBEL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~128565','0~EXT',0,0,0,0,GETDATE() --Provider: CONATSER, JARED; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109254','0~EXT',0,0,0,0,GETDATE() --Provider: CONNERY, LISA B; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107313','0~EXT',0,0,0,0,GETDATE() --Provider: COOK, MELVIN D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109258','0~EXT',0,0,0,0,GETDATE() --Provider: COPPEDGE, MITCHELL D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000323','0~EXT',0,0,0,0,GETDATE() --Provider: CORTEZ, MADELINE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1026299','0~EXT',0,0,0,0,GETDATE() --Provider: COSTULAS, ALENA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~121398','0~EXT',0,0,0,0,GETDATE() --Provider: COX, SARAH ELIZABETH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111248','0~EXT',0,0,0,0,GETDATE() --Provider: COX, STEVEN E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1005517','0~EXT',0,0,0,0,GETDATE() --Provider: CREEKMORE II, AERIC WYNN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~127847','0~EXT',0,0,0,0,GETDATE() --Provider: CROMER, BROOKE P; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1014816','0~EXT',0,0,0,0,GETDATE() --Provider: CROSS, SHEA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109267','0~EXT',0,0,0,0,GETDATE() --Provider: CROW, THOMAS R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~140864','0~EXT',1,0,0,0,GETDATE() --Provider: CROWE, WHITNEY L; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~112029','0~EXT',0,0,0,0,GETDATE() --Provider: DAVIS, ELISA A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114070','0~EXT',0,0,0,0,GETDATE() --Provider: DAVIS, MARK L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100889','0~EXT',0,0,0,0,GETDATE() --Provider: DEAN, MISTY D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1023431','0~EXT',0,0,0,0,GETDATE() --Provider: DECARVALHO, GABRIEL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101297','0~EXT',1,0,0,0,GETDATE() --Provider: DEDEKE, ERIC M; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~123252','0~EXT',0,0,0,0,GETDATE() --Provider: DEMPSEY, GARY B; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~129185','0~EXT',0,0,0,0,GETDATE() --Provider: DENSON, NEANS LYNN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1032608','0~EXT',0,0,0,0,GETDATE() --Provider: DESAI PANDYA, NIDHI; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1009054','0~EXT',0,0,0,0,GETDATE() --Provider: DICKEY, BRANDI; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1023715','0~EXT',0,0,0,0,GETDATE() --Provider: DO, THAI H; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111661','0~EXT',0,0,0,0,GETDATE() --Provider: DOESCHER, MARK P; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008764','0~EXT',0,0,0,0,GETDATE() --Provider: DRAPER, TERRY JEAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110515','0~EXT',0,0,0,0,GETDATE() --Provider: DUHON, LISA D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111061','0~EXT',0,0,0,0,GETDATE() --Provider: DUNCAN, JEFFREY A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~131425','0~EXT',0,0,0,0,GETDATE() --Provider: DUNN, SHANNON LEE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114086','0~EXT',0,0,0,0,GETDATE() --Provider: EAGLE, STORM M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114089','0~EXT',0,0,0,0,GETDATE() --Provider: EGGERS, SARAH JAYNE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1026661','0~EXT',0,0,0,0,GETDATE() --Provider: ELDER, HALLI J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112712','0~EXT',0,0,0,0,GETDATE() --Provider: ELDRIDGE, TIMOTHY J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107433','0~EXT',0,0,0,0,GETDATE() --Provider: ELENBURG, DARREN D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101506','0~EXT',0,0,0,0,GETDATE() --Provider: ELLIS, BRIAN T; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~144683','0~EXT',0,0,0,0,GETDATE() --Provider: ESTRERA, KENNETH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1010020','0~EXT',0,0,0,0,GETDATE() --Provider: ETHRIDGE, CAMERON KEITH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1021948','0~EXT',0,0,0,0,GETDATE() --Provider: FERGESON, MARK GLENNDON; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107472','0~EXT',0,0,0,0,GETDATE() --Provider: FERGUSON, KEENAN L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000592','0~EXT',0,0,0,0,GETDATE() --Provider: FIELDS, JUSTIN ELLIOT; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002175','0~EXT',0,0,0,0,GETDATE() --Provider: FIPPS, BRIAN KIRK; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101624','0~EXT',0,0,0,0,GETDATE() --Provider: FISHER, ERIN M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1003891','0~EXT',0,0,0,0,GETDATE() --Provider: FISHER, KAILEE RENEE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109656','0~EXT',0,0,0,0,GETDATE() --Provider: FITZGERALD, SHAWN ROBERT; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1010522','0~EXT',0,0,0,0,GETDATE() --Provider: FLETCHER, KRYSTAL DAWN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109284','0~EXT',0,0,0,0,GETDATE() --Provider: FLOYD, JEFFREY D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101657','0~EXT',0,0,0,0,GETDATE() --Provider: FONG, JUDY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1024954','0~EXT',0,0,0,0,GETDATE() --Provider: FOWLER, TRACYE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000281','0~EXT',0,0,0,0,GETDATE() --Provider: FOX, AUDRALAN GAYLE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~116255','0~EXT',0,0,0,0,GETDATE() --Provider: FRANCISCO, RAPHAEL C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112607','0~EXT',1,0,0,0,GETDATE() --Provider: FRANK, BRYAN L; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1013386','0~EXT',0,0,0,0,GETDATE() --Provider: FROST, JEREE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~140903','0~EXT',0,0,0,0,GETDATE() --Provider: FURLONG-SERVIN, VICTORIA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1009834','0~EXT',0,0,0,0,GETDATE() --Provider: GAGLIANO, MICHAEL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109288','0~EXT',0,0,0,0,GETDATE() --Provider: GARLAND, JACKIE W; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1026340','0~EXT',0,0,0,0,GETDATE() --Provider: GARRETT, AMBER; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107542','0~EXT',0,0,0,0,GETDATE() --Provider: GARVIN, JANET L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~115095','0~EXT',0,0,0,0,GETDATE() --Provider: GEARY, JAY ALAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109786','0~EXT',0,0,0,0,GETDATE() --Provider: GEOHAGAN, JENNA L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1027157','0~EXT',0,0,0,0,GETDATE() --Provider: GEORGE, SUSAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107554','0~EXT',0,0,0,0,GETDATE() --Provider: GIBSON, RENAH T; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1029904','0~EXT',0,0,0,0,GETDATE() --Provider: GIOVAN, MICHAEL P; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1007830','0~EXT',0,0,0,0,GETDATE() --Provider: GOODE, STACY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114958','0~EXT',0,0,0,0,GETDATE() --Provider: GOODWIN, AUDREY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1029233','0~EXT',0,0,0,0,GETDATE() --Provider: GREER, KRISTIN NICOLE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111421','0~EXT',0,0,0,0,GETDATE() --Provider: GRELLNER, RANDY J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~119572','0~EXT',0,0,0,0,GETDATE() --Provider: GRIFFIN, CODY WILLIAM; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~102004','0~EXT',0,0,0,0,GETDATE() --Provider: GRIM, STEPHANIE C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000065','0~EXT',0,0,0,0,GETDATE() --Provider: GROVES, PHILICIA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~117414','0~EXT',0,0,0,0,GETDATE() --Provider: GUTHRIE, JANICE DAWN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1004733','0~EXT',0,0,0,0,GETDATE() --Provider: HAAG, KATHRYN CARLITA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000088','0~EXT',0,0,0,0,GETDATE() --Provider: HAMMAN, TIMA SUZANNE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107614','0~EXT',0,0,0,0,GETDATE() --Provider: HANCOCK, RITA K; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109304','0~EXT',0,0,0,0,GETDATE() --Provider: HANIGAR, KIMBERLY K; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1020094','0~EXT',0,0,0,0,GETDATE() --Provider: HANLEY, KIMBERLY NOELLE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~135650','0~EXT',0,0,0,0,GETDATE() --Provider: HART, JORDAN KENDALL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~102222','0~EXT',0,0,0,0,GETDATE() --Provider: HAYNES, AMBER; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1003919','0~EXT',0,0,0,0,GETDATE() --Provider: HAYNES, REBECCA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1025364','0~EXT',0,0,0,0,GETDATE() --Provider: HEALTH CENTER, BETHANY CHILDRENS; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~102247','0~EXT',1,0,0,0,GETDATE() --Provider: HEINLEN, JONATHAN E; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002063','0~EXT',0,0,0,0,GETDATE() --Provider: HEISE, WILL D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~143668','0~EXT',1,0,0,0,GETDATE() --Provider: HENTHORN, TARA R; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~102287','0~EXT',0,0,0,0,GETDATE() --Provider: HERMANCE, TERRY C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1003931','0~EXT',1,0,0,0,GETDATE() --Provider: HERRIAN, TERRI L; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002939','0~EXT',0,0,0,0,GETDATE() --Provider: HERRING, MELISSA SHANAY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107670','0~EXT',0,0,0,0,GETDATE() --Provider: HESS, DON R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008727','0~EXT',0,0,0,0,GETDATE() --Provider: HESTON, MISTI; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109312','0~EXT',0,0,0,0,GETDATE() --Provider: HILL, DANIEL P; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~102337','0~EXT',0,0,0,0,GETDATE() --Provider: HISEY, BRENT N; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008271','0~EXT',0,0,0,0,GETDATE() --Provider: HOBBIE, TAMMY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1007347','0~EXT',0,0,0,0,GETDATE() --Provider: HOBBS, KRISTYN NICOLE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~102363','0~EXT',0,0,0,0,GETDATE() --Provider: HOFFSOMMER, JEFFREY G; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109313','0~EXT',0,0,0,0,GETDATE() --Provider: HOLDEN, JOHN W; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~120650','0~EXT',0,0,0,0,GETDATE() --Provider: HOOKER, JARED BLAKE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000103','0~EXT',0,0,0,0,GETDATE() --Provider: HOPKINS, DAVID; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000465','0~EXT',0,0,0,0,GETDATE() --Provider: HOWARD, BRONWYN L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000305','0~EXT',0,0,0,0,GETDATE() --Provider: HOWARD, JANIE L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~117558','0~EXT',0,0,0,0,GETDATE() --Provider: HOWELL, STEPHANIE FAITH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109318','0~EXT',0,0,0,0,GETDATE() --Provider: HUBANKS, JOHN M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~140804','0~EXT',0,0,0,0,GETDATE() --Provider: HUDSON, GEORGE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~140805','0~EXT',0,0,0,0,GETDATE() --Provider: HUDSON, HAYLEY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113678','0~EXT',0,0,0,0,GETDATE() --Provider: HULSEY, MARK A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109320','0~EXT',0,0,0,0,GETDATE() --Provider: HULSON, TERRILL L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1032237','0~EXT',0,0,0,0,GETDATE() --Provider: IANCU, MIHAI; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1006473','0~HPICH',1,0,0,0,GETDATE() --Provider: INTERWICZ, SCOTT R; Practice: HPI CH
INSERT INTO map.EpicPracticeProviders SELECT '5~107744','0~EXT',0,0,0,0,GETDATE() --Provider: IVORY, MATHEW J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110474','0~EXT',0,0,0,0,GETDATE() --Provider: JACKSON, SAMANTHA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1004869','0~EXT',0,0,0,0,GETDATE() --Provider: JACKSON, TROY WAYNE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001026','0~EXT',0,0,0,0,GETDATE() --Provider: JACOBS, LACEY KRISTINE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~102575','0~EXT',0,0,0,0,GETDATE() --Provider: JAMAL, JAWAID A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001093','0~EXT',0,0,0,0,GETDATE() --Provider: JEFFCOAT, LAURYN ROCHELLE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~142337','0~EXT',0,0,0,0,GETDATE() --Provider: JIMENEZ, SUSANA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002795','0~EXT',0,0,0,0,GETDATE() --Provider: JOHN, EMILY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1003106','0~EXT',0,0,0,0,GETDATE() --Provider: JOHNSON, BROOKELYN ANNETTE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111902','0~EXT',0,0,0,0,GETDATE() --Provider: JOHNSON, WAYNE A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112778','0~EXT',0,0,0,0,GETDATE() --Provider: JORDAN, KRISTEN D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~123088','0~EXT',0,0,0,0,GETDATE() --Provider: JOYKUTTY, SHIJY A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1010408','0~EXT',0,0,0,0,GETDATE() --Provider: JUDKINS, KYLE R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1020951','0~EXT',0,0,0,0,GETDATE() --Provider: JUENGEL, KACI BROOKE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107788','0~EXT',0,0,0,0,GETDATE() --Provider: KADIVAR, ARYAN, M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~102754','0~EXT',0,0,0,0,GETDATE() --Provider: KANG, BOBBY C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114200','0~EXT',0,0,0,0,GETDATE() --Provider: KENNEDY, HEATHER C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~128291','0~EXT',0,0,0,0,GETDATE() --Provider: KENNEDY, KARISA J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~127319','0~EXT',0,0,0,0,GETDATE() --Provider: KESSLER, HILLARIE ELAINE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1007752','0~EXT',0,0,0,0,GETDATE() --Provider: KIENKA, NANCY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001466','0~EXT',0,0,0,0,GETDATE() --Provider: KING, ANGELA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113581','0~EXT',0,0,0,0,GETDATE() --Provider: KIRKPATRICK, RICHARD A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114794','0~EXT',0,0,0,0,GETDATE() --Provider: KLINE, RILEY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1029340','0~EXT',0,0,0,0,GETDATE() --Provider: KLOSE, MICHAEL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1012563','0~EXT',0,0,0,0,GETDATE() --Provider: KLOSKE, JOANIE ELIZABETH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107850','0~EXT',1,0,0,0,GETDATE() --Provider: KNAPP, STACEY D; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~102891','0~EXT',0,0,0,0,GETDATE() --Provider: KNOX, KIM; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103514','0~EXT',1,0,0,0,GETDATE() --Provider: KOOMSON, MEREDITH; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000954','0~EXT',0,0,0,0,GETDATE() --Provider: KUEHNER, AMANDA LAUREN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1016566','0~EXT',0,0,0,0,GETDATE() --Provider: KURIAN, BEJOY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114217','0~EXT',0,0,0,0,GETDATE() --Provider: LAFARLETTE, AMANDA L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112493','0~EXT',0,0,0,0,GETDATE() --Provider: LAMKIN, BRIAN E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103010','0~EXT',0,0,0,0,GETDATE() --Provider: LANSINGER, YURI C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~115479','0~EXT',0,0,0,0,GETDATE() --Provider: LASHBROOK, DAPHNE LYNN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1007485','0~EXT',0,0,0,0,GETDATE() --Provider: LAUGHLIN, AMANDA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107881','0~EXT',0,0,0,0,GETDATE() --Provider: LE, JENNY T; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000063','0~EXT',0,0,0,0,GETDATE() --Provider: LEACHMAN-HAMMONS, JANEY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~115207','0~EXT',0,0,0,0,GETDATE() --Provider: LEAL, CHRISTIE ARNOLD; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1020728','0~EXT',0,0,0,0,GETDATE() --Provider: LEE, KYLIE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1014288','0~EXT',0,0,0,0,GETDATE() --Provider: LEPLEY, SUMMER MARIAH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112371','0~EXT',0,0,0,0,GETDATE() --Provider: LEWIS, REBECCA D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~121191','0~EXT',0,0,0,0,GETDATE() --Provider: LINDSEY, ASHLEY R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1024129','0~EXT',0,0,0,0,GETDATE() --Provider: LIPSCOMB, TIFFANY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1009339','0~EXT',0,0,0,0,GETDATE() --Provider: LITTLE AXE, LAUREN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~127585','0~EXT',0,0,0,0,GETDATE() --Provider: LONG, BRADLEY T; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1014223','0~EXT',0,0,0,0,GETDATE() --Provider: LOPEZ WESLEY, KATHY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107938','0~EXT',0,0,0,0,GETDATE() --Provider: LOVE, JAMES E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111032','0~EXT',0,0,0,0,GETDATE() --Provider: LOWRANCE III, RICHARD A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1028333','0~EXT',0,0,0,0,GETDATE() --Provider: LOYOLA, WALTER XAVIER; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000730','0~EXT',0,0,0,0,GETDATE() --Provider: MADHAVARAPU, SEETHAL R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103245','0~EXT',0,0,0,0,GETDATE() --Provider: MAHMOOD, HAMID; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~130875','0~RSG',0,0,0,0,GETDATE() --Provider: MAHONEY, HILARY B; Practice: Robert G. Spencer, M.D.
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000083','0~EXT',0,0,0,0,GETDATE() --Provider: MANGUM, ROBYN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1017388','0~EXT',0,0,0,0,GETDATE() --Provider: MARTIN, NICHOLAS ALLEN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~115398','0~EXT',0,0,0,0,GETDATE() --Provider: MARTIN, ZACHARY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113876','0~EXT',0,0,0,0,GETDATE() --Provider: MARTINEZ, MARS S; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008119','0~EXT',0,0,0,0,GETDATE() --Provider: MAUPIN, JEREMIAH JACOB; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103405','0~EXT',0,0,0,0,GETDATE() --Provider: MAYO, COLBY D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~131566','0~EXT',0,0,0,0,GETDATE() --Provider: MCGHEE, MIRANDA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~119703','0~EXT',0,0,0,0,GETDATE() --Provider: MCGINNIS, BRIANA AINE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1014617','0~EXT',0,0,0,0,GETDATE() --Provider: MCINTOSH, CASSIE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000668','0~EXT',0,0,0,0,GETDATE() --Provider: MENZ, SARAH KELLEEN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008500','0~EXT',0,0,0,0,GETDATE() --Provider: MILLER, SHEILA D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103673','0~EXT',0,0,0,0,GETDATE() --Provider: MILLS, VICTORIA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008568','0~EXT',0,0,0,0,GETDATE() --Provider: MINER, MARTINA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1025724','0~EXT',0,0,0,0,GETDATE() --Provider: MINSON, LORA BETH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1024409','0~EXT',0,0,0,0,GETDATE() --Provider: MITCHELL, MICHAEL L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103707','0~EXT',0,0,0,0,GETDATE() --Provider: MOERY, SAMANTHA C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108093','0~EXT',0,0,0,0,GETDATE() --Provider: MOORE, BARBARA ELIZABETH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1026402','0~EXT',0,0,0,0,GETDATE() --Provider: MOORE, MACE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103746','0~EXT',0,0,0,0,GETDATE() --Provider: MOORE, ROBERT K; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112544','0~EXT',0,0,0,0,GETDATE() --Provider: MOREMAN, DENA M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1015231','0~EXT',0,0,0,0,GETDATE() --Provider: MOSCA, NICHOLAS DAVID; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1012990','0~EXT',0,0,0,0,GETDATE() --Provider: MUNDA, MATTHEW; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109754','0~EXT',0,0,0,0,GETDATE() --Provider: MURRAY, DEBRA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1024068','0~EXT',0,0,0,0,GETDATE() --Provider: MURRAY, KASONDRA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103861','0~EXT',0,0,0,0,GETDATE() --Provider: NANDA, SUMEETA M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1006883','0~EXT',0,0,0,0,GETDATE() --Provider: NASH, STEPHANIE S; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108141','0~EXT',0,0,0,0,GETDATE() --Provider: NAWAZ, MUDASSIR, M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1014193','0~EXT',0,0,0,0,GETDATE() --Provider: NESDAHL, KELLY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111465','0~EXT',0,0,0,0,GETDATE() --Provider: NEWEY, MARK W; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~122150','0~EXT',0,0,0,0,GETDATE() --Provider: NGUYEN, ANH TU; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103923','0~EXT',0,0,0,0,GETDATE() --Provider: NGUYEN, THUY T; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103938','0~EXT',0,0,0,0,GETDATE() --Provider: NIEHUES, CHRISTY A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109378','0~EXT',0,0,0,0,GETDATE() --Provider: NIEMAN, CATHY E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~121247','0~EXT',0,0,0,0,GETDATE() --Provider: NOLAN, ELIZABETH MCALLISTER; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110425','0~EXT',0,0,0,0,GETDATE() --Provider: NORRIS, DANNY R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001232','0~EXT',0,0,0,0,GETDATE() --Provider: NORWOOD, AUTUMN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~118559','0~EXT',0,0,0,0,GETDATE() --Provider: NUSRAT, SALMAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~121248','0~EXT',0,0,0,0,GETDATE() --Provider: OLSEN, KELSEY A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1020309','0~EXT',0,0,0,0,GETDATE() --Provider: OZCAN, ERSIN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109385','0~EXT',0,0,0,0,GETDATE() --Provider: PAGE, RICKY L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~126913','0~EXT',0,0,0,0,GETDATE() --Provider: PARKER, DAVID B; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1004611','0~EXT',0,0,0,0,GETDATE() --Provider: PARMER, BRADEN D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108226','0~EXT',0,0,0,0,GETDATE() --Provider: PARRINGTON, ANN M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110877','0~EXT',0,0,0,0,GETDATE() --Provider: PASZKOWIAK, JAROSLAW K; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1025445','0~EXT',0,0,0,0,GETDATE() --Provider: PATEL, YESHA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104157','0~EXT',0,0,0,0,GETDATE() --Provider: PAYNE, EMILY KATHERINE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109072','0~EXT',0,0,0,0,GETDATE() --Provider: PECK, BRYAN E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~117389','0~EXT',0,0,0,0,GETDATE() --Provider: PENDERGRAFT, CHRISTI; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1004029','0~EXT',0,0,0,0,GETDATE() --Provider: PETERSON, BRADEN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~119662','0~EXT',0,0,0,0,GETDATE() --Provider: PETERSON, KOURTNEY MICHELE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109393','0~EXT',0,0,0,0,GETDATE() --Provider: PHELPS, CRAIG; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~115981','0~EXT',0,0,0,0,GETDATE() --Provider: PHILIP, NISSY SAJAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104234','0~EXT',0,0,0,0,GETDATE() --Provider: PINARD, ELIZABETH A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~118333','0~EXT',0,0,0,0,GETDATE() --Provider: PLUMB, IMRAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001705','0~EXT',1,0,0,0,GETDATE() --Provider: POPE, JORDAN ROBERTS; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1005067','0~EXT',0,0,0,0,GETDATE() --Provider: POPE-BAILEY, ANGELA DAWN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104277','0~EXT',0,0,0,0,GETDATE() --Provider: POREMBSKI, MARGARET A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104311','0~EXT',0,0,0,0,GETDATE() --Provider: PRASAD, RAKESH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109398','0~EXT',0,0,0,0,GETDATE() --Provider: PRISE, JAMES G; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109399','0~EXT',0,0,0,0,GETDATE() --Provider: PROCTOR, HARRELL DOUGLAS; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104335','0~EXT',1,0,0,0,GETDATE() --Provider: PROUGH, AMIE E; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1028259','0~EXT',0,0,0,0,GETDATE() --Provider: PUCKETT, KENNEDI; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~125677','0~EXT',0,0,0,0,GETDATE() --Provider: PURCER, ANGELA D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~117884','0~EXT',0,0,0,0,GETDATE() --Provider: QIN, JENNEY Z; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1023632','0~EXT',0,0,0,0,GETDATE() --Provider: RAMOS, EVERLINO ABEN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109403','0~EXT',0,0,0,0,GETDATE() --Provider: RAMOS, MICHAEL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~140963','0~EXT',0,0,0,0,GETDATE() --Provider: REITH, CHRISTINE M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1021712','0~EXT',0,0,0,0,GETDATE() --Provider: RENFROW, TAMIKA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002804','0~EXT',0,0,0,0,GETDATE() --Provider: RICHARDSON, PORSHA LYNN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1023682','0~EXT',0,0,0,0,GETDATE() --Provider: RIOS, JENNIFER; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108348','0~EXT',0,0,0,0,GETDATE() --Provider: RIVERS, RICHARD A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1017878','0~EXT',0,0,0,0,GETDATE() --Provider: ROOSTAEYAN, OMID; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001464','0~EXT',0,0,0,0,GETDATE() --Provider: ROSE, JODY GENE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1025837','0~EXT',0,0,0,0,GETDATE() --Provider: RUSHING, AMANDA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109422','0~EXT',0,0,0,0,GETDATE() --Provider: SCHMIDT, RICKY R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~117609','0~EXT',0,0,0,0,GETDATE() --Provider: SCOGGIN, RIKKI JUSTICE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109821','0~EXT',0,0,0,0,GETDATE() --Provider: SCOTT, JEWELLE MAE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104787','0~EXT',0,0,0,0,GETDATE() --Provider: SEELBACH-WARD, SHAWNA D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114313','0~EXT',0,0,0,0,GETDATE() --Provider: SHARP, BRIAN G; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1018575','0~EXT',0,0,0,0,GETDATE() --Provider: SHEAMAN, MARK; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109435','0~EXT',0,0,0,0,GETDATE() --Provider: SIRAJUDDIN, RIAZ A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008295','0~EXT',0,0,0,0,GETDATE() --Provider: SKAGGS, JOANNE C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1013857','0~EXT',0,0,0,0,GETDATE() --Provider: SMITH, JENNIFER MARIE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114471','0~EXT',0,0,0,0,GETDATE() --Provider: SMITH, MARIA AGNES; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111292','0~EXT',0,0,0,0,GETDATE() --Provider: SMITH, RICHARD B; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1013433','0~EXT',0,0,0,0,GETDATE() --Provider: SONY, BENCY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105048','0~EXT',0,0,0,0,GETDATE() --Provider: SPENCE, WILLIAM DEAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001753','0~EXT',0,0,0,0,GETDATE() --Provider: SPROWLS, JONAS R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114332','0~EXT',0,0,0,0,GETDATE() --Provider: STANBERRY, TOMMIE G; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1010895','0~EXT',0,0,0,0,GETDATE() --Provider: STEELE, EUNHYE GRACE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~122158','0~EXT',0,0,0,0,GETDATE() --Provider: STORM, MEREDITH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105186','0~EXT',0,0,0,0,GETDATE() --Provider: STRONG III, CLINTON R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1031962','0~EXT',0,0,0,0,GETDATE() --Provider: STULL, JAMES; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108563','0~EXT',0,0,0,0,GETDATE() --Provider: SUTOR, RONALD J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1018616','0~EXT',0,0,0,0,GETDATE() --Provider: TANNER, JEREMY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1003893','0~EXT',0,0,0,0,GETDATE() --Provider: TAPONNO, MELANIE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000415','0~EXT',0,0,0,0,GETDATE() --Provider: TATE, MARIA LOUISE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1007401','0~EXT',0,0,0,0,GETDATE() --Provider: TATE, TESSA RAE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105247','0~EXT',1,0,0,0,GETDATE() --Provider: TAYLOR, ASHLEY N; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1014229','0~EXT',0,0,0,0,GETDATE() --Provider: TAYLOR, JENNIFER; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1017002','0~EXT',0,0,0,0,GETDATE() --Provider: TAYLOR, KOREY DANIELLE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~122490','0~EXT',1,0,0,0,GETDATE() --Provider: THIELKER, LINDSAY M; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1011867','0~EXT',0,0,0,0,GETDATE() --Provider: THOMAS, JEANETTE SUE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008810','0~EXT',0,0,0,0,GETDATE() --Provider: THOMPSON, MELANIE ANN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000158','0~EXT',0,0,0,0,GETDATE() --Provider: THOMPSON-MATHEW, MIRIAM ELAINE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1029197','0~EXT',0,0,0,0,GETDATE() --Provider: THOMSON, CLARA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000931','0~EXT',0,0,0,0,GETDATE() --Provider: TISDALE, JIMMY L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~122837','0~EXT',1,0,0,1,GETDATE() --Provider: TITUS, AMANDA; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~114361','0~EXT',0,0,0,0,GETDATE() --Provider: TRIGG, ROSE M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108623','0~EXT',0,0,0,0,GETDATE() --Provider: TROXELL, MAGARET; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111766','0~EXT',0,0,0,0,GETDATE() --Provider: TRULY, TED F; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1003289','0~EXT',0,0,0,0,GETDATE() --Provider: TYSZKO, SARAH LYNN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~128947','0~EXT',0,0,0,0,GETDATE() --Provider: UGWU, DANA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~117687','0~EXT',0,0,0,0,GETDATE() --Provider: UMAKUMARAN, GEETHA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1030324','0~EXT',0,0,0,0,GETDATE() --Provider: VA HOSPITAL NORTH OKC, CLINIC; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1026821','0~EXT',0,0,0,0,GETDATE() --Provider: VALLES, ANNA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108652','0~EXT',0,0,0,0,GETDATE() --Provider: VAVERKA, LORA MAY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1016676','0~EXT',0,0,0,0,GETDATE() --Provider: VAZQUEZ, CHANDLAR M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1013455','0~EXT',0,0,0,0,GETDATE() --Provider: VEDALA, RAGHUVEER; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008463','0~EXT',0,0,0,0,GETDATE() --Provider: VEIT, NANCY M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1004412','0~EXT',0,0,0,0,GETDATE() --Provider: VINNEDGE, DANIELLE L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105530','0~EXT',0,0,0,0,GETDATE() --Provider: VOGEL, ROBERT BRADLEY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110517','0~EXT',0,0,0,0,GETDATE() --Provider: VONFELDT, KRYSTAL M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1006001','0~EXT',0,0,0,0,GETDATE() --Provider: WADE, DUSTIN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108672','0~EXT',0,0,0,0,GETDATE() --Provider: WALLACE, KACEY, D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008464','0~EXT',0,0,0,0,GETDATE() --Provider: WARREN-BARNETT, KATY D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105615','0~EXT',0,0,0,0,GETDATE() --Provider: WASEMILLER-SMITH, LISA J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~115265','0~EXT',0,0,0,0,GETDATE() --Provider: WATERMAN, LISA RENEE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110312','0~EXT',0,0,0,0,GETDATE() --Provider: WATKINS, STEVEN K; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001544','0~EXT',0,0,0,0,GETDATE() --Provider: WEAVER, MELISA DAWN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105666','0~EXT',0,0,0,0,GETDATE() --Provider: WEBSTER, MICHELLE E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109975','0~EXT',0,0,0,0,GETDATE() --Provider: WELLS-BURRIS, JESSICA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109489','0~EXT',0,0,0,0,GETDATE() --Provider: WESTCOTT, ROBERT M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1022128','0~EXT',0,0,0,0,GETDATE() --Provider: WHITESELL, JADE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111549','0~EXT',0,0,0,0,GETDATE() --Provider: WIESNER, ELISE R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000009','0~EXT',0,0,0,0,GETDATE() --Provider: WILCOX, AARON PAUL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108757','0~EXT',0,0,0,0,GETDATE() --Provider: WILLIAMS, WESLEY M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105814','0~EXT',0,0,0,0,GETDATE() --Provider: WILLIAMSON, DANIEL A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~121039','0~EXT',0,0,0,0,GETDATE() --Provider: WILSON, JOSHUA ALAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~122119','0~EXT',0,0,0,0,GETDATE() --Provider: WILSON, MEGAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~135546','0~EXT',0,0,0,0,GETDATE() --Provider: WILSON, NICHOLAS HOWARD; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108768','0~EXT',0,0,0,0,GETDATE() --Provider: WILSON, VICTOR T; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~119483','0~EXT',0,0,0,0,GETDATE() --Provider: WINHAM, S RILEY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1007992','0~EXT',0,0,0,0,GETDATE() --Provider: WOOD, CHARLES DAVID; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105903','0~EXT',0,0,0,0,GETDATE() --Provider: WOODSON, ALEXA G; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001542','0~EXT',0,0,0,0,GETDATE() --Provider: WOODSON, ELENA BETH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~118112','0~EXT',0,0,0,0,GETDATE() --Provider: YARBROUGH, ARDRY LANCE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002731','0~EXT',0,0,0,0,GETDATE() --Provider: ZAFAR, SAMEER; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1004446','0~EXT',0,0,0,0,GETDATE() --Provider: ZOLLO, VERONICA LEE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104649','0~EXT',0,0,0,0,GETDATE() --Provider: SACHDEV, ARUN K; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~110831','0~EXT',0,0,0,0,GETDATE() --Provider: HAMADEH, FAHED M; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~109392','0~EXT',0,0,0,0,GETDATE() --Provider: PHELPS, JEREMY; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~113083','0~EXT',0,0,0,0,GETDATE() --Provider: VOTO, JOE D; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~102946','0~EXT',0,0,0,0,GETDATE() --Provider: KURELLA, RAVINDER R; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~119582','0~EXT',0,0,0,0,GETDATE() --Provider: STUCKEY, CHAD J; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~110947','0~EXT',0,0,0,0,GETDATE() --Provider: WILSON, MARK S II; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~109687','0~EXT',0,0,0,0,GETDATE() --Provider: KANEASTER, S KYLE; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1017495','0~EXT',1,0,0,1,GETDATE() --Provider: LINGAM, PRANATHI; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~104100','0~EXT',0,0,0,0,GETDATE() --Provider: PARKER, DENNIS M; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1004208','0~EXT',0,0,0,0,GETDATE() --Provider: POLAN, MICHELLE B; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~123554','0~EXT',0,0,0,0,GETDATE() --Provider: SEAT, ANDREA M; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002857','0~EXT',0,0,0,0,GETDATE() --Provider: TARIQ, FARHAN; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~100496','0~EXT',0,0,0,0,GETDATE() --Provider: BOND, GARY D; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1021462','0~EXT',0,0,0,0,GETDATE() --Provider: KARIKARI, ISAAC OBIRI; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~112472','0~EXT',0,0,0,0,GETDATE() --Provider: ABU-ESHEH, BAHA A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107285','0~EXT',0,0,0,0,GETDATE() --Provider: CLOWERS, BRIAN E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101296','0~EXT',0,0,0,0,GETDATE() --Provider: DEDEKE, AMY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1007744','0~EXT',0,0,0,0,GETDATE() --Provider: NELSON, CLAYTON E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103893','0~EXT',0,0,0,0,GETDATE() --Provider: NEUMANN II, DAVID A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104233','0~EXT',0,0,0,0,GETDATE() --Provider: PILLOW, JONATHON; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105139','0~EXT',0,0,0,0,GETDATE() --Provider: STEWART, LINZI L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001048','0~EXT',0,0,0,0,GETDATE() --Provider: WEINGARTNER, JOSHUA S; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~132712','0~EXT',1,0,0,0,GETDATE() --Provider: CORLEE, BRYCE; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~101859','0~EXT',0,0,0,0,GETDATE() --Provider: GILLAN, MUHAMMAD M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101897','0~EXT',0,0,0,0,GETDATE() --Provider: GOFF, DARREN W; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110629','0~EXT',0,0,0,0,GETDATE() --Provider: GUERRA, RICO; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105459','0~EXT',0,0,0,0,GETDATE() --Provider: TYNDALL, ROBERT J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1003165','0~EXT',0,0,0,0,GETDATE() --Provider: BUTCHEE, MARGUERITE ANNA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~102125','0~EXT',0,0,0,0,GETDATE() --Provider: HANSEN, JULIA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~115425','0~EXT',0,0,0,0,GETDATE() --Provider: MANGRUM, CHRISTIAN WALTON; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103964','0~EXT',0,0,0,0,GETDATE() --Provider: NORRIS, RYAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112586','0~EXT',0,0,0,0,GETDATE() --Provider: SCOTT, JEFFERY D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109464','0~EXT',0,0,0,0,GETDATE() --Provider: TKACH, THOMAS K; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107020','0~EXT',0,0,0,0,GETDATE() --Provider: ALLEN, DAVID R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100176','0~EXT',0,0,0,0,GETDATE() --Provider: ARMOR, JESS F; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1027453','0~EXT',0,0,0,0,GETDATE() --Provider: FISHER, SYLVIE J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112743','0~EXT',0,0,0,0,GETDATE() --Provider: GODISH, MARK T; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008101','0~EXT',0,0,0,0,GETDATE() --Provider: HARDY, ELVIN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~102163','0~EXT',0,0,0,0,GETDATE() --Provider: HARRIS, LAURANNE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~102778','0~EXT',0,0,0,0,GETDATE() --Provider: KEENER, ROSS S; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110692','0~EXT',0,0,0,0,GETDATE() --Provider: KREMPL, GREG A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1023083','0~EXT',0,0,0,0,GETDATE() --Provider: MOAD, JEREMY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1013010','0~EXT',0,0,0,0,GETDATE() --Provider: PARKER, DANIEL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104313','0~EXT',0,0,0,0,GETDATE() --Provider: PRASSADA, YOLANDA M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108392','0~EXT',0,0,0,0,GETDATE() --Provider: RYAN, MATTHEW M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104816','0~EXT',1,0,0,0,GETDATE() --Provider: SHANBOUR, KAMAL ANTHONY; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~105041','0~EXT',0,0,0,0,GETDATE() --Provider: SPARLING, JEFFREY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105100','0~EXT',0,0,0,0,GETDATE() --Provider: STEARMAN, LAURA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109768','0~EXT',0,0,0,0,GETDATE() --Provider: ASHRAF, ZUBAIR; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~140773','0~EXT',0,0,0,0,GETDATE() --Provider: BABAR, LAILA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1031315','0~EXT',1,0,0,1,GETDATE() --Provider: BLICK, BRIAN; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~116261','0~EXT',0,0,0,0,GETDATE() --Provider: BRUNNABEND, MICHELLE L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111950','0~EXT',0,0,0,0,GETDATE() --Provider: CONNER, ANDREW; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101117','0~EXT',0,0,0,0,GETDATE() --Provider: COTNER, BEVERLY A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101154','0~EXT',0,0,0,0,GETDATE() --Provider: CRAVEN, PAMELA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000534','0~EXT',0,0,0,0,GETDATE() --Provider: DUNCAN, ALLISON L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101510','0~EXT',0,0,0,0,GETDATE() --Provider: ELLIS, CHRISTIAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107591','0~EXT',0,0,0,0,GETDATE() --Provider: GREEN, CHRISTOPHER J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002945','0~EXT',0,0,0,0,GETDATE() --Provider: HACKL, FRANK JOSEPH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~123120','0~EXT',0,0,0,0,GETDATE() --Provider: HAMILTON, AMANDA MAXEDON; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~122793','0~EXT',0,0,0,0,GETDATE() --Provider: HANCOCK, BRANDON; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~130790','0~EXT',0,0,0,0,GETDATE() --Provider: HULL, BRANDON; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1028607','0~EXT',0,0,0,0,GETDATE() --Provider: HUSHLA, DANIEL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~102815','0~EXT',0,0,0,0,GETDATE() --Provider: KHAN, AGHA K; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114530','0~EXT',0,0,0,0,GETDATE() --Provider: KHAN, MOHAMMAD FAISAL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107910','0~EXT',0,0,0,0,GETDATE() --Provider: LINDLEY, TODD E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103202','0~EXT',0,0,0,0,GETDATE() --Provider: LOWE, JAMES B; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~128315','0~EXT',0,0,0,0,GETDATE() --Provider: MAO, TIFFANY F; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107998','0~EXT',0,0,0,0,GETDATE() --Provider: MATOOK, GEORGE M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111896','0~EXT',0,0,0,0,GETDATE() --Provider: MCGINNIS, DONALD W; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103606','0~EXT',0,0,0,0,GETDATE() --Provider: MESIYA, SIKANDAR A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~118294','0~EXT',0,0,0,0,GETDATE() --Provider: PANDAY, KESHAV; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112974','0~EXT',0,0,0,0,GETDATE() --Provider: PHAM, TAN N; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108263','0~EXT',0,0,0,0,GETDATE() --Provider: PLANTS, NICHOLAS B; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~126872','0~EXT',0,0,0,0,GETDATE() --Provider: RADANT, MATTHEW R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104805','0~EXT',0,0,0,0,GETDATE() --Provider: SHADID JR, EDWARD A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108455','0~EXT',0,0,0,0,GETDATE() --Provider: SHAKIR, ARIF ALI; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105296','0~EXT',0,0,0,0,GETDATE() --Provider: THEOBALD, LARA J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~119253','0~EXT',0,0,0,0,GETDATE() --Provider: TKACH, CHRISTOPHER K; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1030712','0~EXT',0,0,0,0,GETDATE() --Provider: UNKNOWN, UNKNOWN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~131660','0~EXT',0,0,0,0,GETDATE() --Provider: VERITY, MARK P; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000279','0~EXT',0,0,0,0,GETDATE() --Provider: WALIA, SUMIT; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001549','0~EXT',0,0,0,0,GETDATE() --Provider: WALKER, STEVEN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113197','0~EXT',0,0,0,0,GETDATE() --Provider: WHELAN, SEAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001507','0~EXT',0,0,0,0,GETDATE() --Provider: WHITE, BREANNA LEA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~116258','0~EXT',0,0,0,0,GETDATE() --Provider: ABDUL-HAQQ, NOOR JIHAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107006','0~EXT',0,0,0,0,GETDATE() --Provider: ADAMS, DONALD E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1003447','0~EXT',0,0,0,0,GETDATE() --Provider: ADEDIJI, FAUSAT A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~126767','0~EXT',0,0,0,0,GETDATE() --Provider: ADEDIPE, TAIWO B; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~126745','0~EXT',0,0,0,0,GETDATE() --Provider: AGRAWAL, KSHITIJKUMAR M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1004335','0~EXT',0,0,0,0,GETDATE() --Provider: AJMERI, ARIF; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1003413','0~EXT',0,0,0,0,GETDATE() --Provider: ALBIRINI, ABDULMAWLA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1015409','0~EXT',0,0,0,0,GETDATE() --Provider: ALBRIGHT, MATTHEW; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112508','0~EXT',0,0,0,0,GETDATE() --Provider: ALGAN, SHEILA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1015524','0~HPICH',1,0,0,0,GETDATE() --Provider: ALJOE, JENNIFER; Practice: HPI CH
INSERT INTO map.EpicPracticeProviders SELECT '5~109211','0~EXT',0,0,0,0,GETDATE() --Provider: ALLEE, BRIAN A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109212','0~EXT',0,0,0,0,GETDATE() --Provider: ALLEE, MARK R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1010519','0~EXT',0,0,0,0,GETDATE() --Provider: ALLEN, MAGGIE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100095','0~EXT',0,0,0,0,GETDATE() --Provider: ALLEN, MELINDA ROTHER; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~129274','0~EXT',0,0,0,0,GETDATE() --Provider: AMIR, MUHAMMAD; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107029','0~EXT',0,0,0,0,GETDATE() --Provider: ANDERSON, KEVIN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1006403','0~EXT',0,0,0,0,GETDATE() --Provider: ANDERSON, NOLEN DALE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008560','0~EXT',0,0,0,0,GETDATE() --Provider: ANDERSON, SHELLY D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113862','0~EXT',0,0,0,0,GETDATE() --Provider: ANDRADE, STEPHEN A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1014429','0~EXT',0,0,0,0,GETDATE() --Provider: ANDREWS, DEANA KAY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1007146','0~EXT',0,0,0,0,GETDATE() --Provider: APPELMAN, RINDI LINN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113001','0~EXT',0,0,0,0,GETDATE() --Provider: AQEL, BASHAR A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100164','0~EXT',0,0,0,0,GETDATE() --Provider: ARAMBULA, MARTHA B; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~120049','0~EXT',0,0,0,0,GETDATE() --Provider: ARTHUR, JESSE KENT; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~117429','0~EXT',0,0,0,0,GETDATE() --Provider: AULD, DAVID; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~137050','0~EXT',0,0,0,0,GETDATE() --Provider: AULT III, LAWRENCE CARROLL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107060','0~EXT',0,0,0,0,GETDATE() --Provider: AVANT, FIORELLA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109222','0~EXT',0,0,0,0,GETDATE() --Provider: AVILA, ANIBAL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100227','0~EXT',0,0,0,0,GETDATE() --Provider: BACA, LAELANI M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100239','0~EXT',0,0,0,0,GETDATE() --Provider: BAJRACHARYA, PUSHMA N; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100253','0~EXT',0,0,0,0,GETDATE() --Provider: BAKER, R STANLEY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1010315','0~EXT',0,0,0,0,GETDATE() --Provider: BAKER, SEAN KELLY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~143594','0~EXT',0,0,0,0,GETDATE() --Provider: BALL, LINDA X; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~117765','0~EXT',0,0,0,0,GETDATE() --Provider: BALLAS, MEGAN K; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1009791','0~EXT',0,0,0,0,GETDATE() --Provider: BANDER, STEVEN G; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008737','0~EXT',0,0,0,0,GETDATE() --Provider: BANGURAH, CAROLYNE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~126961','0~EXT',0,0,0,0,GETDATE() --Provider: BARCLAY, JENNIFER ANNE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1012235','0~EXT',0,0,0,0,GETDATE() --Provider: BARDASHER, TONYA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~127628','0~EXT',0,0,0,0,GETDATE() --Provider: BARKER, SUSAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1018847','0~EXT',0,0,0,0,GETDATE() --Provider: BARNES, EMILLEE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114474','0~EXT',0,0,0,0,GETDATE() --Provider: BARNES, HEATHER; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110627','0~EXT',0,0,0,0,GETDATE() --Provider: BARNES, MICHELLE D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1024685','0~EXT',0,0,0,0,GETDATE() --Provider: BARRETT, CHARLOTTE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1025491','0~EXT',0,0,0,0,GETDATE() --Provider: BARRETT, CORTNEY L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107094','0~EXT',0,0,0,0,GETDATE() --Provider: BARSALOUX, ANDREW F; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112110','0~EXT',0,0,0,0,GETDATE() --Provider: BASENER, CLINT J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1006661','0~EXT',0,0,0,0,GETDATE() --Provider: BASKIN, KAYELEIGH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114772','0~EXT',0,0,0,0,GETDATE() --Provider: BASS, JAMES WILLIAM; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~119192','0~EXT',0,0,0,0,GETDATE() --Provider: BATES, KATRINA ANN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~128381','0~EXT',0,0,0,0,GETDATE() --Provider: BAUER, ANDREW M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1013719','0~EXT',0,0,0,0,GETDATE() --Provider: BAUSTERT, ANGELA C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110638','0~EXT',0,0,0,0,GETDATE() --Provider: BAUTISTA, MARTIN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1003957','0~EXT',0,0,0,0,GETDATE() --Provider: BEAIRD, TAYLOR LAUREN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112992','0~EXT',0,0,0,0,GETDATE() --Provider: BEENE, CHRISTOPHER L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~131779','0~EXT',0,0,0,0,GETDATE() --Provider: BEN, SARAH C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~127965','0~EXT',0,0,0,0,GETDATE() --Provider: BENNETT, ELIZABETH ANN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000984','0~EXT',0,0,0,0,GETDATE() --Provider: BENTLEY, LYNDA DIANNE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100380','0~EXT',0,0,0,0,GETDATE() --Provider: BENTON, JAMI L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114940','0~EXT',0,0,0,0,GETDATE() --Provider: BERRY, RICHARD PHILLIP; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113463','0~EXT',0,0,0,0,GETDATE() --Provider: BEYMER, JAMES R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107127','0~EXT',0,0,0,0,GETDATE() --Provider: BIERIG, KIRT E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1024627','0~EXT',0,0,0,0,GETDATE() --Provider: BILGA, IRYNA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1011333','0~EXT',0,0,0,0,GETDATE() --Provider: BLACK, CAROL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1012380','0~EXT',0,0,0,0,GETDATE() --Provider: BLANKENSHIP, RACHEL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110653','0~EXT',0,0,0,0,GETDATE() --Provider: BLOUGH, JOSEPH A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1005275','0~EXT',0,0,0,0,GETDATE() --Provider: BODIN, TYLER RAY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008695','0~EXT',0,0,0,0,GETDATE() --Provider: BODINE, AMANDA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1031814','0~EXT',0,0,0,0,GETDATE() --Provider: BOGLE, MISTY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1003291','0~EXT',0,0,0,0,GETDATE() --Provider: BOHNSTEDT, SUSAN N; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1014940','0~EXT',0,0,0,0,GETDATE() --Provider: BOLERJACK, TARA LYNN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100495','0~EXT',0,0,0,0,GETDATE() --Provider: BOND II, DENNIS F; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1003897','0~EXT',0,0,0,0,GETDATE() --Provider: BOOS, SHERRI DAWN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1006029','0~EXT',0,0,0,0,GETDATE() --Provider: BOREN JR, NATHAN ALTUS; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1004453','0~EXT',0,0,0,0,GETDATE() --Provider: BORGSMILLER, JACOB; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1010466','0~EXT',0,0,0,0,GETDATE() --Provider: BORGSMILLER, MACHAILLE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000620','0~EXT',0,0,0,0,GETDATE() --Provider: BOURNE, MICHELLE L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113164','0~EXT',0,0,0,0,GETDATE() --Provider: BOUVETTE, KIMBERLY A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107157','0~EXT',0,0,0,0,GETDATE() --Provider: BOWLWARE, KEN D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002443','0~EXT',0,0,0,0,GETDATE() --Provider: BRADFORD, KAREN RAE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1031322','0~EXT',0,0,0,0,GETDATE() --Provider: BRADSHAW, CHARITY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1011632','0~EXT',0,0,0,0,GETDATE() --Provider: BRADSHAW, JERRI; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1004400','0~EXT',0,0,0,0,GETDATE() --Provider: BRADY, MEAGAN L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1012749','0~EXT',0,0,0,0,GETDATE() --Provider: BRANNAN, MARCIA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000348','0~EXT',0,0,0,0,GETDATE() --Provider: BRATTEN, TOBI; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109233','0~EXT',0,0,0,0,GETDATE() --Provider: BRAUD, KRISTA B; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1005821','0~EXT',0,0,0,0,GETDATE() --Provider: BRAUN, TIM; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1013969','0~EXT',0,0,0,0,GETDATE() --Provider: BRAXTON, BIANCA LESHAY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107163','0~EXT',0,0,0,0,GETDATE() --Provider: BRAZIEL, JERRY D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001846','0~EXT',0,0,0,0,GETDATE() --Provider: BREEDEN, CANDICE R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~124248','0~EXT',0,0,0,0,GETDATE() --Provider: BRICKMAN, CAYCI LYNN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1003895','0~EXT',0,0,0,0,GETDATE() --Provider: BROCK, DONALD THOMAS; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~141340','0~EXT',0,0,0,0,GETDATE() --Provider: BROOKS, SYDNI N; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000538','0~EXT',0,0,0,0,GETDATE() --Provider: BROUGHTON, KRISTIN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1020774','0~EXT',0,0,0,0,GETDATE() --Provider: BROWN, ABIGAIL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1032480','0~EXT',0,0,0,0,GETDATE() --Provider: BROWN, AUSTIN C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~129727','0~EXT',1,0,0,0,GETDATE() --Provider: BROWN, PAULA J; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1014087','0~EXT',0,0,0,0,GETDATE() --Provider: BROWN, RYAN DAVID; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000774','0~EXT',0,0,0,0,GETDATE() --Provider: BRUNDIDGE, KASEY LEE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113922','0~EXT',0,0,0,0,GETDATE() --Provider: BRYAN, BRIDGET D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114945','0~EXT',0,0,0,0,GETDATE() --Provider: BRYAN, VINCENT MONTGOMERY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100675','0~EXT',0,0,0,0,GETDATE() --Provider: BRYANT, CHARLES E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1027765','0~EXT',0,0,0,0,GETDATE() --Provider: BULLOCK, HEATHER P; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1004907','0~EXT',0,0,0,0,GETDATE() --Provider: BURNS, COURTNEY LUANNE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1013999','0~EXT',0,0,0,0,GETDATE() --Provider: BURT, ADELE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002177','0~EXT',0,0,0,0,GETDATE() --Provider: BURTON, LISA JEANENE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110604','0~EXT',0,0,0,0,GETDATE() --Provider: BUTCHER, MICHAEL W; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107227','0~EXT',0,0,0,0,GETDATE() --Provider: CALDWELL, CUYLER, M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1026455','0~EXT',0,0,0,0,GETDATE() --Provider: CALLINS, MALLORY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~118584','0~EXT',0,0,0,0,GETDATE() --Provider: CALLISON, JACOB LEON; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101921','0~EXT',0,0,0,0,GETDATE() --Provider: CAMPBELL, COURTNEY N; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109239','0~EXT',0,0,0,0,GETDATE() --Provider: CAMPBELL, RICHARD LEE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1009822','0~EXT',0,0,0,0,GETDATE() --Provider: CANFIELD, MARAH GAIL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1031550','0~EXT',0,0,0,0,GETDATE() --Provider: CAREFIRST WELLNESS ASSOCIATES FORMELY THE SOUTHERN PLAINS MEDICAL CENTER, CENTER; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~115259','0~EXT',0,0,0,0,GETDATE() --Provider: CARLTON, ELIZABETH ANN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113477','0~EXT',0,0,0,0,GETDATE() --Provider: CARNAHAN, MICHAEL W; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100808','0~EXT',0,0,0,0,GETDATE() --Provider: CARNINE, THADDEUS; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~119815','0~EXT',0,0,0,0,GETDATE() --Provider: CARREL, JERRY EDWARD; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~125534','0~EXT',0,0,0,0,GETDATE() --Provider: CARSON, TAYLOR R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1003045','0~EXT',0,0,0,0,GETDATE() --Provider: CARTER III, SAMUEL R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002421','0~EXT',0,0,0,0,GETDATE() --Provider: CARTER, ALLISON; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112926','0~EXT',0,0,0,0,GETDATE() --Provider: CARTER, CHARLES C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000439','0~EXT',0,0,0,0,GETDATE() --Provider: CARTER, RANDALL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~117768','0~EXT',0,0,0,0,GETDATE() --Provider: CARVER, JAMES M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113588','0~EXT',0,0,0,0,GETDATE() --Provider: CASHERO, THOMAS; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1022753','0~EXT',0,0,0,0,GETDATE() --Provider: CAVNER, AMY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1024821','0~EXT',0,0,0,0,GETDATE() --Provider: CENTER, BETHANY CHILDREN'S HEALTH CENTER; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1022219','0~EXT',0,0,0,0,GETDATE() --Provider: CENTER, OU HEALTH HAROLD HAMM DIABETES; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113420','0~EXT',0,0,0,0,GETDATE() --Provider: CHALKIN, BRIAN A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001018','0~EXT',0,0,0,0,GETDATE() --Provider: CHALLIS, CHRISTOPHER CALE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008838','0~EXT',0,0,0,0,GETDATE() --Provider: CHANCE, MARY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1030416','0~EXT',0,0,0,0,GETDATE() --Provider: CHANDLER-HERBERT, SAMANTHA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1013246','0~EXT',1,0,0,0,GETDATE() --Provider: CHAPMAN, CHARLENE C; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~126041','0~EXT',0,0,0,0,GETDATE() --Provider: CHAUHAN, VARUN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000540','0~EXT',0,0,0,0,GETDATE() --Provider: CHEN, NICOLE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000054','0~EXT',0,0,0,0,GETDATE() --Provider: CHEN, YI; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~132844','0~EXT',0,0,0,0,GETDATE() --Provider: CHERIAN, BETSY ANN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1009831','0~EXT',0,0,0,0,GETDATE() --Provider: CHERIAN, SAKARIAH M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109961','0~EXT',0,0,0,0,GETDATE() --Provider: CHITTURI, SHALINI; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109247','0~EXT',0,0,0,0,GETDATE() --Provider: CHLEBORAD, JANICE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107271','0~EXT',0,0,0,0,GETDATE() --Provider: CHOPRA, KAREN M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1028322','0~EXT',0,0,0,0,GETDATE() --Provider: CHRISTOPHER J. BARRY, MD; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112652','0~EXT',0,0,0,0,GETDATE() --Provider: CHRUSCIEL, DEEPTI G; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000442','0~EXT',0,0,0,0,GETDATE() --Provider: CIBES-SILVA, MARISTELA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1022345','0~EXT',0,0,0,0,GETDATE() --Provider: CLARK, BEVERLY ANN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~141321','0~EXT',0,0,0,0,GETDATE() --Provider: CLARK, BRITTANY L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1023470','0~EXT',0,0,0,0,GETDATE() --Provider: CLARK, SHERIDAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110844','0~EXT',0,0,0,0,GETDATE() --Provider: CLARKE, MARY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001110','0~EXT',0,0,0,0,GETDATE() --Provider: CLAUNCH, JERE D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000548','0~EXT',0,0,0,0,GETDATE() --Provider: CLINE, CAMBER DEAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000661','0~EXT',0,0,0,0,GETDATE() --Provider: COBB, ESTER; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108697','0~EXT',1,0,0,0,GETDATE() --Provider: COCHENOUR, NATALIE J; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~133516','0~EXT',0,0,0,0,GETDATE() --Provider: COCHRAN, DAVID JAMES; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101004','0~EXT',0,0,0,0,GETDATE() --Provider: COCHRANE, SHAWN W; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1006903','0~EXT',0,0,0,0,GETDATE() --Provider: COLEMAN-JACKSON, RHONDA JEAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107296','0~EXT',0,0,0,0,GETDATE() --Provider: COLLINS, JENNIFER V; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107299','0~EXT',0,0,0,0,GETDATE() --Provider: COMBS, KATHLEEN E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112642','0~EXT',0,0,0,0,GETDATE() --Provider: CONLEY, JOHN D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1018661','0~EXT',0,0,0,0,GETDATE() --Provider: CONNEYWERDY, JULIA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1029986','0~EXT',0,0,0,0,GETDATE() --Provider: CONNOR, CHRISTOPHER; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101070','0~EXT',0,0,0,0,GETDATE() --Provider: CONRAD, VICKI J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1005255','0~EXT',0,0,0,0,GETDATE() --Provider: COOK, SEAN MICHAEL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1005297','0~EXT',0,0,0,0,GETDATE() --Provider: COOPER, JAMES KEITH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000602','0~EXT',0,0,0,0,GETDATE() --Provider: COTTRILL, GLEN DAVID; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107330','0~EXT',0,0,0,0,GETDATE() --Provider: COX, JON P; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002940','0~EXT',0,0,0,0,GETDATE() --Provider: CRAWFORD, MICHEAL JOE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~115615','0~EXT',0,0,0,0,GETDATE() --Provider: CRITTENDEN, NEIL E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1004752','0~EXT',0,0,0,0,GETDATE() --Provider: CRITTENDEN, SUNITA CHAHAR; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008246','0~EXT',0,0,0,0,GETDATE() --Provider: CROSBY, AMBER L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008325','0~EXT',0,0,0,0,GETDATE() --Provider: CUBIT, AMANDA LYNN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112103','0~EXT',0,0,0,0,GETDATE() --Provider: CUI, YU; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110187','0~EXT',0,0,0,0,GETDATE() --Provider: CUMMING, JEFFREY C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1022975','0~EXT',0,0,0,0,GETDATE() --Provider: CUNNINGHAM, HOLLY ELIZABETH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~115315','0~EXT',0,0,0,0,GETDATE() --Provider: CUNNINGHAM, KANDI LYNN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001058','0~EXT',0,0,0,0,GETDATE() --Provider: DAKE, JANA L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1023753','0~EXT',1,0,0,0,GETDATE() --Provider: DANESHFAR, SOBHAN; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~117668','0~EXT',0,0,0,0,GETDATE() --Provider: DANIELS, BRITTANY S; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114384','0~EXT',0,0,0,0,GETDATE() --Provider: DANTZLER, NANCY ANNE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1033180','0~TDT',1,1,0,0,GETDATE() --Provider: DAUGHERTY, BAILEY; Practice: Thomason Medical Clinic
INSERT INTO map.EpicPracticeProviders SELECT '5~P1014701','0~EXT',0,0,0,0,GETDATE() --Provider: DAVENPORT, BARRY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1029599','0~EXT',0,0,0,0,GETDATE() --Provider: DAVIS, CASSIE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000110','0~EXT',0,0,0,0,GETDATE() --Provider: DAVIS, CHARLYCE ERIN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107360','0~EXT',0,0,0,0,GETDATE() --Provider: DAVIS, JIM D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107361','0~EXT',0,0,0,0,GETDATE() --Provider: DAVIS, MARC J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112666','0~EXT',0,0,0,0,GETDATE() --Provider: DAVIS, MERLE L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101273','0~EXT',0,0,0,0,GETDATE() --Provider: DAWKINS, MARK A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109270','0~EXT',0,0,0,0,GETDATE() --Provider: DAWOD, ABDALLAH S; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~123767','0~EXT',0,0,0,0,GETDATE() --Provider: DE SANTIAGO, ALEJANDRA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101286','0~EXT',0,0,0,0,GETDATE() --Provider: DEAN, JOSIE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114072','0~EXT',0,0,0,0,GETDATE() --Provider: DEAN, KENDA L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109785','0~EXT',0,0,0,0,GETDATE() --Provider: DEAN, ROSELYNN R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1012345','0~EXT',0,0,0,0,GETDATE() --Provider: DEEMER, MALAYA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1016789','0~EXT',0,0,0,0,GETDATE() --Provider: DEGIUSTI, KASEY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1009012','0~EXT',0,0,0,0,GETDATE() --Provider: DEL ROSARIO, CYNTHIA GUERRERO; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~124868','0~EXT',0,0,0,0,GETDATE() --Provider: DENNEY, MARK C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113046','0~EXT',0,0,0,0,GETDATE() --Provider: DENNIS, BRUCE W; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112038','0~EXT',0,0,0,0,GETDATE() --Provider: DENNIS, GREGORY J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107383','0~EXT',0,0,0,0,GETDATE() --Provider: DENNIS, RYAN W; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1017993','0~EXT',0,0,0,0,GETDATE() --Provider: DENNY, MOLLY MARIE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1003613','0~EXT',0,0,0,0,GETDATE() --Provider: DENTON, SHERYL LYNN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114076','0~EXT',0,0,0,0,GETDATE() --Provider: DEPPEN, JESSICA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~119411','0~EXT',0,0,0,0,GETDATE() --Provider: DETWILER, ALEX N; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101326','0~EXT',0,0,0,0,GETDATE() --Provider: DEVAKONDA, ARUN K; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1016838','0~EXT',1,0,0,0,GETDATE() --Provider: DEVINE, ZACKERY R; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~110929','0~EXT',0,0,0,0,GETDATE() --Provider: DICKERSON, JOHN R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1019240','0~EXT',0,0,0,0,GETDATE() --Provider: DICKERSON, MORGAN NICOLE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1024614','0~EXT',0,0,0,0,GETDATE() --Provider: DISKIN, LAUREN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1028219','0~EXT',0,0,0,0,GETDATE() --Provider: DIVERSITY, FAMILY HEALTH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~119581','0~EXT',0,0,0,0,GETDATE() --Provider: DIXON, SALENA A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1023148','0~EXT',0,0,0,0,GETDATE() --Provider: DO, DAVID; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1005293','0~EXT',0,0,0,0,GETDATE() --Provider: DO, SEATON Q; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101376','0~EXT',0,0,0,0,GETDATE() --Provider: DONWERTH, ALEXANDRA S; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1009591','0~EXT',0,0,0,0,GETDATE() --Provider: DOWNS, LISA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002524','0~EXT',0,0,0,0,GETDATE() --Provider: DUBBERSTEIN, LAUREN KATHERINE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101413','0~EXT',0,0,0,0,GETDATE() --Provider: DUBOIS, PEGGY L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1028112','0~EXT',0,0,0,0,GETDATE() --Provider: DUNFORD, BRIANNE J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1007902','0~EXT',0,0,0,0,GETDATE() --Provider: DUNN, KEVIN F; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~123374','0~EXT',0,0,0,0,GETDATE() --Provider: DURSKA-KELLER, MONIKA K; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~130383','0~EXT',0,0,0,0,GETDATE() --Provider: DZAMBO, PHILIP; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000926','0~EXT',0,0,0,0,GETDATE() --Provider: EDDY, KETTI LYNN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101470','0~EXT',0,0,0,0,GETDATE() --Provider: EDGMON, KIMBERLY B; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101474','0~EXT',1,0,0,0,GETDATE() --Provider: EDWARDS, BRADLEY A; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~101476','0~EXT',0,0,0,0,GETDATE() --Provider: EDWARDS, COLBY L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101483','0~EXT',0,0,0,0,GETDATE() --Provider: EGAS, CARLOS A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1004640','0~EXT',0,0,0,0,GETDATE() --Provider: EICHERT, STEPHEN J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110735','0~EXT',0,0,0,0,GETDATE() --Provider: EISER, THOMAS J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1010043','0~EXT',0,0,0,0,GETDATE() --Provider: ELASS, NEDAL AMIN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000667','0~EXT',0,0,0,0,GETDATE() --Provider: ELLENBURG, MICHELLE L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1006538','0~EXT',0,0,0,0,GETDATE() --Provider: ELLIOTT, LARRY SHANE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111210','0~EXT',0,0,0,0,GETDATE() --Provider: EMERSON, GWENDOLYN B; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108954','0~EXT',1,0,0,0,GETDATE() --Provider: EPPERSON, KEVIN Q; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~101534','0~EXT',0,0,0,0,GETDATE() --Provider: ERFORD, CHRISTINA J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113085','0~EXT',0,0,0,0,GETDATE() --Provider: ERHARDT, MARK D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1026200','0~EXT',0,0,0,0,GETDATE() --Provider: ERNST, JAMIE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1030052','0~EXT',0,0,0,0,GETDATE() --Provider: ESDEN, JANA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1030256','0~EXT',0,0,0,0,GETDATE() --Provider: ETTER, DESTINY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107457','0~EXT',0,0,0,0,GETDATE() --Provider: EVANS, CRYSTALLE M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101551','0~EXT',0,0,0,0,GETDATE() --Provider: EVANS, JAMES MARKHAM; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114094','0~EXT',0,0,0,0,GETDATE() --Provider: EVANS, MARK A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~128803','0~EXT',0,0,0,0,GETDATE() --Provider: FAIAZI, SALAR MAYSAM; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114096','0~EXT',0,0,0,0,GETDATE() --Provider: FALCONER, RALPH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1009403','0~EXT',0,0,0,0,GETDATE() --Provider: FALKENSTERN, REBECCA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1017948','0~EXT',0,0,0,0,GETDATE() --Provider: FAMILY CARE, SOUTHSIDE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107465','0~EXT',0,0,0,0,GETDATE() --Provider: FARGHALY, SAMAR; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101582','0~EXT',0,0,0,0,GETDATE() --Provider: FARROW, DIANA L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1004885','0~EXT',0,0,0,0,GETDATE() --Provider: FELL, JULIA KATHLEEN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110388','0~EXT',0,0,0,0,GETDATE() --Provider: FERGESON, MARK A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1029198','0~EXT',0,0,0,0,GETDATE() --Provider: FERNANDES, CARLTON JOHN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1029818','0~EXT',0,0,0,0,GETDATE() --Provider: FERRELL, AMY KATHLEEN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1004748','0~EXT',0,0,0,0,GETDATE() --Provider: FETTERS, NICOLE L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1026570','0~EXT',0,0,0,0,GETDATE() --Provider: FINCH, COREY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110395','0~EXT',0,0,0,0,GETDATE() --Provider: FIRTH, PAUL L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1012476','0~EXT',0,0,0,0,GETDATE() --Provider: FLEMINGS, BRITTANY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1013169','0~EXT',0,0,0,0,GETDATE() --Provider: FLUSCHE, BREANNE KALI; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1010666','0~EXT',0,0,0,0,GETDATE() --Provider: FOMBY, MEGHAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~102685','0~EXT',0,0,0,0,GETDATE() --Provider: FONG, CRISTIN M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114104','0~EXT',0,0,0,0,GETDATE() --Provider: FOSTER, JESSICA D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1016763','0~EXT',0,0,0,0,GETDATE() --Provider: FOUNTAIN, RALPH GENE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000388','0~EXT',0,0,0,0,GETDATE() --Provider: FRANK, ALEXANDER FREDRICK; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112303','0~EXT',0,0,0,0,GETDATE() --Provider: FRANKLIN, RACHEL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1018861','0~EXT',0,0,0,0,GETDATE() --Provider: FRANKS, KIMBERLY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~123014','0~EXT',0,0,0,0,GETDATE() --Provider: FRANTZ, BROOKE N; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101711','0~EXT',0,0,0,0,GETDATE() --Provider: FREDRICK, LORI A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1014674','0~EXT',0,0,0,0,GETDATE() --Provider: FREEMAN, TYGER MICHELLE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1027472','0~EXT',0,0,0,0,GETDATE() --Provider: FRIEDL, BROOKE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101727','0~EXT',0,0,0,0,GETDATE() --Provider: FRIEDMAN, ERIC S; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~115171','0~EXT',0,0,0,0,GETDATE() --Provider: FROST, JILL WHITNEY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1007614','0~EXT',0,0,0,0,GETDATE() --Provider: FRY, KRISTI N; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1026443','0~EXT',0,0,0,0,GETDATE() --Provider: FRYAR, WINTER; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101765','0~EXT',0,0,0,0,GETDATE() --Provider: GADDE, LAXMINARAYANA R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1023205','0~EXT',0,0,0,0,GETDATE() --Provider: GAINES, MATTHEW STEVEN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~133037','0~EXT',0,0,0,0,GETDATE() --Provider: GAISKI, MADISON; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112563','0~EXT',0,0,0,0,GETDATE() --Provider: GALLARDO, GRACIELA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109661','0~EXT',0,0,0,0,GETDATE() --Provider: GALLEGO-SANCHEZ, HECTOR; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1021224','0~EXT',0,0,0,0,GETDATE() --Provider: GANGA, VYJAYANTHI; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101776','0~EXT',0,0,0,0,GETDATE() --Provider: GARABELLI, LAUREN K; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~134322','0~EXT',0,0,0,0,GETDATE() --Provider: GARAFOLA, KORI R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1003889','0~EXT',0,0,0,0,GETDATE() --Provider: GARCIA, SILVIA ISABEL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1007248','0~EXT',0,0,0,0,GETDATE() --Provider: GARLETT JR., JOSEPH FREDRICK; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109289','0~EXT',0,0,0,0,GETDATE() --Provider: GARNER, JAMES R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109290','0~EXT',0,0,0,0,GETDATE() --Provider: GARRETT, JEFFREY V; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1004546','0~EXT',0,0,0,0,GETDATE() --Provider: GARRETT, STEPHANIE JANE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~115274','0~EXT',0,0,0,0,GETDATE() --Provider: GARRISON, LEVI J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000992','0~EXT',0,0,0,0,GETDATE() --Provider: GARRISON, STEPHANIE R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1020483','0~EXT',0,0,0,0,GETDATE() --Provider: GEOHAGEN, JENNA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~116225','0~EXT',0,0,0,0,GETDATE() --Provider: GEURTS, CARRIE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101842','0~EXT',0,0,0,0,GETDATE() --Provider: GHANI, MOHAMMAD; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~123254','0~EXT',0,0,0,0,GETDATE() --Provider: GHATE, GAURI A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~134091','0~THP',0,0,0,0,GETDATE() --Provider: GILLETTE, AARON J; Practice: Total Healthcare Partners
INSERT INTO map.EpicPracticeProviders SELECT '5~141627','0~EXT',0,0,0,0,GETDATE() --Provider: GILLISPIE, ALLON; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1014573','0~EXT',0,0,0,0,GETDATE() --Provider: GILSON, CLIFFORD JOHN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111326','0~EXT',0,0,0,0,GETDATE() --Provider: GIN, ANDREW C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000871','0~EXT',0,0,0,0,GETDATE() --Provider: GIRVIN, KEARI LYNN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110245','0~EXT',0,0,0,0,GETDATE() --Provider: GIULIANO, LARISSA F; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101888','0~EXT',0,0,0,0,GETDATE() --Provider: GOBEN, CHARITY J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1028031','0~EXT',0,0,0,0,GETDATE() --Provider: GOODWIN, NICHOLAS MATTHEW; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1017239','0~EXT',0,0,0,0,GETDATE() --Provider: GOODWIN, SIERRA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1005424','0~EXT',0,0,0,0,GETDATE() --Provider: GOSEY, ALICIA ROSE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101933','0~EXT',0,0,0,0,GETDATE() --Provider: GOTCHER, MICHAEL D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~121550','0~EXT',0,0,0,0,GETDATE() --Provider: GRADY, GINA MARIE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1028316','0~EXT',0,0,0,0,GETDATE() --Provider: GRAHAM, HEATHER; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1017497','0~EXT',0,0,0,0,GETDATE() --Provider: GRAY, ISAAC BENJAMIN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002755','0~EXT',0,0,0,0,GETDATE() --Provider: GRAY, JEREMY D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114124','0~EXT',0,0,0,0,GETDATE() --Provider: GRAY, KYLE J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109297','0~EXT',0,0,0,0,GETDATE() --Provider: GRAY, PATRICK W; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1003856','0~EXT',0,0,0,0,GETDATE() --Provider: GREENLY, CHRISTY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101989','0~EXT',0,0,0,0,GETDATE() --Provider: GREYSON, RICHARD C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1021563','0~EXT',0,0,0,0,GETDATE() --Provider: GRIECO, MARCO; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1012049','0~EXT',0,0,0,0,GETDATE() --Provider: GRIFFITH, JAMIE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113534','0~EXT',0,0,0,0,GETDATE() --Provider: GRIGGS, THOMAS S; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107598','0~EXT',0,0,0,0,GETDATE() --Provider: GRIZZLE, JOHN D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1007576','0~EXT',0,0,0,0,GETDATE() --Provider: GUERRERO, CRHISTIAN NOEMI; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1016426','0~EXT',0,0,0,0,GETDATE() --Provider: GUNN, ANGELA RENEE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~124691','0~EXT',0,0,0,0,GETDATE() --Provider: GUTHRIE, AMBER LYN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1006158','0~EXT',0,0,0,0,GETDATE() --Provider: HAENEL, SHANNON; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114135','0~EXT',0,0,0,0,GETDATE() --Provider: HAGAN, CAROL L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1025205','0~EXT',0,0,0,0,GETDATE() --Provider: HAGAN, SARA MARIE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1005590','0~EXT',0,0,0,0,GETDATE() --Provider: HAILEY, BRIAN SCOTT; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~128208','0~EXT',0,0,0,0,GETDATE() --Provider: HAINES, KANDICE D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107609','0~EXT',0,0,0,0,GETDATE() --Provider: HALE II, WILLIAM J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1026481','0~EXT',0,0,0,0,GETDATE() --Provider: HALE, HALEY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002138','0~EXT',0,0,0,0,GETDATE() --Provider: HALL, NAKEDA LASHON; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114138','0~EXT',0,0,0,0,GETDATE() --Provider: HAMMOND, COURTNEY W; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114139','0~EXT',0,0,0,0,GETDATE() --Provider: HAMMONS, DONNELL R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1030164','0~EXT',0,0,0,0,GETDATE() --Provider: HAMRE, CANDICE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~121067','0~EXT',0,0,0,0,GETDATE() --Provider: HANNINGTON, AMY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1004016','0~EXT',0,0,0,0,GETDATE() --Provider: HARDAGE, STEVEN REX; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107619','0~EXT',0,0,0,0,GETDATE() --Provider: HARDEN, MONICA E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~102140','0~EXT',0,0,0,0,GETDATE() --Provider: HARDZOG-BRITT, CARLA J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110541','0~EXT',0,0,0,0,GETDATE() --Provider: HARMON, BETTY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~102154','0~EXT',0,0,0,0,GETDATE() --Provider: HARMS, MEGHAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1027929','0~EXT',0,0,0,0,GETDATE() --Provider: HARP, TARA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~141441','0~EXT',0,0,0,0,GETDATE() --Provider: HART, VANESSA J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107637','0~EXT',0,0,0,0,GETDATE() --Provider: HARTWIG, MICHAEL D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113829','0~EXT',0,0,0,0,GETDATE() --Provider: HARVEY, MARVIN R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112421','0~EXT',0,0,0,0,GETDATE() --Provider: HARVEY, ZANE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1005415','0~EXT',0,0,0,0,GETDATE() --Provider: HARWELL, DANIEL MARTIN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114151','0~EXT',0,0,0,0,GETDATE() --Provider: HAWKINS, JULIE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1025729','0~EXT',0,0,0,0,GETDATE() --Provider: HAYES, ANDREA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111487','0~EXT',0,0,0,0,GETDATE() --Provider: HAYMORE, BRET R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1022591','0~EXT',0,0,0,0,GETDATE() --Provider: HEALTH CARE, PINNACLE FAMILY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1024548','0~EXT',0,0,0,0,GETDATE() --Provider: HEALTH CLINIC, REYNOLDS ARMY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002336','0~EXT',0,0,0,0,GETDATE() --Provider: HEBERT, REID; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008108','0~EXT',0,0,0,0,GETDATE() --Provider: HEDRICK, HEATHER DAWN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109308','0~EXT',0,0,0,0,GETDATE() --Provider: HELTON, RICHARD J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1010696','0~EXT',0,0,0,0,GETDATE() --Provider: HEMBREE, AUTUMN R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1020518','0~EXT',0,0,0,0,GETDATE() --Provider: HENSON, CHRISTIAN A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114157','0~EXT',0,0,0,0,GETDATE() --Provider: HERB, BRIAN H; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~102289','0~EXT',0,0,0,0,GETDATE() --Provider: HERNDON, CHRISTOPHER M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1026251','0~EXT',0,0,0,0,GETDATE() --Provider: HIDALGO, LUZ MARIEL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111859','0~EXT',0,0,0,0,GETDATE() --Provider: HIGGINS, DONALD J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1023794','0~EXT',0,0,0,0,GETDATE() --Provider: HIGHTOWER, KALETHA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109966','0~EXT',0,0,0,0,GETDATE() --Provider: HIGHTOWER, ROBERT B; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1004877','0~EXT',0,0,0,0,GETDATE() --Provider: HILDEBRAND, JESSICA D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001287','0~EXT',0,0,0,0,GETDATE() --Provider: HINTZE, ALMA JORDAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~126835','0~EXT',0,0,0,0,GETDATE() --Provider: HOBBS, JORDAN ELIZABETH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1028757','0~EXT',0,0,0,0,GETDATE() --Provider: HOFFSOMMER, NICHOLAS; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1007007','0~EXT',0,0,0,0,GETDATE() --Provider: HOGUE, ADAM DUANE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108989','0~EXT',0,0,0,0,GETDATE() --Provider: HOKETT, JAMIE L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~129731','0~EXT',0,0,0,0,GETDATE() --Provider: HOLETZKY, KRISTIN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113312','0~EXT',0,0,0,0,GETDATE() --Provider: HOLLAND JR, DAVID L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1009119','0~EXT',0,0,0,0,GETDATE() --Provider: HOLLENBECK, JACOB; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~138124','0~EXT',0,0,0,0,GETDATE() --Provider: HOLMBOE, MARY C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109314','0~EXT',0,0,0,0,GETDATE() --Provider: HOLTER, JEREMY P; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1010484','0~EXT',0,0,0,0,GETDATE() --Provider: HONEYCUTT, DEBORAH ANN TRAVIS; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~102406','0~EXT',0,0,0,0,GETDATE() --Provider: HOOPER, ELIZABETH A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112916','0~EXT',0,0,0,0,GETDATE() --Provider: HORSTMAN, JOSEPH A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~126345','0~EXT',0,0,0,0,GETDATE() --Provider: HOSAKOTE SUBRAHMANYAM, BABU; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1024144','0~EXT',0,0,0,0,GETDATE() --Provider: HOSPITAL, VA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~102439','0~EXT',0,0,0,0,GETDATE() --Provider: HOUK JR, LARRY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1012266','0~EXT',0,0,0,0,GETDATE() --Provider: HOWARD, DYLON STEWART; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002124','0~EXT',0,0,0,0,GETDATE() --Provider: HOWARD, JEFFREY WAYLAND; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~129231','0~EXT',0,0,0,0,GETDATE() --Provider: HOWE, MASON; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~138658','0~EXT',0,0,0,0,GETDATE() --Provider: HRACHOVA, MAYA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114388','0~EXT',0,0,0,0,GETDATE() --Provider: HUDSON, TANYA J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114509','0~EXT',0,0,0,0,GETDATE() --Provider: HUNTER, KOBY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114172','0~EXT',0,0,0,0,GETDATE() --Provider: HURST, MARQUIS M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002399','0~EXT',0,0,0,0,GETDATE() --Provider: HURWITZ, ZACHARY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1006072','0~EXT',0,0,0,0,GETDATE() --Provider: HUSER IV, MARSHALL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112656','0~EXT',0,0,0,0,GETDATE() --Provider: HUSKERSON, ADAM; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001329','0~EXT',0,0,0,0,GETDATE() --Provider: HUTCHINSON, MELANIE ELIZABETH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1016863','0~EXT',0,0,0,0,GETDATE() --Provider: HUTCHISON, JACEY CHA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1009747','0~EXT',0,0,0,0,GETDATE() --Provider: IBRAHIMI, SAMI; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1026569','0~EXT',0,0,0,0,GETDATE() --Provider: INDIAN, CLINIC; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~139611','0~EXT',0,0,0,0,GETDATE() --Provider: INGRAM, CHRISTINA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1006175','0~EXT',0,0,0,0,GETDATE() --Provider: INTURI, ROHITHA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107743','0~EXT',0,0,0,0,GETDATE() --Provider: IRVIN, MICHAEL J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~131756','0~EXT',0,0,0,0,GETDATE() --Provider: ISER, COURTNEY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109985','0~EXT',0,0,0,0,GETDATE() --Provider: JACKSON, CAMILLE CATHERINE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~122083','0~EXT',0,0,0,0,GETDATE() --Provider: JACKSON, CHARLES ANDREW; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110762','0~EXT',0,0,0,0,GETDATE() --Provider: JACKSON, DONNA S; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000736','0~EXT',0,0,0,0,GETDATE() --Provider: JACKSON, MALARIE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1019017','0~EXT',0,0,0,0,GETDATE() --Provider: JACOBS, PAUL ALLEN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~127113','0~EXT',0,0,0,0,GETDATE() --Provider: JAMAL, SERENA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~117348','0~EXT',0,0,0,0,GETDATE() --Provider: JAMELARIN, EDWARD B; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002048','0~EXT',0,0,0,0,GETDATE() --Provider: JAMES, JENNIFER; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109002','0~EXT',0,0,0,0,GETDATE() --Provider: JANSEN, JOSHUA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107756','0~EXT',0,0,0,0,GETDATE() --Provider: JANTZEN, CHARLES A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008001','0~EXT',0,0,0,0,GETDATE() --Provider: JANZ, HUNTER; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110852','0~EXT',0,0,0,0,GETDATE() --Provider: JARED, MATTHEW; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111463','0~EXT',0,0,0,0,GETDATE() --Provider: JAWAID, FARRUKH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110246','0~EXT',0,0,0,0,GETDATE() --Provider: JEFFRIES, MATLOCK; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~143508','0~EXT',0,0,0,0,GETDATE() --Provider: JENKINS, KELCIE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1006827','0~EXT',0,0,0,0,GETDATE() --Provider: JENNINGS, LEE ALEXANDRA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1025507','0~EXT',0,0,0,0,GETDATE() --Provider: JIMERSON, ANDREW; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~124828','0~EXT',0,0,0,0,GETDATE() --Provider: JOERN, JERRY E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~136807','0~EXT',0,0,0,0,GETDATE() --Provider: JOHN, SHYMOL A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1031844','0~EXT',0,0,0,0,GETDATE() --Provider: JOHNSON, APRIL B; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1029272','0~EXT',0,0,0,0,GETDATE() --Provider: JOHNSON, CAROL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~133735','0~EXT',0,0,0,0,GETDATE() --Provider: JOHNSON, CONNER EUGENE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1003398','0~EXT',0,0,0,0,GETDATE() --Provider: JOHNSON, JAY KEVIN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107766','0~EXT',0,0,0,0,GETDATE() --Provider: JOHNSON, JOHNNY O; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~102657','0~EXT',0,0,0,0,GETDATE() --Provider: JOHNSON, JULI A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110595','0~EXT',0,0,0,0,GETDATE() --Provider: JOHNSON, M B; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~119627','0~EXT',0,0,0,0,GETDATE() --Provider: JOHNSON, MARK DANIEL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109683','0~EXT',0,0,0,0,GETDATE() --Provider: JOHNSON, MICHAEL C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1004646','0~EXT',0,0,0,0,GETDATE() --Provider: JOHNSTON, JOHNNY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1029619','0~EXT',0,0,0,0,GETDATE() --Provider: JONES, DAPHNEE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1019851','0~EXT',0,0,0,0,GETDATE() --Provider: JONES, LYNDSEY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1022789','0~SCS',0,0,0,0,GETDATE() --Provider: JONES, RANDI; Practice: S. Christopher Shadid, M.D.
INSERT INTO map.EpicPracticeProviders SELECT '5~P1031735','0~EXT',0,0,0,0,GETDATE() --Provider: JONES, STEPHANIE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~102712','0~EXT',0,0,0,0,GETDATE() --Provider: JONES, SUSAN K; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~123709','0~EXT',0,0,0,0,GETDATE() --Provider: JONES, TONYA KAY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107782','0~EXT',0,0,0,0,GETDATE() --Provider: JORDAN, CHRISTOPHER, M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1023841','0~EXT',0,0,0,0,GETDATE() --Provider: JOSEPH, THOMAS; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~119282','0~EXT',1,0,0,0,GETDATE() --Provider: JOY, TINA; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1032869','0~EXT',0,0,0,0,GETDATE() --Provider: KADIVAR, ARYAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100834','0~EXT',0,0,0,0,GETDATE() --Provider: KAPPUS, CYNTHIA CARTER; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1004899','0~EXT',0,0,0,0,GETDATE() --Provider: KAPUR, HARI S; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008529','0~EXT',0,0,0,0,GETDATE() --Provider: KARNES, REBEKAH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1010464','0~EXT',0,0,0,0,GETDATE() --Provider: KAUTZ, VALERIE SUZANNE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107799','0~EXT',0,0,0,0,GETDATE() --Provider: KAVANAUGH, AUBREY A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114194','0~EXT',0,0,0,0,GETDATE() --Provider: KEAST, BRIDGET A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114195','0~EXT',0,0,0,0,GETDATE() --Provider: KECK-SMITH, TANYA M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111567','0~EXT',0,0,0,0,GETDATE() --Provider: KEEFER, MICHAEL J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002556','0~EXT',0,0,0,0,GETDATE() --Provider: KENNEDY, KIMBERLY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~118480','0~EXT',0,0,0,0,GETDATE() --Provider: KERR, MISHELL JANE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114203','0~EXT',0,0,0,0,GETDATE() --Provider: KHAN, KIMBERLY S; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110372','0~EXT',0,0,0,0,GETDATE() --Provider: KHAN, MUNEER A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~102817','0~EXT',0,0,0,0,GETDATE() --Provider: KHANNA, SUDHIR K; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113920','0~EXT',0,0,0,0,GETDATE() --Provider: KHAWANDANAH, MOHAMAD O; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110689','0~EXT',0,0,0,0,GETDATE() --Provider: KHETPAL, VIVEK; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008657','0~EXT',0,0,0,0,GETDATE() --Provider: KHOURY, STEPHEN C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1015366','0~EXT',0,0,0,0,GETDATE() --Provider: KILHOFFER, TIFFANY ANN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1019523','0~EXT',0,0,0,0,GETDATE() --Provider: KILKENNY, LAURIE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000401','0~EXT',0,0,0,0,GETDATE() --Provider: KIM, DONALD H; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1029912','0~EXT',0,0,0,0,GETDATE() --Provider: KIMBROUGH, SAMUEL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~142475','0~EXT',0,0,0,0,GETDATE() --Provider: KING, KALEB; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1018964','0~EXT',0,0,0,0,GETDATE() --Provider: KING, KIMBERLY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1006484','0~EXT',0,0,0,0,GETDATE() --Provider: KING, SARA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1023725','0~EXT',0,0,0,0,GETDATE() --Provider: KING, SCOTTY L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000189','0~EXT',0,0,0,0,GETDATE() --Provider: KING, STEVEN DUANE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1030795','0~EXT',0,0,0,0,GETDATE() --Provider: KIRBY, AMY B; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000024','0~EXT',0,0,0,0,GETDATE() --Provider: KLASSEN, WALTER; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1032717','0~EXT',0,0,0,0,GETDATE() --Provider: KLEINLE, STEFANIE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1003906','0~EXT',0,0,0,0,GETDATE() --Provider: KLUMP, KATHRYN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114207','0~EXT',0,0,0,0,GETDATE() --Provider: KNIGHT GLASS, NATALEE N; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~119823','0~EXT',0,0,0,0,GETDATE() --Provider: KNUDSEN, SHELTON; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~102916','0~EXT',0,0,0,0,GETDATE() --Provider: KRAFT, JOEL J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1011175','0~EXT',0,0,0,0,GETDATE() --Provider: KRAMER, KATHRYN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~119378','0~EXT',0,0,0,0,GETDATE() --Provider: KRAMER, PAUL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109334','0~EXT',0,0,0,0,GETDATE() --Provider: KRIEGER, MICHAEL D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110714','0~EXT',0,0,0,0,GETDATE() --Provider: KRISHNAMURTHI, SUBRAMANIAM; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1013161','0~EXT',0,0,0,0,GETDATE() --Provider: KROUSE, ADAM; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109337','0~EXT',0,0,0,0,GETDATE() --Provider: KUMAR, BOMMASAMUDRAM A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~102956','0~EXT',1,0,0,0,GETDATE() --Provider: KUYKENDALL, ELISE M; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~115465','0~EXT',0,0,0,0,GETDATE() --Provider: KUYKENDALL, LAUREN BINDER; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112925','0~EXT',0,0,0,0,GETDATE() --Provider: KYGER, DAVID L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110707','0~EXT',0,0,0,0,GETDATE() --Provider: LAD, CHANDAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112485','0~EXT',0,0,0,0,GETDATE() --Provider: LAIRD, GORDON P; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1006560','0~EXT',0,0,0,0,GETDATE() --Provider: LAIRD, SARAH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1004723','0~EXT',0,0,0,0,GETDATE() --Provider: LANDIS, DEREK TODD; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1011034','0~EXT',0,0,0,0,GETDATE() --Provider: LANE, TRACY ELAINE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~141151','0~EXT',1,0,0,0,GETDATE() --Provider: LANGFORD, KYLE; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000125','0~EXT',0,0,0,0,GETDATE() --Provider: LAWRENCE, GARY M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1025864','0~EXT',0,0,0,0,GETDATE() --Provider: LAWRENCE, KELLI; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000782','0~EXT',0,0,0,0,GETDATE() --Provider: LAWVER, MEGAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109341','0~EXT',0,0,0,0,GETDATE() --Provider: LEBLANC, HELEN D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008871','0~EXT',0,0,0,0,GETDATE() --Provider: LECK, SONYA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1004227','0~EXT',0,0,0,0,GETDATE() --Provider: LEE, ANNDEE N; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1003167','0~EXT',0,0,0,0,GETDATE() --Provider: LEE, BRIAN SPENCER; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103060','0~EXT',0,0,0,0,GETDATE() --Provider: LEE, DANIEL W; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110212','0~EXT',0,0,0,0,GETDATE() --Provider: LEE, FELICIA R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1007612','0~EXT',0,0,0,0,GETDATE() --Provider: LEE, JENNIFER L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112211','0~EXT',0,0,0,0,GETDATE() --Provider: LEGG-JACK, TAMUNOSISI E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1018100','0~EXT',0,0,0,0,GETDATE() --Provider: LEVERETTE, JIMMY R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103096','0~EXT',0,0,0,0,GETDATE() --Provider: LEVERIDGE, CHARLES ANTHONY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1026260','0~EXT',0,0,0,0,GETDATE() --Provider: LEVY, ERNESTO N; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1026505','0~EXT',0,0,0,0,GETDATE() --Provider: LEWIS, KRISTEN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1003362','0~EXT',0,0,0,0,GETDATE() --Provider: LICH, ALEXANDRA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103118','0~EXT',0,0,0,0,GETDATE() --Provider: LIMBAUGH, MANUEL CARL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1015113','0~EXT',0,0,0,0,GETDATE() --Provider: LISHERNESS, LUKE J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~126873','0~EXT',0,0,0,0,GETDATE() --Provider: LITCHFIELD, JENNIFER; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1021859','0~EXT',0,0,0,0,GETDATE() --Provider: LITTLE AXE, INDIAN HEALTH CLINIC; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103142','0~EXT',0,0,0,0,GETDATE() --Provider: LITTLE, KRISTI DAWN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~141790','0~EXT',0,0,0,0,GETDATE() --Provider: LIU, JASON; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107924','0~EXT',0,0,0,0,GETDATE() --Provider: LOFGREN, MARTY M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~129556','0~EXT',0,0,0,0,GETDATE() --Provider: LOGGAINS, BENTON C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1004210','0~EXT',0,0,0,0,GETDATE() --Provider: LOGSDON, JENNIFER ANN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1018770','0~EXT',0,0,0,0,GETDATE() --Provider: LOGSDON, JEREMY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000168','0~EXT',0,0,0,0,GETDATE() --Provider: LONG JR, JOHN STEVEN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~116477','0~EXT',0,0,0,0,GETDATE() --Provider: LONG, KELLY A (FAM MED); Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103172','0~EXT',0,0,0,0,GETDATE() --Provider: LONG, KELLY P (PEDS); Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113023','0~EXT',0,0,0,0,GETDATE() --Provider: LOPER, JEANIE M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111411','0~EXT',0,0,0,0,GETDATE() --Provider: LOVE JR, JAMES T; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1024656','0~EXT',0,0,0,0,GETDATE() --Provider: LOVE, JENNIFER MARIE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111306','0~EXT',0,0,0,0,GETDATE() --Provider: LOVELACE, DAVID M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103198','0~EXT',0,0,0,0,GETDATE() --Provider: LOVELESS, TRINITY M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1026005','0~EXT',0,0,0,0,GETDATE() --Provider: LOVELL, ANDREW; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114237','0~EXT',0,0,0,0,GETDATE() --Provider: LOWRY, AMANDA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114238','0~EXT',0,0,0,0,GETDATE() --Provider: LUCAS, AVIS J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008014','0~EXT',0,0,0,0,GETDATE() --Provider: LUCAS, KELLY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107947','0~EXT',0,0,0,0,GETDATE() --Provider: LUCIO, LINDA, M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1010701','0~EXT',0,0,0,0,GETDATE() --Provider: LUKOSE, ANSON; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109351','0~EXT',0,0,0,0,GETDATE() --Provider: LUNN, CHARLES; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~143295','0~EXT',0,0,0,0,GETDATE() --Provider: LUO, RANDY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103220','0~EXT',0,0,0,0,GETDATE() --Provider: LYND, TARA D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~141417','0~EXT',0,0,0,0,GETDATE() --Provider: LYU, KEVIN W; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103224','0~EXT',0,0,0,0,GETDATE() --Provider: MAAROUF, HODA H; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1030160','0~EXT',0,0,0,0,GETDATE() --Provider: MACKEY, MELINDA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1029923','0~EXT',0,0,0,0,GETDATE() --Provider: MACKIN, LEE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1033377','0~EXT',0,0,0,0,GETDATE() --Provider: MADUPU, ASHWIN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~124584','0~HPICH',1,0,0,0,GETDATE() --Provider: MAHANA, CRYSTAL A; Practice: HPI CH
INSERT INTO map.EpicPracticeProviders SELECT '5~P1026791','0~EXT',0,0,0,0,GETDATE() --Provider: MAKIN, ADAM; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113391','0~EXT',0,0,0,0,GETDATE() --Provider: MALOY, CYNTHIA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103278','0~EXT',0,0,0,0,GETDATE() --Provider: MANNEL, ROBERT S; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1017836','0~EXT',0,0,0,0,GETDATE() --Provider: MANNING, TAMARA SCHUCK; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1003925','0~EXT',0,0,0,0,GETDATE() --Provider: MARTIN, DENISE JOAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1023911','0~EXT',0,0,0,0,GETDATE() --Provider: MARTIN, DUSTIN SCOTT; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111515','0~EXT',0,0,0,0,GETDATE() --Provider: MARTIN, JOHN C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008279','0~EXT',0,0,0,0,GETDATE() --Provider: MARTIN, MICHELLE R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000806','0~EXT',0,0,0,0,GETDATE() --Provider: MASHBURN, WHITNEY T; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103334','0~EXT',0,0,0,0,GETDATE() --Provider: MASON, KEVIN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1010663','0~EXT',0,0,0,0,GETDATE() --Provider: MASTERMAN, MARY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1014594','0~EXT',0,0,0,0,GETDATE() --Provider: MASTERS, CHELSEA MARIE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1017987','0~EXT',0,0,0,0,GETDATE() --Provider: MATHEW, BETSY A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103380','0~EXT',0,0,0,0,GETDATE() --Provider: MATOUSEK, SARAH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114254','0~EXT',0,0,0,0,GETDATE() --Provider: MATSON, TONYA C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1010169','0~EXT',0,0,0,0,GETDATE() --Provider: MATTHEW, GODWIN SALIFU; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1029228','0~EXT',0,0,0,0,GETDATE() --Provider: MATTHEWS, TARA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110443','0~EXT',0,0,0,0,GETDATE() --Provider: MAYER, RENAE L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002494','0~EXT',0,0,0,0,GETDATE() --Provider: MAYS, ISRAEL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1012463','0~EXT',0,0,0,0,GETDATE() --Provider: MCADAMS, PAYTON ELIZABETH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1003865','0~EXT',0,0,0,0,GETDATE() --Provider: MCALLISTER, ASHLEY BUNCE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1019551','0~EXT',0,0,0,0,GETDATE() --Provider: MCCAMMOND, JENNIFER; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1019132','0~EXT',0,0,0,0,GETDATE() --Provider: MCCOLLUM, BRENDAN JAMES; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~118910','0~EXT',0,0,0,0,GETDATE() --Provider: MCCOY, ANGELA C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108025','0~EXT',0,0,0,0,GETDATE() --Provider: MCCRORY, RODNEY O; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104020','0~EXT',0,0,0,0,GETDATE() --Provider: MCCUNE, MARIE M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1016599','0~EXT',0,0,0,0,GETDATE() --Provider: MCFALLS, NATASHA D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111626','0~EXT',0,0,0,0,GETDATE() --Provider: MCINTYRE, DENNIS K; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113644','0~EXT',0,0,0,0,GETDATE() --Provider: MCLEOD, WALLACE B III; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1021628','0~EXT',0,0,0,0,GETDATE() --Provider: MEDICAL CENTER, ACCESS; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~115201','0~EXT',0,0,0,0,GETDATE() --Provider: MEDICO, AMBER L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114392','0~EXT',0,0,0,0,GETDATE() --Provider: MEDLEY, SHANNON J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103571','0~EXT',0,0,0,0,GETDATE() --Provider: MEDVED, ANASTASIA M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1033297','0~EXT',0,0,0,0,GETDATE() --Provider: MEFFORD, MIKAYLA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114268','0~EXT',0,0,0,0,GETDATE() --Provider: MEHL, MYRTH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108048','0~EXT',0,0,0,0,GETDATE() --Provider: MEITES, HERBERT L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~129940','0~EXT',1,0,0,0,GETDATE() --Provider: MENDELL, TAYLOR J; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1004931','0~EXT',0,0,0,0,GETDATE() --Provider: MEREDITH JR, WILLIAM ROBERT; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1032793','0~EXT',0,0,0,0,GETDATE() --Provider: MERRELL, MICHELLE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103603','0~EXT',0,0,0,0,GETDATE() --Provider: MERRITT-SCHIERMEYER, CAROLINE E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113470','0~EXT',0,0,0,0,GETDATE() --Provider: METTRY, CHARLES R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113267','0~EXT',0,0,0,0,GETDATE() --Provider: MEYER, JEFFERY P; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1017283','0~EXT',0,0,0,0,GETDATE() --Provider: MIER GIRAUD, FERNANDO; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1011247','0~EXT',0,0,0,0,GETDATE() --Provider: MIKLES, AMY ALANE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109367','0~EXT',0,0,0,0,GETDATE() --Provider: MILLER, BARBARA H; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~120932','0~EXT',0,0,0,0,GETDATE() --Provider: MILLER, JEFFREY L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109366','0~EXT',0,0,0,0,GETDATE() --Provider: MILLER, JENEICE A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~118608','0~EXT',0,0,0,0,GETDATE() --Provider: MILLER, LAUREN M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1003575','0~EXT',0,0,0,0,GETDATE() --Provider: MILLS, BRANDON SCOTT; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~133323','0~EXT',0,0,0,0,GETDATE() --Provider: MIMS, CATHERINE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1007306','0~EXT',0,0,0,0,GETDATE() --Provider: MINSHALL, JENNIFER LEIGH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108087','0~EXT',0,0,0,0,GETDATE() --Provider: MITROO, SERENA, M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000796','0~EXT',0,0,0,0,GETDATE() --Provider: MITTAL, YOGESH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~115117','0~EXT',0,0,0,0,GETDATE() --Provider: MOBLY, LARRY G; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103709','0~EXT',0,0,0,0,GETDATE() --Provider: MOHAMMAD, AAMIR; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1005951','0~EXT',0,0,0,0,GETDATE() --Provider: MONTIEL II, PATRICIO JOSE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103733','0~EXT',0,0,0,0,GETDATE() --Provider: MOORE, BRIAN C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103735','0~EXT',0,0,0,0,GETDATE() --Provider: MOORE, CRAIG B; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108095','0~EXT',0,0,0,0,GETDATE() --Provider: MOORE, JOHN STEVEN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~125727','0~EXT',0,0,0,0,GETDATE() --Provider: MORGAN, GARRETT W; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1020141','0~EXT',0,0,0,0,GETDATE() --Provider: MORGAN, KEELEY ERIN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1004368','0~EXT',0,0,0,0,GETDATE() --Provider: MORGAN, RANDALL J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109715','0~EXT',0,0,0,0,GETDATE() --Provider: MORGAN, RYAN T; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1009560','0~EXT',0,0,0,0,GETDATE() --Provider: MORRIS, BLAKE TYLER; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1023522','0~EXT',0,0,0,0,GETDATE() --Provider: MORRIS, CHRISTY LYNN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1024635','0~EXT',0,0,0,0,GETDATE() --Provider: MORRISETT, CARLI; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111620','0~EXT',0,0,0,0,GETDATE() --Provider: MORROW, JULIE M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008684','0~EXT',0,0,0,0,GETDATE() --Provider: MORROW, TAMRA A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114286','0~EXT',0,0,0,0,GETDATE() --Provider: MOSE, RHONDA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~116103','0~THP',1,1,0,0,GETDATE() --Provider: MOSS, SHEILA D; Practice: Total Healthcare Partners
INSERT INTO map.EpicPracticeProviders SELECT '5~114289','0~EXT',0,0,0,0,GETDATE() --Provider: MUNCY, DEVON J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1018600','0~EXT',0,0,0,0,GETDATE() --Provider: MUNOZ, CHRISTINE R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~129191','0~EXT',0,0,0,0,GETDATE() --Provider: MUNS, EMILY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1028544','0~EXT',0,0,0,0,GETDATE() --Provider: MURCHISON, LISA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1026248','0~EXT',0,0,0,0,GETDATE() --Provider: MUSA, AHMAD; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109376','0~EXT',0,0,0,0,GETDATE() --Provider: NALLACHERU, SRIKANTH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1012521','0~EXT',0,0,0,0,GETDATE() --Provider: NARR, BRANDON TAYLOR; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1021979','0~EXT',0,0,0,0,GETDATE() --Provider: NAVAS, ALBERTO J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~124190','0~EXT',0,0,0,0,GETDATE() --Provider: NELSON, BRETT ARIC; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~136577','0~EXT',0,0,0,0,GETDATE() --Provider: NELSON, CHRISTOPHER B; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114293','0~EXT',0,0,0,0,GETDATE() --Provider: NELSON, DAMARCUS R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1006924','0~EXT',0,0,0,0,GETDATE() --Provider: NELSON, RALPH JOSEF; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103890','0~HPIPAN',1,0,0,0,GETDATE() --Provider: NESSELRODE, ROBERT L; Practice: HPIP Anesthesia
INSERT INTO map.EpicPracticeProviders SELECT '5~P1020012','0~EXT',0,0,0,0,GETDATE() --Provider: NEUROLOGY, OU; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1007341','0~EXT',0,0,0,0,GETDATE() --Provider: NGHE, XUAN THAO; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109874','0~EXT',0,0,0,0,GETDATE() --Provider: NGO, BICH-THY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103910','0~EXT',0,0,0,0,GETDATE() --Provider: NGUYEN, BAOLONG; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1031775','0~EXT',0,0,0,0,GETDATE() --Provider: NGUYEN, HAYLEY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~115558','0~EXT',0,0,0,0,GETDATE() --Provider: NGUYEN, HIEU CHI; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1021556','0~EXT',0,0,0,0,GETDATE() --Provider: NGUYEN, KATHERINE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~141548','0~EXT',0,0,0,0,GETDATE() --Provider: NGUYEN, PHUONG T; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~115282','0~EXT',0,0,0,0,GETDATE() --Provider: NICHOLS, JENNIFER PAULA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000529','0~EXT',0,0,0,0,GETDATE() --Provider: NOE, LISA DIANE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000739','0~EXT',0,0,0,0,GETDATE() --Provider: NUTTER, BRYAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110801','0~EXT',0,0,0,0,GETDATE() --Provider: OBHRAI, KANWAL K; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1009781','0~EXT',0,0,0,0,GETDATE() --Provider: ODOM, AMANDA KAYE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~115458','0~EXT',0,0,0,0,GETDATE() --Provider: OGDEN, TRACY SUE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1033278','0~EXT',0,0,0,0,GETDATE() --Provider: OGLETREE, SANDRA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1010884','0~EXT',0,0,0,0,GETDATE() --Provider: OKROI, ANGELA M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1015064','0~EXT',0,0,0,0,GETDATE() --Provider: OLMSTED, ERIN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109383','0~EXT',0,0,0,0,GETDATE() --Provider: OLTMANNS, KEVIN L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1012603','0~EXT',0,0,0,0,GETDATE() --Provider: OMEARA, AARON EDWARD; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1021593','0~EXT',0,0,0,0,GETDATE() --Provider: ONE, HEALTHCARE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104040','0~EXT',0,0,0,0,GETDATE() --Provider: O'QUIN, MICHAEL J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1004101','0~EXT',0,0,0,0,GETDATE() --Provider: ORENDORFF, CHRISTOPHER WILLIAM; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~129277','0~EXT',0,0,0,0,GETDATE() --Provider: ORGEL, MATTHEW I; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1031954','0~EXT',0,0,0,0,GETDATE() --Provider: ORICA, LESLIE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104049','0~EXT',0,0,0,0,GETDATE() --Provider: OSBORN, JOHN CLARK; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1031872','0~EXT',0,0,0,0,GETDATE() --Provider: OTOOLE, KARI; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104062','0~EXT',0,0,0,0,GETDATE() --Provider: OVERTURFF, MARY R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1018197','0~EXT',0,0,0,0,GETDATE() --Provider: OWEIS, NICOLE MICHELLE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1031665','0~EXT',0,0,0,0,GETDATE() --Provider: PAHAMARK, SASIPHA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104091','0~EXT',0,0,0,0,GETDATE() --Provider: PANTER, BENJAMIN I; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~118217','0~EXT',0,0,0,0,GETDATE() --Provider: PARCHURI, KRIS; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104102','0~EXT',0,0,0,0,GETDATE() --Provider: PARKER, KRISTI M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1017979','0~EXT',0,0,0,0,GETDATE() --Provider: PARKER, PATRICK W; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1024240','0~EXT',1,0,0,0,GETDATE() --Provider: PARKS, SUZAN; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~120068','0~EXT',0,0,0,0,GETDATE() --Provider: PARTEE, MOLLY KAY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1020808','0~EXT',0,0,0,0,GETDATE() --Provider: PARTIN, AMANDA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~117942','0~EXT',0,0,0,0,GETDATE() --Provider: PASQUE, CHARLES B; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113798','0~EXT',0,0,0,0,GETDATE() --Provider: PATEL, AMISH R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104130','0~EXT',0,0,0,0,GETDATE() --Provider: PATEL, SHAURIN N; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1032880','0~EXT',0,0,0,0,GETDATE() --Provider: PATEL, URVASHI; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1016802','0~EXT',0,0,0,0,GETDATE() --Provider: PATTERSON, NATALIE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~130791','0~EXT',0,0,0,0,GETDATE() --Provider: PEARL, GREGORY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000354','0~EXT',0,0,0,0,GETDATE() --Provider: PELTON, TODD BRADFORD; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~115455','0~EXT',0,0,0,0,GETDATE() --Provider: PENDARVIS, BRIAN TRAVIS; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1007999','0~EXT',0,0,0,0,GETDATE() --Provider: PENICK, ALYSSA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114029','0~EXT',0,0,0,0,GETDATE() --Provider: PENNYPACKER, REGGIE D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~127106','0~EXT',0,0,0,0,GETDATE() --Provider: PENWELL, KEVIN M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~143628','0~EXT',0,0,0,0,GETDATE() --Provider: PERRY, COLTON; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1024226','0~EXT',0,0,0,0,GETDATE() --Provider: PETERSON, DEBRA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1007638','0~EXT',0,0,0,0,GETDATE() --Provider: PETERSON, EMILY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1027948','0~EXT',0,0,0,0,GETDATE() --Provider: PETRICEK, CHRISTIAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1010297','0~EXT',0,0,0,0,GETDATE() --Provider: PHAM, NHUNG; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~123699','0~EXT',0,0,0,0,GETDATE() --Provider: PITTMAN, BRADLEY D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109395','0~EXT',0,0,0,0,GETDATE() --Provider: PITTMAN, JOHN R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1010967','0~EXT',0,0,0,0,GETDATE() --Provider: PLUNK, JESSICA JANAE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108265','0~EXT',0,0,0,0,GETDATE() --Provider: PLUSQUELLEC, PAUL L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1005552','0~EXT',0,0,0,0,GETDATE() --Provider: POEMOCEAH, KENNETH MARCUS; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~135446','0~EXT',0,0,0,0,GETDATE() --Provider: PONDS FOSTER, DEVON MARIE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1031417','0~EXT',0,0,0,0,GETDATE() --Provider: POOR BUFFALO, SHANNA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~128320','0~EXT',0,0,0,0,GETDATE() --Provider: POPE, GEORGE DARBY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~123658','0~EXT',0,0,0,0,GETDATE() --Provider: POPIELEC, STEPHEN E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1011103','0~EXT',0,0,0,0,GETDATE() --Provider: POTTER, SADIE MARIE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1030535','0~EXT',0,0,0,0,GETDATE() --Provider: PRATT, CHRISTOPHER DO; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000187','0~EXT',0,0,0,0,GETDATE() --Provider: PRATT-REID, ANTONIA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1004434','0~EXT',0,0,0,0,GETDATE() --Provider: PRENTICE, HEATHER; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104317','0~EXT',0,0,0,0,GETDATE() --Provider: PRESLAR, PAUL L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000947','0~EXT',0,0,0,0,GETDATE() --Provider: PRICE, JOHN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1003682','0~EXT',0,0,0,0,GETDATE() --Provider: PRICE, PHILLIP TYLER; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109597','0~EXT',0,0,0,0,GETDATE() --Provider: PRICE, WHITNEY M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008218','0~EXT',0,0,0,0,GETDATE() --Provider: PRIDDLE, JOSHUA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1029135','0~EXT',0,0,0,0,GETDATE() --Provider: PROVIDER, NOT IS SYSTEM; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1009452','0~EXT',0,0,0,0,GETDATE() --Provider: PUTNAM, KRISTI ANN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111808','0~EXT',0,0,0,0,GETDATE() --Provider: QUY, TYSON; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~136174','0~EXT',0,0,0,0,GETDATE() --Provider: RADIO, JOHN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001310','0~EXT',0,0,0,0,GETDATE() --Provider: RAINWATER, ELIZABETH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000096','0~EXT',0,0,0,0,GETDATE() --Provider: RAMAKRISHNAN, KALYANASRISHNAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111842','0~EXT',0,0,0,0,GETDATE() --Provider: RAMIREZ, HENRY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1015923','0~EXT',0,0,0,0,GETDATE() --Provider: RAMOS, MICHAEL JOSEPH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002419','0~EXT',0,0,0,0,GETDATE() --Provider: RAMSEY, JUSTIN WAYNE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1024780','0~EXT',0,0,0,0,GETDATE() --Provider: RANGEL, JEANETH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1020088','0~EXT',0,0,0,0,GETDATE() --Provider: RAPP, STEIKA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~143721','0~EXT',0,0,0,0,GETDATE() --Provider: RAY, RONIKA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104413','0~EXT',0,0,0,0,GETDATE() --Provider: RAYAN, GHAZI M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~137617','0~EXT',0,0,0,0,GETDATE() --Provider: RECORD, CHARLSIE GAYLE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113743','0~EXT',0,0,0,0,GETDATE() --Provider: REDDY, PRITHI S; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001879','0~EXT',0,0,0,0,GETDATE() --Provider: REED, KENNETH CALRISIAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1009599','0~EXT',0,0,0,0,GETDATE() --Provider: REGGIO, TAMMIE D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1030769','0~EXT',0,0,0,0,GETDATE() --Provider: REICHENBERGER, JENI; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1004089','0~EXT',0,0,0,0,GETDATE() --Provider: REINECKE, AMBER KATHRYN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1004272','0~EXT',0,0,0,0,GETDATE() --Provider: REINHARDT, LAURA ALLISON; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~131770','0~EXT',0,0,0,0,GETDATE() --Provider: RENKEN, BROCK M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~121771','0~EXT',0,0,0,0,GETDATE() --Provider: RENOUARD, ELIZABETH S; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1022061','0~EXT',0,0,0,0,GETDATE() --Provider: RENTAS, EDUARDO; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113255','0~EXT',0,0,0,0,GETDATE() --Provider: REZAEI, ABOLGHASEM M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~123056','0~EXT',0,0,0,0,GETDATE() --Provider: RHODES, REBECCA A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104485','0~EXT',0,0,0,0,GETDATE() --Provider: RICE, KAYLA A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008136','0~EXT',0,0,0,0,GETDATE() --Provider: RICHARDSON, MICKI; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104497','0~EXT',0,0,0,0,GETDATE() --Provider: RICHEY, TIFFANY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~129247','0~EXT',0,0,0,0,GETDATE() --Provider: RIESENBERG, LANDON A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104510','0~EXT',0,0,0,0,GETDATE() --Provider: RIGGS, MICHAEL O; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113576','0~EXT',0,0,0,0,GETDATE() --Provider: RIMMER, TERRY A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002417','0~EXT',0,0,0,0,GETDATE() --Provider: ROBERTSON, ANTHONY TYLER; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1022421','0~EXT',0,0,0,0,GETDATE() --Provider: ROBERTSON, WHITNEY ALYSE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1021713','0~EXT',0,0,0,0,GETDATE() --Provider: ROBINSON, JONATHAN BARRETT; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1009147','0~EXT',0,0,0,0,GETDATE() --Provider: ROBINSON, VALERIE ELIZABETH JONES; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1005050','0~EXT',0,0,0,0,GETDATE() --Provider: ROCKWOOD, JAMES; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109410','0~EXT',0,0,0,0,GETDATE() --Provider: RODRIGUEZ, ORSON P; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1027409','0~EXT',0,0,0,0,GETDATE() --Provider: ROGERS, BRINON; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002674','0~EXT',0,0,0,0,GETDATE() --Provider: ROGERS, ROBERT B; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1021668','0~EXT',0,0,0,0,GETDATE() --Provider: ROHDE, GREG; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~142446','0~EXT',0,0,0,0,GETDATE() --Provider: ROOF, LESLIE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114911','0~EXT',0,0,0,0,GETDATE() --Provider: RORICK, MARY JANE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~119593','0~EXT',0,0,0,0,GETDATE() --Provider: ROSELIUS, KASSI ANN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108376','0~EXT',0,0,0,0,GETDATE() --Provider: ROSS, CHADWICK B; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1031898','0~EXT',0,0,0,0,GETDATE() --Provider: ROSS, JEFFERY THOMAS; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008998','0~EXT',0,0,0,0,GETDATE() --Provider: ROSSON II, JOHN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109415','0~EXT',0,0,0,0,GETDATE() --Provider: ROTHER, JEFFREY A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111682','0~EXT',0,0,0,0,GETDATE() --Provider: ROTHWELL, DAVID T; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~117724','0~EXT',0,0,0,0,GETDATE() --Provider: ROUSE, ELIZABETH LOUISE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1020990','0~EXT',0,0,0,0,GETDATE() --Provider: RUHL, CORA ELIZABETH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~121635','0~EXT',0,0,0,0,GETDATE() --Provider: RUTHERFORD, CHARLES S; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~136368','0~EXT',0,0,0,0,GETDATE() --Provider: RYAN, BROOKE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1007072','0~EXT',0,0,0,0,GETDATE() --Provider: RYAN, KIM ANN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~117091','0~EXT',1,0,0,0,GETDATE() --Provider: SAKARIAH, BIJI; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1005250','0~EXT',0,0,0,0,GETDATE() --Provider: SALADIN, ELIZABETH JANE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1031643','0~EXT',0,0,0,0,GETDATE() --Provider: SALLEE, BETHANY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110518','0~EXT',0,0,0,0,GETDATE() --Provider: SAMANT, PRIYA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1026875','0~EXT',1,0,0,0,GETDATE() --Provider: SAMUELS, JESSE; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1003772','0~EXT',0,0,0,0,GETDATE() --Provider: SANAULLAH, MUHAMMAD; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~136780','0~EXT',0,0,0,0,GETDATE() --Provider: SANDERSON, ROY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1007673','0~EXT',0,0,0,0,GETDATE() --Provider: SANDKNOP, LES T; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~118073','0~EXT',0,0,0,0,GETDATE() --Provider: SANDMANN-CROW, LAUREN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104696','0~EXT',0,0,0,0,GETDATE() --Provider: SAXTON, DAVID L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108411','0~EXT',0,0,0,0,GETDATE() --Provider: SCAUNASU, ADRIAN A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~115555','0~EXT',0,0,0,0,GETDATE() --Provider: SCEARS, MEGHAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104713','0~EXT',0,0,0,0,GETDATE() --Provider: SCHAUFELE, JULIE A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110115','0~EXT',0,0,0,0,GETDATE() --Provider: SCHEID, DEWEY C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114304','0~EXT',0,0,0,0,GETDATE() --Provider: SCHENK, MARY B; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108419','0~EXT',0,0,0,0,GETDATE() --Provider: SCHIPUL, JOHN J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109424','0~EXT',0,0,0,0,GETDATE() --Provider: SCHOELEN, STEVE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000013','0~EXT',0,0,0,0,GETDATE() --Provider: SCHRECKENGOST, MELISSA K; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1028610','0~EXT',0,0,0,0,GETDATE() --Provider: SCHROEDER, CAITLIN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104741','0~EXT',0,0,0,0,GETDATE() --Provider: SCHROEDER, CHAD M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~138382','0~EXT',0,0,0,0,GETDATE() --Provider: SCHUCANY, WILLIAM G; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108431','0~EXT',0,0,0,0,GETDATE() --Provider: SCHUFF, ANGELA L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001980','0~EXT',0,0,0,0,GETDATE() --Provider: SCHWARTZ, MARK STEVEN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113264','0~EXT',0,0,0,0,GETDATE() --Provider: SCHWERDTFEGER, PETIE A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1022647','0~EXT',0,0,0,0,GETDATE() --Provider: SCOGGINS, RIKKI JUSTICE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~122814','0~EXT',0,0,0,0,GETDATE() --Provider: SEAY, LACEY DANIELLE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114311','0~EXT',0,0,0,0,GETDATE() --Provider: SEILAS, LIJI; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108441','0~EXT',0,0,0,0,GETDATE() --Provider: SELF, PHILIP M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1026220','0~EXT',0,0,0,0,GETDATE() --Provider: SELF, REFERRAL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008907','0~EXT',0,0,0,0,GETDATE() --Provider: SEN, MURAT; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104800','0~EXT',0,0,0,0,GETDATE() --Provider: SERADGE, HOUSHANG; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~118943','0~EXT',0,0,0,0,GETDATE() --Provider: SEVER, CALEB; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000428','0~EXT',0,0,0,0,GETDATE() --Provider: SEYMOUR, KERRI L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1019874','0~EXT',0,0,0,0,GETDATE() --Provider: SHAFFER, RICHARD T; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110498','0~EXT',0,0,0,0,GETDATE() --Provider: SHAH, MUDDASIR A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~135981','0~EXT',0,0,0,0,GETDATE() --Provider: SHAKIR, NABEELA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~142195','0~EXT',0,0,0,0,GETDATE() --Provider: SHARFMAN, ZACHARY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008217','0~EXT',0,0,0,0,GETDATE() --Provider: SHARP, LARRY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1022296','0~EXT',0,0,0,0,GETDATE() --Provider: SHARROCK, HOLLIE ELIZABETH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008251','0~EXT',0,0,0,0,GETDATE() --Provider: SHEBESTER, LAYNIE DAWN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~143702','0~EXT',0,0,0,0,GETDATE() --Provider: SHEFFIELD, ADAM; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108467','0~EXT',0,0,0,0,GETDATE() --Provider: SHEIKH, SAQIB; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~134460','0~EXT',0,0,0,0,GETDATE() --Provider: SHELTON, WILLIAM L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1009210','0~EXT',0,0,0,0,GETDATE() --Provider: SHEN, DANIEL WAY EN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1006225','0~EXT',0,0,0,0,GETDATE() --Provider: SHEPPARD, LINDSEY NICOLE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1030485','0~EXT',0,0,0,0,GETDATE() --Provider: SHERMAN, NICOLE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1025292','0~EXT',1,0,0,0,GETDATE() --Provider: SHOMAN, AUSTIN J; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~108481','0~EXT',0,0,0,0,GETDATE() --Provider: SHUART, JEFFREY R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104891','0~EXT',0,0,0,0,GETDATE() --Provider: SILER, TIMOTHY D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114317','0~EXT',0,0,0,0,GETDATE() --Provider: SIMON, EUNICE J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1009586','0~EXT',0,0,0,0,GETDATE() --Provider: SIMON, TOMMIE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1030835','0~EXT',0,0,0,0,GETDATE() --Provider: SIMPSON, KASEY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104915','0~EXT',0,0,0,0,GETDATE() --Provider: SIMS, LARHONDA K; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110582','0~EXT',0,0,0,0,GETDATE() --Provider: SKINNER, RYAN T; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002736','0~EXT',0,0,0,0,GETDATE() --Provider: SLAYBAUGH, ELISE ECKHARDT; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~141440','0~EXT',0,0,0,0,GETDATE() --Provider: SLOAN, BRITTNEY N; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114321','0~EXT',0,0,0,0,GETDATE() --Provider: SMITH, ALISHA B; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008962','0~EXT',0,0,0,0,GETDATE() --Provider: SMITH, BARBARA LYNN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1018865','0~EXT',0,0,0,0,GETDATE() --Provider: SMITH, BRYAN MATTHEW; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1025099','0~EXT',0,0,0,0,GETDATE() --Provider: SMITH, CHRIS; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104966','0~EXT',0,0,0,0,GETDATE() --Provider: SMITH, GLENN L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~124193','0~EXT',0,0,0,0,GETDATE() --Provider: SMITH, GREGORY ALLAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112197','0~EXT',0,0,0,0,GETDATE() --Provider: SMITH, KATIE M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109997','0~EXT',0,0,0,0,GETDATE() --Provider: SMITH, SANDRA S; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1017886','0~EXT',0,0,0,0,GETDATE() --Provider: SMITH, STACEY LYNN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000808','0~EXT',0,0,0,0,GETDATE() --Provider: SMITH, STEVEN E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1010296','0~EXT',0,0,0,0,GETDATE() --Provider: SNYDER, KRISTINA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1029653','0~EXT',0,0,0,0,GETDATE() --Provider: SOEKAMTO, JONATHAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110870','0~EXT',0,0,0,0,GETDATE() --Provider: SOLANO, AMBROSIO A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1024426','0~EXT',0,0,0,0,GETDATE() --Provider: SOMERO, ERIKA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110192','0~EXT',0,0,0,0,GETDATE() --Provider: SORRELS, CHRISTOPHER W; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001793','0~EXT',0,0,0,0,GETDATE() --Provider: SPARKS, JASON ROBERT; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1006173','0~EXT',0,0,0,0,GETDATE() --Provider: SPENCER, BRANT D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1024985','0~EXT',0,0,0,0,GETDATE() --Provider: SPENCER, KYLE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1013868','0~EXT',0,0,0,0,GETDATE() --Provider: STACY, LAUREL ELIZABETH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111849','0~EXT',0,0,0,0,GETDATE() --Provider: STACY, TADGY D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114335','0~EXT',0,0,0,0,GETDATE() --Provider: STANLEY, HEATHER D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000180','0~EXT',0,0,0,0,GETDATE() --Provider: STEIN, KENNETH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~143419','0~EXT',0,0,0,0,GETDATE() --Provider: STEPHENS, SCOTT; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1004493','0~EXT',0,0,0,0,GETDATE() --Provider: STEVERSON, JACOB KYLE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109446','0~EXT',0,0,0,0,GETDATE() --Provider: STEWART, WILLIAM T; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000340','0~EXT',0,0,0,0,GETDATE() --Provider: STEWART, WILLIAM W; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~133385','0~EXT',0,0,0,0,GETDATE() --Provider: STONEKING, LYNSEY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000421','0~EXT',0,0,0,0,GETDATE() --Provider: STOUT, LYNNETTA F; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114343','0~EXT',0,0,0,0,GETDATE() --Provider: STRONG, MIKA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109449','0~EXT',0,0,0,0,GETDATE() --Provider: STUTZMAN, BRENDA R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~116214','0~EXT',0,0,0,0,GETDATE() --Provider: SUKUT, TARA M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1032198','0~EXT',0,0,0,0,GETDATE() --Provider: SULLIVAN, KELLI; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105204','0~EXT',0,0,0,0,GETDATE() --Provider: SULLIVAN, STEVEN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~121536','0~EXT',0,0,0,0,GETDATE() --Provider: SWANSON, JAMES FRANCIS; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112859','0~EXT',1,0,0,0,GETDATE() --Provider: SWARTZ, COURTNEY L; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1009808','0~EXT',0,0,0,0,GETDATE() --Provider: SWEET, ROBERT; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1011659','0~EXT',0,0,0,0,GETDATE() --Provider: SWEETIN, MARY K; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110908','0~EXT',0,0,0,0,GETDATE() --Provider: SWINNEY, AUDIE G; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1024603','0~EXT',0,0,0,0,GETDATE() --Provider: SYED, AYSHA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105224','0~EXT',0,0,0,0,GETDATE() --Provider: SYKES, LEE T; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105229','0~EXT',0,0,0,0,GETDATE() --Provider: TABIAI, TIFFANY A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112812','0~EXT',0,0,0,0,GETDATE() --Provider: TAN, SYLVIA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000996','0~EXT',0,0,0,0,GETDATE() --Provider: TANNER, ANITA L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109455','0~EXT',0,0,0,0,GETDATE() --Provider: TARDIBONO, GEORGE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109864','0~EXT',0,0,0,0,GETDATE() --Provider: TATE, STEVEN A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1011415','0~EXT',0,0,0,0,GETDATE() --Provider: TAYLOR, CHRISTOPHER AQUIES; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105254','0~EXT',0,0,0,0,GETDATE() --Provider: TAYLOR, JASON M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113398','0~EXT',0,0,0,0,GETDATE() --Provider: TAYLOR-ALBERT, ELIZABETH S; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~137199','0~EXT',0,0,0,0,GETDATE() --Provider: TERRELL, LAUREN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1022344','0~EXT',0,0,0,0,GETDATE() --Provider: TEST, TEST; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~117855','0~EXT',0,0,0,0,GETDATE() --Provider: THANOU, AIKATERINI; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105313','0~EXT',0,0,0,0,GETDATE() --Provider: THOMAS, IRA ARTHUR; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~138377','0~EXT',0,0,0,0,GETDATE() --Provider: THOMAS, JOEL R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114405','0~EXT',0,0,0,0,GETDATE() --Provider: THOMAS, TIMOTHY D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105336','0~EXT',0,0,0,0,GETDATE() --Provider: THOMPSON, CHRISTOPHER L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~121981','0~EXT',0,0,0,0,GETDATE() --Provider: THOMPSON, HEATHER; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000006','0~EXT',0,0,0,0,GETDATE() --Provider: THOMPSON, JANNA K; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108601','0~EXT',0,0,0,0,GETDATE() --Provider: THOMPSON, JEFFREY M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1006862','0~EXT',0,0,0,0,GETDATE() --Provider: THOMPSON, MICHAEL DOUGLAS; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~132873','0~EXT',0,0,0,0,GETDATE() --Provider: THOMPSON, NICOLE A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1011463','0~EXT',0,0,0,0,GETDATE() --Provider: TIPPECONNIC, MICHELLE RENEE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105375','0~EXT',0,0,0,0,GETDATE() --Provider: TIPPIN, HALEY P; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109865','0~EXT',0,0,0,0,GETDATE() --Provider: TIPSWORD, HEATHER; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111239','0~EXT',0,0,0,0,GETDATE() --Provider: TOALSON, THOMAS W; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1027145','0~EXT',0,0,0,0,GETDATE() --Provider: TOENEBOEHN, MATTHEW; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108612','0~EXT',0,0,0,0,GETDATE() --Provider: TOMA, GIGI J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1012987','0~EXT',0,0,0,0,GETDATE() --Provider: TOWRY, SARAH JEANNE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108618','0~EXT',0,0,0,0,GETDATE() --Provider: TRAN, JOHN D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1010575','0~EXT',0,0,0,0,GETDATE() --Provider: TRAN, MY HAHN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~123756','0~EXT',0,0,0,0,GETDATE() --Provider: TRAVIS, CHRISTOPHER TODD; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111794','0~EXT',0,0,0,0,GETDATE() --Provider: TREADWELL, STEPHEN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1029604','0~EXT',0,0,0,0,GETDATE() --Provider: TRIBULL, JENNA L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109116','0~EXT',0,0,0,0,GETDATE() --Provider: TROJAN, RYAN JOSEPH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105436','0~EXT',0,0,0,0,GETDATE() --Provider: TU, DUC M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108628','0~EXT',0,0,0,0,GETDATE() --Provider: TUPPER, JOEL S; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1013554','0~EXT',0,0,0,0,GETDATE() --Provider: TUTAK, NATALIA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111804','0~EXT',0,0,0,0,GETDATE() --Provider: VALLURUPALLI, SANTARAM; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~136581','0~EXT',0,0,0,0,GETDATE() --Provider: VAN DAM, TAYLOR LYNN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1023547','0~EXT',0,0,0,0,GETDATE() --Provider: VANHOOSE, CARRIE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1032002','0~EXT',0,0,0,0,GETDATE() --Provider: VANLANDINGHAM, WILLIAM BRIAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000988','0~EXT',0,0,0,0,GETDATE() --Provider: VARGHESE, JANSON P; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1004916','0~EXT',0,0,0,0,GETDATE() --Provider: VASEER, SAMARA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108655','0~EXT',0,0,0,0,GETDATE() --Provider: VEAL, MONTE, D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1018924','0~EXT',0,0,0,0,GETDATE() --Provider: VEDALA, KRISHNA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1023693','0~EXT',0,0,0,0,GETDATE() --Provider: VELEZPAGAN, GRACE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112567','0~EXT',0,0,0,0,GETDATE() --Provider: VELURY, PADMASHREE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1026089','0~EXT',0,0,0,0,GETDATE() --Provider: VERNON, HAMILTON; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~122712','0~EXT',0,0,0,0,GETDATE() --Provider: VESTAL, JONATHAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1023927','0~EXT',0,0,0,0,GETDATE() --Provider: VIRANI, SHEHNAZ; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112960','0~EXT',0,0,0,0,GETDATE() --Provider: VOIGHT, KRYSTAL M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~126812','0~EXT',0,0,0,0,GETDATE() --Provider: VORWALD, BROCK W; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1032535','0~EXT',0,0,0,0,GETDATE() --Provider: VU, ALBERT; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114510','0~EXT',0,0,0,0,GETDATE() --Provider: VU, DAVID; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1013865','0~EXT',0,0,0,0,GETDATE() --Provider: WALGREN, LAURA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1028471','0~EXT',0,0,0,0,GETDATE() --Provider: WALKER, JASMYNE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001650','0~EXT',0,0,0,0,GETDATE() --Provider: WALLACE, PHYLLIS A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105578','0~EXT',0,0,0,0,GETDATE() --Provider: WALLING, BROOKE A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~133230','0~EXT',0,0,0,0,GETDATE() --Provider: WALSH, JOSEPH E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~122939','0~EXT',0,0,0,0,GETDATE() --Provider: WALWORTH, KELLY J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~121428','0~EXT',0,0,0,0,GETDATE() --Provider: WANG, ZHANJUAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105595','0~EXT',0,0,0,0,GETDATE() --Provider: WARD, DAVID ANDREW; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008227','0~EXT',0,0,0,0,GETDATE() --Provider: WARD, ROBERT; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001770','0~EXT',0,0,0,0,GETDATE() --Provider: WAREN, CARLY DION; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000507','0~EXT',0,0,0,0,GETDATE() --Provider: WASHINGTON, KENNETH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109481','0~EXT',0,0,0,0,GETDATE() --Provider: WATERS, PRESTON A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1015130','0~EXT',0,0,0,0,GETDATE() --Provider: WAUGH, TAYLOR A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1006730','0~EXT',0,0,0,0,GETDATE() --Provider: WEATHERFORD, RENEE A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1025821','0~EXT',0,0,0,0,GETDATE() --Provider: WEAVER, ADAM M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~133713','0~EXT',0,0,0,0,GETDATE() --Provider: WEBB, JAMES E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~126928','0~EXT',0,0,0,0,GETDATE() --Provider: WEBER, NATHANIEL D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001822','0~EXT',0,0,0,0,GETDATE() --Provider: WELLINGTON, REBECCA R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1013102','0~EXT',0,0,0,0,GETDATE() --Provider: WENGER, JILL L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1007994','0~EXT',0,0,0,0,GETDATE() --Provider: WENNER, TREKA B; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112603','0~EXT',0,0,0,0,GETDATE() --Provider: WEST JR, MICHAEL C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1019380','0~EXT',0,0,0,0,GETDATE() --Provider: WHITAKER, CONNIE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002290','0~EXT',0,0,0,0,GETDATE() --Provider: WHITE, CRYSTAL DANIELLE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1004373','0~EXT',0,0,0,0,GETDATE() --Provider: WHITE, HILLARY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105718','0~EXT',0,0,0,0,GETDATE() --Provider: WHITE, JAMES; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1029494','0~EXT',0,0,0,0,GETDATE() --Provider: WHITE, TYLER; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105734','0~EXT',0,0,0,0,GETDATE() --Provider: WHITSON, BRIAN D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105755','0~EXT',0,0,0,0,GETDATE() --Provider: WILEY, JULIE L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000192','0~EXT',0,0,0,0,GETDATE() --Provider: WILHELM, PAUL GERARD; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105794','0~EXT',0,0,0,0,GETDATE() --Provider: WILLIAMS, JOHN M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114369','0~EXT',0,0,0,0,GETDATE() --Provider: WILLIAMS, KATHERINE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002029','0~EXT',0,0,0,0,GETDATE() --Provider: WILLIAMS, LESLIE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1005443','0~EXT',0,0,0,0,GETDATE() --Provider: WILLIAMS, PHILLIP SCOTT; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1017019','0~EXT',0,0,0,0,GETDATE() --Provider: WILLIAMS, STACI Y; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008290','0~EXT',0,0,0,0,GETDATE() --Provider: WILLIAMS, TERRI NICOLE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110675','0~EXT',0,0,0,0,GETDATE() --Provider: WILLIAMSON, SHERRIE G; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105818','0~EXT',0,0,0,0,GETDATE() --Provider: WILLIS, ALYSON B; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109496','0~EXT',0,0,0,0,GETDATE() --Provider: WILSON, CONNIE M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008782','0~EXT',0,0,0,0,GETDATE() --Provider: WILSON, GEORGE KRISTOPHER; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112461','0~EXT',0,0,0,0,GETDATE() --Provider: WILSON, GREGORY L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~118568','0~EXT',0,0,0,0,GETDATE() --Provider: WILSON, LOUIS J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111572','0~EXT',0,0,0,0,GETDATE() --Provider: WILSON, VIVIAN L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1011298','0~EXT',0,0,0,0,GETDATE() --Provider: WINDSCHITL, JEANNETTE ELAINE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111305','0~EXT',0,0,0,0,GETDATE() --Provider: WINFREE, KERSEY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105853','0~EXT',0,0,0,0,GETDATE() --Provider: WING, ARLYN G; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000727','0~EXT',0,0,0,0,GETDATE() --Provider: WINTERS, BRENDA KAY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1025155','0~EXT',0,0,0,0,GETDATE() --Provider: WISTER, ALEXA NICOLE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112748','0~EXT',0,0,0,0,GETDATE() --Provider: WLODAVER, CLIFFORD G; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110773','0~EXT',0,0,0,0,GETDATE() --Provider: WOLF, MITCHELL A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000380','0~EXT',0,0,0,0,GETDATE() --Provider: WOLFE, AMBER D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108783','0~EXT',0,0,0,0,GETDATE() --Provider: WOOD, HAROLD S; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113343','0~EXT',0,0,0,0,GETDATE() --Provider: WOODALL, MONICA M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105893','0~EXT',0,0,0,0,GETDATE() --Provider: WOODRUFF, LINDA S; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110380','0~EXT',0,0,0,0,GETDATE() --Provider: WOODRUFF, ROBERT A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1017325','0~EXT',0,0,0,0,GETDATE() --Provider: WRIGHT, JESSICA RUTH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113222','0~EXT',0,0,0,0,GETDATE() --Provider: WRIGHT, TIMOTHY F; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1014672','0~EXT',0,0,0,0,GETDATE() --Provider: WU, JENNIFER K; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105938','0~EXT',0,0,0,0,GETDATE() --Provider: WYATT, WILLIE G; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~132573','0~EXT',0,0,0,0,GETDATE() --Provider: YANG, CHEE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1004598','0~EXT',0,0,0,0,GETDATE() --Provider: YARBOROUGH, ERIN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002330','0~EXT',0,0,0,0,GETDATE() --Provider: YATES, ASHLEY MEADOR; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1009689','0~EXT',0,0,0,0,GETDATE() --Provider: YOUNG, LISA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1010128','0~EXT',0,0,0,0,GETDATE() --Provider: YOUNG, ROBERT R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1018298','0~EXT',0,0,0,0,GETDATE() --Provider: YOUNG, ROSA KIM; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1031220','0~EXT',0,0,0,0,GETDATE() --Provider: YOURISON, ISAAC; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105980','0~EXT',0,0,0,0,GETDATE() --Provider: YUNT, KEVIN J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1010075','0~EXT',0,0,0,0,GETDATE() --Provider: YURFELD, ILONA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108797','0~EXT',0,0,0,0,GETDATE() --Provider: ZACHARIAS, SONI J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1018410','0~EXT',0,0,0,0,GETDATE() --Provider: ZAMORA, AMBER DAWN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109158','0~EXT',0,0,0,0,GETDATE() --Provider: ZELLMER, JOHNNY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1011263','0~EXT',0,0,0,0,GETDATE() --Provider: ZLATNIK, ISABELLE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1013140','0~EXT',0,0,0,0,GETDATE() --Provider: ZUMWALT, ANNALIESA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1025525','0~EXT',0,0,0,0,GETDATE() --Provider: CARTWRIGHT, MARK; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~101013','0~EXT',0,0,0,0,GETDATE() --Provider: COGAR, BRYAN D; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~136205','0~EXT',0,0,0,0,GETDATE() --Provider: GEORGE, ELIZABETH A; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1020848','0~EXT',0,0,0,0,GETDATE() --Provider: REGIONAL PHYSICAL, THERAPY; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~133753','0~EXT',0,0,0,0,GETDATE() --Provider: PALANIAPPUN, SENTHIL; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~109359','0~EXT',0,0,0,0,GETDATE() --Provider: MCCONNELL, WENDY; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~104094','0~EXT',0,0,0,0,GETDATE() --Provider: PARACHA, MOHAMMAD I; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1007985','0~EXT',0,0,0,0,GETDATE() --Provider: HAYNES, JACOB ASHER; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~109535','0~EXT',0,0,0,0,GETDATE() --Provider: PATEL, TRUSHAR B; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1030436','0~EXT',0,0,0,0,GETDATE() --Provider: HANKS, DAVID; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001915','0~EXT',0,0,0,0,GETDATE() --Provider: KUYKENDALL, TRACY D; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~126008','0~EXT',0,0,0,0,GETDATE() --Provider: ALI, ABEERA; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~100399','0~EXT',0,0,0,0,GETDATE() --Provider: BESON, BRENT A; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~140723','0~EXT',0,0,0,0,GETDATE() --Provider: MORRIS, CHANCE; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1010716','0~EXT',0,0,0,0,GETDATE() --Provider: ELIADES, MYRTO; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~103329','0~EXT',0,0,0,0,GETDATE() --Provider: MASIH, ASHISH K; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~108142','0~EXT',0,0,0,0,GETDATE() --Provider: NAYFA, TERRY M; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~109580','0~EXT',0,0,0,0,GETDATE() --Provider: NEEL, J DAVID; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~108328','0~EXT',0,0,0,0,GETDATE() --Provider: RHINEHART, BRANDON M; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~113595','0~EXT',0,0,0,0,GETDATE() --Provider: MAPLE, JOHN T II; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~100415','0~EXT',0,0,0,0,GETDATE() --Provider: BILAL, AHMAD; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~104823','0~EXT',0,0,0,0,GETDATE() --Provider: SHAVER, JEFFREY T; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000897','0~EXT',0,0,0,0,GETDATE() --Provider: TRAN, TONY HUU; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~132822','0~EXT',0,0,0,0,GETDATE() --Provider: WHITE, EMILY S; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1006441','0~EXT',0,0,0,0,GETDATE() --Provider: CHRISTOFI, VICTORIA; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~111841','0~EXT',0,0,0,0,GETDATE() --Provider: O'LEARY, DENA E; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~118274','0~EXT',0,0,0,0,GETDATE() --Provider: OLIVA, WILLIAM; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~111662','0~EXT',0,0,0,0,GETDATE() --Provider: ALI, TAUSEEF; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~136513','0~EXT',0,0,0,0,GETDATE() --Provider: BURNEIKIS, DOMINYKAS; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~100793','0~EXT',0,0,0,0,GETDATE() --Provider: CAREY, JOSHUA PAUL; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1025679','0~EXT',1,0,0,0,GETDATE() --Provider: CHRISTENSEN, SARAH; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~113952','0~EXT',0,0,0,0,GETDATE() --Provider: DE SOUSA, EDUARDO A; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~101542','0~EXT',0,0,0,0,GETDATE() --Provider: ESPARZA, NATALIE A; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1005797','0~EXT',0,0,0,0,GETDATE() --Provider: LECLAIRE, EDGAR L; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~103633','0~EXT',0,0,0,0,GETDATE() --Provider: MILLER, ANDREA JANAE; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001555','0~EXT',0,0,0,0,GETDATE() --Provider: PIERCEY, JIMMY; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~104802','0~EXT',0,0,0,0,GETDATE() --Provider: SERES, KENNETH A; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~115285','0~EXT',0,0,0,0,GETDATE() --Provider: SHEPHERD, KATHERINE L; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1006976','0~EXT',0,0,0,0,GETDATE() --Provider: TANWIR, MANSOOR; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1028736','0~EXT',0,0,0,0,GETDATE() --Provider: WALLACE, RANDY; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~118566','0~EXT',0,0,0,0,GETDATE() --Provider: WEBB, TYLER; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~105879','0~EXT',0,0,0,0,GETDATE() --Provider: WONG, KENNETH MATTHEW; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000431','0~EXT',0,0,0,0,GETDATE() --Provider: WYNN, DONNY; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~100941','0~EXT',0,0,0,0,GETDATE() --Provider: CHRYSANT, GEORGE; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~101216','0~EXT',0,0,0,0,GETDATE() --Provider: DALY, TIMOTHY; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~101225','0~EXT',0,0,0,0,GETDATE() --Provider: DARTER, AMY LIEBL; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~103702','0~EXT',0,0,0,0,GETDATE() --Provider: MOAD, JEREMY B; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~114810','0~EXT',0,0,0,0,GETDATE() --Provider: PATTERSON, CATHERINE AMBER; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~104414','0~EXT',0,0,0,0,GETDATE() --Provider: RAZA, ABBAS; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~120280','0~EXT',0,0,0,0,GETDATE() --Provider: SEAT, CHRISTOPHER M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110247','0~EXT',0,0,0,0,GETDATE() --Provider: THAKRAL, RISHI; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000286','0~EXT',0,0,0,0,GETDATE() --Provider: AL-BOTROS, ADONIS SIMON; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~122560','0~EXT',0,0,0,0,GETDATE() --Provider: BERRY, AMANDA N; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008147','0~EXT',0,0,0,0,GETDATE() --Provider: BITAR, HUSSEIN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103072','0~EXT',0,0,0,0,GETDATE() --Provider: COATS, SUSAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111096','0~EXT',0,0,0,0,GETDATE() --Provider: CRAIG, LATASHA B; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002578','0~EXT',0,0,0,0,GETDATE() --Provider: CRAWLEY, CARA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000172','0~EXT',0,0,0,0,GETDATE() --Provider: GREGORY, SETH MICHAEL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113185','0~EXT',0,0,0,0,GETDATE() --Provider: JOHN, MICHAEL D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107954','0~EXT',0,0,0,0,GETDATE() --Provider: MADDEN, GEORGE W; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103698','0~EXT',0,0,0,0,GETDATE() --Provider: MITRO, JOSEPH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113877','0~EXT',0,0,0,0,GETDATE() --Provider: PRABHU, VIJAY N; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1005872','0~EXT',0,0,0,0,GETDATE() --Provider: REEDER, CHRISTINA VANIERSEL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1023160','0~EXT',0,0,0,0,GETDATE() --Provider: ROMANO, ERICA B; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112660','0~EXT',0,0,0,0,GETDATE() --Provider: SALEM, GEORGE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105188','0~EXT',0,0,0,0,GETDATE() --Provider: STUBBS, LENNY D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1019885','0~EXT',0,0,0,0,GETDATE() --Provider: THERAPY, SELECT PHYSICAL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105534','0~EXT',0,0,0,0,GETDATE() --Provider: VONGTHAVARAVAT, VERAPAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100130','0~EXT',0,0,0,0,GETDATE() --Provider: ANDERSON, JEROME; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1018265','0~EXT',0,0,0,0,GETDATE() --Provider: CENTRAL, PHYSICAL THERAPY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112511','0~EXT',0,0,0,0,GETDATE() --Provider: CRAIN, RUSSELL D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~122877','0~EXT',0,0,0,0,GETDATE() --Provider: DEES, RICHARD; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105038','0~EXT',0,0,0,0,GETDATE() --Provider: DEPANI-SPARKES, ELISA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001049','0~EXT',0,0,0,0,GETDATE() --Provider: DOSHI, VIRAL K; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110902','0~EXT',0,0,0,0,GETDATE() --Provider: GHATA, JOE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109665','0~EXT',0,0,0,0,GETDATE() --Provider: GLADE, ROBERT S; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~118273','0~EXT',0,0,0,0,GETDATE() --Provider: HARKESS, BENJAMIN BEECHER; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~141243','0~EXT',0,0,0,0,GETDATE() --Provider: HERRITT, BRIAN C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1022199','0~EXT',0,0,0,0,GETDATE() --Provider: IMAGING, AM RAD EVOLUTION; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~102621','0~EXT',0,0,0,0,GETDATE() --Provider: JIA, GREGORY Y; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~144543','0~EBJ',1,0,1,0,GETDATE() --Provider: JOHNSON, ERIC B; Practice: Eric B. Johnson, M.D.
INSERT INTO map.EpicPracticeProviders SELECT '5~102942','0~EXT',0,0,0,0,GETDATE() --Provider: KUMAR, KIRTIDA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~102991','0~EXT',0,0,0,0,GETDATE() --Provider: LANE, RICHARD; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103004','0~EXT',0,0,0,0,GETDATE() --Provider: LANG-SHEPPARD, KELLY M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103131','0~EXT',0,0,0,0,GETDATE() --Provider: LINK, BRIAN A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112370','0~EXT',0,0,0,0,GETDATE() --Provider: MORGAN, AARON; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104067','0~EXT',0,0,0,0,GETDATE() --Provider: OWENS, KERRY C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1023147','0~EXT',0,0,0,0,GETDATE() --Provider: PELVIC HEALTH, VIBE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104682','0~EXT',0,0,0,0,GETDATE() --Provider: SANTOS, PERRY M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105003','0~EXT',0,0,0,0,GETDATE() --Provider: SMITH, STEWART; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1021323','0~EXT',0,0,0,0,GETDATE() --Provider: SPECTRUM, IMAGING; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1021710','0~EXT',0,0,0,0,GETDATE() --Provider: YATES, GAYLEN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1020889','0~EXT',0,0,0,0,GETDATE() --Provider: ZOOM, DIAGNOSTICS; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~135885','0~EXT',0,0,0,0,GETDATE() --Provider: ARCOS, VICENTE K; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1007279','0~EXT',0,0,0,0,GETDATE() --Provider: ARTHAM, SURYA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107050','0~EXT',0,0,0,0,GETDATE() --Provider: ASBURY, JEFFREY M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1017692','0~EXT',0,0,0,0,GETDATE() --Provider: ATAKPO, PAUL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001419','0~EXT',0,0,0,0,GETDATE() --Provider: BARRETT, BARBARA JEAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114926','0~EXT',0,0,0,0,GETDATE() --Provider: BLACK, ALLYSON RENEE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100791','0~EXT',0,0,0,0,GETDATE() --Provider: CAREY, CHRISTOPHER D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1018055','0~EXT',0,0,0,0,GETDATE() --Provider: CENTER, THE IMAGING; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008972','0~EXT',0,0,0,0,GETDATE() --Provider: CHANANA, NITIN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112626','0~EXT',0,0,0,0,GETDATE() --Provider: COLLIER, SUSANNAH L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113108','0~EXT',0,0,0,0,GETDATE() --Provider: DEES, BRETT R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101912','0~EXT',0,0,0,0,GETDATE() --Provider: GONZALEZ, ANNIE L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002019','0~EXT',0,0,0,0,GETDATE() --Provider: GRAY, SYLVIA SUSANA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1019883','0~EXT',0,0,0,0,GETDATE() --Provider: GREENFIELD, MARK; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002509','0~EXT',0,0,0,0,GETDATE() --Provider: GREGORY, JAMES RICHARD; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~102054','0~EXT',0,0,0,0,GETDATE() --Provider: HACKER, KELLY J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~102086','0~EXT',0,0,0,0,GETDATE() --Provider: HALLERAN, SEAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~123559','0~EXT',0,0,0,0,GETDATE() --Provider: HARVEY, SHANI O; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~102199','0~EXT',0,0,0,0,GETDATE() --Provider: HASSOUN, BASEL S; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1004256','0~EXT',0,0,0,0,GETDATE() --Provider: HENDERSON, KYLE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~102688','0~EXT',0,0,0,0,GETDATE() --Provider: JONES, EDWARD D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112622','0~EXT',0,0,0,0,GETDATE() --Provider: KASTENS, DONALD J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~102820','0~EXT',0,0,0,0,GETDATE() --Provider: KHAVARI, SHAWN A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~118177','0~EXT',0,0,0,0,GETDATE() --Provider: LYONS, CHRISTOPHER PATRICK; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001727','0~EXT',0,0,0,0,GETDATE() --Provider: MAQUSI, SUHAIR; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000713','0~EXT',0,0,0,0,GETDATE() --Provider: MOLLET, TODD; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1032462','0~EXT',0,0,0,0,GETDATE() --Provider: PANICO, BRITTANY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111089','0~EXT',0,0,0,0,GETDATE() --Provider: PATEL, ANIL D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1029985','0~EXT',0,0,0,0,GETDATE() --Provider: PHYSICAL THERAPY, ATHLETICO; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111651','0~EXT',0,0,0,0,GETDATE() --Provider: PILLOW, ENSA K; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104369','0~EXT',0,0,0,0,GETDATE() --Provider: RACZKOWSKI, CARL A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104460','0~EXT',0,0,0,0,GETDATE() --Provider: REITER, STEVEN J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000610','0~EXT',0,0,0,0,GETDATE() --Provider: SAHA, AMITABH PRATIM; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104721','0~EXT',0,0,0,0,GETDATE() --Provider: SCHIFFERDECKER, BRANISLAV; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109426','0~EXT',0,0,0,0,GETDATE() --Provider: SEACAT, COURTNEY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108451','0~EXT',0,0,0,0,GETDATE() --Provider: SHAH, SHUJAHAT H; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112729','0~EXT',0,0,0,0,GETDATE() --Provider: SILVESTRE, OMAR; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001406','0~EXT',0,0,0,0,GETDATE() --Provider: SINGHAL, POOJA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105225','0~EXT',1,0,0,1,GETDATE() --Provider: SYLVESTER, CARL L; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~113437','0~EXT',0,0,0,0,GETDATE() --Provider: TOUBIA, NAGIB T; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108673','0~EXT',0,0,0,0,GETDATE() --Provider: WALLACE, TRENTON D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114520','0~EXT',0,0,0,0,GETDATE() --Provider: WEAVER, TIMOTHY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109541','0~EXT',0,0,0,0,GETDATE() --Provider: WICKS, RYAN F; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~136171','0~EXT',0,0,0,0,GETDATE() --Provider: ABRAHAMS, ELDHOSE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~143806','0~EXT',0,0,0,0,GETDATE() --Provider: ADEPOJU, ADEDAMOLA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110813','0~EXT',0,0,0,0,GETDATE() --Provider: ALWARD, ERIN K; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100151','0~EXT',0,0,0,0,GETDATE() --Provider: ANDRUS, JOHN C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~116368','0~EXT',0,0,0,0,GETDATE() --Provider: ARGO, JIMMY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~124985','0~EXT',0,0,0,0,GETDATE() --Provider: ARULKUMAR, SAILESH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1026601','0~EXT',0,0,0,0,GETDATE() --Provider: ATHLETICO, PHYSICAL THERAPY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001504','0~EXT',0,0,0,0,GETDATE() --Provider: BELLAK, JASON MICHAEL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109875','0~EXT',0,0,0,0,GETDATE() --Provider: BENDURE, WILLIAM B; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107141','0~EXT',0,0,0,0,GETDATE() --Provider: BLALOCK, DEBORAH SUE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1007718','0~EXT',0,0,0,0,GETDATE() --Provider: BOOTH, KRISTINA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000253','0~EXT',0,0,0,0,GETDATE() --Provider: BRAZEAL, TIFFANY GAIL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100599','0~EXT',0,0,0,0,GETDATE() --Provider: BRITTON, BRADLEY D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~130288','0~EXT',0,0,0,0,GETDATE() --Provider: BROWN, JASON A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100677','0~EXT',0,0,0,0,GETDATE() --Provider: BRYANT, JENNIFER; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100684','0~EXT',0,0,0,0,GETDATE() --Provider: BUENDIA, JOSEPH C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1009305','0~EXT',0,0,0,0,GETDATE() --Provider: BURROUGHS, ADAM G; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1030238','0~EXT',0,0,0,0,GETDATE() --Provider: BYERS, JACOB Q; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~127209','0~EXT',0,0,0,0,GETDATE() --Provider: CAIN, SARAH E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109242','0~EXT',0,0,0,0,GETDATE() --Provider: CARTER, STEVEN N; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~126590','0~EXT',0,0,0,0,GETDATE() --Provider: CEASE, ANDREW; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1003237','0~EXT',0,0,0,0,GETDATE() --Provider: CLOUD, DINAH SUE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~125762','0~EXT',0,0,0,0,GETDATE() --Provider: DUNN, IAN F; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101448','0~EXT',0,0,0,0,GETDATE() --Provider: DYER JR, ROBERT K; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1019488','0~EXT',0,0,0,0,GETDATE() --Provider: EDMOND, MERCY THERAPY SERVICES; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109303','0~EXT',0,0,0,0,GETDATE() --Provider: HADDAD, PHILLIP A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~102105','0~EXT',0,0,0,0,GETDATE() --Provider: HAMPTON, DIANA E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110399','0~EXT',0,0,0,0,GETDATE() --Provider: HAWKINS, BEAU M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1017964','0~EXT',0,0,0,0,GETDATE() --Provider: HEILEN, LATISHA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~102375','0~EXT',0,0,0,0,GETDATE() --Provider: HOLLEN, CHARLES W; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113956','0~EXT',0,0,0,0,GETDATE() --Provider: HONG, SHIH-KUANG; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110080','0~EXT',0,0,0,0,GETDATE() --Provider: HUMMER, KIMBERLEY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1006580','0~EXT',0,0,0,0,GETDATE() --Provider: JACKSON, JARED R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001025','0~EXT',0,0,0,0,GETDATE() --Provider: JOHN, ANDREW RILEY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109684','0~EXT',0,0,0,0,GETDATE() --Provider: JONES, KATHRYN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000101','0~EXT',0,0,0,0,GETDATE() --Provider: KAKISH, WILLIAM RANDALL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~115462','0~EXT',0,0,0,0,GETDATE() --Provider: KARUNAPUZHA, CHERIAN ABRAHAM; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~131811','0~EXT',0,0,0,0,GETDATE() --Provider: KHAN, ARIFA M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110272','0~EXT',0,0,0,0,GETDATE() --Provider: KHAN, TEHSEEN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1003023','0~EXT',0,0,0,0,GETDATE() --Provider: KHANNA, VARUN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~102963','0~MSO',0,0,0,0,GETDATE() --Provider: LABRIE, DEBORAH D; Practice: M. Sean O'Brien, D.O.
INSERT INTO map.EpicPracticeProviders SELECT '5~123363','0~EXT',0,0,0,0,GETDATE() --Provider: LEVY, AIMEE DAWN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103102','0~EXT',0,0,0,0,GETDATE() --Provider: LEWIS, KAYCI D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103269','0~EXT',0,0,0,0,GETDATE() --Provider: MANDANAS, ROMEO A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~115482','0~EXT',0,0,0,0,GETDATE() --Provider: MARTIN, STEPHEN ROSS; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112433','0~EXT',0,0,0,0,GETDATE() --Provider: MCCOLLOM, VANCE E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002762','0~EXT',0,0,0,0,GETDATE() --Provider: MCKINNEY, KIBWEI A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1024137','0~EXT',0,0,0,0,GETDATE() --Provider: MILLER, JEFFERY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1016386','0~EXT',0,0,0,0,GETDATE() --Provider: MOCK, KYLE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1005287','0~EXT',0,0,0,0,GETDATE() --Provider: MORGAN, CHRISTOPHER D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112912','0~EXT',0,0,0,0,GETDATE() --Provider: NAEL, RAHA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103862','0~EXT',0,0,0,0,GETDATE() --Provider: NANDA, SUMIT K; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1018500','0~EXT',0,0,0,0,GETDATE() --Provider: NGUYEN, KRISTY D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1018078','0~EXT',0,0,0,0,GETDATE() --Provider: PETER STANBRO, MD, MPH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008020','0~EXT',0,0,0,0,GETDATE() --Provider: PHILIP, DEEPA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~140939','0~EXT',1,0,0,0,GETDATE() --Provider: PITTMAN, STEPHEN; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1029716','0~EXT',0,0,0,0,GETDATE() --Provider: PREMIER, BREAST HEALTH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104347','0~EXT',0,0,0,0,GETDATE() --Provider: PULS, ALAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1006600','0~EXT',0,0,0,0,GETDATE() --Provider: RAMADAN, MOHAMMAD OMAR; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109805','0~EXT',0,0,0,0,GETDATE() --Provider: RAPARTHI, AGNEL R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~127175','0~EXT',0,0,0,0,GETDATE() --Provider: RENFRO, BONNIE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104474','0~EXT',0,0,0,0,GETDATE() --Provider: REYES, SANTIAGO R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1018664','0~EXT',1,0,0,1,GETDATE() --Provider: RHODES, ROBERT M; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001587','0~EXT',0,0,0,0,GETDATE() --Provider: ROTH, JONATHAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~3080153','0~EXT',0,0,0,0,GETDATE() --Provider: RPB_WEWOKA INDIAN HEALTH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108422','0~EXT',0,0,0,0,GETDATE() --Provider: SCHMIDT, DWAYNE A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114043','0~EXT',0,0,0,0,GETDATE() --Provider: SHADFAR, SCOTT; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~122255','0~EXT',0,0,0,0,GETDATE() --Provider: SHAMBAYATI, MARYAM; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104883','0~EXT',0,0,0,0,GETDATE() --Provider: SIDDIQUE, BUSHRA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109447','0~EXT',0,0,0,0,GETDATE() --Provider: STIERLEN, LOYAL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105157','0~EXT',0,0,0,0,GETDATE() --Provider: STOKESBERRY, DAVID S; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105238','0~EXT',0,0,0,0,GETDATE() --Provider: TARPAY, MARTHA M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1031141','0~EXT',0,0,0,0,GETDATE() --Provider: THERAWEST, PHYSICAL THERAPY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1032293','0~EXT',0,0,0,0,GETDATE() --Provider: TOUCHSTONE IMG, EDMOND; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1032626','0~EXT',0,0,0,0,GETDATE() --Provider: TOUCHSTONE, IMAGING; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002442','0~EXT',0,0,0,0,GETDATE() --Provider: TRACZYK II, RICK; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109465','0~EXT',0,0,0,0,GETDATE() --Provider: TRANG, LIEM Q; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1029979','0~EXT',0,0,0,0,GETDATE() --Provider: UNKNOWN PRACTICE A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1025635','0~EXT',0,0,0,0,GETDATE() --Provider: VALIR PHYSICAL THERAPY, EDMOND; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105682','0~EXT',0,0,0,0,GETDATE() --Provider: WENDELKEN, JAMES ANDREW; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105948','0~EXT',0,0,0,0,GETDATE() --Provider: YASIN, IRIM S; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105952','0~EXT',0,0,0,0,GETDATE() --Provider: YATES, GAYLAN D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1030977','0~EXT',0,0,0,0,GETDATE() --Provider: AARON, MERYL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100008','0~EXT',0,0,0,0,GETDATE() --Provider: ABID, HUMAIRA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1022434','0~EXT',0,0,0,0,GETDATE() --Provider: ACTION PHYSICAL THERAPY, HARRAH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001039','0~EXT',0,0,0,0,GETDATE() --Provider: AGEE, CARSON KENDALL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~117943','0~EXT',0,0,0,0,GETDATE() --Provider: AHMAD, SHOAIB; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100082','0~EXT',0,0,0,0,GETDATE() --Provider: ALI, FAZAL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100086','0~EXT',0,0,0,0,GETDATE() --Provider: ALLEN, ARIELLE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100115','0~EXT',0,0,0,0,GETDATE() --Provider: AMAYEM, AHMED A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111440','0~EXT',0,0,0,0,GETDATE() --Provider: AMBAW, SAMSON M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114444','0~EXT',0,0,0,0,GETDATE() --Provider: AMIN, RAJENDRA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1012020','0~EXT',0,0,0,0,GETDATE() --Provider: ANDERSON, BRADLEY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107028','0~EXT',0,0,0,0,GETDATE() --Provider: ANDERSON, CHARLES D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001467','0~EXT',0,0,0,0,GETDATE() --Provider: ARRIENS, CRISTINA GALE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~136081','0~EXT',0,0,0,0,GETDATE() --Provider: ASHRAF, OBAID; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113861','0~EXT',0,0,0,0,GETDATE() --Provider: BAIRD, CLINTON J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107077','0~EXT',0,0,0,0,GETDATE() --Provider: BALUJA, PANKAJ, M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1006814','0~EXT',0,0,0,0,GETDATE() --Provider: BARNES, MACKENZIE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1033209','0~EXT',0,0,0,0,GETDATE() --Provider: BARNGROVER, KEN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008941','0~EXT',0,0,0,0,GETDATE() --Provider: BATTLES, JARROD; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107106','0~EXT',0,0,0,0,GETDATE() --Provider: BEAN, GORDON J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110567','0~EXT',0,0,0,0,GETDATE() --Provider: BELL, JOHN M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100386','0~EXT',0,0,0,0,GETDATE() --Provider: BERGNER, MICHELLE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~122260','0~EXT',0,0,0,0,GETDATE() --Provider: BRANCH, CHADWICK; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100646','0~EXT',0,0,0,0,GETDATE() --Provider: BROWN, LEIGHANN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1030524','0~EXT',0,0,0,0,GETDATE() --Provider: BROWN, MATTHEW; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1021537','0~EXT',0,0,0,0,GETDATE() --Provider: CANTU-CLATZA, JUAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100832','0~EXT',0,0,0,0,GETDATE() --Provider: CARTER, BRADLEY D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1032393','0~EXT',0,0,0,0,GETDATE() --Provider: CHANGES, POSITIVE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109246','0~EXT',0,0,0,0,GETDATE() --Provider: CHEEMA, ZAHID F; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109248','0~EXT',0,0,0,0,GETDATE() --Provider: CHOHAN, ASIM J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110764','0~EXT',0,0,0,0,GETDATE() --Provider: CHONG, LAURA K; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100938','0~EXT',0,0,0,0,GETDATE() --Provider: CHRISTENSEN, ROBERT J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100940','0~EXT',0,0,0,0,GETDATE() --Provider: CHRISTIE, GAVIN C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100958','0~EXT',0,0,0,0,GETDATE() --Provider: CLARK, KEITH F; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~100971','0~EXT',0,0,0,0,GETDATE() --Provider: CLARK, ROBERT M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1024519','0~EXT',0,0,0,0,GETDATE() --Provider: CLARY, ZACHARY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112598','0~EXT',0,0,0,0,GETDATE() --Provider: COLLAZO, WILLIAM A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1033235','0~EXT',0,0,0,0,GETDATE() --Provider: COLLEGE OF DENISTRY, OU; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008442','0~EXT',0,0,0,0,GETDATE() --Provider: COLLINS, LINDSEY KAY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101064','0~EXT',0,0,0,0,GETDATE() --Provider: CONNER, STEPHEN B; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101072','0~EXT',0,0,0,0,GETDATE() --Provider: COOK III, WILLIAM W; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109256','0~EXT',0,0,0,0,GETDATE() --Provider: COOKSON, MICHAEL S; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112918','0~EXT',0,0,0,0,GETDATE() --Provider: CRAWLEY, CHAD; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1009340','0~EXT',0,0,0,0,GETDATE() --Provider: DEMARZO, DANIELLE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1027388','0~EXT',0,0,0,0,GETDATE() --Provider: DERMATOLOGY, LAM; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112564','0~EXT',0,0,0,0,GETDATE() --Provider: DERNAIKA, TAREK A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~119620','0~EXT',0,0,0,0,GETDATE() --Provider: DIMACHKIE, PERIHAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002146','0~EXT',0,0,0,0,GETDATE() --Provider: DOYLE, LANCE B; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112625','0~EXT',0,0,0,0,GETDATE() --Provider: DREVETS, DOUGLAS A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112270','0~EXT',0,0,0,0,GETDATE() --Provider: DULL, SCOTT T; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008570','0~EXT',0,0,0,0,GETDATE() --Provider: ECHOLS, ANTHONY C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~129596','0~EXT',0,0,0,0,GETDATE() --Provider: EL HAJ CHEHADE, AHEL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008478','0~EXT',0,0,0,0,GETDATE() --Provider: EL RASSI, EDWARD T; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101496','0~EXT',0,0,0,0,GETDATE() --Provider: ELKINS, CHARLES C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101511','0~EXT',0,0,0,0,GETDATE() --Provider: ELLIS, DAVID P; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1030283','0~EXT',0,0,0,0,GETDATE() --Provider: ENHANCED, WOUND CARE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1011432','0~EXT',0,0,0,0,GETDATE() --Provider: ERSTENIUK, BLAIRE ALLYN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1018412','0~EXT',0,0,0,0,GETDATE() --Provider: FAIRVIEW REGIONAL MEDICAL CENTER; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1029648','0~EXT',0,0,0,0,GETDATE() --Provider: FITZPATRICK, JENNIFER; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1027577','0~EXT',0,0,0,0,GETDATE() --Provider: FULLER, COLIN WYATT; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~119632','0~EXT',0,0,0,0,GETDATE() --Provider: GARCIA, EDUARDO; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~101786','0~EXT',0,0,0,0,GETDATE() --Provider: GARNER, WILLIAM; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107556','0~EXT',0,0,0,0,GETDATE() --Provider: GIERMAN, JOSHUA, M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1006357','0~EXT',0,0,0,0,GETDATE() --Provider: GLAZE, TYLER W; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001850','0~EXT',0,0,0,0,GETDATE() --Provider: GOFF, CHRISTOPHER; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1026231','0~EXT',0,0,0,0,GETDATE() --Provider: GOODMAN, BRIAN T; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1027496','0~EXT',0,0,0,0,GETDATE() --Provider: GRAFFEO, CHRISTOPHER SALVATORE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113418','0~EXT',0,0,0,0,GETDATE() --Provider: GRAU, RENEE H; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1007483','0~EXT',0,0,0,0,GETDATE() --Provider: GREWELL, PAIGE ELIZABETH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1005963','0~EXT',0,0,0,0,GETDATE() --Provider: GRIFFITH, KYLE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110761','0~EXT',0,0,0,0,GETDATE() --Provider: HALL, THOMAS C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1014646','0~EXT',0,0,0,0,GETDATE() --Provider: HAMILTON, ROBERT; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1012738','0~EXT',0,0,0,0,GETDATE() --Provider: HANING, JUSTIN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001326','0~EXT',0,0,0,0,GETDATE() --Provider: HANSEN, KARL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~102128','0~EXT',0,0,0,0,GETDATE() --Provider: HARAGSIM, LUKAS; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1027620','0~EXT',0,0,0,0,GETDATE() --Provider: HASLAM, MICHAEL L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~135862','0~EXT',0,0,0,0,GETDATE() --Provider: HEIN, RACHEL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114399','0~EXT',0,0,0,0,GETDATE() --Provider: HEIN, ROBERT A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~102286','0~EXT',0,0,0,0,GETDATE() --Provider: HERLIHY, RICHARD E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~102297','0~EXT',0,0,0,0,GETDATE() --Provider: HESTER III, RALPH B; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113196','0~EXT',0,0,0,0,GETDATE() --Provider: HINOJOSA, WILLIAM D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1016376','0~EXT',0,0,0,0,GETDATE() --Provider: HOBBY LOBBY, CLINIC OF; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110302','0~EXT',0,0,0,0,GETDATE() --Provider: HOLBROOK, ROBERT M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~102381','0~EXT',0,0,0,0,GETDATE() --Provider: HOLLOMAN, ERIN L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113358','0~EXT',0,0,0,0,GETDATE() --Provider: HOLTER-CHAKRABA, JENNIFER L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001170','0~EXT',0,0,0,0,GETDATE() --Provider: HORNICK, LESLIE B; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1018528','0~EXT',0,0,0,0,GETDATE() --Provider: HOSPITAL, COMMUNITY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~140855','0~EXT',0,0,0,0,GETDATE() --Provider: HUANG, AMANDA D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~102496','0~EXT',0,0,0,0,GETDATE() --Provider: HUMMEL, JOHN C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1030907','0~EXT',0,0,0,0,GETDATE() --Provider: IMAGING, ZOOM; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~102546','0~EXT',0,0,0,0,GETDATE() --Provider: JACKSON, ANTHONY D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~116277','0~EXT',0,0,0,0,GETDATE() --Provider: JOHNSON, JEREMY JON; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111802','0~EXT',0,0,0,0,GETDATE() --Provider: JOLLIFF, KEVIN L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~102696','0~EXT',0,0,0,0,GETDATE() --Provider: JONES, JUSTIN M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1012226','0~EXT',0,0,0,0,GETDATE() --Provider: KAHANDA, RAHAL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113669','0~EXT',0,0,0,0,GETDATE() --Provider: KANDIMALA, GEETHA B; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1029335','0~EXT',0,0,0,0,GETDATE() --Provider: KEMPTON, INSURANCE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~120651','0~EXT',0,0,0,0,GETDATE() --Provider: KHAN, TAHA JAWAID; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~127990','0~EXT',0,0,0,0,GETDATE() --Provider: KHAN, TARIQ A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~120010','0~EXT',0,0,0,0,GETDATE() --Provider: KHAN, ZEESHAN AKHTAR; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~102819','0~EXT',0,0,0,0,GETDATE() --Provider: KHASTGIR, TERRANCE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1022577','0~EXT',0,0,0,0,GETDATE() --Provider: KICKAPOO ST, SSM HEALTH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110081','0~EXT',0,0,0,0,GETDATE() --Provider: KIPGEN, WYNTER WILLIAMS; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1031666','0~EXT',0,0,0,0,GETDATE() --Provider: KIRK, LYNELLE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~123620','0~EXT',0,0,0,0,GETDATE() --Provider: KODURU, PRAMODA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~102904','0~EXT',0,0,0,0,GETDATE() --Provider: KOHLI, VIVEK; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107861','0~EXT',0,0,0,0,GETDATE() --Provider: KUMAR, RAJESH N; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~124225','0~EXT',0,0,0,0,GETDATE() --Provider: LANDRY, AMBER CHANTELL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103030','0~EXT',0,0,0,0,GETDATE() --Provider: LAW, GEORGE STANFORD; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1027444','0~EXT',0,0,0,0,GETDATE() --Provider: LESPERANCE, MARCI MARIE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103110','0~EXT',0,0,0,0,GETDATE() --Provider: LI, FIONA Y; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1005573','0~EXT',0,0,0,0,GETDATE() --Provider: LIM, MARIA EMMELINE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~129619','0~EXT',0,0,0,0,GETDATE() --Provider: LINDEMUTH, MARY K; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114236','0~EXT',0,0,0,0,GETDATE() --Provider: LOWE, PAUL F; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~107958','0~EXT',0,0,0,0,GETDATE() --Provider: MAGNESS, STEVEN M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103274','0~EXT',0,0,0,0,GETDATE() --Provider: MANJUNATH, GURUPRASAD; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~113872','0~EXT',0,0,0,0,GETDATE() --Provider: MARSHALL, JACK E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1033207','0~EXT',0,0,0,0,GETDATE() --Provider: MARTIN, MARY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1007967','0~EXT',0,0,0,0,GETDATE() --Provider: MARTINOVIC, MARYANN E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001884','0~EXT',0,0,0,0,GETDATE() --Provider: MARTUCCI, MARTIN LEO; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1012183','0~EXT',0,0,0,0,GETDATE() --Provider: MATHIAS, BRITTANY JO; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~125392','0~EXT',0,0,0,0,GETDATE() --Provider: MATTHEWS, PAMELA SUE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1028873','0~EXT',0,0,0,0,GETDATE() --Provider: MCBRIDE, JEFFREY D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~124175','0~EXT',0,0,0,0,GETDATE() --Provider: MCGARRY, ANDREW M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112786','0~EXT',0,0,0,0,GETDATE() --Provider: MCGATH, JOHN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~133154','0~EXT',0,0,0,0,GETDATE() --Provider: MCQUARY, ANNA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110356','0~EXT',0,0,0,0,GETDATE() --Provider: MEHDI, NIGHAT F; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~126802','0~EXT',0,0,0,0,GETDATE() --Provider: MELSON, ANDREW THOMAS; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~115177','0~EXT',0,0,0,0,GETDATE() --Provider: MELTON, JACK W; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1021729','0~EXT',0,0,0,0,GETDATE() --Provider: MERCY HOSPITAL OKLAHOMA CITY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1031285','0~EXT',0,0,0,0,GETDATE() --Provider: MERCY, GI; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1029174','0~EXT',0,0,0,0,GETDATE() --Provider: MERCY, ORTHO; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~114458','0~EXT',0,0,0,0,GETDATE() --Provider: MERKEY, MICHAEL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1007047','0~EXT',0,0,0,0,GETDATE() --Provider: MILLER, JOSEPH E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103667','0~EXT',1,0,0,1,GETDATE() --Provider: MILLER, WILLIAM J; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~103814','0~EXT',0,0,0,0,GETDATE() --Provider: MUCHMORE, JOHN S; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1003349','0~EXT',0,0,0,0,GETDATE() --Provider: NAQVI, SYED; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~126931','0~EXT',0,0,0,0,GETDATE() --Provider: NECHTOW, WILLIAM; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~108152','0~EXT',0,0,0,0,GETDATE() --Provider: NELSON, JOHN W; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109379','0~EXT',0,0,0,0,GETDATE() --Provider: NORMAN, DEREK; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~103957','0~EXT',0,0,0,0,GETDATE() --Provider: NORMAN, JENNIFER; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~121260','0~EXT',0,0,0,0,GETDATE() --Provider: O'BRIEN, JAMES CLAYTON; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1022781','0~EXT',0,0,0,0,GETDATE() --Provider: OKLAHOMA KIDNEY CARE OUTSIDE MESSAGES; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1021380','0~EXT',0,0,0,0,GETDATE() --Provider: OKLAHOMA, ARTHRITIS CENTER; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~115480','0~EXT',0,0,0,0,GETDATE() --Provider: OLLAR-SHOEMAKE, LESLIE JUNE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001418','0~EXT',0,0,0,0,GETDATE() --Provider: ONESON, RUTH H; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1024796','0~EXT',0,0,0,0,GETDATE() --Provider: OU HEALTH PHYSICIANS, PSYCHIATRY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1025624','0~EXT',0,0,0,0,GETDATE() --Provider: OU HEALTH, PHYSICIANS; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110297','0~EXT',0,0,0,0,GETDATE() --Provider: OVERHULSER, PATRICIA I; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1032919','0~EXT',0,0,0,0,GETDATE() --Provider: OZAKI, CHARLES; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~136527','0~EXT',0,0,0,0,GETDATE() --Provider: PALMER, MICHAEL C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000154','0~EXT',0,0,0,0,GETDATE() --Provider: PAPPY, REJI MATHEW; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1010221','0~EXT',0,0,0,0,GETDATE() --Provider: PARKE, CADE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002459','0~EXT',0,0,0,0,GETDATE() --Provider: PARKS, JON CHARLES; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~115261','0~EXT',0,0,0,0,GETDATE() --Provider: PATHAK, SUJAN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1004206','0~EXT',0,0,0,0,GETDATE() --Provider: PAYNE, JOSHUA E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1023104','0~EXT',0,0,0,0,GETDATE() --Provider: PETERSON, LAUREN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002996','0~EXT',0,0,0,0,GETDATE() --Provider: PHAM, ANTHONY TRUNG; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1026300','0~EXT',1,0,0,0,GETDATE() --Provider: PHILLIPS, TYLER; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1030744','0~EXT',0,0,0,0,GETDATE() --Provider: PHYSICAL THERAPY, ECHO; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111331','0~EXT',0,0,0,0,GETDATE() --Provider: PICKARD, DARRELL J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002464','0~EXT',0,0,0,0,GETDATE() --Provider: PICKETT, STEPHANIE DETER; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1030407','0~EXT',1,0,0,0,GETDATE() --Provider: PORTER, JUSTIN R; Practice: External
INSERT INTO map.EpicPracticeProviders SELECT '5~104309','0~EXT',0,0,0,0,GETDATE() --Provider: PRABHU, SANTOSH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000252','0~EXT',0,0,0,0,GETDATE() --Provider: PRASAD, NIRAJ KISHORE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1003634','0~EXT',0,0,0,0,GETDATE() --Provider: PRIVOTT, MARK B; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104368','0~EXT',0,0,0,0,GETDATE() --Provider: RABLE, DENISE L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1031674','0~EXT',0,0,0,0,GETDATE() --Provider: RADIOLOGY, CDI; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~117345','0~EXT',0,0,0,0,GETDATE() --Provider: RAHHAL, JOHN MARK; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1005563','0~EXT',0,0,0,0,GETDATE() --Provider: RAINES, ALEXANDER R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104383','0~EXT',0,0,0,0,GETDATE() --Provider: RAMGOPAL, VADAKEPAT; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~124684','0~EXT',0,0,0,0,GETDATE() --Provider: RANDHAWA, PAL SINGH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~124739','0~EXT',0,0,0,0,GETDATE() --Provider: REEVES, PATRICK B; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1020003','0~EXT',0,0,0,0,GETDATE() --Provider: REHABILITATION, VALIR; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001185','0~EXT',0,0,0,0,GETDATE() --Provider: REVELIS, ANDREAS FRANK; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008434','0~EXT',0,0,0,0,GETDATE() --Provider: RICH, BRIAN KEITH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1025268','0~EXT',0,0,0,0,GETDATE() --Provider: ROBINSON, DARRELL C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1025863','0~EXT',0,0,0,0,GETDATE() --Provider: ROBINSON, JIMMY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~3080203','0~EXT',0,0,0,0,GETDATE() --Provider: RPB_JACKSON COUNTY MEMORIAL HOSPITAL AUTHORITY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~3080434','0~EXT',0,0,0,0,GETDATE() --Provider: RPB_MERCY CLINIC PRIMARY CARE I-35; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~3080391','0~EXT',0,0,0,0,GETDATE() --Provider: RPB_ST MARYS PHYSICIAN ASSOCIATES, LLC; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~133889','0~EXT',0,0,0,0,GETDATE() --Provider: RUGHANI, ANKUR; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1022022','0~EXT',0,0,0,0,GETDATE() --Provider: SAHINLER, BOLKAR; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1005672','0~EXT',0,0,0,0,GETDATE() --Provider: SCHROEDER, KRISTA L; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~126434','0~WAS',1,0,1,0,GETDATE() --Provider: SCHWERDTFEGER, WADE A; Practice: Wade A. Schwerdtfeger, M.D.
INSERT INTO map.EpicPracticeProviders SELECT '5~113265','0~EXT',0,0,0,0,GETDATE() --Provider: SCOTT, BROOK D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1022886','0~EXT',0,0,0,0,GETDATE() --Provider: SELECT, REHAB; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~104812','0~EXT',0,0,0,0,GETDATE() --Provider: SHAH, SANDEEP N; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111705','0~EXT',0,0,0,0,GETDATE() --Provider: SIGLER, SCOTT C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~115319','0~EXT',0,0,0,0,GETDATE() --Provider: SIKKA, SANJAY; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1027996','0~EXT',0,0,0,0,GETDATE() --Provider: SISLER, KATHLEEN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~132776','0~EXT',0,0,0,0,GETDATE() --Provider: SKAGGS, LEAH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110267','0~EXT',0,0,0,0,GETDATE() --Provider: SMALLEY, KENT R; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111420','0~EXT',0,0,0,0,GETDATE() --Provider: SMITH JR, ROGER E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1028744','0~EXT',0,0,0,0,GETDATE() --Provider: SOBEL, ROSE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1014665','0~EXT',0,0,0,0,GETDATE() --Provider: SOM, SUMIT; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110806','0~EXT',0,0,0,0,GETDATE() --Provider: SORENSEN, RAYMOND F; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~126361','0~EXT',0,0,0,0,GETDATE() --Provider: SPYROU, ELIAS; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105067','0~EXT',0,0,0,0,GETDATE() --Provider: SROUJI, NABIL E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1020441','0~EXT',0,0,0,0,GETDATE() --Provider: SSM SAINT ANTHONY OKC; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112619','0~EXT',0,0,0,0,GETDATE() --Provider: STANBRO, PETER B; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1018533','0~EXT',0,0,0,0,GETDATE() --Provider: STEPHENS, MICHAEL C.; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105152','0~EXT',0,0,0,0,GETDATE() --Provider: STOCCO, AMBER; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1033276','0~EXT',0,0,0,0,GETDATE() --Provider: STONE, CHERYL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105160','0~EXT',0,0,0,0,GETDATE() --Provider: STONE, DANA G; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111575','0~EXT',0,0,0,0,GETDATE() --Provider: STUTES, SHAHAN A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1003331','0~EXT',0,0,0,0,GETDATE() --Provider: SULLIVAN, JOHN PATRICK; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112617','0~EXT',0,0,0,0,GETDATE() --Provider: TATUM, HARVEY A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000717','0~EXT',0,0,0,0,GETDATE() --Provider: TEDESCO, DUSTIN SHAWN; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~110624','0~EXT',0,0,0,0,GETDATE() --Provider: THAMBUSWAMY, MICHAEL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1019057','0~EXT',0,0,0,0,GETDATE() --Provider: THERAPY IN MOTION - NE - RECORDS; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1022437','0~EXT',0,0,0,0,GETDATE() --Provider: THERAPY, TAYLOR PHYSICAL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1029791','0~EXT',0,0,0,0,GETDATE() --Provider: THERAPYAND BALANCE CENTERS, FYZICAL; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112251','0~EXT',0,0,0,0,GETDATE() --Provider: TINSLEY, LANE E; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1004772','0~EXT',0,0,0,0,GETDATE() --Provider: TOPLICEANU, ALEXANDRU; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1033307','0~EXT',0,0,0,0,GETDATE() --Provider: TOUCHSTONE IMAGING YUKON, MD; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~136705','0~EXT',0,0,0,0,GETDATE() --Provider: TULLOS, HURTIS J; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1022776','0~EXT',0,0,0,0,GETDATE() --Provider: VALIR PHYSICAL THERAPY, OKC SOUTH; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1032017','0~EXT',0,0,0,0,GETDATE() --Provider: VALIR, MAY AVE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~112958','0~EXT',0,0,0,0,GETDATE() --Provider: VARAHAN, SUBHA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1007529','0~EXT',0,0,0,0,GETDATE() --Provider: VAUGHAN, HANNAH M; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105497','0~EXT',0,0,0,0,GETDATE() --Provider: VAVRICKA, BEVERLY A; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~105524','0~EXT',0,0,0,0,GETDATE() --Provider: VIRK, IMRAN S; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1020978','0~EXT',0,0,0,0,GETDATE() --Provider: WALKER SQUARE, THERAPITAS; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000776','0~EXT',0,0,0,0,GETDATE() --Provider: WEDLAKE, JOHN ROBERT; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1009173','0~EXT',0,0,0,0,GETDATE() --Provider: WHITE, KAITLYN DEANNA; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001813','0~EXT',0,0,0,0,GETDATE() --Provider: WHITE, TRACI LYNNE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111394','0~EXT',0,0,0,0,GETDATE() --Provider: WHORTON, JOSHUA D; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1018243','0~EXT',0,0,0,0,GETDATE() --Provider: WOMENS HEALTH, LAKESIDE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109147','0~EXT',0,0,0,0,GETDATE() --Provider: WOODSON, RONALD; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~111780','0~EXT',0,0,0,0,GETDATE() --Provider: WORKMAN, MARK; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~126869','0~EXT',0,0,0,0,GETDATE() --Provider: YATES, TIMOTHY C; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~109164','0~EXT',0,0,0,0,GETDATE() --Provider: ZUERKER, JOE; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~P1033490','0~EXT',0,0,0,0,GETDATE() --Provider: CENTER, CITRIS DIAGNOSIS; Practice: 
INSERT INTO map.EpicPracticeProviders SELECT '5~144477','0~EXT',0,0,0,0,GETDATE() --Provider: MACALLISTER, MATTHEW C; Practice: 


--Added 10.2.2024 - Chris Cross
INSERT INTO map.EpicPracticeProviders SELECT '5~102916','0~EXT1',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~130510','0~EXT2',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~134108','0~EXT3',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~104561','0~EXT4',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~100628','0~EXT5',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~100636','0~EXT5',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~101364','0~EXT5',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~P1031857','0~EXT5',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~P1020976','0~EXT5',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~114212','0~EXT5',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~109411','0~EXT5',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~104886','0~EXT5',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~133036','0~EXT6',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~123403','0~EXT7',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~103202','0~EXT8',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~127424','0~EXT9',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~105130','0~EXT9',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~100270','0~EXT10',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~P1015253','0~EXT11',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~136394','0~EXT12',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~115463','0~EXT12',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002314','0~EXT12',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~P1011932','0~EXT13',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~100041','0~EXT14',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~100214','0~EXT14',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~127740','0~EXT14',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~102198','0~EXT14',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~130816','0~EXT14',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~102378','0~EXT14',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~103098','0~EXT14',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~104429','0~EXT14',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~104620','0~EXT14',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~104676','0~EXT14',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~128776','0~EXT14',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~131398','0~EXT14',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~123300','0~EXT14',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~108714','0~EXT14',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~104804','0~EXT15',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000235','0~EXT16',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~P1005108','0~EXT17',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~P1013671','0~EXT18',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~P1021347','0~EXT19',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~P1030614','0~EXT20',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~125683','0~EXT21',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~104740','0~EXT22',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~P1016838','0~EXT23',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000130','0~EXT24',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000108','0~EXT25',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~107335','0~EXT26',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~103999','0~EXT27',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~101509','0~EXT28',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~105783','0~EXT29',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~135764','0~EXT30',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000103','0~EXT31',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000375','0~EXT32',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~141151','0~EXT33',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~100618','0~EXT34',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~140864','0~EXT35',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~107850','0~EXT35',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~104072','0~EXT35',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~104088','0~EXT35',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~123018','0~EXT35',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~105432','0~EXT35',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~112985','0~EXT36',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~123120','0~EXT37',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~120908','0~EXT38',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~102924','0~EXT38',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~109389','0~EXT38',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~105894','0~EXT38',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~101875','0~EXT39',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~103514','0~EXT39',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~136241','0~EXT39',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~109394','0~EXT39',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~126670','0~EXT39',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~P1010261','0~EXT40',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~100742','0~EXT40',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~102022','0~EXT40',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~143629','0~EXT40',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~104436','0~EXT40',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~142900','0~EXT41',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~140512','0~EXT41',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~107978','0~EXT41',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~126560','0~EXT41',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~109724','0~EXT41',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~115227','0~EXT42',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~109275','0~EXT42',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~112859','0~EXT42',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~102082','0~EXT43',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~102218','0~EXT43',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~123258','0~EXT43',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~103722','0~EXT43',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~104505','0~EXT43',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~105039','0~EXT43',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~108721','0~EXT43',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~129229','0~EXT44',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~105038','0~EXT45',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~104313','0~EXT45',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~109445','0~EXT46',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~109798','0~EXT47',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~101297','0~EXT48',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~107504','0~EXT48',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~108030','0~EXT48',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~107034','0~EXT49',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~101141','0~EXT49',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~101185','0~EXT49',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~101296','0~EXT49',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~107532','0~EXT49',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~105862','0~EXT49',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~109788','0~EXT49',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~130325','0~EXT50',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~109285','0~EXT50',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~123016','0~EXT50',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~108414','0~EXT50',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~117700','0~EXT51',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~101098','0~EXT52',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~109757','0~EXT52',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~109442','0~EXT52',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~109559','0~EXT53',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~103714','0~EXT53',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~108377','0~EXT53',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000827','0~EXT53',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~124623','0~EXT54',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~107258','0~EXT54',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~101722','0~EXT54',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~102808','0~EXT54',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~114273','0~EXT54',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~108167','0~EXT54',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~108168','0~EXT54',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~129276','0~EXT54',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~P1013911','0~EXT54',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~107092','0~EXT55',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~143509','0~EXT55',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~103765','0~EXT55',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~105687','0~EXT55',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~107707','0~EXT56',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~102521','0~EXT56',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~100290','0~EXT57',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~100584','0~EXT57',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~101729','0~EXT57',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~107802','0~EXT57',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~103149','0~EXT57',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~130927','0~EXT57',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~105247','0~EXT57',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~141209','0~EXT57',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~129233','0~EXT57',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~114383','0~EXT58',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~101783','0~EXT58',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~128359','0~EXT59',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~124396','0~EXT59',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~P1021403','0~EXT59',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~140826','0~EXT60',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~122252','0~EXT60',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~132873','0~EXT60',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~109161','0~EXT60',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~112327','0~EXT61',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~105552','0~EXT62',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~118653','0~EXT63',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~111741','0~EXT64',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000550','0~EXT65',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~107276','0~EXT66',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~P1007612','0~EXT66',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~104875','0~EXT66',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~123698','0~EXT67',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~117336','0~EXT68',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~104100','0~EXT68',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~119923','0~EXT69',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~132363','0~EXT69',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~129826','0~EXT69',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001725','0~EXT69',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~119925','0~EXT69',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~129230','0~EXT69',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~P1009757','0~EXT70',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~135734','0~EXT71',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001909','0~EXT72',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~P1013239','0~EXT72',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008021','0~EXT73',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~127084','0~EXT74',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~138252','0~EXT74',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~120036','0~EXT74',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~133603','0~EXT74',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~132317','0~EXT74',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~132884','0~EXT74',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~107101','0~EXT75',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~122821','0~EXT75',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~102267','0~EXT76',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~135427','0~EXT77',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~140804','0~EXT77',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~103172','0~EXT78',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~101489','0~EXT79',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~139655','0~EXT79',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000864','0~EXT80',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~117998','0~EXT81',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~125763','0~EXT81',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~P1005827','0~EXT82',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000170','0~EXT83',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~P1005020','0~EXT83',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~P1008275','0~EXT83',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~105623','0~EXT84',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~100570','0~EXT85',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~102771','0~EXT85',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~102823','0~EXT85',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~127133','0~EXT86',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002921','0~EXT87',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~112677','0~EXT88',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~143667','0~EXT89',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~103651','0~EXT89',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~114279','0~EXT90',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~P1006419','0~EXT91',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~107093','0~EXT92',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~P1003931','0~EXT93',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~108060','0~EXT94',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~105026','0~EXT95',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~125177','0~EXT96',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~107241','0~EXT97',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~114910','0~EXT98',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~P1015003','0~EXT99',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~104280','0~EXT99',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001814','0~EXT99',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~104109','0~EXT100',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~115002','0~EXT101',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~121675','0~EXT101',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~134088','0~EXT101',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002381','0~EXT101',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~130587','0~EXT101',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~104595','0~EXT101',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~105274','0~EXT101',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~P1007297','0~EXT102',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001821','0~EXT102',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~114955','0~EXT103',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~114491','0~EXT104',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~113521','0~EXT104',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~108729','0~EXT104',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000073','0~EXT105',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~100703','0~EXT106',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~108697','0~EXT106',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~102956','0~EXT106',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~113573','0~EXT107',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~109372','0~EXT108',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000265','0~EXT109',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~104244','0~EXT109',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~113204','0~EXT110',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~115906','0~EXT111',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000806','0~EXT111',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~104006','0~EXT112',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~110824','0~EXT113',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~P1023753','0~EXT113',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~107594','0~EXT113',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~P1007744','0~EXT113',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~112014','0~EXT113',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~P1005756','0~EXT114',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~110713','0~EXT115',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~109145','0~EXT116',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~101439','0~EXT116',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001394','0~EXT116',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~126060','0~EXT116',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~104842','0~EXT116',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~P1030506','0~EXT117',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~P1000368','0~EXT118',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~123017','0~EXT119',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~116244','0~EXT120',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~P1009831','0~EXT121',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~P1028031','0~EXT121',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~P1006883','0~EXT121',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002906','0~EXT122',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~P1031315','0~EXT123',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~P1005166','0~EXT123',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~101260','0~EXT124',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~P1002657','0~EXT125',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~P1013727','0~EXT126',0,0,0,0,GETDATE()

INSERT INTO map.EpicPracticeProviders SELECT '5~103039','0~EXT127',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~P1003144','0~EXT128',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~102391','0~EXT128',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~101082','0~EXT129',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~124194','0~EXT130',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~P1004114','0~EXT130',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~110696','0~EXT131',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~P1018101','0~EXT132',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~107651','0~EXT132',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~P1001854','0~EXT132',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~P1004790','0~EXT133',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~102065','0~EXT133',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~105263','0~EXT133',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~105988','0~EXT134',0,0,0,0,GETDATE()
INSERT INTO map.EpicPracticeProviders SELECT '5~144782','0~SJA',0,0,0,0,GETDATE()


INSERT INTO map.EpicPracticeProviders SELECT '5~107024','0~EXT135',0,0,0,0,GETDATE()


DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~100290' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~100041' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~100214' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~100570' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~100584' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~100742' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~100628' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~100636' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~100270' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~100618' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~101082' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~101098' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~100703' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~101141' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~101185' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~101364' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~101509' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~101439' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~101296' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~101297' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~101260' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~101722' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~101875' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~101783' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~102022' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~102082' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~101729' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~102065' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~102218' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~102267' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~102198' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~102378' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~102391' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~102521' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~102771' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~102808' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~102823' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~102916' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~102924' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~102956' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~103098' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~103202' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~103039' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~103149' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~103172' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~103514' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~103651' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~103714' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~103722' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~103765' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~103999' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~104006' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~104109' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~104072' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~104088' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~104244' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~104313' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~104429' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~104436' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~104100' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~104280' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~104505' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~104620' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~104676' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~104740' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~104804' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~104886' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~105130' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~105026' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~105038' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~105039' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~105263' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~105274' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~105432' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~104561' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~104595' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~104842' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~104875' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~105552' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~105687' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~105783' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~105623' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~105862' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~105894' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~105988' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~107101' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~105247' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~107024' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~107034' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~107276' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~107335' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~107504' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~107532' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~107241' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~107258' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~107594' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~107707' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~107651' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~107802' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~107850' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~107978' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~108030' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~108167' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~108168' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~108414' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~108060' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~108377' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~107092' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~107093' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~108697' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~109161' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~109285' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~108729' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~109145' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~109275' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~109372' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~109389' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~109394' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~109442' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~109445' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~109411' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~109559' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~109798' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~110824' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~108714' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~108721' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~109724' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~109757' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~110713' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~111741' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~112327' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~113573' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~112014' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~112677' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~112985' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~113204' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~112859' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~114212' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~114279' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~109788' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~110696' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~113521' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~114273' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~114383' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~114491' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~115002' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~115227' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~115463' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~114910' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~115906' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~116244' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~117336' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~118653' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~117998' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~117700' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~114955' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~119923' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~119925' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~120908' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~120036' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~121675' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~122252' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~123403' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~123016' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~123017' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~123018' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~123120' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~123258' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~123300' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~124194' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~124396' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~125177' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~125763' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~126060' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~126670' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~127133' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~125683' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~126560' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~127424' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~127740' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~128359' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~128776' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~127084' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~129229' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~129230' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~129276' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~129826' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~129233' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~130325' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~130510' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~130587' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~130816' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~130927' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~131398' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~132363' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~132873' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~132884' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~133036' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~133603' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~132317' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~134088' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~134108' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~136394' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~135734' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~135764' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~135427' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~140512' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~141151' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~141209' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~136241' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~140804' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~140864' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~142900' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~143629' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~143667' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~P1000073' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~140826' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~P1000103' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~P1000108' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~P1000368' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~P1000375' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~P1000550' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~P1000130' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~P1000170' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~P1000265' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~P1000235' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~P1000827' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~P1000864' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~P1001394' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~P1001725' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~P1001814' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~P1001821' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~P1001854' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~P1001909' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~P1002381' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~P1003144' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~P1004114' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~P1002657' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~P1002906' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~P1002921' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~P1003931' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~P1004790' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~P1005166' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~P1002314' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~P1005020' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~P1000806' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~P1005108' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~P1005756' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~P1005827' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~P1006419' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~P1006883' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~P1007297' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~P1007744' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~P1008021' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~P1008275' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~P1010261' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~P1007612' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~P1009757' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~P1009831' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~P1011932' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~P1013911' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~P1013239' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~P1013727' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~P1015003' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~P1016838' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~P1018101' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~P1023753' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~P1021403' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~P1028031' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~P1015253' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~P1020976' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~P1013671' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~P1021347' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~P1030614' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~P1031857' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~P1031315' and PracticeID = '0~EXT'
DELETE FROM map.EpicPracticeProviders WHERE ProviderID = '5~P1030506' and PracticeID = '0~EXT'



*/
--select 
--ProviderID
--,count(1) ct
--from map.EpicPracticeProviders
--group by ProviderID
--order by ct desc

/*--OLD Dynamic Logic replaced by manual mapping*/
/*
INSERT INTO map.EpicPracticeProviders
(
	ProviderID 
	,PracticeID 
	,EpicPracticeProviderUpdatedDatetime 
)


	select
		p.ProviderID
		--,p.ProviderFullName
		,d.PracticeID
		--,pt.PracticeName
		--,d.DepartmentID
		--,d.DepartmentName
		--,count(1) as ChargeCount
		--,max(t2.TransactionDateOfPosting) as LastPostDate
		,getdate() as EpicPracticeProviderUpdatedDatetime
	from fact.Transactions2 t2
		left join dim.vDepartments d ON d.DepartmentID = t2.TransactionDepartmentID
		left join dim.vPractices pt ON pt.PracticeID = d.PracticeID
		left join dim.vProviders p ON p.ProviderID = t2.TransactionBillingProviderID
	where 1=1
		and t2.TransactionBillingType = 'PB'
		and t2.TransactionType = 'Charge'
		and t2.TransactionDateOfVoid is null
		and t2.TransactionDatasourceID = 5 /*Epic*/
		and pt.PracticeID is not null
		and t2.TransactionBillingProviderID <> '5~125582' /*Exc Murphi Scarborough because she works at 2 practices.  Handled in vEpicReferrals logic*/
		and NOT(t2.TransactionBillingProviderID = '5~119683' and pt.PracticeID = '0~MSO') /*Exc Odor showing up in MSO due to xray issue*/
	group by 
		d.PracticeID
		,pt.PracticeName
		--,d.DepartmentID
		--,d.DepartmentName
		,p.ProviderID
		,p.ProviderFullName
	having count(1) > 15
	--order by 
	--	d.PracticeID
	--	,pt.PracticeName

	UNION ALL

	SELECT '5~P1000829','0~LCS',GETDATE()
	UNION ALL
	SELECT '5~110422','0~DDR',GETDATE()

	UNION ALL
	SELECT '5~P1001334','0~RSU',GETDATE()
	UNION ALL
	SELECT '5~P1000090','0~TAK',GETDATE()
	UNION ALL
	SELECT '5~107898','0~DDR',GETDATE()
	*/



	--select * from dim.vPractices where PracticeName like 'Lance%'
	--SELECT * FROM DIM.VPROVIDERS P WHERE P.ProviderFullName LIKE '%lEINEN, J%'
GO
