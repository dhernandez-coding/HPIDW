CREATE TABLE [stg].[THPTransactions] (
    [Trans_Number] NVARCHAR(50) NULL,
    [Type] NVARCHAR(100) NULL,
    [Entered_Last_Modified] DATETIME NULL,
    [Date] DATE NULL,
    [Num] NVARCHAR(100) NULL,
    [Class] NVARCHAR(150) NULL,
    [Name] NVARCHAR(255) NULL,
    [Memo] NVARCHAR(300) NULL,
    [Account] NVARCHAR(255) NULL,
    [Account_Type] NVARCHAR(100) NULL,
    [Clr] NVARCHAR(50) NULL,
    [Split] NVARCHAR(200) NULL,
    [Debit] DECIMAL(18,2) NULL,
    [Credit] DECIMAL(18,2) NULL,
    [Original_Amount] DECIMAL(18,2) NULL,
    [Practice] NVARCHAR(50) NULL,
    [UpdateDateTime] DATETIME NULL,
    [Provider] NVARCHAR(255) NULL
);
GO
