CREATE TABLE [rpt].[MetricTypes] (
    [MetricTypeID] INT IDENTITY(1,1) NOT NULL,
    [MetricTypeName] VARCHAR(100) NULL,
    [MetricTypeDescription] VARCHAR(300) NULL,
    [MetricTypeUpdateDate] DATE NULL,
    CONSTRAINT [PK__MetricTy__79DBA04480996943] PRIMARY KEY ([MetricTypeID])
);
GO
