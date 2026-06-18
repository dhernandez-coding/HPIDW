CREATE TABLE [dim].[ProcedureCodes] (
    [ProcedureCodeID] VARCHAR(50) NOT NULL,
    [ProcedureCodeDataSourceID] INT NOT NULL,
    [ProcedureCodeSourceID] VARCHAR(50) NOT NULL,
    [ProcedureCode] VARCHAR(50) NOT NULL,
    [ProcedureCodeInsuranceDescription] VARCHAR(200) NULL,
    [ProcedureCodeStatementDescription] VARCHAR(200) NULL,
    [ProcedureCodeType] VARCHAR(50) NULL,
    [ProcedureCodeCategoryID] VARCHAR(50) NULL,
    [ProcedureCodeCategoryAbbreviation] VARCHAR(50) NULL,
    [ProcedureCodeCategoryDescription] VARCHAR(50) NULL,
    [ProcedureCodeSelfPay] BIT NULL,
    [ProcedureCodeEnableSplitBilling] BIT NULL,
    [ProcedureCodeInfusion] BIT NULL,
    [ProcedureCodeIsActive] BIT NULL,
    [ProcedureCodeUpdatedDateTime] DATETIME NULL,
    CONSTRAINT [PK_ProcedureCodes] PRIMARY KEY ([ProcedureCodeID])
);
GO
