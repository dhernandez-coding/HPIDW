-- =============================================
-- Author:		Ryan Tisserand
-- Create date: 03/15/2023
-- Description:	Extracts, Transforms and Loads Procedure Code Data from Medhost Community Hospital Source System into a dim Table
-- Change Control
--	1. 03/15/2023 - Ryan Tisserand - Initial build of procedure
-- =============================================
CREATE PROCEDURE stg.spMedhostCHReloadDimProcedureCodesFull
AS
BEGIN
SET NOCOUNT ON;

delete from dim.ProcedureCodes where ProcedureCodeDataSourceID = 8

insert into dim.ProcedureCodes
(
	ProcedureCodeID,
	ProcedureCodeDataSourceID,
	ProcedureCodeSourceID,
	ProcedureCode,
	ProcedureCodeInsuranceDescription,
	ProcedureCodeStatementDescription,
	ProcedureCodeType,
	ProcedureCodeCategoryID,
	ProcedureCodeCategoryAbbreviation,
	ProcedureCodeCategoryDescription,
	ProcedureCodeSelfPay,
	ProcedureCodeEnableSplitBilling,
	ProcedureCodeInfusion,
	ProcedureCodeIsActive,
	ProcedureCodeUpdatedDateTime
)

select
	'8~' + p.PRCODE_ ProcedureCodeID,
	8 ProcedureCodeDataSourceID,
	p.PRCODE_ ProcedureCodeSourceID,
	p.PRCODE_ ProcedureCode,
	p.PRDESC_ ProcedureCodeInsuranceDescription,
	p.PRDSCSHRT_ ProcedureCodeStatementDescription,
	'' ProcedureCodeType,
	'' ProcedureCodeCategoryID,
	'' ProcedureCodeCategoryAbbreviation,
	'' ProcedureCodeCategoryDescription,
	'' ProcedureCodeSelfPay,
	'' ProcedureCodeEnableSplitBilling,
	'' ProcedureCodeInfusion,
	1 ProcedureCodeIsActive,
	getdate() ProcedureCodeUpdatedDateTime
from openquery
([HMSLS],
'
	select
		PRCODE_,
		PRDESC_,
		PRDSCSHRT_
	from HOSPF110.I10PROC
'
)p
END
GO
