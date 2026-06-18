-- =============================================
-- Author:		Jacob Roan
-- Create date: 07/25/2023
-- Description:	Extracts, Transforms and Loads Payer Category Data from APM Source System into a dim Table
-- Change Control
--	1. 07/25/2023 - Jacob Roan - Initial build of procedure
-- =============================================
CREATE   PROCEDURE [stg].[spAPMReloadDimPayerCategoriesFull]
AS
BEGIN
SET NOCOUNT ON;

delete from dim.PayerCategories where PayerCategoryDataSourceID = 1

insert into dim.PayerCategories
(
	PayerCategoryID
	,PayerCategoryDataSourceID
	,PayerCategorySourceID
	,PayerCategoryName
	,PayerCategoryIsActive
	,PayerCategoryUpdatedDatetime
)
select 
	'1' + '~' + cast(ic.Insurance_Category_ID as varchar(50)) PayerCategoryID,
	1 PayerCategoryDataSourceID,
	ic.Insurance_Category_ID PayerCategorySourceID,
	ic.[Description] PayerCategoryName,
	1 PayerCategoryIsActive,
	getdate() PayerCategoryUpdatedDatetime
from tievmdb03.Ntier_627200.PM.Insurance_Categories ic

--select * from tievmdb03.Ntier_627200.PM.Carriers p where p.Name like '%Blue%'
----select * from tievmdb03.Ntier_627200.PM.Insurance_Plans p where p.Name like '%Blue%'
--select * from tievmdb03.Ntier_627200.PM.Insurance_Categories p where p.Name like '%Blue%'
--select * from tievmdb03.Ntier_627200.PM.Insurance_Groups p
--select * from tievmdb03.Ntier_627200.PM.Insurance_Reporting_Classes p

--select * from tievmdb03.Ntier_627200.PM.Ins_Group_Membership p
--left join tievmdb03.Ntier_627200.PM.Insurance_Categories i on p.Insurance_Category_ID = i.Insurance_Category_ID
--left join map.PayerCategories c on i.Description = c.PayerSubCategory
END
GO
