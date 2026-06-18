CREATE PROCEDURE [stg].[spEPICReloadDimCPTCode] AS

-- =============================================
-- Author: Chris Cross
-- Create date: 9/1/2023
-- Description:	Reload CPT Codes from EPIC
-- Change control: 
-- 1. 10/29/2025 - Diego Hernandez - Modified to use OPENQUERY for data retrieval

-- =============================================


 DROP TABLE IF EXISTS #OneCPT

 SELECT
  CPT_CODE as CPTCode
  ,RVU_WORK_COMPON as RVU
  ,NAME_HISTORY as CPTDescription
  ,CONTACT_DATE as EffectiveStartDate --ISNULL(lead(CONTACT_DATE,1) over(partition by CPT_CODE order by CONTACT_DATE),'2099-12-31 00:00:00.000') as EffectiveEndDate
  ,ROW_NUMBER() OVER(PARTITION BY CPT_CODE, CONTACT_DATE ORDER BY CPT_Code) as CPTrow_num

  INTO #OneCPT
  FROM 
  -- Subquery to take less CPT Codes from several NAME_HISTORYs
  (SELECT 
    CPT_CODE,
    RVU_WORK_COMPON,
    NAME_HISTORY,
    ROW_NUMBER() OVER (PARTITION BY CPT_CODE, CONTACT_DATE ORDER BY CONTACT_DATE DESC) AS row_num,
    CONTACT_COMMENT,
    CONTACT_DATE,
    CONTACT_TYPE_C
FROM OPENQUERY([CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM],
'
    SELECT 
        CPT_CODE,
        RVU_WORK_COMPON,
        NAME_HISTORY,
        ROW_NUMBER() OVER (PARTITION BY CPT_CODE, CONTACT_DATE ORDER BY CONTACT_DATE DESC) AS row_num,
        CONTACT_COMMENT,
        CONTACT_DATE,
        CONTACT_TYPE_C
    FROM [Clarity].[ORGFILTER].[CLARITY_EAP_OT]
    WHERE 1=1
      AND CONTACT_COMMENT = ''CMS data import''
      AND CONTACT_DATE >= ''2020-01-01''
      AND CONTACT_TYPE_C = 2
      AND CPT_CODE IS NOT NULL
') AS ot ) eap
   
  WHERE 1=1 
  AND eap.row_num = 1
  
  --and cpt_code = '22849'



 TRUNCATE TABLE dim.CPTCode
 INSERT INTO dim.CPTCode

   SELECT
     CONCAT('5~',CPTCode,'~',FORMAT(EffectiveStartDate,'MMddyyyy'),'~',FORMAT(ISNULL(lead(EffectiveStartDate,1) over(partition by CPTCODE order by EffectiveStartDate),'2099-12-31 00:00:00.000'),'MMddyyyy')) as CPTCodeID 
	,5 as CPTCodeDatasourceID 
	,CPTCode
	,RVU
	,CPTDescription
	,EffectiveStartDate
	,ISNULL(lead(EffectiveStartDate,1) over(partition by CPTCODE order by EffectiveStartDate),'2099-12-31 00:00:00.000') as EffectiveEndDate
	,CASE WHEN lead(EffectiveStartDate,1) over(partition by CPTCODE order by EffectiveStartDate) IS NULL THEN 1 ELSE 0 END as CPTCodeIsActive
	,GETDATE() as CPTCodeUpdatedDatetime

FROM #OneCPT
WHERE CPTrow_num = 1
ORDER BY CPTCode


--------- ###################################### OLD QUERY ###################################################################
---- CTE to take 1 CPT Code from multiple effective dates

-- DROP TABLE IF EXISTS #OneCPT

-- SELECT
--  CPT_CODE as CPTCode
--  ,RVU_WORK_COMPON as RVU
--  ,NAME_HISTORY as CPTDescription
--  ,CONTACT_DATE as EffectiveStartDate --ISNULL(lead(CONTACT_DATE,1) over(partition by CPT_CODE order by CONTACT_DATE),'2099-12-31 00:00:00.000') as EffectiveEndDate
--  ,ROW_NUMBER() OVER(PARTITION BY CPT_CODE, CONTACT_DATE ORDER BY CPT_Code) as CPTrow_num

--  INTO #OneCPT
--  FROM 
--  -- Subquery to take less CPT Codes from several NAME_HISTORYs
--  (SELECT 

--   CPT_CODE
--  ,RVU_WORK_COMPON
--  ,NAME_HISTORY
--  ,ROW_NUMBER() OVER(PARTITION BY CPT_CODE, CONTACT_DATE ORDER BY CONTACT_DATE desc) as row_num
--  ,CONTACT_COMMENT 
--  ,CONTACT_DATE 
--  ,CONTACT_TYPE_C 
  
--  FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].CLARITY.[ORGFILTER].[CLARITY_EAP_OT]
--  WHERE 1=1
--	  AND CONTACT_COMMENT = 'CMS data import'
--	  AND CONTACT_DATE >= '2020-01-01'
--	  AND CONTACT_TYPE_C = 2
--	  AND CPT_CODE IS NOT NULL
   
--  ) eap
   
--  WHERE 1=1 
--  AND eap.row_num = 1
  
--  --and cpt_code = '22849'



-- TRUNCATE TABLE dim.CPTCode
-- INSERT INTO dim.CPTCode

--   SELECT
--     CONCAT('5~',CPTCode,'~',FORMAT(EffectiveStartDate,'MMddyyyy'),'~',FORMAT(ISNULL(lead(EffectiveStartDate,1) over(partition by CPTCODE order by EffectiveStartDate),'2099-12-31 00:00:00.000'),'MMddyyyy')) as CPTCodeID 
--	,5 as CPTCodeDatasourceID 
--	,CPTCode
--	,RVU
--	,CPTDescription
--	,EffectiveStartDate
--	,ISNULL(lead(EffectiveStartDate,1) over(partition by CPTCODE order by EffectiveStartDate),'2099-12-31 00:00:00.000') as EffectiveEndDate
--	,CASE WHEN lead(EffectiveStartDate,1) over(partition by CPTCODE order by EffectiveStartDate) IS NULL THEN 1 ELSE 0 END as CPTCodeIsActive
--	,GETDATE() as CPTCodeUpdatedDatetime

--FROM #OneCPT
--WHERE CPTrow_num = 1
--ORDER BY CPTCode












 -- Testing --



-- TRUNCATE TABLE dim.CPTCode

 -- DROP TABLE dim.CPTCode
  
 -- ALTER TABLE dim.CPTCode
 -- DROP COLUMN CPTDescription

 -- ALTER TABLE dim.CPTCode
 -- ADD CPTEffectiveEndDate datetime
 -- UPDATE dim.CPTCode SET CPTEffectiveEndDate = EffectiveEndDate
 -- ALTER TABLE dim.CPTCode DROP COLUMN EffectiveEndDate


 -- --UPDATE dim.CPTCode
  --SET
GO
