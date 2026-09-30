CREATE view [dim].[vPBProcedureCodes] as 
-- 9/29/2026 - Repointed from hpi_etl.dbo.PBProcedureCodess to dim.PBProcedureCodes (maintained by the HPI app).
SELECT p.ProcedureCodeID                              AS Id
      ,p.ProcedureCode
      ,p.CptDescription
      ,CAST(CASE WHEN p.IsActive = 1 THEN 0 ELSE 1 END AS bit) AS IsDeleted
      ,p.ChargeCount
      ,p.TotalCharges
      ,p.LastPostDate
      ,p.IsLocationDependent                          AS ProcedureCodeIsLocationDependent
      ,p.InPlay                                       AS ProcedureCodeInPlay
      ,p.THPLab                                       AS ProcedureCodeTHPLab
      ,p.CategoryID                                   AS ProcedureCodeCategoryId
      ,p.ServiceLineID                                AS ProcedureCodeServiceLineId
      ,p.DHSCategoryID                                AS ProcedureCodeDHSCategoryId
      ,p.FirstPostDate
      ,p.CreatedDatetime                              AS CreatedDate
      ,p.UpdatedDatetime                              AS ModifiedDate
      ,p.ModifiedBy
      ,CAST(NULL AS datetime)                         AS DeletedDate
      ,CAST(NULL AS varchar(100))                     AS DeletedBy
      ,p.IsActive
      ,p.IsMapped                                     AS Mapped
FROM dim.PBProcedureCodes p
GO
