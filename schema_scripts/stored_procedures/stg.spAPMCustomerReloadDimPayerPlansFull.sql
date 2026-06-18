-- =============================================
-- Author:		Jacob Roan
-- Create date: 07/25/2023
-- Description:	Extracts, Transforms and Loads Payer Data from APM Source System into a dim Table
-- Change Control
--	1. 07/25/2023 - Jacob Roan - Initial build of procedure
-- =============================================

CREATE PROCEDURE [stg].[spAPMCustomerReloadDimPayerPlansFull]
AS
BEGIN
SET NOCOUNT OFF;

delete from dim.PayerPlans where PayerPlanDataSourceID = 12


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
	'12~SELF' as PayerPlanID
	,12 as PayerPlanDataSourceID
	,'SELF' as PayerPlanSourceID
	,'12~SELF' as PayerID
	,'Self-Pay' as PayerPlanName
	,NULL as PayerPlanContractNumber
	,1 as PayerPlanIsActive
	,getdate() PayerPlanUpdatedDateTime

UNION ALL

select 
	'12' + '~' + cast(p.Carrier_ID as varchar(50)) PayerPlanID,
	12 as PayerPlanDataSourceID,
	convert(varchar(50),p.Carrier_ID) PayerPlanSourceID,
	'12' + '~' + cast(p.Carrier_ID as varchar(50)) PayerID,
	p.[Name] PayerPlanName,
	null PayerPlanContractNumber,
	1 PayerIsActive,
	getdate() PayerUpdatedDateTime

from [TIEVMDB03].Ntier_HPI_Customers.[PM].Carriers p
where 1=1
	--and p.Carrier_id = '1210'

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
