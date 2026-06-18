-- =============================================
-- Author:		Eric Silvestri
-- Create date: 07/25/2023
-- Description:	Extracts, Transforms and Loads Payer Category Data from APM Source System into a dim Table
-- Change Control
-- =============================================

CREATE   PROCEDURE [stg].[spAPMCustomerReloadDimPayerCategoriesFull]
AS
BEGIN
SET NOCOUNT Off;

delete from dim.PayerCategories where PayerCategoryDataSourceID = 12

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
	'12' + '~' + cast(ic.Insurance_Category_ID as varchar(50)) PayerCategoryID,
	12 as PayerCategoryDataSourceID,
	ic.Insurance_Category_ID PayerCategorySourceID,
	ic.[Description] PayerCategoryName,
	1 as PayerCategoryIsActive,
	getdate() PayerCategoryUpdatedDatetime
from [TIEVMDB03].Ntier_HPI_Customers.[PM].Insurance_Categories ic
group by
	ic.Insurance_Category_ID
	,ic.[Description]
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
