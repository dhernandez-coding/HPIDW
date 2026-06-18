CREATE TABLE [stg].[ReportBoardPacketTPG] (
    [Category_L0] NVARCHAR(155) NULL,
    [Category_L1] NVARCHAR(155) NULL,
    [Category_L2] NVARCHAR(155) NULL,
    [Category_L3] NVARCHAR(155) NULL,
    [Category_L4] NVARCHAR(155) NULL,
    [Category_L5] NVARCHAR(155) NULL,
    [Account] NVARCHAR(255) NULL,
    [Period_Current_Name] NVARCHAR(100) NULL,
    [Amount_Current] DECIMAL(18,2) NULL,
    [Period_Prior_Name] NVARCHAR(100) NULL,
    [Amount_Prior] DECIMAL(18,2) NULL,
    [Amount_Year] DECIMAL(18,2) NULL,
    [Indent_Level] INT NULL,
    [Source_Row] INT NULL,
    [Location] NVARCHAR(100) NULL,
    [UpdateDateTime] DATETIME NULL DEFAULT (getdate())
);
GO
