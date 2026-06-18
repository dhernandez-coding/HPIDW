CREATE PROCEDURE [stg].spReloadMedhostChargeDesc
AS
BEGIN
SET NOCOUNT ON;

-- 1.5 minute exec
-- 2 minute exec


 --create table fact.MedhostChargeDesc (

	--	ChargeCode int
	--	,Price decimal(18,2)
	--	,RevCode1 int
	--	,RevCode2 int
	--	,RevCode3 int
	--	,EffectiveDate date
	--	,TerminationDate date
	--	,ChangeDate date
	--	,ChangedBy varchar(50)
	--	,Facility int
	--	,IsActive bit
 --	)

begin tran
    begin try

        truncate table fact.MedhostChargeDesc

        -- ar info, arrival and departure dates, docnums, insurance plan info
        -- last 3 years ytd including this year
        insert into fact.MedhostChargeDesc


  select
	*
	,case
		when TerminationDate = '9999-12-31' then 1
		else 0
	end as IsActive
	from openquery(hmsls, 
  '
	select
		svccd ChargeCode
		,price1 Price
		,inscd4 RevCode1
		,inscd24 RevCode2
		,inscd34 RevCode3
		,cdmeffdt EffectiveDate
		,cdmterdt TerminationDate
		,cdmchgdt ChangeDate
		,cdmchgby ChangedBy
		,110 Facility
		
	from mhd32.HOSPF110.CHGDHST
	-- where CDMTERDT = ''9999-12-31''
	-- order by cmpsdat desc
	-- fetch first 100 rows only

	union all

	select
		svccd ChargeCode
		,price1 Price
		,inscd4 RevCode1
		,inscd24 RevCode2
		,inscd34 RevCode3
		,cdmeffdt EffectiveDate
		,cdmterdt TerminationDate
		,cdmchgdt ChangeDate
		,cdmchgby ChangedBy
		,100 Facility
	from mhd32.HOSPF100.CHGDHST
	-- order by cmpsdat desc
	-- fetch first 100 rows only
  ')

        commit transaction
    end try

    begin catch
        rollback transaction
    end catch

end
GO
