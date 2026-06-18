-- =============================================
-- Author:		Chris Cross
-- Create date: 03/14/2023
-- Description:	Extracts, Transforms and Loads Provider Data from Medhost Community Hospital Source System into a dim Table
-- Change Control
--	1. 03/14/2023 - Chris Cross - Initial build of procedure
-- =============================================
CREATE PROCEDURE [stg].[spMedhostCHReloadDimPayerCategoriesFull]
AS
BEGIN
SET NOCOUNT ON;

delete from dim.PayerCategories where PayerCategoryDataSourceID = 8

insert into dim.PayerCategories
(
	[PayerCategoryID]
      ,[PayerCategoryDataSourceID]
      ,[PayerCategorySourceID]
      ,[PayerCategoryName]
      ,[PayerCategoryIsActive]
      ,[PayerCategoryUpdatedDatetime]
)
	/*Create a manual record for Self-Pay*/
	select
		CONCAT('8~','SP') AS PayerCategoryID
		,8 as PayerCategoryDatasourceID
		,'SP' as PayerCategorySourceID
		,'Self-Pay' as PayerCategoryName
		,1 as PayerCategoryIsActive
		,GETDATE() as PayerCategorUpdateDatetime

	UNION ALL

	select 
		CONCAT('8~',ITYPE) as PayerCategoryID
		,8 as PayerCategoryDataSourceID
		,ITYPE as PayerCategorySourceID
		,/*Manually mapped to Payer Category due to not finding a reliable description in Medhost*/
		 CASE WHEN p.ITYPE = 'C' THEN 'Commercial'
			  WHEN p.ITYPE = 'M' THEN 'Medicare'
			  WHEN p.ITYPE = 'B' THEN 'BCBS'
			  WHEN p.ITYPE = 'W' THEN 'Medicaid'
			  WHEN p.ITYPE = 'H' THEN 'Tricare'
			  WHEN p.ITYPE = 'O' THEN 'Workers Comp'
			  ELSE 'Other' END as PayerCategoryName
		,1 as PayerCategoryIsActive
		,GETDATE() as PayerCategoryUpdatedDatetime
		--, count(1), max(icname), min(icname) 
	FROM OPENQUERY([hmsls],'
	select 
	i.*
	from MHD32.HOSPF110.INSMAST i
	where 1=1

	') p
	group by ITYPE

END
GO
