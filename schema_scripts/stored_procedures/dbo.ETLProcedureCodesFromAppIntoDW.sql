Create Procedure ETLProcedureCodesFromAppIntoDW
as

--etl into the cpt code table records that dont currently exist in it.
Insert into HPIDW.dim.CPTCode
select 
Concat(Concat(Concat(0,'~'), Concat(PBPC.ProcedureCode,'~')), Replace(Cast(PBPC.EffectiveStartDate as varchar(60)), ' ' , '')),
0, --App is soure idc
PBPC.ProcedureCode,
PBPC.RVU,
PBPC.CPTDescription,
PBPC.EffectiveStartDate,
PBPC.EffectiveEndDate,
 CASE 
        WHEN PBPC.IsDeleted = 1 THEN 0
        WHEN PBPC.IsDeleted = 0 THEN 1
        ELSE NULL
    END AS CPTCodeIsActive,
	GETDATE()
From [HPIApp].[dbo].[PBProcedureCodes] PBPC
LEFT JOIN HPIApp.dbo.DHSCategories DHSC on PBPC.ProcedureCodeDHSCategoryId = DHSC.DHSCategoryID
LEFT JOIN HPIApp.dbo.ServiceLines SL on PBPC.ProcedureCodeServiceLineId= SL.ServiceLineID
LEFT JOIN HPIApp.dbo.PBProcedureCategories PBPCs on PBPC.ProcedureCodeCategoryId= PBPCs.Id
where ProcedureCode not in
(Select CPTCode from HPIDW.dim.CPTCode)
--update cpt codes with the values in the app
UPDATE HPIDW.dim.CPTCode
SET 
cptCode.RVU = PBPC.RVU,
cptCode.CPTDescription = PBPC.CPTDescription,
cptCode.EffectiveStartDate = PBPC.EffectiveStartDate,
cptCode.EffectiveEndDate = PBPC.EffectiveEndDate
FROM HPIDW.dim.CPTCode cptCode

JOIN [HPIApp].[dbo].[PBProcedureCodes] PBPC ON cptCode.CPTCode = PBPC.ProcedureCode
LEFT JOIN HPIApp.dbo.DHSCategories DHSC on PBPC.ProcedureCodeDHSCategoryId = DHSC.DHSCategoryID
LEFT JOIN HPIApp.dbo.ServiceLines SL on PBPC.ProcedureCodeServiceLineId= SL.ServiceLineID
LEFT JOIN HPIApp.dbo.PBProcedureCategories PBPCs on PBPC.ProcedureCodeCategoryId= PBPCs.Id;

--etl into the procedure code categories table records that dont currently exist in it.
Insert into [HPIDW].[stg].[PBProcedureCodeCategories]
select 
PBPC.ProcedureCode,
PBPCs.ProcedureCategory,
PBPCs.ProcedureCategoryVisitType,
SL.ServiceLineName,
PBPC.ProcedureCodeIsLocationDependent,
PBPC.ProcedureCodePriority,
 DHSC.DHSCategoryName,
Case
When PBPC.ProcedureCodeInPlay  = 1
	Then 'Y'
	else 'N'
	end as ProcedureCodeInPlay,
Case
When PBPC.ProcedureCodeTHPLab  = 1
	Then 'Y'
	else 'N'
	end as ProcedureCodeTHPLab
From [HPIApp].[dbo].[PBProcedureCodes] PBPC
LEFT JOIN HPIApp.dbo.DHSCategories DHSC on PBPC.ProcedureCodeDHSCategoryId = DHSC.DHSCategoryID
LEFT JOIN HPIApp.dbo.ServiceLines SL on PBPC.ProcedureCodeServiceLineId= SL.ServiceLineID
LEFT JOIN HPIApp.dbo.PBProcedureCategories PBPCs on PBPC.ProcedureCodeCategoryId = PBPCs.Id
where ProcedureCode not in
(Select ProcedureCode from  [HPIDW].[stg].[PBProcedureCodeCategories])
And ProcedureCode is not null;
--update procedure code categories with the values in the app
UPDATE HPIDW.[stg].[PBProcedureCodeCategories]
SET 

HPIDW.[stg].[PBProcedureCodeCategories].ProcedureCodeCategory = PBPCs.ProcedureCategory,
HPIDW.[stg].[PBProcedureCodeCategories].ProcedureCodeSubCategory = PBPCs.ProcedureCategoryVisitType,
HPIDW.[stg].[PBProcedureCodeCategories].ProcedureCodeServiceLine = SL.ServiceLineName,
HPIDW.[stg].[PBProcedureCodeCategories].ProcedureCodeIsLocationDependent= PBPC.ProcedureCodeIsLocationDependent,
HPIDW.[stg].[PBProcedureCodeCategories].ProcedureCodePriority = PBPC.ProcedureCodePriority,
HPIDW.[stg].[PBProcedureCodeCategories].ProcedureCodeDHSCategory = DHSC.DHSCategoryName,
HPIDW.[stg].[PBProcedureCodeCategories].ProcedureCodeInPlay = Case
When PBPC.ProcedureCodeInPlay = 1 Then 'Y'
	else 'N' 
	end ,
HPIDW.[stg].[PBProcedureCodeCategories].ProcedureCodeTHPLab =  Case
When PBPC.ProcedureCodeTHPLab = 1 then 'Y'
	else 'N'
	end

FROM HPIDW.[stg].[PBProcedureCodeCategories] category
JOIN [HPIApp].[dbo].[PBProcedureCodes] PBPC ON category.ProcedureCode = PBPC.ProcedureCode
LEFT JOIN HPIApp.dbo.DHSCategories DHSC on PBPC.ProcedureCodeDHSCategoryId = DHSC.DHSCategoryID
LEFT JOIN HPIApp.dbo.ServiceLines SL on PBPC.ProcedureCodeServiceLineId= SL.ServiceLineID
LEFT JOIN HPIApp.dbo.PBProcedureCategories PBPCs on PBPC.ProcedureCodeCategoryId= PBPCs.Id;

--select * From [HPIDW].[stg].[PBProcedureCodeCategories] 
--select * From  [HPIApp].[dbo].[PBProcedureCodes]
GO
