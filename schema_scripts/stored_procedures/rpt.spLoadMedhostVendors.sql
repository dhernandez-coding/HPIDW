-- =============================================
-- Author:		Eric Silvestri
-- Create date: 08/21/2024
-- Description:	Loads table rpt.MedhostVendors
-- Change Control
--
-- =============================================
CREATE PROCEDURE [rpt].[spLoadMedhostVendors]
AS
BEGIN
SET NOCOUNT ON;


insert into rpt.MedhostVendors
(
	 VendorLocation
	 ,VendorNumber
	 ,VendorName
	 ,VendorAreaCode
	 ,VendorPhoneNumber
	 ,VendorYTDPurchases
)
SELECT 
	c.avhosp as VendorLocation
	,c.avvend as VendorNumber
	,c.avname as VendorName
	,c.avarcd as VendorAreaCode
	,c.avphon as VendorPhoneNumber
	,c.avypur as VendorYTDPurchases
 FROM OPENQUERY([mhd32.hpillc.org (HOSPF010)],'
SELECT
	v.avhosp
	,v.avvend
	,v.avname
	,v.avarcd
	,v.avphon
	,v.avypur --COLHDG("YTD" "Purchases")
FROM MHD32.HOSPF010.VENDMAST v
	') c

END
GO
