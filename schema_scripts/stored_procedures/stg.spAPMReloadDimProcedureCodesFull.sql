-- =============================================
-- Author:		Ryan Tisserand
-- Create date: 12/28/2022
-- Description:	Extracts, Transforms and Loads Procedure Code Data from APM Source System into a dim Table
-- Change Control
--	1. 11/23/2022 - Ryan Tisserand - Initial build of procedure
--  2. 03/10/2023 - Ryan Tisserand - Added delete statement to replace truncate job step
-- =============================================
CREATE PROCEDURE [stg].[spAPMReloadDimProcedureCodesFull]
AS
BEGIN
SET NOCOUNT ON;

delete from dim.ProcedureCodes where ProcedureCodeDataSourceID = 1

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
	ProcedureCodeInfusion
)
select
	'1~' + cast(pc.Procedure_Code_ID as varchar(50)) ProcedureCodeID,
	'1' DataSourceID,
	pc.Procedure_Code_ID SourceProcedureCodeID,
	pc.Procedure_Code ProcedureCode,
	pc.Insurance_Description ProcedureCodeInsuranceDescription,
	pc.Statement_Description ProcedureCodeStatementDescription,
	pc.Procedure_Type ProcedureCodeType,
	pc.Procedure_Category_ID ProcedureCodeCategoryID,
	c.Abbreviation ProcedureCodeCategoryAbbreviation,
	c.[Description] ProcdureCodeCategoryDescription,
	pc.SelfPay_Procedure ProcedureCodeSelfPay,
	pc.Enable_Split_Billing ProcedureCodeEnableSplitBilling,
	case when i.InfusionCodeProcedureCode is null then 0 else 1 end ProcedureCodeInfusion
from tievmdb03.Ntier_627200.PM.Procedure_Codes pc
left join tievmdb03.Ntier_627200.PM.Procedure_Categories c on pc.Procedure_Category_ID = c.Procedure_Category_ID
left join map.InfusionCodes i on pc.Procedure_Code = i.InfusionCodeProcedureCode and i.DataSourceID = 1
END
GO
