-- =============================================
-- Author:		Chris Cross
-- Create date: 03/14/2023
-- Description:	Extracts, Transforms and Loads Provider Data from Medhost Community Hospital Source System into a dim Table
-- Change Control
--	1. 03/14/2023 - Chris Cross - Initial build of procedure
-- =============================================
CREATE PROCEDURE [stg].[spMedhostCHReloadDimFinancialClassesFull]
AS
BEGIN
SET NOCOUNT ON;

delete from dim.FinancialClasses where FinancialClassDataSourceID = 8

insert into dim.FinancialClasses
(
	[FinancialClassID]
      ,[FinancialClassDataSourceID]
      ,[FinancialClassSourceID]
      ,[FinancialClassName]
      ,[FinancialClassIsActive]
      ,[FinancialClassUpdatedDatetime]
)


--select * from openquery([hmsls],'select FNWCLS, MAX(FCLSN) AS FinancialClass from MHD32.EISF110.EISCLSL1 GROUP BY FNWCLS ')

	select 
		CONCAT('8~',FNWCLS) as FinancialClassID
		,8 as FinancialClassDataSourceID
		,FNWCLS as FinancialClassSourceID
		,FinancialClass
		,1 as FinancialClassIsActive
		,GETDATE() as FinancialClassUpdatedDatetime
		--, count(1), max(icname), min(icname) 
	 from openquery([hmsls],'select FNWCLS, MAX(FCLSN) AS FinancialClass from MHD32.EISF110.EISCLSL1 GROUP BY FNWCLS ') as F


END
GO
