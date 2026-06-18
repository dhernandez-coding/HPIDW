-- =============================================
-- Author:		Jacob Roan
-- Create date: 07/25/2023
-- Description:	Extracts, Transforms and Loads Payer Data from APM Source System into a dim Table
-- Change Control
--	1. 07/25/2023 - Jacob Roan - Initial build of procedure
-- =============================================

CREATE PROCEDURE [stg].[spAPMReloadDimPayerPlansFull]
AS
BEGIN
SET NOCOUNT ON;

delete from dim.PayerPlans where PayerPlanDataSourceID = 1



insert into dim.PayerPlans
(
	PayerPlanID,
	PayerPlanDataSourceID,
	PayerPlanSourceID,
	PayerID,
	PayerPlanName,
	PayerPlanContractNumber,
	PayerPlanIsActive,
	PayerPlanUpdatedDateTime
)

select 
	'1~SELF' as PayerPlanID
	,1 as PayerPlanDataSourceID
	,'SELF' as PayerPlanSourceID
	,'1~SELF' as PayerID
	,'Self-Pay' as PayerPlanName
	,NULL as PayerPlanContractNumber
	,1 as PayerPlanIsActive
	,getdate() PayerPlanUpdatedDateTime

UNION ALL

select 
	'1' + '~' + cast(p.Carrier_ID as varchar(50)) PayerPlanID,
	1 PayerPlanDataSourceID,
	convert(varchar(50),p.Carrier_ID) PayerPlanSourceID,
	'1' + '~' + cast(p.Carrier_ID as varchar(50)) PayerID,
	p.[Name] PayerPlanName,
	null PayerPlanContractNumber,
	1 PayerIsActive,
	getdate() PayerUpdatedDateTime

from tievmdb03.Ntier_627200.PM.Carriers p

--select * from tievmdb03.Ntier_627200.PM.Carriers p where p.Name like '%BCBS%'
--select * from tievmdb03.Ntier_627200.PM.Insurance_Plans p where description not like '%$%'
--select * from tievmdb03.Ntier_627200.PM.Insurance_Categories p where --p.Name like '%Blue%'
--select * from tievmdb03.Ntier_627200.PM.Insurance_Groups p
--select * from tievmdb03.Ntier_627200.PM.Insurance_Reporting_Classes p

--select * from tievmdb03.Ntier_627200.PM.Ins_Group_Membership p
--left join tievmdb03.Ntier_627200.PM.Insurance_Categories i on p.Insurance_Category_ID = i.Insurance_Category_ID
--left join map.PayerCategories c on i.[Description] = c.PayerSubCategory
END
GO
