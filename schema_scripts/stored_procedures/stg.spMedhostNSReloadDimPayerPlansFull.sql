-- =============================================
-- Author:		Chris Cross
-- Create date: 03/14/2023
-- Description:	Extracts, Transforms and Loads Payer Plan Data from MEDHOST Source System into a dim Table
-- Change Control
--	1. 03/14/2023 - Chris Cross - Initial build of procedure
-- =============================================
CREATE PROCEDURE [stg].[spMedhostNSReloadDimPayerPlansFull]
AS
BEGIN
SET NOCOUNT ON;

-- HOSP: NS, SERVER: HOSPF100, SOURCEID: 2

 DELETE FROM dim.PayerPlans WHERE PayerPlanDataSourceID = 2

insert into dim.PayerPlans
(
	[PayerPlanID]
      ,[PayerPlanDataSourceID]
      ,[PayerPlanSourceID]
      ,[PayerID]
      ,[PayerPlanName]
	  ,[PayerPlanContractNumber]
      ,[PayerPlanIsActive]
      ,[PayerPlanUpdatedDatetime]
)

select 
	CONCAT('2~', convert(varchar(100),p.INSCO), '~', convert(varchar(100),p.INSPL)) AS  PayerPlanID,
	2 as PayerPlanDataSourceID,
	CONCAT(convert(varchar(100),p.INSCO), '~', convert(varchar(100),p.INSPL)) as PayerPlanSourceID,
	CONCAT('2~',p.INSCO) as PayerID,
	p.[INSNME] as PayerPlanName,
	p.INSCNTR as PayerPlanContractNumber,
	1 as PayerPlanIsActive,
	GETDATE() PayerPlanUpdateDateTime 
--select * 
 FROM OPENQUERY([hmsls],'
	select
	ip.*
	from MHD32.HOSPF100.INSPLAN ip 
	where 1=1
	') p
END
GO
