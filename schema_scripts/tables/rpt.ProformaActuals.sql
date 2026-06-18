CREATE TABLE [rpt].[ProformaActuals] (
    [ProformaActualID] INT IDENTITY(1,1) NOT NULL,
    [ProformaActualFiscalYear] INT NOT NULL,
    [ProformaActualFiscalPeriod] INT NOT NULL,
    [ProformaActualProviderFullName] NVARCHAR(255) NOT NULL,
    [ProformaActualReportingProviderID] NVARCHAR(50) NOT NULL,
    [ProformaActualFormattedDate] DATE NOT NULL,
    [ProformaActualOfficeVisitsSum] INT NOT NULL DEFAULT ((0)),
    [ProformaActualSurgicalVisitsSum] INT NOT NULL DEFAULT ((0)),
    [ProformaActualLoadDatetime] DATETIME NOT NULL DEFAULT (getdate()),
    CONSTRAINT [PK__Proforma__92073714BC9CD4CB] PRIMARY KEY ([ProformaActualID])
);
GO
