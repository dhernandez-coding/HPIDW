-- =============================================
-- Author:		Jacob Roan
-- Create date: 03/08/2023
-- Description:	Extracts, Transforms and Loads Payer Data from MEDHOST Source System into a dim Table
-- Change Control
--	1. 03/14/2023 - Chris Cross - Initial build of procedure
-- =============================================
CREATE PROCEDURE [stg].[spMedhostCHReloadDimPayersFull]
AS
BEGIN
SET NOCOUNT ON;

-- HOSP: NS, SERVER: HOSPF100, SOURCEID: 8

 DELETE FROM dim.Payers WHERE PayerDataSourceID = 8

insert into dim.Payers
(
	PayerID,
	PayerDataSourceID,
	PayerSourceID,
	PayerGroupID,
	PayerCategoryID,
	PayerName,
	PayerAbbreviation,
	PayerStreetAddress1,
	PayerStreetAddress2,
	PayerCity,
	PayerState,
	PayerZipCode,
	PayerIsActive,
	PayerUpdatedDateTime
)

select 
	CONCAT('8~', cast(p.INSCO as varchar(50))) AS  PayerID,
	8 as PayerDataSourceID,
	p.INSCO as PayerSourceID,
	NULL as PayerGroupID,
	CASE WHEN p.INSCO = '999' THEN '8~SP' ELSE CONCAT('8~',p.ITYPE) END as PayerCategoryID,
	p.[ICNAME] as PayerName,
	p.[ICNAME] as PayerAbbreviation,
	null as PayerStreetAddress1,
	null as PayerStreetAddress2,
	null as PayerCity,
	null as PayerState,
	null as PayerZipCode,
	1 as PayerIsActive,
	GETDATE() PayerUpdateDateTime

 FROM OPENQUERY([hmsls],'
	select
	i.*
	from MHD32.HOSPF110.INSMAST i
		--left join MHD32.HOSPF110.INSPLAN ip ON i.insco = ip.insco
	where 1=1

	') p
END
GO
