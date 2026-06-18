CREATE TABLE [stg].[PBProcedureCodeCategories] (
    [ProcedureCode] VARCHAR(30) NULL,
    [ProcedureCodeCategory] VARCHAR(100) NULL,
    [ProcedureCodeSubCategory] VARCHAR(100) NULL,
    [ProcedureCodeServiceLine] VARCHAR(100) NULL,
    [ProcedureCodeIsLocationDependent] BIT NULL,
    [ProcedureCodePriority] INT NULL,
    [ProcedureCodeDHSCategory] VARCHAR(30) NULL,
    [ProcedureCodeInPlay] VARCHAR(3) NULL,
    [ProcedureCodeTHPLab] VARCHAR(3) NULL
);
GO
