CREATE TABLE [stg].[ModMed_Financial_Category] (
    [financial_category_id] VARCHAR(20) NULL,
    [firm_id] VARCHAR(20) NULL,
    [category_name] VARCHAR(100) NULL,
    [is_self_pay] BIT NULL,
    [category_type] VARCHAR(20) NULL,
    [patient_responsible] BIT NULL,
    [rcm_category] VARCHAR(100) NULL,
    [active] BIT NULL,
    [firm_global_id] VARCHAR(10) NULL
);
GO
