-- =============================================
-- Author:		Jacob Roan
-- Create date: 02/07/2023
-- Description:	Extracts and Loads AR Data from Medhost Source System into a stg Table
-- Change Control
--	1. 02/15/2023 - Jacob Roan - Initial build of procedure (6 min exec)
--	2. 02/15/2023 - Jacob Roan - unioned community and nw hospital (6 min exec)
-- =============================================
CREATE PROCEDURE [stg].[spMedhostReloadFactTransactions]
AS
BEGIN
SET NOCOUNT ON;


-- create table fact.MedhostTransactions (

-- 	recid varchar(50)
-- 	,patno int
-- 	,seqnum int
-- 	,cycle int
-- 	,trdate varchar(20)
-- 	,tcode int
-- 	,tamt decimal(18,2)
-- 	,glnum int
-- 	,ptype varchar(20)
-- 	,fincl varchar(20)
    -- ,optdsc varchar(50)
    -- ,isotrdate DATE
    -- ,isodate date
    -- ,isomtendd date
--,HospitalAbrev varchar(50)
-- 	)

begin tran
    begin try

        truncate table fact.MedhostTransactions

        -- ar info, arrival and departure dates, docnums, insurance plan info
        -- last 3 years ytd including this year
        insert into fact.MedhostTransactions -- 588657 from comm
        select
            *
        from openquery(HMSLS, 
            'select
                recid
                ,patno
                ,seqnum
                ,cycle
                ,trdate
                ,tcode
                ,tamt
                ,glnum
                ,ptype
                ,fincl
                ,optdsc
                ,isotrdate
                ,isoodate
                ,isomtendd
				,''Comm'' as HospitalAbrev
            FROM MHD32.HOSPF110.araccum
            where year(isotrdate) >= year(current date) - 2'
        )

		union all

        select
            *
        from openquery(HMSLS, 
            'select
                recid
                ,patno
                ,seqnum
                ,cycle
                ,trdate
                ,tcode
                ,tamt
                ,glnum
                ,ptype
                ,fincl
                ,optdsc
                ,isotrdate
                ,isoodate
                ,isomtendd
				,''NWS'' as HospitalAbrev
            FROM MHD32.HOSPF100.araccum
            where year(isotrdate) >= year(current date) - 2'
        )

        commit transaction
    end try

    begin catch
        rollback transaction
    end catch

end
GO
