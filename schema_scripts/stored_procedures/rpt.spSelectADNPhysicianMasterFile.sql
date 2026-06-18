-- =============================================
-- Author:		XX
-- Create date: 08/11/2023
-- Description:	
-- Change Control
--	
-- =============================================
CREATE PROCEDURE [rpt].[spSelectADNPhysicianMasterFile]
AS
BEGIN
SET NOCOUNT ON;

SELECT 
370192 AS [Hospital Identifier]
,SER.PROV_ID AS [Physician Identifier]
,COALESCE(SER.EXTERNAL_NAME,SER.PROV_NAME) AS [Physicians Full Name]
--,'' AS [Hospitals Internal Specialty Code]
--,'' AS [ADN Standard Specialty Code]
FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].CLARITY_SER SER
WHERE 
SER.PROV_ID NOT IN ('0','10') --TEST / NULL VALUES

union all

SELECT 
370203 AS [Hospital Identifier]
,SER.PROV_ID AS [Physician Identifier]
,COALESCE(SER.EXTERNAL_NAME,SER.PROV_NAME) AS [Physicians Full Name]
--,'' AS [Hospitals Internal Specialty Code]
--,'' AS [ADN Standard Specialty Code]
FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].CLARITY_SER SER
WHERE 
SER.PROV_ID NOT IN ('0','10') --TEST / NULL VALUES

END
GO
