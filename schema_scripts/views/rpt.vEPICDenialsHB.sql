/*HB*/
	CREATE VIEW rpt.vEPICDenialsHB as
	SELECT
		bdc.*
	FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[Clarity].[ORGFILTER].V_ARHB_BDC bdc
	WHERE 1=1
		and bdc.BDC_TYPE = 'Denial'
		--and bdc.BDC_ID in (18080832,18080833,18080834)
GO
