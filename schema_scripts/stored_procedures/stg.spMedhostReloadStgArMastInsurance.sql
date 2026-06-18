-- =============================================
-- Author:		Jacob Roan
-- Create date: 02/07/2023
-- Description:	Extracts and Loads AR Data from Medhost Source System into a stg Table
-- Change Control
--	1. 02/07/2023 - Jacob Roan - Initial build of procedure
--  2. 02/07/2023 - Jacob Roan - Added Insurance Plan info (~3.5 min exec time)
--  3. 02/14/2023 - Jacob Roan - Added catch try/catch (3 min exec time)
-- =============================================
CREATE PROCEDURE [stg].[spMedhostReloadStgArMastInsurance]
AS
BEGIN
SET NOCOUNT ON;


--create table stg.MedhostArMastInsurance (

--	recid varchar(50)
--	,patno int
--	,hstnum int
--	,garnum int
--	,pnam20 varchar(20)
--	,gnam20 varchar(20)
--	,curbl decimal(18,2)
--	,todfc decimal(18,2)
--	,blstm decimal(18,2)
--	,orgbl decimal(18,2)
--	,nostm int
--	,dtlst int
--	,dtfbl int
--	,nopmt int
--	,amtlp decimal(18,2)
--	,trsrc varchar(50)
--	,arfc1 varchar(1)
--	,arfc2 varchar(1)
--	,arfc3 varchar(1)
--	,ptype varchar(1)
--	,lstdt int
--	,notrn int
--	,ins1 int
--	,ins2 int
--	,ins3 int
--	,ipl1 int
--	,ipl2 int
--	,ipl3 int
--	,[time] varchar(50)
--	,hssvc varchar(15)
--	,dtltr int
--	,rebd varchar(50)
--	,price int
--	,ubcode int
--	,isadate1 date
--	,isddate1 date
--	,isdtlst date
--	,isdtfbl date
--	,islstdt date
--	,isdtltr date
--	,nwdocnum int
--	,nwrefdoc int
--	,iprecid varchar(50)
--	,insco int
--	,icname varchar(50)
--	,inspl int
--	,instyp varchar(50)
--	,insnme varchar(50)
--	,mail1 varchar(50)
--	,mail2 varchar(50)
--	,ipcity varchar(50)
--	,ipst varchar(50)
--	,ipzip varchar(15)
--  ,HosptialAbrev varchar(50)
--	)

begin tran
    begin try

        truncate table stg.MedhostArMastInsurance

        -- ar info, arrival and departure dates, docnums, insurance plan info
        -- last 3 years ytd including this year
        insert into stg.MedhostArMastInsurance
        select
            *
        from openquery(HMSLS, 
            'select
                ar.recid
                ,ar.patno
                ,ar.hstnum
                ,ar.garnum
                ,ar.pnam20
                ,ar.gnam20
                ,ar.curbl
                ,ar.todfc
                ,ar.blstm
                ,ar.orgbl
                ,ar.nostm
                ,ar.dtlst
                ,ar.dtfbl
                ,ar.nopmt
                ,ar.amtlp
                ,ar.trsrc
                ,ar.arfc1
                ,ar.arfc2
                ,ar.arfc3
                ,ar.ptype
                ,ar.lstdt
                ,ar.notrn
                ,ar.ins1
                ,ar.ins2
                ,ar.ins3
                ,ar.ipl1
                ,ar.ipl2
                ,ar.ipl3
                ,ar.time
                ,ar.hssvc
                ,ar.dtltr
                ,ar.rebd
                ,ar.price
                ,ar.ubcode
                ,ar.isadate1
                ,ar.isddate1
                ,ar.isdtlst
                ,ar.isdtfbl
                ,ar.islstdt
                ,ar.isdtltr
                ,ar.nwdocnum
                ,ar.nwrefdoc
                ,ip.recid as iprecid
                ,ip.insco
                ,im.icname
                ,ip.inspl
                ,ip.instyp
                ,ip.insnme
                ,ip.mail1
                ,ip.mail2
                ,ip.ipcity
                ,ip.ipst
                ,ip.ipzip
				,''Comm'' as HosptialAbrev
            FROM MHD32.HOSPF110.armast ar
            left JOIN MHD32.HOSPF110.insplan ip on ar.ins1 = ip.insco and ar.ipl1 = ip.inspl
            left JOIN MHD32.HOSPF110.insmast im on ip.insco = im.insco
            where year(isadate1) >= year(current date) - 2'
        )

		union all

        select
            *
        from openquery(HMSLS, 
            'select
                ar.recid
                ,ar.patno
                ,ar.hstnum
                ,ar.garnum
                ,ar.pnam20
                ,ar.gnam20
                ,ar.curbl
                ,ar.todfc
                ,ar.blstm
                ,ar.orgbl
                ,ar.nostm
                ,ar.dtlst
                ,ar.dtfbl
                ,ar.nopmt
                ,ar.amtlp
                ,ar.trsrc
                ,ar.arfc1
                ,ar.arfc2
                ,ar.arfc3
                ,ar.ptype
                ,ar.lstdt
                ,ar.notrn
                ,ar.ins1
                ,ar.ins2
                ,ar.ins3
                ,ar.ipl1
                ,ar.ipl2
                ,ar.ipl3
                ,ar.time
                ,ar.hssvc
                ,ar.dtltr
                ,ar.rebd
                ,ar.price
                ,ar.ubcode
                ,ar.isadate1
                ,ar.isddate1
                ,ar.isdtlst
                ,ar.isdtfbl
                ,ar.islstdt
                ,ar.isdtltr
                ,ar.nwdocnum
                ,ar.nwrefdoc
                ,ip.recid as iprecid
                ,ip.insco
                ,im.icname
                ,ip.inspl
                ,ip.instyp
                ,ip.insnme
                ,ip.mail1
                ,ip.mail2
                ,ip.ipcity
                ,ip.ipst
                ,ip.ipzip
				,''NWS'' as HosptialAbrev
            FROM MHD32.HOSPF100.armast ar
            left JOIN MHD32.HOSPF100.insplan ip on ar.ins1 = ip.insco and ar.ipl1 = ip.inspl
            left JOIN MHD32.HOSPF100.insmast im on ip.insco = im.insco
            where year(isadate1) >= year(current date) - 2'
        )

        commit transaction
    end try

    begin catch
        rollback transaction
    end catch

end
GO
