-- =============================================
-- Author:		Eric Silvestri
-- Create date: 08/21/2024
-- Description:	Loads table rpt.MedhostAP
-- Change Control
-- 10/9/2024 - Eric Silvestri added logic to the join to correct the GL number getting matched to the correct check number
	-- Also added join to vendors to bring the vendor names
	-- added APVendorName and APInvoicePostDate
-- =============================================
CREATE PROCEDURE [rpt].[spLoadMedhostAP]
AS
BEGIN
SET NOCOUNT ON;



insert into rpt.MedhostAP
(
	APLocation
	,APVendorNumber
	,APVendorName
	,APInvoiceNumber
	,APInvoicePostDate
	,APBankCode
	,APCheckNumber
	,APCheckDate
	,APCheckDateOfPosting
	,APGrossAmount
	,APInvoiceAmount
	,APPONumber
	,APGLNumber
)
SELECT 
	c.ppposthosp as APLocationName
	,c.ppvend as APVendorNumber
	,c.avname as APVendorName
	,c.ppinv as APInvoiceNumber	
	,c.appostdate as APInvoicePostDate
	,c.ppbkcd as APBankCode
	,c.ppckno as APCheckNumber
	,c.ispppddt as APCheckDate
	,c.isppckpt as APCheckDateOfPosting
	,c.ppgros  as APGrossAmount
	,c.apdamtinv as APInvoiceAmount
	,c.apdponm as APPONumber
	,c.APDGLNM as APGLNumber
 FROM OPENQUERY([mhd32.hpillc.org (HOSPF010)],'
	SELECT
		app.ppposthosp
	    ,app.ppvend
		,v.avname
	    ,app.ppinv
		,apd.appostdate
	    ,app.ppbkcd 
	    ,app.ppckno
	    ,app.ispppddt
	    ,app.isppckpt
	    ,app.ppgros
		,apd.apdamtinv
	    ,apd.apdponm
		,apd.APDGLNM
	FROM MHD32.HOSPF010.APPYMNTS app
		LEFT JOIN MHD32.HOSPF010.APDETAIL apd on apd.APDINV = app.PPINV 
											and apd.APDHOSP = app.PPHOSP
											and apd.APDVND = app.PPVEND
		LEFT JOIN MHD32.HOSPF010.VENDMAST v on v.avvend = app.ppvend
											and v.avhosp = app.pphosp
	GROUP BY
	 	app.ppposthosp
	    ,app.ppvend
		,v.avname
	    ,app.ppinv
		,apd.appostdate
	    ,app.ppbkcd 
	    ,app.ppckno
	    ,app.ispppddt
	    ,app.isppckpt
	    ,app.ppgros
		,apd.apdamtinv
	    ,apd.apdponm
		,apd.APDGLNM
	') c
END
GO
