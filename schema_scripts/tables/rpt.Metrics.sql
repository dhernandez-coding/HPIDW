CREATE TABLE [rpt].[Metrics] (
    [MetricID] INT IDENTITY(1,1) NOT NULL,
    [MetricName] VARCHAR(100) NULL,
    [MetricDescription] VARCHAR(300) NULL,
    [MetricQuerySource] VARCHAR(100) NULL,
    [MetricLoadProcedure] VARCHAR(100) NULL,
    [MetricTypeID] INT NULL,
    [MetricCategory] VARCHAR(20) NULL,
    [MetricCreateDate] DATE NULL,
    [MetricUpdateDate] DATE NULL,
    CONSTRAINT [PK__Metrics__5610564584458A64] PRIMARY KEY ([MetricID])
);
GO
